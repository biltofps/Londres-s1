-----------------------------------------------------------------------
-- Account maintenance fee
-- Every Config.Account.maintenanceDays the fee is taken from the balance
-- of that bank. If the balance is short, whatever is left is taken.
-----------------------------------------------------------------------
local RSGCore = exports['rsg-core']:GetCoreObject()

local function chargeDue()
    local days = tonumber(Config.Account.maintenanceDays) or 0
    if days <= 0 then return end
    local rows = MySQL.query.await(
        'SELECT citizenid, bank FROM rsg_bank_opened WHERE last_fee_at <= (NOW() - INTERVAL ? DAY)', { days }) or {}

    for _, row in ipairs(rows) do
        local bank = Config.Banks[row.bank]
        local _, fee = BankFees(row.bank)
        if bank and fee > 0 then
            local Player = RSGCore.Functions.GetPlayerByCitizenId(row.citizenid)
            if Player then
                local charged = math.min(fee, tonumber(Player.PlayerData.money[row.bank]) or 0)
                if charged > 0 then
                    Player.Functions.RemoveMoney(row.bank, charged, 'bank-maintenance')
                    BankNotify(Player.PlayerData.source, 'sv_maintenance_charged', 'inform', ('%.2f'):format(charged), bank.label)
                end
            else
                DebitOffline(row.citizenid, row.bank, fee)
            end
        end
        MySQL.update.await('UPDATE rsg_bank_opened SET last_fee_at = NOW() WHERE citizenid = ? AND bank = ?', { row.citizenid, row.bank })
    end

    if #rows > 0 then
        BankLog('maintenance', nil, { { name = 'Accounts charged', value = tostring(#rows), inline = true } })
    end
end

CreateThread(function()
    while not BankingDBReady do Wait(1000) end
    while true do
        local ok, err = pcall(chargeDue)
        if not ok then print(('[rsg-banking] ^1maintenance error:^7 %s'):format(err)) end
        Wait(math.max(1, tonumber(Config.Account.checkMinutes) or 30) * 60000)
    end
end)
