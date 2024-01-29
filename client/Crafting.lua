--// Gestion Craft //--
RegisterNetEvent('MoonShine:finCraft')
AddEventHandler('MoonShine:finCraft', function()
    isMenuOpened = false
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false) 
end)


RegisterNetEvent('MoonShine:closeMenu')
AddEventHandler('MoonShine:closeMenu', function()
    isMenuOpened = false
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false) 
end)


Citizen.CreateThread(function()
	WarMenu.CreateMenu('menu', 'Feu de Camp')
    WarMenu.SetSubTitle('menu', "")

	repeat
		if WarMenu.IsMenuOpened('menu') then
            for i,v in pairs(Config.Craft)do 
                if(v.Job == "null" or v.Job == _userJob)then
                    if WarMenu.Button(v.CraftName .." ".. v.itemGain[1].qtyGain .."x") then
                        TriggerServerEvent('MoonShine:Craft', i, currentCoords.x, currentCoords.y, currentCoords.z)
                        WarMenu.CloseMenu()
                    end
                end
            end
            
            if WarMenu.Button("Quitter") then
                ClearPedTasks(PlayerPedId())
                FreezeEntityPosition(PlayerPedId(), false)                 
                WarMenu.CloseMenu()    
                isMenuOpened = false
			end
            WarMenu.Display()
        end
        Citizen.Wait(0)	
	until false
end)


RegisterNetEvent('MoonShine:progressbar')
AddEventHandler('MoonShine:progressbar', function(timer)
    coalInProgress = true
    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), timer, true, false, false, false)
    exports.gum_progressbars:DisplayProgressBar(timer)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    coalInProgress = false
end)