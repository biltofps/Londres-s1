Config = {}

Config.Debug = false

-- TESTE: ignora o periodo abaixo e usa os tempos de teste (rodadas a cada TestInterval)
-- para valer de verdade, troque para false
Config.TestMode = false

-- periodo do evento (horario do servidor, ano atual)
Config.Period = {
    start  = { month = 11, day = 20, hour = 0,  min = 0  },
    finish = { month = 11, day = 25, hour = 23, min = 55 },
}

-- tempos (minutos)
Config.Interval        = 120 -- uma rodada a cada 2 horas
Config.TestInterval    = 5   -- intervalo no modo teste
Config.FirstRoundDelay = 5   -- primeira rodada depois que o periodo abre / o script inicia
Config.TestFirstRoundDelay = 1
Config.RoundDuration   = 15  -- os presentes que ninguem pegou somem depois disso

-- avisos antes da rodada (segundos antes) e contagem regressiva final na tela
Config.Warnings  = { 300, 60 }
Config.Countdown = 5

-- som tocado no inicio da contagem regressiva (arquivo em html/sounds/)
Config.Sound = { file = 'natal.ogg', volume = 0.5 }

-- presentes
Config.PropsPerRound   = 50
Config.PointsPerProp   = 1
Config.Model           = 'p_crate03x' -- qualquer prop do jogo
Config.NoRepeatDistance = 50.0        -- presente novo nunca cai a menos de X metros de onde ja teve presente
Config.HistoryRounds   = 0            -- quantas rodadas o historico lembra (0 = todas). apagar history.json zera
Config.TownShare       = 0.3          -- 30% dos presentes perto das cidades (Locations), o resto espalhado pelo mapa (Regions)
Config.MinDistance     = 80.0         -- distancia minima entre dois presentes
Config.ExtraRadius     = 250.0        -- presentes extras (ou ponto ocupado) caem entre MinDistance e X metros de um ponto da lista
Config.SpawnDistance   = 150.0        -- o prop so e criado perto do jogador (o blip aparece no mapa inteiro)
Config.TargetDistance  = 2.0
Config.ServerMaxDistance = 8.0        -- o server confere a distancia do jogador ao pegar

Config.Blip = {
    sprite = 'blip_ambient_delivery',
    scale  = 0.2,
    color  = 'BLIP_MODIFIER_MP_COLOR_8',
}

-- comandos
Config.Command       = 'eventonatal' -- /eventonatal: abre o ranking
Config.RankingSize   = 10
Config.AdminStart    = 'natal_iniciar' -- forca uma rodada agora
Config.AdminStop     = 'natal_parar'   -- encerra a rodada atual
Config.AdminPermission = 'admin'

Config.Text = {
    event_name    = 'Evento de Natal',
    warning       = 'O Evento de Natal comeca em %s!',
    countdown     = 'O Evento de Natal vai comecar em',
    started_title = 'O EVENTO DE NATAL COMECOU!',
    started       = '%s presentes foram espalhados pelo mapa. Procure no mapa e pegue o maximo que puder!',
    ended_title   = 'Evento de Natal encerrado',
    ended         = 'A rodada acabou. Veja o ranking com /%s',
    ended_all     = 'Todos os presentes foram encontrados! Veja o ranking com /%s',
    blip          = 'Presente de Natal',
    target        = 'Pegar presente',
    collected     = '+%s ponto(s)! Voce tem %s pontos no evento.',
    too_late      = 'Alguem pegou esse presente antes de voce.',
    too_far       = 'Chegue mais perto do presente.',
    no_round      = 'Nenhuma rodada do evento esta acontecendo.',
    already       = 'Ja existe uma rodada acontecendo.',
    help_rank     = 'Ranking do Evento de Natal',
    minutes       = '%s minuto(s)',
    seconds       = '%s segundo(s)',
}

-- regioes de terra do mapa (retangulos aproximados). os presentes "espalhados" caem em um ponto qualquer
-- dentro delas; agua e descartada pelo client. z = altura media do terreno, so para o filtro de agua
Config.Regions = {
    { min = vector2(-5700.0, -3600.0), max = vector2(-2000.0, -2100.0), z = 10.0  }, -- New Austin
    { min = vector2(-2600.0, -2300.0), max = vector2(-300.0,   800.0),  z = 100.0 }, -- West Elizabeth
    { min = vector2(-2500.0,   800.0), max = vector2(1200.0,  2400.0),  z = 300.0 }, -- Ambarino (Grizzlies)
    { min = vector2(-300.0,  -1500.0), max = vector2(1800.0,   900.0),  z = 100.0 }, -- New Hanover / Heartlands / Scarlett Meadows
    { min = vector2(1800.0,  -1800.0), max = vector2(2900.0,     0.0),  z = 45.0  }, -- Bayou Nwa / Saint Denis
    { min = vector2(1800.0,      0.0), max = vector2(3100.0,  1800.0),  z = 100.0 }, -- Roanoke Ridge / Annesburg
}

-- cidades: parte dos presentes (TownShare) aparece perto delas, e o presente que cai na agua e levado para perto de uma
-- a altura (z) e ajustada no chao pelo client
Config.Locations = {
    vector3(-297.5, 791.3, 118.3),   -- Valentine
    vector3(-245.0, 760.0, 118.0),   -- Valentine (estabulo)
    vector3(-370.0, 720.0, 116.0),   -- Valentine (estacao)
    vector3(2632.0, -1312.0, 52.0),  -- Saint Denis
    vector3(2700.0, -1400.0, 46.4),  -- Saint Denis (mercado)
    vector3(2560.0, -1210.0, 53.4),  -- Saint Denis (norte)
    vector3(1225.0, -1305.0, 76.9),  -- Rhodes
    vector3(1340.0, -1300.0, 77.0),  -- Rhodes (leste)
    vector3(-813.0, -1324.0, 43.6),  -- Blackwater
    vector3(-750.0, -1260.0, 43.4),  -- Blackwater (norte)
    vector3(-1791.0, -386.0, 160.3), -- Strawberry
    vector3(2930.0, 1288.0, 44.6),   -- Annesburg
    vector3(2985.0, 570.0, 44.6),    -- Van Horn
    vector3(1420.0, 312.0, 88.5),    -- Emerald Ranch
    vector3(-3685.0, -2623.0, -13.4),-- Armadillo
    vector3(-5512.0, -2950.0, -1.8), -- Tumbleweed
    vector3(-1349.0, 2412.0, 307.0), -- Colter
    vector3(-337.0, -360.0, 88.0),   -- Flatneck Station
    vector3(-1094.0, -577.0, 82.4),  -- Riggs Station
    vector3(-2390.0, -2380.0, 61.0), -- MacFarlane's Ranch
    vector3(2108.0, -593.0, 41.6),   -- Lagras
    vector3(-5230.0, -3470.0, -20.0),-- Benedict Point
    vector3(-1960.0, -1600.0, 116.0),-- Manzanita Post
    vector3(500.0, 640.0, 110.0),    -- Heartland
}
