local RSGCore = exports['rsg-core']:GetCoreObject()

local FarmData = {}
local PlantIndex = {}
local FarmCoords = {}
local PlayerCoords = {}
local WaterWagons = {}
local PlantDex = 0
local FarmingLock = {}
local FarmerJobs = {}
local HarvestStats = {}
local OwnerSources = {}
local SourceOwner = {}

local function debugLog(message)
    if Config.debug then
        print(("[bilto_farming] %s"):format(message))
    end
end

local function getSteamHex(src, player)
    if player and player.PlayerData and player.PlayerData.steam then
        return player.PlayerData.steam
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if type(id) == "string" and id:sub(1, 6) == "steam:" then
            return id
        end
    end
    return "N/A"
end

local function sendHarvestWebhook(src, harvested)
    if not Config.adminwebhook or Config.adminwebhook == "" then
        return
    end
    if not harvested or #harvested == 0 then
        return
    end
    local player = RSGCore.Functions.GetPlayer(src)
    local name = GetPlayerName(src) or "Unknown"
    if player and player.PlayerData and player.PlayerData.charinfo then
        local ci = player.PlayerData.charinfo
        local full = (ci.firstname or "") .. " " .. (ci.lastname or "")
        if full:gsub("%s+", "") ~= "" then
            name = full
        end
    end
    local steamHex = getSteamHex(src, player)
    local embed = {{
        title = "Farming Colheita",
        description = ("**Jogador:** %s\n**SteamHex:** %s\n**Planta / Quantidade:** %s"):format(
            tostring(name),
            tostring(steamHex),
            table.concat(harvested, ", ")
        ),
        color = 65280,
        footer = { text = "Bilto Farming | " .. os.date("%d/%m/%Y %H:%M:%S") }
    }}
    PerformHttpRequest(
        Config.adminwebhook,
        function() end,
        "POST",
        json.encode({
            username = "Bilto Farming",
            avatar_url = Config.webhookavatar,
            embeds = embed
        }),
        { ["Content-Type"] = "application/json" }
    )
end

local JobPlants = Config.jobPlants or {}
for jobName, jobData in pairs(JobPlants.jobs or {}) do
    FarmerJobs[jobName] = jobData
end

-- ponto dentro do poligono (2D) - ray casting
local function pointInPolygon(x, y, points)
    local inside = false
    local j = #points
    for i = 1, #points do
        local pi, pj = points[i], points[j]
        if ((pi.y > y) ~= (pj.y > y)) and (x < (pj.x - pi.x) * (y - pi.y) / (pj.y - pi.y) + pi.x) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function isInJobZone(coords, jobName)
    local jobData = FarmerJobs[jobName]
    if not coords or not jobData then
        return false
    end
    for _, zone in ipairs(jobData.zones or {}) do
        local points = zone.points
        if points and #points >= 3 then
            local okZ = (not zone.minZ or coords.z >= zone.minZ) and (not zone.maxZ or coords.z <= zone.maxZ)
            if okZ and pointInPolygon(coords.x, coords.y, points) then
                return true
            end
        end
    end
    return false
end

local function notify(src, message, ntype)
    if not message or message == "" then
        return
    end
    TriggerClientEvent('bilto_notify:client', src, {
        type = ntype or "info",
        title = "Plantação",
        description = message,
        duration = 3000,
        position = Config.notifyPosition or 'bottom-center'
    })
end

local function getCharId(src)
    local player = RSGCore.Functions.GetPlayer(src)
    if not player then
        return nil
    end
    local mode = Config.charidType or "citizenid"
    if mode == "cid" then
        return tostring(player.PlayerData.cid or player.PlayerData.citizenid)
    end
    return tostring(player.PlayerData.citizenid or player.PlayerData.cid)
end

local function getMaxHarvestLevel()
    local maxLevel = 0
    for lvl in pairs(Config.harvestLevelTargets or {}) do
        local n = tonumber(lvl) or 0
        if n > maxLevel then
            maxLevel = n
        end
    end
    return maxLevel
end

local function getHarvestLevel(total)
    if not Config.harvestLevelEnabled then
        return 0
    end
    local maxLevel = getMaxHarvestLevel()
    local level = 0
    for i = 1, maxLevel do
        local req = Config.harvestLevelTargets and Config.harvestLevelTargets[i]
        if req and total >= req then
            level = i
        end
    end
    return level
end

local function getHarvestBonus(level)
    if not Config.harvestLevelEnabled then
        return 0
    end
    if Config.harvestLevelBonus and Config.harvestLevelBonus[level] then
        return tonumber(Config.harvestLevelBonus[level]) or 0
    end
    return tonumber(level) or 0
end

local function getHarvestProgress(total)
    if not Config.harvestLevelEnabled then
        return 0
    end
    local maxLevel = getMaxHarvestLevel()
    local level = getHarvestLevel(total)
    local currentTarget = 0
    if level > 0 then
        currentTarget = tonumber(Config.harvestLevelTargets[level]) or 0
    end
    local nextTarget = tonumber(Config.harvestLevelTargets[level + 1]) or 0
    if level >= maxLevel or nextTarget <= currentTarget then
        return 100
    end
    local pct = math.ceil(((total - currentTarget) / (nextTarget - currentTarget)) * 100)
    if pct < 0 then
        pct = 0
    elseif pct > 100 then
        pct = 100
    end
    if pct == 0 and total > currentTarget then
        pct = 1
    end
    return pct
end

local function getHarvestData(charid)
    if not charid then
        return { total = 0, level = 0 }
    end
    local key = tostring(charid)
    if not HarvestStats[key] then
        HarvestStats[key] = { total = 0, level = 0 }
    end
    local data = HarvestStats[key]
    data.total = tonumber(data.total) or 0
    local lvl = getHarvestLevel(data.total)
    if lvl ~= data.level then
        data.level = lvl
    end
    return data
end

local function sendHarvestLevel(src, charid)
    if not src or not charid then
        return
    end
    local data = getHarvestData(charid)
    local pct = getHarvestProgress(data.total or 0)
    TriggerClientEvent('bilto_farming:reclevel', src, data.level or 0, data.total or 0, pct)
end

local function saveHarvestData(charid)
    if not charid then
        return
    end
    local data = HarvestStats[tostring(charid)]
    if not data then
        return
    end
    MySQL.insert.await(
        'INSERT INTO bilto_playerfarmslevels (charid, total, level) VALUES (:charid, :total, :level) ON DUPLICATE KEY UPDATE total = :total, level = :level',
        { charid = tostring(charid), total = tonumber(data.total) or 0, level = tonumber(data.level) or 0 }
    )
end

local function rebuildOwnerSources(charid)
    local owners = {}
    local key = tostring(charid)
    for _, src in pairs(RSGCore.Functions.GetPlayers()) do
        local player = RSGCore.Functions.GetPlayer(src)
        if player then
            local pid = tostring(player.PlayerData.citizenid or player.PlayerData.cid)
            if pid == key then
                owners[#owners + 1] = src
                SourceOwner[src] = key
            end
        end
    end
    OwnerSources[key] = owners
    return owners
end

local function addOwnerSource(src, charid)
    if not src or not charid then
        return
    end
    local key = tostring(charid)
    SourceOwner[src] = key
    local owners = OwnerSources[key]
    if not owners then
        OwnerSources[key] = { src }
        return
    end
    for _, owner in ipairs(owners) do
        if owner == src then
            return
        end
    end
    owners[#owners + 1] = src
end

local function removeOwnerSource(src)
    local key = SourceOwner[src]
    if not key then
        return
    end
    SourceOwner[src] = nil
    local owners = OwnerSources[key]
    if not owners then
        return
    end
    for i = #owners, 1, -1 do
        if owners[i] == src then
            table.remove(owners, i)
        end
    end
    if #owners == 0 then
        OwnerSources[key] = nil
    end
end

local function getOwnerSources(charid)
    if not charid then
        return {}
    end
    local key = tostring(charid)
    local owners = OwnerSources[key]
    if owners then
        return owners
    end
    return rebuildOwnerSources(key)
end

local function hasItem(src, item, amount)
    if not item then
        return false
    end
    return RSGCore.Functions.HasItem(src, item, amount or 1)
end

local function addItem(src, item, amount)
    if not item then
        return false
    end
    return exports['rsg-inventory']:AddItem(src, item, amount or 1)
end

local function removeItem(src, item, amount)
    if not item then
        return false
    end
    return exports['rsg-inventory']:RemoveItem(src, item, amount or 1)
end

local function resolveFertItem(src, fertConfig)
    if not fertConfig then
        return nil, 0
    end
    if type(fertConfig) == "string" then
        return (hasItem(src, fertConfig, 1) and fertConfig or nil), 1
    end
    if type(fertConfig) ~= "table" then
        return nil, 0
    end
    for _, entry in ipairs(fertConfig) do
        if type(entry) == "string" then
            if hasItem(src, entry, 1) then
                return entry, 1
            end
        elseif type(entry) == "table" then
            local name = entry.name or entry.item
            local count = tonumber(entry.count) or 1
            if name and hasItem(src, name, count) then
                return name, count
            end
        end
    end
    return nil, 0
end

local function getBucketItem(src)
    if not Config.singleBucket then
        return nil
    end
    return exports['rsg-inventory']:GetItemByName(src, Config.bucketItem)
end

local function getBucketWater(item)
    if not item or type(item.info) ~= "table" then
        return 0
    end
    return tonumber(item.info.water) or 0
end

local function setBucketWater(src, item, value)
    if not item then
        return 0
    end
    local capacity = tonumber(Config.bucketCapacity) or 100
    local water = math.max(0, math.min(tonumber(value) or 0, capacity))
    local info = type(item.info) == "table" and item.info or {}
    info.water = water
    exports['rsg-inventory']:SetItemData(src, item.name, "info", info)
    return water
end

local function tryAutoWaterFromWagon(src, plant, wagonNet, ignoreRequirements)
    if not (Config.wagonAutoEnabled and Config.wagonAutoWaterPlant) then
        return false
    end
    if not plant or plant.watered ~= false then
        return false
    end
    if not ignoreRequirements and not (plant.fert and plant.trem) then
        return false
    end
    local netId = tonumber(wagonNet)
    local cost = tonumber(Config.wagonAutoCost) or 0
    if not netId or cost <= 0 then
        return false
    end
    local current = WaterWagons[netId] or 0
    if current < cost then
        notify(src, "Carroca sem agua suficiente.", "error")
        return false
    end
    WaterWagons[netId] = current - cost
    TriggerClientEvent('bilto_farming:recinfowagons', -1, WaterWagons)
    plant.watered = true
    return true
end

local function normalizeCoords(coords)
    if not coords then
        return nil
    end
    if coords.x then
        return { x = coords.x, y = coords.y, z = coords.z }
    end
    if coords[1] then
        return { x = coords[1], y = coords[2], z = coords[3] }
    end
    return nil
end

local function nextRenderId()
    PlantDex = PlantDex + 1
    return PlantDex
end

local function normalizePlant(seedType, plant)
    if type(plant) ~= "table" then
        return nil
    end
    plant.type = plant.type or seedType
    plant.timer = tonumber(plant.timer) or (Config.seeds[seedType] and Config.seeds[seedType].totaltime) or 0
    plant.watered = plant.watered == true
    plant.fert = plant.fert == true
    plant.trem = plant.trem == true
    plant.difficulty = tonumber(plant.difficulty) or (Config.seeds[seedType] and Config.seeds[seedType].difficulty) or Config.maxdiff
    plant.health = tonumber(plant.health) or (Config.seeds[seedType] and Config.seeds[seedType].health) or 100
    plant.life = tonumber(plant.life) or 0
    plant.coords = normalizeCoords(plant.coords)
    plant.render = tonumber(plant.render) or plant.render
    if not plant.render then
        plant.render = nextRenderId()
    end
    return plant
end

local function indexPlant(charid, seedType, key, plant)
    if not plant or not plant.render then
        return
    end
    PlantIndex[plant.render] = {
        charid = charid,
        seedType = seedType,
        key = key,
    }
    if plant.coords then
        FarmCoords[plant.render] = plant.coords
    end
end

local function unindexPlant(render)
    PlantIndex[render] = nil
    FarmCoords[render] = nil
end

local function rebuildIndex()
    PlantIndex = {}
    FarmCoords = {}
    for charid, types in pairs(FarmData) do
        if type(types) == "table" then
            for seedType, plants in pairs(types) do
                if type(plants) == "table" then
                    for key, plant in pairs(plants) do
                        local normalized = normalizePlant(seedType, plant)
                        if normalized then
                            FarmData[charid][seedType][key] = normalized
                            indexPlant(charid, seedType, key, normalized)
                        end
                    end
                end
            end
        end
    end
end

local function saveDex()
    local updated = MySQL.update.await('UPDATE bilto_playerfarmsdex SET dex = ?', { PlantDex })
    if not updated or updated == 0 then
        MySQL.insert.await('INSERT INTO bilto_playerfarmsdex (dex) VALUES (?)', { PlantDex })
    end
end

local function savePlayer(charid)
    if not charid then
        return
    end
    local farm = FarmData[charid] or {}
    local data = json.encode(farm)
    MySQL.insert.await(
        'INSERT INTO bilto_playerfarms (charid, farm) VALUES (:charid, :farm) ON DUPLICATE KEY UPDATE farm = :farm',
        { charid = charid, farm = data }
    )
end

local function saveAll()
    for charid in pairs(FarmData) do
        savePlayer(charid)
    end
    for charid in pairs(HarvestStats) do
        saveHarvestData(charid)
    end
    saveDex()
end

local function loadAll()
    local rows = MySQL.query.await('SELECT charid, farm FROM bilto_playerfarms', {})
    for _, row in pairs(rows or {}) do
        local charid = tostring(row.charid)
        local farm = {}
        if row.farm and row.farm ~= "" then
            local ok, decoded = pcall(json.decode, row.farm)
            if ok and type(decoded) == "table" then
                farm = decoded
            end
        end
        FarmData[charid] = farm
    end

    local dex = MySQL.scalar.await('SELECT dex FROM bilto_playerfarmsdex LIMIT 1')
    PlantDex = tonumber(dex) or 0

    rebuildIndex()
    debugLog("loaded farms: " .. tostring(#(rows or {})))
end

local function loadHarvestStats()
    local rows = MySQL.query.await('SELECT charid, total, level FROM bilto_playerfarmslevels', {})
    for _, row in pairs(rows or {}) do
        local charid = tostring(row.charid)
        HarvestStats[charid] = {
            total = tonumber(row.total) or 0,
            level = tonumber(row.level) or 0
        }
    end
end

local function sendFullData(src)
    TriggerClientEvent('bilto_farming:recinfo', src, FarmData, true)
    TriggerClientEvent('bilto_farming:recinfowagons', src, WaterWagons)
    local charid = getCharId(src)
    TriggerClientEvent('bilto_farming:reccharid', src, charid)
    TriggerClientEvent('bilto_farming:recblips', src, FarmData[charid] or {})
    if charid then
        sendHarvestLevel(src, charid)
    end
end

local function isFarmerJob(jobName)
    return FarmerJobs[jobName] ~= nil
end

local function countPlants(charid)
    local total = 0
    local byType = {}
    local farms = FarmData[charid] or {}
    for seedType, plants in pairs(farms) do
        local count = 0
        for _ in pairs(plants) do
            count = count + 1
        end
        byType[seedType] = count
        total = total + count
    end
    return total, byType
end

local function distance(a, b)
    local dx = (a.x - b.x)
    local dy = (a.y - b.y)
    local dz = (a.z - b.z)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function isTooClose(coords)
    if not coords or not Config.plantspace then
        return false
    end
    for _, plant in pairs(PlantIndex) do
        local data = FarmData[plant.charid] and FarmData[plant.charid][plant.seedType]
        local p = data and data[plant.key]
        if p and p.coords and distance(coords, p.coords) < Config.plantspace then
            return true
        end
    end
    return false
end

local function updatePlantForAll(charid, seedType, key, plant, source)
    local renderId = plant and plant.render or nil
    if Config.updateOwnerOnly then
        for _, src in ipairs(getOwnerSources(charid)) do
            TriggerClientEvent('bilto_farming:recplant', src, charid, seedType, key, plant, renderId)
        end
        return
    end
    if source then
        TriggerClientEvent('bilto_farming:recplant', source, charid, seedType, key, plant, renderId)
    end
    if not Config.updateNearbyOnly or not plant or not plant.coords then
        if not source then
            TriggerClientEvent('bilto_farming:recplant', -1, charid, seedType, key, plant, renderId)
        end
        return
    end
    local radius = tonumber(Config.updateRadius) or Config.render or 15
    for src, pcoords in pairs(PlayerCoords) do
        if pcoords and (not source or src ~= source) then
            if distance(pcoords, plant.coords) <= radius then
                TriggerClientEvent('bilto_farming:recplant', src, charid, seedType, key, plant, renderId)
            end
        end
    end
end

local function applyTimerDelta(plant, deltaMinutes)
    if not plant or not plant.timer or plant.timer <= 0 or deltaMinutes <= 0 then
        return false
    end
    local oldTimer = plant.timer
    local timeToWater = Config.seeds[plant.type] and Config.seeds[plant.type].timetowater
    local newTimer = oldTimer
    local crossedTimeToWater = false

    if not timeToWater then
        newTimer = math.max(oldTimer - deltaMinutes, 0)
    else
        timeToWater = tonumber(timeToWater) or 0
        if oldTimer > timeToWater then
            local above = oldTimer - timeToWater
            if deltaMinutes <= above then
                newTimer = oldTimer - deltaMinutes
            else
                local remaining = deltaMinutes - above
                crossedTimeToWater = true
                if plant.watered then
                    newTimer = math.max(timeToWater - remaining, 0)
                else
                    newTimer = timeToWater
                end
            end
        elseif oldTimer == timeToWater then
            if plant.watered then
                newTimer = math.max(oldTimer - deltaMinutes, 0)
            else
                newTimer = oldTimer
            end
        else
            newTimer = math.max(oldTimer - deltaMinutes, 0)
        end
        if oldTimer > timeToWater and newTimer <= timeToWater then
            crossedTimeToWater = true
        end
    end

    plant.timer = newTimer
    if newTimer == oldTimer then
        return false
    end

    local hitZero = oldTimer > 0 and newTimer == 0
    return crossedTimeToWater or hitZero
end

local function sendRemoval(charid, renderId)
    TriggerClientEvent('bilto_farming:recplant', -1, nil, nil, nil, nil, renderId)
end

local function removePlant(render, reason)
    local idx = PlantIndex[render]
    if not idx then
        return
    end
    local charid = idx.charid
    local seedType = idx.seedType
    local key = idx.key
    if FarmData[charid] and FarmData[charid][seedType] then
        FarmData[charid][seedType][key] = nil
        if next(FarmData[charid][seedType]) == nil then
            FarmData[charid][seedType] = nil
        end
    end
    unindexPlant(render)
    debugLog(("remove plant render=%s owner=%s type=%s reason=%s"):format(
        tostring(render),
        tostring(charid),
        tostring(seedType),
        tostring(reason or "unknown")
    ))
    sendRemoval(idx.charid, render)
    savePlayer(charid)
end

local function registerUseableItems()
    local registered = {}
    if Config.singleBucket and Config.bucketItem then
        registered[Config.bucketItem] = true
        RSGCore.Functions.CreateUseableItem(Config.bucketItem, function(source)
            TriggerClientEvent('bilto_farming:wateringcan', source)
        end)
    end

    for seedType, data in pairs(Config.seeds or {}) do
        if data.seedname and not registered[data.seedname] then
            registered[data.seedname] = true
            RSGCore.Functions.CreateUseableItem(data.seedname, function(source)
                if FarmingLock[source] then
                    return
                end
                FarmingLock[source] = true
                TriggerClientEvent('bilto_farming:usedseed', source, seedType)
            end)
        end
    end

    if not Config.singleBucket then
        for _, itemName in pairs(Config.watercanitems or {}) do
            if itemName and not registered[itemName] then
                registered[itemName] = true
                RSGCore.Functions.CreateUseableItem(itemName, function(source)
                    TriggerClientEvent('bilto_farming:wateringcan', source)
                end)
            end
        end

        if Config.emptycan and not registered[Config.emptycan] then
            registered[Config.emptycan] = true
            RSGCore.Functions.CreateUseableItem(Config.emptycan, function(source)
                TriggerClientEvent('bilto_farming:usebucketinwater', source)
            end)
        end
    end
end
-- tabelas criadas automaticamente ao iniciar (SQL compativel com MySQL e MariaDB)
local DatabaseSchema = {
    [[
        CREATE TABLE IF NOT EXISTS `bilto_playerfarms` (
            `charid` VARCHAR(50) NOT NULL,
            `farm` LONGTEXT NOT NULL,
            PRIMARY KEY (`charid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]],
    [[
        CREATE TABLE IF NOT EXISTS `bilto_playerfarmsdex` (
            `dex` BIGINT NOT NULL DEFAULT 0
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]],
    [[
        CREATE TABLE IF NOT EXISTS `bilto_playerfarmslevels` (
            `charid` VARCHAR(50) NOT NULL,
            `total` INT NOT NULL DEFAULT 0,
            `level` INT NOT NULL DEFAULT 0,
            PRIMARY KEY (`charid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]],
}

local function setupDatabase()
    for _, query in ipairs(DatabaseSchema) do
        local ok, err = pcall(MySQL.query.await, query)
        if not ok then
            print(("^1[bilto_farming] erro ao criar tabela: %s^0"):format(tostring(err)))
            return false
        end
    end
    local ok, dex = pcall(MySQL.scalar.await, 'SELECT dex FROM bilto_playerfarmsdex LIMIT 1')
    if ok and dex == nil then
        MySQL.insert.await('INSERT INTO bilto_playerfarmsdex (dex) VALUES (0)')
    end
    print("^2[bilto_farming] banco de dados pronto^0")
    return true
end

MySQL.ready(function()
    registerUseableItems()
    if not setupDatabase() then
        return
    end

    loadAll()
    loadHarvestStats()
    for _, src in pairs(RSGCore.Functions.GetPlayers()) do
        local charid = getCharId(src)
        if charid then
            addOwnerSource(src, charid)
        end
        sendFullData(src)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        saveAll()
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    FarmingLock[src] = nil
    PlayerCoords[src] = nil
    removeOwnerSource(src)
end)

AddEventHandler('RSGCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    removeOwnerSource(src)
    local charid = getCharId(src)
    if charid then
        addOwnerSource(src, charid)
    end
    sendFullData(src)
end)

RegisterNetEvent('bilto_farming:requestcharid', function()
    TriggerClientEvent('bilto_farming:reccharid', source, getCharId(source))
end)

RegisterNetEvent('bilto_farming:requestlevel', function()
    local src = source
    local charid = getCharId(src)
    if charid then
        sendHarvestLevel(src, charid)
    end
end)

RegisterNetEvent('bilto_farming:requestcoords', function()
    TriggerClientEvent('bilto_farming:reccoords', source, FarmCoords)
end)

RegisterNetEvent('bilto_farming:requestplants', function(renderIds)
    local src = source
    if type(renderIds) ~= "table" then
        return
    end
    local payload = {}
    for _, render in ipairs(renderIds) do
        local renderId = tonumber(render)
        local idx = renderId and PlantIndex[renderId]
        if idx and FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] then
            local plant = FarmData[idx.charid][idx.seedType][idx.key]
            if plant then
                table.insert(payload, {
                    k = idx.charid,
                    x = idx.seedType,
                    g = idx.key,
                    info = plant,
                })
            end
        end
    end
    TriggerClientEvent('bilto_farming:recplants', src, payload)
end)

RegisterNetEvent('bilto_farming:requestblips', function()
    local src = source
    local charid = getCharId(src)
    TriggerClientEvent('bilto_farming:recblips', src, FarmData[charid] or {})
end)

RegisterNetEvent('bilto_farming:updatecoords', function(coords)
    PlayerCoords[source] = normalizeCoords(coords)
end)

RegisterNetEvent('bilto_farming:requestupdate', function(render)
    local src = source
    local renderId = tonumber(render)
    local idx = renderId and PlantIndex[renderId]
    if not idx then
        return
    end
    local plant = FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] and FarmData[idx.charid][idx.seedType][idx.key]
    if plant then
        TriggerClientEvent('bilto_farming:recplant', src, idx.charid, idx.seedType, idx.key, plant, renderId)
    end
end)

-- valida o plantio (itens, limites, zona do job, distancia); retorna ok, mensagem de erro
local function validatePlanting(src, seedType, fixedCoords)
    local player = RSGCore.Functions.GetPlayer(src)
    local charid = getCharId(src)
    local seedData = Config.seeds[seedType]
    if not player or not charid or not seedData then
        return false
    end

    local jobName = player.PlayerData.job and player.PlayerData.job.name or "unknown"
    if seedData.joblocked and seedData.joblocked ~= 0 and type(seedData.joblocked) == "table" then
        local allowed = false
        for _, job in pairs(seedData.joblocked) do
            if job == jobName then
                allowed = true
                break
            end
        end
        if not allowed then
            return false, language.joblock or "Job locked."
        end
    end

    if seedData.seedname and seedData.seedreq and not hasItem(src, seedData.seedname, seedData.seedreq) then
        return false, language.notenoughseeds or "Not enough seeds."
    end

    if Config.plantingitem and not hasItem(src, Config.plantingitem, 1) then
        return false, language.nohoe or "Missing planting tool."
    end

    local total, byType = countPlants(charid)
    local normalMax = tonumber(Config.totalplants) or 30
    local jobData = JobPlants.enabled and FarmerJobs[jobName] or nil
    local maxTotal = jobData and math.max(tonumber(jobData.maxTotal) or normalMax, normalMax) or normalMax
    if total >= maxTotal then
        return false, language.toomany or "Too many plants."
    end

    -- plantas acima do limite normal (so job): precisam estar dentro de uma zona do proprio job
    if total >= normalMax and JobPlants.zoneRequired ~= false and not isInJobZone(fixedCoords, jobName) then
        return false, (language.needjobzone or "Need to be inside the farm zone (%s)."):format(normalMax)
    end

    local maxType = seedData.maxcount or maxTotal
    if jobData then
        maxType = maxType + (tonumber(jobData.extraPerType) or 0)
    end
    if (byType[seedType] or 0) >= maxType then
        return false, language.toomanyofkind or "Too many of this plant."
    end

    if fixedCoords and isTooClose(fixedCoords) then
        return false, language.closeplant or "Too close to another plant."
    end

    return true
end

-- checagem antes da animacao de plantar
RSGCore.Functions.CreateCallback('bilto_farming:canPlant', function(source, cb, seedType, coords)
    local ok, message = validatePlanting(source, seedType, normalizeCoords(coords))
    if not ok then
        FarmingLock[source] = nil
        if message then
            notify(source, message, "error")
        end
    end
    cb(ok)
end)

RegisterNetEvent('bilto_farming:approvefarming', function(seedType, coords, wagonNet)
    local src = source
    local fixedCoords = normalizeCoords(coords)
    local ok, message = validatePlanting(src, seedType, fixedCoords)
    if not ok then
        if message then
            notify(src, message, "error")
        end
        return
    end
    local charid = getCharId(src)
    local seedData = Config.seeds[seedType]

    if seedData.seedname and seedData.seedreq then
        removeItem(src, seedData.seedname, seedData.seedreq)
    end

    FarmData[charid] = FarmData[charid] or {}
    FarmData[charid][seedType] = FarmData[charid][seedType] or {}

    local renderId = nextRenderId()
    local plant = {
        type = seedType,
        coords = fixedCoords,
        render = renderId,
        timer = seedData.totaltime or 0,
        watered = false,
        fert = false,
        trem = false,
        difficulty = seedData.difficulty or Config.maxdiff,
        health = seedData.health or 100,
        life = 0,
    }

    tryAutoWaterFromWagon(src, plant, wagonNet, true)

    FarmData[charid][seedType][renderId] = plant
    indexPlant(charid, seedType, renderId, plant)
    savePlayer(charid)
    saveDex()

    updatePlantForAll(charid, seedType, renderId, plant, src)
    TriggerClientEvent('bilto_farming:createblip', src, seedType, fixedCoords, renderId)
end)

RegisterNetEvent('bilto_farming:cleartofarm', function()
    FarmingLock[source] = nil
end)

-- valida a acao sem consumir nada (usado antes da animacao no client)
local function validateAction(src, action, seedType, plant)
    if action == "harvest" then
        if plant.watered ~= true then
            return false, "Regue a planta antes de colher."
        end
        if plant.timer and plant.timer > 0 then
            return false, "A planta ainda não está pronta."
        end
    elseif action == "trim" then
        if plant.trem then
            return false, "Esta planta já foi podada."
        end
        if Config.trimmeritem and not hasItem(src, Config.trimmeritem, 1) then
            return false, language.notrimmer or "Missing trimmer."
        end
    elseif action == "fert" then
        if plant.fert then
            return false, language.arfert or "Already fertilized."
        end
        local fertConfig = Config.seeds[seedType] and Config.seeds[seedType].fert
        if fertConfig and not resolveFertItem(src, fertConfig) then
            return false, language.nofert or "Missing fertilizer."
        end
    elseif action == "water" then
        if plant.watered then
            return false, "Esta planta já foi regada."
        end
        if Config.singleBucket then
            local bucket = getBucketItem(src)
            if not bucket then
                return false, "Você precisa de um balde."
            end
            if getBucketWater(bucket) < (tonumber(Config.bucketUse) or 20) then
                return false, "Balde sem agua suficiente."
            end
        elseif Config.cleanwateritem and not hasItem(src, Config.cleanwateritem, 1) then
            return false, language.needempty or "Need a clean bucket."
        end
    end
    return true
end

RSGCore.Functions.CreateCallback('bilto_farming:canInteract', function(source, cb, action, render)
    local renderId = tonumber(render)
    local idx = renderId and PlantIndex[renderId]
    local plant = idx and FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] and FarmData[idx.charid][idx.seedType][idx.key]
    if not plant then
        cb(false)
        return
    end
    if Config.onlyowner then
        local charid = getCharId(source)
        if not charid or tostring(charid) ~= tostring(idx.charid) then
            cb(false)
            return
        end
    end
    local ok, message = validateAction(source, action, idx.seedType, plant)
    if not ok then
        notify(source, message, "error")
    end
    cb(ok)
end)

RegisterNetEvent('bilto_farming:interact', function(action, seedType, render, wagonNet)
    local src = source
    local renderId = tonumber(render)
    local idx = renderId and PlantIndex[renderId]
    if not idx then
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    local plant = FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] and FarmData[idx.charid][idx.seedType][idx.key]
    if not plant then
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if Config.onlyowner then
        local charid = getCharId(src)
        if not charid or tostring(charid) ~= tostring(idx.charid) then
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
    end

    if action == "remove" then
        removePlant(renderId, "manual_remove")
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if action == "harvest" then
        if plant.watered ~= true then
            notify(src, "Regue a planta antes de colher.", "error")
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        if plant.timer and plant.timer > 0 then
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        local harvesterId = getCharId(src) or idx.charid
        local harvestData = getHarvestData(harvesterId)
        local bonus = getHarvestBonus(harvestData.level or 0)
        local rewards = Config.seeds[idx.seedType] and Config.seeds[idx.seedType].rewarditem or {}
        local trimBoost = Config.seeds[idx.seedType] and Config.seeds[idx.seedType].trimboost or 0
        local harvested = {}
        local totalAdded = 0
        for _, reward in pairs(rewards) do
            local count = tonumber(reward.count) or 1
            if plant.trem and trimBoost > 0 then
                count = count + trimBoost
            end
            if bonus > 0 then
                count = count + bonus
            end
            if Config.plantredhp and plant.health and plant.health <= Config.plantredhp then
                count = count - (Config.nohealthsubamount or 0)
            end
            if count <= 0 then
                count = 1
            end
            addItem(src, reward.name, count)
            local label = reward.label or reward.name or "Item"
            harvested[#harvested + 1] = (tostring(count) .. "x " .. tostring(label))
            totalAdded = totalAdded + count
        end
        if Config.harvestLevelEnabled and harvesterId and totalAdded > 0 then
            local beforeLevel = harvestData.level or 0
            harvestData.total = (harvestData.total or 0) + totalAdded
            harvestData.level = getHarvestLevel(harvestData.total)
            saveHarvestData(harvesterId)
            sendHarvestLevel(src, harvesterId)
            if Config.harvestLevelNotify and harvestData.level > beforeLevel then
                local bonusNow = getHarvestBonus(harvestData.level)
                notify(src, ("Nivel de colheita %s! Bonus +%s."):format(harvestData.level, bonusNow), "success")
            end
        end
        if #harvested > 0 then
            notify(src, "Voce colheu: " .. table.concat(harvested, ", "), "success")
            sendHarvestWebhook(src, harvested)
        end
        removePlant(renderId, "harvest")
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if action == "dmg" then
        plant.health = (plant.health or 0) - (Config.healthlossonfail or 0)
        plant.difficulty = math.min((plant.difficulty or 0) + (Config.diffinc or 0), Config.maxdiff or (plant.difficulty or 0))
        if plant.health <= (Config.plantdestructionhp or 0) then
            removePlant(renderId, "health_zero")
            notify(src, language.dmgnorec or "Plant destroyed.", "error")
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        notify(src, language.dmgrec or "Plant damaged.", "error")
        updatePlantForAll(idx.charid, idx.seedType, idx.key, plant, src)
        savePlayer(idx.charid)
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if action == "trim" then
        if plant.trem then
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        if Config.trimmeritem and not hasItem(src, Config.trimmeritem, 1) then
            notify(src, language.notrimmer or "Missing trimmer.", "error")
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        plant.trem = true
        tryAutoWaterFromWagon(src, plant, wagonNet)
        TriggerClientEvent('bilto_farming:animationtrigger', src, "trim")
        updatePlantForAll(idx.charid, idx.seedType, idx.key, plant, src)
        savePlayer(idx.charid)
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if action == "fert" then
        if plant.fert then
            notify(src, language.arfert or "Already fertilized.", "error")
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        local fertConfig = Config.seeds[idx.seedType] and Config.seeds[idx.seedType].fert
        local fertItem, fertCount = resolveFertItem(src, fertConfig)
        if fertConfig and not fertItem then
            notify(src, language.nofert or "Missing fertilizer.", "error")
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        if fertItem and fertCount > 0 then
            removeItem(src, fertItem, fertCount)
        end
        plant.fert = true
        local currentTimer = tonumber(plant.timer) or 0
        local fertMinutes = 5
        plant.timer = math.max(currentTimer - fertMinutes, 0)
        tryAutoWaterFromWagon(src, plant, wagonNet)
        TriggerClientEvent('bilto_farming:animationtrigger', src, "fert")
        updatePlantForAll(idx.charid, idx.seedType, idx.key, plant, src)
        savePlayer(idx.charid)
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    if action == "water" then
        if plant.watered then
            TriggerClientEvent('bilto_farming:recst', src)
            return
        end
        if Config.singleBucket then
            local bucket = getBucketItem(src)
            if not bucket then
                notify(src, language.needempty or "Need a bucket.", "error")
                TriggerClientEvent('bilto_farming:recst', src)
                return
            end
            local useAmount = tonumber(Config.bucketUse) or 20
            local current = getBucketWater(bucket)
            if current < useAmount then
                notify(src, "Balde sem agua suficiente.", "error")
                TriggerClientEvent('bilto_farming:recst', src)
                return
            end
            setBucketWater(src, bucket, current - useAmount)
        else
            if Config.cleanwateritem and not hasItem(src, Config.cleanwateritem, 1) then
                notify(src, language.needempty or "Need a clean bucket.", "error")
                TriggerClientEvent('bilto_farming:recst', src)
                return
            end
            if Config.cleanwateritem then
                removeItem(src, Config.cleanwateritem, 1)
            end
            if Config.emptycan then
                addItem(src, Config.emptycan, 1)
            end
        end
        plant.watered = true
        updatePlantForAll(idx.charid, idx.seedType, idx.key, plant, src)
        savePlayer(idx.charid)
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end

    TriggerClientEvent('bilto_farming:recst', src)
end)

RegisterNetEvent('bilto_farming:watefromriver', function()
    local src = source
    if Config.singleBucket then
        local bucket = getBucketItem(src)
        if not bucket then
            notify(src, language.needempty or "Need a bucket.", "error")
            TriggerClientEvent('bilto_farming:cbuck', src)
            return
        end
        setBucketWater(src, bucket, Config.bucketCapacity or 100)
    else
        if Config.emptycan and not hasItem(src, Config.emptycan, 1) then
            notify(src, language.needempty or "Need an empty bucket.", "error")
            TriggerClientEvent('bilto_farming:cbuck', src)
            return
        end
        if Config.emptycan then
            removeItem(src, Config.emptycan, 1)
        end
        if Config.dirtywateritem then
            addItem(src, Config.dirtywateritem, 1)
        end
    end
    TriggerClientEvent('bilto_farming:cbuck', src)
end)

RegisterNetEvent('bilto_farming:termbucket', function()
    TriggerClientEvent('bilto_farming:cbuck', source)
end)

RegisterNetEvent('bilto_farming:checkbucket', function()
    local src = source
    if Config.singleBucket then
        local bucket = getBucketItem(src)
        if not bucket then
            TriggerClientEvent('bilto_farming:clearonholdbucket', src)
            notify(src, language.needempty or "Need a bucket.", "error")
            return
        end
        setBucketWater(src, bucket, Config.bucketCapacity or 100)
        TriggerClientEvent('bilto_farming:pumpbucket', src)
        return
    end
    if Config.dirtywateritem and hasItem(src, Config.dirtywateritem, 1) then
        removeItem(src, Config.dirtywateritem, 1)
        if Config.cleanwateritem then
            addItem(src, Config.cleanwateritem, 1)
        end
        TriggerClientEvent('bilto_farming:pumpbucket', src)
        return
    end
    TriggerClientEvent('bilto_farming:clearonholdbucket', src)
    notify(src, language.needempty or "Need a bucket.", "error")
end)

RegisterNetEvent('bilto_farming:sendwagonfillrequest', function(modelKey, network)
    local src = source
    local maxCap = Config.waterwagons and Config.waterwagons[modelKey]
    local netId = tonumber(network)
    if not maxCap or not netId then
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    local current = WaterWagons[netId] or 0
    if current >= maxCap then
        notify(src, language.wagonfull or "Wagon full.", "error")
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    local add = tonumber(Config.wagonFillAmount) or 1
    if add <= 0 then
        add = 1
    end
    if current + add > maxCap then
        add = maxCap - current
    end
    if add <= 0 then
        notify(src, language.wagonfull or "Wagon full.", "error")
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    WaterWagons[netId] = current + add
    TriggerClientEvent('bilto_farming:recinfowagons', -1, WaterWagons)
    TriggerClientEvent('bilto_farming:recst', src)
end)

RegisterNetEvent('bilto_farming:waterfromwagon', function(network)
    local src = source
    local netId = tonumber(network)
    if not netId then
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    local current = WaterWagons[netId] or 0
    local cost = tonumber(Config.wagonBucketCost) or (Config.bucketCapacity or 100)
    if cost <= 0 then
        cost = 1
    end
    if current < cost then
        notify(src, language.wagonfull or "Wagon empty.", "error")
        TriggerClientEvent('bilto_farming:recst', src)
        return
    end
    WaterWagons[netId] = current - cost
    TriggerClientEvent('bilto_farming:recinfowagons', -1, WaterWagons)
    if Config.singleBucket then
        local bucket = getBucketItem(src)
        if bucket then
            setBucketWater(src, bucket, Config.bucketCapacity or 100)
        else
            notify(src, language.needempty or "Need a bucket.", "error")
        end
    elseif Config.cleanwateritem then
        addItem(src, Config.cleanwateritem, 1)
    end
    TriggerClientEvent('bilto_farming:recst', src)
end)

CreateThread(function()
    local saveCounter = 0
    local lastMinute = -1
    local lastTick = os.time()
    while true do
        Wait(60000)
        local nowStamp = os.time()
        local deltaMinutes = math.floor((nowStamp - lastTick) / 60)
        if deltaMinutes < 1 then
            deltaMinutes = 1
        end
        lastTick = nowStamp
        local now = os.date("*t")
        local minutes = now.hour * 60 + now.min

        for _, idx in pairs(PlantIndex) do
            local plant = FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] and FarmData[idx.charid][idx.seedType][idx.key]
            if plant and plant.timer and plant.timer > 0 then
                local shouldUpdate = applyTimerDelta(plant, deltaMinutes)
                if shouldUpdate then
                    updatePlantForAll(idx.charid, idx.seedType, idx.key, plant)
                end
            end
        end

        saveCounter = saveCounter + 1
        if Config.timesave and saveCounter >= Config.timesave then
            saveAll()
            saveCounter = 0
        end

        if minutes ~= lastMinute then
            lastMinute = minutes
            for _, restartMinute in pairs(Config.restarttime or {}) do
                if minutes == restartMinute then
                    for _, idx in pairs(PlantIndex) do
                        local plant = FarmData[idx.charid] and FarmData[idx.charid][idx.seedType] and FarmData[idx.charid][idx.seedType][idx.key]
                        if plant then
                            plant.life = (plant.life or 0) + 1
                            if Config.totallife and plant.life >= Config.totallife then
                                removePlant(plant.render, "life_cycle")
                            else
                                updatePlantForAll(idx.charid, idx.seedType, idx.key, plant)
                            end
                        end
                    end
                    saveAll()
                    break
                end
            end
        end
    end
end)
