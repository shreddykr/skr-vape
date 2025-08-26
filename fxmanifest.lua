fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'shreddykr'
description 'SKR Vape Kit with Refill & Disposable Vapes'
version '1.0.3'

shared_script '@ox_lib/init.lua'
shared_script 'shared/config.lua'

client_script 'client/client.lua'
server_script 'server/server.lua'

dependencies {
    'ox_inventory',
    'ox_lib'
}


files {
    'stream/*.ydr',
    'stream/*.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp'

