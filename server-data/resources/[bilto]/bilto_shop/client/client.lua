local RSGCore = exports['rsg-core']:GetCoreObject()

local spawnedPeds = {}   -- [key] = ped
local spawning    = {}   -- [key] = true enquanto o NPC existe ou esta sendo criado
local blips       = {}
local zones       = {}   -- lojas sem NPC: zona do ox_target

local function OpenShop(key)
    TriggerServerEvent('bilto_shop:server:open', key)
end

-- so mostra a opcao para quem tem o emprego (o server confere de novo)
local function CanInteract(shop)
    if not shop.jobs then return true end
    local pd = RSGCore.Functions.GetPlayerData()
    local job = pd and pd.job and pd.job.name
    for _, name in ipairs(shop.jobs) do
        if name == job then return true end
    end
    return false
end

local function TargetOption(key, shop)
    return {
        name = 'bilto_shop_' .. key,
        icon = 'fa-solid fa-store',
        label = Config.Text.open:format(shop.label),
        distance = Config.TargetDistance,
        canInteract = function() return CanInteract(shop) end,
        onSelect = function() OpenShop(key) end,
    }
end

--------------------------------------------------------------------------------
-- sons
--------------------------------------------------------------------------------
local function SoundFor(key, kind)
    local shop = Config.Shops[key]
    local own = shop and shop.sounds and shop.sounds[kind]
    if own ~= nil then return own end
    return Config.Sounds[kind]
end

local function PlayNative(snd)
    if snd and snd.native then PlaySoundFrontend(snd.native.name, snd.native.set, true, 0) end
end

local lastSound -- som pendente caso o .ogg falhe
RegisterNetEvent('bilto_shop:client:sound', function(key, kind)
    local snd = SoundFor(key, kind)
    if not snd then return end
    if snd.file then
        lastSound = snd
        SendNUIMessage({ action = 'sound', kind = kind, file = snd.file, volume = snd.volume })
    else
        PlayNative(snd)
    end
end)

-- arquivo .ogg faltando ou com erro: toca o som do jogo no lugar
RegisterNUICallback('soundFailed', function(_, cb)
    PlayNative(lastSound)
    lastSound = nil
    cb('ok')
end)

--------------------------------------------------------------------------------
-- NPCs
--------------------------------------------------------------------------------
local function SpawnPed(key, shop)
    spawning[key] = true
    local model = joaat(shop.npc)
    if not IsModelValid(model) then
        print(('[bilto_shop] modelo invalido na loja %s: %s'):format(key, shop.npc))
        return -- deixa spawning marcado para nao tentar de novo a cada segundo
    end
    if not pcall(lib.requestModel, model, 5000) then spawning[key] = nil return end

    local c = shop.coords
    local ped = CreatePed(model, c.x, c.y, c.z - 1.0, c.w, false, false, false, false)
    SetModelAsNoLongerNeeded(model)
    if not ped or ped == 0 then spawning[key] = nil return end
    Citizen.InvokeNative(0x9587913B9E772D29, ped, true) -- PlaceEntityOnGroundProperly
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- SetRandomOutfitVariation
    if Config.FadeIn then SetEntityAlpha(ped, 0, false) end
    SetEntityInvincible(ped, true)
    SetEntityCanBeDamaged(ped, false)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, false)
    TaskStartScenarioInPlace(ped, joaat(shop.scenario or Config.DefaultScenario), 0, true)
    spawnedPeds[key] = ped

    exports.ox_target:addLocalEntity(ped, { TargetOption(key, shop) })

    if Config.FadeIn then
        CreateThread(function()
            for a = 51, 255, 51 do
                Wait(50)
                if not DoesEntityExist(ped) then return end
                SetEntityAlpha(ped, a, false)
            end
            ResetEntityAlpha(ped)
        end)
    end
end

local function DespawnPed(key)
    local ped = spawnedPeds[key]
    spawnedPeds[key], spawning[key] = nil, nil
    if not ped or not DoesEntityExist(ped) then return end
    exports.ox_target:removeLocalEntity(ped)
    DeletePed(ped)
end

CreateThread(function()
    while true do
        local pc = GetEntityCoords(cache.ped or PlayerPedId())
        for key, shop in pairs(Config.Shops) do
            if shop.npc then
                local near = #(pc - shop.coords.xyz) < Config.SpawnDistance
                if near and not spawning[key] then
                    SpawnPed(key, shop)
                elseif not near and spawning[key] then
                    DespawnPed(key)
                end
            end
        end
        Wait(1000)
    end
end)

--------------------------------------------------------------------------------
-- camera no NPC enquanto a loja esta aberta
--------------------------------------------------------------------------------
local cam

local function StopFocus()
    if not cam then return end
    RenderScriptCams(false, true, Config.Focus.ease, true, true, 0)
    DestroyCam(cam, false)
    cam = nil
end

RegisterNetEvent('bilto_shop:client:opened', function(key)
    local f, ped = Config.Focus, spawnedPeds[key]
    if not f.enabled or cam or not ped or not DoesEntityExist(ped) then return end

    local pos  = GetOffsetFromEntityInWorldCoords(ped, f.side, f.distance, f.height)
    local look = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, f.lookHeight)
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, f.fov, false, 0)
    PointCamAtCoord(cam, look.x, look.y, look.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, f.ease, true, true, 0)
    TaskTurnPedToFaceEntity(cache.ped, ped, 1000)

    -- volta a camera quando o inventario fechar (ESC, compra concluida, morte...)
    CreateThread(function()
        Wait(500) -- a NUI do inventario abre junto com este evento
        while cam and exports['rsg-inventory']:IsOpen() do Wait(200) end
        StopFocus()
    end)
end)

--------------------------------------------------------------------------------
-- blips + zonas (lojas sem NPC)
--------------------------------------------------------------------------------
local function CreateBlip(shop)
    local c = shop.coords
    local blip = N_0x554d9d53f696d002(1664425300, c.x, c.y, c.z) -- BlipAddForCoords
    SetBlipSprite(blip, shop.blip.sprite, true)
    SetBlipScale(blip, shop.blip.scale or 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, shop.label) -- SetBlipName
    if shop.blip.color then BlipAddModifier(blip, joaat(shop.blip.color)) end
    return blip
end

CreateThread(function()
    for key, shop in pairs(Config.Shops) do
        if shop.blip then blips[#blips + 1] = CreateBlip(shop) end
        if not shop.npc then
            zones[#zones + 1] = exports.ox_target:addSphereZone({
                coords = shop.coords.xyz,
                radius = 1.5,
                options = { TargetOption(key, shop) },
            })
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    StopFocus()
    for key in pairs(spawnedPeds) do DespawnPed(key) end
    for _, blip in ipairs(blips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    for _, id in ipairs(zones) do exports.ox_target:removeZone(id) end
end)
