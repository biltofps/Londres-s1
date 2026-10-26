local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local busy     = {}   -- [src] = true while a transaction is running
local lastCall = {}   -- [src] = GetGameTimer() of last request (rate limit)

---------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------
local function round(n) return math.floor(n * 100 + 0.5) / 100 end
local function m(n) return ('%.2f'):format(tonumber(n) or 0) end -- money for notifications

function BankNotify(src, key, ntype, ...)
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('cl_title'), description = locale(key, ...), type = ntype or 'inform', duration = 5000
    })
end
local notify = BankNotify

local function rateLimited(src)
    local now = GetGameTimer()
    if lastCall[src] and now - lastCall[src] < Config.Cooldown then BankLogBlocked(src, 'Rate limited'); return true end
    lastCall[src] = now
    return false
end

local function nearBank(src, bankId)
    local bank = type(bankId) == 'string' and Config.Banks[bankId]
    if not bank then return false end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    return #(GetEntityCoords(ped) - bank.coords) <= Config.ServerMaxDistance
end

local function validAmount(src, amount)
    amount = tonumber(amount)
    if not amount or amount ~= amount or amount == math.huge then
        notify(src, 'sv_invalid_amount', 'error'); return nil
    end
    amount = round(amount)
    if amount < 0.01 then notify(src, 'sv_invalid_amount', 'error'); return nil end
    if amount > Config.MaxTransaction then
        notify(src, 'sv_max_amount', 'error', m(Config.MaxTransaction)); return nil
    end
    return amount
end

local function fullName(charinfo)
    charinfo = charinfo or {}
    return ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''):match('^%s*(.-)%s*$')
end

---Opening / maintenance fee for a bank (a bank may override the global value)
function BankFees(bankId)
    local b = Config.Banks[bankId] or {}
    return math.max(0, tonumber(b.openFee or Config.Account.openFee) or 0),
           math.max(0, tonumber(b.maintenanceFee or Config.Account.maintenanceFee) or 0)
end

---Change a bank money type of a character that is offline (straight into the players row).
---bankId is always a Config.Banks key, so it is safe inside the JSON path. Never goes below 0.
local function changeOffline(cid, bankId, delta)
    local path = ('$.%s'):format(bankId)
    local n = MySQL.update.await(
        ('UPDATE players SET money = JSON_SET(money, \'%s\', GREATEST(ROUND(COALESCE(JSON_EXTRACT(money, \'%s\'), 0) + ?, 2), 0)) WHERE citizenid = ?')
            :format(path, path),
        { delta, cid })
    return (n or 0) > 0
end
function CreditOffline(cid, bankId, amount) return changeOffline(cid, bankId, amount) end
function DebitOffline(cid, bankId, amount) return changeOffline(cid, bankId, -amount) end

---Does the citizen have an account at this bank? (a row in rsg_bank_opened)
function HasAccount(cid, bankId)
    return MySQL.scalar.await('SELECT 1 FROM rsg_bank_opened WHERE citizenid = ? AND bank = ?', { cid, bankId }) ~= nil
end

local function buildData(src, bankId, receipt)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return nil end
    local d = Player.PlayerData
    local bank = Config.Banks[bankId]
    local openFee, maintFee = BankFees(bankId)
    local balance = d.money[bankId] or 0

    local hasAccount, nextFee = HasAccount(d.citizenid, bankId), nil
    if hasAccount and maintFee > 0 then
        local last = MySQL.scalar.await('SELECT UNIX_TIMESTAMP(last_fee_at) FROM rsg_bank_opened WHERE citizenid = ? AND bank = ?', { d.citizenid, bankId })
        nextFee = last and (tonumber(last) + Config.Account.maintenanceDays * 86400) or nil
    end

    return {
        bankId     = bankId,
        label      = bank.label,
        monogram   = bank.monogram,
        motto      = bank.motto,
        founded    = bank.founded,
        code       = bank.code,
        teller     = bank.teller,
        name       = fullName(d.charinfo),
        citizenid  = d.citizenid,
        hasAccount = hasAccount,
        balance    = balance,
        cash       = d.money.cash or 0,
        max        = Config.MaxTransaction,
        openFee    = openFee,
        maintFee   = maintFee,
        maintDays  = Config.Account.maintenanceDays,
        nextFee    = nextFee,
        receipt    = receipt,
    }
end

-- DB ready, player lookup, distance, rate limit and per-player lock around every action.
-- needAccount: refuse unless the player has an account at this bank.
-- fn returns a receipt table on success; it is sent to the UI with the refreshed data.
local function guarded(src, bankId, needAccount, fn)
    if not BankingDBReady or busy[src] or rateLimited(src) then return nil end
    if not nearBank(src, bankId) then
        notify(src, 'sv_too_far', 'error')
        BankLogSuspicious(src, 'Transaction attempted away from the bank', bankId)
        return nil
    end
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return nil end
    local cid = Player.PlayerData.citizenid

    busy[src] = true
    local ok, res
    if needAccount and not HasAccount(cid, bankId) then
        ok = true
        notify(src, 'sv_no_account', 'error')
    else
        ok, res = pcall(fn, Player, cid)
    end
    busy[src] = nil
    if not ok then print(('[rsg-banking] ^1error:^7 %s'):format(res)) end
    local receipt = ok and type(res) == 'table' and res or nil
    if receipt then
        receipt.id = ('%s-%06d'):format(Config.Banks[bankId].code or '0000', math.random(0, 999999))
        receipt.time = os.time()
    end
    return buildData(src, bankId, receipt)
end

---------------------------------------------------------------------
-- callbacks
---------------------------------------------------------------------
lib.callback.register('rsg-banking:server:getData', function(src, bankId)
    if not BankingDBReady or rateLimited(src) then return nil end
    if not nearBank(src, bankId) then BankLogBlocked(src, 'Menu request away from the bank', tostring(bankId)); return nil end
    return buildData(src, bankId)
end)

lib.callback.register('rsg-banking:server:openAccount', function(src, bankId)
    return guarded(src, bankId, false, function(Player, cid)
        if HasAccount(cid, bankId) then return notify(src, 'sv_account_exists', 'error') end
        local fee = BankFees(bankId)
        if fee > 0 and not Player.Functions.RemoveMoney('cash', fee, 'bank-open-' .. bankId) then
            return notify(src, 'sv_cant_afford_open', 'error', m(fee))
        end
        local n = MySQL.update.await('INSERT IGNORE INTO rsg_bank_opened (citizenid, bank) VALUES (?, ?)', { cid, bankId })
        if (n or 0) == 0 then
            if fee > 0 then Player.Functions.AddMoney('cash', fee, 'bank-open-refund') end
            return notify(src, 'sv_account_exists', 'error')
        end
        local label = Config.Banks[bankId].label
        notify(src, 'sv_account_opened', 'success', label)
        BankLog('account_opened', src, {
            { name = 'Bank', value = label, inline = true },
            { name = 'Fee', value = BankMoney(fee), inline = true },
        })
        return { type = 'opened', amount = fee }
    end)
end)

lib.callback.register('rsg-banking:server:deposit', function(src, bankId, amount)
    return guarded(src, bankId, true, function(Player)
        amount = validAmount(src, amount); if not amount then return end
        if not Player.Functions.RemoveMoney('cash', amount, 'bank-deposit-' .. bankId) then
            return notify(src, 'sv_not_enough_cash', 'error')
        end
        if not Player.Functions.AddMoney(bankId, amount, 'bank-deposit') then
            Player.Functions.AddMoney('cash', amount, 'bank-deposit-refund')
            return notify(src, 'sv_invalid_amount', 'error')
        end
        notify(src, 'sv_deposited', 'success', m(amount))
        local label = Config.Banks[bankId].label
        BankLog('deposit', src, {
            { name = 'Bank', value = label, inline = true },
            { name = 'Amount', value = BankMoney(amount), inline = true },
            { name = 'New Balance', value = BankMoney(Player.PlayerData.money[bankId]), inline = true },
        })
        BankLogLarge('Deposit', src, label, amount)
        return { type = 'deposit', amount = amount }
    end)
end)

lib.callback.register('rsg-banking:server:withdraw', function(src, bankId, amount)
    return guarded(src, bankId, true, function(Player)
        amount = validAmount(src, amount); if not amount then return end
        if not Player.Functions.RemoveMoney(bankId, amount, 'bank-withdraw') then
            return notify(src, 'sv_not_enough_balance', 'error')
        end
        Player.Functions.AddMoney('cash', amount, 'bank-withdraw-' .. bankId)
        notify(src, 'sv_withdrew', 'success', m(amount))
        local label = Config.Banks[bankId].label
        BankLog('withdraw', src, {
            { name = 'Bank', value = label, inline = true },
            { name = 'Amount', value = BankMoney(amount), inline = true },
            { name = 'New Balance', value = BankMoney(Player.PlayerData.money[bankId]), inline = true },
        })
        BankLogLarge('Withdrawal', src, label, amount)
        return { type = 'withdraw', amount = amount }
    end)
end)

-- Transfer to another character's account at this same bank, by citizen id
lib.callback.register('rsg-banking:server:transfer', function(src, bankId, target, amount)
    return guarded(src, bankId, true, function(Player, cid)
        target = type(target) == 'string' and target:upper():match('^%s*([%w]+)%s*$')
        if not target or #target > 50 then return notify(src, 'sv_invalid_citizen', 'error') end
        if target == cid then return notify(src, 'sv_transfer_self', 'error') end
        amount = validAmount(src, amount); if not amount then return end

        local Target = RSGCore.Functions.GetPlayerByCitizenId(target)
        local targetName
        if Target then
            targetName = fullName(Target.PlayerData.charinfo)
        else
            local row = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { target })
            if not row then return notify(src, 'sv_invalid_citizen', 'error') end
            targetName = fullName(json.decode(row.charinfo or '{}'))
        end
        if not HasAccount(target, bankId) then
            return notify(src, 'sv_target_no_account', 'error', targetName, Config.Banks[bankId].label)
        end

        if not Player.Functions.RemoveMoney(bankId, amount, 'bank-transfer-' .. target) then
            return notify(src, 'sv_not_enough_balance', 'error')
        end
        -- re-check: the target may have logged in or out while we waited on the database
        Target = RSGCore.Functions.GetPlayerByCitizenId(target)
        local ok
        if Target then
            ok = Target.Functions.AddMoney(bankId, amount, 'bank-transfer-' .. cid)
        else
            ok = CreditOffline(target, bankId, amount)
        end
        if not ok then
            Player.Functions.AddMoney(bankId, amount, 'bank-transfer-refund')
            return notify(src, 'sv_invalid_citizen', 'error')
        end

        local label = Config.Banks[bankId].label
        notify(src, 'sv_transferred', 'success', m(amount), targetName, target)
        if Target then
            notify(Target.PlayerData.source, 'sv_transfer_received', 'success', m(amount), fullName(Player.PlayerData.charinfo), label)
        end
        BankLog('transfer', src, {
            { name = 'Bank', value = label, inline = true },
            { name = 'Amount', value = BankMoney(amount), inline = true },
            { name = 'To', value = ('%s (%s)%s'):format(targetName, target, Target and '' or ' [offline]'), inline = true },
        })
        BankLogLarge('Transfer', src, label, amount, { { name = 'To', value = target, inline = true } })
        return { type = 'transfer', amount = amount, toName = targetName, toCid = target }
    end)
end)

AddEventHandler('playerDropped', function()
    busy[source], lastCall[source] = nil, nil
end)

---------------------------------------------------------------------
-- admin: /fecharconta [citizenid] [bank]  (bank = valbank, armbank, rhobank, blkbank, bank; empty = all)
-- Only removes the account; any balance stays in that money type.
---------------------------------------------------------------------
RSGCore.Commands.Add('fecharconta', locale('cmd_close_help'), {
    { name = 'citizenid', help = 'Citizen ID' },
    { name = 'bank', help = 'valbank / armbank / rhobank / blkbank / bank' },
}, false, function(src, args)
    local cid = args[1] and args[1]:upper()
    local bankId = args[2] and args[2]:lower()
    if not cid then return notify(src, 'sv_invalid_citizen', 'error') end
    if bankId and not Config.Banks[bankId] then return notify(src, 'cmd_close_bad_bank', 'error') end

    local n
    if bankId then
        n = MySQL.update.await('DELETE FROM rsg_bank_opened WHERE citizenid = ? AND bank = ?', { cid, bankId })
    else
        n = MySQL.update.await('DELETE FROM rsg_bank_opened WHERE citizenid = ?', { cid })
    end
    if (n or 0) == 0 then return notify(src, 'cmd_close_none', 'error', cid) end
    notify(src, 'cmd_close_done', 'success', n, cid)
    BankLog('system', src, {
        { name = 'Citizen ID', value = cid, inline = true },
        { name = 'Bank', value = bankId and Config.Banks[bankId].label or 'all', inline = true },
    }, { description = 'Account(s) closed by admin' })
end, 'admin')
