--[[
──────────────────────────────────────────────────────────────────

	SEM_InteractionMenu (fxmanifest.lua) - Created by NevinBatista
	Current Version: v1.7.1 (Sep 2021)
	https://discord.gg/93s5Wr4rBe 
	
		!!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

──────────────────────────────────────────────────────────────────
]]

lua54 'yes'
dependency 'ox_lib'

fx_version 'cerulean'
games {'gta5'}

--DO NOT REMOVE THESE
title 'SEM_InteractionMenu'
description 'Multi Purpose Interaction Menu'
author 'NevinBatista [BatmanDev]'
version 'v1.7.1' --This is required for the version checker, DO NOT change or remove

client_scripts {
    'dependencies/NativeUI.lua',
    'client.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'functions.lua',
    'menu.lua',
}

server_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    'server.lua',
    'functions.lua',
}

exports {
    'IsOndutyLEO',
     '@ox_lib/init.lua',
    'IsOndutyFire',
}
