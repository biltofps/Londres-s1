local RSGCore = exports['rsg-core']:GetCoreObject()
local Config = type(Config) == 'table' and Config or {}
local PANEL_ACTION_DEFINITIONS_DEFAULT

local function trim(value)
    if type(value) ~= 'string' then
        return ''
    end

    return value:gsub('^%s+', ''):gsub('%s+$', '')
end

local function ensureString(value, fallback)
    local output = trim(value)
    if output == '' then
        return fallback
    end
    return output
end

local function ensureNumber(value, fallback, minValue, maxValue)
    local parsed = tonumber(value)
    if parsed == nil then
        parsed = fallback
    end

    if minValue ~= nil and parsed < minValue then
        parsed = minValue
    end
    if maxValue ~= nil and parsed > maxValue then
        parsed = maxValue
    end

    return parsed
end

local function ensureInteger(value, fallback, minValue, maxValue)
    return math.floor(ensureNumber(value, fallback, minValue, maxValue))
end

local function ensureBoolean(value, fallback)
    if type(value) == 'boolean' then
        return value
    end
    return fallback
end

local function ensureTable(value, fallback)
    if type(value) == 'table' then
        return value
    end
    return fallback
end

local function sanitizeText(value, maxLength, fallback)
    local output = trim(value)
    if output == '' then
        return fallback or ''
    end

    local limit = maxLength or 128
    if #output > limit then
        output = output:sub(1, limit)
    end

    return output
end

function sanitizeSqlIdentifier(value)
    local output = sanitizeText(value, 128, '')
    output = output:gsub('[^%w_%-]', '')
    return output
end

local function normalizeMoneyTypeEntries(rawMoneyTypes)
    local source = ensureTable(rawMoneyTypes, {})
    local normalized = {}
    local seen = {}

    for _, entry in ipairs(source) do
        if type(entry) == 'table' then
            local value = sanitizeText(entry.value, 32, '')
            if value == '' then
                value = sanitizeText(entry.key, 32, '')
            end
            value = value:lower():gsub('[^%w_]', '')
            if value == '' then
                goto continue
            end

            if not seen[value] then
                local label = sanitizeText(entry.label, 64, value)
                normalized[#normalized + 1] = {
                    value = value,
                    label = label
                }
                seen[value] = true
            end
        end

        ::continue::
    end

    return normalized
end

local function normalizePanelActionDefinitions(rawDefinitions)
    local source = ensureTable(rawDefinitions, {})
    local normalized = {}
    local seen = {}

    for _, entry in ipairs(source) do
        if type(entry) ~= 'table' then
            goto continue
        end

        local key = sanitizeText(entry.key, 64, '')
        if key == '' or seen[key] then
            goto continue
        end

        local requiredPermission = sanitizeText(entry.requiredPermission, 64, '')
        if requiredPermission == '' then
            requiredPermission = sanitizeText(entry.permission, 64, key)
        end
        if requiredPermission == '' then
            requiredPermission = 'manage_permissions'
        end

        local normalizedDefinition = {
            key = key,
            requiredPermission = requiredPermission,
            inCatalog = entry.inCatalog ~= false,
            requiresHandler = entry.requiresHandler ~= false
        }

        local localeKey = sanitizeText(entry.locale, 64, '')
        if localeKey ~= '' then
            normalizedDefinition.locale = localeKey
        end

        normalized[#normalized + 1] = normalizedDefinition
        seen[key] = true

        ::continue::
    end

    return normalized
end

local function normalizePermissionPresetEntries(rawPresets)
    local source = ensureTable(rawPresets, {})
    local normalized = {}
    local seen = {}

    for _, entry in ipairs(source) do
        if type(entry) ~= 'table' then
            goto continue
        end

        local key = sanitizeText(entry.key, 64, ''):lower():gsub('[^%w_]', '')
        if key == '' or seen[key] then
            goto continue
        end

        normalized[#normalized + 1] = {
            key = key,
            label = sanitizeText(entry.label, 96, key),
            permissions = ensureTable(entry.permissions, {})
        }
        seen[key] = true

        ::continue::
    end

    return normalized
end

local function normalizeRuntimeConfig(raw)
    local cfg = ensureTable(raw, {})
    local function section(name)
        local sectionValue = cfg[name]
        if type(sectionValue) ~= 'table' then
            sectionValue = {}
            cfg[name] = sectionValue
        end
        return sectionValue
    end

    -- Núcleo de comportamento do admin (valores principais).
    cfg.Command = ensureString(cfg.Command, 'admin')
    cfg.Noclip = ensureTable(cfg.Noclip, {})
    cfg.Noclip.command = sanitizeText(cfg.Noclip.command, 32, 'nc')

    -- Cargos da framework (rsgcore.<group>), na ordem do maior para o menor.
    local frameworkRoles = {}
    local seenFrameworkRoles = {}
    for _, entry in ipairs(ensureTable(cfg.FrameworkRoles, {})) do
        if type(entry) == 'table' then
            local group = sanitizeText(entry.group, 32, ''):lower():gsub('[^%w_]', '')
            if group ~= '' and not seenFrameworkRoles[group] then
                frameworkRoles[#frameworkRoles + 1] = {
                    group = group,
                    label = sanitizeText(entry.label, 64, group),
                    inherits = sanitizeText(entry.inherits, 32, ''):lower():gsub('[^%w_]', ''),
                    permissions = ensureTable(entry.permissions, {})
                }
                seenFrameworkRoles[group] = frameworkRoles[#frameworkRoles]
            end
        end
    end
    -- Herança no formato do server.cfg: { grupo, herda_de }.
    for _, link in ipairs(ensureTable(cfg.FrameworkHierarchy, {})) do
        if type(link) == 'table' then
            local child = seenFrameworkRoles[sanitizeText(link[1], 32, ''):lower()]
            local parent = sanitizeText(link[2], 32, ''):lower():gsub('[^%w_]', '')
            if type(child) == 'table' and parent ~= '' then
                child.inherits = parent
            end
        end
    end
    cfg.FrameworkRoles = frameworkRoles
    cfg.PrivateMessageDuration = ensureInteger(cfg.PrivateMessageDuration, 9000, 1000, 60000)
    cfg.Locale = ensureString(cfg.Locale, 'ptbr'):lower()
    cfg.Locales = ensureTable(cfg.Locales, {})

    -- UI.
    local ui = section('Ui')
    ui.title = ensureString(ui.title, 'Bitinho Admin')
    ui.refreshCooldownMs = ensureInteger(ui.refreshCooldownMs, 1500, 100, 10000)
    ui.modalDebug = ensureBoolean(ui.modalDebug, false)

    -- Notificações.
    local notifications = section('Notifications')
    notifications.defaultDuration = ensureInteger(notifications.defaultDuration, 4200, 500, 60000)
    notifications.adminDuration = ensureInteger(notifications.adminDuration, 5000, 500, 60000)
    notifications.targetDuration = ensureInteger(notifications.targetDuration, 5200, 500, 60000)

    -- Regras de job.
    local jobs = section('Jobs')
    jobs.removeJobTarget = ensureTable(jobs.removeJobTarget, {})
    jobs.removeJobTarget.name = ensureString(jobs.removeJobTarget.name, 'unemployed'):lower()
    jobs.removeJobTarget.grade = ensureInteger(jobs.removeJobTarget.grade, 0, 0, 50)

    -- Sistema de dinheiro.
    local money = section('Money')
    money.cashType = ensureString(money.cashType, 'cash'):lower()
    cfg.MoneyTypes = normalizeMoneyTypeEntries(cfg.MoneyTypes)
    if #cfg.MoneyTypes == 0 then
        cfg.MoneyTypes = normalizeMoneyTypeEntries(money.types)
    end
    money.types = {}
    for _, moneyType in ipairs(cfg.MoneyTypes) do
        money.types[#money.types + 1] = {
            key = moneyType.value,
            label = moneyType.label
        }
    end

    -- Ban.
    local ban = section('Ban')
    ban.defaultReason = ensureString(ban.defaultReason, 'Banido pela administracao.')
    ban.dayPresets = ensureTable(ban.dayPresets, {})
    ban.maxDays = ensureInteger(ban.maxDays, 3650, 1, 36500)
    ban.permanentExpire = ensureInteger(ban.permanentExpire, 2147483647, 1, 2147483647)

    -- Persistência de dados.
    local permissions = section('Permissions')
    permissions.tableName = ensureString(permissions.tableName, 'bilto_admin_permissions')
    permissions.presetsTableName = ensureString(permissions.presetsTableName, 'bilto_admin_role_permissions')
    permissions.presets = normalizePermissionPresetEntries(permissions.presets)

    -- Performance/limites.
    local performance = section('Performance')
    performance.globalMoneyCacheMs = ensureInteger(performance.globalMoneyCacheMs, 15000, 500, 600000)
    performance.blipPlayersCacheMs = ensureInteger(performance.blipPlayersCacheMs, 300, 100, 5000)

    local limits = section('Limits')
    limits.moneyActionMax = ensureInteger(limits.moneyActionMax, 100000000, 1, 2000000000)
    limits.addItemAmountMax = ensureInteger(limits.addItemAmountMax, 1000, 1, 2000000)
    limits.checkItemAmountMax = ensureInteger(limits.checkItemAmountMax, 1000, 1, 2000000)
    limits.addWeightAmountMax = ensureInteger(limits.addWeightAmountMax, 100000000, 1, 2000000000)
    limits.addSlotsAmountMax = ensureInteger(limits.addSlotsAmountMax, 1000, 1, 100000)

    -- Configuração de ações do painel.
    local panelActions = section('PanelActions')
    local configuredManage = ensureTable(panelActions.manage, {})
    local configuredDefinitions = normalizePanelActionDefinitions(panelActions.definitions)

    local normalizedManage = {
        permissionAddPlayer = configuredManage.permissionAddPlayer ~= false,
        permissionUpdatePlayer = configuredManage.permissionUpdatePlayer ~= false,
        permissionRemovePlayer = configuredManage.permissionRemovePlayer ~= false,
        permissionPresetUpdate = configuredManage.permissionPresetUpdate ~= false
    }
    panelActions.manage = normalizedManage

    local mergedDefinitions = {}
    local seenDefinitions = {}
    for _, definition in ipairs(configuredDefinitions) do
        if definition.key ~= '' and not seenDefinitions[definition.key] then
            mergedDefinitions[#mergedDefinitions + 1] = definition
            seenDefinitions[definition.key] = true
        end
    end

    for _, definition in ipairs(PANEL_ACTION_DEFINITIONS_DEFAULT) do
        if definition.key ~= '' and not seenDefinitions[definition.key] then
            mergedDefinitions[#mergedDefinitions + 1] = definition
            seenDefinitions[definition.key] = true
        end
    end

    panelActions.definitions = mergedDefinitions

    -- Segurança e fluxo.
    local security = section('Security')
    security.panelStateCacheMs = ensureInteger(security.panelStateCacheMs, 350, 100, 5000)
    security.wallWeaponStateMinIntervalMs = ensureInteger(security.wallWeaponStateMinIntervalMs, 90, 0, 2000)
    security.actionLockEnabled = ensureBoolean(security.actionLockEnabled, true)

    local observability = section('Observability')
    observability.enabled = ensureBoolean(observability.enabled, false)
    observability.logActions = ensureBoolean(observability.logActions, false)

    local webhook = section('Webhook')
    webhook.username = ensureString(webhook.username, 'Bilto Admin')
    webhook.avatarUrl = ensureString(webhook.avatarUrl, '')
    webhook.color = ensureInteger(webhook.color, 3447003, 0, 16777215)

    local webhooks = section('Webhooks')
    for actionName, url in pairs(webhooks) do
        webhooks[actionName] = ensureString(url, '')
    end

    -- Noclip.
    local noclip = section('Noclip')
    noclip.command = ensureString(noclip.command, 'nc')

    -- Developer.
    local developer = section('Developer')
    developer.adminHorses = ensureTable(developer.adminHorses, {})

    return cfg
end

local freezeState = {}
local noclipState = {}
local wallWeaponState = {}
cachedDatabaseName = cachedDatabaseName or nil
local DB_BAN_EXPIRE_MAX = 2147483647
local PANEL_MANAGE_ACTIONS = {}
local PANEL_ACTION_PERMISSIONS = {}
local PANEL_PERMISSION_DEFINITIONS = {}
local PANEL_PERMISSION_KEYS = {}
local PANEL_HANDLER_REQUIRED = {}
PANEL_ACTION_DEFINITIONS_DEFAULT = {
    { key = 'copyCoords', requiredPermission = 'copyCoords', inCatalog = true, locale = 'dashboard_get_coords', requiresHandler = false },
    { key = 'viewBannedPlayers', requiredPermission = 'viewBannedPlayers', inCatalog = true, locale = 'nav_banned_players', requiresHandler = false },
    { key = 'viewUtilitiesPanel', requiredPermission = 'viewUtilitiesPanel', inCatalog = true, locale = 'nav_utilities', requiresHandler = false },
    { key = 'goto', requiredPermission = 'goto', inCatalog = true },
    { key = 'bring', requiredPermission = 'bring', inCatalog = true },
    { key = 'revive', requiredPermission = 'revive', inCatalog = true },
    { key = 'heal', requiredPermission = 'heal', inCatalog = true },
    { key = 'executeLightning', requiredPermission = 'executeLightning', inCatalog = true },
    { key = 'toggleFreeze', requiredPermission = 'toggleFreeze', inCatalog = true },
    { key = 'spectate', requiredPermission = 'spectate', inCatalog = true },
    { key = 'openInventory', requiredPermission = 'openInventory', inCatalog = true },
    { key = 'setJob', requiredPermission = 'setJob', inCatalog = true },
    { key = 'upsertMultijobJob', requiredPermission = 'upsertMultijobJob', inCatalog = true },
    { key = 'removeJob', requiredPermission = 'removeJob', inCatalog = true },
    { key = 'addItem', requiredPermission = 'addItem', inCatalog = true },
    { key = 'addMoney', requiredPermission = 'addMoney', inCatalog = true },
    { key = 'removeMoney', requiredPermission = 'removeMoney', inCatalog = true },
    { key = 'addWeight', requiredPermission = 'addWeight', inCatalog = true },
    { key = 'addSlots', requiredPermission = 'addSlots', inCatalog = true },
    { key = 'removeWeight', requiredPermission = 'removeWeight', inCatalog = true },
    { key = 'removeSlots', requiredPermission = 'removeSlots', inCatalog = true },
    { key = 'renameCharacter', requiredPermission = 'renameCharacter', inCatalog = true },
    { key = 'changeHeight', requiredPermission = 'changeHeight', inCatalog = true },
    { key = 'clearInventory', requiredPermission = 'clearInventory', inCatalog = true },
    { key = 'privateMessage', requiredPermission = 'privateMessage', inCatalog = true },
    { key = 'kick', requiredPermission = 'kick', inCatalog = true },
    { key = 'banPlayer', requiredPermission = 'banPlayer', inCatalog = true },
    { key = 'editBan', requiredPermission = 'editBan', inCatalog = true },
    { key = 'removeBan', requiredPermission = 'removeBan', inCatalog = true },
    { key = 'checkItemCapacity', requiredPermission = 'checkItemCapacity', inCatalog = true },
    { key = 'togglePlayerBlips', requiredPermission = 'togglePlayerBlips', inCatalog = true },
    { key = 'togglePlayerWall', requiredPermission = 'togglePlayerWall', inCatalog = true },
    { key = 'toggleNoclip', requiredPermission = 'toggleNoclip', inCatalog = true },
    { key = 'spawnAdminHorse', requiredPermission = 'spawnAdminHorse', inCatalog = true },
    { key = 'openCompanyStash', requiredPermission = 'openCompanyStash', inCatalog = true },
    { key = 'teleportToCoords', requiredPermission = 'teleportToCoords', inCatalog = true, locale = 'nav_teleports', requiresHandler = false },
    { key = 'manageTeleportLocations', requiredPermission = 'manageTeleportLocations', inCatalog = true, requiresHandler = false },
}
local PANEL_ACTION_DEFAULT_LABEL_KEYS = {
    copyCoords = 'dashboard_get_coords',
    viewBannedPlayers = 'nav_banned_players',
    viewUtilitiesPanel = 'nav_utilities',
    manage_permissions = 'permissions_th_manage',
    ['goto'] = 'action_goto',
    bring = 'action_bring',
    revive = 'action_revive',
    heal = 'action_heal',
    executeLightning = 'action_execute_lightning',
    toggleFreeze = 'action_freeze_toggle',
    spectate = 'action_spectate',
    openInventory = 'action_open_inventory',
    setJob = 'action_set_job_menu',
    upsertMultijobJob = 'action_multijob_upsert',
    removeJob = 'action_remove_job',
    addItem = 'action_add_item_menu',
    addMoney = 'action_add_money_menu',
    removeMoney = 'action_remove_money_menu',
    addWeight = 'action_add_weight_menu',
    addSlots = 'action_add_slots_menu',
    removeWeight = 'action_remove_weight_menu',
    removeSlots = 'action_remove_slots_menu',
    renameCharacter = 'action_rename_player',
    changeHeight = 'action_change_height',
    clearInventory = 'action_clear_inventory',
    privateMessage = 'action_private_message',
    kick = 'action_kick_player',
    banPlayer = 'action_ban_player',
    editBan = 'banned_action_edit',
    removeBan = 'banned_action_remove',
    checkItemCapacity = 'action_check_item_capacity',
    togglePlayerBlips = 'developer_toggle_blips',
    togglePlayerWall = 'developer_toggle_wall',
    toggleNoclip = 'developer_toggle_noclip',
    spawnAdminHorse = 'dashboard_spawn_horse',
    openCompanyStash = 'action_open_company_stash',
    teleportToCoords = 'nav_teleports',
    manageTeleportLocations = 'action_manage_teleports',
}
Config = normalizeRuntimeConfig(Config)

local panelPermissionStore = {
    loaded = false,
    storageReady = false,
    tableName = nil,
    byCitizenid = {},
    entries = {}
}
local panelPermissionPresetStore = {
    loaded = false,
    storageReady = false,
    tableName = nil,
    byKey = {},
    entries = {}
}
local panelStaticCatalogCache = nil
local globalMoneyCache = {
    expiresAt = 0,
    data = nil
}
local panelStateCacheBySource = {}
local BLIP_PLAYERS_CACHE_TTL_MS = math.max(100, math.floor(tonumber(Config.Performance and Config.Performance.blipPlayersCacheMs) or 300))
local blipPlayersCache = {
    expiresAt = 0,
    entries = nil
}
local wallWeaponStateUpdateAt = {}
local actionInFlightBySource = {}
local PANEL_STATE_CACHE_TTL_MS = math.max(100, math.floor(tonumber(Config.Security and Config.Security.panelStateCacheMs) or 350))
local WALL_WEAPON_STATE_MIN_INTERVAL_MS = math.max(0, math.floor(tonumber(Config.Security and Config.Security.wallWeaponStateMinIntervalMs) or 90))
local ACTION_LOCK_ENABLED = not (Config.Security and Config.Security.actionLockEnabled == false)
local spectateTargetByAdmin = {}
local getPlayerNameSafe
local fetchStoredMultijobEntries
BitinhoAdmin = BitinhoAdmin or {}

local function buildPanelActionRuntimeConfig()
    local manageActions = ensureTable(Config.PanelActions and Config.PanelActions.manage, {})
    local definitions = ensureTable(Config.PanelActions and Config.PanelActions.definitions, {})

    PANEL_MANAGE_ACTIONS = {}
    PANEL_ACTION_PERMISSIONS = {}
    PANEL_PERMISSION_DEFINITIONS = {}
    PANEL_PERMISSION_KEYS = {}
    PANEL_HANDLER_REQUIRED = {}
    BitinhoAdmin.frameworkRolePermissionCache = nil

    for _, definition in ipairs(definitions) do
        if type(definition) ~= 'table' then
            goto continue
        end

        local key = sanitizeText(definition.key, 64, '')
        if key == '' then
            goto continue
        end

        local requiredPermission = sanitizeText(definition.requiredPermission, 64, '')
        if requiredPermission == '' then
            requiredPermission = sanitizeText(definition.permission, 64, key)
        end
        if requiredPermission == '' then
            requiredPermission = 'manage_permissions'
        end

        PANEL_PERMISSION_DEFINITIONS[#PANEL_PERMISSION_DEFINITIONS + 1] = {
            key = key,
            localeKey = sanitizeText(definition.locale, 64, ''),
            inCatalog = definition.inCatalog ~= false,
            requiredPermission = requiredPermission,
            requiresHandler = definition.requiresHandler ~= false
        }
        PANEL_ACTION_PERMISSIONS[key] = requiredPermission
        PANEL_HANDLER_REQUIRED[key] = definition.requiresHandler ~= false
        if definition.inCatalog ~= false then
            PANEL_PERMISSION_KEYS[#PANEL_PERMISSION_KEYS + 1] = key
        end

        ::continue::
    end

    for actionName, enabled in pairs(manageActions) do
        local normalizedAction = sanitizeText(actionName, 64, '')
        if normalizedAction ~= '' and enabled == true then
            PANEL_MANAGE_ACTIONS[normalizedAction] = true
            if PANEL_ACTION_PERMISSIONS[normalizedAction] == nil then
                PANEL_ACTION_PERMISSIONS[normalizedAction] = 'manage_permissions'
            end
        end
    end
end

buildPanelActionRuntimeConfig()

local function toSourceNumber(source)
    local parsed = tonumber(source)
    if not parsed or parsed <= 0 then
        return nil
    end

    return parsed
end

local function round(value, decimals)
    if type(value) ~= 'number' then
        return 0
    end

    local precision = 10 ^ (decimals or 0)
    return math.floor((value * precision) + 0.5) / precision
end

local function getNowMs()
    if type(GetGameTimer) == 'function' then
        local timer = tonumber(GetGameTimer())
        if timer then
            return timer
        end
    end

    return math.floor(os.clock() * 1000)
end

local function normalizeLicense(rawValue)
    local value = sanitizeText(rawValue, 128, '')
    if value == '' then
        return ''
    end

    local lower = value:lower()
    if lower:sub(1, 8) == 'license:' then
        return value:sub(9)
    end
    if lower:sub(1, 9) == 'license2:' then
        return value:sub(10)
    end

    return value
end

local function getSafePermanentExpire()
    local configured = math.floor(tonumber(Config.Ban and Config.Ban.permanentExpire) or DB_BAN_EXPIRE_MAX)
    if configured <= 0 then
        configured = DB_BAN_EXPIRE_MAX
    end
    if configured > DB_BAN_EXPIRE_MAX then
        configured = DB_BAN_EXPIRE_MAX
    end
    return configured
end

local function formatBanDayPresetList()
    local presets = buildBanDayPresetCatalog()
    if #presets == 0 then
        return ''
    end

    local listValues = {}
    for _, days in ipairs(presets) do
        listValues[#listValues + 1] = tostring(days)
    end

    return table.concat(listValues, ', ')
end

local function interpolateText(template, params)
    if type(template) ~= 'string' then
        return ''
    end

    local output = template
    if type(params) == 'table' then
        for key, value in pairs(params) do
            output = output:gsub(('{%s}'):format(tostring(key)), tostring(value))
        end
    end

    return output
end

local function getLocaleBundles()
    local localeKey = sanitizeText(Config.Locale, 12, 'ptbr'):lower()
    local locales = type(Config.Locales) == 'table' and Config.Locales or {}
    local fallback = type(locales.ptbr) == 'table' and locales.ptbr or {}
    local active = type(locales[localeKey]) == 'table' and locales[localeKey] or fallback
    return localeKey, active, fallback
end

local function getLocalizedText(group, key, fallbackText)
    local _, active, fallback = getLocaleBundles()
    local activeGroup = type(active[group]) == 'table' and active[group] or type(active.texts) == 'table' and active.texts or active
    local fallbackGroup = type(fallback[group]) == 'table' and fallback[group] or type(fallback.texts) == 'table' and fallback.texts or fallback
    local value = activeGroup[key]
    if type(value) ~= 'string' then
        value = fallbackGroup[key]
    end
    if type(value) ~= 'string' then
        value = fallbackText or key
    end
    return value
end

local function S(key, params, fallbackText)
    return interpolateText(getLocalizedText('server', key, fallbackText), params)
end

local function isObservabilityEnabled()
    return Config.Observability and Config.Observability.enabled == true
end

local function shouldLogActions()
    return isObservabilityEnabled() and Config.Observability.logActions == true
end

local function normalizeVersionString(value)
    local normalized = sanitizeText(value, 64, ''):lower()
    normalized = normalized:gsub('^v', '')
    normalized = normalized:gsub('[^%d%.%-_]', '')
    return normalized
end

local function splitVersionParts(version)
    local parts = {}
    local normalized = normalizeVersionString(version)
    for token in normalized:gmatch('[^%.]+') do
        local numberPart = tonumber(token:match('^(%d+)')) or 0
        parts[#parts + 1] = numberPart
    end
    return parts
end

local function compareVersions(left, right)
    local leftParts = splitVersionParts(left)
    local rightParts = splitVersionParts(right)
    local total = math.max(#leftParts, #rightParts)

    for index = 1, total do
        local leftValue = leftParts[index] or 0
        local rightValue = rightParts[index] or 0
        if leftValue < rightValue then
            return -1
        end
        if leftValue > rightValue then
            return 1
        end
    end

    return 0
end

local function getVersionCheckerConfig()
    local checker = ensureTable(type(VersionConfig) == 'table' and VersionConfig or Config.VersionChecker, {})
    checker.enabled = ensureBoolean(checker.enabled, false)
    checker.latestVersion = normalizeVersionString(checker.latestVersion)
    checker.url = sanitizeText(checker.url, 512, '')
    checker.downloadUrl = sanitizeText(checker.downloadUrl, 512, '')
    return checker
end

local function getCurrentResourceVersion()
    return normalizeVersionString(GetResourceMetadata(GetCurrentResourceName(), 'version', 0))
end

local function printVersionStatus(latestVersion)
    return latestVersion
end

local function runVersionCheck()
    local checker = getVersionCheckerConfig()
    if checker.enabled ~= true then
        return
    end

    if checker.latestVersion ~= '' then
        printVersionStatus(checker.latestVersion)
        return
    end

    if checker.url == '' then
        return
    end

    PerformHttpRequest(checker.url, function(statusCode, body)
        if statusCode ~= 200 or type(body) ~= 'string' then
            return
        end

        local latestVersion = trim(body:match('([%w%._%-]+)') or '')
        printVersionStatus(latestVersion)
    end, 'GET')
end

local function invalidatePanelStaticCatalogCache()
    panelStaticCatalogCache = nil
end

local function clearGlobalMoneyCache()
    globalMoneyCache.expiresAt = 0
    globalMoneyCache.data = nil
end

local function invalidateBlipPlayersCache()
    blipPlayersCache.expiresAt = 0
    blipPlayersCache.entries = nil
end

local function invalidatePanelStateCache(source)
    local sourceId = toSourceNumber(source)
    if sourceId then
        panelStateCacheBySource[sourceId] = nil
        return
    end

    panelStateCacheBySource = {}
end

local function isActionInFlight(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return false
    end
    return actionInFlightBySource[sourceId] == true
end

local function setActionInFlight(source, inFlight)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return
    end

    if inFlight then
        actionInFlightBySource[sourceId] = true
        return
    end

    actionInFlightBySource[sourceId] = nil
end

local function toBoolean(value)
    return value == true or value == 1 or value == '1' or value == 'true'
end

local function normalizeCitizenId(value)
    return sanitizeText(value, 64, ''):lower()
end

local function getPanelPermissionTableName()
    local rawName = sanitizeText(Config.Permissions and Config.Permissions.tableName, 64, 'bilto_admin_permissions')
    local normalized = rawName:gsub('[^%w_]', '')
    if normalized == '' then
        normalized = 'bilto_admin_permissions'
    end
    return normalized
end

local function getPanelPermissionPresetTableName()
    local rawName = sanitizeText(Config.Permissions and Config.Permissions.presetsTableName, 64, 'bilto_admin_role_permissions')
    local normalized = rawName:gsub('[^%w_]', '')
    if normalized == '' then
        normalized = 'bilto_admin_role_permissions'
    end
    return normalized
end

local function getConfiguredPermissionPresets()
    return type(Config.Permissions and Config.Permissions.presets) == 'table'
        and Config.Permissions.presets
        or {}
end

local function buildEmptyPanelPermissionSet()
    local permissions = {
        all_permissions = false
    }
    for _, key in ipairs(PANEL_PERMISSION_KEYS) do
        permissions[key] = false
    end
    return permissions
end

local function normalizePanelPermissionSet(rawPermissions)
    local normalized = buildEmptyPanelPermissionSet()
    if type(rawPermissions) ~= 'table' then
        return normalized
    end

    normalized.all_permissions = toBoolean(rawPermissions.all_permissions)
    for _, key in ipairs(PANEL_PERMISSION_KEYS) do
        normalized[key] = toBoolean(rawPermissions[key])
    end

    if normalized.all_permissions then
        for _, key in ipairs(PANEL_PERMISSION_KEYS) do
            normalized[key] = true
        end
    end

    return normalized
end

local function encodePanelPermissionSet(permissionSet)
    local encoded = json.encode(normalizePanelPermissionSet(permissionSet))
    if type(encoded) ~= 'string' or encoded == '' then
        return '{}'
    end
    return encoded
end

local function decodePanelPermissionSet(rawPermissions)
    if type(rawPermissions) == 'table' then
        return normalizePanelPermissionSet(rawPermissions)
    end

    if type(rawPermissions) == 'string' and rawPermissions ~= '' then
        return normalizePanelPermissionSet(json.decode(rawPermissions))
    end

    return buildEmptyPanelPermissionSet()
end

local function ensurePanelPermissionStorage()
    if panelPermissionStore.storageReady then
        return true, nil
    end

    if type(MySQL) ~= 'table' then
        return false, S('permission_mysql_unavailable', nil, 'OxMySQL indisponivel para permissoes do painel.')
    end

    panelPermissionStore.tableName = getPanelPermissionTableName()
    local createQuery = ([[CREATE TABLE IF NOT EXISTS `%s` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `citzenid` VARCHAR(64) NOT NULL,
        `name` VARCHAR(96) NOT NULL DEFAULT '',
        `granted_by` VARCHAR(96) NOT NULL DEFAULT '',
        `preset_key` VARCHAR(64) NOT NULL DEFAULT '',
        `permissions` LONGTEXT NOT NULL,
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        UNIQUE KEY `uniq_citzenid` (`citzenid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;]]):format(panelPermissionStore.tableName)
    MySQL.query.await(createQuery)

    local citzenidColumnRows = MySQL.query.await(
        'SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
        { panelPermissionStore.tableName, 'citzenid' }
    ) or {}
    if #citzenidColumnRows == 0 then
        MySQL.query.await(('ALTER TABLE `%s` ADD COLUMN `citzenid` VARCHAR(64) NOT NULL DEFAULT \'\' AFTER `id`'):format(panelPermissionStore.tableName))
    end

    local legacyLicenseRows = MySQL.query.await(
        'SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
        { panelPermissionStore.tableName, 'license' }
    ) or {}
    if #legacyLicenseRows > 0 then
        MySQL.query.await(([[
            UPDATE `%s` permissions
            INNER JOIN `players` players
                ON LOWER(players.license) COLLATE utf8mb4_unicode_ci
                = LOWER(permissions.license) COLLATE utf8mb4_unicode_ci
            SET permissions.citzenid = LOWER(players.citizenid)
            WHERE (permissions.citzenid IS NULL OR permissions.citzenid = '')
              AND players.citizenid IS NOT NULL
              AND players.citizenid <> ''
        ]]):format(panelPermissionStore.tableName))
    end

    local presetColumnRows = MySQL.query.await(
        'SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
        { panelPermissionStore.tableName, 'preset_key' }
    ) or {}
    if #presetColumnRows == 0 then
        MySQL.query.await(('ALTER TABLE `%s` ADD COLUMN `preset_key` VARCHAR(64) NOT NULL DEFAULT \'\' AFTER `granted_by`'):format(panelPermissionStore.tableName))
    end

    panelPermissionStore.storageReady = true
    return true, nil
end

local function reloadPanelPermissionStore()
    local storageReady, storageErr = ensurePanelPermissionStorage()
    if not storageReady then
        return false, storageErr
    end

    local byCitizenid = {}
    local entries = {}
    local rows = MySQL.query.await(('SELECT citzenid, name, granted_by, preset_key, permissions, created_at, updated_at FROM `%s` ORDER BY id DESC'):format(panelPermissionStore.tableName)) or {}
    for _, row in ipairs(rows) do
        local normalizedCitizenid = normalizeCitizenId(row and row.citzenid)
        if normalizedCitizenid ~= '' and not byCitizenid[normalizedCitizenid] then
            local normalizedPermissions = decodePanelPermissionSet(row and row.permissions)
            local entry = {
                citzenid = normalizedCitizenid,
                name = sanitizeText(row and row.name, 96, 'N/A'),
                grantedBy = sanitizeText(row and row.granted_by, 96, '-'),
                presetKey = sanitizeText(row and row.preset_key, 64, ''):lower():gsub('[^%w_]', ''),
                permissions = normalizedPermissions,
                createdAt = sanitizeText(tostring(row and row.created_at or ''), 64, ''),
                updatedAt = sanitizeText(tostring(row and row.updated_at or ''), 64, '')
            }
            byCitizenid[normalizedCitizenid] = entry
            entries[#entries + 1] = entry
        end
    end

    table.sort(entries, function(a, b)
        local left = sanitizeText(a and a.name, 96, '')
        local right = sanitizeText(b and b.name, 96, '')
        if left == right then
            return sanitizeText(a and a.citzenid, 64, '') < sanitizeText(b and b.citzenid, 64, '')
        end
        return left < right
    end)

    panelPermissionStore.byCitizenid = byCitizenid
    panelPermissionStore.entries = entries
    panelPermissionStore.loaded = true
    return true, nil
end

local function ensurePanelPermissionPresetStorage()
    if panelPermissionPresetStore.storageReady then
        return true, nil
    end

    if type(MySQL) ~= 'table' then
        return false, S('permission_mysql_unavailable', nil, 'OxMySQL indisponivel para permissoes do painel.')
    end

    panelPermissionPresetStore.tableName = getPanelPermissionPresetTableName()
    local createQuery = ([[CREATE TABLE IF NOT EXISTS `%s` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `preset_key` VARCHAR(64) NOT NULL,
        `label` VARCHAR(96) NOT NULL DEFAULT '',
        `permissions` LONGTEXT NOT NULL,
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        UNIQUE KEY `uniq_preset_key` (`preset_key`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;]]):format(panelPermissionPresetStore.tableName)
    MySQL.query.await(createQuery)
    panelPermissionPresetStore.storageReady = true
    return true, nil
end

-- The panel roles are the framework groups; config.lua only gives their first value.
-- After that the database wins, so changes made in the panel survive restarts.
local function seedPanelPermissionPresets()
    for _, role in ipairs(Config.FrameworkRoles or {}) do
        if BitinhoAdmin.IsEditableFrameworkGroup(role.group) then
            MySQL.update.await(
                ('INSERT IGNORE INTO `%s` (preset_key, label, permissions) VALUES (?, ?, ?)'):format(panelPermissionPresetStore.tableName),
                {
                    role.group,
                    role.label,
                    encodePanelPermissionSet(BitinhoAdmin.GetConfigRolePermissions(role.group))
                }
            )
        end
    end
end

local function reloadPanelPermissionPresetStore()
    local storageReady, storageErr = ensurePanelPermissionPresetStorage()
    if not storageReady then
        return false, storageErr
    end

    seedPanelPermissionPresets()

    local byKey = {}
    local entries = {}
    local rows = MySQL.query.await(('SELECT preset_key, label, permissions, created_at, updated_at FROM `%s` ORDER BY id ASC'):format(panelPermissionPresetStore.tableName)) or {}
    for _, row in ipairs(rows) do
        local key = sanitizeText(row and row.preset_key, 64, ''):lower():gsub('[^%w_]', '')
        -- old custom roles stay in the table but are no longer offered
        local role = BitinhoAdmin.IsEditableFrameworkGroup(key) and BitinhoAdmin.GetFrameworkRoleByGroup(key) or nil
        if role and not byKey[key] then
            local entry = {
                key = key,
                label = role.label,
                permissions = decodePanelPermissionSet(row and row.permissions),
                createdAt = sanitizeText(tostring(row and row.created_at or ''), 64, ''),
                updatedAt = sanitizeText(tostring(row and row.updated_at or ''), 64, '')
            }
            byKey[key] = entry
            entries[#entries + 1] = entry
        end
    end

    local roleOrder = {}
    for index, role in ipairs(Config.FrameworkRoles or {}) do
        roleOrder[role.group] = index
    end
    table.sort(entries, function(a, b)
        return (roleOrder[a.key] or 0) < (roleOrder[b.key] or 0)
    end)

    panelPermissionPresetStore.byKey = byKey
    panelPermissionPresetStore.entries = entries
    panelPermissionPresetStore.loaded = true
    return true, nil
end

local function ensurePanelPermissionPresetStoreLoaded()
    if panelPermissionPresetStore.loaded then
        return true, nil
    end
    return reloadPanelPermissionPresetStore()
end

local function getPanelPermissionPresetByKey(presetKeyRaw)
    local presetKey = sanitizeText(presetKeyRaw, 64, ''):lower():gsub('[^%w_]', '')
    if presetKey == '' then
        return nil
    end

    local loaded = ensurePanelPermissionPresetStoreLoaded()
    if not loaded then
        return nil
    end

    return panelPermissionPresetStore.byKey[presetKey]
end

local function ensurePanelPermissionStoreLoaded()
    if panelPermissionStore.loaded then
        return true, nil
    end
    return reloadPanelPermissionStore()
end

local function getPanelPermissionEntryByCitizenid(citizenidRaw)
    local normalizedCitizenid = normalizeCitizenId(citizenidRaw)
    if normalizedCitizenid == '' then
        return nil
    end

    local loaded = ensurePanelPermissionStoreLoaded()
    if not loaded then
        return nil
    end

    return panelPermissionStore.byCitizenid[normalizedCitizenid]
end

local function resolvePanelPermissionSetForEntry(entry)
    if type(entry) ~= 'table' then
        return buildEmptyPanelPermissionSet()
    end

    local preset = getPanelPermissionPresetByKey(entry.presetKey)
    if preset and type(preset.permissions) == 'table' then
        return normalizePanelPermissionSet(preset.permissions)
    end

    return normalizePanelPermissionSet(entry.permissions)
end

local function buildPanelPermissionPresetCatalog()
    ensurePanelPermissionPresetStoreLoaded()

    local catalog = {}
    for _, entry in ipairs(panelPermissionPresetStore.entries or {}) do
        local permissions = normalizePanelPermissionSet(entry.permissions)
        catalog[#catalog + 1] = {
            key = entry.key,
            label = entry.label,
            permissions = permissions
        }
    end

    return catalog
end

local function getSourceNormalizedCitizenid(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return ''
    end
    local player = RSGCore.Functions.GetPlayer(sourceId)
    local playerData = player and player.PlayerData or {}
    return normalizeCitizenId(playerData and playerData.citizenid)
end

-- kept on BitinhoAdmin (not chunk-level locals) because the main chunk is at Lua's 200-local limit
function BitinhoAdmin.GetFrameworkRole(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return nil
    end

    -- A role comes from server.cfg (ace) or from the panel (cargo saved for the citizenid).
    local entry = getPanelPermissionEntryByCitizenid(getSourceNormalizedCitizenid(sourceId))
    local panelGroup = entry and entry.presetKey or ''
    for _, role in ipairs(Config.FrameworkRoles or {}) do
        if role.group == panelGroup or RSGCore.Functions.HasPermission(sourceId, role.group) then
            return role
        end
    end

    return nil
end

function BitinhoAdmin.GetFrameworkRoleByGroup(group)
    for _, role in ipairs(Config.FrameworkRoles or {}) do
        if role.group == group then
            return role
        end
    end
    return nil
end

-- The top role (all_permissions in config) is fixed; every other role is edited in the panel.
function BitinhoAdmin.IsEditableFrameworkGroup(group)
    local role = BitinhoAdmin.GetFrameworkRoleByGroup(group)
    return role ~= nil and toBoolean(role.permissions.all_permissions) ~= true
end

function BitinhoAdmin.GetFrameworkRolePermissions(group)
    if BitinhoAdmin.IsEditableFrameworkGroup(group) then
        local preset = getPanelPermissionPresetByKey(group)
        if preset and type(preset.permissions) == 'table' then
            return normalizePanelPermissionSet(preset.permissions)
        end
    end
    return BitinhoAdmin.GetConfigRolePermissions(group)
end

-- Permissions from config.lua with the hierarchy applied; used as the starting value saved in the database.
function BitinhoAdmin.GetConfigRolePermissions(group)
    BitinhoAdmin.frameworkRolePermissionCache = BitinhoAdmin.frameworkRolePermissionCache or {}
    local cache = BitinhoAdmin.frameworkRolePermissionCache
    if cache[group] then
        return cache[group]
    end

    local rolesByGroup = {}
    for _, role in ipairs(Config.FrameworkRoles or {}) do
        rolesByGroup[role.group] = role
    end

    local merged = {}
    local visited = {}
    local current = rolesByGroup[group]
    while current and not visited[current.group] do
        visited[current.group] = true
        for key, value in pairs(current.permissions) do
            if toBoolean(value) then
                merged[key] = true
            end
        end
        current = current.inherits ~= '' and rolesByGroup[current.inherits] or nil
    end

    cache[group] = normalizePanelPermissionSet(merged)
    return cache[group]
end

-- Gives the framework group (rsgcore.<group>) of the role saved in the panel. rsg-core only
-- applies it until restart, so it is reapplied on login and taken back when the player leaves.
function BitinhoAdmin.SyncPanelRoleAce(sourceId)
    BitinhoAdmin.appliedPanelRoles = BitinhoAdmin.appliedPanelRoles or {}
    local applied = BitinhoAdmin.appliedPanelRoles[sourceId]
    local entry = getPanelPermissionEntryByCitizenid(getSourceNormalizedCitizenid(sourceId))
    local wanted = entry and BitinhoAdmin.IsEditableFrameworkGroup(entry.presetKey) and entry.presetKey or nil
    if applied == wanted then
        return
    end
    if applied then
        RSGCore.Functions.RemovePermission(sourceId, applied)
    end
    if wanted then
        RSGCore.Functions.AddPermission(sourceId, wanted)
    end
    BitinhoAdmin.appliedPanelRoles[sourceId] = wanted
end

function BitinhoAdmin.ClearPanelRoleAce(sourceId)
    local applied = BitinhoAdmin.appliedPanelRoles and BitinhoAdmin.appliedPanelRoles[sourceId]
    if applied then
        RSGCore.Functions.RemovePermission(sourceId, applied)
        BitinhoAdmin.appliedPanelRoles[sourceId] = nil
    end
end

function BitinhoAdmin.SyncAllPanelRoleAces()
    for _, playerSource in ipairs(RSGCore.Functions.GetPlayers()) do
        local sourceId = toSourceNumber(playerSource)
        if sourceId then
            BitinhoAdmin.SyncPanelRoleAce(sourceId)
        end
    end
end

function BitinhoAdmin.GetSourceFrameworkPermissions(source)
    local role = BitinhoAdmin.GetFrameworkRole(source)
    if not role then
        return nil, nil
    end
    return BitinhoAdmin.GetFrameworkRolePermissions(role.group), role
end

local function hasFrameworkPanelPermission(source)
    return BitinhoAdmin.GetFrameworkRole(source) ~= nil
end

local function isGodPermission(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return false
    end

    return RSGCore.Functions.HasPermission(sourceId, 'god')
end

local function getPanelCustomEntryBySource(source)
    local sourceCitizenid = getSourceNormalizedCitizenid(source)
    if sourceCitizenid == '' then
        return nil, ''
    end

    return getPanelPermissionEntryByCitizenid(sourceCitizenid), sourceCitizenid
end

local function hasPanelPermission(source)
    if hasFrameworkPanelPermission(source) then
        return true
    end

    local customEntry = getPanelCustomEntryBySource(source)
    return customEntry ~= nil
end

-- Only GOD edits the roles and decides who gets each one.
local function canManagePanelPermissions(source)
    return isGodPermission(source)
end

local function hasPanelActionPermission(source, actionName)
    if type(actionName) ~= 'string' or actionName == '' then
        return false
    end

    if PANEL_MANAGE_ACTIONS[actionName] then
        return canManagePanelPermissions(source)
    end

    local rolePermissions = BitinhoAdmin.GetSourceFrameworkPermissions(source)
    if rolePermissions and rolePermissions.all_permissions == true then
        return true
    end

    local requiredPermission = PANEL_ACTION_PERMISSIONS[actionName]
    if type(requiredPermission) ~= 'string' or requiredPermission == '' then
        return false
    end

    if rolePermissions and rolePermissions[requiredPermission] == true then
        return true
    end

    local customEntry = getPanelCustomEntryBySource(source)
    if not customEntry then
        return false
    end

    local permissions = resolvePanelPermissionSetForEntry(customEntry)
    return permissions.all_permissions == true or permissions[requiredPermission] == true
end

local function buildPanelPermissionCatalog()
    local catalog = {}
    for _, definition in ipairs(PANEL_PERMISSION_DEFINITIONS) do
        if definition.inCatalog == false then
            goto continue
        end

        local translationKey = sanitizeText(definition.localeKey, 64, '')
        if translationKey == '' then
            translationKey = sanitizeText(PANEL_ACTION_DEFAULT_LABEL_KEYS[definition.key], 64, '')
        end

        local fallbackLabel = sanitizeText(definition.key, 96, 'acao')
        local translatedLabel = translationKey == '' and fallbackLabel or S(translationKey, nil, fallbackLabel)
        catalog[#catalog + 1] = {
            key = definition.key,
            label = sanitizeText(translatedLabel, 96, fallbackLabel)
        }

        ::continue::
    end
    return catalog
end

function BitinhoAdmin.GetNotificationTitle(notifyType)
    local normalizedType = tostring(notifyType or 'info'):lower()
    if normalizedType == 'ok' or normalizedType == 'success' then
        return S('notification_success_title', nil, 'Sucesso')
    end
    if normalizedType == 'error' then
        return S('notification_denied_title', nil, 'Negado')
    end
    if normalizedType == 'warn' or normalizedType == 'warning' then
        return S('notification_warning_title', nil, 'Aviso')
    end
    return S('notification_info_title', nil, 'Informação')
end

local function notify(source, description, notifyType)
    TriggerClientEvent('bilto_admin:client:showToast', source, {
        title = BitinhoAdmin.GetNotificationTitle(notifyType),
        description = description,
        type = notifyType or 'info',
        duration = Config.Notifications.adminDuration
    })
end

getPlayerNameSafe = function(source)
    local sourceId = tonumber(source) or source
    return GetPlayerName(sourceId) or ('ID %s'):format(sourceId)
end

local function getCharacterFullName(playerData, fallback)
    local charinfo = type(playerData and playerData.charinfo) == 'table' and playerData.charinfo or {}
    local first = sanitizeText(charinfo.firstname or charinfo.firstName, 48, '')
    local last = sanitizeText(charinfo.lastname or charinfo.lastName, 48, '')
    local fullCharName = (first .. ' ' .. last):gsub('^%s+', ''):gsub('%s+$', '')
    if fullCharName ~= '' then
        return fullCharName
    end

    local fallbackName = sanitizeText(playerData and playerData.name, 96, '')
    if fallbackName ~= '' and not fallbackName:find('steam:', 1, true) then
        return fallbackName
    end

    local sanitizedFallback = sanitizeText(fallback, 96, '')
    if sanitizedFallback ~= '' then
        return sanitizedFallback
    end

    local sourceId = toSourceNumber(playerData and playerData.source)
    if sourceId then
        return ('ID %s'):format(sourceId)
    end

    return 'N/A'
end

local function getCharacterNameSafe(source, fallback)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        local sanitizedFallback = sanitizeText(fallback, 96, '')
        return sanitizedFallback ~= '' and sanitizedFallback or 'N/A'
    end

    local player = RSGCore and RSGCore.Functions and RSGCore.Functions.GetPlayer(sourceId) or nil
    if player and player.PlayerData then
        return getCharacterFullName(player.PlayerData, fallback or ('ID %s'):format(sourceId))
    end

    local sanitizedFallback = sanitizeText(fallback, 96, '')
    if sanitizedFallback ~= '' then
        return sanitizedFallback
    end

    return ('ID %s'):format(sourceId)
end

local function notifyTargetAction(targetSource, adminSource, description, notifyType)
    local parsedTarget = toSourceNumber(targetSource)
    if not parsedTarget then
        return
    end

    TriggerClientEvent('bilto_admin:client:showToast', parsedTarget, {
        title = BitinhoAdmin.GetNotificationTitle(notifyType),
        description = description or '',
        type = notifyType or 'info',
        duration = Config.Notifications.targetDuration
    })
end

local function getPlayerObject(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return nil
    end

    local player = RSGCore.Functions.GetPlayer(sourceId)
    if not player or not player.PlayerData then
        return nil
    end

    return player
end

local function getFullName(playerData)
    return getCharacterFullName(playerData, 'N/A')
end

function getOnlinePlayerByCitizenid(citizenidRaw)
    local citizenid = sanitizeText(citizenidRaw, 64, '')
    if citizenid == '' then
        return nil, nil
    end

    local normalizedCitizenid = citizenid:lower()
    local sources = RSGCore.Functions.GetPlayers()
    for _, source in ipairs(sources) do
        local sourceId = toSourceNumber(source)
        local player = sourceId and getPlayerObject(sourceId) or nil
        local playerData = player and player.PlayerData or {}
        local playerCitizenid = sanitizeText(playerData and playerData.citizenid, 64, '')
        if playerCitizenid ~= '' and playerCitizenid:lower() == normalizedCitizenid then
            return sourceId, player
        end
    end

    return nil, nil
end

function getCurrentDatabaseName()
    if cachedDatabaseName and cachedDatabaseName ~= '' then
        return cachedDatabaseName
    end

    local row = MySQL.single.await('SELECT DATABASE() AS dbname')
    local dbname = sanitizeText(row and row.dbname, 128, '')
    if dbname ~= '' then
        cachedDatabaseName = dbname
    end

    return dbname
end

function decodeJsonTable(rawValue)
    if type(rawValue) == 'table' then
        return rawValue
    end
    if type(rawValue) ~= 'string' or rawValue == '' then
        return nil
    end

    local ok, decoded = pcall(json.decode, rawValue)
    if ok and type(decoded) == 'table' then
        return decoded
    end

    return nil
end

function getCharacterDeleteTargets(citizenidRaw)
    local citizenid = sanitizeText(citizenidRaw, 64, '')
    if citizenid == '' or type(MySQL) ~= 'table' then
        return {}, 0
    end

    local databaseName = getCurrentDatabaseName()
    if databaseName == '' then
        return {}, 0
    end

    local rows = MySQL.query.await([[
        SELECT TABLE_NAME AS tableName, COLUMN_NAME AS columnName
        FROM information_schema.columns
        WHERE table_schema = ?
          AND (
            LOWER(column_name) LIKE '%citizenid%'
            OR LOWER(column_name) LIKE '%citzenid%'
          )
        ORDER BY TABLE_NAME ASC, ORDINAL_POSITION ASC
    ]], { databaseName }) or {}

    local grouped = {}
    for _, row in ipairs(rows) do
        local tableName = sanitizeSqlIdentifier(row and row.tableName)
        local columnName = sanitizeSqlIdentifier(row and row.columnName)
        if tableName ~= '' and columnName ~= '' then
            grouped[tableName] = grouped[tableName] or {
                tableName = tableName,
                columns = {}
            }
            grouped[tableName].columns[#grouped[tableName].columns + 1] = columnName
        end
    end

    local matchedTables = {}
    local totalRows = 0

    for _, entry in pairs(grouped) do
        if #entry.columns > 0 then
            local whereClauses = {}
            local params = {}
            for _, columnName in ipairs(entry.columns) do
                whereClauses[#whereClauses + 1] = ('`%s` = ?'):format(columnName)
                params[#params + 1] = citizenid
            end

            local countSql = ('SELECT COUNT(*) AS total FROM `%s` WHERE %s'):format(entry.tableName, table.concat(whereClauses, ' OR '))
            local countRow = MySQL.single.await(countSql, params)
            local matchCount = math.floor(tonumber(countRow and countRow.total) or 0)
            if matchCount > 0 then
                totalRows = totalRows + matchCount
                matchedTables[#matchedTables + 1] = {
                    tableName = entry.tableName,
                    columns = entry.columns,
                    matchCount = matchCount
                }
            end
        end
    end

    table.sort(matchedTables, function(a, b)
        return a.tableName < b.tableName
    end)

    return matchedTables, totalRows
end

local getMoneySnapshot

function buildCharacterLookupPayload(citizenidRaw)
    local citizenid = sanitizeText(citizenidRaw, 64, '')
    if citizenid == '' or type(MySQL) ~= 'table' then
        return nil
    end

    local playerRow = MySQL.single.await('SELECT citizenid, license, charinfo, money FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    local charinfo = decodeJsonTable(playerRow and playerRow.charinfo) or {}
    local matchedTables, totalRows = getCharacterDeleteTargets(citizenid)
    local onlineSource, onlinePlayer = getOnlinePlayerByCitizenid(citizenid)
    local offlineMoney = decodeJsonTable(playerRow and playerRow.money) or {}
    local moneySnapshot = {}

    if onlinePlayer and onlinePlayer.PlayerData then
        moneySnapshot = getMoneySnapshot(onlinePlayer.PlayerData)
    else
        local configuredTypes = type(Config.MoneyTypes) == 'table' and Config.MoneyTypes or {}
        if #configuredTypes == 0 then
            configuredTypes = type(Config.Money) == 'table' and type(Config.Money.types) == 'table' and Config.Money.types or {}
        end

        for _, entry in ipairs(configuredTypes) do
            local key = sanitizeText(entry.value, 32, sanitizeText(entry.key, 32, '')):lower()
            if key ~= '' then
                moneySnapshot[key] = tonumber(offlineMoney[key]) or 0
            end
        end
    end

    return {
        found = playerRow ~= nil or #matchedTables > 0,
        citizenid = citizenid,
        license = sanitizeText(playerRow and playerRow.license, 96, ''),
        fullname = getCharacterFullName({ charinfo = charinfo }, citizenid),
        online = onlineSource ~= nil,
        onlineSource = onlineSource or 0,
        money = moneySnapshot,
        matchedTables = matchedTables,
        totalRows = totalRows
    }
end

local function deleteCharacterRecordsByCitizenid(citizenid)
    local lookup = buildCharacterLookupPayload(citizenid)
    if not lookup or lookup.found ~= true or type(lookup.matchedTables) ~= 'table' or #lookup.matchedTables == 0 then
        return false, S('developer_character_not_found', nil, 'Nenhum personagem encontrado para esta citizenid.'), nil
    end

    local transactionStarted = false
    local foreignKeysDisabled = false
    local deletedTables = 0
    local deletedRows = 0

    local ok, err = xpcall(function()
        MySQL.query.await('START TRANSACTION')
        transactionStarted = true
        MySQL.query.await('SET FOREIGN_KEY_CHECKS = 0')
        foreignKeysDisabled = true

        for _, target in ipairs(lookup.matchedTables) do
            local safeTable = sanitizeSqlIdentifier(target.tableName)
            local whereClauses = {}
            local params = {}

            for _, columnName in ipairs(target.columns or {}) do
                local safeColumn = sanitizeSqlIdentifier(columnName)
                if safeTable ~= '' and safeColumn ~= '' then
                    whereClauses[#whereClauses + 1] = ('`%s` = ?'):format(safeColumn)
                    params[#params + 1] = citizenid
                end
            end

            if safeTable ~= '' and #whereClauses > 0 then
                local sql = ('DELETE FROM `%s` WHERE %s'):format(safeTable, table.concat(whereClauses, ' OR '))
                local affectedRows = MySQL.update.await(sql, params) or 0
                deletedRows = deletedRows + math.max(0, affectedRows)
                deletedTables = deletedTables + 1
            end
        end

        MySQL.query.await('SET FOREIGN_KEY_CHECKS = 1')
        foreignKeysDisabled = false
        MySQL.query.await('COMMIT')
        transactionStarted = false
    end, function(errorMessage)
        return debug.traceback(tostring(errorMessage), 2)
    end)

    if foreignKeysDisabled then
        pcall(function()
            MySQL.query.await('SET FOREIGN_KEY_CHECKS = 1')
        end)
    end

    if transactionStarted then
        pcall(function()
            MySQL.query.await('ROLLBACK')
        end)
    end

    if not ok then
        return false, S('developer_delete_fail', nil, 'Falha ao deletar o personagem do banco de dados.'), nil
    end

    return true, S('developer_delete_success', {
        citizenid = citizenid,
        tables = deletedTables,
        rows = deletedRows
    }, 'Personagem {citizenid} deletado com sucesso. Tabelas limpas: {tables} | Registros removidos: {rows}.'), {
        citizenid = citizenid,
        deletedTables = deletedTables,
        deletedRows = deletedRows
    }
end

getMoneySnapshot = function(playerData)
    local money = playerData.money or {}
    local snapshot = {}
    local configuredTypes = type(Config.MoneyTypes) == 'table' and Config.MoneyTypes or {}
    if #configuredTypes == 0 then
        configuredTypes = type(Config.Money) == 'table' and type(Config.Money.types) == 'table' and Config.Money.types or {}
    end

    for _, entry in ipairs(configuredTypes) do
        local key = sanitizeText(entry.value, 32, sanitizeText(entry.key, 32, '')):lower()
        if key ~= '' then
            snapshot[key] = tonumber(money[key]) or 0
        end
    end

    return snapshot
end

local function getMetaSnapshot(playerData)
    local metadata = playerData.metadata or {}
    return {
        hunger = tonumber(metadata.hunger) or 0,
        thirst = tonumber(metadata.thirst) or 0,
        cleanliness = tonumber(metadata.cleanliness) or 0,
        isdead = metadata.isdead == true,
        ishandcuffed = metadata.ishandcuffed == true
    }
end

local function getCoordsSnapshot(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return nil
    end

    local ped = GetPlayerPed(sourceId)
    if not ped or ped == 0 then
        return nil
    end

    local coords = GetEntityCoords(ped)
    return {
        x = round(coords.x, 2),
        y = round(coords.y, 2),
        z = round(coords.z, 2)
    }
end

local function getInventoryWeightUsed(playerData)
    local items = playerData and playerData.items or {}
    local totalWeight = 0

    for _, item in pairs(items) do
        if type(item) == 'table' then
            local amount = tonumber(item.amount) or 0
            if amount > 0 then
                local itemWeight = tonumber(item.weight) or 0
                if itemWeight <= 0 then
                    local itemName = sanitizeText(item.name, 64, ''):lower()
                    local sharedItem = RSGCore.Shared.Items[itemName]
                    itemWeight = tonumber(sharedItem and sharedItem.weight) or 0
                end

                totalWeight = totalWeight + (itemWeight * amount)
            end
        end
    end

    return round(totalWeight, 2)
end

local function getInventoryCapacitySnapshot(playerData)
    local maxWeight = tonumber(playerData and playerData.weight) or 0
    local maxSlots = math.max(0, math.floor(tonumber(playerData and playerData.slots) or 0))
    local usedWeight = getInventoryWeightUsed(playerData)
    local usedSlots = 0
    local freeWeight = maxWeight - usedWeight
    if freeWeight < 0 then
        freeWeight = 0
    end

    local items = playerData and playerData.items or {}
    for _, item in pairs(items) do
        if type(item) == 'table' and (tonumber(item.amount) or 0) > 0 then
            usedSlots = usedSlots + 1
        end
    end

    local freeSlots = maxSlots - usedSlots
    if freeSlots < 0 then
        freeSlots = 0
    end

    return {
        maxWeight = round(maxWeight, 2),
        usedWeight = round(usedWeight, 2),
        freeWeight = round(freeWeight, 2),
        maxSlots = maxSlots,
        usedSlots = usedSlots,
        freeSlots = freeSlots
    }
end

local function fetchStoredAppearanceHeight(citizenidRaw)
    local citizenid = sanitizeText(citizenidRaw, 64, '')
    if citizenid == '' or type(MySQL) ~= 'table' then
        return nil
    end

    local row = MySQL.single.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    local skin = row and row.skin and json.decode(row.skin) or {}
    if type(skin) ~= 'table' then
        return nil
    end

    local parsed = tonumber(skin.height)
    if not parsed or parsed <= 0 then
        return nil
    end

    return math.floor((parsed * 10) + 0.5) / 10
end

local function formatDateTimeFromEpoch(epoch)
    local timestamp = tonumber(epoch)
    if not timestamp or timestamp <= 0 then
        return os.date('%Y-%m-%d %H:%M:%S')
    end
    return os.date('%Y-%m-%d %H:%M:%S', timestamp)
end

local function clearSupportStateForSource(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return
    end

    if spectateTargetByAdmin[sourceId] then
        TriggerClientEvent('bilto_admin:client:spectate:setState', sourceId, {
            enabled = false,
            targetSource = 0
        })
        spectateTargetByAdmin[sourceId] = nil
    end

    for adminSource, targetSource in pairs(spectateTargetByAdmin) do
        if tonumber(targetSource) == sourceId then
            TriggerClientEvent('bilto_admin:client:spectate:setState', tonumber(adminSource) or 0, {
                enabled = false,
                targetSource = 0
            })
            spectateTargetByAdmin[adminSource] = nil
        end
    end

end

function BitinhoAdmin.sendActionWebhook(entry)
    local webhookSettings = Config.Webhook
    local webhooks = Config.Webhooks
    local webhookUrl = type(webhooks) == 'table' and sanitizeText(webhooks[entry.action], 512, '') or ''
    if type(webhookSettings) ~= 'table'
        or webhookUrl:match('^https://discord%.com/api/webhooks/') == nil then
        return
    end

    -- kept local to this function (not chunk-level) to avoid growing the
    -- file's top-level local count past Lua's 200-local main-chunk limit
    local destructiveActions = {
        banPlayer = true,
        kick = true,
        removeJob = true,
        removeMoney = true,
        removeWeight = true,
        removeSlots = true,
        removeBan = true,
        clearInventory = true,
        deleteCharacterByCitizenid = true,
        permissionRemovePlayer = true
    }
    local positiveActions = {
        addItem = true,
        addMoney = true,
        addWeight = true,
        addSlots = true,
        permissionAddPlayer = true,
        revive = true,
        heal = true,
        spawnAdminHorse = true
    }

    local embedColor = webhookSettings.color
    if destructiveActions[entry.action] then
        embedColor = 15158332
    elseif positiveActions[entry.action] then
        embedColor = 3066993
    end

    local function appendActorFields(fields, label, actor)
        fields[#fields + 1] = { name = label, value = ('**%s**'):format(actor.characterName), inline = false }
        fields[#fields + 1] = { name = S('field_citizenid', {}, 'Citizenid'), value = ('`%s`'):format(actor.citizenid), inline = true }
        fields[#fields + 1] = { name = S('webhook_field_license', {}, 'License'), value = ('`%s`'):format(actor.license), inline = true }
        fields[#fields + 1] = { name = S('webhook_field_source', {}, 'ID Temporario'), value = ('`%s`'):format(actor.source), inline = true }
    end

    local actionTitle = S('webhook_action_' .. tostring(entry.action), {}, S('webhook_default_action', {}, 'Acao Administrativa'))
    local username = sanitizeText(webhookSettings.username, 80, 'Bilto Admin')
    local avatarUrl = sanitizeText(webhookSettings.avatarUrl, 512, '')

    local fields = {}
    appendActorFields(fields, S('webhook_admin_label', {}, '👮 Administrador'), entry.admin)

    if entry.targetSource > 0 then
        appendActorFields(fields, S('webhook_target_label', {}, '🎯 Alvo'), entry.target)
    end

    if entry.detail ~= '' then
        fields[#fields + 1] = {
            name = S('webhook_details_label', {}, '📝 Detalhes'),
            value = entry.detail,
            inline = false
        }
    end

    local embed = {
        title = S('webhook_log_title', { action = actionTitle }, actionTitle),
        color = embedColor,
        fields = fields,
        footer = { text = S('webhook_footer', {}, 'Bilto Admin • Auditoria') },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    if avatarUrl ~= '' then
        embed.author = { name = username, icon_url = avatarUrl }
        embed.thumbnail = { url = avatarUrl }
    else
        embed.author = { name = username }
    end

    PerformHttpRequest(webhookUrl, function() end, 'POST', json.encode({
        username = username,
        avatar_url = avatarUrl,
        allowed_mentions = { parse = {} },
        embeds = { embed }
    }), {
        ['Content-Type'] = 'application/json'
    })
end

local function pushAction(_adminSource, _actionName, _targetSource, _detail)
    local parsedAdminSource = toSourceNumber(_adminSource)
    local parsedTargetSource = toSourceNumber(_targetSource)

    local function buildWebhookActor(sourceId, fallbackName)
        local player = sourceId and getPlayerObject(sourceId) or nil
        local playerData = player and player.PlayerData or {}
        local license = ''

        if sourceId then
            for _, identifier in ipairs(GetPlayerIdentifiers(sourceId)) do
                if identifier:sub(1, 8) == 'license:' then
                    license = identifier
                    break
                end
            end
        end

        return {
            characterName = getCharacterFullName(playerData, fallbackName or 'N/A'),
            citizenid = sanitizeText(playerData.citizenid, 64, 'Nao informado'),
            license = sanitizeText(license, 96, 'Nao informado'),
            source = sourceId or 0
        }
    end

    local entry = {
        action = sanitizeText(_actionName, 64, ''),
        adminSource = parsedAdminSource or 0,
        adminName = parsedAdminSource and getPlayerNameSafe(parsedAdminSource) or 'N/A',
        admin = buildWebhookActor(parsedAdminSource, parsedAdminSource and getPlayerNameSafe(parsedAdminSource) or 'N/A'),
        targetSource = parsedTargetSource or 0,
        targetName = parsedTargetSource and getPlayerNameSafe(parsedTargetSource) or '',
        target = parsedTargetSource and buildWebhookActor(parsedTargetSource, getPlayerNameSafe(parsedTargetSource)) or nil,
        detail = sanitizeText(tostring(_detail or ''), 220, ''),
        at = os.date('%d/%m/%Y %H:%M:%S')
    }

    BitinhoAdmin.sendActionWebhook(entry)

    if shouldLogActions() then
        print(('[bilto_admin] action=%s admin=%s[%s] target=%s[%s] detail=%s'):format(
            entry.action,
            entry.adminName,
            entry.adminSource,
            entry.targetName,
            entry.targetSource,
            entry.detail
        ))
    end

end

local function getPanelStaffRoleLabel(sourceId)
    local customEntry = getPanelCustomEntryBySource(sourceId)
    if customEntry then
        local preset = getPanelPermissionPresetByKey(customEntry.presetKey)
        if preset and preset.label ~= '' then
            return preset.label
        end
        return S('player_staff_role_default', nil, 'Staff')
    end

    local role = BitinhoAdmin.GetFrameworkRole(sourceId)
    if role then
        return role.label
    end

    return ''
end

local function buildPlayerEntry(source)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return nil
    end

    local player = getPlayerObject(sourceId)
    if not player then
        return nil
    end

    local playerData = player.PlayerData
    local job = playerData.job or {}
    local rawGrade = job.grade
    local gradeLevel = 0
    local gradeName = 'N/A'

    if type(rawGrade) == 'table' then
        gradeLevel = tonumber(rawGrade.level) or tonumber(rawGrade.grade) or tonumber(rawGrade.id) or tonumber(rawGrade.rank) or 0
        gradeName = sanitizeText(rawGrade.name, 48, 'N/A')
    elseif type(rawGrade) == 'number' then
        gradeLevel = math.floor(rawGrade)
    elseif type(rawGrade) == 'string' then
        gradeLevel = tonumber(rawGrade) or 0
    end

    if gradeName == 'N/A' and type(job.name) == 'string' and job.name ~= '' then
        local sharedJob = RSGCore.Shared.Jobs[job.name]
        local sharedGrade = sharedJob and sharedJob.grades and sharedJob.grades[tostring(gradeLevel)] or nil
        if sharedGrade and sharedGrade.name then
            gradeName = sanitizeText(sharedGrade.name, 48, 'N/A')
        end
    end

    local license = normalizeLicense(playerData.license)
    if license == '' then
        local rawLicense = RSGCore.Functions.GetIdentifier(sourceId, 'license')
        license = normalizeLicense(rawLicense)
    end

    local jobsList = {}
    local seenJobs = {}
    local function addJobEntry(rawName, rawLabel, rawGrade, rawGradeName, rawOnDuty)
        local entryName = sanitizeText(rawName, 42, ''):lower()
        if entryName == '' or seenJobs[entryName] then
            return
        end

        seenJobs[entryName] = true
        jobsList[#jobsList + 1] = {
            name = entryName,
            label = sanitizeText(rawLabel, 64, entryName),
            grade = math.floor(tonumber(rawGrade) or 0),
            gradeName = sanitizeText(rawGradeName, 48, 'N/A'),
            onduty = rawOnDuty == true
        }
    end

    local citizenid = sanitizeText(playerData.citizenid, 64, '')
    if citizenid ~= '' then
        local multijobEntries = fetchStoredMultijobEntries(citizenid)
        for _, jobEntry in ipairs(multijobEntries) do
            addJobEntry(
                jobEntry and jobEntry.job,
                jobEntry and jobEntry.jobLabel,
                jobEntry and jobEntry.grade,
                jobEntry and jobEntry.gradeLabel,
                false
            )
        end
    end

    addJobEntry(job.name, job.label or job.name, gradeLevel, gradeName, job.onduty == true)

    local appearanceHeight = fetchStoredAppearanceHeight(citizenid)

    return {
        source = sourceId,
        name = getPlayerNameSafe(sourceId),
        fullname = getFullName(playerData),
        firstname = sanitizeText(playerData and playerData.charinfo and (playerData.charinfo.firstname or playerData.charinfo.firstName), 48, ''),
        lastname = sanitizeText(playerData and playerData.charinfo and (playerData.charinfo.lastname or playerData.charinfo.lastName), 48, ''),
        license = license,
        citizenid = playerData.citizenid or 'N/A',
        job = {
            name = job.name or 'unemployed',
            label = job.label or job.name or 'unemployed',
            grade = gradeLevel,
            gradeName = gradeName,
            onduty = job.onduty == true
        },
        money = getMoneySnapshot(playerData),
        metadata = getMetaSnapshot(playerData),
        height = appearanceHeight,
        inventory = getInventoryCapacitySnapshot(playerData),
        ping = GetPlayerPing(sourceId),
        coords = getCoordsSnapshot(sourceId),
        frozen = freezeState[sourceId] == true,
        isStaff = hasPanelPermission(sourceId),
        staffRole = getPanelStaffRoleLabel(sourceId),
        jobs = jobsList
    }
end

local function collectPlayers()
    local entries = {}
    local sources = RSGCore.Functions.GetPlayers()

    for _, source in ipairs(sources) do
        local playerEntry = buildPlayerEntry(source)
        if playerEntry then
            entries[#entries + 1] = playerEntry
        end
    end

    table.sort(entries, function(a, b)
        return a.source < b.source
    end)

    return entries
end

local function getCharacterNameForWall(playerData, sourceId)
    local charinfo = type(playerData and playerData.charinfo) == 'table' and playerData.charinfo or {}
    local first = sanitizeText(charinfo.firstname or charinfo.firstName, 48, '')
    local last = sanitizeText(charinfo.lastname or charinfo.lastName, 48, '')
    local joined = (first .. ' ' .. last):gsub('^%s+', ''):gsub('%s+$', '')
    if joined ~= '' then
        return joined
    end

    local fallback = sanitizeText(playerData and playerData.name, 96, '')
    if fallback ~= '' then
        return fallback
    end

    return getPlayerNameSafe(sourceId)
end

local function collectPlayersForBlips()
    local entries = {}
    local sources = RSGCore.Functions.GetPlayers()

    for _, source in ipairs(sources) do
        local sourceId = toSourceNumber(source)
        if sourceId then
            local coords = getCoordsSnapshot(sourceId)
            if coords then
                local player = getPlayerObject(sourceId)
                local playerData = player and player.PlayerData or {}
                local fullName = getCharacterNameForWall(playerData, sourceId)
                local job = type(playerData.job) == 'table' and playerData.job or {}
                local company = sanitizeText(job.label, 64, sanitizeText(job.name, 64, 'N/A'))
                local citizenidRaw = sanitizeText(playerData.citizenid, 64, '')
                local citizenid = citizenidRaw ~= '' and citizenidRaw or 'N/A'
                local adminRole = ''
                local adminRoleKey = ''
                local sourceCitizenid = getSourceNormalizedCitizenid(sourceId)
                if sourceCitizenid ~= '' then
                    local permissionEntry = getPanelPermissionEntryByCitizenid(sourceCitizenid)
                    local preset = permissionEntry and getPanelPermissionPresetByKey(permissionEntry.presetKey) or nil
                    adminRoleKey = sanitizeText(permissionEntry and permissionEntry.presetKey, 64, '')
                    adminRole = sanitizeText(preset and preset.label, 64, '')
                end
                if adminRoleKey == '' then
                    local frameworkRole = BitinhoAdmin.GetFrameworkRole(sourceId)
                    if frameworkRole then
                        adminRoleKey = frameworkRole.group
                        adminRole = frameworkRole.label
                    end
                end
                local weapon = wallWeaponState[sourceId]
                if type(weapon) == 'table' then
                    local weaponHash = tonumber(weapon.weaponHash) or 0
                    if weaponHash ~= 0 and weaponHash ~= -1569615261 then
                        weapon = { weaponHash = weaponHash }
                    else
                        weapon = nil
                    end
                else
                    weapon = nil
                end
                entries[#entries + 1] = {
                    id = sourceId,
                    name = fullName,
                    fullname = fullName,
                    citizenid = citizenid,
                    company = company,
                    adminRole = adminRole,
                    adminRoleKey = adminRoleKey,
                    coords = coords,
                    weapon = weapon
                }
            end
        end
    end

    return entries
end

local function getCachedPlayersForBlips()
    local now = getNowMs()
    if type(blipPlayersCache.entries) == 'table' and now < (tonumber(blipPlayersCache.expiresAt) or 0) then
        return blipPlayersCache.entries
    end

    local entries = collectPlayersForBlips()
    blipPlayersCache.entries = entries
    blipPlayersCache.expiresAt = now + BLIP_PLAYERS_CACHE_TTL_MS
    return entries
end

RegisterNetEvent('bilto_admin:server:updateWallWeaponState', function(payload)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return
    end

    local now = getNowMs()
    local lastUpdateAt = tonumber(wallWeaponStateUpdateAt[sourceId]) or 0
    if WALL_WEAPON_STATE_MIN_INTERVAL_MS > 0 and (now - lastUpdateAt) < WALL_WEAPON_STATE_MIN_INTERVAL_MS then
        return
    end
    wallWeaponStateUpdateAt[sourceId] = now

    local currentWeaponHash = tonumber(wallWeaponState[sourceId] and wallWeaponState[sourceId].weaponHash) or 0
    if type(payload) ~= 'table' then
        if currentWeaponHash ~= 0 then
            wallWeaponState[sourceId] = nil
            invalidateBlipPlayersCache()
        end
        return
    end

    local weaponHash = tonumber(payload.weaponHash) or 0
    if weaponHash == 0 or weaponHash == -1569615261 then
        if currentWeaponHash ~= 0 then
            wallWeaponState[sourceId] = nil
            invalidateBlipPlayersCache()
        end
        return
    end

    if currentWeaponHash == weaponHash then
        return
    end

    wallWeaponState[sourceId] = {
        weaponHash = weaponHash
    }
    invalidateBlipPlayersCache()
end)

local function getPanelPermissionUiFlags(rawPermissions)
    local normalized = normalizePanelPermissionSet(rawPermissions)
    local output = {
        all_permissions = normalized.all_permissions == true
    }
    for _, key in ipairs(PANEL_PERMISSION_KEYS) do
        output[key] = normalized[key] == true
    end
    return output
end

local function collectOnlinePermissionCandidates()
    local entries = {}
    local sources = RSGCore.Functions.GetPlayers()
    for _, source in ipairs(sources) do
        local sourceId = toSourceNumber(source)
        if sourceId then
            local sourceCitizenid = getSourceNormalizedCitizenid(sourceId)
            if sourceCitizenid ~= '' then
                local player = getPlayerObject(sourceId)
                local playerData = player and player.PlayerData or {}
                local customEntry = getPanelPermissionEntryByCitizenid(sourceCitizenid)
                local frameworkRole = BitinhoAdmin.GetFrameworkRole(sourceId)
                local hasFrameworkAccess = frameworkRole ~= nil
                local isGod = isGodPermission(sourceId)
                entries[#entries + 1] = {
                    source = sourceId,
                    name = getPlayerNameSafe(sourceId),
                    fullname = getFullName(playerData),
                    citizenid = sanitizeText(playerData and playerData.citizenid, 64, 'N/A'),
                    citzenid = sourceCitizenid,
                    isGod = isGod,
                    hasFrameworkAccess = hasFrameworkAccess,
                    frameworkGroup = frameworkRole and frameworkRole.group or '',
                    frameworkLabel = frameworkRole and frameworkRole.label or '',
                    hasCustomAccess = customEntry ~= nil,
                    hasPanelAccess = isGod or hasFrameworkAccess or customEntry ~= nil
                }
            end
        end
    end

    table.sort(entries, function(a, b)
        return a.source < b.source
    end)

    return entries
end

local function buildPermissionEntriesForPanel()
    local entries = {}
    local seen = {}
    local onlineByCitizenid = {}
    local onlineCandidates = collectOnlinePermissionCandidates()

    for _, online in ipairs(onlineCandidates) do
        onlineByCitizenid[online.citzenid] = online
    end

    ensurePanelPermissionStoreLoaded()
    for _, stored in ipairs(panelPermissionStore.entries or {}) do
        local online = onlineByCitizenid[stored.citzenid]
        local permissions = getPanelPermissionUiFlags(resolvePanelPermissionSetForEntry(stored))
        local preset = getPanelPermissionPresetByKey(stored.presetKey)
        entries[#entries + 1] = {
            citzenid = stored.citzenid,
            name = online and online.fullname or stored.name,
            source = online and online.source or 0,
            online = online ~= nil,
            accessType = preset and 'preset' or 'custom',
            presetKey = preset and preset.key or '',
            presetLabel = preset and preset.label or '',
            permissions = permissions,
            canManage = permissions.manage_permissions == true or permissions.all_permissions == true,
            isGod = online and online.isGod == true,
            editable = true,
            grantedBy = stored.grantedBy,
            updatedAt = stored.updatedAt
        }
        seen[stored.citzenid] = true
    end

    for _, online in ipairs(onlineCandidates) do
        if not seen[online.citzenid] and (online.isGod or online.hasFrameworkAccess) then
            local permissions = getPanelPermissionUiFlags(
                online.frameworkGroup ~= '' and BitinhoAdmin.GetFrameworkRolePermissions(online.frameworkGroup) or nil
            )
            entries[#entries + 1] = {
                citzenid = online.citzenid,
                name = online.fullname,
                source = online.source,
                online = true,
                accessType = online.isGod and 'god' or 'framework',
                presetLabel = online.frameworkLabel,
                permissions = permissions,
                canManage = online.isGod or permissions.all_permissions == true or permissions.manage_permissions == true,
                isGod = online.isGod,
                editable = false,
                grantedBy = '-',
                updatedAt = ''
            }
            seen[online.citzenid] = true
        end
    end

    table.sort(entries, function(a, b)
        if a.online ~= b.online then
            return a.online == true
        end
        local left = sanitizeText(a and a.name, 96, '')
        local right = sanitizeText(b and b.name, 96, '')
        if left == right then
            return sanitizeText(a and a.citzenid, 64, '') < sanitizeText(b and b.citzenid, 64, '')
        end
        return left < right
    end)

    return entries, onlineCandidates
end

local function buildAdminHorseCatalog()
    local catalog = {}
    local seen = {}
    local configured = Config.Developer and Config.Developer.adminHorses or {}

    for _, entry in ipairs(configured) do
        local horseId = sanitizeText(entry and entry.id, 64, ''):lower()
        local label = sanitizeText(entry and entry.label, 96, '')
        local model = sanitizeText(entry and entry.model, 96, ''):lower()
        local image = sanitizeText(entry and entry.image, 320, '')

        if horseId == '' and model ~= '' then
            horseId = model
        end
        if label == '' then
            label = horseId
        end

        if horseId ~= '' and model ~= '' and not seen[horseId] then
            seen[horseId] = true
            catalog[#catalog + 1] = {
                id = horseId,
                label = label,
                model = model,
                image = image
            }
        end
    end

    table.sort(catalog, function(a, b)
        return sanitizeText(a and a.label, 96, '') < sanitizeText(b and b.label, 96, '')
    end)

    return catalog
end

-- Exposed on BitinhoAdmin (instead of a top-level `local`) to stay clear of
-- Lua's 200-local-per-chunk ceiling, same as the Teleports/TopRichPlayers additions.
function BitinhoAdmin.BuildBuiltInTeleportCatalog()
    local catalog = {}
    local seen = {}
    local configured = type(Config.Teleports) == 'table' and Config.Teleports or {}

    for _, entry in ipairs(configured) do
        local teleportId = sanitizeText(entry and entry.id, 64, ''):lower()
        local name = sanitizeText(entry and entry.name, 100, '')
        local x = tonumber(entry and entry.x)
        local y = tonumber(entry and entry.y)
        local z = tonumber(entry and entry.z)

        if teleportId ~= '' and name ~= '' and x and y and z and not seen[teleportId] then
            seen[teleportId] = true
            catalog[#catalog + 1] = {
                id = teleportId,
                name = name,
                category = 'towns',
                description = sanitizeText(entry and entry.description, 255, ''),
                x = round(x, 2),
                y = round(y, 2),
                z = round(z, 2),
                heading = round(tonumber(entry and entry.heading) or 0.0, 1)
            }
        end
    end

    table.sort(catalog, function(a, b)
        return a.name < b.name
    end)

    return catalog
end

local function findAdminHorseById(horseIdRaw)
    local horseId = sanitizeText(horseIdRaw, 64, ''):lower()
    if horseId == '' then
        return nil
    end

    local catalog = panelStaticCatalogCache and panelStaticCatalogCache.adminHorses or buildAdminHorseCatalog()
    for _, entry in ipairs(catalog) do
        if sanitizeText(entry and entry.id, 64, ''):lower() == horseId then
            return entry
        end
    end

    return nil
end

local function getConfiguredMoneyTypeKeys()
    local configured = type(Config.MoneyTypes) == 'table' and Config.MoneyTypes or {}
    if #configured == 0 then
        configured = type(Config.Money) == 'table' and type(Config.Money.types) == 'table' and Config.Money.types or {}
    end

    local keys = {}
    local seen = {}

    for _, entry in ipairs(configured) do
        local key = sanitizeText(entry.value, 32, sanitizeText(entry.key, 32, '')):lower():gsub('[^%w_]', '')
        if key ~= '' and not seen[key] then
            seen[key] = true
            keys[#keys + 1] = key
        end
    end

    return keys
end

local function queryGlobalMoneyTotals()
    local totalsByType = {}
    local keys = getConfiguredMoneyTypeKeys()
    local cashType = sanitizeText(Config.Money and Config.Money.cashType, 24, 'cash'):lower():gsub('[^%w_]', '')

    local function isBankMoneyType(key)
        if type(key) ~= 'string' or key == '' or key == cashType then
            return false
        end

        if key == 'bank' then
            return true
        end

        return key:find('bank', 1, true) ~= nil
    end

    for _, key in ipairs(keys) do
        totalsByType[key] = 0
    end

    if type(MySQL) ~= 'table' or #keys == 0 then
        return {
            totalCash = 0,
            totalBank = 0,
            totalMoney = 0,
            byType = totalsByType
        }
    end

    local rows = MySQL.query.await('SELECT citizenid, money FROM players') or {}
    for _, row in ipairs(rows) do
        local citizenid = sanitizeText(row and row.citizenid, 64, '')
        local moneyTable = nil

        -- an online character's live bank/cash can differ from the `players` row
        -- (it's only as fresh as their last autosave), so prefer the live session.
        if citizenid ~= '' then
            local _, onlinePlayer = getOnlinePlayerByCitizenid(citizenid)
            if onlinePlayer and onlinePlayer.PlayerData and type(onlinePlayer.PlayerData.money) == 'table' then
                moneyTable = onlinePlayer.PlayerData.money
            end
        end

        if not moneyTable then
            moneyTable = decodeJsonTable(row and row.money)
        end

        if moneyTable then
            for _, key in ipairs(keys) do
                totalsByType[key] = (tonumber(totalsByType[key]) or 0) + (tonumber(moneyTable[key]) or 0)
            end
        end
    end

    local totalCash = tonumber(totalsByType[cashType]) or 0
    local totalBank = 0
    for _, key in ipairs(keys) do
        local amount = tonumber(totalsByType[key]) or 0
        totalsByType[key] = amount

        if isBankMoneyType(key) then
            totalBank = totalBank + amount
        end
    end

    return {
        totalCash = round(totalCash, 2),
        totalBank = round(totalBank, 2),
        totalMoney = round(totalCash + totalBank, 2),
        byType = totalsByType
    }
end

local function getGlobalMoneyTotalsCached()
    local now = os.time()
    local ttlMs = math.max(1000, math.floor(tonumber(Config.Performance and Config.Performance.globalMoneyCacheMs) or 15000))
    local ttlSeconds = math.max(1, math.floor(ttlMs / 1000))
    if globalMoneyCache.data and now < globalMoneyCache.expiresAt then
        return globalMoneyCache.data
    end

    local totals = queryGlobalMoneyTotals()
    globalMoneyCache.data = totals
    globalMoneyCache.expiresAt = now + ttlSeconds
    return totals
end

-- Exposed on the BitinhoAdmin global (instead of a top-level `local`) because
-- this file already sits at Lua's 200-local-per-chunk ceiling.
BitinhoAdmin.topRichPlayersCache = BitinhoAdmin.topRichPlayersCache or {
    expiresAt = 0,
    data = nil
}

function BitinhoAdmin.ClearTopRichPlayersCache()
    BitinhoAdmin.topRichPlayersCache.expiresAt = 0
    BitinhoAdmin.topRichPlayersCache.data = nil
end

function BitinhoAdmin.GetTopRichPlayersCached(limit)
    local cache = BitinhoAdmin.topRichPlayersCache
    local now = os.time()
    local ttlMs = math.max(1000, math.floor(tonumber(Config.Performance and Config.Performance.globalMoneyCacheMs) or 15000))
    local ttlSeconds = math.max(1, math.floor(ttlMs / 1000))
    if cache.data and now < cache.expiresAt then
        return cache.data
    end

    local keys = getConfiguredMoneyTypeKeys()
    local safeLimit = math.max(1, math.floor(tonumber(limit) or 10))
    local top = {}

    if type(MySQL) == 'table' and #keys > 0 then
        local rows = MySQL.query.await('SELECT citizenid, charinfo, money FROM players') or {}
        local entries = {}

        for _, row in ipairs(rows) do
            local citizenid = sanitizeText(row and row.citizenid, 64, '')
            if citizenid ~= '' then
                local onlineSource, onlinePlayer = getOnlinePlayerByCitizenid(citizenid)
                local moneyTable = onlinePlayer and onlinePlayer.PlayerData and onlinePlayer.PlayerData.money
                    or decodeJsonTable(row and row.money)
                    or {}

                local byType = {}
                local total = 0
                for _, key in ipairs(keys) do
                    local amount = round(tonumber(moneyTable[key]) or 0, 2)
                    byType[key] = amount
                    total = total + amount
                end

                if total > 0 then
                    local charinfo = decodeJsonTable(row and row.charinfo) or {}
                    entries[#entries + 1] = {
                        citizenid = citizenid,
                        name = getCharacterFullName({ charinfo = charinfo }, citizenid),
                        online = onlineSource ~= nil,
                        money = byType,
                        total = round(total, 2)
                    }
                end
            end
        end

        table.sort(entries, function(a, b)
            return a.total > b.total
        end)

        for index = 1, math.min(safeLimit, #entries) do
            top[#top + 1] = entries[index]
        end
    end

    cache.data = top
    cache.expiresAt = now + ttlSeconds
    return top
end

-- Custom teleport locations (Teleports tab). Also exposed on BitinhoAdmin
-- rather than top-level `local`s to stay clear of Lua's 200-local ceiling.
BitinhoAdmin.teleportStore = BitinhoAdmin.teleportStore or {
    storageReady = false
}

function BitinhoAdmin.EnsureTeleportStorage()
    if BitinhoAdmin.teleportStore.storageReady then
        return true
    end

    if type(MySQL) ~= 'table' then
        return false
    end

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS `bilto_admin_teleports` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `name` VARCHAR(100) NOT NULL,
        `category` VARCHAR(30) NOT NULL DEFAULT 'special',
        `description` VARCHAR(255) NOT NULL DEFAULT '',
        `x` FLOAT NOT NULL,
        `y` FLOAT NOT NULL,
        `z` FLOAT NOT NULL,
        `heading` FLOAT NOT NULL DEFAULT 0,
        `created_by` VARCHAR(96) NOT NULL DEFAULT '',
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;]])

    BitinhoAdmin.teleportStore.storageReady = true
    return true
end

function BitinhoAdmin.GetTeleportLocations()
    if not BitinhoAdmin.EnsureTeleportStorage() then
        return {}
    end

    local rows = MySQL.query.await('SELECT id, name, category, description, x, y, z, heading, created_by FROM bilto_admin_teleports ORDER BY name ASC') or {}
    local entries = {}

    for _, row in ipairs(rows) do
        entries[#entries + 1] = {
            id = tonumber(row.id),
            name = sanitizeText(row.name, 100, ''),
            category = sanitizeText(row.category, 30, 'special'):lower(),
            description = sanitizeText(row.description, 255, ''),
            x = tonumber(row.x) or 0.0,
            y = tonumber(row.y) or 0.0,
            z = tonumber(row.z) or 0.0,
            heading = tonumber(row.heading) or 0.0,
            createdBy = sanitizeText(row.created_by, 96, '')
        }
    end

    return entries
end

function BitinhoAdmin.AddTeleportLocation(adminSource, payload)
    if not BitinhoAdmin.EnsureTeleportStorage() then
        return false, S('teleport_storage_unavailable', nil, 'Armazenamento de teleportes indisponivel.')
    end

    local data = type(payload) == 'table' and payload or {}
    local name = sanitizeText(data.name, 100, '')
    if name == '' then
        return false, S('teleport_name_required', nil, 'Informe um nome para o local.')
    end

    local category = sanitizeText(data.category, 30, 'special'):lower():gsub('[^%w_]', '')
    if category == '' then
        category = 'special'
    end

    local description = sanitizeText(data.description, 255, '')
    local x = tonumber(data.x)
    local y = tonumber(data.y)
    local z = tonumber(data.z)
    if not x or not y or not z then
        return false, S('teleport_coords_invalid', nil, 'Coordenadas invalidas.')
    end
    local heading = tonumber(data.heading) or 0.0

    local createdBy = getCharacterNameSafe(adminSource)
    local insertId = MySQL.insert.await(
        'INSERT INTO bilto_admin_teleports (name, category, description, x, y, z, heading, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { name, category, description, round(x, 2), round(y, 2), round(z, 2), round(heading, 1), createdBy }
    )

    if not insertId then
        return false, S('teleport_add_fail', nil, 'Falha ao adicionar local.')
    end

    pushAction(adminSource, 'addTeleportLocation', nil, name)
    return true, S('teleport_add_success', { name = name }, 'Local {name} adicionado.')
end

function BitinhoAdmin.DeleteTeleportLocation(adminSource, payload)
    if not BitinhoAdmin.EnsureTeleportStorage() then
        return false, S('teleport_storage_unavailable', nil, 'Armazenamento de teleportes indisponivel.')
    end

    local data = type(payload) == 'table' and payload or {}
    local id = tonumber(data.id)
    if not id then
        return false, S('teleport_invalid_id', nil, 'ID de local invalido.')
    end

    local affected = MySQL.update.await('DELETE FROM bilto_admin_teleports WHERE id = ?', { id })
    if not affected or affected <= 0 then
        return false, S('teleport_delete_fail', nil, 'Falha ao remover local.')
    end

    pushAction(adminSource, 'deleteTeleportLocation', nil, tostring(id))
    return true, S('teleport_delete_success', nil, 'Local removido.')
end

local function buildDashboard(entries, globalMoneyTotals, topRichPlayers)
    local online = #entries
    local deadPlayers = 0
    local staffOnline = 0
    local totalPing = 0
    local jobBuckets = {}
    local sharedJobs = RSGCore.Shared.Jobs or {}

    -- Include all jobs created in the server, even with zero online players.
    for jobName, jobData in pairs(sharedJobs) do
        local jobLabel = sanitizeText(jobData and jobData.label, 42, sanitizeText(jobName, 42, 'unemployed'))
        if not jobBuckets[jobLabel] then
            jobBuckets[jobLabel] = {
                job = jobLabel,
                total = 0,
                onDuty = 0
            }
        end
    end

    for _, entry in ipairs(entries) do
        if entry.metadata.isdead then
            deadPlayers = deadPlayers + 1
        end

        if entry.isStaff then
            staffOnline = staffOnline + 1
        end

        totalPing = totalPing + entry.ping

        local entryJob = entry.job or {}
        local jobLabel = sanitizeText(entryJob.label, 42, sanitizeText(entryJob.name, 42, 'unemployed'))
        if not jobBuckets[jobLabel] then
            jobBuckets[jobLabel] = {
                job = jobLabel,
                total = 0,
                onDuty = 0
            }
        end

        jobBuckets[jobLabel].total = jobBuckets[jobLabel].total + 1
        if entryJob.onduty then
            jobBuckets[jobLabel].onDuty = jobBuckets[jobLabel].onDuty + 1
        end
    end

    local averagePing = 0
    if online > 0 then
        averagePing = math.floor(totalPing / online)
    end

    local globalTotals = type(globalMoneyTotals) == 'table' and globalMoneyTotals or {}
    local jobDistribution = {}
    for _, data in pairs(jobBuckets) do
        jobDistribution[#jobDistribution + 1] = data
    end

    table.sort(jobDistribution, function(a, b)
        if a.total == b.total then
            return a.job < b.job
        end

        return a.total > b.total
    end)

    return {
        online = online,
        maxClients = GetConvarInt('sv_maxclients', 0),
        staffOnline = staffOnline,
        deadPlayers = deadPlayers,
        averagePing = averagePing,
        totalMoney = round(tonumber(globalTotals.totalMoney) or 0, 2),
        jobDistribution = jobDistribution,
        topRichPlayers = type(topRichPlayers) == 'table' and topRichPlayers or {},
        updatedAt = os.date('%Y-%m-%d %H:%M:%S')
    }
end

local function buildMoneyTypeCatalog()
    local catalog = {}
    local configured = type(Config.MoneyTypes) == 'table' and Config.MoneyTypes or {}
    if #configured == 0 then
        configured = type(Config.Money) == 'table' and type(Config.Money.types) == 'table' and Config.Money.types or {}
    end
    local seen = {}

    for _, entry in ipairs(configured) do
        local key = sanitizeText(entry.value, 32, sanitizeText(entry.key, 32, '')):lower()
        if key ~= '' and not seen[key] then
            seen[key] = true
            catalog[#catalog + 1] = {
                key = key,
                label = sanitizeText(entry.label, 42, key:upper())
            }
        end
    end

    return catalog
end

local function buildJobCatalog()
    local catalog = {}
    for jobName, jobData in pairs(RSGCore.Shared.Jobs or {}) do
        local grades = {}
        local gradeMap = jobData.grades or {}

        for gradeKey, gradeData in pairs(gradeMap) do
            local level = tonumber(gradeKey)
            if level then
                grades[#grades + 1] = {
                    level = level,
                    name = sanitizeText(gradeData.name, 48, ('Grade %s'):format(level))
                }
            end
        end

        table.sort(grades, function(a, b)
            return a.level < b.level
        end)

        catalog[#catalog + 1] = {
            name = jobName,
            label = sanitizeText(jobData.label, 64, jobName),
            grades = grades
        }
    end

    table.sort(catalog, function(a, b)
        return a.label < b.label
    end)

    return catalog
end

local function buildItemCatalog()
    local catalog = {}
    for itemName, itemData in pairs(RSGCore.Shared.Items or {}) do
        catalog[#catalog + 1] = {
            name = itemName,
            label = sanitizeText(itemData.label, 64, itemName),
            description = sanitizeText(itemData.description, 160, ''),
            itemType = sanitizeText(itemData.type, 24, 'item'),
            category = sanitizeText(itemData.category, 48, ''):lower(),
            image = sanitizeText(itemData.image, 120, ''),
            weight = tonumber(itemData.weight) or 0
        }
    end

    table.sort(catalog, function(a, b)
        return a.label < b.label
    end)

    return catalog
end

local function buildCompanyStashCatalog()
    local resourceState = GetResourceState('rsg-bossmenu')
    if resourceState ~= 'started' then
        return {}, S('company_stash_catalog_unavailable', nil, 'Catalogo de baus indisponivel (rsg-bossmenu offline).')
    end

    local ok, rawCatalog = pcall(function()
        return exports['rsg-bossmenu']:GetBossStashCatalog()
    end)
    if not ok or type(rawCatalog) ~= 'table' then
        return {}, S('company_stash_catalog_unavailable', nil, 'Catalogo de baus indisponivel no momento.')
    end

    local catalog = {}
    local seenByName = {}
    for _, entry in ipairs(rawCatalog) do
        local stashName = sanitizeText(entry and entry.stashName, 80, ''):lower()
        if stashName ~= '' and not seenByName[stashName] then
            seenByName[stashName] = true
            local jobName = sanitizeText(entry and entry.job, 64, stashName:gsub('^boss_', ''))
            catalog[#catalog + 1] = {
                stashName = stashName,
                job = jobName,
                label = sanitizeText(entry and entry.label, 96, jobName ~= '' and jobName or stashName),
                maxweight = math.max(1, math.floor(tonumber(entry and entry.maxweight) or 4000000)),
                slots = math.max(1, math.floor(tonumber(entry and entry.slots) or 10))
            }
        end
    end

    table.sort(catalog, function(a, b)
        local left = sanitizeText(a and a.label, 96, '')
        local right = sanitizeText(b and b.label, 96, '')
        if left == right then
            return sanitizeText(a and a.job, 64, '') < sanitizeText(b and b.job, 64, '')
        end
        return left < right
    end)

    return catalog, nil
end

local function buildBanDayPresetCatalog()
    local seen = {}
    local catalog = {}

    for _, raw in ipairs(Config.Ban and Config.Ban.dayPresets or {}) do
        local days = math.floor(tonumber(raw) or 0)
        if days > 0 and not seen[days] then
            seen[days] = true
            catalog[#catalog + 1] = days
        end
    end

    table.sort(catalog, function(a, b)
        return a < b
    end)

    if #catalog == 0 then
        catalog = { 1, 3, 7, 15, 30 }
    end

    return catalog
end

local function buildBanDurationCatalog()
    local catalog = {}
    local presets = buildBanDayPresetCatalog()

    for _, days in ipairs(presets) do
        catalog[#catalog + 1] = {
            value = tostring(days),
            label = days == 1
                and S('ban_duration_day', { days = days }, '{days} dia')
                or S('ban_duration_days', { days = days }, '{days} dias')
        }
    end

    catalog[#catalog + 1] = {
        value = 'permanent',
        label = S('ban_duration_permanent', nil, 'Permanente')
    }

    return catalog
end

local function buildStaticPanelCatalog()
    return {
        jobs = buildJobCatalog(),
        items = buildItemCatalog(),
        moneyTypes = buildMoneyTypeCatalog(),
        banDurations = buildBanDurationCatalog(),
        adminHorses = buildAdminHorseCatalog(),
        builtInTeleports = BitinhoAdmin.BuildBuiltInTeleportCatalog(),
        permissionDefinitions = buildPanelPermissionCatalog(),
        permissionPresets = buildPanelPermissionPresetCatalog()
    }
end

local function getStaticPanelCatalog()
    if panelStaticCatalogCache ~= nil then
        return panelStaticCatalogCache
    end

    panelStaticCatalogCache = buildStaticPanelCatalog()
    return panelStaticCatalogCache
end

local function isAllowedBanDayAmount(amountRaw)
    local amount = math.floor(tonumber(amountRaw) or 0)
    if amount <= 0 then
        return false
    end

    for _, allowed in ipairs(buildBanDayPresetCatalog()) do
        if allowed == amount then
            return true
        end
    end

    return false
end

local function validateTarget(targetSource)
    local parsedSource = tonumber(targetSource)
    if not parsedSource or parsedSource <= 0 then
        return nil, nil, S('target_invalid_id', nil, 'ID de alvo invalido.')
    end

    local player = getPlayerObject(parsedSource)
    if not player then
        return nil, nil, S('target_offline', nil, 'Jogador alvo offline.')
    end

    return parsedSource, player
end

local function getIdentifierSafe(source, identifierType)
    local value = RSGCore.Functions.GetIdentifier(source, identifierType)
    if type(value) ~= 'string' then
        return ''
    end

    return value
end

local function resolveBanMode(modeRaw)
    local mode = sanitizeText(modeRaw, 16, 'permanent'):lower()
    if mode == 'permanent' or mode == 'days' then
        return mode
    end

    return nil
end

local function buildBanExpiration(mode, amountRaw)
    local permanentExpire = getSafePermanentExpire()
    if mode == 'permanent' then
        return permanentExpire, nil
    end

    local amount = math.floor(tonumber(amountRaw) or 0)
    if amount <= 0 then
        return nil, S('ban_amount_invalid_temporary', nil, 'Quantidade invalida para ban temporario.')
    end

    if mode == 'days' then
        local maxDays = tonumber(Config.Ban and Config.Ban.maxDays) or 3650
        if not isAllowedBanDayAmount(amount) then
            return nil, S('ban_duration_invalid', { presetList = formatBanDayPresetList() }, 'Duracao invalida. Use {presetList} dias ou permanente.')
        end

        if amount > maxDays then
            return nil, S('ban_days_max', { maxDays = maxDays }, 'Quantidade maxima de dias: {maxDays}.')
        end

        local expiresAt = os.time() + (amount * 86400)
        return math.min(expiresAt, permanentExpire), nil
    end

    return nil, S('ban_mode_invalid', nil, 'Modo de banimento invalido.')
end

local function formatBanExpiration(expiresAt)
    local permanentExpire = getSafePermanentExpire()
    if tonumber(expiresAt) >= permanentExpire then
        return S('ban_expiration_permanent', nil, 'permanente')
    end

    local timeTable = os.date('*t', tonumber(expiresAt))
    return S('ban_expiration_until', {
        day = ('%02d'):format(timeTable.day),
        month = ('%02d'):format(timeTable.month),
        year = ('%04d'):format(timeTable.year),
        hour = ('%02d'):format(timeTable.hour),
        min = ('%02d'):format(timeTable.min)
    }, 'ate {day}/{month}/{year} {hour}:{min}')
end

local function collectActiveLocalBans()
    if type(MySQL) ~= 'table' then
        return {}
    end

    local now = os.time()
    local rows = MySQL.query.await('SELECT id, name, license, reason, expire, bannedby FROM bans ORDER BY id DESC') or {}
    local entries = {}
    local permanentExpire = getSafePermanentExpire()

    for _, row in ipairs(rows) do
        local banId = math.floor(tonumber(row and row.id) or 0)
        local expire = math.floor(tonumber(row and row.expire) or 0)
        if banId > 0 and expire > now then
            entries[#entries + 1] = {
                id = banId,
                name = sanitizeText(row and row.name, 96, 'N/A'),
                license = sanitizeText(row and row.license, 120, 'N/A'),
                reason = sanitizeText(row and row.reason, 220, '-'),
                bannedBy = sanitizeText(row and row.bannedby, 96, '-'),
                expire = expire,
                expireSort = expire,
                isPermanent = expire >= permanentExpire,
                expiresLabel = formatBanExpiration(expire)
            }
        end
    end

    return entries
end

local function collectActiveBans()
    local entries = {}

    for _, row in ipairs(collectActiveLocalBans()) do
        entries[#entries + 1] = row
    end

    table.sort(entries, function(a, b)
        local leftExpire = tonumber(a and a.expireSort) or tonumber(a and a.expire) or 0
        local rightExpire = tonumber(b and b.expireSort) or tonumber(b and b.expire) or 0
        if leftExpire == rightExpire then
            return tostring(a.id) > tostring(b.id)
        end
        return leftExpire > rightExpire
    end)

    return entries
end

local function parseBanId(rawBanId)
    local banId = math.floor(tonumber(rawBanId) or 0)
    if banId <= 0 then
        return nil, S('ban_id_invalid', nil, 'ID do banimento invalido.')
    end
    return banId
end

local function buildBanEditedExpiration(currentExpire, mode, amountRaw)
    local permanentExpire = getSafePermanentExpire()
    if mode == 'permanent' then
        return permanentExpire, nil
    end

    local amount = math.floor(tonumber(amountRaw) or 0)
    if amount <= 0 then
        return nil, S('ban_amount_invalid_temporary', nil, 'Quantidade invalida para ban temporario.')
    end

    if mode ~= 'days' then
        return nil, S('ban_mode_invalid', nil, 'Modo de banimento invalido.')
    end

    local maxDays = tonumber(Config.Ban and Config.Ban.maxDays) or 3650
    if not isAllowedBanDayAmount(amount) then
        return nil, S('ban_duration_invalid', { presetList = formatBanDayPresetList() }, 'Duracao invalida. Use {presetList} dias ou permanente.')
    end
    if amount > maxDays then
        return nil, S('ban_days_max', { maxDays = maxDays }, 'Quantidade maxima de dias: {maxDays}.')
    end

    local baseExpire = math.max(os.time(), math.floor(tonumber(currentExpire) or 0))
    local expiresAt = baseExpire + (amount * 86400)
    return math.min(expiresAt, permanentExpire), nil
end

local function requirePlayerFunction(player, functionName)
    if type(player) ~= 'table' then
        return nil, 'player_invalido'
    end

    local desiredName = tostring(functionName or '')
    local desiredNameLower = desiredName:lower()

    local function isCallable(value)
        local valueType = type(value)
        if valueType == 'function' then
            return true
        end

        if valueType == 'table' or valueType == 'userdata' then
            local metatable = getmetatable(value)
            if type(metatable) == 'table' and type(metatable.__call) == 'function' then
                return true
            end
        end

        return false
    end

    local function resolveCallable(container)
        if type(container) ~= 'table' then
            return nil
        end

        local direct = container[desiredName]
        if isCallable(direct) then
            return direct
        end

        for key, value in pairs(container) do
            if isCallable(value) and tostring(key):lower() == desiredNameLower then
                return value
            end
        end

        return nil
    end

    local functionsContainer = type(player.Functions) == 'table' and player.Functions or nil
    local handler = resolveCallable(functionsContainer) or resolveCallable(player)
    if isCallable(handler) then
        return handler, nil
    end

    return nil, ('handler_ausente:%s'):format(tostring(functionName))
end

local function collectTableKeysLimited(sourceTable, maxItems)
    if type(sourceTable) ~= 'table' then
        return 'n/a'
    end

    local limit = math.max(1, math.floor(tonumber(maxItems) or 24))
    local keys = {}

    for key in pairs(sourceTable) do
        keys[#keys + 1] = tostring(key)
    end

    table.sort(keys)

    if #keys > limit then
        local visible = {}
        for index = 1, limit do
            visible[#visible + 1] = keys[index]
        end
        visible[#visible + 1] = ('...(+%s)'):format(#keys - limit)
        return table.concat(visible, ', ')
    end

    return table.concat(keys, ', ')
end

local function collectFunctionKeysLimited(sourceTable, maxItems)
    if type(sourceTable) ~= 'table' then
        return 'n/a'
    end

    local limit = math.max(1, math.floor(tonumber(maxItems) or 24))
    local keys = {}

    local function isCallable(value)
        local valueType = type(value)
        if valueType == 'function' then
            return true
        end

        if valueType == 'table' or valueType == 'userdata' then
            local metatable = getmetatable(value)
            if type(metatable) == 'table' and type(metatable.__call) == 'function' then
                return true
            end
        end

        return false
    end

    for key, value in pairs(sourceTable) do
        if isCallable(value) then
            keys[#keys + 1] = tostring(key)
        end
    end

    table.sort(keys)

    if #keys > limit then
        local visible = {}
        for index = 1, limit do
            visible[#visible + 1] = keys[index]
        end
        visible[#visible + 1] = ('...(+%s)'):format(#keys - limit)
        return table.concat(visible, ', ')
    end

    return table.concat(keys, ', ')
end

local function debugLogSetJobAttempt(adminSource, targetSource, player, payload)
    return adminSource, targetSource, player, payload
end

local function debugLogMissingPlayerHandler(functionName, targetSource, player)
    return functionName, targetSource, player
end

local function actionGoto(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local targetCoords = getCoordsSnapshot(parsedTarget)
    if not targetCoords then
        return false, S('action_goto_target_coords_fail', nil, 'Nao foi possivel ler a posicao do alvo.')
    end

    TriggerClientEvent('bilto_admin:client:teleportTo', adminSource, targetCoords)
    pushAction(adminSource, 'goto', parsedTarget, 'teleportado ate o jogador')
    return true, S('self_goto_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce foi ate {targetName} [{targetSource}].')
end

local function actionBring(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local adminCoords = getCoordsSnapshot(adminSource)
    if not adminCoords then
        return false, S('action_bring_admin_coords_fail', nil, 'Nao foi possivel ler sua posicao.')
    end

    TriggerClientEvent('bilto_admin:client:teleportTo', parsedTarget, adminCoords)
    notifyTargetAction(parsedTarget, adminSource, S('bring_target_notify', nil, 'Voce foi teleportado por um administrador.'), 'info')
    pushAction(adminSource, 'bring', parsedTarget, 'trazido ate o admin')
    return true, S('bring_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce trouxe {targetName} [{targetSource}] ate voce.')
end

local function actionRevive(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    TriggerClientEvent('rsg-medic:client:adminRevive', parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('revive_target_notify', nil, 'Voce foi revivido por um administrador.'), 'ok')
    pushAction(adminSource, 'revive', parsedTarget, 'revive acionado')
    return true, S('revive_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce reviveu {targetName} [{targetSource}].')
end

local function actionHeal(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if player.Functions and type(player.Functions.SetMetaData) == 'function' then
        player.Functions.SetMetaData({
            hunger = 100,
            thirst = 100,
            cleanliness = 100,
            stress = 0,
            health = 600
        })
    end

    TriggerClientEvent('rsg-medic:client:adminHeal', parsedTarget)
    TriggerClientEvent('bilto_admin:client:restoreStamina', parsedTarget)
    TriggerClientEvent('hud:client:UpdateNeeds', parsedTarget, 100, 100, 100)
    TriggerClientEvent('hud:client:UpdateStress', parsedTarget, 0)
    notifyTargetAction(parsedTarget, adminSource, S('heal_target_notify', nil, 'Voce foi curado e teve todos os status restaurados por um administrador.'), 'ok')
    pushAction(adminSource, 'heal', parsedTarget, 'heal + hunger/thirst/cleanliness/stress restored')
    return true, S('heal_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce curou {targetName} [{targetSource}] e restaurou todos os status.')
end

function BitinhoAdmin.actionExecuteLightning(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    TriggerClientEvent('bilto_admin:client:executeLightning', parsedTarget)
    pushAction(adminSource, 'executeLightning', parsedTarget, 'raio executado')
    return true, S('execute_lightning_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce executou um raio em {targetName} [{targetSource}].')
end

local function actionToggleFreeze(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    freezeState[parsedTarget] = not freezeState[parsedTarget]
    TriggerClientEvent('bilto_admin:client:setFrozen', parsedTarget, freezeState[parsedTarget])
    pushAction(adminSource, 'toggleFreeze', parsedTarget, freezeState[parsedTarget] and 'frozen=true' or 'frozen=false')
    return true, freezeState[parsedTarget]
        and S('toggle_freeze_success', {
            targetName = getCharacterNameSafe(parsedTarget),
            targetSource = parsedTarget
        }, 'Voce congelou {targetName} [{targetSource}].')
        or S('toggle_unfreeze_success', {
            targetName = getCharacterNameSafe(parsedTarget),
            targetSource = parsedTarget
        }, 'Voce descongelou {targetName} [{targetSource}].')
end

local function actionSpectate(adminSource, payload)
    local parsedAdmin = toSourceNumber(adminSource)
    if not parsedAdmin then
        return false, S('target_invalid_id', nil, 'ID de alvo invalido.')
    end

    local parsedTarget, _, err = validateTarget(payload and payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if parsedTarget == parsedAdmin then
        return false, S('spectate_self_denied', nil, 'Voce nao pode spectar a si mesmo.')
    end

    local currentTarget = toSourceNumber(spectateTargetByAdmin[parsedAdmin])
    local enableSpectate = currentTarget ~= parsedTarget
    if enableSpectate then
        spectateTargetByAdmin[parsedAdmin] = parsedTarget
    else
        spectateTargetByAdmin[parsedAdmin] = nil
    end

    TriggerClientEvent('bilto_admin:client:spectate:setState', parsedAdmin, {
        enabled = enableSpectate,
        targetSource = enableSpectate and parsedTarget or 0,
        targetName = enableSpectate and getCharacterNameSafe(parsedTarget) or '',
        actorName = getCharacterNameSafe(parsedAdmin)
    })

    pushAction(adminSource, 'spectate', parsedTarget, enableSpectate and 'enabled' or 'disabled')
    return true, enableSpectate
        and S('spectate_enabled', {
            targetName = getCharacterNameSafe(parsedTarget),
            targetSource = parsedTarget
        }, 'Spectate ativado em {targetName} [{targetSource}].')
        or S('spectate_disabled', nil, 'Spectate desativado.')
end

local function actionOpenInventory(adminSource, payload)
    local parsedTarget, targetPlayer, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local adminPlayer = getPlayerObject(adminSource)
    if not adminPlayer or not targetPlayer then
        return false, S('action_open_inventory_fail', nil, 'Nao foi possivel abrir o inventario deste jogador.')
    end

    -- Fast path: avoid rsg-inventory OpenInventoryById built-in 1500ms wait.
    if Player(parsedTarget).state.inv_busy then
        exports['rsg-inventory']:CloseInventory(parsedTarget)
    end

    local playerItems = adminPlayer.PlayerData.items or {}
    local targetItems = targetPlayer.PlayerData.items or {}
    local formattedInventory = {
        name = ('otherplayer-%s'):format(parsedTarget),
        label = getCharacterNameSafe(parsedTarget),
        maxweight = tonumber(targetPlayer.PlayerData.weight) or 0,
        slots = tonumber(targetPlayer.PlayerData.slots) or 0,
        inventory = targetItems
    }

    Player(parsedTarget).state.inv_busy = true
    TriggerClientEvent('rsg-inventory:client:openInventory', adminSource, playerItems, formattedInventory)
    pushAction(adminSource, 'openInventory', parsedTarget, 'inventario aberto pelo admin')
    return true, S('open_inventory_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce abriu o inventario de {targetName} [{targetSource}].')
end

local function actionOpenCompanyStash(adminSource, payload)
    local stashName = sanitizeText(payload and payload.stashName, 80, ''):lower()
    if stashName == '' then
        return false, S('company_stash_invalid', nil, 'Bau invalido.')
    end

    local companyStashes, catalogErr = buildCompanyStashCatalog()
    if #companyStashes == 0 then
        return false, catalogErr or S('company_stash_catalog_unavailable', nil, 'Catalogo de baus indisponivel.')
    end

    local selectedStash = nil
    for _, entry in ipairs(companyStashes) do
        if sanitizeText(entry and entry.stashName, 80, '') == stashName then
            selectedStash = entry
            break
        end
    end

    if not selectedStash then
        return false, S('company_stash_not_found', nil, 'Bau nao encontrado no catalogo.')
    end

    exports['rsg-inventory']:OpenInventory(adminSource, selectedStash.stashName, {
        label = sanitizeText(selectedStash.label, 96, selectedStash.stashName),
        maxweight = math.max(1, math.floor(tonumber(selectedStash.maxweight) or 4000000)),
        slots = math.max(1, math.floor(tonumber(selectedStash.slots) or 10))
    })

    pushAction(adminSource, 'openCompanyStash', nil, ('%s [%s]'):format(
        sanitizeText(selectedStash.label, 96, selectedStash.stashName),
        sanitizeText(selectedStash.stashName, 80, '-')
    ))

    return true, S('company_stash_open_success', {
        label = sanitizeText(selectedStash.label, 96, selectedStash.stashName)
    }, 'Bau "{label}" aberto com sucesso.')
end

local function actionTogglePlayerBlips(adminSource, _)
    TriggerClientEvent('bilto_admin:client:togglePlayerBlips', adminSource)
    pushAction(adminSource, 'togglePlayerBlips', nil, 'blips toggled')
    return true, S('toggle_blips_success', nil, 'Blips de jogadores alternados.')
end

local function actionTogglePlayerWall(adminSource, _)
    TriggerClientEvent('bilto_admin:client:togglePlayerWall', adminSource)
    pushAction(adminSource, 'togglePlayerWall', nil, 'wall toggled')
    return true, S('toggle_wall_success', nil, 'Wall de jogadores alternado.')
end

local function setNoclipState(source, enabled)
    local sourceId = toSourceNumber(source)
    if not sourceId then
        return false
    end

    local nextState = enabled == true
    noclipState[sourceId] = nextState
    TriggerClientEvent('bilto_admin:client:noclip:setEnabled', sourceId, nextState)
    return true
end

local function actionToggleNoclip(adminSource, _)
    local sourceId = toSourceNumber(adminSource)
    if not sourceId then
        return false, S('target_invalid_id', nil, 'ID de alvo invalido.')
    end

    local nextState = noclipState[sourceId] ~= true
    setNoclipState(sourceId, nextState)
    pushAction(adminSource, 'toggleNoclip', sourceId, nextState and 'enabled' or 'disabled')
    return true, nextState
        and S('noclip_enabled', nil, 'Noclip ativado.')
        or S('noclip_disabled', nil, 'Noclip desativado.')
end

local function canUseNoclipCommand(source)
    if hasPanelActionPermission(source, 'toggleNoclip') then
        return true
    end

    return hasPanelPermission(source)
end

local function actionSpawnAdminHorse(adminSource, payload)
    local horseEntry = findAdminHorseById(payload and payload.horseId)
    if not horseEntry then
        return false, S('horse_invalid', nil, 'Cavalo invalido.')
    end

    TriggerClientEvent('bilto_admin:client:spawnAdminHorse', adminSource, horseEntry.model, horseEntry.label)
    pushAction(adminSource, 'spawnAdminHorse', nil, horseEntry.label)
    return true, S('horse_spawn_success', {
        label = horseEntry.label
    }, 'Cavalo "{label}" spawnado com sucesso.')
end

local function actionKick(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local reason = sanitizeText(payload.reason, 180, S('kick_default_reason', nil, 'Removido pela administracao.'))
    pushAction(adminSource, 'kick', parsedTarget, reason)
    DropPlayer(parsedTarget, S('kick_drop_message', {
        panelTitle = Config.Ui.title,
        reason = reason
    }, '[{panelTitle}] Voce foi removido por Administrador.\nMotivo: {reason}'))

    return true, S('kick_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce removeu {targetName} [{targetSource}] do servidor.')
end

local function persistCharacterRename(citizenid, charinfo)
    local encodedCharinfo = json.encode(charinfo)
    local affectedRows = MySQL.update.await('UPDATE players SET charinfo = ? WHERE citizenid = ?', {
        encodedCharinfo,
        citizenid
    })

    local persistedRow = MySQL.single.await('SELECT charinfo FROM players WHERE citizenid = ?', { citizenid })
    local persistedCharinfo = persistedRow and persistedRow.charinfo and json.decode(persistedRow.charinfo) or {}
    local persistedFirst = sanitizeText(persistedCharinfo and (persistedCharinfo.firstname or persistedCharinfo.firstName), 48, '')
    local persistedLast = sanitizeText(persistedCharinfo and (persistedCharinfo.lastname or persistedCharinfo.lastName), 48, '')
    local expectedFirst = sanitizeText(charinfo.firstname or charinfo.firstName, 48, '')
    local expectedLast = sanitizeText(charinfo.lastname or charinfo.lastName, 48, '')

    if type(affectedRows) ~= 'number' or affectedRows < 1 then
        return false, affectedRows, persistedRow
    end

    if persistedFirst ~= expectedFirst or persistedLast ~= expectedLast then
        return false, affectedRows, persistedRow
    end

    return true, affectedRows, persistedRow
end

local function normalizeHeightValue(value)
    local parsed = tonumber(value)
    if not parsed then
        return nil
    end

    if parsed <= 0 then
        return nil
    end

    return math.floor((parsed * 10) + 0.5) / 10
end

local function formatHeightValue(value)
    local normalized = normalizeHeightValue(value)
    if not normalized then
        return '0'
    end

    if math.abs(normalized - math.floor(normalized)) < 0.001 then
        return tostring(math.floor(normalized))
    end

    return ('%.1f'):format(normalized)
end

local function persistCharacterHeight(citizenid, height)
    local skinRow = MySQL.single.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    if not skinRow then
        return false, 'missing'
    end

    local skin = skinRow.skin and json.decode(skinRow.skin) or {}
    if type(skin) ~= 'table' then
        skin = {}
    end

    local currentHeight = normalizeHeightValue(skin.height)
    if currentHeight and math.abs(currentHeight - height) < 0.001 then
        return false, 'same', currentHeight
    end

    skin.height = height

    local affectedRows = MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ?', {
        json.encode(skin),
        citizenid
    })

    local persistedRow = MySQL.single.await('SELECT skin FROM playerskins WHERE citizenid = ?', { citizenid })
    local persistedSkin = persistedRow and persistedRow.skin and json.decode(persistedRow.skin) or {}
    local persistedHeight = normalizeHeightValue(persistedSkin and persistedSkin.height)

    if type(affectedRows) ~= 'number' or affectedRows < 1 or not persistedHeight or math.abs(persistedHeight - height) >= 0.001 then
        return false, 'update', currentHeight
    end

    return true, currentHeight
end

local function actionRenameCharacter(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if type(MySQL) ~= 'table' then
        return false, S('mysql_unavailable', nil, 'OxMySQL nao disponivel para registrar alteracoes no banco.')
    end

    local playerData = player.PlayerData or {}
    local citizenid = sanitizeText(playerData.citizenid, 64, '')
    if citizenid == '' then
        return false, S('rename_player_citizenid_missing', nil, 'CitizenID indisponivel para trocar o nome do personagem.')
    end

    local firstName = sanitizeText(payload.firstName, 48, '')
    local lastName = sanitizeText(payload.lastName, 48, '')
    if firstName == '' then
        return false, S('rename_player_first_invalid', nil, 'Informe um nome valido.')
    end
    if lastName == '' then
        return false, S('rename_player_last_invalid', nil, 'Informe um sobrenome valido.')
    end

    local charinfo = type(playerData.charinfo) == 'table' and playerData.charinfo or {}
    local currentFirst = sanitizeText(charinfo.firstname or charinfo.firstName, 48, '')
    local currentLast = sanitizeText(charinfo.lastname or charinfo.lastName, 48, '')
    if currentFirst == firstName and currentLast == lastName then
        return false, S('rename_player_same_name', nil, 'O jogador ja esta com este nome e sobrenome.')
    end

    charinfo.firstname = firstName
    charinfo.lastname = lastName
    charinfo.firstName = nil
    charinfo.lastName = nil
    local oldFullName = (currentFirst .. ' ' .. currentLast):gsub('^%s+', ''):gsub('%s+$', '')
    local newFullName = (firstName .. ' ' .. lastName):gsub('^%s+', ''):gsub('%s+$', '')
    player.PlayerData.charinfo = charinfo

    local persisted = persistCharacterRename(citizenid, charinfo)
    if not persisted then
        return false, S('rename_player_update_fail', nil, 'Falha ao atualizar o nome do personagem no banco de dados.')
    end

    pushAction(adminSource, 'renameCharacter', parsedTarget, ('%s -> %s'):format(oldFullName ~= '' and oldFullName or '-', newFullName))
    notifyTargetAction(parsedTarget, adminSource, S('rename_player_target_notify', {
        fullName = newFullName,
        seconds = 5
    }, 'Seu personagem foi renomeado para {fullName}. Voce sera removido em {seconds} segundos e precisara relogar.'), 'warn')

    CreateThread(function()
        Wait(5000)
        local stillOnline = getPlayerObject(parsedTarget)
        if not stillOnline then
            return
        end

        DropPlayer(parsedTarget, S('rename_player_drop_message', {
            fullName = newFullName
        }, 'Seu personagem foi renomeado para {fullName}. Entre novamente para aplicar a alteracao.'))

        Wait(1500)
        persistCharacterRename(citizenid, charinfo)
    end)

    return true, S('rename_player_success', {
        targetSource = parsedTarget,
        fullName = newFullName
    }, 'Nome do jogador [{targetSource}] alterado para {fullName}. O jogador sera removido em 5 segundos para relogar.')
end

local function actionChangeHeight(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if type(MySQL) ~= 'table' then
        return false, S('mysql_unavailable', nil, 'OxMySQL nao disponivel para registrar alteracoes no banco.')
    end

    local playerData = player.PlayerData or {}
    local citizenid = sanitizeText(playerData.citizenid, 64, '')
    if citizenid == '' then
        return false, S('change_height_citizenid_missing', nil, 'CitizenID indisponivel para trocar a altura do personagem.')
    end

    local heightValue = normalizeHeightValue(payload.height)
    if not heightValue then
        return false, S('change_height_invalid', nil, 'Informe uma altura valida maior que zero.')
    end

    local persisted, reason, previousHeight = persistCharacterHeight(citizenid, heightValue)
    if not persisted then
        if reason == 'missing' then
            return false, S('change_height_skin_missing', nil, 'Nenhum registro de aparencia foi encontrado para este personagem.')
        end
        if reason == 'same' then
            return false, S('change_height_same', {
                height = formatHeightValue(heightValue)
            }, 'O personagem ja esta com a altura {height}.')
        end
        return false, S('change_height_update_fail', nil, 'Falha ao atualizar a altura do personagem no banco de dados.')
    end

    local formattedHeight = formatHeightValue(heightValue)
    local previousHeightLabel = previousHeight and formatHeightValue(previousHeight) or '-'
    pushAction(adminSource, 'changeHeight', parsedTarget, ('%s -> %s'):format(previousHeightLabel, formattedHeight))
    notifyTargetAction(parsedTarget, adminSource, S('change_height_target_notify', {
        height = formattedHeight,
        seconds = 5
    }, 'A altura do seu personagem foi alterada para {height}. Voce sera removido em {seconds} segundos e precisara relogar.'), 'warn')

    CreateThread(function()
        Wait(5000)
        local stillOnline = getPlayerObject(parsedTarget)
        if not stillOnline then
            return
        end

        DropPlayer(parsedTarget, S('change_height_drop_message', {
            height = formattedHeight
        }, 'A altura do seu personagem foi alterada para {height}. Entre novamente para aplicar a alteracao.'))

        Wait(1500)
        persistCharacterHeight(citizenid, heightValue)
    end)

    return true, S('change_height_success', {
        targetSource = parsedTarget,
        height = formattedHeight
    }, 'Altura do jogador [{targetSource}] alterada para {height}. O jogador sera removido em 5 segundos para relogar.')
end

local function actionClearInventory(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if GetResourceState('rsg-inventory') == 'missing' then
        return false, S('clear_inventory_unavailable', nil, 'rsg-inventory indisponivel para limpar o inventario.')
    end

    exports['rsg-inventory']:ClearInventory(parsedTarget)
    if player.Functions and type(player.Functions.Save) == 'function' then
        player.Functions.Save()
    end

    notifyTargetAction(parsedTarget, adminSource, S('clear_inventory_target_notify', nil, 'Seu inventario foi limpo por um administrador.'), 'warn')
    pushAction(adminSource, 'clearInventory', parsedTarget, 'inventory cleared')
    return true, S('clear_inventory_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce limpou o inventario de {targetName} [{targetSource}].')
end

local function actionPrivateMessage(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local message = sanitizeText(payload.message, 300, '')
    if message == '' then
        return false, S('private_message_empty', nil, 'Digite uma mensagem antes de enviar.')
    end

    TriggerClientEvent('bilto_admin:client:receiveStaffMessage', parsedTarget, {
        staff = getCharacterNameSafe(adminSource, S('admin_actor_label', nil, 'Administrador')),
        message = message,
        duration = Config.PrivateMessageDuration
    })

    pushAction(adminSource, 'privateMessage', parsedTarget, message)
    return true, S('private_message_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce enviou uma mensagem para {targetName} [{targetSource}].')
end

local function actionBanPlayer(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    if type(MySQL) ~= 'table' then
        return false, S('mysql_unavailable', nil, 'OxMySQL nao disponivel para registrar banimento.')
    end

    local banMode = resolveBanMode(payload.banMode)
    if not banMode then
        return false, S('ban_mode_invalid', nil, 'Modo de banimento invalido.')
    end

    local reason = sanitizeText(payload.reason, 220, sanitizeText(Config.Ban and Config.Ban.defaultReason, 220, 'Banido pela administracao.'))
    local expiresAt, expiresErr = buildBanExpiration(banMode, payload.banAmount)
    if not expiresAt then
        return false, expiresErr
    end

    local license = getIdentifierSafe(parsedTarget, 'license')
    if license == '' then
        license = getIdentifierSafe(parsedTarget, 'license2')
    end
    if license == '' and player and player.PlayerData then
        license = sanitizeText(player.PlayerData.license, 120, '')
    end
    if license ~= '' then
        local normalizedLicense = normalizeLicense(license)
        if normalizedLicense ~= '' and normalizedLicense == license then
            license = ('license:%s'):format(normalizedLicense)
        end
    end
    if license == '' then
        return false, S('license_missing', nil, 'Nao foi possivel identificar a license do jogador.')
    end

    local discord = getIdentifierSafe(parsedTarget, 'discord')
    local ip = getIdentifierSafe(parsedTarget, 'ip')
    local targetName = getCharacterNameSafe(parsedTarget)
    local adminName = getCharacterNameSafe(adminSource, S('admin_actor_label', nil, 'Administrador'))

    local insertId = MySQL.insert.await('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        targetName,
        license,
        discord,
        ip,
        reason,
        expiresAt,
        adminName
    })

    if not insertId then
        return false, S('ban_db_insert_fail', nil, 'Falha ao registrar banimento no banco de dados.')
    end

    local expiresLabel = formatBanExpiration(expiresAt)
    pushAction(adminSource, 'banPlayer', parsedTarget, ('%s | %s'):format(expiresLabel, reason))

    local dropMessage = S('ban_drop_message', {
        panelTitle = Config.Ui.title,
        expiresLabel = expiresLabel,
        reason = reason
    }, '[{panelTitle}] Voce foi banido por Administrador.\nDuracao: {expiresLabel}.\nMotivo: {reason}')
    DropPlayer(parsedTarget, dropMessage)

    return true, S('ban_success', {
        targetName = targetName,
        targetSource = parsedTarget,
        expiresLabel = expiresLabel
    }, 'Voce baniu {targetName} [{targetSource}] ({expiresLabel}).')
end

local function actionEditBan(adminSource, payload)
    if type(MySQL) ~= 'table' then
        return false, S('mysql_unavailable', nil, 'OxMySQL nao disponivel para registrar banimento.')
    end

    local banId, banErr = parseBanId(payload and payload.banId)
    if not banId then
        return false, banErr
    end

    local banRow = MySQL.single.await('SELECT id, name, expire FROM bans WHERE id = ?', { banId })
    if not banRow then
        return false, S('ban_not_found', nil, 'Banimento nao encontrado.')
    end

    local banMode = resolveBanMode(payload and payload.banMode)
    if not banMode then
        return false, S('ban_mode_invalid', nil, 'Modo de banimento invalido.')
    end

    local newExpire, expireErr = buildBanEditedExpiration(banRow.expire, banMode, payload and payload.banAmount)
    if not newExpire then
        return false, expireErr
    end

    local affectedRows = MySQL.update.await('UPDATE bans SET expire = ? WHERE id = ?', { newExpire, banId }) or 0
    if affectedRows < 1 then
        return false, S('ban_update_fail', nil, 'Falha ao atualizar banimento.')
    end

    local targetName = sanitizeText(banRow.name, 96, 'N/A')
    local expiresLabel = formatBanExpiration(newExpire)
    pushAction(adminSource, 'editBan', nil, ('ID %s -> %s'):format(banId, expiresLabel))

    return true, S('ban_edit_success', {
        targetName = targetName,
        banId = banId,
        expiresLabel = expiresLabel
    }, 'Voce atualizou o banimento de {targetName} (ID {banId}) para {expiresLabel}.')
end

local function actionRemoveBan(adminSource, payload)
    if type(MySQL) ~= 'table' then
        return false, S('mysql_unavailable', nil, 'OxMySQL nao disponivel para registrar banimento.')
    end

    local banId, banErr = parseBanId(payload and payload.banId)
    if not banId then
        return false, banErr
    end

    local banRow = MySQL.single.await('SELECT id, name FROM bans WHERE id = ?', { banId })
    if not banRow then
        return false, S('ban_not_found', nil, 'Banimento nao encontrado.')
    end

    local affectedRows = MySQL.update.await('DELETE FROM bans WHERE id = ?', { banId }) or 0
    if affectedRows < 1 then
        return false, S('ban_remove_fail', nil, 'Falha ao remover banimento.')
    end

    local targetName = sanitizeText(banRow.name, 96, 'N/A')
    pushAction(adminSource, 'removeBan', nil, ('ID %s'):format(banId))

    return true, S('ban_remove_success', {
        targetName = targetName,
        banId = banId
    }, 'Voce removeu o banimento de {targetName} (ID {banId}).')
end

fetchStoredMultijobEntries = function(citizenid)
    local normalizedCitizenId = sanitizeText(citizenid, 64, '')
    if normalizedCitizenId == '' then
        return {}
    end

    if GetResourceState('rsg-multijob') ~= 'started' then
        return {}
    end

    local ok, entries = pcall(function()
        return exports['rsg-multijob']:GetPlayerJobs(normalizedCitizenId)
    end)
    if ok and type(entries) == 'table' then
        return entries
    end

    return {}
end

local function persistMultijobEntry(citizenid, jobName, grade)
    local normalizedCitizenId = sanitizeText(citizenid, 64, '')
    local normalizedJobName = sanitizeText(jobName, 42, ''):lower()
    local normalizedGrade = math.floor(tonumber(grade) or 0)
    if normalizedCitizenId == '' or normalizedJobName == '' or normalizedJobName == 'unemployed' then
        return true
    end

    if GetResourceState('rsg-multijob') ~= 'started' then
        return false
    end

    local ok, result = pcall(function()
        return exports['rsg-multijob']:AddJobToPlayer(normalizedCitizenId, normalizedJobName, normalizedGrade)
    end)
    return ok and result == true
end

local function removePersistedMultijobEntry(citizenid, jobName)
    local normalizedCitizenId = sanitizeText(citizenid, 64, '')
    local normalizedJobName = sanitizeText(jobName, 42, ''):lower()
    if normalizedCitizenId == '' or normalizedJobName == '' then
        return false
    end

    if GetResourceState('rsg-multijob') ~= 'started' then
        return false
    end

    local ok, result = pcall(function()
        return exports['rsg-multijob']:RemoveJobFromPlayer(normalizedCitizenId, normalizedJobName)
    end)
    return ok and result == true
end

local function resolveFallbackJobAfterRemoval(citizenid, removedJobName, defaultJobName, defaultGrade)
    local normalizedRemovedJob = sanitizeText(removedJobName, 42, ''):lower()
    local fallbackJobName = sanitizeText(defaultJobName, 42, 'unemployed'):lower()
    local fallbackGrade = math.floor(tonumber(defaultGrade) or 0)
    local entries = fetchStoredMultijobEntries(citizenid)

    for _, entry in ipairs(entries) do
        local entryJobName = sanitizeText(entry and entry.job, 42, sanitizeText(entry and entry.name, 42, '')):lower()
        local entryGrade = math.floor(tonumber(entry and entry.grade) or 0)
        local jobData = RSGCore.Shared.Jobs and RSGCore.Shared.Jobs[entryJobName] or nil
        if entryJobName ~= '' and entryJobName ~= normalizedRemovedJob and jobData and type(jobData.grades) == 'table' and jobData.grades[tostring(entryGrade)] then
            return entryJobName, entryGrade
        end
    end

    return fallbackJobName, fallbackGrade
end

local function actionSetJob(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    debugLogSetJobAttempt(adminSource, parsedTarget, player, payload)

    local setJobHandler, setJobErr = requirePlayerFunction(player, 'SetJob')
    if not setJobHandler then
        debugLogMissingPlayerHandler('SetJob', parsedTarget, player)
        return false, S('setjob_unavailable', { error = setJobErr or 'erro' }, 'SetJob indisponivel para este player ({error}).')
    end

    local jobName = sanitizeText(payload.jobName, 42, ''):lower()
    if jobName == '' then
        return false, S('setjob_invalid_job', nil, 'Selecione um job valido.')
    end

    local jobData = RSGCore.Shared.Jobs[jobName]
    if not jobData then
        return false, S('setjob_job_not_found', nil, 'Job nao encontrado no core.')
    end

    local requestedGrade = tonumber(payload.grade) or 0
    local gradeKey = tostring(math.floor(requestedGrade))
    if not jobData.grades or not jobData.grades[gradeKey] then
        if jobData.grades and jobData.grades['0'] then
            gradeKey = '0'
        else
            return false, S('setjob_invalid_grade', nil, 'Grade invalida para o job selecionado.')
        end
    end

    local playerData = player and player.PlayerData or {}
    local citizenid = sanitizeText(playerData and playerData.citizenid, 64, '')
    local currentJobName = sanitizeText(playerData and playerData.job and playerData.job.name, 42, ''):lower()
    if citizenid ~= '' and not persistMultijobEntry(citizenid, jobName, tonumber(gradeKey)) then
        if currentJobName ~= '' and currentJobName ~= jobName then
            removePersistedMultijobEntry(citizenid, currentJobName)
        end
        persistMultijobEntry(citizenid, jobName, tonumber(gradeKey))
    end

    local success = setJobHandler(jobName, tonumber(gradeKey))
    if not success then
        return false, S('setjob_apply_fail', nil, 'Falha ao atualizar job do jogador.')
    end

    local gradeLabel = jobData.grades and jobData.grades[gradeKey] and jobData.grades[gradeKey].name or ('Grade %s'):format(gradeKey)
    local jobLabel = sanitizeText(jobData.label, 64, jobName)
    local gradeLabelSafe = sanitizeText(gradeLabel, 64, gradeKey)
    notifyTargetAction(parsedTarget, adminSource, S('setjob_target_notify', {
        jobLabel = jobLabel,
        gradeLabel = gradeLabelSafe
    }, 'Seu job foi alterado para {jobLabel} ({gradeLabel}) por um administrador.'), 'info')
    pushAction(adminSource, 'setJob', parsedTarget, ('%s grade %s'):format(jobName, gradeKey))
    return true, S('setjob_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget,
        jobLabel = jobLabel,
        gradeLabel = gradeLabelSafe
    }, 'Voce definiu o job de {targetName} [{targetSource}] para {jobLabel} ({gradeLabel}).')
end

local function actionUpsertMultijobJob(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload and payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local playerData = player and player.PlayerData or {}
    local citizenid = sanitizeText(playerData and playerData.citizenid, 64, '')
    if citizenid == '' then
        return false, S('multijob_citizenid_missing', nil, 'CitizenID indisponivel para editar multijob.')
    end

    local jobName = sanitizeText(payload and payload.jobName, 42, ''):lower()
    if jobName == '' then
        return false, S('setjob_invalid_job', nil, 'Selecione um job valido.')
    end

    local jobData = RSGCore.Shared.Jobs[jobName]
    if not jobData or type(jobData.grades) ~= 'table' then
        return false, S('setjob_job_not_found', nil, 'Job nao encontrado no core.')
    end

    local requestedGrade = tonumber(payload and payload.grade) or 0
    local gradeKey = tostring(math.floor(requestedGrade))
    if not jobData.grades[gradeKey] then
        return false, S('setjob_invalid_grade', nil, 'Grade invalida para o job selecionado.')
    end

    if not persistMultijobEntry(citizenid, jobName, tonumber(gradeKey)) then
        return false, S('multijob_upsert_fail', nil, 'Falha ao salvar job na multijob (limite ou erro interno).')
    end

    local setActive = payload and payload.setActive == true
    if setActive then
        debugLogSetJobAttempt(adminSource, parsedTarget, player, payload)
        local setJobHandler, setJobErr = requirePlayerFunction(player, 'SetJob')
        if not setJobHandler then
            debugLogMissingPlayerHandler('SetJob', parsedTarget, player)
            return false, S('setjob_unavailable', { error = setJobErr or 'erro' }, 'SetJob indisponivel para este player ({error}).')
        end

        local switched = setJobHandler(jobName, tonumber(gradeKey))
        if not switched then
            return false, S('setjob_apply_fail', nil, 'Falha ao atualizar job do jogador.')
        end
    end

    local gradeLabel = sanitizeText(jobData.grades[gradeKey] and jobData.grades[gradeKey].name, 64, gradeKey)
    local jobLabel = sanitizeText(jobData.label, 64, jobName)
    notifyTargetAction(parsedTarget, adminSource, S('multijob_upsert_target_notify', {
        jobLabel = jobLabel,
        gradeLabel = gradeLabel
    }, 'Seu multijob foi atualizado para {jobLabel} ({gradeLabel}) por um administrador.'), 'info')
    pushAction(adminSource, 'upsertMultijobJob', parsedTarget, ('%s grade %s active=%s'):format(jobName, gradeKey, setActive and '1' or '0'))

    return true, S('multijob_upsert_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget,
        jobLabel = jobLabel,
        gradeLabel = gradeLabel
    }, 'Multijob de {targetName} [{targetSource}] atualizado para {jobLabel} ({gradeLabel}).')
end

local function actionRemoveJob(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local configuredTarget = Config.Jobs and Config.Jobs.removeJobTarget or {}
    local targetJob = sanitizeText(configuredTarget and configuredTarget.name, 42, 'unemployed'):lower()
    local targetGrade = math.floor(tonumber(configuredTarget and configuredTarget.grade) or 0)
    local sharedJobs = RSGCore.Shared.Jobs or {}
    local targetJobData = sharedJobs[targetJob]
    if not targetJobData or type(targetJobData.grades) ~= 'table' then
        return false, S('removejob_no_fallback', nil, 'Nao existe job padrao para remocao.')
    end

    local gradeKey = tostring(targetGrade)
    if not targetJobData.grades[gradeKey] then
        return false, S('setjob_invalid_grade', nil, 'Grade invalida para o job selecionado.')
    end

    local payloadJobName = sanitizeText(payload.jobName, 42, ''):lower()
    local playerData = player and player.PlayerData or {}
    local citizenid = sanitizeText(playerData and playerData.citizenid, 64, '')
    local currentJobName = sanitizeText(playerData and playerData.job and playerData.job.name, 42, ''):lower()
    local setJobHandler, setJobErr = requirePlayerFunction(player, 'SetJob')
    if not setJobHandler then
        debugLogMissingPlayerHandler('SetJob', parsedTarget, player)
        return false, S('setjob_unavailable', { error = setJobErr or 'erro' }, 'SetJob indisponivel para este player ({error}).')
    end

    if payloadJobName ~= '' then
        local removedFromStorage = citizenid ~= '' and removePersistedMultijobEntry(citizenid, payloadJobName) or false
        if not removedFromStorage and payloadJobName ~= currentJobName then
            return false, S('removejob_job_not_found', { jobName = payloadJobName }, 'Este jogador nao possui o job {jobName}.')
        end

        if payloadJobName == currentJobName then
            local nextJob, nextGrade = resolveFallbackJobAfterRemoval(citizenid, payloadJobName, targetJob, targetGrade)
            local switched = setJobHandler(nextJob, nextGrade)
            if not switched then
                return false, S('removejob_apply_fail', nil, 'Falha ao remover job do jogador.')
            end

            targetJob = nextJob
            targetGrade = nextGrade
            gradeKey = tostring(nextGrade)
        end

        notifyTargetAction(parsedTarget, adminSource, S('removejob_target_notify', {
            jobName = targetJob
        }, 'Seu job foi removido por um administrador. Novo job: {jobName}.'), 'warn')
        pushAction(adminSource, 'removeJob', parsedTarget, ('removed %s -> fallback %s [%s]'):format(payloadJobName, targetJob, gradeKey))
        return true, S('removejob_specific_success', {
            targetName = getCharacterNameSafe(parsedTarget),
            targetSource = parsedTarget,
            removedJob = payloadJobName
        }, 'Voce removeu o job {removedJob} de {targetName} [{targetSource}].')
    end

    if currentJobName ~= '' and currentJobName ~= targetJob and citizenid ~= '' then
        removePersistedMultijobEntry(citizenid, currentJobName)
    end

    local success = setJobHandler(targetJob, targetGrade)
    if not success then
        return false, S('removejob_apply_fail', nil, 'Falha ao remover job do jogador.')
    end

    notifyTargetAction(parsedTarget, adminSource, S('removejob_target_notify', {
        jobName = targetJob
    }, 'Seu job foi removido por um administrador. Novo job: {jobName}.'), 'warn')
    pushAction(adminSource, 'removeJob', parsedTarget, ('job reset -> %s [%s]'):format(targetJob, gradeKey))
    return true, S('removejob_success', {
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget,
        jobName = targetJob
    }, 'Voce removeu o job de {targetName} [{targetSource}]. Novo job: {jobName}.')
end

local function actionAddItem(adminSource, payload)
    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local itemName = sanitizeText(payload.itemName, 64, ''):lower()
    if itemName == '' then
        return false, S('additem_invalid_item', nil, 'Selecione um item valido.')
    end

    if not RSGCore.Shared.Items[itemName] then
        return false, S('additem_not_found', nil, 'Item nao encontrado no core.')
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('additem_amount_min', nil, 'Quantidade deve ser maior que zero.')
    end

    local maxItemAmount = math.floor(tonumber(Config.Limits and Config.Limits.addItemAmountMax) or 1000)
    if amount > maxItemAmount then
        return false, S('additem_amount_max', { maxAmount = maxItemAmount }, 'Quantidade maxima por envio: {maxAmount}.')
    end

    local canAdd, canAddReason = exports['rsg-inventory']:CanAddItem(parsedTarget, itemName, amount)
    if canAdd ~= true then
        if canAddReason == 'slots' then
            return false, S('additem_no_slots', nil, 'Jogador sem slot livre no inventario.')
        end

        local player = getPlayerObject(parsedTarget)
        local playerData = player and player.PlayerData or {}
        local capacity = getInventoryCapacitySnapshot(playerData)
        local itemWeight = tonumber(RSGCore.Shared.Items[itemName].weight) or 0
        local requiredWeight = round(itemWeight * amount, 2)
        return false, S('additem_no_weight', {
            required = ('%.2f'):format(requiredWeight / 1000.0),
            free = ('%.2f'):format(capacity.freeWeight / 1000.0)
        }, 'Jogador sem KG suficiente. Necessario: {required} KG | Livre: {free} KG.')
    end

    local success = exports['rsg-inventory']:AddItem(parsedTarget, itemName, amount, nil, nil, 'bilto_admin:additem')
    if not success then
        return false, S('additem_add_fail', nil, 'Falha ao adicionar item (inventario cheio ou bloqueado).')
    end

    local itemLabel = sanitizeText(RSGCore.Shared.Items[itemName].label, 64, itemName)
    notifyTargetAction(parsedTarget, adminSource, S('additem_target_notify', {
        amount = amount,
        itemLabel = itemLabel
    }, 'Voce recebeu {amount}x {itemLabel} de um administrador.'), 'ok')
    if payload._suppressActionLog ~= true then
        pushAction(adminSource, 'addItem', parsedTarget, ('Item adicionado:\n• %s\nQuantidade: %s'):format(itemLabel, amount))
    end
    return true, S('additem_success', {
        amount = amount,
        itemLabel = itemLabel,
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce adicionou {amount}x {itemLabel} para {targetName} [{targetSource}].')
end

local function actionCheckItemCapacity(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local items = type(payload.items) == 'table' and payload.items or {}
    if #items == 0 then
        return false, S('capacity_add_at_least_one', nil, 'Adicione pelo menos um item na lista para validar capacidade.')
    end

    local requiredWeight = 0
    local itemLines = {}
    local maxListAmount = math.floor(tonumber(Config.Limits and Config.Limits.checkItemAmountMax) or 1000)
    for _, entry in ipairs(items) do
        local itemName = sanitizeText(entry.itemName or entry.name, 64, ''):lower()
        local amount = math.floor(tonumber(entry.amount) or 0)
        if itemName == '' or amount <= 0 then
            return false, S('capacity_invalid_list', nil, 'Lista de itens invalida.')
        end
        if amount > maxListAmount then
            return false, S('capacity_item_amount_max', { maxAmount = maxListAmount }, 'Quantidade maxima por item na lista: {maxAmount}.')
        end

        local itemData = RSGCore.Shared.Items[itemName]
        if not itemData then
            return false, S('capacity_invalid_item_in_list', { itemName = itemName }, 'Item invalido na lista: {itemName}')
        end

        requiredWeight = requiredWeight + ((tonumber(itemData.weight) or 0) * amount)
        itemLines[#itemLines + 1] = ('• %s - %sx'):format(sanitizeText(itemData.label, 64, itemName), amount)
    end

    local capacity = getInventoryCapacitySnapshot(player.PlayerData)
    local hasEnough = capacity.freeWeight >= requiredWeight
    local resultData = {
        maxWeight = capacity.maxWeight,
        usedWeight = capacity.usedWeight,
        freeWeight = capacity.freeWeight,
        requiredWeight = round(requiredWeight, 2),
        remainingWeight = round(math.max(capacity.freeWeight - requiredWeight, 0), 2),
        hasEnough = hasEnough
    }

    if not hasEnough then
        return false, S('capacity_not_enough', {
            required = ('%.2f'):format(resultData.requiredWeight / 1000.0),
            free = ('%.2f'):format(resultData.freeWeight / 1000.0)
        }, 'Jogador sem KG suficiente. Necessario: {required} KG | Livre: {free} KG.'), resultData
    end

    pushAction(adminSource, 'checkItemCapacity', parsedTarget, ('Itens verificados:\n%s\nPeso necessario: %s'):format(
        table.concat(itemLines, '\n'),
        resultData.requiredWeight
    ))
    return true, S('capacity_enough', nil, 'Jogador possui KG suficiente para receber os itens.'), resultData
end

function BitinhoAdmin.actionAddItems(adminSource, payload)
    local items = type(payload and payload.items) == 'table' and payload.items or nil
    if not items then
        return actionAddItem(adminSource, payload)
    end

    if #items == 0 then
        return false, S('additem_invalid_item', nil, 'Selecione um item valido.')
    end

    local parsedTarget, _, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local itemLines = {}
    for _, item in ipairs(items) do
        local itemName = sanitizeText(item and (item.itemName or item.name), 64, ''):lower()
        local amount = math.floor(tonumber(item and item.amount) or 0)
        local ok, message = actionAddItem(adminSource, {
            targetSource = parsedTarget,
            itemName = itemName,
            amount = amount,
            _suppressActionLog = true
        })

        if not ok then
            if #itemLines > 0 then
                pushAction(adminSource, 'addItem', parsedTarget, ('Itens adicionados parcialmente:\n%s'):format(table.concat(itemLines, '\n')))
            end
            return false, message
        end

        local itemData = RSGCore.Shared.Items[itemName] or {}
        local itemLabel = sanitizeText(itemData.label, 64, itemName)
        itemLines[#itemLines + 1] = ('• %s - Quantidade: %s'):format(itemLabel, amount)
    end

    pushAction(adminSource, 'addItem', parsedTarget, ('Itens adicionados:\n%s'):format(table.concat(itemLines, '\n')))
    return true, S('additem_success', {
        amount = #items,
        itemLabel = 'itens',
        targetName = getCharacterNameSafe(parsedTarget),
        targetSource = parsedTarget
    }, 'Voce adicionou {amount}x {itemLabel} para {targetName} [{targetSource}].')
end

local function resolveMoneyType(moneyTypeRaw)
    local moneyType = sanitizeText(moneyTypeRaw, 32, ''):lower()
    if moneyType == '' then
        return nil
    end

    local configured = type(Config.MoneyTypes) == 'table' and Config.MoneyTypes or {}
    if #configured == 0 then
        configured = type(Config.Money) == 'table' and type(Config.Money.types) == 'table' and Config.Money.types or {}
    end

    for _, entry in ipairs(configured) do
        local key = sanitizeText(entry.value, 32, sanitizeText(entry.key, 32, '')):lower()
        if key == moneyType then
            return moneyType
        end
    end

    return nil
end

local function ensureMoneyTypeEntry(player, moneyType)
    if type(player) ~= 'table' or type(player.PlayerData) ~= 'table' then
        return false, 'playerdata_invalido'
    end

    if type(player.PlayerData.money) ~= 'table' then
        player.PlayerData.money = {}
    end

    if player.PlayerData.money[moneyType] == nil then
        player.PlayerData.money[moneyType] = 0
    end

    return true, nil
end

local function actionAddMoney(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local addMoneyHandler, addMoneyErr = requirePlayerFunction(player, 'AddMoney')
    if not addMoneyHandler then
        return false, S('addmoney_unavailable', { error = addMoneyErr or 'erro' }, 'AddMoney indisponivel para este player ({error}).')
    end

    local moneyType = resolveMoneyType(payload.moneyType)
    if not moneyType then
        return false, S('money_invalid_type', nil, 'Tipo de dinheiro invalido.')
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('money_amount_min', nil, 'Valor deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.moneyActionMax) or 100000000)
    if amount > maxAmount then
        return false, S('money_add_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo por envio: {maxAmount}.')
    end

    local moneyReady, moneyReadyErr = ensureMoneyTypeEntry(player, moneyType)
    if not moneyReady then
        return false, S('money_wallet_prepare_fail', { error = moneyReadyErr or 'erro' }, 'Falha ao preparar carteira do player ({error}).')
    end

    local success = addMoneyHandler(moneyType, amount, 'bilto_admin:addmoney')
    if not success then
        local currentBalance = tonumber(player.PlayerData.money[moneyType]) or 0
        return false, S('money_add_fail', {
            moneyType = moneyType,
            currentBalance = currentBalance
        }, 'Falha ao adicionar dinheiro no tipo {moneyType} (saldo atual: {currentBalance}).')
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('addmoney_target_notify', {
        amount = amount,
        moneyType = moneyType
    }, 'Voce recebeu ${amount} em {moneyType} de um administrador.'), 'ok')
    clearGlobalMoneyCache()
    BitinhoAdmin.ClearTopRichPlayersCache()
    pushAction(adminSource, 'addMoney', parsedTarget, ('%s +%s'):format(moneyType, amount))
    return true, S('addmoney_success', {
        amount = amount,
        targetName = targetName,
        targetSource = parsedTarget,
        moneyType = moneyType
    }, 'Voce adicionou ${amount} para {targetName} [{targetSource}] em {moneyType}.')
end

local function actionRemoveMoney(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local removeMoneyHandler, removeMoneyErr = requirePlayerFunction(player, 'RemoveMoney')
    if not removeMoneyHandler then
        return false, S('removemoney_unavailable', { error = removeMoneyErr or 'erro' }, 'RemoveMoney indisponivel para este player ({error}).')
    end

    local moneyType = resolveMoneyType(payload.moneyType)
    if not moneyType then
        return false, S('money_invalid_type', nil, 'Tipo de dinheiro invalido.')
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('money_amount_min', nil, 'Valor deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.moneyActionMax) or 100000000)
    if amount > maxAmount then
        return false, S('money_remove_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo por remocao: {maxAmount}.')
    end

    local moneyReady, moneyReadyErr = ensureMoneyTypeEntry(player, moneyType)
    if not moneyReady then
        return false, S('money_wallet_prepare_fail', { error = moneyReadyErr or 'erro' }, 'Falha ao preparar carteira do player ({error}).')
    end

    local success = removeMoneyHandler(moneyType, amount, 'bilto_admin:removemoney')
    if not success then
        local currentBalance = tonumber(player.PlayerData.money[moneyType]) or 0
        return false, S('money_remove_fail', {
            moneyType = moneyType,
            currentBalance = currentBalance
        }, 'Falha ao remover dinheiro em {moneyType} (saldo atual: {currentBalance}).')
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('removemoney_target_notify', {
        amount = amount,
        moneyType = moneyType
    }, 'Foi removido ${amount} em {moneyType} por um administrador.'), 'warn')
    clearGlobalMoneyCache()
    BitinhoAdmin.ClearTopRichPlayersCache()
    pushAction(adminSource, 'removeMoney', parsedTarget, ('%s -%s'):format(moneyType, amount))
    return true, S('removemoney_success', {
        amount = amount,
        targetName = targetName,
        targetSource = parsedTarget,
        moneyType = moneyType
    }, 'Voce removeu ${amount} de {targetName} [{targetSource}] em {moneyType}.')
end

local function actionAddWeight(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('weight_amount_min', nil, 'Valor de peso deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.addWeightAmountMax) or 100000000)
    if amount > maxAmount then
        return false, S('weight_add_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo de peso por envio: {maxAmount}.')
    end

    local currentWeight = math.floor(tonumber(player.PlayerData and player.PlayerData.weight) or 0)
    local newWeight = currentWeight + amount
    if newWeight <= 0 then
        return false, S('weight_result_invalid', nil, 'Peso final invalido para o jogador.')
    end

    RSGCore.Functions.ChangeWeight(parsedTarget, newWeight)
    if player.Functions and type(player.Functions.Save) == 'function' then
        player.Functions.Save()
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('addweight_target_notify', {
        amount = ('%.2f'):format(amount / 1000.0)
    }, 'Seu limite de peso foi aumentado em {amount} KG por um administrador.'), 'ok')
    pushAction(adminSource, 'addWeight', parsedTarget, ('+%s => %s'):format(amount, newWeight))
    return true, S('addweight_success', {
        amount = ('%.2f'):format(amount / 1000.0),
        total = ('%.2f'):format(newWeight / 1000.0),
        targetName = targetName,
        targetSource = parsedTarget
    }, 'Voce adicionou {amount} KG para {targetName} [{targetSource}]. Novo limite: {total} KG.')
end

local function actionAddSlots(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('slots_amount_min', nil, 'Valor de slots deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.addSlotsAmountMax) or 1000)
    if amount > maxAmount then
        return false, S('slots_add_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo de slots por envio: {maxAmount}.')
    end

    local currentSlots = math.floor(tonumber(player.PlayerData and player.PlayerData.slots) or 0)
    local newSlots = currentSlots + amount
    if newSlots <= 0 then
        return false, S('slots_result_invalid', nil, 'Quantidade final de slots invalida para o jogador.')
    end

    RSGCore.Functions.ChangeSlots(parsedTarget, newSlots)
    if player.Functions and type(player.Functions.Save) == 'function' then
        player.Functions.Save()
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('addslots_target_notify', {
        amount = amount
    }, 'Seus slots foram aumentados em {amount} por um administrador.'), 'ok')
    pushAction(adminSource, 'addSlots', parsedTarget, ('+%s => %s'):format(amount, newSlots))
    return true, S('addslots_success', {
        amount = amount,
        total = newSlots,
        targetName = targetName,
        targetSource = parsedTarget
    }, 'Voce adicionou {amount} slots para {targetName} [{targetSource}]. Novo limite: {total} slots.')
end

-- kept on BitinhoAdmin (not chunk-level locals) because the main chunk is at Lua's 200-local limit
function BitinhoAdmin.ActionRemoveWeight(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('weight_amount_min', nil, 'Valor de peso deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.addWeightAmountMax) or 100000000)
    if amount > maxAmount then
        return false, S('weight_remove_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo de peso por remocao: {maxAmount}.')
    end

    -- the new limit can't be lower than what the player is already carrying
    local capacity = getInventoryCapacitySnapshot(player.PlayerData)
    local currentWeight = math.floor(tonumber(player.PlayerData and player.PlayerData.weight) or 0)
    local newWeight = currentWeight - amount
    local minWeight = math.max(1, math.ceil(capacity.usedWeight))
    if newWeight < minWeight then
        return false, S('weight_remove_below_used', {
            used = ('%.2f'):format(capacity.usedWeight / 1000.0),
            maxRemove = ('%.2f'):format(math.max(currentWeight - minWeight, 0) / 1000.0)
        }, 'O jogador carrega {used} KG. Voce pode remover no maximo {maxRemove} KG.')
    end

    RSGCore.Functions.ChangeWeight(parsedTarget, newWeight)
    if player.Functions and type(player.Functions.Save) == 'function' then
        player.Functions.Save()
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('removeweight_target_notify', {
        amount = ('%.2f'):format(amount / 1000.0)
    }, 'Seu limite de peso foi reduzido em {amount} KG por um administrador.'), 'warn')
    pushAction(adminSource, 'removeWeight', parsedTarget, ('-%s => %s'):format(amount, newWeight))
    return true, S('removeweight_success', {
        amount = ('%.2f'):format(amount / 1000.0),
        total = ('%.2f'):format(newWeight / 1000.0),
        targetName = targetName,
        targetSource = parsedTarget
    }, 'Voce removeu {amount} KG de {targetName} [{targetSource}]. Novo limite: {total} KG.')
end

function BitinhoAdmin.ActionRemoveSlots(adminSource, payload)
    local parsedTarget, player, err = validateTarget(payload.targetSource)
    if not parsedTarget then
        return false, err
    end

    local amount = math.floor(tonumber(payload.amount) or 0)
    if amount <= 0 then
        return false, S('slots_amount_min', nil, 'Valor de slots deve ser maior que zero.')
    end

    local maxAmount = math.floor(tonumber(Config.Limits and Config.Limits.addSlotsAmountMax) or 1000)
    if amount > maxAmount then
        return false, S('slots_remove_amount_max', {
            maxAmount = maxAmount
        }, 'Valor maximo de slots por remocao: {maxAmount}.')
    end

    -- the new limit can't cut off a slot that still has an item in it
    local highestUsedSlot = 0
    for key, item in pairs(player.PlayerData and player.PlayerData.items or {}) do
        if type(item) == 'table' and (tonumber(item.amount) or 0) > 0 then
            local slot = math.floor(tonumber(item.slot) or tonumber(key) or 0)
            if slot > highestUsedSlot then
                highestUsedSlot = slot
            end
        end
    end

    local currentSlots = math.floor(tonumber(player.PlayerData and player.PlayerData.slots) or 0)
    local newSlots = currentSlots - amount
    local minSlots = math.max(1, highestUsedSlot)
    if newSlots < minSlots then
        return false, S('slots_remove_below_used', {
            slot = highestUsedSlot,
            maxRemove = math.max(currentSlots - minSlots, 0)
        }, 'O jogador tem item ate o slot {slot}. Voce pode remover no maximo {maxRemove} slots.')
    end

    RSGCore.Functions.ChangeSlots(parsedTarget, newSlots)
    if player.Functions and type(player.Functions.Save) == 'function' then
        player.Functions.Save()
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    notifyTargetAction(parsedTarget, adminSource, S('removeslots_target_notify', {
        amount = amount
    }, 'Seus slots foram reduzidos em {amount} por um administrador.'), 'warn')
    pushAction(adminSource, 'removeSlots', parsedTarget, ('-%s => %s'):format(amount, newSlots))
    return true, S('removeslots_success', {
        amount = amount,
        total = newSlots,
        targetName = targetName,
        targetSource = parsedTarget
    }, 'Voce removeu {amount} slots de {targetName} [{targetSource}]. Novo limite: {total} slots.')
end

local function parseRequestedPanelPermissions(rawPermissions)
    if type(rawPermissions) ~= 'table' then
        return nil, S('permission_payload_invalid', nil, 'Permissoes invalidas no payload.')
    end

    return normalizePanelPermissionSet(rawPermissions), nil
end

local function parseRequestedPermissionPresetKey(rawPresetKey)
    local presetKey = sanitizeText(rawPresetKey, 64, ''):lower():gsub('[^%w_]', '')
    if presetKey == '' then
        return ''
    end

    if not getPanelPermissionPresetByKey(presetKey) then
        return nil
    end

    return presetKey
end

local function upsertPanelPermissionEntry(citzenid, name, grantedBy, permissions, presetKey)
    local storageReady, storageErr = ensurePanelPermissionStorage()
    if not storageReady then
        return false, storageErr
    end

    local normalizedPresetKey = sanitizeText(presetKey, 64, ''):lower():gsub('[^%w_]', '')

    local affectedRows = MySQL.update.await(
        ('INSERT INTO `%s` (citzenid, name, granted_by, preset_key, permissions) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), granted_by = VALUES(granted_by), preset_key = VALUES(preset_key), permissions = VALUES(permissions)'):format(panelPermissionStore.tableName),
        {
            citzenid,
            sanitizeText(name, 96, 'N/A'),
            sanitizeText(grantedBy, 96, '-'),
            normalizedPresetKey,
            encodePanelPermissionSet(permissions)
        }
    ) or 0

    if affectedRows < 0 then
        return false, S('permission_save_fail', nil, 'Falha ao salvar permissoes do painel.')
    end

    panelPermissionStore.loaded = false
    local reloaded, reloadErr = reloadPanelPermissionStore()
    if not reloaded then
        return false, reloadErr or S('permission_reload_fail', nil, 'Falha ao recarregar permissoes do painel.')
    end

    return true, nil
end

local function actionPermissionAddPlayer(adminSource, payload)
    local parsedTarget, player, targetErr = validateTarget(payload and payload.targetSource)
    if not parsedTarget then
        return false, targetErr
    end

    local normalizedCitizenid = getSourceNormalizedCitizenid(parsedTarget)
    if normalizedCitizenid == '' and player and player.PlayerData then
        normalizedCitizenid = normalizeCitizenId(player.PlayerData.citizenid)
    end
    if normalizedCitizenid == '' then
        return false, S('permission_target_license_missing', nil, 'Nao foi possivel identificar a citizenid do jogador selecionado.')
    end

    local requestedPermissions, permissionErr = parseRequestedPanelPermissions(payload and payload.permissions)
    if not requestedPermissions then
        return false, permissionErr
    end

    local presetKey = parseRequestedPermissionPresetKey(payload and payload.presetKey)
    if presetKey == nil or presetKey == '' then
        return false, S('permission_preset_invalid', nil, 'Cargo de permissao invalido.')
    end

    local targetName = getCharacterNameSafe(parsedTarget)
    local fullName = getFullName(player and player.PlayerData or {})
    local saved, saveErr = upsertPanelPermissionEntry(
        normalizedCitizenid,
        sanitizeText(fullName, 96, targetName),
        getCharacterNameSafe(adminSource, S('admin_actor_label', nil, 'Administrador')),
        requestedPermissions,
        presetKey
    )
    if not saved then
        return false, saveErr
    end

    BitinhoAdmin.SyncAllPanelRoleAces()
    pushAction(adminSource, 'permissionAddPlayer', parsedTarget, normalizedCitizenid)
    return true, S('permission_add_success', {
        targetName = fullName,
        targetSource = parsedTarget
    }, 'Permissoes do painel aplicadas para {targetName} [{targetSource}].'), {
        citzenid = normalizedCitizenid,
        presetKey = presetKey,
        permissions = getPanelPermissionUiFlags(presetKey ~= '' and getPanelPermissionPresetByKey(presetKey).permissions or requestedPermissions)
    }
end

local function actionPermissionUpdatePlayer(adminSource, payload)
    local normalizedCitizenid = normalizeCitizenId(payload and (payload.citzenid or payload.citizenid))
    local targetSource = toSourceNumber(payload and payload.targetSource)
    local targetName = sanitizeText(payload and payload.name, 96, 'N/A')

    if normalizedCitizenid == '' and targetSource then
        normalizedCitizenid = getSourceNormalizedCitizenid(targetSource)
    end
    if normalizedCitizenid == '' then
        return false, S('permission_license_invalid', nil, 'Citizenid invalida para atualizar permissoes.')
    end

    local requestedPermissions, permissionErr = parseRequestedPanelPermissions(payload and payload.permissions)
    if not requestedPermissions then
        return false, permissionErr
    end

    local presetKey = parseRequestedPermissionPresetKey(payload and payload.presetKey)
    if presetKey == nil or presetKey == '' then
        return false, S('permission_preset_invalid', nil, 'Cargo de permissao invalido.')
    end

    if targetSource then
        local targetPlayer = getPlayerObject(targetSource)
        if targetPlayer and targetPlayer.PlayerData then
            targetName = getFullName(targetPlayer.PlayerData)
        else
            targetName = getCharacterNameSafe(targetSource)
        end
    end

    local existingEntry = getPanelPermissionEntryByCitizenid(normalizedCitizenid)
    if targetName == 'N/A' and existingEntry then
        targetName = sanitizeText(existingEntry.name, 96, 'N/A')
    end
    if targetName == 'N/A' then
        targetName = normalizedCitizenid
    end

    local saved, saveErr = upsertPanelPermissionEntry(
        normalizedCitizenid,
        targetName,
        getCharacterNameSafe(adminSource, S('admin_actor_label', nil, 'Administrador')),
        requestedPermissions,
        presetKey
    )
    if not saved then
        return false, saveErr
    end

    BitinhoAdmin.SyncAllPanelRoleAces()
    pushAction(adminSource, 'permissionUpdatePlayer', targetSource, normalizedCitizenid)
    return true, S('permission_update_success', {
        targetName = targetName
    }, 'Permissoes do painel atualizadas para {targetName}.'), {
        citzenid = normalizedCitizenid,
        presetKey = presetKey,
        permissions = getPanelPermissionUiFlags(presetKey ~= '' and getPanelPermissionPresetByKey(presetKey).permissions or requestedPermissions)
    }
end

local function actionPermissionRemovePlayer(adminSource, payload)
    local normalizedCitizenid = normalizeCitizenId(payload and (payload.citzenid or payload.citizenid))
    if normalizedCitizenid == '' then
        return false, S('permission_license_invalid', nil, 'Citizenid invalida para atualizar permissoes.')
    end

    local storageReady, storageErr = ensurePanelPermissionStorage()
    if not storageReady then
        return false, storageErr
    end

    local removedRows = MySQL.update.await(
        ('DELETE FROM `%s` WHERE citzenid = ?'):format(panelPermissionStore.tableName),
        { normalizedCitizenid }
    ) or 0
    if removedRows < 1 then
        return false, S('permission_not_found', nil, 'Permissao do painel nao encontrada para esta citizenid.')
    end

    panelPermissionStore.loaded = false
    local reloaded, reloadErr = reloadPanelPermissionStore()
    if not reloaded then
        return false, reloadErr or S('permission_reload_fail', nil, 'Falha ao recarregar permissoes do painel.')
    end

    BitinhoAdmin.SyncAllPanelRoleAces()
    pushAction(adminSource, 'permissionRemovePlayer', nil, normalizedCitizenid)
    return true, S('permission_remove_success', nil, 'Permissao do painel removida com sucesso.')
end

local function actionPermissionPresetUpdate(adminSource, payload)
    local presetKey = parseRequestedPermissionPresetKey(payload and payload.presetKey)
    if presetKey == nil or presetKey == '' then
        return false, S('permission_preset_invalid', nil, 'Cargo de permissao invalido.')
    end

    local requestedPermissions, permissionErr = parseRequestedPanelPermissions(payload and payload.permissions)
    if not requestedPermissions then
        return false, permissionErr
    end

    local preset = getPanelPermissionPresetByKey(presetKey)
    if not preset then
        return false, S('permission_preset_invalid', nil, 'Cargo de permissao invalido.')
    end

    local storageReady, storageErr = ensurePanelPermissionPresetStorage()
    if not storageReady then
        return false, storageErr
    end

    local affectedRows = MySQL.update.await(
        ('UPDATE `%s` SET label = ?, permissions = ? WHERE preset_key = ?'):format(panelPermissionPresetStore.tableName),
        {
            sanitizeText(preset.label, 96, presetKey),
            encodePanelPermissionSet(requestedPermissions),
            presetKey
        }
    ) or 0
    if affectedRows < 0 then
        return false, S('permission_preset_update_fail', nil, 'Falha ao salvar permissoes do cargo.')
    end

    panelPermissionPresetStore.loaded = false
    panelStaticCatalogCache = nil
    local reloaded, reloadErr = reloadPanelPermissionPresetStore()
    if not reloaded then
        return false, reloadErr or S('permission_reload_fail', nil, 'Falha ao recarregar permissoes do painel.')
    end

    pushAction(adminSource, 'permissionPresetUpdate', nil, presetKey)
    return true, S('permission_preset_update_success', {
        presetLabel = preset.label
    }, 'Permissoes do cargo {presetLabel} atualizadas com sucesso.'), {
        presetKey = presetKey,
        permissions = getPanelPermissionUiFlags(requestedPermissions)
    }
end

function actionFindCharacterByCitizenid(_, payload)
    if type(MySQL) ~= 'table' then
        return false, S('developer_db_unavailable', nil, 'Banco de dados indisponivel.')
    end

    local citizenid = sanitizeText(payload and payload.citizenid, 64, '')
    if citizenid == '' then
        return false, S('developer_citizenid_required', nil, 'Informe uma citizenid valida.')
    end

    local lookup = buildCharacterLookupPayload(citizenid)
    if not lookup or lookup.found ~= true then
        return false, S('developer_character_not_found', nil, 'Nenhum personagem encontrado para esta citizenid.')
    end

    if lookup.online then
        return true, S('developer_character_found_online', {
            citizenid = citizenid
        }, 'Citizenid encontrada. O personagem esta online e podera ser kickado antes da delecao.'), lookup
    end

    return true, S('developer_character_found', {
        citizenid = citizenid,
        rows = lookup.totalRows
    }, 'Citizenid localizada com {rows} registro(s) elegivel(is) para limpeza.'), lookup
end

function actionDeleteCharacterByCitizenid(adminSource, payload)
    if type(MySQL) ~= 'table' then
        return false, S('developer_db_unavailable', nil, 'Banco de dados indisponivel.')
    end

    local citizenid = sanitizeText(payload and payload.citizenid, 64, '')
    if citizenid == '' then
        return false, S('developer_citizenid_required', nil, 'Informe uma citizenid valida.')
    end

    local lookup = buildCharacterLookupPayload(citizenid)
    if not lookup or lookup.found ~= true or type(lookup.matchedTables) ~= 'table' or #lookup.matchedTables == 0 then
        return false, S('developer_character_not_found', nil, 'Nenhum personagem encontrado para esta citizenid.')
    end

    local onlineSource = getOnlinePlayerByCitizenid(citizenid)
    if onlineSource then
        local kickMessage = S('kick_drop_message', {
            panelTitle = Config.Ui.title,
            reason = 'Personagem agendado para delecao administrativa.'
        }, '[{panelTitle}] Voce foi removido do servidor.\nMotivo: {reason}')

        SetTimeout(5000, function()
            local liveSource = getOnlinePlayerByCitizenid(citizenid)
            if liveSource then
                DropPlayer(liveSource, kickMessage)
            end
        end)

        SetTimeout(10000, function()
            local deleteOk, _, deleteData = deleteCharacterRecordsByCitizenid(citizenid)
            if deleteOk and deleteData then
                pushAction(adminSource, 'deleteCharacterByCitizenid', nil, ('scheduled citizenid=%s tables=%s rows=%s'):format(citizenid, deleteData.deletedTables or 0, deleteData.deletedRows or 0))
            end
        end)

        return true, S('developer_delete_scheduled', {
            citizenid = citizenid
        }, 'Personagem online. O jogador sera kickado em 5 segundos e o banco sera limpo 5 segundos depois.'), {
            citizenid = citizenid,
            scheduled = true,
            kickDelayMs = 5000,
            deleteDelayMs = 10000
        }
    end

    local ok, message, data = deleteCharacterRecordsByCitizenid(citizenid)
    if not ok then
        return false, message
    end

    pushAction(adminSource, 'deleteCharacterByCitizenid', nil, ('citizenid=%s tables=%s rows=%s'):format(citizenid, data.deletedTables or 0, data.deletedRows or 0))
    return true, message, data
end

local actionMap = {
    ['goto'] = actionGoto,
    bring = actionBring,
    revive = actionRevive,
    heal = actionHeal,
    executeLightning = BitinhoAdmin.actionExecuteLightning,
    toggleFreeze = actionToggleFreeze,
    spectate = actionSpectate,
    openInventory = actionOpenInventory,
    openCompanyStash = actionOpenCompanyStash,
    togglePlayerBlips = actionTogglePlayerBlips,
    togglePlayerWall = actionTogglePlayerWall,
    toggleNoclip = actionToggleNoclip,
    spawnAdminHorse = actionSpawnAdminHorse,
    kick = actionKick,
    privateMessage = actionPrivateMessage,
    setJob = actionSetJob,
    upsertMultijobJob = actionUpsertMultijobJob,
    removeJob = actionRemoveJob,
    banPlayer = actionBanPlayer,
    editBan = actionEditBan,
    removeBan = actionRemoveBan,
    addItem = BitinhoAdmin.actionAddItems,
    checkItemCapacity = actionCheckItemCapacity,
    addMoney = actionAddMoney,
    removeMoney = actionRemoveMoney,
    addWeight = actionAddWeight,
    addSlots = actionAddSlots,
    removeWeight = BitinhoAdmin.ActionRemoveWeight,
    removeSlots = BitinhoAdmin.ActionRemoveSlots,
    renameCharacter = actionRenameCharacter,
    changeHeight = actionChangeHeight,
    clearInventory = actionClearInventory,
    permissionAddPlayer = actionPermissionAddPlayer,
    permissionUpdatePlayer = actionPermissionUpdatePlayer,
    permissionRemovePlayer = actionPermissionRemovePlayer,
    permissionPresetUpdate = actionPermissionPresetUpdate
}

local uiSelfCheck = {}

function uiSelfCheck.loadResourceText(path)
    local resourceName = GetCurrentResourceName()
    if type(resourceName) ~= 'string' or resourceName == '' then
        return nil
    end

    local content = LoadResourceFile(resourceName, path)
    if type(content) ~= 'string' or content == '' then
        return nil
    end

    return content
end

function uiSelfCheck.collectMarkupAttributeValues(content, attributeName)
    local values = {}
    if type(content) ~= 'string' or content == '' then
        return values
    end

    local pattern = ('%s%%s*=%%s*([\"\'])(.-)%%1'):format(attributeName)
    for _, value in content:gmatch(pattern) do
        local normalizedValue = sanitizeText(value, 128, '')
        if normalizedValue ~= '' then
            values[normalizedValue] = true
        end
    end

    return values
end

function uiSelfCheck.collectScriptElementIds(content)
    local values = {}
    if type(content) ~= 'string' or content == '' then
        return values
    end

    for _, value in content:gmatch('document%.getElementById%((["\'])(.-)%1%)') do
        local normalizedValue = sanitizeText(value, 128, '')
        if normalizedValue ~= '' then
            values[normalizedValue] = true
        end
    end

    return values
end

function uiSelfCheck.appendStaticUiIssues(issues)
    local html = uiSelfCheck.loadResourceText('ui/index.html')
    if not html then
        issues[#issues + 1] = 'ui/index.html nao pode ser lido pelo self-check'
        return
    end

    local script = uiSelfCheck.loadResourceText('ui/script.js')
    if not script then
        issues[#issues + 1] = 'ui/script.js nao pode ser lido pelo self-check'
        return
    end

    local htmlIds = uiSelfCheck.collectMarkupAttributeValues(html, 'id')
    local scriptIds = uiSelfCheck.collectScriptElementIds(script)

    for id in pairs(scriptIds) do
        if htmlIds[id] ~= true then
            issues[#issues + 1] = ('NUI id referenciado no script e ausente no HTML: %s'):format(id)
        end
    end

    local panelTargets = uiSelfCheck.collectMarkupAttributeValues(html, 'data%-panel%-target')
    local panels = uiSelfCheck.collectMarkupAttributeValues(html, 'data%-panel')
    for panelTarget in pairs(panelTargets) do
        if panels[panelTarget] ~= true then
            issues[#issues + 1] = ('data-panel-target sem painel correspondente: %s'):format(panelTarget)
        end
    end
end

local function runStartupSelfChecks()
    local issues = {}
    local requiredResources = {
        'ox_lib',
        'oxmysql',
        'rsg-core',
        'rsg-medic',
        'rsg-inventory',
        'rsg-bossmenu',
        'rsg-multijob'
    }

    for actionName, requiresHandler in pairs(PANEL_HANDLER_REQUIRED) do
        if requiresHandler == true and type(actionMap[actionName]) ~= 'function' then
            issues[#issues + 1] = ('actionMap ausente para action "%s"'):format(actionName)
        end
    end

    for actionName in pairs(actionMap) do
        if type(PANEL_ACTION_PERMISSIONS[actionName]) ~= 'string' or PANEL_ACTION_PERMISSIONS[actionName] == '' then
            issues[#issues + 1] = ('permissao ausente para action "%s"'):format(actionName)
        end
    end

    for _, resourceName in ipairs(requiredResources) do
        local resourceState = GetResourceState(resourceName)
        if resourceState ~= 'started' then
            issues[#issues + 1] = ('dependencia offline: %s (%s)'):format(resourceName, tostring(resourceState))
        end
    end

    local adminCommandName = sanitizeText(Config.Command, 32, 'admin'):lower()
    local noclipCommandName = sanitizeText(Config.Noclip and Config.Noclip.command, 32, 'nc'):lower()
    if adminCommandName == '' then
        issues[#issues + 1] = 'Config.Command sem valor valido'
    end
    if noclipCommandName == '' then
        issues[#issues + 1] = 'Config.Noclip.command sem valor valido'
    end
    if adminCommandName ~= '' and adminCommandName == noclipCommandName then
        issues[#issues + 1] = ('Config.Command conflita com Config.Noclip.command ("%s")'):format(adminCommandName)
    end

    for actionName, requiredPermission in pairs(PANEL_ACTION_PERMISSIONS) do
        if type(requiredPermission) ~= 'string' or requiredPermission == '' then
            issues[#issues + 1] = ('requiredPermission ausente para action "%s"'):format(actionName)
        end
    end

    if #getConfiguredMoneyTypeKeys() == 0 then
        issues[#issues + 1] = 'Config.MoneyTypes sem valores validos'
    end

    uiSelfCheck.appendStaticUiIssues(issues)

    local ok = #issues == 0
    return ok, issues
end

lib.callback.register('bilto_admin:server:getPanelState', function(source)
    if not hasPanelPermission(source) then
        return {
            ok = false,
            message = S('permission_view_denied', nil, 'Você não tem permissão para acessar o admin')
        }
    end

    local sourceId = toSourceNumber(source)
    local now = getNowMs()
    if sourceId then
        local cached = panelStateCacheBySource[sourceId]
        if type(cached) == 'table'
            and type(cached.payload) == 'table'
            and now < (tonumber(cached.expiresAt) or 0)
        then
            return cached.payload
        end
    end

    ensurePanelPermissionStoreLoaded()
    local players = collectPlayers()
    local companyStashes = buildCompanyStashCatalog()
    local globalMoneyTotals = getGlobalMoneyTotalsCached()
    local topRichPlayers = BitinhoAdmin.GetTopRichPlayersCached(10)
    local dashboard = buildDashboard(players, globalMoneyTotals, topRichPlayers)
    local bannedPlayers = collectActiveBans()
    local permissionEntries, onlinePermissionCandidates = buildPermissionEntriesForPanel()
    local canManagePermissions = canManagePanelPermissions(source)
    local staticCatalog = getStaticPanelCatalog()

    -- What this admin can use, so the NUI only shows the options they have.
    local frameworkPermissions, frameworkRole = BitinhoAdmin.GetSourceFrameworkPermissions(source)
    local selfPermissions = {
        all_permissions = frameworkPermissions ~= nil and frameworkPermissions.all_permissions == true,
        manage_permissions = canManagePermissions
    }
    for actionName in pairs(PANEL_ACTION_PERMISSIONS) do
        if selfPermissions[actionName] == nil then
            selfPermissions[actionName] = hasPanelActionPermission(source, actionName)
        end
    end
    selfPermissions.deleteCharacterByCitizenid = hasPanelActionPermission(source, 'deleteCharacterByCitizenid')

    local response = {
        ok = true,
        dashboard = dashboard,
        players = players,
        bannedPlayers = bannedPlayers,
        permissions = {
            entries = permissionEntries,
            onlinePlayers = onlinePermissionCandidates,
            canManage = canManagePermissions,
            self = {
                role = frameworkRole and frameworkRole.group or '',
                roleLabel = frameworkRole and frameworkRole.label or '',
                permissions = selfPermissions
            }
        },
        catalog = {
            jobs = staticCatalog.jobs,
            items = staticCatalog.items,
            moneyTypes = staticCatalog.moneyTypes,
            banDurations = staticCatalog.banDurations,
            companyStashes = companyStashes,
            adminHorses = staticCatalog.adminHorses,
            builtInTeleports = staticCatalog.builtInTeleports,
            permissionDefinitions = staticCatalog.permissionDefinitions,
            permissionPresets = staticCatalog.permissionPresets
        }
    }

    if sourceId then
        panelStateCacheBySource[sourceId] = {
            expiresAt = now + PANEL_STATE_CACHE_TTL_MS,
            payload = response
        }
    end

    return response
end)

lib.callback.register('bilto_admin:server:getBlipPlayers', function(source)
    if not hasPanelPermission(source) then
        return {}
    end

    return getCachedPlayersForBlips()
end)

lib.callback.register('bilto_admin:server:getTeleportLocations', function(source)
    if not hasPanelPermission(source) or not hasPanelActionPermission(source, 'teleportToCoords') then
        return { ok = false, message = S('permission_action_denied', nil, 'Sem permissao para executar a acao.'), data = {} }
    end

    return { ok = true, data = BitinhoAdmin.GetTeleportLocations() }
end)

lib.callback.register('bilto_admin:server:addTeleportLocation', function(source, payload)
    if not hasPanelPermission(source) or not hasPanelActionPermission(source, 'manageTeleportLocations') then
        return { ok = false, message = S('permission_action_denied', nil, 'Sem permissao para executar a acao.') }
    end

    local ok, message = BitinhoAdmin.AddTeleportLocation(source, payload)
    if ok then
        invalidatePanelStateCache()
    end
    return { ok = ok, message = message }
end)

lib.callback.register('bilto_admin:server:deleteTeleportLocation', function(source, payload)
    if not hasPanelPermission(source) or not hasPanelActionPermission(source, 'manageTeleportLocations') then
        return { ok = false, message = S('permission_action_denied', nil, 'Sem permissao para executar a acao.') }
    end

    local ok, message = BitinhoAdmin.DeleteTeleportLocation(source, payload)
    if ok then
        invalidatePanelStateCache()
    end
    return { ok = ok, message = message }
end)

lib.callback.register('bilto_admin:server:canExecutePanelAction', function(source, actionName)
    local action = sanitizeText(actionName, 64, '')
    if action == '' then
        return { ok = false, message = S('permission_action_denied', nil, 'Sem permissao para executar esta acao.') }
    end

    if not hasPanelPermission(source) then
        return { ok = false, message = S('permission_action_denied', nil, 'Sem permissao para executar a acao.') }
    end

    if not hasPanelActionPermission(source, action) then
        local canManage = PANEL_MANAGE_ACTIONS[action] == true
        local deniedMessage = canManage
            and S('permission_manage_denied', nil, 'Somente GOD ou quem possui permissao de gerenciamento pode alterar permissoes.')
            or S('permission_action_denied_specific', nil, 'Sem permissao para executar esta acao.')
        return { ok = false, message = deniedMessage }
    end

    return { ok = true, message = '' }
end)

local function executePanelAction(source, payload)
    if not hasPanelPermission(source) then
        return {
            ok = false,
            message = S('permission_action_denied', nil, 'Sem permissao para executar a acao.')
        }
    end

    if type(payload) ~= 'table' then
        return {
            ok = false,
            message = S('payload_invalid', nil, 'Payload invalido.')
        }
    end

    local actionName = sanitizeText(payload.action, 64, '')
    local handler = actionMap[actionName]
    if not handler then
        return {
            ok = false,
            message = S('action_unsupported', nil, 'Acao nao suportada.')
        }
    end

    if not hasPanelActionPermission(source, actionName) then
        local deniedMessage = PANEL_MANAGE_ACTIONS[actionName]
            and S('permission_manage_denied', nil, 'Somente GOD ou quem possui permissao de gerenciamento pode alterar permissoes.')
            or S('permission_action_denied_specific', nil, 'Sem permissao para executar esta acao.')
        return {
            ok = false,
            message = deniedMessage
        }
    end

    local sourceId = toSourceNumber(source)
    if ACTION_LOCK_ENABLED and sourceId and isActionInFlight(sourceId) then
        return {
            ok = false,
            message = S('action_in_progress', nil, 'Aguarde a acao anterior finalizar.')
        }
    end

    if ACTION_LOCK_ENABLED and sourceId then
        setActionInFlight(sourceId, true)
    end

    local succeeded, ok, responseMessage, responseData = xpcall(function()
        return handler(source, payload)
    end, function(err)
        return debug.traceback(tostring(err), 2)
    end)

    if ACTION_LOCK_ENABLED and sourceId then
        setActionInFlight(sourceId, false)
    end

    if not succeeded then
        return {
            ok = false,
            message = S('action_fail_default', nil, 'Falha ao executar a acao.')
        }
    end

    if ok then
        invalidatePanelStateCache()
        return {
            ok = true,
            message = responseMessage,
            data = responseData
        }
    end

    return {
        ok = false,
        message = responseMessage or S('action_fail_default', nil, 'Falha ao executar a acao.'),
        data = responseData
    }
end

function BitinhoAdmin.ExecutePanelAction(source, actionName, payload)
    local payloadToUse = payload
    if type(payloadToUse) ~= 'table' then
        payloadToUse = {}
    end
    payloadToUse.action = sanitizeText(actionName, 64, sanitizeText(payloadToUse.action, 64, ''))
    return executePanelAction(source, payloadToUse)
end

function BitinhoAdmin.OpenPanel(source)
    if source <= 0 then
        return false, S('panel_closed', nil, 'Painel fechado.')
    end

    if not hasPanelPermission(source) then
        return false, S('command_no_permission', nil, 'Você não tem permissão para acessar o admin')
    end

    TriggerClientEvent('bilto_admin:client:openPanel', source)
    return true, S('status_panel_updated', nil, 'Painel atualizado.')
end

function BitinhoAdmin.ToggleNoclip(source)
    if source <= 0 then
        return false, S('panel_closed', nil, 'Painel fechado.')
    end

    if not canUseNoclipCommand(source) then
        return false, S('command_noclip_no_permission', nil, 'Voce nao tem permissao para usar noclip.')
    end

    return actionToggleNoclip(source, {})
end

BitinhoAdmin.Notify = function(source, description, notifyType)
    if type(source) ~= 'number' then
        return
    end
    notify(source, description, notifyType or 'info')
end

lib.callback.register('bilto_admin:server:performAction', function(source, payload)
    return executePanelAction(source, payload)
end)

AddEventHandler('RSGCore:Server:PlayerLoaded', function(player)
    local sourceId = toSourceNumber(player and player.PlayerData and player.PlayerData.source)
    if sourceId then
        BitinhoAdmin.SyncPanelRoleAce(sourceId)
    end
end)

AddEventHandler('RSGCore:Server:OnPlayerUnload', function(playerSource)
    local sourceId = toSourceNumber(playerSource)
    if sourceId then
        BitinhoAdmin.ClearPanelRoleAce(sourceId)
    end
end)

AddEventHandler('playerDropped', function()
    local sourceId = tonumber(source)
    if sourceId then
        BitinhoAdmin.ClearPanelRoleAce(sourceId)
        freezeState[sourceId] = nil
        noclipState[sourceId] = nil
        wallWeaponState[sourceId] = nil
        wallWeaponStateUpdateAt[sourceId] = nil
        setActionInFlight(sourceId, false)
        clearSupportStateForSource(sourceId)
        invalidatePanelStateCache(sourceId)
        invalidatePanelStateCache()
        invalidateBlipPlayersCache()
    end
end)

local adminCommandName = sanitizeText(Config.Command, 32, 'admin'):lower()
local noclipCommandName = sanitizeText(Config.Noclip and Config.Noclip.command, 32, 'nc'):lower()

if adminCommandName ~= '' then
    RSGCore.Commands.Add(adminCommandName, S('command_description', nil, 'Abrir painel administrativo Bitinho'), {}, false, function(source)
        if source <= 0 then
            return
        end

        local ok, message = BitinhoAdmin.OpenPanel(source)
        notify(source, message, ok and 'ok' or 'error')
    end, 'user')
end

if noclipCommandName ~= '' then
    if noclipCommandName ~= adminCommandName then
        RSGCore.Commands.Add(noclipCommandName, S('command_noclip_description', nil, 'Alternar noclip administrativo'), {}, false, function(source)
            if source <= 0 then
                return
            end

            local ok, message = BitinhoAdmin.ToggleNoclip(source)
            notify(source, message, ok and 'ok' or 'error')
        end, 'user')
    end
end

RegisterCommand('bilto_admin_selfcheck', function(source)
    if tonumber(source) and tonumber(source) > 0 then
        return
    end

    runStartupSelfChecks()
end, true)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for sourceId in pairs(BitinhoAdmin.appliedPanelRoles or {}) do
        BitinhoAdmin.ClearPanelRoleAce(sourceId)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    invalidatePanelStaticCatalogCache()
    clearGlobalMoneyCache()
    BitinhoAdmin.ClearTopRichPlayersCache()
    invalidatePanelStateCache()
    invalidateBlipPlayersCache()
    actionInFlightBySource = {}
    wallWeaponStateUpdateAt = {}
    spectateTargetByAdmin = {}
    getStaticPanelCatalog()
    local loaded, err = ensurePanelPermissionStoreLoaded()
    if not loaded then
        return
    end

    local presetsLoaded, presetsErr = ensurePanelPermissionPresetStoreLoaded()
    if not presetsLoaded then
        return
    end

    BitinhoAdmin.SyncAllPanelRoleAces()
    runStartupSelfChecks()

    runVersionCheck()
end)
