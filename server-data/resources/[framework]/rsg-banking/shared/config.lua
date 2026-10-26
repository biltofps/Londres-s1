Config = {}

Config.OpenKey           = 'J'        -- RSGCore.Shared.Keybinds key
Config.ServerMaxDistance = 5.0        -- max distance from the bank for any transaction (server checked)
Config.Cooldown          = 500        -- ms between bank requests per player (anti-spam)
Config.MaxTransaction    = 100000     -- per single deposit/withdraw/transfer

-- Accounts: a player must open an account at each bank before using it.
-- Any bank in Config.Banks can override openFee / maintenanceFee with its own value.
Config.Account = {
    openFee         = 25,   -- cash paid to open an account (0 = free)
    maintenanceFee  = 5,    -- taken from that bank's balance every maintenanceDays (0 = off)
    maintenanceDays = 7,    -- real days between maintenance charges
    checkMinutes    = 30,   -- how often the server looks for accounts with maintenance due
}

-- Opening hours (in-game clock). Set Config.UseHours = false for 24/7 banks
Config.UseHours  = false
Config.OpenHour  = 7
Config.CloseHour = 21

-- Closing time: stop players getting locked inside
Config.Closing = {
    warnHours    = 1,      -- in-game hours before closing to warn players inside (0 = off)
    insideRadius = 15.0,   -- distance from a bank's coords that counts as "inside" (must also be in an interior)
    graceSeconds = 120,    -- real seconds a player may stay inside after closing before being escorted out
    escort       = true,   -- teleport lingering players to the bank's `exit` (only banks with an exit set)
}
-- Add `exit = vector4(x, y, z, heading)` to a bank below (a spot on the street outside its front door)
-- to enable escorting for that bank. Banks without an exit just keep their doors usable from inside.

-- Blip
Config.Blip = {
    enabled = true,
    sprite  = -2128054417,             -- bank blip
    scale   = 0.2,
    openColor   = 'BLIP_MODIFIER_MP_COLOR_8',   -- green when open
    closedColor = 'BLIP_MODIFIER_MP_COLOR_10',  -- red when closed
    updateInterval = 10000,                     -- ms between open/closed checks
}

-- Each bank is a RSG-Core money type (same list as bilto_admin Config.MoneyTypes).
-- Money deposited at a bank stays in that bank: it can only be withdrawn there.
-- Shown in the menu: monogram, motto, founding year, branch code and the teller who greets new customers.
Config.Banks = {
    valbank = {
        label    = 'Valentine Bank',
        coords   = vector3(-308.58, 776.07, 118.70),
        monogram = 'V',
        motto    = 'Confiança do criador ao vaqueiro',
        founded  = 1874,
        code     = '0417',
        teller   = 'Sr. Walter Hughes',
    },
    armbank = {
        label    = 'Armadillo Bank',
        coords   = vector3(-3666.25, -2626.57, -13.59),
        monogram = 'A',
        motto    = 'Firme como o deserto',
        founded  = 1881,
        code     = '0923',
        teller   = 'Sr. Ezekiel Parr',
    },
    rhobank = {
        label    = 'Rhodes Bank',
        coords   = vector3(1292.307, -1301.539, 77.04012),
        monogram = 'R',
        motto    = 'Tradição sulista desde 1866',
        founded  = 1866,
        code     = '0352',
        teller   = 'Sra. Abigail Gray',
    },
    blkbank = {
        label    = 'Blackwater Bank',
        coords   = vector3(-813.1633, -1277.486, 43.63771),
        monogram = 'B',
        motto    = 'O futuro passa por aqui',
        founded  = 1879,
        code     = '0688',
        teller   = 'Sr. Theodore Finch',
    },
    bank = {
        label    = 'Saint Denis Bank',
        coords   = vector3(2644.579, -1292.313, 52.24956),
        monogram = 'SD',
        motto    = 'A instituição da capital',
        founded  = 1858,
        code     = '0001',
        teller   = 'Sr. Archibald Pembrook',
    },
}

-- Bank doors. state = 0 -> unlocked while the bank is open, locked when closed
-- state = 1 -> always locked (vaults, back rooms)
Config.BankDoors = {

    -- valentine ( open = 0 / locked = 1)
    { door = 2642457609, state = 0 }, -- main door
    { door = 3886827663, state = 0 }, -- main door
    { door = 1340831050, state = 1 }, -- bared right
    { door = 2343746133, state = 1 }, -- bared left
    { door = 334467483,  state = 1 }, -- inner door1
    { door = 3718620420, state = 1 }, -- inner door2
    { door = 576950805,  state = 1 }, -- valut

    -- rhodes  ( open = 0 / locked = 1)
    { door = 3317756151, state = 0 }, -- main door
    { door = 3088209306, state = 0 }, -- main door
    { door = 2058564250, state = 1 }, -- inner door1
    { door = 3142122679, state = 1 }, -- inner door2
    { door = 1634148892, state = 1 }, -- inner door3
    { door = 3483244267, state = 1 }, -- valut

    -- saint denis ( open = 0 / locked = 1)
    { door = 2158285782, state = 0 }, -- main door
    { door = 1733501235, state = 0 }, -- main door
    { door = 2089945615, state = 0 }, -- main door
    { door = 2817024187, state = 0 }, -- main door
    { door = 1830999060, state = 1 }, -- inner private door
    { door = 965922748,  state = 1 }, -- manager door
    { door = 1634115439, state = 1 }, -- manager door
    { door = 1751238140, state = 1 }, -- vault

    -- blackwater
    { door = 531022111,  state = 0 }, -- main door
    { door = 2117902999, state = 1 }, -- inner door
    { door = 2817192481, state = 1 }, -- manager door
    { door = 1462330364, state = 1 }, -- vault door

    -- armadillo
    { door = 3101287960, state = 0 }, -- main door
    { door = 3550475905, state = 1 }, -- inner door
    { door = 1329318347, state = 1 }, -- inner door
    { door = 1366165179, state = 1 }, -- back door

}
