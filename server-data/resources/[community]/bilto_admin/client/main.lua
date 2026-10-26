local Config = type(Config) == 'table' and Config or {}

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

local function normalizeClientConfig(raw)
    local cfg = ensureTable(raw, {})

    cfg.Locale = ensureString(cfg.Locale, 'ptbr'):lower()
    cfg.Locales = ensureTable(cfg.Locales, {})
    cfg.PrivateMessageDuration = ensureInteger(cfg.PrivateMessageDuration, 9000, 1000, 60000)

    cfg.Ui = ensureTable(cfg.Ui, {})
    cfg.Ui.title = ensureString(cfg.Ui.title, 'Bitinho Admin')
    cfg.Ui.refreshCooldownMs = ensureInteger(cfg.Ui.refreshCooldownMs, 1500, 100, 10000)
    cfg.Ui.modalDebug = ensureBoolean(cfg.Ui.modalDebug, false)
    cfg.Ui.openKeyHash = ensureInteger(cfg.Ui.openKeyHash, 0x3C3DD371, 1, 0xFFFFFFFF)
    cfg.Ui.openKeyDebounceMs = ensureInteger(cfg.Ui.openKeyDebounceMs, 300, 80, 5000)

    cfg.Notifications = ensureTable(cfg.Notifications, {})
    cfg.Notifications.defaultDuration = ensureInteger(cfg.Notifications.defaultDuration, 4200, 500, 60000)
    cfg.Notifications.adminDuration = ensureInteger(cfg.Notifications.adminDuration, 5000, 500, 60000)
    cfg.Notifications.targetDuration = ensureInteger(cfg.Notifications.targetDuration, 5200, 500, 60000)

    cfg.Client = ensureTable(cfg.Client, {})
    cfg.Client.tracking = ensureTable(cfg.Client.tracking, {})
    cfg.Client.tracking.activeIntervalMs = ensureInteger(cfg.Client.tracking.activeIntervalMs, 500, 100, 10000)

    cfg.Client.wallText = ensureTable(cfg.Client.wallText, {})
    cfg.Client.wallText.maxDistance = ensureNumber(cfg.Client.wallText.maxDistance, 260.0, 20.0, 1000.0)
    cfg.Client.wallText.zOffset = ensureNumber(cfg.Client.wallText.zOffset, 0.92, -10.0, 10.0)
    cfg.Client.wallText.idleWaitMs = ensureInteger(cfg.Client.wallText.idleWaitMs, 250, 0, 5000)
    cfg.Client.wallText.titleColor = ensureString(cfg.Client.wallText.titleColor, '~t7~')
    cfg.Client.wallText.resetColor = ensureString(cfg.Client.wallText.resetColor, '~q~')

    cfg.Client.wallWeaponState = ensureTable(cfg.Client.wallWeaponState, {})
    cfg.Client.wallWeaponState.stateBagKey = ensureString(cfg.Client.wallWeaponState.stateBagKey, 'bitinho_wall_weapon')
    cfg.Client.wallWeaponState.armedIntervalMs = ensureInteger(cfg.Client.wallWeaponState.armedIntervalMs, 180, 50, 5000)
    cfg.Client.wallWeaponState.unarmedIntervalMs = ensureInteger(cfg.Client.wallWeaponState.unarmedIntervalMs, 450, 50, 5000)

    cfg.Developer = ensureTable(cfg.Developer, {})
    cfg.Developer.horseOverpower = ensureNumber(cfg.Developer.horseOverpower, 5000.0, 1.0, 1000000.0)

    cfg.Support = ensureTable(cfg.Support, {})

    return cfg
end

Config = normalizeClientConfig(Config)

local panelOpen = false
local refreshLockedUntil = 0
local frozenByAdmin = false
local playerBlipsEnabled = false
local playerWallEnabled = false
local playerBlips = {}
local playerTrackingThread = nil
local lastTrackedPlayers = {}
local playerWallThread = nil
local wallRenderer = type(BitinhoAdminWall) == 'table' and BitinhoAdminWall or nil
local hasWallRenderer = wallRenderer
    and type(wallRenderer.createConfig) == 'function'
    and type(wallRenderer.resolveCoords) == 'function'
    and type(wallRenderer.buildLines) == 'function'
    and type(wallRenderer.draw) == 'function'
    and type(wallRenderer.isInRange) == 'function'
local wallTextSettings = Config.Client.wallText
local wallTextConfig = hasWallRenderer and wallRenderer.createConfig({
    maxDistance = wallTextSettings.maxDistance,
    zOffset = wallTextSettings.zOffset
}) or {
    maxDistanceSq = wallTextSettings.maxDistance * wallTextSettings.maxDistance,
    zOffset = wallTextSettings.zOffset
}
local UNARMED_HASH = GetHashKey('WEAPON_UNARMED')
local wallWeaponStateKey = Config.Client.wallWeaponState.stateBagKey
local lastWallWeaponState = nil
local WALL_STATE_INTERVAL_ARMED_MS = Config.Client.wallWeaponState.armedIntervalMs
local WALL_STATE_INTERVAL_UNARMED_MS = Config.Client.wallWeaponState.unarmedIntervalMs
local TRACK_INTERVAL_ACTIVE_MS = Config.Client.tracking.activeIntervalMs
local PANEL_TOGGLE_KEY_HASH = Config.Ui.openKeyHash
local PANEL_TOGGLE_DEBOUNCE_MS = Config.Ui.openKeyDebounceMs
local lastPanelToggleInputAt = 0
local spectateState = {
    enabled = false,
    targetSource = 0,
    savedCoords = nil,
    savedHeading = 0.0
}

local function buildWallWeaponState()
    local state = {
        weaponHash = 0
    }

    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        return state
    end

    local hasWeapon, weaponHash = GetCurrentPedWeapon(ped, true, 0, true)
    if not hasWeapon or not weaponHash or weaponHash == 0 or weaponHash == UNARMED_HASH or weaponHash == -1569615261 then
        return state
    end

    state.weaponHash = weaponHash
    return state
end

local function isSameWallWeaponState(a, b)
    if type(a) ~= 'table' or type(b) ~= 'table' then
        return false
    end

    return (tonumber(a.weaponHash) or 0) == (tonumber(b.weaponHash) or 0)
end

CreateThread(function()
    while true do
        local nextState = buildWallWeaponState()
        if not isSameWallWeaponState(nextState, lastWallWeaponState) then
            if LocalPlayer and LocalPlayer.state and type(LocalPlayer.state.set) == 'function' then
                LocalPlayer.state:set(wallWeaponStateKey, nextState, true)
            end
            TriggerServerEvent('bilto_admin:server:updateWallWeaponState', nextState)
            lastWallWeaponState = nextState
        end

        local waitTime = ((tonumber(nextState.weaponHash) or 0) == 0)
            and WALL_STATE_INTERVAL_UNARMED_MS
            or WALL_STATE_INTERVAL_ARMED_MS
        Wait(waitTime)
    end
end)

local function sanitizeText(value, maxLength, fallback)
    if type(value) ~= 'string' then
        return fallback or ''
    end

    local output = value:gsub('^%s+', ''):gsub('%s+$', '')
    if output == '' then
        return fallback or ''
    end

    local limit = tonumber(maxLength) or 128
    if #output > limit then
        output = output:sub(1, limit)
    end

    return output
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
    local localeKey = sanitizeText(Config and Config.Locale, 12, 'ptbr'):lower()
    local locales = type(Config and Config.Locales) == 'table' and Config.Locales or {}
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

local function C(key, params, fallbackText)
    return interpolateText(getLocalizedText('client', key, fallbackText), params)
end

local function buildUiLocalePayload()
    local localeKey, activeLocale, fallbackLocale = getLocaleBundles()
    local activeUi = type(activeLocale.ui) == 'table' and activeLocale.ui or type(activeLocale.texts) == 'table' and activeLocale.texts or activeLocale
    local activeMeta = type(activeLocale.meta) == 'table' and activeLocale.meta or {}
    local fallbackMeta = type(fallbackLocale.meta) == 'table' and fallbackLocale.meta or {}
    local modalDebugEnabled = Config and Config.Ui and Config.Ui.modalDebug == true

    return {
        key = localeKey,
        htmlLang = activeMeta.htmlLang or fallbackMeta.htmlLang or 'pt-BR',
        numberLocale = activeMeta.numberLocale or fallbackMeta.numberLocale or 'pt-BR',
        ui = activeUi,
        settings = {
            modalDebug = modalDebugEnabled
        }
    }
end

local function pushToast(description, notifyType, duration, title)
    local normalizedType = tostring(notifyType or 'info'):lower()
    local resolvedTitle = title
    if resolvedTitle == Config.Ui.title then
        resolvedTitle = nil
    end
    if not resolvedTitle or resolvedTitle == '' then
        if normalizedType == 'ok' or normalizedType == 'success' then
            resolvedTitle = C('notification_success_title', nil, 'Sucesso')
        elseif normalizedType == 'error' then
            resolvedTitle = C('notification_denied_title', nil, 'Negado')
        elseif normalizedType == 'warn' or normalizedType == 'warning' then
            resolvedTitle = C('notification_warning_title', nil, 'Aviso')
        else
            resolvedTitle = C('notification_info_title', nil, 'Informação')
        end
    end

    SendNUIMessage({
        action = 'bilto_admin:toast',
        payload = {
            title = resolvedTitle,
            message = description or '',
            type = normalizedType,
            duration = tonumber(duration) or Config.Notifications.defaultDuration
        }
    })
end

local function stopSpectate(reasonMessage, notifyType)
    if not spectateState.enabled then
        return
    end

    spectateState.enabled = false
    spectateState.targetSource = 0

    local ped = PlayerPedId()
    NetworkSetInSpectatorMode(false, ped)

    if spectateState.savedCoords and type(spectateState.savedCoords) == 'vector3' then
        SetEntityCoords(ped, spectateState.savedCoords.x + 0.0, spectateState.savedCoords.y + 0.0, spectateState.savedCoords.z + 0.0, false, false, false, false)
        SetEntityHeading(ped, spectateState.savedHeading + 0.0)
    end

    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetEntityCollision(ped, true, true)
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    spectateState.savedCoords = nil
    spectateState.savedHeading = 0.0

    if reasonMessage and reasonMessage ~= '' then
        pushToast(reasonMessage, notifyType or 'warn', Config.Notifications.defaultDuration)
    end
end

local function startSpectate(targetSource, targetName)
    local parsedTarget = tonumber(targetSource) or 0
    if parsedTarget <= 0 then
        stopSpectate(C('spectate_disabled', nil, 'Spectate desativado.'), 'warn')
        return
    end

    local targetPlayerId = GetPlayerFromServerId(parsedTarget)
    local targetPed = targetPlayerId ~= -1 and GetPlayerPed(targetPlayerId) or 0
    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        pushToast(C('spectate_target_lost', nil, 'Jogador saiu de alcance/offline. Spectate desativado.'), 'warn', Config.Notifications.defaultDuration)
        return
    end

    local ped = PlayerPedId()
    spectateState.savedCoords = GetEntityCoords(ped)
    spectateState.savedHeading = GetEntityHeading(ped) + 0.0
    spectateState.targetSource = parsedTarget
    spectateState.enabled = true

    SetEntityVisible(ped, false, false)
    SetEntityCollision(ped, false, false)
    SetEntityInvincible(ped, true)
    NetworkSetEntityInvisibleToNetwork(ped, true)
    NetworkSetInSpectatorMode(true, targetPed)

    pushToast(C('spectate_enabled', {
        targetName = sanitizeText(targetName, 96, ('ID %s'):format(parsedTarget)),
        targetSource = parsedTarget
    }, 'Spectate ativado em {targetName} [{targetSource}].'), 'ok', Config.Notifications.defaultDuration)
end

local function clearPlayerBlips()
    for _, blip in pairs(playerBlips) do
        RemoveBlip(blip)
    end
    playerBlips = {}
end

local function setUiState(open)
    panelOpen = open
    SetNuiFocus(open, open)
    local localePayload = buildUiLocalePayload()
    local panelTitle = localePayload.ui and localePayload.ui.panel_title or Config.Ui.title

    SendNUIMessage({
        action = 'bilto_admin:toggle',
        open = open,
        title = panelTitle,
        locale = localePayload
    })
end

local function pushStateToUi(payload)
    local safePayload = type(payload) == 'table' and payload or {}
    safePayload.locale = buildUiLocalePayload()

    SendNUIMessage({
        action = 'bilto_admin:updateState',
        payload = safePayload
    })
end

local function syncPlayerBlips(entries)
    if not playerBlipsEnabled then
        if next(playerBlips) then
            clearPlayerBlips()
        end
        return
    end

    local safeEntries = type(entries) == 'table' and entries or {}
    local seen = {}
    for _, entry in ipairs(safeEntries) do
        local serverId = tonumber(entry.id)
        local coords = entry.coords
        if serverId and type(coords) == 'table' then
            seen[serverId] = true
            if not playerBlips[serverId] then
                local blip = BlipAddForCoords(1664425300, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
                SetBlipSprite(blip, GetHashKey('blip_ambient_companion'))
                SetBlipScale(blip, 0.6)
                local label = ('ID: %s | %s'):format(serverId, entry.name or '')
                SetBlipName(blip, label)
                playerBlips[serverId] = blip
            else
                SetBlipCoords(playerBlips[serverId], coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
            end
        end
    end

    for serverId, blip in pairs(playerBlips) do
        if not seen[serverId] then
            RemoveBlip(blip)
            playerBlips[serverId] = nil
        end
    end
end

local function ensurePlayerWallThread()
    if not hasWallRenderer then
        return
    end

    if playerWallThread then
        return
    end

    playerWallThread = CreateThread(function()
        while playerWallEnabled do
            local ped = PlayerPedId()
            local myCoords = GetEntityCoords(ped)
            local trackedPlayers = lastTrackedPlayers

            for _, entry in ipairs(trackedPlayers) do
                local serverId = tonumber(entry and entry.id)
                if serverId then
                    local coords, targetPed = wallRenderer.resolveCoords(entry, serverId, wallTextConfig.zOffset)
                    if coords and wallRenderer.isInRange(myCoords, coords, wallTextConfig.maxDistanceSq) then
                        local lines = wallRenderer.buildLines(entry, serverId, playerWallEnabled, sanitizeText, targetPed)
                        wallRenderer.draw(coords.x, coords.y, coords.z, lines, wallTextConfig)
                    end
                end
            end

            Wait((#trackedPlayers > 0) and 0 or wallTextSettings.idleWaitMs)
        end

        playerWallThread = nil
    end)
end

local function ensurePlayerTrackingThread()
    if playerTrackingThread then
        return
    end

    playerTrackingThread = CreateThread(function()
        while playerBlipsEnabled or playerWallEnabled do
            local entries = {}
            local response = lib.callback.await('bilto_admin:server:getBlipPlayers', false)
            if type(response) == 'table' then
                for _, entry in ipairs(response) do
                    entries[#entries + 1] = entry
                end
            end

            lastTrackedPlayers = entries
            syncPlayerBlips(entries)
            Wait(TRACK_INTERVAL_ACTIVE_MS)
        end

        lastTrackedPlayers = {}
        clearPlayerBlips()
        playerTrackingThread = nil
    end)
end

local function requestPanelState(force)
    local now = GetGameTimer()
    if not force and now < refreshLockedUntil then
        return false
    end

    refreshLockedUntil = now + Config.Ui.refreshCooldownMs

    local response = lib.callback.await('bilto_admin:server:getPanelState', false)
    if not response or response.ok ~= true then
        local message = response and response.message or C('panel_load_fail', nil, 'Falha ao carregar dados do painel.')
        pushToast(message, 'error', Config.Notifications.adminDuration)
        return false
    end

    pushStateToUi(response)
    return true
end

RegisterNetEvent('bilto_admin:client:openPanel', function()
    if panelOpen then
        return
    end

    local loaded = requestPanelState(true)
    if not loaded then
        return
    end

    setUiState(true)
    ensurePlayerTrackingThread()
end)

CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustReleased(0, PANEL_TOGGLE_KEY_HASH) then
            local now = GetGameTimer()
            if (now - lastPanelToggleInputAt) < PANEL_TOGGLE_DEBOUNCE_MS then
                goto continue
            end
            lastPanelToggleInputAt = now

            if panelOpen then
                setUiState(false)
                goto continue
            end

            if IsPauseMenuActive() then
                goto continue
            end

            local loaded = requestPanelState(true)
            if loaded then
                setUiState(true)
                ensurePlayerTrackingThread()
            end
        end

        ::continue::
    end
end)

RegisterNetEvent('bilto_admin:client:teleportTo', function(coords)
    if type(coords) ~= 'table' then
        return
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)
    if not x or not y or not z then
        return
    end

    local ped = PlayerPedId()
    SetEntityCoords(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false, false)
end)

RegisterNetEvent('bilto_admin:client:setFrozen', function(state)
    local ped = PlayerPedId()
    frozenByAdmin = state == true
    FreezeEntityPosition(ped, frozenByAdmin)

    if frozenByAdmin then
        pushToast(C('frozen', nil, 'Voce foi congelado por um administrador.'), 'warn', Config.Notifications.targetDuration)
        return
    end

    pushToast(C('unfrozen', nil, 'Voce foi descongelado por um administrador.'), 'ok', Config.Notifications.targetDuration)
end)

RegisterNetEvent('bilto_admin:client:executeLightning', function()
    local ped = PlayerPedId()
    if ped == nil or ped == 0 then
        return
    end

    local coords = GetEntityCoords(ped)
    Citizen.InvokeNative(0x67943537D179597C, coords.x, coords.y, coords.z, 1.0)
    Wait(300)
    AddExplosion(coords.x, coords.y, coords.z, 33, -1.0, true, false, 1.0)
end)

RegisterNetEvent('bilto_admin:client:receiveStaffMessage', function(payload)
    if type(payload) ~= 'table' then
        return
    end

    local staff = payload.staff or 'Administrador'
    local message = payload.message or ''
    local duration = tonumber(payload.duration) or Config.PrivateMessageDuration

    if message == '' then
        return
    end

    pushToast(message, 'info', duration, C('staff_message_title', {
        staff = staff
    }, 'Mensagem do administrador'))
end)

RegisterNetEvent('bilto_admin:client:showToast', function(payload)
    if type(payload) ~= 'table' then
        return
    end

    pushToast(payload.description or '', payload.type or 'info', payload.duration or Config.Notifications.defaultDuration, payload.title)
end)

RegisterNetEvent('bilto_admin:client:restoreStamina', function()
    local playerId = PlayerId()
    if playerId == nil then
        return
    end

    CreateThread(function()
        local delays = { 0, 150, 350, 700, 1200, 1800, 2600 }

        for _, delay in ipairs(delays) do
            if delay > 0 then
                Wait(delay)
            end

            local ped = PlayerPedId()
            if ped and ped ~= 0 then
                SetAttributeCoreValue(ped, 1, 100)
                Citizen.InvokeNative(0xC6258F41D86676E0, ped, 1, 100.0)
                EnableAttributeOverpower(ped, 1, 5000.0)
                Citizen.InvokeNative(0xF6A7C08DF2E28B28, ped, 1, 5000.0, false)
            end

            Citizen.InvokeNative(0xA352C1B864CAFD33, playerId, 1.0)
        end
    end)
end)

RegisterNetEvent('bilto_admin:client:togglePlayerBlips', function()
    playerBlipsEnabled = not playerBlipsEnabled

    if not playerBlipsEnabled then
        clearPlayerBlips()
        pushToast(C('blips_disabled', nil, 'Blips de jogadores desativados.'), 'warn', Config.Notifications.defaultDuration)
        return
    end

    pushToast(C('blips_enabled', nil, 'Blips de jogadores ativados.'), 'ok', Config.Notifications.defaultDuration)
    syncPlayerBlips(lastTrackedPlayers)
    ensurePlayerTrackingThread()
end)

RegisterNetEvent('bilto_admin:client:togglePlayerWall', function()
    if not hasWallRenderer then
        pushToast(C('action_fail', nil, 'Falha ao executar acao.'), 'error', Config.Notifications.defaultDuration)
        return
    end

    playerWallEnabled = not playerWallEnabled
    if not playerWallEnabled then
        pushToast(C('wall_disabled', nil, 'Wall de jogadores desativado.'), 'warn', Config.Notifications.defaultDuration)
        return
    end

    pushToast(C('wall_enabled', nil, 'Wall de jogadores ativado.'), 'ok', Config.Notifications.defaultDuration)
    ensurePlayerTrackingThread()
    ensurePlayerWallThread()
end)

RegisterNetEvent('bilto_admin:client:spawnAdminHorse', function(modelName, horseLabel)
    local model = sanitizeText(modelName, 96, ''):lower()
    if model == '' then
        pushToast(C('horse_spawn_fail', nil, 'Falha ao spawnar cavalo.'), 'error', Config.Notifications.defaultDuration)
        return
    end

    local hash = joaat(model)
    if not IsModelInCdimage(hash) then
        pushToast(C('horse_spawn_fail', nil, 'Falha ao spawnar cavalo.'), 'error', Config.Notifications.defaultDuration)
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    local ped = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.0)
    local heading = GetEntityHeading(ped)
    local horsePed = CreatePed(hash, pos.x + 0.0, pos.y + 0.0, (pos.z - 1.0) + 0.0, heading + 0.0, true, false)
    if not horsePed or horsePed == 0 then
        SetModelAsNoLongerNeeded(hash)
        pushToast(C('horse_spawn_fail', nil, 'Falha ao spawnar cavalo.'), 'error', Config.Notifications.defaultDuration)
        return
    end

    TaskMountAnimal(ped, horsePed, 10000, -1, 1.0, 1, 0, 0)
    SetRandomOutfitVariation(horsePed, true)
    EnableAttributeOverpower(horsePed, 0, Config.Developer.horseOverpower)
    EnableAttributeOverpower(horsePed, 1, Config.Developer.horseOverpower)
    SetPlayerOwnsMount(ped, horsePed)
    ApplyShopItemToPed(horsePed, -447673416, true, true, true)
    NetworkSetEntityInvisibleToNetwork(horsePed, true)
    SetModelAsNoLongerNeeded(hash)

    pushToast(C('horse_spawned', {
        label = sanitizeText(horseLabel, 96, model)
    }, 'Cavalo {label} spawnado.'), 'ok', Config.Notifications.defaultDuration)
end)

RegisterNetEvent('bilto_admin:client:spectate:setState', function(payload)
    local state = type(payload) == 'table' and payload or {}
    local enabled = state.enabled == true
    if not enabled then
        stopSpectate(C('spectate_disabled', nil, 'Spectate desativado.'), 'warn')
        return
    end

    startSpectate(state.targetSource, state.targetName)
end)

RegisterNUICallback('ready', function(_, cb)
    if panelOpen then
        requestPanelState(true)
    end

    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    local ok = requestPanelState(true)
    cb({ ok = ok })
end)

RegisterNUICallback('getCurrentCoords', function(_, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local access = lib.callback.await('bilto_admin:server:canExecutePanelAction', false, 'copyCoords')
    if not access or access.ok ~= true then
        cb({ ok = false, message = access and access.message or C('permission_action_denied', nil, 'Sem permissao para executar esta acao.') })
        return
    end

    local ped = PlayerPedId()
    if not ped or ped <= 0 or not DoesEntityExist(ped) then
        cb({ ok = false, message = C('status_coords_fetch_fail', nil, 'Falha ao pegar coordenadas.') })
        return
    end

    local coords = GetEntityCoords(ped)
    if not coords then
        cb({ ok = false, message = C('status_coords_fetch_fail', nil, 'Falha ao pegar coordenadas.') })
        return
    end

    cb({
        ok = true,
        data = {
            x = coords.x + 0.0,
            y = coords.y + 0.0,
            z = coords.z + 0.0,
            heading = GetEntityHeading(ped) + 0.0
        }
    })
end)

RegisterNUICallback('teleportToCoords', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local access = lib.callback.await('bilto_admin:server:canExecutePanelAction', false, 'teleportToCoords')
    if not access or access.ok ~= true then
        cb({ ok = false, message = access and access.message or C('permission_action_denied', nil, 'Sem permissao para executar esta acao.') })
        return
    end

    local payload = type(data) == 'table' and data or {}
    local x, y, z = tonumber(payload.x), tonumber(payload.y), tonumber(payload.z)
    if not x or not y or not z then
        cb({ ok = false, message = C('teleport_coords_invalid', nil, 'Coordenadas invalidas.') })
        return
    end

    local ped = PlayerPedId()
    SetEntityCoordsNoOffset(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false)
    local heading = tonumber(payload.heading)
    if heading then
        SetEntityHeading(ped, heading + 0.0)
    end

    cb({ ok = true })
end)

RegisterNUICallback('getTeleportLocations', function(_, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.'), data = {} })
        return
    end

    local response = lib.callback.await('bilto_admin:server:getTeleportLocations', false)
    cb(response or { ok = false, data = {} })
end)

RegisterNUICallback('addTeleportLocation', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local response = lib.callback.await('bilto_admin:server:addTeleportLocation', false, data)
    cb(response or { ok = false, message = C('action_fail', nil, 'Falha ao executar acao.') })
end)

RegisterNUICallback('deleteTeleportLocation', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local response = lib.callback.await('bilto_admin:server:deleteTeleportLocation', false, data)
    cb(response or { ok = false, message = C('action_fail', nil, 'Falha ao executar acao.') })
end)

RegisterNUICallback('canExecutePanelAction', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local action = sanitizeText(type(data) == 'table' and data.action or '', 64, '')
    if action == '' then
        cb({ ok = false, message = C('permission_action_denied', nil, 'Sem permissao para executar esta acao.') })
        return
    end

    local response = lib.callback.await('bilto_admin:server:canExecutePanelAction', false, action)
    cb(response or { ok = false, message = C('permission_action_denied', nil, 'Sem permissao para executar esta acao.') })
end)

RegisterNUICallback('copyToClipboard', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local payload = type(data) == 'table' and data or {}
    local text = sanitizeText(payload.text, 512, '')
    if text == '' then
        cb({ ok = false, message = C('status_coords_copy_fail', nil, 'Falha ao copiar.') })
        return
    end

    if type(SetClipboard) == 'function' then
        SetClipboard(text)
        cb({ ok = true })
        return
    end

    cb({ ok = false, message = C('status_coords_copy_fail', nil, 'Falha ao copiar.') })
end)

RegisterNUICallback('performAction', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local response = lib.callback.await('bilto_admin:server:performAction', false, data)
    if not response or response.ok ~= true then
        local message = response and response.message or C('action_fail', nil, 'Falha ao executar acao.')
        cb({ ok = false, message = message, data = response and response.data or nil })
        return
    end

    local actionName = type(data) == 'table' and tostring(data.action or '') or ''
    if actionName == 'openInventory' then
        cb({ ok = true, message = response.message, data = response.data })
        return
    end

    if actionName == 'checkItemCapacity' then
        cb({ ok = true, message = response.message, data = response.data })
        return
    end

    requestPanelState(true)
    cb({ ok = true, message = response.message, data = response.data })
end)

RegisterNUICallback('openInventoryFast', function(data, cb)
    if not panelOpen then
        cb({ ok = false, message = C('panel_closed', nil, 'Painel fechado.') })
        return
    end

    local payload = type(data) == 'table' and data or {}
    payload.action = 'openInventory'

    cb({ ok = true })

    CreateThread(function()
        local response = lib.callback.await('bilto_admin:server:performAction', false, payload)
        if not response or response.ok ~= true then
            local message = response and response.message or C('open_inventory_fail', nil, 'Falha ao abrir inventario.')
            pushToast(message, 'error', Config.Notifications.defaultDuration)
        end
    end)
end)

RegisterNUICallback('close', function(_, cb)
    setUiState(false)
    cb({ ok = true })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    stopSpectate(nil, 'info')

    if panelOpen then
        SetNuiFocus(false, false)
    end

    if frozenByAdmin then
        FreezeEntityPosition(PlayerPedId(), false)
        frozenByAdmin = false
    end

    playerBlipsEnabled = false
    playerWallEnabled = false
    clearPlayerBlips()
    if LocalPlayer and LocalPlayer.state and type(LocalPlayer.state.set) == 'function' then
        LocalPlayer.state:set(wallWeaponStateKey, { weaponHash = 0 }, true)
    end
    TriggerServerEvent('bilto_admin:server:updateWallWeaponState', { weaponHash = 0 })
    lastWallWeaponState = nil
end)

