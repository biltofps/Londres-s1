fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Bilto'
description 'bilto_shop - lojas com NPC/blip usando a NUI do rsg-inventory (inventario do jogador + loja com precos)'
version '1.0.0'

-- so para tocar os sons .ogg (html/sounds)
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/sounds/*.ogg'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'ox_target',
    'bilto_notify', -- notificacoes de compra/venda
    'rsg-inventory' -- a loja abre na propria NUI do inventario (server/shops.lua do rsg-inventory)
}

lua54 'yes'
