BitinhoAdminWall = BitinhoAdminWall or {}

local Config = type(Config) == 'table' and Config or {}
local clientConfig = type(Config.Client) == 'table' and Config.Client or {}
local wallTextConfig = type(clientConfig.wallText) == 'table' and clientConfig.wallText or {}
local wallWeaponConfig = type(clientConfig.wallWeaponState) == 'table' and clientConfig.wallWeaponState or {}

local function readString(value, fallback)
    if type(value) ~= 'string' then
        return fallback
    end
    local output = value:gsub('^%s+', ''):gsub('%s+$', '')
    if output == '' then
        return fallback
    end
    return output
end

local function readNumber(value, fallback)
    local parsed = tonumber(value)
    if parsed == nil then
        return fallback
    end
    return parsed
end

local UNARMED_HASH = GetHashKey('WEAPON_UNARMED')
local WALL_WEAPON_STATE_KEY = readString(wallWeaponConfig.stateBagKey, 'bitinho_wall_weapon')
local RSGCore = exports['rsg-core']:GetCoreObject()
local weaponLabelCache = {}

local DEFAULT_CONFIG = {
    maxDistance = readNumber(wallTextConfig.maxDistance, 260.0),
    zOffset = readNumber(wallTextConfig.zOffset, 0.92)
}

local TITLE_RGB = { 60, 205, 95, 215 }
local VALUE_RGB = { 255, 255, 255, 215 }
local ROLE_RED_RGB = { 220, 70, 70, 215 }
local ROLE_YELLOW_RGB = { 235, 205, 70, 215 }
local ROLE_BLUE_RGB = { 90, 175, 255, 215 }
local WALL_ON_RGB = { 60, 205, 95, 215 }
local WALL_OFF_RGB = { 220, 70, 70, 215 }
local LINE_HEIGHT = 0.022
local CHAR_WIDTH = 0.00385

local function sanitizeFallback(value, maxLength, fallback)
    local output = tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if output == '' then
        output = fallback or ''
    end

    local limit = tonumber(maxLength) or 128
    if #output > limit then
        output = output:sub(1, limit)
    end

    return output
end

local function getLocaleBundles()
    local allLocales = type(Config.Locales) == 'table' and Config.Locales or {}
    local activeKey = readString(Config.Locale, 'ptbr'):lower()
    local active = type(allLocales[activeKey]) == 'table' and allLocales[activeKey] or {}
    local fallback = type(allLocales.ptbr) == 'table' and allLocales.ptbr or active
    return active, fallback
end

local function getLocalizedText(key, fallbackText)
    local active, fallback = getLocaleBundles()
    local activeText = active[key]
    if type(activeText) == 'string' and activeText ~= '' then
        return activeText
    end

    local fallbackLocaleText = fallback[key]
    if type(fallbackLocaleText) == 'string' and fallbackLocaleText ~= '' then
        return fallbackLocaleText
    end

    return fallbackText or ''
end

local function getRoleLabel(roleKey, fallbackLabel)
    local normalizedKey = readString(roleKey, ''):lower()
    if normalizedKey == '' then
        return fallbackLabel or ''
    end

    local localeKey = ('permission_role_%s'):format(normalizedKey)
    return getLocalizedText(localeKey, fallbackLabel or normalizedKey)
end

local function normalizeConfig(overrides)
    local config = type(overrides) == 'table' and overrides or {}
    local maxDistance = tonumber(config.maxDistance) or DEFAULT_CONFIG.maxDistance
    local zOffset = tonumber(config.zOffset) or DEFAULT_CONFIG.zOffset

    return {
        maxDistance = maxDistance,
        maxDistanceSq = maxDistance * maxDistance,
        zOffset = zOffset
    }
end

local function normalizeRoleKey(value)
    if type(value) ~= 'string' then
        return ''
    end

    return value:lower():gsub('^%s+', ''):gsub('%s+$', '')
end

local function getRoleColor(roleLabel)
    local roleKey = normalizeRoleKey(roleLabel)
    if roleKey == 'fundador' or roleKey == 'founder' or roleKey == 'god' or roleKey == 'headadmin' then
        return ROLE_RED_RGB
    end
    if roleKey == 'admin' or roleKey == 'mod' then
        return ROLE_RED_RGB
    end
    if roleKey == 'helper' then
        return ROLE_BLUE_RGB
    end
    if roleKey == 'developer' then
        return ROLE_YELLOW_RGB
    end
    if roleKey == 'administrador' or roleKey == 'administrator' then
        return ROLE_RED_RGB
    end
    if roleKey == 'banimento' or roleKey == 'ban' then
        return ROLE_RED_RGB
    end
    if roleKey == 'suporte' or roleKey == 'support' then
        return ROLE_BLUE_RGB
    end
    return VALUE_RGB
end

local function buildSegment(text, color)
    return {
        text = tostring(text or ''),
        color = color or VALUE_RGB
    }
end

local function estimateSegmentWidth(text)
    return (#tostring(text or '')) * CHAR_WIDTH
end

local function drawSegmentsLine(x, y, z, lineIndex, segments)
    local totalWidth = 0.0
    for _, segment in ipairs(segments) do
        totalWidth = totalWidth + estimateSegmentWidth(segment.text)
    end

    local startX = -(totalWidth / 2.0)
    local currentX = startX
    local currentY = (lineIndex - 1) * LINE_HEIGHT

    SetDrawOrigin(x + 0.0, y + 0.0, z + 0.0, 0)

    for _, segment in ipairs(segments) do
        local color = segment.color or VALUE_RGB

        SetTextScale(0.25, 0.25)
        SetTextFontForCurrentCommand(9)
        SetTextCentre(false)
        SetTextColor(color[1], color[2], color[3], color[4] or 215)
        SetTextDropshadow(1, 0, 0, 0, 200)

        DisplayText(CreateVarString(10, "LITERAL_STRING", segment.text), currentX, currentY)
        currentX = currentX + estimateSegmentWidth(segment.text)
    end

    ClearDrawOrigin()
end

function BitinhoAdminWall.createConfig(overrides)
    return normalizeConfig(overrides)
end

function BitinhoAdminWall.resolveCoords(entry, serverId, zOffset)
    local offset = tonumber(zOffset) or DEFAULT_CONFIG.zOffset
    local playerIndex = GetPlayerFromServerId(serverId)
    if playerIndex and playerIndex ~= -1 then
        local targetPed = GetPlayerPed(playerIndex)
        if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            return {
                x = targetCoords.x + 0.0,
                y = targetCoords.y + 0.0,
                z = (targetCoords.z + offset) + 0.0
            }, targetPed
        end
    end

    local fallbackCoords = entry and entry.coords
    if fallbackCoords and fallbackCoords.x and fallbackCoords.y and fallbackCoords.z then
        return {
            x = (tonumber(fallbackCoords.x) or 0.0) + 0.0,
            y = (tonumber(fallbackCoords.y) or 0.0) + 0.0,
            z = ((tonumber(fallbackCoords.z) or 0.0) + offset) + 0.0
        }, nil
    end
end

function BitinhoAdminWall.isInRange(originCoords, targetCoords, maxDistanceSq)
    local ox = originCoords and tonumber(originCoords.x)
    local oy = originCoords and tonumber(originCoords.y)
    local oz = originCoords and tonumber(originCoords.z)
    local tx = targetCoords and tonumber(targetCoords.x)
    local ty = targetCoords and tonumber(targetCoords.y)
    local tz = targetCoords and tonumber(targetCoords.z)
    if not ox or not oy or not oz or not tx or not ty or not tz then
        return false
    end

    local dx = ox - tx
    local dy = oy - ty
    local dz = oz - tz
    local distanceSq = (dx * dx) + (dy * dy) + (dz * dz)
    return distanceSq <= (tonumber(maxDistanceSq) or (DEFAULT_CONFIG.maxDistance * DEFAULT_CONFIG.maxDistance))
end

local function getWeaponDefinition(weaponHash)
    local shared = RSGCore and RSGCore.Shared and RSGCore.Shared.Weapons
    if type(shared) ~= 'table' then
        return nil
    end
    return shared[weaponHash]
end

local function getWeaponLabel(weaponHash)
    if weaponLabelCache[weaponHash] then
        return weaponLabelCache[weaponHash]
    end

    local definition = getWeaponDefinition(weaponHash)
    local label = definition and (definition.label or definition.name) or nil
    if type(label) ~= 'string' or label == '' then
        label = 'Arma'
    end

    weaponLabelCache[weaponHash] = label
    return label
end

local function getHealthPercent(targetPed)
    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        return nil
    end

    local current = tonumber(GetEntityHealth(targetPed)) or 0
    local maximum = tonumber(GetEntityMaxHealth(targetPed)) or 0
    if maximum <= 0 then
        return nil
    end

    local percent = math.floor(((current / maximum) * 100) + 0.5)
    if percent < 0 then
        percent = 0
    elseif percent > 100 then
        percent = 100
    end
    return percent
end

local function getReplicatedWeaponState(serverId)
    local id = tonumber(serverId)
    if not id or type(Player) ~= 'function' then
        return nil
    end

    local targetPlayer = Player(id)
    if not targetPlayer or not targetPlayer.state then
        return nil
    end

    local state = targetPlayer.state[WALL_WEAPON_STATE_KEY]
    if type(state) ~= 'table' then
        return nil
    end

    local weaponHash = tonumber(state.weaponHash) or 0
    if weaponHash == 0 or weaponHash == UNARMED_HASH or weaponHash == -1569615261 then
        return nil
    end

    return {
        weaponHash = weaponHash
    }
end

local function normalizeWeaponState(state)
    if type(state) ~= 'table' then
        return nil
    end

    local weaponHash = tonumber(state.weaponHash) or 0
    if weaponHash == 0 or weaponHash == UNARMED_HASH or weaponHash == -1569615261 then
        return nil
    end

    return {
        weaponHash = weaponHash
    }
end

function BitinhoAdminWall.buildLines(entry, serverId, wallEnabled, sanitizeText, targetPed)
    local sanitizer = type(sanitizeText) == 'function' and sanitizeText or sanitizeFallback
    local adminLabel = getLocalizedText('wall_label_admin', 'ADMIN')
    local cidLabel = getLocalizedText('wall_label_cid', 'CID')
    local idLabel = getLocalizedText('wall_label_id', 'ID')
    local nameLabel = getLocalizedText('wall_label_name', 'NAME')
    local wallLabel = getLocalizedText('wall_label_wall', 'WALL')
    local healthLabel = getLocalizedText('wall_label_health', 'HEALTH')
    local weaponLabelText = getLocalizedText('wall_label_weapon', 'WEAPON')
    local wallOnLabel = getLocalizedText('wall_state_on', 'ON')
    local wallOffLabel = getLocalizedText('wall_state_off', 'OFF')
    local cid = sanitizer(type(entry) == 'table' and entry.citizenid or nil, 32, 'N/A')
    local fullName = sanitizer(type(entry) == 'table' and (entry.fullname or entry.name) or nil, 40, 'N/A')
    local adminRole = sanitizer(type(entry) == 'table' and entry.adminRole or nil, 48, '')
    local adminRoleKey = sanitizer(type(entry) == 'table' and entry.adminRoleKey or nil, 64, '')
    local adminRoleLabel = getRoleLabel(adminRoleKey, adminRole)

    cid = cid:gsub('|', ''):gsub('%s+', '')

    if cid == '' then
        cid = 'N/A'
    end
    if fullName == '' then
        fullName = 'N/A'
    end

    local idText = tostring(tonumber(serverId) or serverId or 'N/A')
    local wallState = wallEnabled and ('[ %s ]'):format(wallOnLabel) or ('[ %s ]'):format(wallOffLabel)
    local wallStateColor = wallEnabled and WALL_ON_RGB or WALL_OFF_RGB
    local healthText = 'N/A'
    local weaponText = nil
    local adminRoleColor = getRoleColor(adminRoleKey ~= '' and adminRoleKey or adminRole)

    local healthPercent = getHealthPercent(targetPed)
    if healthPercent ~= nil then
        healthText = ('%d%%'):format(healthPercent)
    end

    local replicatedWeapon = normalizeWeaponState(type(entry) == 'table' and entry.weapon or nil)
    if not replicatedWeapon then
        replicatedWeapon = getReplicatedWeaponState(serverId)
    end
    if replicatedWeapon then
        weaponText = sanitizeFallback(getWeaponLabel(replicatedWeapon.weaponHash), 64, weaponLabelText)
    elseif targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
        local hasWeapon, weaponHash = GetCurrentPedWeapon(targetPed, true, 0, true)
        if hasWeapon and weaponHash and weaponHash ~= 0 and weaponHash ~= UNARMED_HASH and weaponHash ~= -1569615261 then
            weaponText = sanitizeFallback(getWeaponLabel(weaponHash), 64, weaponLabelText)
        end
    end

    local lines = {
        {
            buildSegment(('%s: '):format(adminLabel), TITLE_RGB),
            buildSegment(adminRoleLabel ~= '' and ('[ %s ]'):format(adminRoleLabel) or '', adminRoleColor)
        },
        {
            buildSegment(('%s: '):format(cidLabel), TITLE_RGB),
            buildSegment(cid, VALUE_RGB),
            buildSegment(' | ', VALUE_RGB),
            buildSegment(('%s: '):format(idLabel), TITLE_RGB),
            buildSegment(idText, VALUE_RGB)
        },
        {
            buildSegment(('%s: '):format(nameLabel), TITLE_RGB),
            buildSegment(fullName, VALUE_RGB),
            buildSegment(' | ', VALUE_RGB),
            buildSegment(('%s: '):format(wallLabel), TITLE_RGB),
            buildSegment(wallState, wallStateColor)
        },
        {
            buildSegment(('%s: '):format(healthLabel), TITLE_RGB),
            buildSegment(healthText, VALUE_RGB)
        }
    }

    if weaponText and weaponText ~= '' then
        lines[#lines + 1] = {
            buildSegment(('%s:  '):format(weaponLabelText), TITLE_RGB),
            buildSegment(weaponText, VALUE_RGB)
        }
    end

    return lines
end

function BitinhoAdminWall.draw(x, y, z, lines, _)
    if type(lines) ~= 'table' then
        return
    end

    for index, line in ipairs(lines) do
        if type(line) == 'table' and #line > 0 then
            drawSegmentsLine(x, y, z, index, line)
        end
    end
end
