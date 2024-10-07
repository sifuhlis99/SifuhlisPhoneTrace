fx_version 'cerulean'
game 'gta5'

author 'Sifuhlis@CalibreRoleplay'
description 'Tap and Trace Kit for PD'
version '1.0.0'

server_scripts {
    '@qb-core/server/main.lua', -- Ensure this line is present
    'server/main.lua',
}

client_scripts {
    '@qb-core/client/main.lua', -- Ensure this line is present
    'client/main.lua',
}