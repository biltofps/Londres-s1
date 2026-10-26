local Config = type(Config) == 'table' and Config or {}

local DEFAULT_SPEED_LEVELS = { 0.5, 1.0, 2.0, 4.0, 8.0, 10.0 }
local DEFAULT_CONTROLS = {
    increaseSpeed = { 0xCC1075A7, 0x62800C92 },
    decreaseSpeed = { 0xFD0F0C2C, 0x8BDE7443 },
    up = 0xD9D0E1C0,
    down = 0x8FFC75D6,
    forward = 0x8FD015D8,
    backward = 0xD27782E3,
    left = 0x7065027D,
    right = 0xB4E465B4,
    blocked = {
        0xB238FE0B,
        0x3076E97C,
    }
}

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

local function normalizeControlList(value, fallback)
    if type(value) == 'number' then
        return value
    end

    local input = ensureTable(value, {})
    local output = {}
    for _, entry in ipairs(input) do
        local control = tonumber(entry)
        if control then
            output[#output + 1] = math.floor(control)
        end
    end

    if #output == 0 then
        return fallback
    end

    return output
end

local function normalizeSpeedLevels(value)
    local source = ensureTable(value, DEFAULT_SPEED_LEVELS)
    local validated = {}

    for _, entry in ipairs(source) do
        local speed = tonumber(entry)
        if speed and speed > 0 then
            validated[#validated + 1] = speed
        end
    end

    if #validated == 0 then
        return DEFAULT_SPEED_LEVELS
    end

    return validated
end

local function normalizeNoclipConfig(raw)
    local root = ensureTable(raw, {})
    local noclip = ensureTable(root.Noclip, {})
    local controls = ensureTable(noclip.controls, {})
    local behavior = ensureTable(noclip.behavior, {})

    local speedLevels = normalizeSpeedLevels(noclip.speedLevels)

    return {
        SpeedLevels = speedLevels,
        DefaultSpeedIndex = ensureInteger(noclip.defaultSpeedIndex, 1, 1, #speedLevels),
        ShowHud = ensureBoolean(noclip.showHud, true),
        IdleWaitMs = ensureInteger(noclip.idleWaitMs, 400, 50, 10000),
        HudHelpText = ensureString(noclip.hudHelpText, 'W/S: Frente/Tras | A/D: Esquerda/Direita | SPACE: Subir | SHIFT: Descer | Scroll Frente: +Vel | Scroll Tras: -Vel'),

        IncreaseSpeedControl = normalizeControlList(controls.increaseSpeed, DEFAULT_CONTROLS.increaseSpeed),
        DecreaseSpeedControl = normalizeControlList(controls.decreaseSpeed, DEFAULT_CONTROLS.decreaseSpeed),
        UpControl = normalizeControlList(controls.up, DEFAULT_CONTROLS.up),
        DownControl = normalizeControlList(controls.down, DEFAULT_CONTROLS.down),
        ForwardControl = normalizeControlList(controls.forward, DEFAULT_CONTROLS.forward),
        BackwardControl = normalizeControlList(controls.backward, DEFAULT_CONTROLS.backward),
        LeftControl = normalizeControlList(controls.left, DEFAULT_CONTROLS.left),
        RightControl = normalizeControlList(controls.right, DEFAULT_CONTROLS.right),
        BlockedControls = normalizeControlList(controls.blocked, DEFAULT_CONTROLS.blocked),

        Behavior = {
            invincible = ensureBoolean(behavior.invincible, true),
            invisible = ensureBoolean(behavior.invisible, true),
            freezeEntity = ensureBoolean(behavior.freezeEntity, true),
            disableCollision = ensureBoolean(behavior.disableCollision, false),
            preventRagdoll = ensureBoolean(behavior.preventRagdoll, false),
        }
    }
end

local Noclip = normalizeNoclipConfig(Config)

local Enabled = false
local SpeedLevels = Noclip.SpeedLevels
local SpeedIndex = Noclip.DefaultSpeedIndex
local Speed = SpeedLevels[SpeedIndex]
local ShowHud = Noclip.ShowHud
local FrozenEntity = nil
local HudThreadRunning = false
local EnsureHudThread

local function setEntityCollisionState(entity, enabled)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return
    end

    if Noclip.Behavior.disableCollision then
        SetEntityCollision(entity, enabled, enabled)
    end
end

local function setPedRagdollState(ped, enabled)
    if not ped or ped == 0 or type(SetPedCanRagdoll) ~= 'function' then
        return
    end

    if Noclip.Behavior.preventRagdoll then
        SetPedCanRagdoll(ped, enabled)
    end
end

local function ToggleNoclip()
    Enabled = not Enabled

    local entity = GetNoClipTarget()
    local ped = PlayerPedId()

    if Enabled then
        SetEntityInvincible(ped, Noclip.Behavior.invincible)
        setPedRagdollState(ped, false)

        if entity ~= 0 and GetEntityType(entity) == 1 then
            ClearPedTasksImmediately(entity, false, false)
        end

        FrozenEntity = entity
        if Noclip.Behavior.freezeEntity and entity ~= 0 then
            FreezeEntityPosition(entity, true)
            SetEntityHeading(entity, TranslateHeading(entity, GetEntityHeading(entity)))
        end

        setEntityCollisionState(entity, false)

        if Noclip.Behavior.invisible then
            SetEntityVisible(ped, false, false)
        else
            SetEntityVisible(ped, true, false)
        end

        EnsureHudThread()
        return
    end

    SetEntityInvincible(ped, false)
    setPedRagdollState(ped, true)
    SetEntityVisible(ped, true, false)

    if FrozenEntity ~= nil and FrozenEntity ~= 0 and DoesEntityExist(FrozenEntity) then
        if Noclip.Behavior.freezeEntity then
            FreezeEntityPosition(FrozenEntity, false)
        end
        setEntityCollisionState(FrozenEntity, true)
    end

    FrozenEntity = nil
end

function GetNoClipTarget()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local mount = GetMount(ped)
    return (veh == 0 and (mount == 0 and ped or mount) or veh)
end

function TranslateHeading(entity, h)
    if GetEntityType(entity) == 1 then
        return (h + 180) % 360
    end

    return h
end

function DrawHudText(text, x, y, centered)
    SetTextScale(0.30, 0.30)
    SetTextColor(255, 255, 255, 255)
    SetTextCentre(centered)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextFontForCurrentCommand(0)
    DisplayText(CreateVarString(10, 'LITERAL_STRING', text), x, y)
end

local function DrawNoclipFixedHud()
    DrawHudText(string.format('NOCLIP | Velocidade: %.1f (%d/%d)', Speed, SpeedIndex, #SpeedLevels), 0.5, 0.90, true)
    DrawHudText(Noclip.HudHelpText, 0.5, 0.93, true)
end

EnsureHudThread = function()
    if HudThreadRunning then
        return
    end

    HudThreadRunning = true

    CreateThread(function()
        while Enabled and ShowHud do
            DrawNoclipFixedHud()
            Wait(0)
        end

        HudThreadRunning = false
    end)
end

function SetSpeedIndex(value)
    local index = math.floor(tonumber(value) or 1)
    if index < 1 then index = 1 end
    if index > #SpeedLevels then index = #SpeedLevels end

    SpeedIndex = index
    Speed = SpeedLevels[SpeedIndex]
end

function CheckControls(func, pad, controls)
    if type(controls) == 'number' then
        return func(pad, controls)
    end

    for _, control in ipairs(controls) do
        if func(pad, control) then
            return true
        end
    end

    return false
end

function DisableControls(pad, controls)
    if type(controls) == 'number' then
        DisableControlAction(pad, controls, true)
        return
    end

    for _, control in ipairs(controls) do
        DisableControlAction(pad, control, true)
    end
end

CreateThread(function()
    while true do
        if not Enabled then
            Wait(Noclip.IdleWaitMs)
        else
            local sleep = 0

            DisableControls(0, Noclip.IncreaseSpeedControl)
            DisableControls(0, Noclip.DecreaseSpeedControl)
            DisableControls(0, Noclip.BlockedControls)

            local forward = CheckControls(IsDisabledControlPressed, 0, Noclip.ForwardControl)
            local backward = CheckControls(IsDisabledControlPressed, 0, Noclip.BackwardControl)
            local moveLeft = CheckControls(IsDisabledControlPressed, 0, Noclip.LeftControl)
            local moveRight = CheckControls(IsDisabledControlPressed, 0, Noclip.RightControl)
            local movingUp = CheckControls(IsDisabledControlPressed, 0, Noclip.UpControl)
            local movingDown = CheckControls(IsDisabledControlPressed, 0, Noclip.DownControl)
            local speedUp = CheckControls(IsDisabledControlJustReleased, 0, Noclip.IncreaseSpeedControl)
            local speedDown = CheckControls(IsDisabledControlJustReleased, 0, Noclip.DecreaseSpeedControl)

            local anyInput = forward or backward or moveLeft or moveRight or movingUp or movingDown or speedUp or speedDown
            if not anyInput then
                Wait(sleep)
                goto continue
            end

            DisableFirstPersonCamThisFrame()

            local entity = GetNoClipTarget()
            if entity ~= FrozenEntity then
                if FrozenEntity and DoesEntityExist(FrozenEntity) then
                    if Noclip.Behavior.freezeEntity then
                        FreezeEntityPosition(FrozenEntity, false)
                    end
                    setEntityCollisionState(FrozenEntity, true)
                end

                FrozenEntity = entity
                if Noclip.Behavior.freezeEntity and entity ~= 0 then
                    FreezeEntityPosition(entity, true)
                end
                setEntityCollisionState(entity, false)
            end

            if entity == 0 or not DoesEntityExist(entity) then
                Wait(0)
                goto continue
            end

            local ped = PlayerPedId()
            if Noclip.Behavior.invisible then
                SetEntityVisible(ped, false, false)
            else
                SetEntityVisible(ped, true, false)
            end

            local coords = GetEntityCoords(entity)
            local x, y, z = coords.x, coords.y, coords.z
            local h = TranslateHeading(entity, GetEntityHeading(entity))

            if speedUp then
                SetSpeedIndex(SpeedIndex + 1)
            end
            if speedDown then
                SetSpeedIndex(SpeedIndex - 1)
            end

            if movingUp then
                z = z + Speed
            end
            if movingDown then
                z = z - Speed
            end

            if forward or backward or moveLeft or moveRight then
                local r = -h * math.pi / 180
                local dx = Speed * math.sin(r)
                local dy = Speed * math.cos(r)

                if forward then
                    x = x + dx
                    y = y + dy
                end

                if backward then
                    x = x - dx
                    y = y - dy
                end

                if moveLeft then
                    x = x - dy
                    y = y + dx
                end

                if moveRight then
                    x = x + dy
                    y = y - dx
                end
            end

            if forward or backward or moveLeft or moveRight or movingUp or movingDown then
                local rot = GetGameplayCamRot(2)
                h = rot.z
            end

            SetEntityCoordsNoOffset(entity, x, y, z)
            SetEntityHeading(entity, TranslateHeading(entity, h))
            Wait(sleep)
        end

        ::continue::
    end
end)

RegisterNetEvent('bilto_admin:client:noclip:setEnabled', function(state)
    local shouldEnable = state == true
    if shouldEnable == Enabled then
        return
    end

    ToggleNoclip()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and Enabled then
        ToggleNoclip()
    end
end)
