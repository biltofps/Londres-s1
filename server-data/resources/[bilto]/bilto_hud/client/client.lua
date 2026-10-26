--[[
    bilto_hud - Client

    Desenha a HUD e cuida do editor. A logica de fome/sede/estresse/temperatura
    fica em client/status.lua (HudStatus e compartilhado entre os dois arquivos).

    Comandos:
        /hud        -> abre o editor (modelos, estilos, icones, cores, posicoes)
        /togglehud  -> esconde/mostra a HUD
]]

local RSGCore = exports['rsg-core']:GetCoreObject()
local KVP_KEY = 'bilto_hud:layout'
local KVP_PRESETS = 'bilto_hud:presets'

local nuiReady = false
local editorOpen = false
local hudEnabled = true
local lastShow = nil
local money = { cash = 0, gold = 0, bank = 0, bloodmoney = 0 }

------------------------------------------------
-- utils
------------------------------------------------
local function notify(title, description, notifyType)
    if GetResourceState('bilto_notify') == 'started' then
        exports['bilto_notify']:Notify({ title = title, description = description, type = notifyType, duration = 4000, position = 'center-right' })
    else
        lib.notify({ title = title, description = description, type = notifyType == 'info' and 'inform' or notifyType, duration = 4000 })
    end
end

local function round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

local function updateMoney(playerData)
    if not playerData or not playerData.money then return end
    money.cash = playerData.money.cash or 0
    money.gold = playerData.money.gold or 0
    money.bank = playerData.money.bank or 0
    money.bloodmoney = playerData.money.bloodmoney or 0
end

local function getHorseStats()
    local horse = GetMount(cache.ped)
    if not horse or horse == 0 then return 0, 0, 0 end

    local maxHealth = Citizen.InvokeNative(0x4700A416E8324EF3, horse, Citizen.ResultAsInteger())
    local maxStamina = Citizen.InvokeNative(0xCB42AFE2B613EE55, horse, Citizen.ResultAsFloat())
    local dirt = Citizen.InvokeNative(0x147149F2E909323C, horse, 16, Citizen.ResultAsInteger())

    local health = maxHealth > 0 and Citizen.InvokeNative(0x82368787EA73C0F7, horse) / maxHealth * 100 or 0
    local stamina = maxStamina > 0 and Citizen.InvokeNative(0x775A1CA7893AA8B5, horse, Citizen.ResultAsFloat()) / maxStamina * 100 or 0

    return round(health, 1), round(stamina, 1), 100 - dirt
end

------------------------------------------------
-- layout (cache local + banco)
------------------------------------------------
local function loadLayout()
    local cached = GetResourceKvpString(KVP_KEY)
    local layout = cached and json.decode(cached) or nil

    SendNUIMessage({
        action = 'init',
        layout = layout,
        config = {
            lowThreshold = Config.LowThreshold,
            voiceModes = Config.VoiceModes,
            tempUnit = Config.TempUnit,
            defaultPreset = Config.DefaultPreset,
            maxPresets = Config.MaxPresets,
            logo = (Config.LogoUrl and Config.LogoUrl ~= '') and Config.LogoUrl or 'assets/logo.png',
        }
    })

    local cachedPresets = GetResourceKvpString(KVP_PRESETS)
    if cachedPresets then
        SendNUIMessage({ action = 'setPresets', presets = json.decode(cachedPresets) })
    end

    local remote = lib.callback.await('bilto_hud:server:getLayout', false)
    if remote then
        SetResourceKvp(KVP_KEY, json.encode(remote))
        SendNUIMessage({ action = 'setLayout', layout = remote })
    end

    local remotePresets = lib.callback.await('bilto_hud:server:getPresets', false)
    if remotePresets then
        SetResourceKvp(KVP_PRESETS, json.encode(remotePresets))
        SendNUIMessage({ action = 'setPresets', presets = remotePresets })
    end
end

RegisterNUICallback('ready', function(_, cb)
    cb(1)
    if nuiReady then return end
    nuiReady = true
    CreateThread(loadLayout)
end)

RegisterNUICallback('saveLayout', function(data, cb)
    cb(1)
    if type(data) ~= 'table' or type(data.layout) ~= 'table' then return end
    SetResourceKvp(KVP_KEY, json.encode(data.layout))
    TriggerServerEvent('bilto_hud:server:saveLayout', data.layout)
    notify('HUD', 'Layout salvo com sucesso.', 'success')
end)

-- presets proprios: a NUI manda a lista inteira sempre que muda (salvar, atualizar, excluir)
RegisterNUICallback('savePresets', function(data, cb)
    cb(1)
    if type(data) ~= 'table' or type(data.presets) ~= 'table' then return end
    SetResourceKvp(KVP_PRESETS, json.encode(data.presets))
    TriggerServerEvent('bilto_hud:server:savePresets', data.presets)
end)

------------------------------------------------
-- editor
------------------------------------------------
local function closeEditor()
    editorOpen = false
    SetNuiFocus(false, false)
end

RegisterCommand(Config.EditorCommand, function()
    if editorOpen or not nuiReady then return end
    editorOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openEditor' })
end, false)

RegisterNUICallback('closeEditor', function(_, cb)
    cb(1)
    closeEditor()
end)

RegisterCommand(Config.ToggleCommand, function()
    hudEnabled = not hudEnabled
    notify('HUD', hudEnabled and 'HUD ativada.' or 'HUD escondida.', 'info')
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and editorOpen then
        SetNuiFocus(false, false)
    end
end)

------------------------------------------------
-- integracao com outros scripts
------------------------------------------------
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    updateMoney(RSGCore.Functions.GetPlayerData())
end)

RegisterNetEvent('RSGCore:Player:SetPlayerData', function(playerData)
    updateMoney(playerData)
end)

-- disparado pelo rsg-core sempre que o dinheiro muda (mostra o +/- na HUD)
RegisterNetEvent('hud:client:OnMoneyChange', function(moneyType, amount, isMinus)
    SendNUIMessage({
        action = 'moneyChange',
        type = moneyType,
        amount = tonumber(amount) or 0,
        minus = isMinus == true or isMinus == 'remove',
    })
end)

-- /cash, /gold, /bloodmoney do rsg-hud: destaca o elemento mesmo se estiver oculto
RegisterNetEvent('hud:client:ShowAccounts', function(moneyType, amount)
    if money[moneyType] ~= nil then money[moneyType] = tonumber(amount) or money[moneyType] end
    SendNUIMessage({ action = 'flash', element = moneyType })
end)

------------------------------------------------
-- loop principal
------------------------------------------------
local lastData = nil

local function hasChanged(data)
    if not lastData then return true end
    for k, v in pairs(data) do
        if lastData[k] ~= v then return true end
    end
    return false
end

CreateThread(function()
    updateMoney(RSGCore.Functions.GetPlayerData())

    while true do
        Wait(Config.TickRate)

        if nuiReady then
            local state = LocalPlayer.state
            local show = editorOpen or (
                state.isLoggedIn
                and hudEnabled
                and HudStatus.uiVisible
                and not IsPauseMenuActive()
                and not IsCinematicCamRendering()
                and not state.isBathingActive
                and not state.inClothingStore
            )

            if show then
                local ped = cache.ped
                local mounted = IsPedOnMount(ped)
                local horseHealth, horseStamina, horseClean = 0, 0, 0
                if mounted then
                    horseHealth, horseStamina, horseClean = getHorseStats()
                end

                local maxHealth = GetEntityMaxHealth(ped)
                if not maxHealth or maxHealth <= 0 then maxHealth = 600 end

                local proximity = state.proximity
                local talking = Citizen.InvokeNative(0x33EEF97F, cache.playerId)

                -- status em inteiros (e o que a HUD mostra): evita mandar mensagem por variacao de 0.01
                local data = {
                    health = round(GetEntityHealth(ped) / maxHealth * 100),
                    stamina = round(Citizen.InvokeNative(0x0FF421E467373FCF, cache.playerId, Citizen.ResultAsFloat()) or 0),
                    hunger = round(state.hunger or 100),
                    thirst = round(state.thirst or 100),
                    cleanliness = round(state.cleanliness or 100),
                    stress = round(state.stress or 0),
                    onHorse = mounted,
                    horse_health = round(horseHealth),
                    horse_stamina = round(horseStamina),
                    horse_clean = round(horseClean),
                    talking = talking == true or talking == 1,
                    voiceIndex = proximity and proximity.index or 2,
                    temp = HudStatus.temperature,
                    cash = money.cash,
                    gold = money.gold,
                    bank = money.bank,
                    bloodmoney = money.bloodmoney,
                    id = GetPlayerServerId(cache.playerId),
                    hour = GetClockHours(),
                    minute = GetClockMinutes(),
                    mail = (state.telegramUnreadMessages or 0) > 0,
                    outlaw = HudStatus.outlaw,
                }

                -- so manda para a NUI quando algo mudou (antes mandava tudo 4x por segundo)
                if lastShow ~= true or hasChanged(data) then
                    lastData = data
                    SendNUIMessage({ action = 'tick', show = true, data = data })
                end
                lastShow = true
            elseif lastShow ~= false then
                SendNUIMessage({ action = 'tick', show = false })
                lastShow = false
            end
        end
    end
end)
