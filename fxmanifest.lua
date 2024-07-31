fx_version 'cerulean'
games { 'gta5' }

author 'RAGE'
description 'Spectate Menu'
version '1.0.0'


shared_script {
	'@es_extended/imports.lua',
	'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'web/index.html'

files {
    'web/*.*',
	'web/assets/*.*'
}