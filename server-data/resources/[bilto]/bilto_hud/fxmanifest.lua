fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Bilto'
description 'bilto_hud - HUD personalizavel com editor visual (estilos, icones, cores e posicoes por jogador)'
version '1.0.0'

-- substitui o rsg-hud: mesmos eventos (hud:client:*) e exports
provide 'rsg-hud'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/status.lua',
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/icons.js',
    'html/presets.js',
    'html/script.js',
    'html/assets/*'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'oxmysql',
    'bilto_notify' -- notificacoes no center-right
}

lua54 'yes'
