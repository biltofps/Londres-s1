-----------------------------------------------------------------------
-- Database setup
--  * rsg_bank_opened: which citizen has an account at which bank
--    (balances themselves live in RSG-Core money types)
--  * one-off migration from rsg-banking v3 (rsg_bank_accounts table):
--    the old table is renamed to rsg_bank_accounts_old first, so this only
--    ever runs once and the original balances stay as a backup
-----------------------------------------------------------------------
local RSGCore = exports['rsg-core']:GetCoreObject()

BankingDBReady = false

-- old branch id -> money type
local LEGACY = {
    valentine  = 'valbank',
    strawberry = 'valbank',
    armadillo  = 'armbank',
    rhodes     = 'rhobank',
    blackwater = 'blkbank',
    saintdenis = 'bank',
}

local function tableExists(name)
    return (MySQL.scalar.await(
        'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?', { name }) or 0) > 0
end

---Runs once, when rsg_bank_opened is first created: characters that already hold
---money in a bank get that account opened for free, so nobody's money is locked.
local function openExistingBalances()
    local n = 0
    for _, row in ipairs(MySQL.query.await('SELECT citizenid, money FROM players') or {}) do
        local money = json.decode(row.money or '{}') or {}
        for bankId in pairs(Config.Banks) do
            if (tonumber(money[bankId]) or 0) > 0 then
                MySQL.update.await('INSERT IGNORE INTO rsg_bank_opened (citizenid, bank) VALUES (?, ?)', { row.citizenid, bankId })
                n = n + 1
            end
        end
    end
    print(('[rsg-banking] ^2Opened %s accounts for characters with existing balances^7'):format(n))
end

local function createTables()
    local isNew = not tableExists('rsg_bank_opened')
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `rsg_bank_opened` (
            `citizenid` VARCHAR(50) NOT NULL,
            `bank` VARCHAR(50) NOT NULL,
            `opened_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `last_fee_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`, `bank`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    if isNew then openExistingBalances() end
end

local function migrate()
    if not tableExists('rsg_bank_accounts') or tableExists('rsg_bank_accounts_old') then return end
    MySQL.query.await('RENAME TABLE rsg_bank_accounts TO rsg_bank_accounts_old')

    local rows = MySQL.query.await('SELECT citizenid, bank, balance FROM rsg_bank_accounts_old') or {}
    local total, count = 0, 0
    for _, row in ipairs(rows) do
        local moneyType = LEGACY[row.bank] or 'bank'
        local amount = tonumber(row.balance) or 0
        -- old accounts stay open (free) at the matching bank
        MySQL.update.await('INSERT IGNORE INTO rsg_bank_opened (citizenid, bank) VALUES (?, ?)', { row.citizenid, moneyType })
        if amount > 0 then
            local Player = RSGCore.Functions.GetPlayerByCitizenId(row.citizenid)
            local ok
            if Player then
                ok = Player.Functions.AddMoney(moneyType, amount, 'bank-migration')
            else
                ok = CreditOffline(row.citizenid, moneyType, amount)
            end
            if ok then
                total, count = total + amount, count + 1
            else
                print(('[rsg-banking] ^1migration: could not move $%.2f (%s) for %s^7'):format(amount, row.bank, row.citizenid))
            end
        end
    end
    print(('[rsg-banking] ^2Migration done: $%.2f moved from %s old branch accounts^7'):format(total, count))
    BankLog('system', nil, {
        { name = 'Accounts', value = tostring(count), inline = true },
        { name = 'Total moved', value = BankMoney(total), inline = true },
    }, { description = 'Old branch accounts migrated to RSG-Core money types' })
end

MySQL.ready(function()
    local ok, err = pcall(createTables)
    if not ok then
        print(('[rsg-banking] ^1Database setup failed:^7 %s'):format(err))
        return
    end
    BankingDBReady = true
    print('[rsg-banking] ^2Database ready^7')
    ok, err = pcall(migrate)
    if not ok then print(('[rsg-banking] ^1Migration failed:^7 %s'):format(err)) end
end)
