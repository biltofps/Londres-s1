Config = {}

Config.Debug = false

----------------------------------
-- NPC / interacao
----------------------------------
Config.SpawnDistance  = 25.0  -- distancia para criar/remover o NPC da loja
Config.TargetDistance = 2.5   -- alcance do ox_target (o rsg-inventory recusa a compra a mais de 10.0 da loja)
Config.FadeIn         = true  -- NPC aparece/some com fade
Config.DefaultScenario = 'WORLD_HUMAN_STAND_IMPATIENT'

----------------------------------
-- camera: foca no NPC enquanto a loja esta aberta (lojas sem NPC nao mudam a camera)
----------------------------------
Config.Focus = {
    enabled    = true,
    distance   = 1.3,  -- distancia da camera na frente do NPC
    side       = 0.0,  -- deslocamento lateral (negativo = esquerda do NPC)
    height     = 0.65, -- altura da camera (a partir do centro do NPC)
    lookHeight = 0.55, -- altura para onde a camera olha (rosto/peito)
    fov        = 45.0, -- menor = mais zoom
    ease       = 600,  -- ms da transicao de entrada/saida
}

----------------------------------
-- seguranca: fecha a loja depois de cada transacao (evita cliques repetidos / duplicacao)
----------------------------------
Config.CloseOnBuy  = true  -- fecha ao concluir uma compra
Config.CloseOnSell = true -- fecha ao concluir uma venda

----------------------------------
-- idioma dos textos do script: 'pt-br' ou 'en'
-- (nomes de lojas e categorias sao escritos direto em Config.Shops)
----------------------------------
Config.Locale = 'pt-br'

Config.Locales = {
    ['pt-br'] = {
        open      = 'Abrir %s',            -- %s = nome da loja
        no_job    = 'Você não tem permissão para usar esta loja.',
        too_far   = 'Você está longe demais da loja.',
        shop_name = 'Loja',
        bought    = 'Você comprou %sx %s por %s.', -- quantidade, item, total
        sold      = 'Você vendeu %sx %s por %s.',
        buys_tab  = 'Compramos',           -- aba com os itens que a loja compra
        hint      = 'Arraste para comprar · solte aqui para vender', -- frase abaixo do nome da loja
    },
    ['en'] = {
        open      = 'Open %s',
        no_job    = 'You are not allowed to use this shop.',
        too_far   = 'You are too far from the shop.',
        shop_name = 'Shop',
        bought    = 'You bought %sx %s for %s.',
        sold      = 'You sold %sx %s for %s.',
        buys_tab  = 'We buy',
        hint      = 'Drag to buy · drop here to sell',
    },
}

Config.Text = Config.Locales[Config.Locale] or Config.Locales['en']

----------------------------------
-- sons
-- file   = arquivo .ogg em html/sounds/ (opcional); volume de 0.0 a 1.0
-- native = som do proprio jogo (PlaySoundFrontend); toca se nao tiver file ou se o arquivo faltar
-- uma loja pode trocar os sons com: sounds = { open = {...} }
-- false desliga o som
----------------------------------
Config.Sounds = {
    open = { file = 'loja_porta.ogg', volume = 0.3, native = { name = 'INFO_SHOW', set = 'Ledger_Sounds' } }, -- ao abrir a loja
    buy  = { file = 'loja_compra.ogg', volume = 0.3, native = { name = 'PURCHASE', set = 'Ledger_Sounds' } }, -- compra concluida
    sell = { file = 'loja_compra.ogg', volume = 0.3, native = { name = 'PURCHASE', set = 'Ledger_Sounds' } }, -- venda concluida
}

----------------------------------
-- lojas (cada loja tem suas categorias e itens)
-- chave      = id unico da loja
-- coords     = vector4 do NPC (x, y, z, heading); sem NPC vira o centro da zona do ox_target
-- npc        = modelo do NPC, ou false para so uma zona de interacao
-- scenario   = animacao do NPC (opcional, padrao Config.DefaultScenario)
-- blip       = { sprite = hash, color = modificador, scale = 0.2 } ou false
-- currency   = 'cash' | 'bloodmoney' | outro tipo de dinheiro do rsg-core
-- jobs       = nil (todos) ou { 'valsheriff', 'medic' } (so esses empregos)
-- canBuy     = true: o jogador pode COMPRAR nesta loja (usa 'categories')
-- canSell    = true: o jogador pode VENDER para esta loja (usa 'buys')
--
-- categories = itens A VENDA, na ordem em que aparecem nos filtros da loja
--   label = nome mostrado no filtro
--   items = { name = item do rsg-core, price = quanto o jogador paga }
--   item a venda NUNCA pode ser vendido de volta para a loja
--
-- buys       = itens que a loja COMPRA do jogador (aparecem na aba 'buysLabel' da loja;
--              o jogador tambem ve o preco em verde nos proprios itens)
-- buysLabel  = nome da aba de compra nesta loja (opcional, padrao Config.Text.buys_tab)
--   name       = item do rsg-core
--   price      = quanto a loja paga por unidade (proporcional a qualidade do item)
--   minQuality = qualidade minima aceita (opcional)
--   item a venda so e comprado de volta se estiver aqui, e o preco pago precisa ser
--   MENOR que o de venda (senao da para comprar e revender sem parar; o item e ignorado)
--
-- estoque: sempre cheio, nunca acaba e nao tem reposicao
--
-- ATENCAO: as coordenadas abaixo sao exemplos, confira no jogo e ajuste.
----------------------------------
Config.Shops = {
    shop_valentine = {
        label = 'Armazém de Valentine',
        coords = vector4(-324.28, 803.39, 117.88, 285.0),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
    shop_rhodes = {
        label = 'Armazém de Rhodes',
        coords = vector4(1329.5198, -1294.5895, 77.0218, 63.3218),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
        shop_sd = {
        label = 'Armazém de Saint Denis',
        coords = vector4(2824.4089, -1319.3584, 46.7557, 321.9146),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
        shop_bw = {
        label = 'Armazém de BlackWater',
        coords = vector4(-784.6049, -1322.1337, 43.8841, 179.5123),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
        shop_am = {
        label = 'Armazém de Armadillo',
        coords = vector4(-3687.3501, -2623.2622, -13.4312, 264.9234),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
        shop_tw = {
        label = 'Armazém de TumbleWeed',
        coords = vector4(-5485.9629, -2938.1099, -0.3996, 118.3894),
        npc = 'u_m_m_valgenstoreowner_01',
        blip = { sprite = 1475879922, color = 'BLIP_MODIFIER_MP_COLOR_32', scale = 0.2 },
        currency = 'cash',
        canBuy = true,   -- vende para o jogador
        canSell = false,  -- compra do jogador
        categories = {
            {
                label = 'Comidas',
                items = {
                    { name = 'bread',  price = 0.50 },
                },
            },
            {
                label = 'Bebidas',
                items = {
                    { name = 'water',  price = 0.50 },
                },
            },
            {
                label = 'Utilidades',
                items = {
                    { name = 'bandage', price = 1.50 },
                },
            },
        },
        buys = {
            { name = 'bread', price = 13000, minQuality = 1 },
        },
    },
}
