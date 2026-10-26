Config = {}

----------------------------------
-- comandos
----------------------------------
Config.EditorCommand = 'hud'        -- abre o editor da HUD
Config.ToggleCommand = 'togglehud'  -- liga/desliga a HUD (so para o proprio jogador)

----------------------------------
-- atualizacao
----------------------------------
Config.TickRate = 250 -- ms entre cada atualizacao dos valores da HUD

----------------------------------
-- regras visuais
----------------------------------
Config.LowThreshold = 25 -- abaixo disso (%) o status fica em alerta (pisca em vermelho)
Config.VoiceModes   = 3  -- quantidade de alcances de voz do pma-voice (sussurro/normal/grito)
Config.TempUnit     = 'C' -- 'C' (Celsius) ou 'F' (Fahrenheit)

----------------------------------
-- modelo padrao para quem nunca editou
-- opcoes (chaves de PRESETS em html/presets.js): classico, western, xerife, brasao, hexagonal,
-- octogonal, quadrado, medidor, orbes, blocos, pontilhado, anel, raios, colmeia, losango,
-- mira, turbina, bussola, cristal, bolinhas, quadradinhos, bateria, segmentos, barras, minimal
----------------------------------
Config.DefaultPreset = 'classico'

----------------------------------
-- logo do servidor (elemento "Logo do servidor" da HUD)
-- troque o arquivo html/assets/logo.png pela sua logo (PNG com fundo transparente fica melhor)
-- ou coloque um link direto aqui (ex.: 'https://i.imgur.com/xxxx.png'); vazio = usa o arquivo
----------------------------------
Config.LogoUrl = ''

----------------------------------
-- salvamento
----------------------------------
Config.SaveCooldown = 2000 -- ms minimo entre salvamentos do mesmo jogador
Config.MaxPresets   = 12   -- quantos presets proprios cada jogador pode salvar ("Meus presets")

--==================================================================
-- STATUS (substitui a logica do rsg-hud)
--==================================================================

----------------------------------
-- necessidades
----------------------------------
Config.StatusInterval = 5000 -- ms entre cada reducao de fome/sede
Config.HungerRate     = 0.01 -- quanto a fome cai por intervalo
Config.ThirstRate     = 0.01 -- quanto a sede cai por intervalo

----------------------------------
-- estresse
----------------------------------
Config.StressChance    = 0.1  -- chance (0-1) de ganhar estresse a cada tiro
Config.MinimumStress   = 50   -- a partir daqui a tela comeca a tremer
Config.MinimumSpeed    = 100  -- acima dessa velocidade (mph) em veiculo ganha estresse
Config.StressDecayRate = 0.01 -- quanto o estresse cai por intervalo

Config.StressShake = { -- intensidade do tremor por faixa de estresse
    { min = 50, max = 60,  intensity = 0.12 },
    { min = 60, max = 70,  intensity = 0.17 },
    { min = 70, max = 80,  intensity = 0.22 },
    { min = 80, max = 90,  intensity = 0.28 },
    { min = 90, max = 100, intensity = 0.32 },
}

Config.StressInterval = { -- intervalo (ms) entre efeitos por faixa de estresse
    { min = 50, max = 60,  timeout = { 50000, 60000 } },
    { min = 60, max = 70,  timeout = { 40000, 50000 } },
    { min = 70, max = 80,  timeout = { 30000, 40000 } },
    { min = 80, max = 90,  timeout = { 20000, 30000 } },
    { min = 90, max = 100, timeout = { 15000, 20000 } },
}

----------------------------------
-- esconder a HUD nativa do RDR2
----------------------------------
Config.HideNative = {
    playerHealth  = true,
    playerStamina = true,
    playerDeadEye = true,
    horseHealth   = true,
    horseStamina  = true,
    horseCourage  = true,
}

----------------------------------
-- minimapa / bussola
----------------------------------
Config.OnFootMinimap = false -- minimapa a pe
Config.OnFootCompass = false -- bussola a pe (quando o minimapa a pe esta desligado)
Config.MountMinimap  = true  -- minimapa montado / em veiculo
Config.MountCompass  = false -- bussola em vez do minimapa quando montado

----------------------------------
-- dano a saude
----------------------------------
Config.DoHealthDamage    = true  -- fome/sede zeradas, frio/calor e sujeira tiram vida
Config.DoHealthDamageFx  = false -- efeito de tela ao tomar dano
Config.DoHealthPainSound = true  -- som de dor ao tomar dano
Config.RemoveHealth      = 5     -- vida removida por frio/calor/sujeira

----------------------------------
-- temperatura
----------------------------------
Config.TempFeature = false -- true = roupas aquecem e frio/calor extremo tiram vida
Config.MinTemp = -5
Config.MaxTemp = 40

Config.ClothingWarmth = { -- quanto cada peca aquece (TempFeature precisa estar ligado)
    [0x9925C067] = 0,  -- chapeu
    [0x2026C46D] = 0,  -- camisa
    [0x1D4C528A] = 0,  -- calca
    [0x777EC6EF] = 0,  -- botas
    [0xE06D30CE] = 15, -- casaco
    [0x662AC34]  = 15, -- casaco aberto
    [0xEABE0032] = 0,  -- luvas
    [0x485EE834] = 0,  -- colete
    [0xAF14310B] = 0,  -- poncho
    [0xA0E3AB7F] = 0,  -- saia
    [0x3107499B] = 0,  -- perneiras
}

Config.NoWarmthJobs = { 'leo', 'medic' } -- tipos de job que nao ganham calor das roupas

----------------------------------
-- higiene
----------------------------------
Config.FlyEffect      = true -- moscas em volta do jogador quando sujo
Config.MinCleanliness = 30
