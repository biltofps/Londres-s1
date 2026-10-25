local prompts = GetRandomIntInRange(0, 0xffffff)
local prompts2 = GetRandomIntInRange(0, 0xffffff)
local prompts3 = GetRandomIntInRange(0, 0xffffff)
local RSGCore = exports['rsg-core']:GetCoreObject()
local pumpwater
local wagonwater
local fert
local water2plant
local fillwagon
local harvest
local trim
local allfarms = {}
local renderedplants = {}
local resp
local holdingcan = false 
local bucketprop
local onholdbucket = false
local clientwaterwagons = {}
local itemSet2  = CreateItemset(true)
local volumeArea = Citizen.InvokeNative(0xB3FB80A32BAE3065, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0) 
local closewagon
local blips = {}
local charid
local removeplant
local refresh = false
local render = {}
local ready
local allowfarming = true 
local disableinv = false 
local updatingnow = false 
local useWagonFillTarget = false
local wagonTargetModels = {}
local function anim(dict, name, duration, flag)
    if lib and lib.requestAnimDict then
        lib.requestAnimDict(dict)
    else
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
    TaskPlayAnim(PlayerPedId(), dict, name, 8.0, -8.0, duration or -1, flag or 0, 0.0, false, false, false)
    if duration and duration > 0 then
        Wait(duration)
    end
    RemoveAnimDict(dict)
end

local function drawtext(text, x, y, scaleX, scaleY, shadow, r, g, b, a, center, duration)
    local endTime = GetGameTimer() + (duration or 0)
    while duration == nil or GetGameTimer() <= endTime do
        SetTextScale(scaleX or 0.3, scaleY or 0.3)
        SetTextFontForCurrentCommand(0)
        SetTextColor(r or 255, g or 255, b or 255, a or 255)
        if shadow then
            SetTextDropshadow(2, 0, 0, 0, 255)
            SetTextDropShadow()
        end
        if center then
            SetTextCentre(true)
        end
        DisplayText(CreateVarString(10, 'LITERAL_STRING', text or ""), x or 0.5, y or 0.5)
        Wait(0)
    end
end

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return end
    SetTextScale(0.3, 0.3)
    SetTextFontForCurrentCommand(0)
    SetTextColor(255, 255, 255, 255)
    SetTextCentre(true)
    DisplayText(CreateVarString(10, 'LITERAL_STRING', text or ""), _x, _y)
end

local inventoryImageBase = "nui://rsg-inventory/html/images/"
local wagonNuiVisible = false
local lastWagonKey = nil
local harvestLevel = 0
local harvestLevelPct = 0
local actionBusy = false

local function hideWagonStatus()
    if wagonNuiVisible then
        SendNUIMessage({ action = "hideWagon" })
        wagonNuiVisible = false
        lastWagonKey = nil
    end
end

local function getPlantDisplay(seedType)
    if not seedType then
        return "Planta", nil
    end
    local seed = Config.seeds and Config.seeds[seedType]
    if not seed then
        return seedType, nil
    end
    local reward = seed.rewarditem and seed.rewarditem[1] or nil
    local label = reward and (reward.label or reward.name) or seedType
    local itemName = reward and reward.name or nil
    return label, itemName
end

local function syncPlantTimer(plant)
    if not plant or plant.timer == nil then
        return
    end
    plant._syncTimer = tonumber(plant.timer) or 0
    plant._syncStamp = GetGameTimer()
end

local function syncAllFarmTimers()
    for _, v in pairs(allfarms) do
        for _, y in pairs(v) do
            for _, h in pairs(y) do
                syncPlantTimer(h)
            end
        end
    end
end

local function getDisplayTimer(plant, now)
    if not plant then
        return 0
    end
    local base = tonumber(plant._syncTimer)
    if base == nil then
        base = tonumber(plant.timer) or 0
    end
    now = now or GetGameTimer()
    local stamp = plant._syncStamp or now
    local elapsedMinutes = math.floor((now - stamp) / 60000)
    if elapsedMinutes <= 0 then
        return base
    end
    local timeToWater = Config.seeds[plant.type] and Config.seeds[plant.type].timetowater
    if not timeToWater then
        return math.max(base - elapsedMinutes, 0)
    end
    timeToWater = tonumber(timeToWater) or 0
    if base > timeToWater then
        local newTimer = base - elapsedMinutes
        if newTimer <= timeToWater and not plant.watered then
            return timeToWater
        end
        return math.max(newTimer, 0)
    end
    if base == timeToWater and not plant.watered then
        return base
    end
    return math.max(base - elapsedMinutes, 0)
end

-- monta os dados da planta para a NUI
local function buildPlantPayload(plant, isOwner)
    local seed = (Config.seeds and Config.seeds[plant.type]) or {}
    local label, itemName = getPlantDisplay(plant.type)
    local t = getDisplayTimer(plant)
    local total = tonumber(seed.totaltime) or 0
    local growthPct = 0
    if total > 0 then
        growthPct = math.floor(((total - t) / total) * 100)
    elseif t == 0 then
        growthPct = 100
    end
    growthPct = math.max(0, math.min(100, growthPct))
    local maxHealth = tonumber(seed.health) or 100
    local timeToWater = tonumber(seed.timetowater)
    return {
        label = label or "Planta",
        image = itemName and (inventoryImageBase .. itemName .. ".png") or nil,
        timer = t,
        growthPct = growthPct,
        ready = t == 0,
        watered = plant.watered == true,
        fert = plant.fert == true,
        trimmed = plant.trem == true,
        waitingWater = t > 0 and not plant.watered and timeToWater ~= nil and t <= timeToWater,
        health = math.floor(tonumber(plant.health) or maxHealth),
        maxHealth = maxHealth,
        owner = isOwner == true,
        level = harvestLevel or 0,
        levelPct = tonumber(harvestLevelPct) or 0,
    }
end

local function showWagonStatus(current, maxCap)
    if not Config.useWagonNui then
        return
    end
    local cur = tonumber(current) or 0
    local maxv = tonumber(maxCap) or 0
    local pct = 0
    if maxv > 0 then
        pct = math.floor((cur / maxv) * 100)
    end
    if pct < 0 then
        pct = 0
    elseif pct > 100 then
        pct = 100
    end
    local key = tostring(cur) .. "|" .. tostring(maxv)
    if key ~= lastWagonKey then
        SendNUIMessage({
            action = "showWagon",
            waterPct = pct,
            waterText = tostring(cur) .. "/" .. tostring(maxv)
        })
        lastWagonKey = key
    end
    wagonNuiVisible = true
end

local function istownbanned(townHash)
    if not townHash or townHash == 0 then
        return false
    end
    for _, name in pairs(Config.towns or {}) do
        if townHash == GetHashKey(name) then
            return true
        end
    end
    return false
end

local function tooclose(all, coords)
    if not all or not coords then
        return false
    end
    for _, v in pairs(all) do
        for _, y in pairs(v) do
            for _, h in pairs(y) do
                if h.coords then
                    local dist = GetDistanceBetweenCoords(coords, h.coords.x, h.coords.y, h.coords.z, true)
                    if dist < (Config.plantspace or 1.5) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function plantexist(rendered, all)
    if not rendered or not rendered.id then
        return false
    end
    for _, v in pairs(all or {}) do
        for _, y in pairs(v) do
            for _, h in pairs(y) do
                if h.render == rendered.id then
                    return true
                end
            end
        end
    end
    return false
end

local function containswagon(wagons, network)
    if not wagons or not network then
        return false, 0
    end
    if wagons[network] ~= nil then
        return true, wagons[network]
    end
    return false, 0
end

local function getWagonModelKey(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return nil
    end
    local model = GetEntityModel(entity)
    for modelKey in pairs(Config.waterwagons or {}) do
        if GetHashKey(modelKey) == model then
            return modelKey
        end
    end
    return nil
end

local function canFillWagonEntity(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end
    if IsPedInVehicle(PlayerPedId(), entity) then
        return false
    end
    local modelKey = getWagonModelKey(entity)
    if not modelKey then
        return false
    end
    local maxCap = tonumber(Config.waterwagons[modelKey]) or 0
    if maxCap <= 0 then
        return false
    end
    local network = NetworkGetNetworkIdFromEntity(entity)
    local current = tonumber(clientwaterwagons[network]) or 0
    if current >= maxCap then
        return false
    end
    return holdingcan or IsEntityInWater(entity)
end

local function fillWagonFromEntity(entity)
    if not canFillWagonEntity(entity) then
        return
    end
    local modelKey = getWagonModelKey(entity)
    if not modelKey then
        return
    end
    local network = NetworkGetNetworkIdFromEntity(entity)
    local _, space = containswagon(clientwaterwagons, network)
    if holdingcan then
        holdingcan = false
        DeleteObject(bucketprop)
    end
    ClearPedTasks(PlayerPedId())
    anim("amb_work@prop_human_pump_water@female_b@idle_a", "idle_a", -1, 1)
    Citizen.Wait(5000)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent("bilto_farming:sendwagonfillrequest", modelKey, network, space)
    resp = nil
    while resp == nil do
        Wait(1000)
    end
end

local function registerWagonFillTarget()
    if GetResourceState('ox_target') ~= 'started' then
        return false
    end
    wagonTargetModels = {}
    for modelKey in pairs(Config.waterwagons or {}) do
        wagonTargetModels[#wagonTargetModels + 1] = modelKey
    end
    if #wagonTargetModels == 0 then
        return false
    end
    exports.ox_target:addModel(wagonTargetModels, {
        {
            name = 'bilto_farming_fillwagon',
            label = language.fillwagon or "Encher",
            icon = 'fa-solid fa-droplet',
            distance = 2.5,
            canInteract = function(entity)
                return canFillWagonEntity(entity)
            end,
            onSelect = function(data)
                if data and data.entity then
                    fillWagonFromEntity(data.entity)
                end
            end
        }
    })
    return true
end

local WagonModels = {}
CreateThread(function()
    Wait(0)
    for model in pairs(Config.waterwagons or {}) do
        WagonModels[GetHashKey(model)] = true
    end
end)

local function findNearbyWaterWagon(coords, range)
    local checkRange = tonumber(range) or 0
    if checkRange <= 0 then
        return nil
    end
    if type(GetGamePool) ~= "function" then
        return nil
    end
    local closest = nil
    local closestDist = checkRange + 0.01
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if WagonModels[GetEntityModel(veh)] then
            local vcoords = GetEntityCoords(veh)
            local dist = GetDistanceBetweenCoords(coords, vcoords.x, vcoords.y, vcoords.z, true)
            if dist <= checkRange and dist < closestDist then
                closestDist = dist
                closest = veh
            end
        end
    end
    return closest
end

local function getNearbyWagonNet(coords)
    if not (Config.wagonAutoEnabled and Config.wagonAutoWaterPlant) then
        return nil
    end
    local wagon = findNearbyWaterWagon(coords, Config.wagonAutoRange)
    if wagon then
        return NetworkGetNetworkIdFromEntity(wagon)
    end
    return nil
end
local function notify(message, ntype)
    if not message or message == "" then
        return
    end
    exports['bilto_notify']:Notify({
        type = ntype or "info",
        title = "Plantação",
        description = message,
        duration = 3000,
        position = Config.notifyPosition or 'bottom-center'
    })
end

-- charid pode chegar nil se o resource reiniciar com o player ja logado
local function getMyCharId()
    if charid == nil then
        local playerData = RSGCore.Functions.GetPlayerData()
        local id = playerData and (playerData.citizenid or playerData.cid)
        if id then
            charid = tostring(id)
        end
    end
    return charid
end

local function isPlantOwner(owner)
    local mine = getMyCharId()
    return mine ~= nil and owner ~= nil and tostring(owner) == tostring(mine)
end

local function findPlantByRender(id)
    local k, x, g = findplant(id)
    if not k then
        return nil
    end
    return allfarms[k][x][g], k
end

local function waitServer()
    resp = nil
    local deadline = GetGameTimer() + 15000
    while resp == nil and GetGameTimer() < deadline do
        Wait(250)
    end
end

-- retorna true se passou no minigame (ou se o minigame estiver desligado)
local function passMinigame(plant)
    if not Config.minigame then
        return true
    end
    local minigame = exports["syn_minigame"]:taskBar(plant.difficulty, 7)
    if minigame == 100 then
        return true
    end
    if Config.ragdollonfail then
        SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
    end
    TriggerServerEvent("bilto_farming:interact", "dmg", plant.type, plant.render)
    Wait(1000)
    return false
end

-- pergunta ao servidor se a acao e possivel (itens, balde etc) antes de animar
local function serverAllows(action, render)
    local result = nil
    RSGCore.Functions.TriggerCallback('bilto_farming:canInteract', function(ok)
        result = ok == true
    end, action, render)
    local deadline = GetGameTimer() + 5000
    while result == nil and GetGameTimer() < deadline do
        Wait(50)
    end
    return result == true
end

-- checa o plantio no servidor antes do minigame/animacao
local function serverAllowsPlant(seedType, coords)
    local result = nil
    RSGCore.Functions.TriggerCallback('bilto_farming:canPlant', function(ok)
        result = ok == true
    end, seedType, coords)
    local deadline = GetGameTimer() + 5000
    while result == nil and GetGameTimer() < deadline do
        Wait(50)
    end
    return result == true
end

local function doPlantAction(id, action)
    if actionBusy then
        return
    end
    local plant, owner = findPlantByRender(id)
    if not plant then
        return
    end
    if Config.onlyowner and not isPlantOwner(owner) then
        return
    end
    actionBusy = true
    -- validacao antes de qualquer animacao
    if action ~= "remove" and not serverAllows(action, plant.render) then
        actionBusy = false
        return
    end
    local displayTimer = getDisplayTimer(plant)
    if action == "harvest" then
        if displayTimer == 0 and plant.watered and passMinigame(plant) then
            harvestanim()
            TriggerServerEvent("bilto_farming:interact", "harvest", plant.type, plant.render)
            waitServer()
        end
    elseif action == "trim" then
        if not plant.trem and passMinigame(plant) then
            local wagonNet = getNearbyWagonNet(GetEntityCoords(PlayerPedId()))
            TriggerServerEvent("bilto_farming:interact", "trim", plant.type, plant.render, wagonNet)
            waitServer()
        end
    elseif action == "fert" then
        if not plant.fert and passMinigame(plant) then
            local wagonNet = getNearbyWagonNet(GetEntityCoords(PlayerPedId()))
            TriggerServerEvent("bilto_farming:interact", "fert", plant.type, plant.render, wagonNet)
            waitServer()
        end
    elseif action == "water" then
        if not plant.watered then
            if passMinigame(plant) then
                wateranim()
                TriggerServerEvent("bilto_farming:interact", "water", plant.type, plant.render)
                waitServer()
            else
                DeleteObject(bucketprop)
                holdingcan = false
            end
        end
    elseif action == "remove" then
        removeplantanim()
        TriggerServerEvent("bilto_farming:interact", "remove", plant.type, plant.render)
        waitServer()
    end
    actionBusy = false
end

-- HUD de status no canto direito: mostra a planta mais proxima (somente leitura)
local shownRender = nil
CreateThread(function()
    local syncElapsed = 0
    while true do
        local sleep = 1000
        local pc = GetEntityCoords(PlayerPedId())
        local maxDist = Config.statusDistance or 2.5
        local best, bestDist, bestOwner
        for k, v in pairs(allfarms) do
            for _, y in pairs(v) do
                for _, h in pairs(y) do
                    if h.coords then
                        local d = #(pc - vector3(h.coords.x, h.coords.y, h.coords.z))
                        if d <= maxDist and (not bestDist or d < bestDist) and (not Config.onlyowner or isPlantOwner(k)) then
                            best, bestDist, bestOwner = h, d, k
                        end
                    end
                end
            end
        end
        if best then
            sleep = 500
            local payload = buildPlantPayload(best, isPlantOwner(bestOwner))
            if shownRender ~= best.render then
                shownRender = best.render
                syncElapsed = 0
                TriggerServerEvent("bilto_farming:requestupdate", best.render)
                SendNUIMessage({ action = "showPlant", plant = payload })
            else
                SendNUIMessage({ action = "updatePlant", plant = payload })
                -- puxa o estado real do servidor enquanto o status estiver visivel
                syncElapsed = syncElapsed + sleep
                if syncElapsed >= (Config.panelSyncSeconds or 2) * 1000 then
                    syncElapsed = 0
                    TriggerServerEvent("bilto_farming:requestupdate", best.render)
                end
            end
        elseif shownRender then
            shownRender = nil
            SendNUIMessage({ action = "hidePlant" })
        end
        Wait(sleep)
    end
end)

-- zona do ox_target por planta (props de planta costumam nao ter colisao, entao alvo por entidade falha)
local plantZones = {}

local function removePlantTarget(id)
    local zone = id and plantZones[id]
    if not zone then
        return
    end
    plantZones[id] = nil
    if GetResourceState('ox_target') == 'started' then
        pcall(function()
            exports.ox_target:removeZone(zone, true)
        end)
    end
end

local function plantOption(id, action, label, icon, available)
    return {
        name = 'bilto_farming_' .. action,
        label = label,
        icon = icon,
        distance = Config.targetDistance or 2.0,
        canInteract = function()
            if actionBusy then
                return false
            end
            local plant, owner = findPlantByRender(id)
            if not plant then
                return false
            end
            if Config.onlyowner and not isPlantOwner(owner) then
                return false
            end
            return available(plant)
        end,
        onSelect = function()
            CreateThread(function()
                doPlantAction(id, action)
            end)
        end
    }
end

local function addPlantTarget(entity, id)
    if GetResourceState('ox_target') ~= 'started' then
        return
    end
    removePlantTarget(id)
    -- centro real do modelo (a origem de varios props de planta fica deslocada do visual)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(entity))
    local sizeX = math.max(maxDim.x - minDim.x, 0.4)
    local sizeY = math.max(maxDim.y - minDim.y, 0.4)
    local height = math.min(math.max(maxDim.z - minDim.z, 0.5), 4.0)
    local center = GetOffsetFromEntityInWorldCoords(entity, (minDim.x + maxDim.x) / 2, (minDim.y + maxDim.y) / 2, 0.0)
    local base = GetEntityCoords(entity).z + minDim.z
    -- margem: sem colisao, o raio atravessa a planta e bate no chao logo atras dela
    local pad = Config.targetPadding or 0.5
    local footprint = math.min(math.max(sizeX, sizeY), 2.5)
    plantZones[id] = exports.ox_target:addBoxZone({
        coords = vector3(center.x, center.y, base + height / 2),
        size = vector3(footprint + pad * 2, footprint + pad * 2, height + 1.0),
        rotation = GetEntityHeading(entity),
        debug = Config.debug,
        options = {
            plantOption(id, "water", language.water2plant or "Regar", 'fa-solid fa-droplet', function(p)
                return not p.watered
            end),
            plantOption(id, "fert", language.fert or "Fertilizar", 'fa-solid fa-seedling', function(p)
                return not p.fert
            end),
            plantOption(id, "trim", language.trim or "Podar", 'fa-solid fa-scissors', function(p)
                return not p.trem
            end),
            plantOption(id, "harvest", language.harvest or "Colher", 'fa-solid fa-basket-shopping', function(p)
                return p.watered and getDisplayTimer(p) == 0
            end),
            plantOption(id, "remove", language.remove or "Remover planta", 'fa-solid fa-trash', function()
                return true
            end),
        }
    })
end

local function deletePlantEntity(entity, id)
    removePlantTarget(id)
    if not entity or entity == 0 then
        return
    end
    SetEntityAsMissionEntity(entity)
    DeleteObject(entity)
end

RegisterNetEvent("bilto_farming:cbuck")
AddEventHandler("bilto_farming:cbuck", function()
    ExecuteCommand(Config.removebucketcommand)
end)
TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)
--[[ RegisterCommand("testan", function(source, args, rawCommand)
    
end, false) ]]

-- delete all rendered plants on script stop
AddEventHandler("onResourceStop",function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if useWagonFillTarget and GetResourceState('ox_target') == 'started' and #wagonTargetModels > 0 then
            pcall(function()
                exports.ox_target:removeModel(wagonTargetModels, 'bilto_farming_fillwagon')
            end)
        end
        for k,v in pairs(renderedplants) do
            deletePlantEntity(v.plant, v.id)
        end
        DeleteObject(bucketprop)
        if IsItemsetValid(itemSet2) then
            Citizen.InvokeNative(0x20A4BF0E09BEE146, itemSet2)
        end
        for k,v in pairs(blips) do 
            RemoveBlip(v.blip)
        end
    end
end)

-- pull plant information from all players
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if charid ~= nil then 
            Citizen.Wait(Config.requestupdatetime*60000)
            TriggerServerEvent("bilto_farming:requestcoords")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("bilto_farming:updatecoords", coords)
    end
end)

RegisterNetEvent("bilto_farming:reccoords")
AddEventHandler("bilto_farming:reccoords", function(plantcoords)
    local plantstorender = {}

    local coords = GetEntityCoords(PlayerPedId())
    for k,v in pairs(plantcoords) do 
        local dist = GetDistanceBetweenCoords(coords,v.x,v.y,v.z, true)
        if 50 > dist then 
            table.insert(plantstorender, k)
        end
    end
    TriggerServerEvent("bilto_farming:requestplants", plantstorender)
end)

AddEventHandler("syn_scene:stopscene", function(x)
    allowfarming = x 
end)

RegisterNetEvent("bilto_farming:reccharid")
AddEventHandler("bilto_farming:reccharid", function(x)
    charid = x 
end)

RegisterNetEvent("bilto_farming:reclevel")
AddEventHandler("bilto_farming:reclevel", function(level, total, pct)
    harvestLevel = tonumber(level) or 0
    harvestLevelPct = tonumber(pct) or 0
end)

RegisterNetEvent("RSGCore:Client:OnPlayerLoaded")
AddEventHandler("RSGCore:Client:OnPlayerLoaded", function()
    local playerData = RSGCore.Functions.GetPlayerData()
    charid = playerData and (playerData.citizenid or playerData.cid) or nil
    TriggerServerEvent("bilto_farming:requestcoords")
    TriggerServerEvent("bilto_farming:requestblips")
    TriggerServerEvent("bilto_farming:requestlevel")

end)

RegisterNetEvent("RSGCore:Client:OnPlayerUnload")
AddEventHandler("RSGCore:Client:OnPlayerUnload", function()
    charid = nil
end)

RegisterNetEvent("bilto_farming:recblips")
AddEventHandler("bilto_farming:recblips", function(plants)
    if charid ~= nil then 
        allfarms[charid] = plants
    end
    for x,y in pairs(plants) do 
        for g,h in pairs(y) do 
            local blip = N_0x554d9d53f696d002(1664425300, h.coords.x, h.coords.y, h.coords.z)
            SetBlipSprite(blip, Config.blip, 1)
            SetBlipScale(blip, 0.1)
            local label = getPlantDisplay(h.type)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, label or h.type)
            table.insert(blips, {blip=blip,id = h.render})
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    -- resource (re)iniciado com o player ja logado: OnPlayerLoaded nao dispara, entao pede os dados aqui
    if getMyCharId() or Config.debug then
        TriggerServerEvent("bilto_farming:requestcharid")
        TriggerServerEvent("bilto_farming:requestcoords")
        TriggerServerEvent("bilto_farming:requestblips")
        TriggerServerEvent("bilto_farming:requestlevel")
    end
end)

 -- request the farming information from the server side 
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    useWagonFillTarget = registerWagonFillTarget()
    if not useWagonFillTarget then
        local str = language.fillwagon
	    fillwagon = PromptRegisterBegin()
	    PromptSetControlAction(fillwagon, Config.keys["G"])
	    str = CreateVarString(10, 'LITERAL_STRING', str)
	    PromptSetText(fillwagon, str)
	    PromptSetEnabled(fillwagon, 1)
	    PromptSetStandardMode(fillwagon,1)
	    PromptSetGroup(fillwagon, prompts3)
	    Citizen.InvokeNative(0xC5F428EE08FA7F2C,fillwagon,true)
	    PromptRegisterEnd(fillwagon)
    end

    local str = language.wagonwater
	wagonwater = PromptRegisterBegin()
	PromptSetControlAction(wagonwater, Config.keys["ENTER"])
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(wagonwater, str)
	PromptSetEnabled(wagonwater, 1)
	PromptSetStandardMode(wagonwater,1)
	PromptSetGroup(wagonwater, prompts3)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,wagonwater,true)
	PromptRegisterEnd(wagonwater)

    local str = language.pump
	pumpwater = PromptRegisterBegin()
	PromptSetControlAction(pumpwater, Config.keys["G"])
	str = CreateVarString(10, 'LITERAL_STRING', str)
	PromptSetText(pumpwater, str)
	PromptSetEnabled(pumpwater, 1)
    PromptSetVisible(pumpwater, 1)
	PromptSetStandardMode(pumpwater,1)
	PromptSetGroup(pumpwater, prompts2)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,pumpwater,true)
	PromptRegisterEnd(pumpwater)
end)
function findplant(id)
    for k,v in pairs(allfarms) do 
        for x,y in pairs(v) do 
            for g,h in pairs(y) do
                if h.render == id then 
                    return k,x,g
                end
            end
        end
    end
end

-- recieve all farm information
RegisterNetEvent('bilto_farming:recinfo')
AddEventHandler('bilto_farming:recinfo', function(x,y)
    allfarms = x 
    ready = y 
    syncAllFarmTimers()
end)

RegisterNetEvent('bilto_farming:recplant')
AddEventHandler('bilto_farming:recplant', function(k,x,g,info,id)
    if info == nil then 
        local k,x,g = findplant(id)
        TriggerEvent("bilto_farming:removeplant",k,x,g)
        return
    end
    if  allfarms[k] == nil then 
        allfarms[k] = {}
    end
    if allfarms[k][x] == nil then 
        allfarms[k][x] = {}
    end
    allfarms[k][x][g] = info
    syncPlantTimer(allfarms[k][x][g])
end)

RegisterNetEvent('bilto_farming:recplants')
AddEventHandler('bilto_farming:recplants', function(info)
    for o,p in pairs(info) do 
        if  allfarms[p.k] == nil then 
            allfarms[p.k] = {}
        end
        if allfarms[p.k][p.x] == nil then 
            allfarms[p.k][p.x] = {}
        end
        allfarms[p.k][p.x][p.g] = p.info
        syncPlantTimer(allfarms[p.k][p.x][p.g])
    end
end)



--rec wagon info
RegisterNetEvent('bilto_farming:recinfowagons')
AddEventHandler('bilto_farming:recinfowagons', function(x)
    clientwaterwagons = x 
end)


-- on watercan item use
RegisterNetEvent('bilto_farming:wateringcan')
AddEventHandler('bilto_farming:wateringcan', function()
    TriggerEvent("rsg-inventory:client:closeInv")
    if Config.singleBucket and IsEntityInWater(PlayerPedId()) then
        TriggerEvent('bilto_farming:usebucketinwater')
        return
    end
    bucket()
end)

-- command to remove bucket from hand 
RegisterCommand(Config.removebucketcommand, function(source, args, rawCommand)
    if bucketprop then 
        DeleteObject(bucketprop)
        ClearPedTasks(PlayerPedId())  
        holdingcan = false 
        bucketprop = nil
    end
end, false) 

-- check if player in water and fill up bucket
RegisterNetEvent('bilto_farming:usebucketinwater')
AddEventHandler('bilto_farming:usebucketinwater', function()
    TriggerEvent("rsg-inventory:client:closeInv")
    local coords = GetEntityCoords(PlayerPedId())
	local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x+3, coords.y+3, coords.z)
	if Water == 231313522 or 2005774838 or -1287619521 or -196675805 or -1308233316 or 1755369577 or -2040708515 or -557290573 or -247856387 or 370072007 or -1504425495 or -1369817450 or -1356490953 or -1781130443 or -1300497193 or -1276586360 or -1410384421 or 650214731 or 592454541 or -804804953 or 1245451421 or -218679770 or -1817904483 or -811730579 or -1229593481 or -105598602 then
		if IsEntityInWater(PlayerPedId()) then
            DeleteObject(bucketprop)
	        FreezeEntityPosition(PlayerPedId(), true)
            anim("amb_work@world_human_bucket_fill@female_a@stand_exit_withprop","exit_front", -1, 1)
            Citizen.Wait(100)
            bucketprop = CreateObject("p_bucket03x", coords.x, coords.y, coords.z, true, true, false)
            AttachEntityToEntity(bucketprop, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_R_Finger43"), 0.01, 0.0, 0.0, 174.0, -32.0, 187.0, false, false, true, false, 0, true, false, false)
            Citizen.Wait(1300)
            DeleteObject(bucketprop)
            ClearPedTasks(PlayerPedId())  
            FreezeEntityPosition(PlayerPedId(), false)   
            TriggerServerEvent("bilto_farming:watefromriver")  
        else
            TriggerServerEvent("bilto_farming:termbucket")  
        end
    else
        TriggerServerEvent("bilto_farming:termbucket")  
    end
end)
-- function for attaching watercan 
function bucket()
    DeleteObject(bucketprop)
	FreezeEntityPosition(PlayerPedId(), true)
	local pos = GetEntityCoords(PlayerPedId(), true)
	ClearPedTasks(PlayerPedId())
	holdingcan = true
	Citizen.Wait(50)
	anim("amb_camp@world_camp_jack_es@bucket_pickup@empty@male_a@base","base", -1, 25)
	bucketprop = CreateObject("p_bucketcampmil01x", pos.x, pos.y, pos.z, true, true, false)
	AttachEntityToEntity(bucketprop, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), -0.03, 0.02, -0.02, 0.0, 0.0, -94.0, false, false, true, false, 0, true, false, false)
	FreezeEntityPosition(PlayerPedId(), false)
end
--animation for trimming 
function trimanim()
    anim("mech_pickup@plant@gold_currant", "exit", 2500, 1)
end
-- harvest animation
function harvestanim()
    anim("mech_pickup@plant@berries", "base", 2500, 1)
end

function removeplantanim()
    FreezeEntityPosition(PlayerPedId(), true)
    anim("amb_camp@world_camp_fire@stomp@male_a@wip_base", "wip_base", -1, 1)
    Citizen.Wait(10000)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
end
-- fert animation
function fertanim()
    anim("mech_pickup@plant@orchid_plant", "base", 2500, 1)
end

-- planting animation
function plantanim()
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), true)
    local coords = GetEntityCoords(PlayerPedId())
    anim("amb_work@world_human_farmer_rake@male_a@idle_a","idle_a", -1, 1)
    Citizen.Wait(700)
    local rake = CreateObject("p_rake02x", coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(rake, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
    Citizen.Wait(7000)
    DeleteEntity(rake)
    ClearPedTasks(PlayerPedId())
    anim("amb_work@world_human_feed_chickens@female_a@base","base", -1, 1)
    Citizen.Wait(700)
    local bag = CreateObject("p_feedbag01bx", coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(bag, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_L_Hand"), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
    Citizen.Wait(4000)
    DeleteEntity(bag)
    ClearPedTasks(PlayerPedId())
	FreezeEntityPosition(PlayerPedId(), false)
end
-- animation for watering plants
function wateranim()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    DeleteObject(bucketprop)
    bucketprop = nil
    holdingcan = false
    -- animacao de despejar com um balde nosso na mao (o cenario largava um balde no chao que nao sumia)
    local c = GetEntityCoords(ped)
    local hash = GetHashKey("p_bucketcampmil01x")
    RequestModel(hash)
    local deadline = GetGameTimer() + 3000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do
        Wait(10)
    end
    local pourBucket = CreateObject(hash, c.x, c.y, c.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(pourBucket, ped, GetEntityBoneIndexByName(ped, "PH_R_Hand"), -0.03, 0.02, -0.02, 0.0, 0.0, -94.0, false, false, true, false, 0, true, false, false)
    anim("amb_work@world_human_bucket_pour@low@male_a@base", "base", -1, 1)
    FreezeEntityPosition(ped, true)
    Wait(Config.waterAnimTime or 6000)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    if DoesEntityExist(pourBucket) then
        DetachEntity(pourBucket, true, true)
        SetEntityAsMissionEntity(pourBucket, true, true)
        DeleteEntity(pourBucket)
    end
    Citizen.InvokeNative(0xFCCC886EDE3C63EC, ped, false, true)
end

--trigger animations if successful at tasks
RegisterNetEvent('bilto_farming:animationtrigger')
AddEventHandler('bilto_farming:animationtrigger', function(type)
    if type == "trim" then 
        trimanim()
    elseif type == "fert" then 
        fertanim()
    end
end)

-- checks if client is in a town and declines the servers request to register plant if the player is. 
RegisterNetEvent('bilto_farming:createblip')
AddEventHandler('bilto_farming:createblip', function(type,coords,idnumber)
    local blip = N_0x554d9d53f696d002(1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.blip, 1)
    SetBlipScale(blip, 0.1)
    local label = getPlantDisplay(type)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, label or type)
    table.insert(blips, {blip=blip,id = idnumber})
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if disableinv then
            sleep = false  
            DisableControlAction(0, 0xC1989F95, true)
        end
    end
end)
RegisterNetEvent('bilto_farming:usedseed')
AddEventHandler('bilto_farming:usedseed', function(type)
    TriggerEvent("rsg-inventory:client:closeInv")
    disableinv = true 
    if allowfarming then 
        TaskStandStill(PlayerPedId(), 3000)
        local coords = GetEntityCoords(PlayerPedId())
        local town = Citizen.InvokeNative(0x43AD8FC02B429D33, coords, 1)
        if not istownbanned(town) then
            if not tooclose(allfarms,coords) then
                if not IsEntityInWater(PlayerPedId()) then

                    if not serverAllowsPlant(type, coords) then
                        -- o servidor ja mostrou o aviso (limite, zona do job, itens...)
                        ClearPedTasks(PlayerPedId())
                    elseif Config.minigame then
                        local diff = Config.seeds[type].difficulty
                        local minigame = exports["syn_minigame"]:taskBar(diff,7)
                        if minigame == 100 then 
                            plantanim()
                            local wagonNet = nil
                            if Config.wagonAutoEnabled then
                                local wagon = findNearbyWaterWagon(coords, Config.wagonAutoRange)
                                if wagon then
                                    wagonNet = NetworkGetNetworkIdFromEntity(wagon)
                                end
                            end
                            TriggerServerEvent("bilto_farming:approvefarming",type,coords,wagonNet)
                        else
                            if Config.ragdollonfail then 
                                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
                            end
                            notify(language.failedd, "error")
                            Wait(50)
                            ClearPedTasks(PlayerPedId())
                        end
                    else
                        plantanim()
                        local wagonNet = nil
                        if Config.wagonAutoEnabled then
                            local wagon = findNearbyWaterWagon(coords, Config.wagonAutoRange)
                            if wagon then
                                wagonNet = NetworkGetNetworkIdFromEntity(wagon)
                            end
                        end
                        TriggerServerEvent("bilto_farming:approvefarming",type,coords,wagonNet)
                    end
                else
                    notify(language.inwater, "error")
                    Wait(50)
                    ClearPedTasks(PlayerPedId())
                end
            else
                notify(language.closeplant, "error")
                Wait(50)
                ClearPedTasks(PlayerPedId())
            end
        else
            notify(language.closetown, "error")
            Wait(50)
            ClearPedTasks(PlayerPedId())
        end
        TriggerServerEvent("bilto_farming:cleartofarm")
    end
    disableinv = false 
end)

-- remove plant 
RegisterNetEvent('bilto_farming:removeplant')
AddEventHandler('bilto_farming:removeplant', function(k,x,g)
    if not allfarms[k] or not allfarms[k][x] or not allfarms[k][x][g] then
        return
    end
    render[allfarms[k][x][g].render] = nil 
    for b,n in pairs(renderedplants) do 
        if allfarms[k][x][g].render == n.id then
            deletePlantEntity(n.plant, n.id)
            for f,q in pairs(blips) do 
                if allfarms[k][x][g].render == q.id then 
                    RemoveBlip(q.blip)
                    table.remove(blips,f)
                end
            end
        end
    end
    allfarms[k][x][g] = nil 
    if next(allfarms[k][x]) == nil then 
        allfarms[k][x] = nil 
    end
end)
-- find and render plants close to the player 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playercoords = GetEntityCoords(PlayerPedId())
        local plant = {}
        for k,v in pairs(allfarms) do 
            for x,y in pairs(v) do 
                for g,h in pairs(y) do 
                    local dist = GetDistanceBetweenCoords(playercoords,h.coords.x,h.coords.y,h.coords.z, true)
                    if Config.render > dist then 
                        renderobj(h.render,h.type,h.coords)
                    else
                        derenderobj(h.render)
                    end 
                end
            end
        end
        for k,v in pairs(renderedplants) do 
            if not plantexist(v, allfarms) then
                render[v.id] = nil
                deletePlantEntity(v.plant, v.id)
                table.remove(renderedplants,k)
            end
        end

        
        Citizen.Wait(500)
    end
end)
-- logic to render objects if not rendered
local function getGroundZ(coords)
    if not coords then
        return false, 0.0
    end
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    local groundZ = coords.z
    local found = false
    for _ = 1, 20 do
        local ok, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, false)
        if ok then
            groundZ = z
            found = true
            break
        end
        Wait(25)
    end
    return found, groundZ
end

local function requestModelWithTimeout(modelHash, timeoutMs)
    if not modelHash or not IsModelValid(modelHash) then
        return false
    end
    timeoutMs = timeoutMs or 3000
    RequestModel(modelHash)
    local started = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        if (GetGameTimer() - started) >= timeoutMs then
            return false
        end
        Wait(10)
    end
    return true
end

function renderobj(id,typex,coords)
    if render[id] == nil then 
        render[id] = false 
    end
    if render[id] == false then
        local seedData = Config.seeds and Config.seeds[typex]
        if not seedData or not seedData.prop or not coords then
            return
        end
        local prop = seedData.prop
        local offset = tonumber(seedData.offset) or 0.0
        local propHash = type(prop) == "string" and GetHashKey(prop) or prop
        if not requestModelWithTimeout(propHash, 3000) then
            render[id] = false
            return
        end
        render[id] = true
        local _, groundZ = getGroundZ(coords)
        local plant = CreateObject(propHash, coords.x, coords.y, groundZ, false, false, true)
        SetModelAsNoLongerNeeded(propHash)
        if not plant or plant == 0 or not DoesEntityExist(plant) then
            render[id] = false
            return
        end
        SetEntityAsMissionEntity(plant)
        PlaceObjectOnGroundProperly(plant)
        if offset ~= 0.0 then -- some plants are still floating even after ground placement
            local coords2 = GetEntityCoords(plant) 
            SetEntityCoords(plant,coords2.x, coords2.y, coords2.z - offset)
        end
        FreezeEntityPosition( plant, true)
        addPlantTarget(plant, id)
        table.insert(renderedplants, {id =id, plant = plant,type = typex})
    end
end
-- logic to delete objects if rendered
function derenderobj(id)
    if render[id] == nil then 
        render[id] = false 
    end
    if render[id] == true then 
        render[id] = false
        for b,q in pairs(renderedplants) do 
            if id == q.id then
                deletePlantEntity(q.plant, q.id)
                table.remove(renderedplants,b)
            end
        end
    end
end

-- recieve fert feedback 
RegisterNetEvent('bilto_farming:recst')
AddEventHandler('bilto_farming:recst', function()
    resp = "done"
end)
-- pump bucket animation
RegisterNetEvent('bilto_farming:pumpbucket')
AddEventHandler('bilto_farming:pumpbucket', function(waterpumpcoords)
    local DataStruct = DataView.ArrayBuffer(256 * 4) 
    local is_data_exists = Citizen.InvokeNative(0x345EC3B7EBDE1CB5, GetEntityCoords(PlayerPedId()), 3.0, DataStruct:Buffer(), 10)
    for i = 1, 10, 1 do
		local scenario = DataStruct:GetInt32(8 * i)
		if scenario ~= 0 then
			if GetHashKey("PROP_HUMAN_PUMP_WATER") == Citizen.InvokeNative(0xA92450B5AE687AAF,scenario) or GetHashKey("PROP_HUMAN_PUMP_WATER_BUCKET") == Citizen.InvokeNative(0xA92450B5AE687AAF,scenario) then 
                ClearPedTasksImmediately(PlayerPedId())
                Citizen.InvokeNative(0xFCCC886EDE3C63EC,PlayerPedId(),false,true)
                TaskUseScenarioPoint(PlayerPedId(), scenario ,  "" , -1.0, true, false, 0, false, -1.0, true)
                Wait(10000)
			end
		end
	end
    ClearPedTasks(PlayerPedId())
    onholdbucket = false
end)


RegisterNetEvent('bilto_farming:clearonholdbucket')
AddEventHandler('bilto_farming:clearonholdbucket', function()
    onholdbucket = false
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if updatingnow then 
            Wait(5000)
            updatingnow = false
        end
    end
end)

-- close to pump loop (interacao com plantas agora e via ox_target + NUI)
Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local playercoords = GetEntityCoords(PlayerPedId())
        local waterpump = GetClosestObjectOfType(playercoords, 1.0, -40350080, false, false, false)
        if waterpump ~= 0 and not onholdbucket then
            local waterpumpcoords = GetEntityCoords(waterpump)
            local pumpdist = GetDistanceBetweenCoords(playercoords,waterpumpcoords, true)
            if 1.5 > pumpdist then
                sleep = 1
                local label  = CreateVarString(10, 'LITERAL_STRING', language.waterpump)
                PromptSetActiveGroupThisFrame(prompts2, label)
                if Citizen.InvokeNative(0xC92AC953F0A982AE,pumpwater) then
                    TriggerServerEvent("bilto_farming:checkbucket",waterpumpcoords)
                    onholdbucket = true
                    Wait(5000)
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)





-- find closest vehicle
function GetClosestveh(coords, range)
    local vehiclesToDraw = {}
    if volumeArea then 
        Citizen.InvokeNative(0x541B8576615C33DE, volumeArea, coords.x, coords.y, coords.z) 
        local itemsFound = Citizen.InvokeNative(0x886171A12F400B89, volumeArea, itemSet2, 2) 
        if itemsFound then
            n = 0
            while n < itemsFound do
                vehiclesToDraw[(GetIndexedItemInItemset(n, itemSet2))] = true
                n = n + 1
            end
        end
        Citizen.InvokeNative(0x20A4BF0E09BEE146, itemSet2)
        for k,v in pairs(vehiclesToDraw) do 
            Citizen.InvokeNative(0x20A4BF0E09BEE146, itemSet2)
            return k
        end
        
    end
    if IsItemsetValid(itemSet2) then
        Citizen.InvokeNative(0x20A4BF0E09BEE146, itemSet2)
    end
end

-- loop to find closest wagon 
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local coords = GetEntityCoords(PlayerPedId())
        closewagon = GetClosestveh(coords,10)
        if closewagon == nil then 
            Wait(1000)
        end
    end
end)

-- filling up and using wagon to get water
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local wagonShown = false
        if closewagon ~= nil then 
            local model = GetEntityModel(closewagon)
            for k,v in pairs(Config.waterwagons) do 
                if GetHashKey(k) == model then 
                    local network = NetworkGetNetworkIdFromEntity(closewagon)
                    local exists,space = containswagon(clientwaterwagons, network)
                    local currentWater = clientwaterwagons[network] or 0
                    local coords = GetEntityCoords(closewagon)
                    local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,coords.x+3, coords.y+3, coords.z)
                    if Config.useWagonNui then
                        showWagonStatus(currentWater, v)
                        wagonShown = true
                    end
                    if not IsPedInVehicle(PlayerPedId(),closewagon) then 
                        if exists then 
                            if not Config.useWagonNui then
                                DrawText3D(coords.x, coords.y,coords.z,"~pa~"..tostring(clientwaterwagons[network]))
                            end
                            local label  = CreateVarString(10, 'LITERAL_STRING', language.Wagon)
                            PromptSetActiveGroupThisFrame(prompts3, label)
                            PromptSetVisible(wagonwater, 1)
                            if Citizen.InvokeNative(0xC92AC953F0A982AE,wagonwater) then
                                ClearPedTasks(PlayerPedId())
                                anim("amb_work@prop_human_pump_water@female_b@idle_a", "idle_a", -1, 1)
                                Citizen.Wait(5000)
                                ClearPedTasks(PlayerPedId())
                                bucket()
                                TriggerServerEvent("bilto_farming:waterfromwagon",network)
                                resp = nil 
                                while resp == nil do 
                                    Wait(1000)
                                end
                            end
                        else
                            PromptSetVisible(wagonwater, 0)
                        end
                        if not useWagonFillTarget then
                            if ( holdingcan or (Water == 231313522 or 2005774838 or -1287619521 or -196675805 or -1308233316 or 1755369577 or -2040708515 or -557290573 or -247856387 or 370072007 or -1504425495 or -1369817450 or -1356490953 or -1781130443 or -1300497193 or -1276586360 or -1410384421 or 650214731 or 592454541 or -804804953 or 1245451421 or -218679770 or -1817904483 or -811730579 or -1229593481 or -105598602) and IsEntityInWater(closewagon)) then
                                local label  = CreateVarString(10, 'LITERAL_STRING', language.Wagon)
                                PromptSetActiveGroupThisFrame(prompts3, label)
                                if exists then 
                                    if clientwaterwagons[network] == nil then
                                        PromptSetVisible(fillwagon, 1)
                                    elseif Config.waterwagons[k] > clientwaterwagons[network] then 
                                        PromptSetVisible(fillwagon, 1)
                                    else
                                        PromptSetVisible(fillwagon, 0)
                                    end
                                else
                                    PromptSetVisible(fillwagon, 1)
                                end
                                if Citizen.InvokeNative(0xC92AC953F0A982AE,fillwagon) then
                                    fillWagonFromEntity(closewagon)
                                end
                            elseif not IsEntityInWater(closewagon) and not holdingcan then 
                                PromptSetVisible(fillwagon, 0)
                            end
                        end
                    else
                        Wait(1000)
                    end
                end
            end
        else
            Wait(1000)
        end
        if Config.useWagonNui and not wagonShown then
            hideWagonStatus()
        end
    end
end)

-- ===================== zonas de plantacao do job (polyzone) =====================

local ZONE_KEYS = {
    add = 0x760A9C6F, -- G
    undo = 0x4AF4D473, -- DEL
    up = 0x6319DB71, -- seta cima
    down = 0x05CA7C52, -- seta baixo
    finish = 0xC7B5340A, -- ENTER
}

-- desenha a zona como paredes translucidas (mesmo estilo do debug do ox_lib)
local function drawZoneWalls(points, minZ, maxZ, r, g, b, closed)
    local count = #points
    local last = closed and count or count - 1
    for i = 1, last do
        local p1 = points[i]
        local p2 = points[(i % count) + 1]
        local ax, ay, bx, by = p1.x, p1.y, p2.x, p2.y
        DrawPoly(ax, ay, minZ, bx, by, minZ, ax, ay, maxZ, r, g, b, 70)
        DrawPoly(ax, ay, maxZ, bx, by, minZ, ax, ay, minZ, r, g, b, 70)
        DrawPoly(bx, by, minZ, ax, ay, maxZ, bx, by, maxZ, r, g, b, 70)
        DrawPoly(bx, by, maxZ, ax, ay, maxZ, bx, by, minZ, r, g, b, 70)
        DrawLine(ax, ay, minZ, bx, by, minZ, r, g, b, 230)
        DrawLine(ax, ay, maxZ, bx, by, maxZ, r, g, b, 230)
        DrawLine(ax, ay, minZ, ax, ay, maxZ, r, g, b, 230)
    end
end

-- zonas ja configuradas (Config.jobPlants.debug = true)
CreateThread(function()
    while true do
        local jobPlants = Config.jobPlants or {}
        if jobPlants.debug then
            local pc = GetEntityCoords(PlayerPedId())
            for _, jobData in pairs(jobPlants.jobs or {}) do
                for _, zone in ipairs(jobData.zones or {}) do
                    local points = zone.points
                    if points and #points >= 2 then
                        local minZ = zone.minZ or (points[1].z - 2.0)
                        local maxZ = zone.maxZ or (points[1].z + 10.0)
                        if #(vector2(pc.x, pc.y) - vector2(points[1].x, points[1].y)) < 300.0 then
                            drawZoneWalls(points, minZ, maxZ, 120, 200, 90, true)
                        end
                    end
                end
            end
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

-- criador de zona estilo PolyZone: /farmzona [nome]
local zoneTool = nil -- { name, points, height }

local function zoneToolBounds(tool)
    local minZ = math.huge
    for _, p in ipairs(tool.points) do
        minZ = math.min(minZ, p.z)
    end
    if minZ == math.huge then
        minZ = GetEntityCoords(PlayerPedId()).z
    end
    minZ = minZ - 2.0
    return minZ, minZ + tool.height
end

local function updateZoneToolHud()
    if not zoneTool then
        SendNUIMessage({ action = "zoneToolHide" })
        return
    end
    SendNUIMessage({
        action = "zoneTool",
        name = zoneTool.name,
        points = #zoneTool.points,
        height = zoneTool.height,
    })
end

local function buildZoneSnippet(tool)
    local minZ, maxZ = zoneToolBounds(tool)
    local lines = {}
    for i, p in ipairs(tool.points) do
        lines[i] = ("                vec3(%.2f, %.2f, %.2f),"):format(p.x, p.y, p.z)
    end
    return table.concat({
        "        {",
        ('            name = "%s",'):format(tool.name),
        ("            minZ = %.1f,"):format(minZ),
        ("            maxZ = %.1f,"):format(maxZ),
        "            points = {",
        table.concat(lines, "\n"),
        "            },",
        "        },",
    }, "\n")
end

local function stopZoneTool()
    zoneTool = nil
    updateZoneToolHud()
end

local function finishZoneTool()
    if #zoneTool.points < 3 then
        notify("A zona precisa de pelo menos 3 pontos", "error")
        return
    end
    local snippet = buildZoneSnippet(zoneTool)
    print("^3[bilto_farming] cole dentro de zones = { } do job em Config.jobPlants.jobs no config.lua:^0\n" .. snippet)
    SendNUIMessage({ action = "copy", text = snippet })
    notify("Zona finalizada! Copiada e impressa no F8", "success")
    stopZoneTool()
end

local function runZoneTool()
    local lastHeightStep = 0
    while zoneTool do
        local ped = PlayerPedId()
        local pc = GetEntityCoords(ped)
        local tool = zoneTool

        for _, key in pairs(ZONE_KEYS) do
            DisableControlAction(0, key, true)
        end

        if IsDisabledControlJustPressed(0, ZONE_KEYS.add) then
            tool.points[#tool.points + 1] = vector3(pc.x, pc.y, pc.z)
            updateZoneToolHud()
        elseif IsDisabledControlJustPressed(0, ZONE_KEYS.undo) and #tool.points > 0 then
            tool.points[#tool.points] = nil
            updateZoneToolHud()
        elseif IsDisabledControlJustPressed(0, ZONE_KEYS.finish) then
            finishZoneTool()
            break
        end

        local now = GetGameTimer()
        if now - lastHeightStep > 80 then
            if IsDisabledControlPressed(0, ZONE_KEYS.up) then
                tool.height = math.min(tool.height + 0.5, 100.0)
                lastHeightStep = now
                updateZoneToolHud()
            elseif IsDisabledControlPressed(0, ZONE_KEYS.down) then
                tool.height = math.max(tool.height - 0.5, 1.0)
                lastHeightStep = now
                updateZoneToolHud()
            end
        end

        -- preview: pontos marcados + trecho ate a posicao atual do player
        local minZ, maxZ = zoneToolBounds(tool)
        local preview = {}
        for i, p in ipairs(tool.points) do
            preview[i] = p
        end
        preview[#preview + 1] = pc
        if #preview >= 2 then
            drawZoneWalls(preview, minZ, maxZ, 90, 210, 110, #preview >= 3)
        end
        for _, p in ipairs(tool.points) do
            DrawLine(p.x, p.y, minZ, p.x, p.y, maxZ, 255, 255, 255, 255)
        end
        Wait(0)
    end
end

RegisterCommand("farmzona", function(_, args)
    if not Config.zoneTool then
        return
    end
    if zoneTool then
        stopZoneTool()
        notify("Criação de zona cancelada", "info")
        return
    end
    local name = table.concat(args, " ")
    zoneTool = {
        name = name ~= "" and name or "Nova zona",
        points = {},
        height = 15.0,
    }
    updateZoneToolHud()
    CreateThread(runZoneTool)
end, false)
