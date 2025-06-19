--[[
──────────────────────────────────────────────────────────────

	SEM_InteractionMenu (client.lua) - Created by NevinBatista
	Current Version: v1.7.1 (Sep 2021)
	
	https://discord.gg/93s5Wr4rBe
	
		!!! Change vaules in the 'config.lua' !!!
	DO NOT EDIT THIS IF YOU DON'T KNOW WHAT YOU ARE DOING

──────────────────────────────────────────────────────────────
]]



--Cuffing Event
local isCuffed = false
RegisterNetEvent('SEM_InteractionMenu:Cuff')
AddEventHandler('SEM_InteractionMenu:Cuff', function()
    local Ped = PlayerPedId()
    if (DoesEntityExist(Ped)) then
        Citizen.CreateThread(function()
            if isCuffed then
                -- Uncuffing
                local animation = { dict = "mp_arresting", name = "b_uncuff" }
                RequestAnimDict(animation.dict)
                while not HasAnimDictLoaded(animation.dict) do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(Ped, animation.dict, animation.name, 8.0, -8, -1, 0, 0, 0, 0, 0)
                
                Citizen.Wait(3000)
                
                isCuffed = false
                SetEnableHandcuffs(Ped, false)
                ClearPedTasksImmediately(Ped)
            else
                -- Cuffing
                isCuffed = true
                SetEnableHandcuffs(Ped, true)
                
                -- Cuffing animation
                local animation = { dict = "mp_arrest_paired", name = "crook_p2_back_right" }
                RequestAnimDict(animation.dict)
                while not HasAnimDictLoaded(animation.dict) do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(Ped, animation.dict, animation.name, 8.0, -8, 3750, 2, 0, 0, 0, 0)
                
                Citizen.SetTimeout(3800, function()
                    if isCuffed then
                        local cuffedAnim = { dict = "mp_arresting", name = "idle" }
                        RequestAnimDict(cuffedAnim.dict)
                        while not HasAnimDictLoaded(cuffedAnim.dict) do
                            Citizen.Wait(0)
                        end
                        TaskPlayAnim(Ped, cuffedAnim.dict, cuffedAnim.name, 8.0, -8, -1, 49, 0, 0, 0, 0)
                    end
                end)
                
                -- Attempt uncuffing
                Citizen.Wait(4000) -- Wait 4 seconds before starting
                TriggerEvent('SEM_InteractionMenu:AttemptUncuff')
            end
        end)
    end
end)

-- Uncuff attempt event
RegisterNetEvent('SEM_InteractionMenu:AttemptUncuff')
AddEventHandler('SEM_InteractionMenu:AttemptUncuff', function()
    if isCuffed then
        if exports['ox_lib'] and exports['ox_lib'].skillCheck then
            local success = exports['ox_lib']:skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'}, {'w', 'a', 's', 'd'})
            if success then
                isCuffed = false
                local Ped = PlayerPedId()
                SetEnableHandcuffs(Ped, false)
                ClearPedTasksImmediately(Ped)
                lib.notify({
                    title = 'Success',
                    description = 'You have escaped cuffs!',
                    type = 'success',
                })
            else
                lib.notify({
                    title = 'Failed',
                    description = 'You failed to escape cuffs!',
                    type = 'error',
                })
            end
        else
            lib.notify({
                title = 'Error',
                description = 'Unable to attempt uncuffing. Required resource not available.',
                type = 'error',
            })
        end
    end
end)

-- Arrest animation
RegisterNetEvent('SEM_InteractionMenu:OfficerCuffAnim')
AddEventHandler('SEM_InteractionMenu:OfficerCuffAnim', function()
    local playerPed = PlayerPedId()
    local animation = {dict = 'mp_arrest_paired', name = 'cop_p2_back_right'}
    
    RequestAnimDict(animation.dict)
    while not HasAnimDictLoaded(animation.dict) do
        Wait(0)
    end
    TaskPlayAnim(playerPed, animation.dict, animation.name, 8.0, -8, 3750, 48, 0, 0, 0, 0)
end)

--Cuff Animation & Restrictions
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        local ped = PlayerPedId()

        if isCuffed then
            if IsEntityDead(ped) then
                isCuffed = false
                SetEnableHandcuffs(ped, false)
                ClearPedTasksImmediately(ped)
            else
                if not IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) then
                    RequestAnimDict("mp_arresting")
                    while not HasAnimDictLoaded("mp_arresting") do
                        Wait(100)
                    end
                    TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
                end

                SetEnableHandcuffs(ped, true)
                SetPedCanPlayGestureAnims(ped, false)
                FreezeEntityPosition(ped, false)

                SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
                
                if not Config.VehEnterCuffed then
                    DisableControlAction(1, 23, true) --F | Enter Vehicle
                    DisableControlAction(1, 75, true) --F | Exit Vehicle
                end
                DisableControlAction(1, 140, true) --R
                DisableControlAction(1, 141, true) --Q
                DisableControlAction(1, 142, true) --LMB
                SetPedPathCanUseLadders(ped, false)
                
                DisableControlAction(0, 21, true) -- disable sprint
                DisableControlAction(0, 24, true) -- disable attack
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 47, true) -- disable weapon
                DisableControlAction(0, 58, true) -- disable weapon
                DisableControlAction(0, 263, true) -- disable melee
                DisableControlAction(0, 264, true) -- disable melee
                DisableControlAction(0, 257, true) -- disable melee
                DisableControlAction(0, 140, true) -- disable melee
                DisableControlAction(0, 141, true) -- disable melee
                DisableControlAction(0, 142, true) -- disable melee
                DisableControlAction(0, 143, true) -- disable melee
                
                if IsPedInAnyVehicle(ped, false) then
                    DisableControlAction(0, 59, true)
                end
            end
        else
            SetEnableHandcuffs(ped, false)
            SetPedCanPlayGestureAnims(ped, true)
            SetPedMoveRateOverride(ped, 1.0)
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
    end
end)



--Dragging Event
local Drag = false
local OfficerDrag = -1
RegisterNetEvent('SEM_InteractionMenu:Drag')
AddEventHandler('SEM_InteractionMenu:Drag', function(ID)
	Drag = not Drag
	OfficerDrag = ID
	
	if not Drag then
        DetachEntity(PlayerPedId(), true, false)
	end
end)

--Drag Attachment
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if Drag then
            local Ped = GetPlayerPed(GetPlayerFromServerId(OfficerDrag))
            local Ped2 = PlayerPedId()
            AttachEntityToEntity(Ped2, Ped, 4103, 0.35, 0.38, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            DisableControlAction(1, 140, true) --R
			DisableControlAction(1, 141, true) --Q
			DisableControlAction(1, 142, true) --LMB
        end
    end
end)



--Force Seat Player Event
RegisterNetEvent('SEM_InteractionMenu:Seat')
AddEventHandler('SEM_InteractionMenu:Seat', function(Veh)
	local Pos = GetEntityCoords(PlayerPedId())
	local EntityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)
    local RayHandle = CastRayPointToPoint(Pos.x, Pos.y, Pos.z, EntityWorld.x, EntityWorld.y, EntityWorld.z, 10, PlayerPedId(), 0)
    local _, _, _, _, VehicleHandle = GetRaycastResult(RayHandle)
    if VehicleHandle ~= nil then
		SetPedIntoVehicle(PlayerPedId(), VehicleHandle, 1)
	end
end)



--Force Unseat Player Event
RegisterNetEvent('SEM_InteractionMenu:Unseat')
AddEventHandler('SEM_InteractionMenu:Unseat', function(ID)
	local Ped = GetPlayerPed(ID)
	ClearPedTasksImmediately(Ped)
	PlayerPos = GetEntityCoords(PlayerPedId(),  true)
	local X = PlayerPos.x - 0
	local Y = PlayerPos.y - 0

    SetEntityCoords(PlayerPedId(), X, Y, PlayerPos.z)
end)



--Spike Strip Spawn Event
local SpawnedSpikes = {}
RegisterNetEvent('SEM_InteractionMenu:Spikes-SpawnSpikes')
AddEventHandler('SEM_InteractionMenu:Spikes-SpawnSpikes', function(Length)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        lib.notify({
            title = 'Info',
            description = 'You cannot set spikes while inside of a vehicle!',
            type = 'info',
        })
        
        return
    end

    local SpawnCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()) , 0.0, 2.0, 0.0)
    for a = 1, Length do
        local Spike = CreateObject(GetHashKey('P_ld_stinger_s'), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, 1, 1, 1)
        local NetID = NetworkGetNetworkIdFromEntity(Spike)
        SetNetworkIdExistsOnAllMachines(NetID, true)
        SetNetworkIdCanMigrate(NetID, false)
        SetEntityHeading(Spike, GetEntityHeading(GetPlayerPed(PlayerId()) ))
        PlaceObjectOnGroundProperly(Spike)
        FreezeEntityPosition(Spike, true)
        SpawnCoords = GetOffsetFromEntityInWorldCoords(Spike, 0.0, 4.0, 0.0)
        table.insert(SpawnedSpikes, NetID)
    end
end)

--Spike Strip Delete Event
RegisterNetEvent('SEM_InteractionMenu:Spikes-DeleteSpikes')
AddEventHandler('SEM_InteractionMenu:Spikes-DeleteSpikes', function()
    for a = 1, #SpawnedSpikes do
        local Spike = NetworkGetEntityFromNetworkId(SpawnedSpikes[a])
        DeleteEntity(Spike)
    end
    lib.notify({
        title = 'Info',
        description = 'Spikes Removed',
        type = 'info',
    })
    SpawnedSpikes = {}
end)

--Spike Strip Tire Popping
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(25)

        if IsPedInAnyVehicle(PlayerPedId() , false) then
            local Vehicle = GetVehiclePedIsIn(PlayerPedId() , false)

            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId()  then
                local VehiclePos = GetEntityCoords(Vehicle, false)
                local Spike = GetClosestObjectOfType(VehiclePos.x, VehiclePos.y, VehiclePos.z, 2.0, GetHashKey('P_ld_stinger_s'), 1, 1, 1)

                if Spike ~= 0 then
                    local Tires = {
                        {bone = 'wheel_lf', index = 0},
                        {bone = 'wheel_rf', index = 1},
                        {bone = 'wheel_lm', index = 2},
                        {bone = 'wheel_rm', index = 3},
                        {bone = 'wheel_lr', index = 4},
                        {bone = 'wheel_rr', index = 5}
                    }
        
                    for a = 1, #Tires do
                        local TirePos = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, Tires[a].bone))
                        local Spike = GetClosestObjectOfType(TirePos.x, TirePos.y, TirePos.z, 2.0, GetHashKey('P_ld_stinger_s'), 1, 1, 1)
                        local SpikePos = GetEntityCoords(Spike, false)
                        local Distance = Vdist(TirePos.x, TirePos.y, TirePos.z, SpikePos.x, SpikePos.y, SpikePos.z)
            
                        if Distance < 1.8 then
                            if not IsVehicleTyreBurst(Vehicle, Tires[a].index, true) or IsVehicleTyreBurst(Vehicle, Tires[a].index, false) then
                                SetVehicleTyreBurst(Vehicle, Tires[a].index, false, 1000.0)
                            end
                        end
                    end
                end
            end
        end
    end
end)



--Backup
RegisterNetEvent('SEM_InteractionMenu:CallBackup')
AddEventHandler('SEM_InteractionMenu:CallBackup', function(Code, StreetName, Coords)
    if LEORestrict() then
        local BackupBlip = nil
        local BackupBlips = {}

        local function CreateBlip(x, y, z, Name, Sprite, Size, Colour)
            BackupBlip = AddBlipForCoord(x, y, z)
            SetBlipSprite(BackupBlip, Sprite)
            SetBlipDisplay(BackupBlip, 4)
            SetBlipScale(BackupBlip, Size)
            SetBlipColour(BackupBlip, Colour)
            SetBlipAsShortRange(BackupBlip, true)
        
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Name)
            EndTextCommandSetBlipName(BackupBlip)
            table.insert(BackupBlips, BackupBlip)
            Citizen.Wait(Config.BackupBlipTimeout * 60000)
            for _, Blip in pairs(BackupBlips) do
                RemoveBlip(Blip)
            end
        end

        if Code == 1 then
            Notify('An officer is requesting ~g~Code 1 ~w~backup at ~b~' .. StreetName)
            CreateBlip(Coords.x, Coords.y, Coords.z, 'Code 1 Backup Requested', 56, 0.8, 2)
        elseif Code == 2 then
            Notify('An officer is requesting ~y~Code 2 ~w~backup at ~b~' .. StreetName)
            CreateBlip(Coords.x, Coords.y, Coords.z, 'Code 2 Backup Requested', 56, 0.8, 17)
        elseif Code == 3 then
            Notify('An officer is requesting ~r~Code 3 ~w~backup at ~b~' .. StreetName)
            CreateBlip(Coords.x, Coords.y, Coords.z, 'Code 3 Backup Requested', 56, 1.0, 49)
        elseif Code == 99 then
            Notify('An officer is requesting ~r~Code 99 ~w~backup at ~b~' .. StreetName)
            CreateBlip(Coords.x, Coords.y, Coords.z, 'Code 99 Backup Requested', 56, 1.2, 49)
        elseif Code == 'panic' then
            Notify('An officer has pressed their ~r~Panic Button ~w~at ~b~' .. StreetName)
            CreateBlip(Coords.x, Coords.y, Coords.z, 'Panic Button Pressed', 103, 1.2, 49)
        end
    end
end)



--Jail
CurrentlyJailed = false
EarlyRelease = false
OriginalJailTime = 0
RegisterNetEvent('SEM_InteractionMenu:JailPlayer')
AddEventHandler('SEM_InteractionMenu:JailPlayer', function(JailTime)
     if CurrentlyJailed then
        return
    end
    if CurrentlyHospitaled then
        return
    end

    OriginalJailTime = JailTime

    local Ped = PlayerPedId()
    if DoesEntityExist(Ped) then
        Citizen.CreateThread(function()
            SetEntityCoords(Ped, Config.JailLocation.Jail.x, Config.JailLocation.Jail.y, Config.JailLocation.Jail.z)
            SetEntityHeading(Ped, Config.JailLocation.Jail.h)
            CurrentlyJailed = true

            while JailTime >= 0 and not EarlyRelease do
                SetEntityInvincible(Ped, true)
                if IsPedInAnyVehicle(Ped, false) then
					ClearPedTasksImmediately(Ped)
                end
                
                if JailTime % 30 == 0 and JailTime ~= 0 then
                    lib.notify({
                        title = 'Judge',
                        description = JailTime .. ' months until release.',
                        type = 'info'
                    })
                end

                Citizen.Wait(1000)

                local Location = GetEntityCoords(Ped, true)
                local Distance = Vdist(Config.JailLocation.Jail.x, Config.JailLocation.Jail.y, Config.JailLocation.Jail.z, Location['x'], Location['y'], Location['z'])
                if Distance > 100 then
                    SetEntityCoords(Ped, Config.JailLocation.Jail.x, Config.JailLocation.Jail.y, Config.JailLocation.Jail.z)
                    SetEntityHeading(Ped, Config.JailLocation.Jail.h)
                    lib.notify({
                        title = 'Judge',
                        description = 'Don\'t try escape, its impossible',
                        type = 'error'
                    })
                end

                JailTime = JailTime - 1
            end

            if EarlyRelease then
                TriggerServerEvent('SEM_InteractionMenu:GlobalChat', {86, 96, 252}, 'Judge', GetPlayerName(PlayerId()) .. ' was released from Jail on Parole')
            else
                TriggerServerEvent('SEM_InteractionMenu:GlobalChat', {86, 96, 252}, 'Judge', GetPlayerName(PlayerId()) .. ' was released from Jail after ' .. OriginalJailTime .. ' months(s).')
            end
            SetEntityCoords(Ped, Config.JailLocation.Release.x, Config.JailLocation.Release.y, Config.JailLocation.Release.z)
            SetEntityHeading(Ped, Config.JailLocation.Release.h)
            CurrentlyJailed = false
            EarlyRelease = false
        end)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:UnjailPlayer')
AddEventHandler('SEM_InteractionMenu:UnjailPlayer', function()
    EarlyRelease = true
end)



--Toggle LEO Weapons
CarbineEquipped = false
ShotgunEquipped = false
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(50)

        if Config.UnrackWeapons == 1 then
            local Ped = PlayerPedId()
            local CurrentWeapon = GetSelectedPedWeapon(Ped)
        
            if CarbineEquipped then
                SetCurrentPedWeapon(Ped, 'weapon_carbinerifle', true)
            else
                if tostring(CurrentWeapon) == '-2084633992' then
                    lib.notify({
                        title = 'Info',
                        description = 'You need to unrank your rifle before you use it!',
                        type = 'info',
                    })
                    
                    SetCurrentPedWeapon(Ped, 'weapon_unarmed', true)
                end
            end
            
            if ShotgunEquipped then
                SetCurrentPedWeapon(Ped, 'weapon_pumpshotgun', true)
            else
                if tostring(CurrentWeapon) == '487013001' then
                    lib.notify({
                        title = 'Info',
                        description = 'You need to unrank your shotgun before you use it!',
                        type = 'info',
                    })
                    SetCurrentPedWeapon(Ped, 'weapon_unarmed', true)
                end
            end
        end
    end
end)



--Civilian Adverts
RegisterNetEvent('SEM_InteractionMenu:SyncAds')
AddEventHandler('SEM_InteractionMenu:SyncAds',function(Text, Name, Loc, File, ID)
    Ad(Text, Name, Loc, File, ID)
end)



--Inventory
RegisterNetEvent('SEM_InteractionMenu:InventoryResult')
AddEventHandler('SEM_InteractionMenu:InventoryResult', function(Inventory)
    Citizen.Wait(5000)

    if Inventory ==  nil then
        Inventory = 'Empty'
    end

    lib.notify({
        title = 'Info',
        description = 'Inventory Items: ' .. Inventory,
        type = 'info',
    })
end)



--BAC
RegisterNetEvent('SEM_InteractionMenu:BACResult')
AddEventHandler('SEM_InteractionMenu:BACResult', function(BACLevel)
    Citizen.Wait(5000)

    if BACLevel == nil then
        BACLevel = 0.00
    end

    if tonumber(BACLevel) < 0.08 then
        lib.notify({
            title = 'Info',
            description = 'BAC Level: ',
            type = 'info',
        })
    else
        lib.notify({
            title = 'Info',
            description = 'BAC Level: ',
            type = 'info',
        })
    end
end)




--Hospital
CurrentlyHospitalized = false
EarlyDischarge = false
OriginalHospitalTime = 0
RegisterNetEvent('SEM_InteractionMenu:HospitalizePlayer')
AddEventHandler('SEM_InteractionMenu:HospitalizePlayer', function(HospitalTime, HospitalLocation)
    if CurrentlyHospitaled then
        return
    end
    if CurrentlyJailed then
        return
    end

    OriginalHospitalTime = HospitalTime

    local Ped = PlayerPedId()
    if DoesEntityExist(Ped) then
        Citizen.CreateThread(function()
            SetEntityCoords(Ped, HospitalLocation.Hospital.x, HospitalLocation.Hospital.y, HospitalLocation.Hospital.z)
            SetEntityHeading(Ped, HospitalLocation.Hospital.h)
            CurrentlyHospitaled = true

            while HospitalTime >= 0 and not EarlyDischarge do
                SetEntityInvincible(Ped, true)
                if IsPedInAnyVehicle(Ped, false) then
					ClearPedTasksImmediately(Ped)
                end
                
                if HospitalTime % 30 == 0 and HospitalTime ~= 0 then
                    TriggerEvent('chat:addMessage', {
                        multiline = true,
                        color = {86, 96, 252},
                        args = {'Doctor', HospitalTime .. ' months until release.'},
                    })
				end

                Citizen.Wait(1000)

                local Location = GetEntityCoords(Ped, true)
                local Distance = Vdist(HospitalLocation.Hospital.x, HospitalLocation.Hospital.y, HospitalLocation.Hospital.z, Location['x'], Location['y'], Location['z'])
				if Distance > 30 then
                    SetEntityCoords(Ped, HospitalLocation.Hospital.x, HospitalLocation.Hospital.y, HospitalLocation.Hospital.z)
                    SetEntityHeading(Ped, HospitalLocation.Hospital.h)
					TriggerEvent('chat:addMessage', {
                        multiline = true,
                        color = {86, 96, 252},
                        args = {'Doctor', 'You cannot discharge yourself!'},
                    })
				end

                HospitalTime = HospitalTime - 1
            end

            if EarlyDischarge then
                TriggerServerEvent('SEM_InteractionMenu:GlobalChat', {86, 96, 252}, 'Doctor', GetPlayerName(PlayerId()) .. ' was discharged from Hospital early')
            else
                TriggerServerEvent('SEM_InteractionMenu:GlobalChat', {86, 96, 252}, 'Doctor', GetPlayerName(PlayerId()) .. ' was discharged from Hospital after ' .. OriginalHospitalTime .. ' months(s).')
            end
            SetEntityCoords(Ped, HospitalLocation.Release.x, HospitalLocation.Release.y, HospitalLocation.Release.z)
            SetEntityHeading(Ped, HospitalLocation.Release.h)
            CurrentlyHospitaled = false
            EarlyDischarge = false
        end)
    end
end)

RegisterNetEvent('SEM_InteractionMenu:UnhospitalizePlayer')
AddEventHandler('SEM_InteractionMenu:UnhospitalizePlayer', function()
    EarlyDischarge = true
end)



--Station Blips
Citizen.CreateThread(function()
    if Config.DisplayStationBlips then
        local function CreateBlip(x, y, z, Name, Colour, Sprite)
            StationBlip = AddBlipForCoord(x, y, z)
            SetBlipSprite(StationBlip, Sprite)
            if Config.StationBlipsDispalyed == 1 then
                SetBlipDisplay(StationBlip, 3)
            elseif Config.StationBlipsDispalyed == 2 then
                SetBlipDisplay(StationBlip, 5)
            else
                SetBlipDisplay(StationBlip, 2)
            end
            SetBlipScale(StationBlip, 1.0)
            SetBlipColour(StationBlip, Colour)
            SetBlipAsShortRange(StationBlip, true)
        
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Name)
            EndTextCommandSetBlipName(StationBlip)
        end

        for _, Station in pairs(Config.LEOStations) do
            CreateBlip(Station.coords.x, Station.coords.y, Station.coords.z, 'Police Station', 38, 60)
        end
        for _, Station in pairs(Config.FireStations) do
            CreateBlip(Station.coords.x, Station.coords.y, Station.coords.z, 'Fire Station', 1, 60)
        end
        for _, Station in pairs(Config.HospitalStations) do
            CreateBlip(Station.coords.x, Station.coords.y, Station.coords.z, 'Hospital', 2, 61)
        end
    end
end)



--Permissions
LEOAce = false
TriggerServerEvent('SEM_InteractionMenu:LEOPerms')
RegisterNetEvent('SEM_InteractionMenu:LEOPermsResult')
AddEventHandler('SEM_InteractionMenu:LEOPermsResult', function(Allowed)
    if Allowed then
        LEOAce = true
    else
        LEOAce = false
    end
end)

FireAce = false
TriggerServerEvent('SEM_InteractionMenu:FirePerms')
RegisterNetEvent('SEM_InteractionMenu:FirePermsResult')
AddEventHandler('SEM_InteractionMenu:FirePermsResult', function(Allowed)
    if Allowed then
        FireAce = true
    else
        FireAce = false
    end
end)

UnjailAllowed = false
TriggerServerEvent('SEM_InteractionMenu:UnjailPerms')
RegisterNetEvent('SEM_InteractionMenu:UnjailPermsResult')
AddEventHandler('SEM_InteractionMenu:UnjailPermsResult', function(Allowed)
    if Allowed then
        UnjailAllowed = true
    else
        UnjailAllowed = false
    end
end)

UnhospitalAllowed = false
TriggerServerEvent('SEM_InteractionMenu:UnhospitalPerms')
RegisterNetEvent('SEM_InteractionMenu:UnhospitalPermsResult')
AddEventHandler('SEM_InteractionMenu:UnhospitalPermsResult', function(Allowed)
    if Allowed then
        UnhospitalAllowed = true
    else
        UnhospitalAllowed = false
    end
end)



--Emote
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if EmotePlaying then
            if Config.EmoteHelp then
                lib.notify({
                    title = 'Info',
                    description = 'You are playing an emote move to cancel',
                    type = 'info',
                })
            end

            --  Spacebar                   W                          S                          A                          D
            if (IsControlPressed(0, 22) or IsControlPressed(0, 32) or IsControlPressed(0, 33) or IsControlPressed(0, 34) or IsControlPressed(0, 35)) then
                CancelEmote()
            end
        end
    end
end)



--Commands
Citizen.CreateThread(function()
    if EmoteRestrict() then
        local Index = 0
        local Emotes = ''
        for _, Emote in pairs(Config.EmotesList) do
            Index = Index + 1
            if Index == 1 then
                Emotes = Emotes .. Emote.name
            else
                Emotes = Emotes .. ', ' .. Emote.name
            end
        end
        
        TriggerEvent('chat:addSuggestion', '/emotes', 'List of Current Avaliable Emotes')
        TriggerEvent('chat:addSuggestion', '/emote', 'Play Emote', {{name = 'Emote Name', help = 'Emotes: ' .. Emotes}})
    else
        TriggerEvent('chat:removeSuggestion', '/emotes')
        TriggerEvent('chat:removeSuggestion', '/emote')
    end

    TriggerEvent('chat:addSuggestion', '/eng', 'Toggles Engine')
    TriggerEvent('chat:addSuggestion', '/hood', 'Toggles Vehicle\'s Hood')
    TriggerEvent('chat:addSuggestion', '/trunk', 'Toggles Vehicle\'s Trunk')
    TriggerEvent('chat:addSuggestion', '/clear', 'Clears all Weapons')
    TriggerEvent('chat:addSuggestion', '/cuff', 'Cuff Player', {{name = 'ID', help = 'Players Server ID'}})
    TriggerEvent('chat:addSuggestion', '/drag', 'Drag Player', {{name = 'ID', help = 'Players Server ID'}})
    TriggerEvent('chat:addSuggestion', '/dropweapon', 'Drops Weapon in Hand')
    TriggerEvent('chat:addSuggestion', '/loadout', 'Equips LEO Weapon Loadout')
    TriggerEvent('chat:addSuggestion', '/coords', 'Shows Current Player Coords and Heading')

    if Config.Radar ~= 0 then
        TriggerEvent('chat:addSuggestion', '/radar', 'Toggle Radar Menu')
    end

    if Config.LEOAccess == 3 or Config.FireAccess == 3 then
        if Config.OndutyPSWDActive then
            TriggerEvent('chat:addSuggestion', '/onduty', 'Enable LEO/Fire Menu', {{name = 'Department', help = 'LEO or Fire'}, {name = 'Password', help = 'Onduty Password'}})
        else
            TriggerEvent('chat:addSuggestion', '/onduty', 'Enable LEO/Fire Menu', {{name = 'Department', help = 'LEO or Fire'}})
        end
    else
        TriggerEvent('chat:removeSuggestion', '/onduty')
    end
end)

LEOOnduty = false
FireOnduty = false
RegisterCommand('onduty', function(source, args, rawCommand)
    if Config.LEOAccess == 3 or Config.FireAccess == 3 then
        if Config.OndutyPSWDActive then
            if args[2] == Config.OndutyPSWD then
                local Department = args[1]:lower()
                if Department == 'leo' then
                    LEOOnduty = not LEOOnduty
                    if LEOOnduty then
                        lib.notify({
                            title = 'Info',
                            description = 'You are on duty as LEO',
                            type = 'info',
                        })
                    else
                        lib.notify({
                            title = 'Info',
                            description = 'You are no longer on duty as LEO',
                            type = 'info',
                        })
                    end
                elseif Department == 'fire' then
                    FireOnduty = not FireOnduty
                    if FireOnduty == true then
                        lib.notify({
                            title = 'Info',
                            description = 'You are on duty as a Firefighter',
                            type = 'info',
                        })
                    else
                        lib.notify({
                            title = 'Info',
                            description = 'You are no longer on duty as a Firefighter',
                            type = 'info',
                        })
                    end
                else
                    lib.notify({
                        title = 'Error',
                        description = 'Invalid Department',
                        type = 'error',
                    })
                end
            else
                lib.notify({
                    title = 'Error',
                    description = 'Incorrect Password',
                    type = 'error',
                })
            end
        else
            local Department = args[1]:lower()
            if Department == 'leo' then
                LEOOnduty = not LEOOnduty
                if LEOOnduty then
                    lib.notify({
                        title = 'Info',
                        description = 'You are on duty as LEO',
                        type = 'info',
                    })
                else
                    lib.notify({
                        title = 'Info',
                        description = 'You are no longer on duty as LEO!',
                        type = 'info',
                    })
                end
            elseif Department == 'fire' then
                FireOnduty = not FireOnduty
                if FireOnduty == true then
                    lib.notify({
                        title = 'Info',
                        description = 'You are onduty as a Firefighter',
                        type = 'info',
                    })
                else
                    lib.notify({
                        title = 'Info',
                        description = 'You are no longer on duty as a Fighterfighter',
                        type = 'info',
                    })
                end
            else
                lib.notify({
                    title = 'Info',
                    description = 'Invalid Department',
                    type = 'info',
                })
            end
        end
    end
end)

function IsOndutyLEO()
    return LEOOnduty
end
function IsOndutyFire()
    return FireOnduty
end

RegisterCommand('cuff', function(source, args, rawCommand)
    if LEORestrict() or FireRestrict() then
        if args[1] ~= nil then
            local ID = tonumber(args[1])
            if Config.CommandDistanceChecked then
                if GetDistance(source) < Config.CommandDistance then
                    TriggerServerEvent('SEM_InteractionMenu:CuffNear', ID)
                else
                    lib.notify({
                        title = 'Info',
                        description = 'That player is too far away',
                        type = 'info',
                    })
                end
            else
                TriggerServerEvent('SEM_InteractionMenu:CuffNear', ID)
            end
        else
            TriggerServerEvent('SEM_InteractionMenu:CuffNear', GetClosestPlayer())
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Invalid Permissions!',
            type = 'error',
        })
    end
end)

RegisterCommand('drag', function(source, args, rawCommand)
    if LEORestrict() or FireRestrict() then
        if args[1] ~= nil then
            local ID = tonumber(args[1])
            if Config.CommandDistanceChecked then
                if GetDistance(source) < Config.CommandDistance then
                    TriggerServerEvent('SEM_InteractionMenu:DragNear', ID)
                else
                    lib.notify({
                        title = 'Info',
                        description = 'That player is too far away!',
                        type = 'info',
                    })
                end
            else
                TriggerServerEvent('SEM_InteractionMenu:DragNear', ID)
            end
        else
            TriggerServerEvent('SEM_InteractionMenu:DragNear', GetClosestPlayer())
        end
    else
        lib.notify({
            title = 'Error',
            description = 'Invalid Permissions',
            type = 'error',
        })
    end
end)

RegisterCommand('radar', function(source, args, rawCommand)
    if Config.Radar ~= 0 then
        if LEORestrict() or FireRestrict() then
            ToggleRadar()
        else
            lib.notify({
                title = 'Error',
                description = 'Invalid Permissions',
                type = 'error',
            })
        end
    end
end)

RegisterCommand('loadout', function(source, args, rawCommand)
    if LEORestrict() then
        if args[1] then
            local RequestedLoadout = args[1]
            
            for Name, Loadout in pairs(Config.LEOLoadouts) do
                if Name:lower() == RequestedLoadout:lower() then
                    SetEntityHealth(GetPlayerPed(-1), 200)
                    RemoveAllPedWeapons(GetPlayerPed(-1), true)
                    AddArmourToPed(GetPlayerPed(-1), 100)

                    for _, Weapon in pairs(Loadout) do
                        GiveWeapon(Weapon.weapon)
                                                                
                        for _, Component in pairs(Weapon.components) do
                            AddWeaponComponent(Weapon.weapon, Component)
                        end
                    end
                    return
                end
            end

            Notify('~r~Invalid Loadout')
        else
            SetEntityHealth(PlayerPedId(), 200)
            RemoveAllPedWeapons(PlayerPedId(), true)
            AddArmourToPed(PlayerPedId(), 100)
            GiveWeapon('weapon_nightstick')
            GiveWeapon('weapon_flashlight')
            GiveWeapon('weapon_fireextinguisher')
            GiveWeapon('weapon_flare')
            GiveWeapon('weapon_stungun')
            GiveWeapon('weapon_combatpistol')
            AddWeaponComponent('weapon_combatpistol', 'component_at_pi_flsh')
            Notify('~g~Loadout Spawned')
        end
    else
        lib.notify({
            title = 'Info',
            description = 'You arnt a LEO!',
            type = 'info',
        })
    end
end)

RegisterCommand('hu', function(source, args, rawCommand)
    local Ped = PlayerPedId()
    if DoesEntityExist(Ped) and not HandCuffed then
        Citizen.CreateThread(function()
            LoadAnimation('random@mugging3')
            if IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or HandCuffed then
                ClearPedSecondaryTask(Ped)
                SetEnableHandcuffs(Ped, false)
            elseif not IsEntityPlayingAnim(Ped, 'random@mugging3', 'handsup_standing_base', 3) or not HandCuffed then
                TaskPlayAnim(Ped, 'random@mugging3', 'handsup_standing_base', 8.0, -8, -1, 49, 0, 0, 0, 0)
                SetEnableHandcuffs(Ped, true)
            end
        end)
    end
end)

RegisterCommand('huk', function(source, args, rawCommand)
    local Ped = PlayerPedId()
    if (DoesEntityExist(Ped) and not IsEntityDead(Ped)) and not HandCuffed then
        Citizen.CreateThread(function()
            LoadAnimation('random@arrests')
            if (IsEntityPlayingAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 3)) then
                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_get_up', 8.0, 1.0, -1, 128, 0, 0, 0, 0)
            else
                TaskPlayAnim(Ped, 'random@arrests', 'idle_2_hands_up', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
                Wait (4000)
                TaskPlayAnim(Ped, 'random@arrests', 'kneeling_arrest_idle', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
            end
        end)
    end
end)

RegisterCommand('dropweapon', function(source, args, rawCommand)
    local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
    SetPedDropsInventoryWeapon(PlayerPedId(), CurrentWeapon, -2.0, 0.0, 0.5, 30)
    lib.notify({
        title = 'Info',
        description = 'Weapon Dropped',
        type = 'info',
    })
end)

RegisterCommand('clear', function(source, args, rawCommand)
    SetEntityHealth(PlayerPedId(), 200)
    RemoveAllPedWeapons(PlayerPedId(), true)
    lib.notify({
        title = 'Info',
        description = 'All Weapons Cleared',
        type = 'info',
    })
end)

RegisterCommand('eng', function(source, args, rawCommand)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if Veh ~= nil and Veh ~= 0 and GetPedInVehicleSeat(Veh, 0) then
        SetVehicleEngineOn(Veh, (not GetIsVehicleEngineRunning(Veh)), false, true)
        lib.notify({
            title = 'Info',
            description = 'Engine Toggled',
            type = 'info',
        })
    end
end)

RegisterCommand('hood', function(source, args, rawCommand)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)

    if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
        if GetVehicleDoorAngleRatio(Veh, 4) > 0 then
            SetVehicleDoorShut(Veh, 4, false)
        else
            SetVehicleDoorOpen(Veh, 4, false, false)
        end
    end

    lib.notify({
        title = 'Info',
        description = 'Hood Toggled',
        type = 'info',
    })
end)

RegisterCommand('trunk', function(source, args, rawCommand)
    local Veh = GetVehiclePedIsIn(PlayerPedId(), false)

    if Veh ~= nil and Veh ~= 0 and Veh ~= 1 then
        if GetVehicleDoorAngleRatio(Veh, 5) > 0 then
            SetVehicleDoorShut(Veh, 5, false)
        else
            SetVehicleDoorOpen(Veh, 5, false, false)
        end
    end

    lib.notify({
        title = 'Info',
        description = 'Trunk Toggled',
        type = 'info',
    })
end)

RegisterCommand('emotes', function(source, args, rawCommand)
    if EmoteRestrict() then
        local Index = 0
        local Emotes = ''
        for _, Emote in pairs(Config.EmotesList) do
            Index = Index + 1
            if Index == 1 then
                Emotes = Emotes .. Emote.name
            else
                Emotes = Emotes .. ', ' .. Emote.name
            end
        end

        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {255, 0 ,0},
            args = {'Emotes', '\n^r^7' .. Emotes},
        })
    end
end)

RegisterCommand('emote', function(source, args, rawCommand)
    if EmoteRestrict() then
        local SelectedEmote = args[1]

        for _, Emote in pairs(Config.EmotesList) do
            if Emote.name == SelectedEmote then
                PlayEmote(Emote.emote, Emote.name)
                return
            end
        end

        TriggerEvent('chat:addMessage', {
            multiline = true,
            color = {255, 0, 0},
            args = {'Emotes', 'Invalid Emote!'},
        })
    end
end)

RegisterCommand('coords', function(source, args, rawCommand)
    local Coords = GetEntityCoords(PlayerPedId())
    local Heading = GetEntityHeading(PlayerPedId())

    TriggerEvent('chatMessage', 'Coords', {255, 255, 0}, '\nX: ' .. Coords.x .. '\nY: ' .. Coords.y .. '\nZ: ' .. Coords.z .. '\nHeading: ' .. Heading)
end)

local options = {
    {
        name = 'Cuff',
        event = 'SEM_InteractionMenu:Cuff',
        icon = 'fa-solid fa-road',
        label = 'Cuff/Uncuff',
        canInteract = function(entity, distance, coords, name, bone)
            return math.random(0, 100) < 51
        end
    },
    {
        name = 'Escort',
        event = 'SEM_InteractionMenu:Drag',
        icon = 'fa-solid fa-road',
        label = 'Escort User',
        canInteract = function(entity, distance, coords, name, bone)
            return math.random(0, 100) < 51
        end
    }
}

exports.ox_target:addGlobalPlayer(options)