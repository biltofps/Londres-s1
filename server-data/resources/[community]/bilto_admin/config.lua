Config = Config or {}

-- ## Permissions ## (mesmos grupos rsgcore.<group> do server.cfg)
-- Checked from top to bottom: the first group the player has is the one applied, so keep
-- the highest group first. A player gets a group from server.cfg or from the panel.
-- The group with `all_permissions = true` (GOD) is fixed: it sees everything and is the only
-- one that edits the other roles and gives them to players in the panel ("Permissoes" tab).
-- The permissions below are only the starting value of each role: on first start they are
-- saved in the database (with the hierarchy applied) and from then on the panel is what counts.
-- Options a role can't use are hidden from its NUI.
Config.FrameworkRoles = {
    -- ###################### GOD ######################
    {
        group = 'god',
        label = 'God',
        permissions = {
            all_permissions = true
        }
    },
    -- ################### HEADADMIN ###################
    {
        group = 'headadmin',
        label = 'Head Admin',
        permissions = {}
    },
    -- ################### DEVELOPER ###################
    {
        group = 'developer',
        label = 'Developer',
        permissions = {
            addMoney = true,
            removeMoney = true,
            addWeight = true,
            addSlots = true,
            spawnAdminHorse = true
        }
    },
    -- ##################### ADMIN #####################
    {
        group = 'admin',
        label = 'Admin',
        permissions = {
            editBan = true,
            removeBan = true,
            setJob = true,
            upsertMultijobJob = true,
            removeJob = true,
            addItem = true,
            checkItemCapacity = true,
            clearInventory = true,
            renameCharacter = true,
            changeHeight = true,
            openCompanyStash = true,
            manageTeleportLocations = true,
            executeLightning = true
        }
    },
    -- ##################### MOD #######################
    {
        group = 'mod',
        label = 'Moderador',
        permissions = {
            toggleFreeze = true,
            kick = true,
            banPlayer = true,
            viewBannedPlayers = true,
            openInventory = true,
            togglePlayerBlips = true,
            togglePlayerWall = true
        }
    },
    -- #################### HELPER #####################
    {
        group = 'helper',
        label = 'Helper',
        permissions = {
            ['goto'] = true,
            bring = true,
            revive = true,
            heal = true,
            spectate = true,
            privateMessage = true,
            teleportToCoords = true,
            copyCoords = true,
            viewUtilitiesPanel = true,
            toggleNoclip = true
        }
    }
}

-- Permission Group Inheritance Hierarchy (igual ao server.cfg: { grupo, herda_de })
Config.FrameworkHierarchy = {
    { 'god', 'headadmin' },       -- GOD inherits HEADADMIN rights
    { 'headadmin', 'developer' }, -- HEADADMIN inherits DEVELOPER rights
    { 'developer', 'admin' },     -- DEVELOPER inherits ADMIN rights
    { 'admin', 'mod' },           -- ADMIN inherits MOD rights
    { 'mod', 'helper' }           -- MOD inherits HELPER rights
}

-- Optional panel command name used by runtime normalization.
Config.Command = 'admin'

-- Default private message duration shown to the target player (ms).
Config.PrivateMessageDuration = 9000

-- Active locale key (must exist in locale.lua).
Config.Locale = 'en'

-- One Discord webhook per completed admin action. Leave an URL empty to disable its log.
Config.Webhooks = {
    ['goto'] = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    bring = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    revive = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    heal = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    executeLightning = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    toggleFreeze = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    spectate = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    openInventory = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    openCompanyStash = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    togglePlayerBlips = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    togglePlayerWall = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    toggleNoclip = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    spawnAdminHorse = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    kick = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    privateMessage = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    setJob = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    upsertMultijobJob = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    removeJob = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    banPlayer = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    editBan = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    removeBan = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    addItem = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    checkItemCapacity = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    addMoney = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    removeMoney = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    addWeight = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    addSlots = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    renameCharacter = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    changeHeight = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    clearInventory = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    permissionAddPlayer = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    permissionUpdatePlayer = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    permissionRemovePlayer = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    permissionPresetUpdate = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc',
    deleteCharacterByCitizenid = 'https://discord.com/api/webhooks/1503625558087569478/AKgQ_4zCI5ha1VEZctbifr-00bfSbg7Wufr0ijGpbz96J1wTdcnWw795pjMt3pcoNLMc'
}

-- UI and NUI runtime behavior.
Config.Ui = {
    title = 'Bilto Admin',
    refreshCooldownMs = 1500,
    modalDebug = false,
    openKeyHash = 0x3C3DD371, -- PGDN (RSGCore.KeyBinds['PGDN'])
    openKeyDebounceMs = 300
}

-- Notification timing (milliseconds).
Config.Notifications = {
    defaultDuration = 3000,
    adminDuration = 5000,
    targetDuration = 5200
}

-- Job behavior used by "remove job" fallback.
Config.Jobs = {
    removeJobTarget = {
        name = 'unemployed',
        grade = 0
    }
}

-- Money types available in panel actions and dashboard summaries.
Config.MoneyTypes = {
    { label = 'Dollar', value = 'cash' },
    { label = 'Gold', value = 'gold' },
    { label = 'Dirty Money', value = 'bloodmoney' },
    { label = 'Valentine Bank', value = 'valbank' },
    { label = 'Armadillo Bank', value = 'armbank' },
    { label = 'Rhodes Bank', value = 'rhobank' },
    { label = 'Blackwater Bank', value = 'blkbank' },
    { label = 'Saint Denis Bank', value = 'bank' }
}

-- Framework base money type for "cash on hand".
Config.Money = {
    cashType = 'cash'
}

-- Storage settings for custom panel permissions.
Config.Permissions = {
    tableName = 'bilto_admin_permissions',
    -- Permissions of each framework role, edited by GOD in the panel (seeded from Config.FrameworkRoles).
    presetsTableName = 'bilto_admin_role_permissions'
}

-- Optional custom action catalog/permission overrides.
Config.PanelActions = {
    manage = {},
    definitions = {}
}

-- Ban settings used by moderation actions.
Config.Ban = {
    defaultReason = 'Banido pela administracao.',
    dayPresets = { 1, 3, 7, 15, 30 },
    maxDays = 3650,
    permanentExpire = 2147483647
}

-- Server-side cache/performance tuning.
Config.Performance = {
    globalMoneyCacheMs = 15000,
    blipPlayersCacheMs = 300
}

-- Safety limits for admin actions.
Config.Limits = {
    moneyActionMax = 100000000,
    addItemAmountMax = 1000,
    checkItemAmountMax = 1000,
    addWeightAmountMax = 100000000,
    addSlotsAmountMax = 1000
}

-- Security and anti-spam controls.
Config.Security = {
    panelStateCacheMs = 350,
    wallWeaponStateMinIntervalMs = 90,
    actionLockEnabled = true
}

-- Optional structured logs.
Config.Observability = {
    enabled = false,
    logActions = false
}

-- Shared visual settings for administrative action webhooks.
Config.Webhook = {
    username = 'Bilto Admin',
    avatarUrl = '',
    color = 3447003
}


-- Client update intervals and wall text rendering.
Config.Client = {
    tracking = {
        activeIntervalMs = 500
    },
    wallText = {
        maxDistance = 300.0,
        zOffset = 1.0,
        idleWaitMs = 250,
        titleColor = '~t7~',
        resetColor = '~q~'
    },
    wallWeaponState = {
        stateBagKey = 'bitinho_wall_weapon',
        armedIntervalMs = 180,
        unarmedIntervalMs = 450
    }
}

-- Noclip settings.
Config.Noclip = {
    command = 'nc',
    speedLevels = { 0.5 ,1, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0 },
    defaultSpeedIndex = 0.5,
    showHud = true,
    idleWaitMs = 400,
    hudHelpText = 'W/S: Frente/Tras | A/D: Esquerda/Direita | SPACE: Subir | SHIFT: Descer | Scroll Frente: +Vel | Scroll Tras: -Vel',
    controls = {
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
            0x3076E97C
        }
    },
    behavior = {
        invincible = true,
        invisible = true,
        freezeEntity = true,
        disableCollision = false,
        preventRagdoll = false
    }
}

-- Developer horse catalog and default horse stats.
Config.Developer = {
    horseOverpower = 5000.0,
    adminHorses = {
        {
            id = 'arabian_white',
            label = 'Arabian White',
            model = 'a_c_horse_arabian_white',
            image = 'https://images.pexels.com/photos/635499/pexels-photo-635499.jpeg?auto=compress&cs=tinysrgb&w=640&h=360&fit=crop'
        },
        {
            id = 'missouri_foxtrotter',
            label = 'Missouri Foxtrotter',
            model = 'a_c_horse_missourifoxtrotter_sablechampagne',
            image = 'https://images.pexels.com/photos/1996333/pexels-photo-1996333.jpeg?auto=compress&cs=tinysrgb&w=640&h=360&fit=crop'
        },
        {
            id = 'nokota_whiteroan',
            label = 'Nokota Whiteroan',
            model = 'a_c_horse_nokota_whiteroan',
            image = 'https://images.pexels.com/photos/1996332/pexels-photo-1996332.jpeg?auto=compress&cs=tinysrgb&w=640&h=360&fit=crop'
        },
        {
            id = 'turkoman_gold',
            label = 'Turkoman Gold',
            model = 'a_c_horse_turkoman_gold',
            image = 'https://images.pexels.com/photos/1996335/pexels-photo-1996335.jpeg?auto=compress&cs=tinysrgb&w=640&h=360&fit=crop'
        },
        {
            id = 'thoroughbred_reverse',
            label = 'Thoroughbred',
            model = 'a_c_horse_thoroughbred_reversedappleblack',
            image = 'https://images.pexels.com/photos/259280/pexels-photo-259280.jpeg?auto=compress&cs=tinysrgb&w=640&h=360&fit=crop'
        }
    }
}

-- Built-in "cities" teleport locations shown on the Teleports tab (towns category only).
Config.Teleports = {
    { id = 'valentine', name = 'Valentine', description = 'Cidade de pecuaria no Heartlands', x = -302.7, y = 799.8, z = 118.5, heading = 0.0 },
    { id = 'saintdenis', name = 'Saint Denis', description = 'Maior cidade e centro industrial', x = 2638.9, y = -1180.5, z = 51.5, heading = 0.0 },
    { id = 'blackwater', name = 'Blackwater', description = 'Cidade moderna no Great Plains', x = -815.1, y = -1279.5, z = 44.4, heading = 0.0 },
    { id = 'strawberry', name = 'Strawberry', description = 'Cidade nas montanhas do Big Valley', x = -1749.8, y = -218.4, z = 158.2, heading = 0.0 },
    { id = 'rhodes', name = 'Rhodes', description = 'Cidade sulista em Lemoyne', x = 1332.9, y = -1305.3, z = 77.9, heading = 0.0 },
    { id = 'armadillo', name = 'Armadillo', description = 'Cidade deserta no New Austin', x = -3685.2, y = -2610.8, z = -13.4, heading = 0.0 },
    { id = 'tumbleweed', name = 'Tumbleweed', description = 'Cidade fantasma no New Austin', x = -5487.5, y = -2933.6, z = -1.4, heading = 0.0 },
    { id = 'annesburg', name = 'Annesburg', description = 'Cidade de mineracao em Roanoke Ridge', x = 2933.4, y = 1345.6, z = 44.1, heading = 0.0 },
    { id = 'vanhorn', name = 'Van Horn Trading Post', description = 'Posto de comercio no Rio Lannahechee', x = 2965.8, y = 566.9, z = 44.5, heading = 0.0 }
}
