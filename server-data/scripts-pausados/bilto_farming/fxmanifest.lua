fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'Bilto Plantação'
author 'Bilto'
description 'Sistema de Plantação'

shared_scripts {
	'config.lua',
	'language.lua',
}

client_scripts {
	'dataview.lua',
	'client.lua',
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/app.js'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

dependencies {
	'rsg-core',
	'rsg-inventory',
	'ox_lib',
	'ox_target',
	'bilto_notify',
	'oxmysql'
}
