local RSGCore = exports['rsg-core']:GetCoreObject()

local TABLE = 'bilto_natal_ranking'

local round    = nil   -- { props = { [id] = vector3 }, left = n, endsAt = os.time() }
local starting = false -- contagem regressiva em andamento
local roundId  = 0

local function Debug(msg, ...)
    if Config.Debug then print(('[bilto_natal] ' .. msg):format(...)) end
end

local function Notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, {
        title = Config.Text.event_name, description = text, type = kind or 'inform', duration = 5000,
    })
end

local function Announce(target, data)
    TriggerClientEvent('bilto_natal:client:announce', target, data)
end

--------------------------------------------------------------------------------
-- periodo do evento
--------------------------------------------------------------------------------
local function Stamp(t)
    return os.time({ year = tonumber(os.date('%Y')), month = t.month, day = t.day, hour = t.hour, min = t.min, sec = 0 })
end

local function InPeriod()
    if Config.TestMode then return true end
    local now = os.time()
    return now >= Stamp(Config.Period.start) and now <= Stamp(Config.Period.finish)
end

local function Minutes(key)
    return (Config.TestMode and Config['Test' .. key] or Config[key]) * 60
end

local function FormatTime(sec)
    if sec >= 60 then return Config.Text.minutes:format(math.ceil(sec / 60)) end
    return Config.Text.seconds:format(sec)
end

--------------------------------------------------------------------------------
-- banco de dados
--------------------------------------------------------------------------------
MySQL.ready(function()
    MySQL.query.await(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `citizenid` VARCHAR(50) NOT NULL,
            `name` VARCHAR(100) NOT NULL DEFAULT '',
            `points` INT NOT NULL DEFAULT 0,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`citizenid`)
        )
    ]]):format(TABLE))
end)

local function CharName(Player)
    local c = Player.PlayerData.charinfo or {}
    local name = ('%s %s'):format(c.firstname or '', c.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')
    return name
end

local function AddPoints(Player, amount)
    local cid = Player.PlayerData.citizenid
    MySQL.query.await(('INSERT INTO `%s` (citizenid, name, points) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE points = points + VALUES(points), name = VALUES(name)'):format(TABLE),
        { cid, CharName(Player), amount })
    local row = MySQL.single.await(('SELECT points FROM `%s` WHERE citizenid = ?'):format(TABLE), { cid })
    return row and row.points or amount
end

--------------------------------------------------------------------------------
-- rodadas
--------------------------------------------------------------------------------
local function Nearest(props, c)
    local best = math.huge
    for _, p in pairs(props) do
        local d = #(p.xy - c.xy)
        if d < best then best = d end
    end
    return best
end

--------------------------------------------------------------------------------
-- historico: lugares onde ja teve presente nunca se repetem (salvo em history.json)
--------------------------------------------------------------------------------
local HISTORY_FILE = 'history.json'
local history = {} -- { { vector2, ... } por rodada, da mais antiga para a mais nova }

do
    local raw = LoadResourceFile(GetCurrentResourceName(), HISTORY_FILE)
    local ok, data = pcall(json.decode, raw or '[]')
    for _, r in ipairs(ok and type(data) == 'table' and data or {}) do
        local list = {}
        for _, p in ipairs(r) do list[#list + 1] = vector2(p[1], p[2]) end
        history[#history + 1] = list
    end
end

local function SaveHistory(props)
    local list = {}
    for _, p in pairs(props) do list[#list + 1] = p.xy end
    history[#history + 1] = list
    while Config.HistoryRounds > 0 and #history > Config.HistoryRounds do table.remove(history, 1) end

    local out = {}
    for i, r in ipairs(history) do
        out[i] = {}
        for j, p in ipairs(r) do out[i][j] = { math.floor(p.x * 10) / 10, math.floor(p.y * 10) / 10 } end
    end
    SaveResourceFile(GetCurrentResourceName(), HISTORY_FILE, json.encode(out), -1)
end

local function NearestUsed(c)
    local best = math.huge
    for _, r in ipairs(history) do
        for _, p in ipairs(r) do
            local d = #(p - c.xy)
            if d < best then best = d end
        end
    end
    return best
end

-- 1 ou mais = lugar livre (longe dos outros presentes da rodada e de tudo que ja foi usado)
local function Score(props, c)
    return math.min(Nearest(props, c) / Config.MinDistance, NearestUsed(c) / Config.NoRepeatDistance)
end

-- tenta ate 30 lugares de gen(); sem lugar livre (mapa saturado), fica o melhor que achou
local function PickFree(props, gen)
    local best, bestS
    for _ = 1, 30 do
        local cand = gen()
        local s = Score(props, cand)
        if s >= 1 then return cand end
        if not bestS or s > bestS then best, bestS = cand, s end
    end
    return best
end

-- anel em volta do ponto, entre MinDistance e ExtraRadius
local function Ring(c)
    local a = math.random() * math.pi * 2
    local r = Config.MinDistance + math.random() * math.max(0, Config.ExtraRadius - Config.MinDistance)
    return vector3(c.x + math.cos(a) * r, c.y + math.sin(a) * r, c.z)
end

local function RandomTown()
    return Config.Locations[math.random(#Config.Locations)]
end

-- ponto qualquer dentro das regioes de terra, sorteando a regiao pelo tamanho (area maior, mais presentes)
local regionArea = 0
for _, r in ipairs(Config.Regions) do
    r.area = (r.max.x - r.min.x) * (r.max.y - r.min.y)
    regionArea = regionArea + r.area
end

local function RandomPoint()
    local pick = math.random() * regionArea
    for _, r in ipairs(Config.Regions) do
        pick = pick - r.area
        if pick <= 0 then
            return vector3(r.min.x + math.random() * (r.max.x - r.min.x), r.min.y + math.random() * (r.max.y - r.min.y), r.z)
        end
    end
end

-- o server nao sabe onde tem agua: pede para um jogador online filtrar os candidatos
-- sem jogador ou sem resposta, usa os candidatos como estao (o client confere de novo ao criar o prop)
local function FilterDry(list)
    local players = GetPlayers()
    if #players == 0 then return list end
    local src = tonumber(players[math.random(#players)])
    local p, done = promise.new(), false
    lib.callback('bilto_natal:client:dry', src, function(ok) if not done then done = true p:resolve(ok) end end, list)
    SetTimeout(4000, function() if not done then done = true p:resolve(nil) end end)
    local ok = Citizen.Await(p)
    if type(ok) ~= 'table' then return list end
    local dry = {}
    for _, i in ipairs(ok) do
        if list[i] then dry[#dry + 1] = list[i] end
    end
    return dry
end

-- tudo sorteado: TownShare em volta das cidades (Locations), o resto espalhado pelo mapa (Regions)
-- cada presente longe dos outros (MinDistance) e de onde ja teve presente (NoRepeatDistance)
local function PickLocations()
    local total = Config.PropsPerRound
    local towns = math.floor(total * Config.TownShare + 0.5)
    local props = {}

    for _ = 1, towns do props[#props + 1] = PickFree(props, function() return Ring(RandomTown()) end) end

    local wild = {}
    for i = 1, (total - towns) * 6 do wild[i] = RandomPoint() end
    for _, cand in ipairs(FilterDry(wild)) do
        if #props >= total then break end
        if Score(props, cand) >= 1 then props[#props + 1] = cand end
    end

    -- faltou lugar seco e livre no mapa: completa em volta das cidades
    while #props < total do props[#props + 1] = PickFree(props, function() return Ring(RandomTown()) end) end

    SaveHistory(props)
    return props
end

local function EndRound(allFound)
    if not round then return end
    round = nil
    TriggerClientEvent('bilto_natal:client:clear', -1)
    local text = allFound and Config.Text.ended_all or Config.Text.ended
    Announce(-1, { title = Config.Text.ended_title, text = text:format(Config.Command), duration = 8000 })
    Debug('rodada encerrada (todos encontrados: %s)', tostring(allFound == true))
end

local function StartRound()
    if round or starting then return false end
    starting = true
    local props = PickLocations() -- antes da contagem: pode esperar ate 4s pelo filtro de agua
    Announce(-1, { title = Config.Text.event_name, text = Config.Text.countdown, countdown = Config.Countdown })
    Wait(Config.Countdown * 1000)

    roundId = roundId + 1
    local myId = roundId
    round = { props = props, left = #props, moves = {}, endsAt = os.time() + Config.RoundDuration * 60 }
    starting = false

    TriggerClientEvent('bilto_natal:client:spawn', -1, props)
    Announce(-1, { title = Config.Text.started_title, text = Config.Text.started:format(#props), duration = 8000 })
    Debug('rodada %s iniciada com %s presentes', myId, #props)

    CreateThread(function()
        while round and roundId == myId and os.time() < round.endsAt do Wait(1000) end
        if round and roundId == myId then EndRound(false) end
    end)
    return true
end

-- agenda: uma rodada a cada Interval enquanto o periodo estiver aberto
CreateThread(function()
    math.randomseed(os.time())
    local nextAt = os.time() + Minutes('FirstRoundDelay')
    local warned = {}
    while true do
        Wait(1000)
        local now = os.time()
        if not InPeriod() then
            nextAt, warned = now + Minutes('FirstRoundDelay'), {}
        elseif not round and not starting then
            local left = nextAt - now
            -- um aviso por vez, com o tempo que falta de verdade (varios avisos vencidos juntos viram um so)
            local due = false
            for _, w in ipairs(Config.Warnings) do
                if left <= w and left > Config.Countdown and not warned[w] then
                    warned[w], due = true, true
                end
            end
            if due then
                Announce(-1, { title = Config.Text.event_name, text = Config.Text.warning:format(FormatTime(left)), duration = 6000 })
            end
            if left <= Config.Countdown then
                nextAt, warned = now + Minutes('Interval'), {}
                CreateThread(StartRound)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- eventos
--------------------------------------------------------------------------------
RegisterNetEvent('bilto_natal:server:collect', function(id)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not round or type(id) ~= 'number' then return end
    local pos = round.props[id]
    if not pos then return Notify(src, Config.Text.too_late, 'error') end

    -- sem OneSync o server nao sabe a posicao do ped (0,0,0): pula a conferencia
    local pc = GetEntityCoords(GetPlayerPed(src))
    if pc ~= vector3(0, 0, 0) and #(pc.xy - pos.xy) > Config.ServerMaxDistance then
        return Notify(src, Config.Text.too_far, 'error')
    end

    -- remove antes de qualquer await: dois jogadores no mesmo presente, so um leva
    round.props[id] = nil
    round.left = round.left - 1
    local last = round.left <= 0
    TriggerClientEvent('bilto_natal:client:remove', -1, id)

    local total = AddPoints(Player, Config.PointsPerProp)
    Notify(src, Config.Text.collected:format(Config.PointsPerProp, total), 'success')
    Debug('%s pegou o presente %s (%s pontos)', CharName(Player), id, total)

    if last then EndRound(true) end
end)

-- o client chegou perto e o presente caiu na agua (ou sem chao): leva para perto de uma cidade
-- no maximo 3 vezes por presente, depois ele sai da rodada
RegisterNetEvent('bilto_natal:server:bad', function(id)
    if not round or type(id) ~= 'number' or not round.props[id] then return end
    local moves = (round.moves[id] or 0) + 1
    round.moves[id] = moves
    if moves > 3 then
        round.props[id] = nil
        round.left = round.left - 1
        TriggerClientEvent('bilto_natal:client:remove', -1, id)
        if round.left <= 0 then EndRound(true) end
        return
    end
    round.props[id] = nil -- nao conta como vizinho dele mesmo
    local pos = PickFree(round.props, function() return Ring(RandomTown()) end)
    round.props[id] = pos
    TriggerClientEvent('bilto_natal:client:move', -1, id, pos)
    Debug('presente %s estava na agua, movido (%s/3)', id, moves)
end)

-- quem entra no meio da rodada recebe os presentes que ainda existem
RegisterNetEvent('bilto_natal:server:sync', function()
    if round then TriggerClientEvent('bilto_natal:client:spawn', source, round.props) end
end)

--------------------------------------------------------------------------------
-- comandos
--------------------------------------------------------------------------------
RSGCore.Commands.Add(Config.Command, Config.Text.help_rank, {}, false, function(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local top = MySQL.query.await(('SELECT name, points FROM `%s` WHERE points > 0 ORDER BY points DESC, updated_at ASC LIMIT ?'):format(TABLE),
        { Config.RankingSize }) or {}
    local me = MySQL.single.await(('SELECT points, (SELECT COUNT(*) + 1 FROM `%s` o WHERE o.points > p.points) AS pos FROM `%s` p WHERE citizenid = ?'):format(TABLE, TABLE),
        { Player.PlayerData.citizenid })
    TriggerClientEvent('bilto_natal:client:ranking', src, {
        top = top,
        me = { name = CharName(Player), points = me and me.points or 0, pos = me and me.pos or nil },
        active = round ~= nil,
        left = round and round.left or 0,
    })
end, 'user')

RSGCore.Commands.Add(Config.AdminStart, 'Evento de Natal: inicia uma rodada agora', {}, false, function(src)
    if round or starting then return Notify(src, Config.Text.already, 'error') end
    CreateThread(StartRound)
end, Config.AdminPermission)

RSGCore.Commands.Add(Config.AdminStop, 'Evento de Natal: encerra a rodada atual', {}, false, function(src)
    if not round then return Notify(src, Config.Text.no_round, 'error') end
    EndRound(false)
end, Config.AdminPermission)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then round = nil end
end)
