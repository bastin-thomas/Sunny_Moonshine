fx_version "adamant"

games { 'rdr3' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
    'config.lua',
    'Alambic.lua',
}

server_scripts {
    'server/server.lua',
    'server/AlambicManagement.lua',
    'server/Crafting.lua'
}

client_scripts {
    'client/client.lua',
	'client/AlambicManagement.lua',
    'client/Crafting.lua',
    'warmenu.lua'
}