local props = {} -- [id] = { coords = vector3, obj = entity, blip = blip }
local model = joaat(Config.Model)

--------------------------------------------------------------------------------
-- blips
--------------------------------------------------------------------------------
local function CreateBlip(c)
    local blip = N_0x554d9d53f696d002(1664425300, c.x, c.y, c.z) -- BlipAddForCoords
    SetBlipSprite(blip, joaat(Config.Blip.sprite), true)
    SetBlipScale(blip, Config.Blip.scale)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.Text.blip) -- SetBlipName
    if Config.Blip.color then BlipAddModifier(blip, joaat(Config.Blip.color)) end
    return blip
end

--------------------------------------------------------------------------------
-- props
--------------------------------------------------------------------------------
local collecting = false
local function Collect(id)
    if collecting then return end
    collecting = true
    CreateThread(function()
        local ped = cache.ped or PlayerPedId()
        TaskStartScenarioInPlace(ped, joaat('WORLD_HUMAN_CROUCH_INSPECT'), 1500, true)
        Wait(1500)
        ClearPedTasks(ped)
        TriggerServerEvent('bilto_natal:server:collect', id)
        collecting = false
    end)
end

local function SpawnObject(id, p)
    p.obj = 0 -- marca como em criacao
    if not IsModelValid(model) then
        print(('[bilto_natal] modelo invalido: %s'):format(Config.Model))
        return
    end
    if not pcall(lib.requestModel, model, 5000) then p.obj = nil return end
    if props[id] ~= p then SetModelAsNoLongerNeeded(model) return end -- pego enquanto carregava

    -- o z do server e so aproximado (pontos sorteados no mapa): procura o chao de cima para baixo
    local c = p.coords
    local found, gz = GetGroundZFor_3dCoord(c.x, c.y, 1000.0, false)
    if not found then
        -- colisao ainda carregando: tenta de novo no proximo segundo, depois desiste e pede outro lugar
        p.obj, p.tries = nil, (p.tries or 0) + 1
        if p.tries == 10 then TriggerServerEvent('bilto_natal:server:bad', id) end
        return
    end
    local water, wz = GetWaterHeight(c.x, c.y, gz + 2.0)
    if water and wz > gz + 0.3 then
        if not p.bad then p.bad = true TriggerServerEvent('bilto_natal:server:bad', id) end
        return -- fica com obj = 0 ate o server mover o presente
    end

    local obj = CreateObject(model, c.x, c.y, gz, false, false, false)
    SetModelAsNoLongerNeeded(model)
    if not obj or obj == 0 then p.obj = nil return end
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    p.obj = obj

    exports.ox_target:addLocalEntity(obj, {{
        name = 'bilto_natal_' .. id,
        icon = 'fa-solid fa-gift',
        label = Config.Text.target,
        distance = Config.TargetDistance,
        onSelect = function() Collect(id) end,
    }})
end

local function DeleteObj(p)
    if p.obj and p.obj ~= 0 and DoesEntityExist(p.obj) then
        exports.ox_target:removeLocalEntity(p.obj)
        DeleteObject(p.obj)
    end
    p.obj = nil
end

local function Remove(id)
    local p = props[id]
    if not p then return end
    props[id] = nil
    DeleteObj(p)
    if p.blip and DoesBlipExist(p.blip) then RemoveBlip(p.blip) end
end

local function ClearAll()
    for id in pairs(props) do Remove(id) end
end

RegisterNetEvent('bilto_natal:client:spawn', function(list)
    ClearAll()
    for id, c in pairs(list) do
        props[id] = { coords = c, blip = CreateBlip(c) }
    end
end)

RegisterNetEvent('bilto_natal:client:remove', Remove)
RegisterNetEvent('bilto_natal:client:clear', ClearAll)

-- presente caiu na agua e o server levou para outro lugar
RegisterNetEvent('bilto_natal:client:move', function(id, c)
    Remove(id)
    props[id] = { coords = c, blip = CreateBlip(c) }
end)

-- o server sorteia pontos no mapa e pede para um jogador tirar os que caem na agua
lib.callback.register('bilto_natal:client:dry', function(list)
    local ok = {}
    for i, c in ipairs(list) do
        local zone = Citizen.InvokeNative(0x5BA7A68A346A5A91, c.x, c.y, c.z) -- GET_WATER_MAP_ZONE_AT_COORDS
        if not zone or zone == 0 or zone == false then ok[#ok + 1] = i end
    end
    return ok
end)

-- so cria o objeto perto do jogador; o blip fica no mapa inteiro
CreateThread(function()
    while true do
        local pc = GetEntityCoords(cache.ped or PlayerPedId())
        for id, p in pairs(props) do
            local near = #(pc.xy - p.coords.xy) < Config.SpawnDistance -- z dos pontos sorteados e aproximado
            if near and not p.obj then
                SpawnObject(id, p)
            elseif not near and p.obj then
                DeleteObj(p)
            end
        end
        Wait(1000)
    end
end)

--------------------------------------------------------------------------------
-- NUI: anuncio gigante + ranking
--------------------------------------------------------------------------------
RegisterNetEvent('bilto_natal:client:announce', function(data)
    SendNUIMessage({
        action = 'announce', title = data.title, text = data.text, countdown = data.countdown, duration = data.duration,
        sound = data.countdown and Config.Sound or nil,
    })
end)

RegisterNetEvent('bilto_natal:client:ranking', function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'ranking', title = Config.Text.help_rank, data = data })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

--------------------------------------------------------------------------------
-- sincronia ao entrar / reiniciar
--------------------------------------------------------------------------------
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('bilto_natal:server:sync')
end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() and LocalPlayer.state.isLoggedIn then
        TriggerServerEvent('bilto_natal:server:sync')
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    ClearAll()
    SetNuiFocus(false, false)
end)
