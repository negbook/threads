fx_version 'adamant'
games {'gta5'}

description 'Threads'

client_scripts 
{
    'threads.lua',
    'modules/client/arrival/*.lua',
    'modules/client/scaleforms/*.lua',
    'modules/client/draws/*.lua'
    
}

server_scripts
{
    'threads.lua',
    'modules/server/**/*.lua'
}