--[[
    bilto_hud - Status (logica herdada do rsg-hud)

    Mantem os mesmos eventos/exports do rsg-hud, entao rsg-consume, rsg-canteen,
    rsg-medic, rsg-bathing, rsg-essentials e bilto_admin continuam funcionando sem alteracao.

    Eventos:
        hud:client:UpdateNeeds (hunger, thirst, cleanliness)
        hud:client:UpdateHunger / UpdateThirst / UpdateStress / UpdateCleanliness (valor)
        hud:client:GainStress / RelieveStress (quantidade)
    Exports:
        exports['bilto_hud']:GetCurrentTemperature()   (tambem via exports['rsg-hud'], ver provide no fxmanifest)
        exports['bilto_hud']:GetOutlawStatus()
]]

local RSGCore = exports['rsg-core']:GetCoreObject()

-- compartilhado com client.lua (mesmo runtime Lua)
HudStatus = {
    temperature = 0,
    outlaw = 0,
    uiVisible = true,
}

------------------------------------------------
-- helpers
------------------------------------------------
local function notify(title, notifyType)
    if GetResourceState('bilto_notify') == 'started' then
        exports['bilto_notify']:Notify({ title = 'Estresse', description = title, type = notifyType, duration = 4000, position = 'center-right' })
    else
        lib.notify({ title = title, type = 'inform', duration = 4000 })
    end
end

local function isDead()
    local playerData = RSGCore.Functions.GetPlayerData()
    return playerData and playerData.metadata and playerData.metadata['isdead']
end

local function updateNeed(key, value, reduce)
    if reduce then
        value = (LocalPlayer.state[key] or 100) - value
    end
    value = lib.math.clamp(lib.math.round(value, 2), 0, 100)
    if LocalPlayer.state[key] ~= value then
        LocalPlayer.state:set(key, value, true)
    end
end

local function updateStress(amount, isGain)
    local playerData = RSGCore.Functions.GetPlayerData()
    if not playerData or not playerData.metadata or playerData.metadata['isdead'] then return end
    -- mesma regra do rsg-hud original: job 'leo' nao alivia estresse por consumo
    if not isGain and playerData.job and playerData.job.type == 'leo' then return end

    local current = LocalPlayer.state.stress or 0
    local newStress = lib.math.clamp(current + (isGain and amount or -amount), 0, 100)
    LocalPlayer.state:set('stress', lib.math.round(newStress, 2), true)

    notify(isGain and 'Voce esta ficando estressado.' or 'Voce se sente mais calmo.', isGain and 'warning' or 'success')
end

local function rangeValue(list, value, field, fallback)
    for _, v in ipairs(list) do
        if value >= v.min and value <= v.max then return v[field] end
    end
    return fallback
end

local function cleanlinessFromPed()
    return Citizen.InvokeNative(0x147149F2E909323C, cache.ped, 16, Citizen.ResultAsInteger())
end

------------------------------------------------
-- eventos usados por outros resources
------------------------------------------------
RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst, newCleanliness)
    updateNeed('hunger', newHunger)
    updateNeed('thirst', newThirst)
    updateNeed('cleanliness', newCleanliness - cleanlinessFromPed())
end)

RegisterNetEvent('hud:client:UpdateHunger', function(value) updateNeed('hunger', value) end)
RegisterNetEvent('hud:client:UpdateThirst', function(value) updateNeed('thirst', value) end)
RegisterNetEvent('hud:client:UpdateStress', function(value) updateNeed('stress', value) end)

RegisterNetEvent('hud:client:UpdateCleanliness', function(value)
    updateNeed('cleanliness', value - cleanlinessFromPed())
end)

RegisterNetEvent('hud:client:GainStress', function(amount) updateStress(amount, true) end)
RegisterNetEvent('hud:client:RelieveStress', function(amount) updateStress(amount, false) end)

RegisterNetEvent('HideAllUI', function()
    HudStatus.uiVisible = not HudStatus.uiVisible
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    HudStatus.uiVisible = true
end)

------------------------------------------------
-- esconder HUD nativa
------------------------------------------------
CreateThread(function()
    local hide = Config.HideNative
    local function hideIcon(a, b) Citizen.InvokeNative(0xC116E6DF68DCE667, a, 2) Citizen.InvokeNative(0xC116E6DF68DCE667, b, 2) end
    if hide.playerStamina then hideIcon(0, 1) end
    if hide.playerDeadEye then hideIcon(2, 3) end
    if hide.playerHealth  then hideIcon(4, 5) end
    if hide.horseHealth   then hideIcon(6, 7) end
    if hide.horseStamina  then hideIcon(8, 9) end
    if hide.horseCourage  then hideIcon(10, 11) end
end)

------------------------------------------------
-- status de procurado
------------------------------------------------
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            HudStatus.outlaw = lib.callback.await('bilto_hud:server:getOutlawStatus', false) or 0
        end
        Wait(30000)
    end
end)

exports('GetOutlawStatus', function() return HudStatus.outlaw end)

------------------------------------------------
-- temperatura
------------------------------------------------
local function clothingWarmth()
    local warmth = 0
    for category, value in pairs(Config.ClothingWarmth) do
        if value ~= 0 and Citizen.InvokeNative(0xFB4891BD7578CDC1, cache.ped, category) == 1 then
            warmth = warmth + value
        end
    end

    local playerData = RSGCore.Functions.GetPlayerData()
    local jobType = playerData and playerData.job and playerData.job.type
    if jobType then
        for _, exempt in ipairs(Config.NoWarmthJobs) do
            if jobType == exempt then return 0 end
        end
    end
    return warmth
end

CreateThread(function()
    while true do
        local celsius = GetTemperatureAtCoords(GetEntityCoords(cache.ped))
        local base = Config.TempUnit == 'F' and math.floor(celsius * 9 / 5 + 32) or math.floor(celsius)
        HudStatus.temperature = base + (Config.TempFeature and clothingWarmth() or 0)
        Wait(1000)
    end
end)

exports('GetCurrentTemperature', function() return HudStatus.temperature end)

------------------------------------------------
-- moscas quando sujo
------------------------------------------------
local FLIES_DICT, FLIES_NAME = 'scr_mg_cleaning_stalls', 'scr_mg_stalls_manure_flies'
local fliesHandle = nil

local function stopFlies()
    if fliesHandle and Citizen.InvokeNative(0x9DD5AFF561E88F2A, fliesHandle) then -- DoesParticleFxLoopedExist
        Citizen.InvokeNative(0x459598F579C98929, fliesHandle, false) -- RemoveParticleFx
    end
    fliesHandle = nil
end

local function updateFlies(clean)
    if LocalPlayer.state.isBathingActive or clean >= Config.MinCleanliness then
        stopFlies()
        return
    end

    if fliesHandle and Citizen.InvokeNative(0x9DD5AFF561E88F2A, fliesHandle) then return end

    local dict = joaat(FLIES_DICT)
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, dict) then -- HasNamedPtfxAssetLoaded
        Citizen.InvokeNative(0xF2B2353BBC0D4E8F, dict) -- RequestNamedPtfxAsset
        local tries = 0
        while not Citizen.InvokeNative(0x65BB72F29138F5D6, dict) and tries < 300 do
            tries = tries + 1
            Wait(0)
        end
    end
    if not Citizen.InvokeNative(0x65BB72F29138F5D6, dict) then return end

    Citizen.InvokeNative(0xA10DB07FC234DD12, FLIES_DICT) -- UseParticleFxAsset
    local bone = IsPedMale(cache.ped) and 413 or 464
    fliesHandle = Citizen.InvokeNative(0x9C56621462FFE7A6, FLIES_NAME, cache.ped, 0.2, 0.0, -0.4, 0.0, 0.0, 0.0, bone, 1.0, 0, 0, 0) -- StartNetworkedParticleFxLoopedOnEntityBone
end

------------------------------------------------
-- dano por fome/sede/temperatura/sujeira + queda das necessidades
------------------------------------------------
local function damageFx(active)
    if not Config.DoHealthDamageFx then return end
    if active then
        Citizen.InvokeNative(0x4102732DF6B4005F, 'MP_Downed', 0, true) -- AnimpostfxPlay
    elseif Citizen.InvokeNative(0x4A123E85D7C4CA0B, 'MP_Downed') then -- AnimpostfxIsRunning
        Citizen.InvokeNative(0xB4FD7446BAB2F394, 'MP_Downed') -- AnimpostfxStop
    end
end

local function hurt(amount, painId)
    if Config.DoHealthPainSound then PlayPain(cache.ped, painId, 1, true, true) end
    SetEntityHealth(cache.ped, math.max(0, GetEntityHealth(cache.ped) - amount))
end

CreateThread(function()
    repeat Wait(500) until LocalPlayer.state.isLoggedIn

    while true do
        Wait(Config.StatusInterval)
        local state = LocalPlayer.state

        if state.isLoggedIn and not isDead() then
            -- higiene vem da sujeira real do ped
            updateNeed('cleanliness', 100 - cleanlinessFromPed())

            if Config.FlyEffect then updateFlies(state.cleanliness or 100) end

            if Config.DoHealthDamage then
                if (state.hunger or 100) <= 0 or (state.thirst or 100) <= 0 then
                    hurt(math.random(5, 10), 9)
                end

                local badTemp = Config.TempFeature and (HudStatus.temperature < Config.MinTemp or HudStatus.temperature > Config.MaxTemp)
                local filthy = (state.cleanliness or 100) <= 0
                if badTemp then hurt(Config.RemoveHealth, 9) end
                if filthy then hurt(Config.RemoveHealth, 12) end
                damageFx(badTemp or filthy)
            end

            updateNeed('hunger', Config.HungerRate, true)
            updateNeed('thirst', Config.ThirstRate, true)
            updateNeed('stress', Config.StressDecayRate, true)
        end
    end
end)

------------------------------------------------
-- estresse: velocidade em veiculo
------------------------------------------------
CreateThread(function()
    while true do
        Wait(10000)
        if IsPedInAnyVehicle(cache.ped, false) then
            local speed = GetEntitySpeed(GetVehiclePedIsIn(cache.ped, false)) * 2.237 -- mph
            if speed >= Config.MinimumSpeed then
                updateStress(math.random(1, 3), true)
            end
        end
    end
end)

------------------------------------------------
-- estresse: atirando
------------------------------------------------
local UNARMED = `WEAPON_UNARMED`
local shootingLoop = false

lib.onCache('weapon', function(weapon)
    local armed = weapon and weapon ~= UNARMED and weapon ~= false
    if not armed or shootingLoop then return end

    shootingLoop = true
    CreateThread(function()
        while cache.weapon and cache.weapon ~= UNARMED do
            if IsPedShooting(cache.ped) and math.random() < Config.StressChance then
                updateStress(math.random(1, 3), true)
            end
            Wait(100)
        end
        shootingLoop = false
    end)
end)

------------------------------------------------
-- estresse: efeitos de tela
------------------------------------------------
CreateThread(function()
    while true do
        local stress = LocalPlayer.state.stress or 0
        local timeout = rangeValue(Config.StressInterval, stress, 'timeout', nil)
        local sleep = timeout and math.random(timeout[1], timeout[2]) or 60000
        local intensity = rangeValue(Config.StressShake, stress, 'intensity', 0.05)

        if stress >= 100 then
            local falls = math.random(2, 4)
            local ragdollTime = falls * 1750
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', intensity)

            if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                SetPedToRagdollWithFall(cache.ped, ragdollTime, ragdollTime, 1, GetEntityForwardVector(cache.ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(500)
            for _ = 1, falls do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', intensity)
            end
        elseif stress >= Config.MinimumStress then
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', intensity)
        end

        Wait(sleep)
    end
end)

------------------------------------------------
-- minimapa / bussola
------------------------------------------------
CreateThread(function()
    while true do
        Wait(500)
        local show = HudStatus.uiVisible
        local mounted = IsPedOnMount(cache.ped) or IsPedInAnyVehicle(cache.ped, false)

        if mounted or LocalPlayer.state.telegramIsBirdPostApproaching then
            if Config.MountMinimap and show then
                SetMinimapType(Config.MountCompass and 3 or 1)
            else
                SetMinimapType(0)
            end
        elseif Config.OnFootMinimap and show then
            SetMinimapType(1)
            if GetInteriorFromEntity(cache.ped) ~= 0 then
                SetRadarConfigType(0xDF5DB58C, 0) -- zoom em interiores
            else
                SetRadarConfigType(0x25B517BF, 0)
            end
        elseif Config.OnFootCompass and show then
            SetMinimapType(3)
        else
            SetMinimapType(0)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then stopFlies() end
end)
