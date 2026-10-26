local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local blips = {}       -- [bankId] = blip
local blipState = {}   -- [bankId] = true (open) / false (closed)
local currentBank = nil

local function isOpen()
    if not Config.UseHours then return true end
    local h = GetClockHours()
    if Config.OpenHour < Config.CloseHour then
        return h >= Config.OpenHour and h < Config.CloseHour
    end
    return h >= Config.OpenHour or h < Config.CloseHour
end

local function closeUI()
    currentBank = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- every UI string is sent to the NUI from the active ox_lib locale
local UI_KEYS = {
    'ui_close', 'ui_customer', 'ui_founded', 'ui_branch', 'ui_branch_lbl', 'ui_account', 'ui_balance', 'ui_cash',
    'ui_maintenance', 'ui_maint_every', 'ui_maint_next', 'ui_free',
    'ui_welcome', 'ui_open_desc', 'ui_open_form', 'ui_holder', 'ui_open_fee', 'ui_open_account', 'ui_terms', 'ui_signature',
    'ui_greet_morning', 'ui_greet_afternoon', 'ui_greet_evening', 'ui_teller', 'ui_sheet_no', 'ui_approved', 'ui_missing',
    'ui_tab_deposit', 'ui_tab_withdraw', 'ui_tab_transfer', 'ui_deposit_desc', 'ui_withdraw_desc', 'ui_transfer_desc',
    'ui_amount', 'ui_target_cid', 'ui_all', 'ui_max_tx',
    'ui_current_balance', 'ui_after_balance', 'ui_cash_after', 'ui_deposit', 'ui_withdraw', 'ui_transfer',
    'ui_confirm_transfer', 'ui_confirm_desc', 'ui_from', 'ui_to', 'ui_cancel', 'ui_confirm',
    'ui_receipt', 'ui_receipt_opened', 'ui_receipt_deposit', 'ui_receipt_withdraw', 'ui_receipt_transfer',
    'ui_bank', 'ui_date', 'ui_receipt_id', 'ui_ok', 'ui_continue',
}
local uiLocales

local function getUILocales()
    if not uiLocales then
        uiLocales = {}
        for _, k in ipairs(UI_KEYS) do uiLocales[k] = locale(k) end
    end
    return uiLocales
end

local function pushData(data)
    if data then SendNUIMessage({ action = 'update', data = data }) end
end

RegisterNetEvent('rsg-banking:client:open', function(bankId)
    if currentBank or not Config.Banks[bankId] then return end
    if not isOpen() then
        lib.notify({ title = locale('cl_title'), description = locale('cl_bank_closed', Config.OpenHour, Config.CloseHour), type = 'error', duration = 5000 })
        return
    end
    local data = lib.callback.await('rsg-banking:server:getData', false, bankId)
    if not data then return end
    currentBank = bankId
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data, locales = getUILocales(), hour = GetClockHours() })
end)

RegisterNUICallback('close', function(_, cb) closeUI(); cb('ok') end)

-- NUI button -> server callback (current bank is always passed first) -> refreshed data back to the UI
local function nuiAction(name, cbName, ...)
    local args = { ... }
    RegisterNUICallback(name, function(d, cb)
        if currentBank then
            local params = {}
            for i, k in ipairs(args) do params[i] = d[k] end
            pushData(lib.callback.await(cbName, false, currentBank, table.unpack(params, 1, #args)))
        end
        cb('ok')
    end)
end

nuiAction('openAccount', 'rsg-banking:server:openAccount')
nuiAction('deposit',     'rsg-banking:server:deposit',  'amount')
nuiAction('withdraw',    'rsg-banking:server:withdraw', 'amount')
nuiAction('transfer',    'rsg-banking:server:transfer', 'target', 'amount')

-- close the menu if the player walks away or the bank closes
CreateThread(function()
    while true do
        if currentBank then
            Wait(1000)
            -- the menu may have been closed during the wait
            local bank = currentBank and Config.Banks[currentBank]
            if bank and (#(GetEntityCoords(cache.ped) - bank.coords) > Config.ServerMaxDistance or not isOpen()) then
                closeUI()
            end
        else
            Wait(2000)
        end
    end
end)

local function setBlipStatus(id, open)
    local blip = blips[id]
    if not blip or blipState[id] == open then return end
    if blipState[id] ~= nil then
        local old = blipState[id] and Config.Blip.openColor or Config.Blip.closedColor
        Citizen.InvokeNative(0xB059D7BD3D78C16F, blip, joaat(old)) -- BlipRemoveModifier
    end
    local new = open and Config.Blip.openColor or Config.Blip.closedColor
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(new))     -- BlipAddModifier
    blipState[id] = open
end

-- Doors: main doors (state 0) follow opening hours, the rest stay locked
local doorsOpen = nil

local function registerDoors()
    for _, d in ipairs(Config.BankDoors or {}) do
        if not Citizen.InvokeNative(0xC153C43EA202C8C1, d.door) then           -- IsDoorRegisteredWithSystem
            Citizen.InvokeNative(0xD99229FE93B46286, d.door, 1, 1, 0, 0, 0, 0)  -- AddDoorToSystemNew
        end
    end
end

local function setDoors(open, force)
    if doorsOpen == open and not force then return end
    for _, d in ipairs(Config.BankDoors or {}) do
        local state = (d.state == 0 and open) and 0 or 1
        Citizen.InvokeNative(0x6BAB9442830C7F53, d.door, state)                 -- DoorSystemSetDoorState
    end
    doorsOpen = open
end

-- Which bank (if any) the player is standing inside
local function bankInside()
    local ped = cache.ped
    if GetInteriorFromEntity(ped) == 0 then return nil end
    local pos = GetEntityCoords(ped)
    for id, bank in pairs(Config.Banks) do
        if #(pos - bank.coords) <= Config.Closing.insideRadius then return id end
    end
end

local function minutesToClose()
    local now = GetClockHours() * 60 + GetClockMinutes()
    local close = Config.CloseHour * 60
    return (close - now) % 1440
end

local function escortOut(id)
    local exit = Config.Banks[id].exit
    if not exit then return end
    DoScreenFadeOut(800)
    while not IsScreenFadedOut() do Wait(50) end
    SetEntityCoords(cache.ped, exit.x, exit.y, exit.z, false, false, false, false)
    SetEntityHeading(cache.ped, exit.w or 0.0)
    Wait(500)
    DoScreenFadeIn(800)
    lib.notify({ title = locale('cl_title'), description = locale('cl_escorted_out'), type = 'inform', duration = 6000 })
end

local warned, closedAt = false, nil

-- Main loop: opening hours -> doors, blips, closing-time handling
CreateThread(function()
    registerDoors()
    setDoors(isOpen(), true)
    local tick = 0
    while true do
        local open = isOpen()
        local inside = Config.UseHours and bankInside() or nil

        -- Closing soon warning (once per day, only while inside a bank)
        if open and inside and Config.Closing.warnHours > 0 then
            if not warned and minutesToClose() <= Config.Closing.warnHours * 60 then
                warned = true
                lib.notify({ title = locale('cl_title'), description = locale('cl_closing_soon', Config.CloseHour), type = 'warning', duration = 7000 })
            end
        elseif open == false then
            warned = false
        end

        -- After closing: doors stay usable for anyone still inside so they can walk out
        if not open and inside then
            if not closedAt then
                closedAt = GetGameTimer()
                lib.notify({ title = locale('cl_title'), description = locale('cl_bank_closed_leave'), type = 'warning', duration = 7000 })
            elseif Config.Closing.escort and GetGameTimer() - closedAt >= Config.Closing.graceSeconds * 1000 then
                escortOut(inside)
                closedAt = nil
            end
        else
            closedAt = nil
        end

        local doorsShouldOpen = open or inside ~= nil
        setDoors(doorsShouldOpen)
        tick = tick + 1
        if tick >= 6 then           -- periodically re-apply in case another script or streaming reset them
            tick = 0
            registerDoors()
            setDoors(doorsShouldOpen, true)
        end
        for id in pairs(blips) do setBlipStatus(id, open) end

        -- check more often while someone is inside a closed bank so doors lock soon after they leave
        Wait(inside and 2000 or (Config.Blip.updateInterval or 10000))
    end
end)

CreateThread(function()
    for id, bank in pairs(Config.Banks) do
        exports['rsg-core']:createPrompt('rsg_bank_' .. id, bank.coords, RSGCore.Shared.Keybinds[Config.OpenKey],
            locale('cl_open_bank', bank.label), {
                type = 'client', event = 'rsg-banking:client:open', args = { id },
            })
        if Config.Blip.enabled then
            local blip = BlipAddForCoords(1664425300, bank.coords.x, bank.coords.y, bank.coords.z)
            SetBlipSprite(blip, Config.Blip.sprite, true)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipName(blip, bank.label)
            blips[id] = blip
            setBlipStatus(id, isOpen())
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, b in pairs(blips) do RemoveBlip(b) end
    for id in pairs(Config.Banks) do exports['rsg-core']:deletePrompt('rsg_bank_' .. id) end
    SetNuiFocus(false, false)
end)
