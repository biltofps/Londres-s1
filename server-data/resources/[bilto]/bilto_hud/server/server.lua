--[[
    bilto_hud - Server
    Guarda o layout da HUD de cada jogador (por license) no banco.
]]

local MAX_LAYOUT_SIZE = 32000   -- caracteres do JSON, evita lixo no banco
local MAX_PRESETS_SIZE = 240000 -- todos os presets salvos de um jogador
local lastSave = {}
local lastPresetSave = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bilto_hud` (
            `license` VARCHAR(64) NOT NULL,
            `layout` LONGTEXT NOT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`license`)
        )
    ]])
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bilto_hud_presets` (
            `license` VARCHAR(64) NOT NULL,
            `presets` LONGTEXT NOT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`license`)
        )
    ]])
end)

local function getLicense(src)
    return GetPlayerIdentifierByType(src, 'license')
end

lib.callback.register('bilto_hud:server:getLayout', function(source)
    local license = getLicense(source)
    if not license then return nil end

    local raw = MySQL.scalar.await('SELECT layout FROM bilto_hud WHERE license = ?', { license })
    if not raw then return nil end

    local ok, layout = pcall(json.decode, raw)
    return ok and layout or nil
end)

RegisterNetEvent('bilto_hud:server:saveLayout', function(layout)
    local src = source
    local license = getLicense(src)
    if not license or type(layout) ~= 'table' or type(layout.elements) ~= 'table' then return end

    local now = GetGameTimer()
    if lastSave[src] and now - lastSave[src] < Config.SaveCooldown then return end
    lastSave[src] = now

    local encoded = json.encode(layout)
    if #encoded > MAX_LAYOUT_SIZE then return end

    MySQL.insert('INSERT INTO bilto_hud (license, layout) VALUES (?, ?) ON DUPLICATE KEY UPDATE layout = VALUES(layout)', {
        license, encoded
    })
end)

------------------------------------------------
-- presets salvos pelo jogador ("Meus presets")
------------------------------------------------
lib.callback.register('bilto_hud:server:getPresets', function(source)
    local license = getLicense(source)
    if not license then return nil end

    local raw = MySQL.scalar.await('SELECT presets FROM bilto_hud_presets WHERE license = ?', { license })
    if not raw then return nil end

    local ok, presets = pcall(json.decode, raw)
    return ok and type(presets) == 'table' and presets or nil
end)

RegisterNetEvent('bilto_hud:server:savePresets', function(presets)
    local src = source
    local license = getLicense(src)
    if not license or type(presets) ~= 'table' then return end

    local now = GetGameTimer()
    if lastPresetSave[src] and now - lastPresetSave[src] < Config.SaveCooldown / 2 then return end
    lastPresetSave[src] = now

    -- valida e limpa: so o que a NUI realmente usa
    local clean = {}
    for i = 1, math.min(#presets, Config.MaxPresets) do
        local p = presets[i]
        if type(p) == 'table' and type(p.data) == 'table' and type(p.data.elements) == 'table' then
            clean[#clean + 1] = {
                id = tostring(p.id or i):sub(1, 24),
                name = tostring(p.name or ('Preset ' .. i)):sub(1, 32),
                date = tonumber(p.date) or 0,
                data = p.data,
            }
        end
    end

    local encoded = json.encode(clean)
    if #encoded > MAX_PRESETS_SIZE then return end

    MySQL.insert('INSERT INTO bilto_hud_presets (license, presets) VALUES (?, ?) ON DUPLICATE KEY UPDATE presets = VALUES(presets)', {
        license, encoded
    })
end)

AddEventHandler('playerDropped', function()
    lastSave[source] = nil
    lastPresetSave[source] = nil
end)

------------------------------------------------
-- herdado do rsg-hud
------------------------------------------------
local RSGCore = exports['rsg-core']:GetCoreObject()

-- /cash, /gold, /bloodmoney: destaca o valor na HUD por alguns segundos
for command, label in pairs({ cash = 'Ver dinheiro', gold = 'Ver ouro', bloodmoney = 'Ver dinheiro sujo' }) do
    RSGCore.Commands.Add(command, label, {}, false, function(source)
        local Player = RSGCore.Functions.GetPlayer(source)
        local amount = Player and Player.PlayerData.money[command]
        if amount ~= nil then
            TriggerClientEvent('hud:client:ShowAccounts', source, command, amount)
        end
    end)
end

lib.callback.register('bilto_hud:server:getOutlawStatus', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return 0 end
    return MySQL.scalar.await('SELECT outlawstatus FROM players WHERE citizenid = ?', { Player.PlayerData.citizenid }) or 0
end)
