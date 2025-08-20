fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script '@ox_lib/init.lua'    

description 'SKR Vape Kit with Refill Support for ox_inventory'
author 'shreddykr'
version '1.0.1'

shared_script 'shared/config.lua'
client_script 'client/client.lua'
server_script 'server/server.lua'

dependencies {
    'ox_inventory',
    'ox_lib'
}

