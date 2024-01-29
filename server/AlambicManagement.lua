-- Gestion Pose de l'alambic: Use Alambic in Inventory
Citizen.CreateThread(function()
	VorpInv.RegisterUsableItem(Config.AlambicItem, function(data)
        --Check si alambic:
        local PlayerCoords = GetEntityCoords(GetPlayerPed(data.source))
        local found = false
        for i,v in pairs(AlambicList)do
            if(GetDistanceBetweenCoords(PlayerCoords, v.Coords, false) < 6.0 )then
                found = true
                break
            end
        end

        if(found == true)then
            TriggerClientEvent("vorp:TipBottom", data.source, 'Eloignez vous de l\'Alambic existant.', 4500)
            return        
        end
        
        --Pose de l'alambic
        local count = VorpInv.getItemCount(data.source, Config.AlambicItem)

		if count >= 1 then
			VorpInv.subItem(data.source, Config.AlambicItem, 1)
			TriggerClientEvent('MoonShine:setAlambic', data.source)
            VorpInv.CloseInv(data.source)
		end
	end)
end)


RegisterServerEvent('MoonShine:PlaceAlambicFailed')
AddEventHandler('MoonShine:PlaceAlambicFailed', function(inwater) 
    local _source = source;
    VorpInv.addItem(_source, Config.AlambicItem, 1);
    
    if(Config.Debug == true)then
        print("IsInWater: " .. tostring(inwater));
    end

    if(inwater)then
        TriggerClientEvent("vorp:TipBottom", _source, 'Placez votre alambic hors de l\'eau', 4500);
    else
        TriggerClientEvent("vorp:TipBottom", _source, 'Placez votre alambic près d\'une rivière', 4500);
    end
end)


-- Placement de l'Alambic
RegisterServerEvent('MoonShine:PlaceAlambic')
AddEventHandler('MoonShine:PlaceAlambic', function(x, y, z)
    local _source = source;

    local tmp = Alambic(x, y, z, 0, 0, 0);
    AlambicList[#AlambicList+1] = tmp;
end)


--Allumage du feu
RegisterServerEvent('MoonShine:StartCampfire')
AddEventHandler('MoonShine:StartCampfire', function(x, y, z) 
    if(Config.Debug == true) then
        print("StartFire");
    end

    --getItems Count
    local _source = source;
    local woodCount = VorpInv.getItemCount(_source, Config.firewood);
    local allumetteCount = VorpInv.getItemCount(_source, Config.starter);


    for i,alambic in pairs(AlambicList)do
        if alambic.Equals(x,y,z) then
            --Get the right Alambic
            --check if you can perform a blocking action
            if(alambic.BlockingAction == false) then
                if woodCount >= Config.woodAmount and allumetteCount >= 1 then
                    --remove item
                    VorpInv.subItem(_source, "wood", 3);
                    VorpInv.subItem(_source, "campfire", 1);
                    
                    --Pose du feu
                    alambic.BlockingAction = true;

                    TriggerClientEvent("MoonShine:StartMinigame", _source, alambic.Coords.x, alambic.Coords.y, alambic.Coords.z)       
                else
                    TriggerClientEvent("vorp:TipBottom", _source, 'Vous avez besoin de 3 bois et 1 allumette', 4500);
                end
            else
                TriggerClientEvent("vorp:TipBottom", _source, "Quelqu'un est déjà en train d'allumer le feu de camp", 4500);
            end
            break
        end        
    end
end)


RegisterServerEvent('MoonShine:InitCampfire')
AddEventHandler('MoonShine:InitCampfire', function(x, y, z) 
    if(Config.Debug == true) then
        print("Start Minigame Fire");
    end

    for i,alambic in pairs(AlambicList)do
        if alambic.Equals(x,y,z) then
            alambic.BlockingAction = false;
            alambic.StartServerCampfire();
        end        
    end
end)

RegisterServerEvent('MoonShine:StopCampfire')
AddEventHandler('MoonShine:StopCampfire', function(x, y, z) 
    if(Config.Debug == true) then
        print("StopCampfire");
    end

    for i,alambic in pairs(AlambicList)do
        if alambic.Equals(x,y,z) then
            alambic.StopServerCampfire();
        end        
    end
end)

RegisterServerEvent('MoonShine:campfire_failed')
AddEventHandler('MoonShine:campfire_failed', function(x,y,z)
    local _source = source

    for i,alambic in pairs(AlambicList)do
        if alambic.Equals(x,y,z) then
            alambic.BlockingAction = false;
        end        
    end

    TriggerClientEvent("vorp:TipBottom", _source,"Vous n'avez pas réussi à allumer le feu", 4000)
	VorpInv.addItem(_source, Config.firewood, Config.woodAmount)
end)




RegisterServerEvent('MoonShine:DismountAlambic')
AddEventHandler('MoonShine:DismountAlambic', function(x, y, z)
    local _source = source;

    if(Config.Debug == true) then
        print("Dismount Alambic"); 
    end

    -- Search the Alambic
    for i, alambic in pairs(AlambicList) do
        if(alambic.Equals(x,y,z) == true)then
            local todel = alambic;
            -- Remove the Campfire
            table.remove(AlambicList, i);
            TriggerClientEvent('MoonShine:DeleteClientAlambic', -1, todel.Coords.x, todel.Coords.y, todel.Coords.z);
            break
        end
    end

    VorpInv.addItem(_source, Config.AlambicItem, 1)
end)



--// Gestion Feu de Camp //--
--Thread de gestion des feux en marches
Citizen.CreateThread(function()
    while true do
        for i, alambic in pairs(AlambicList) do
            -- SI Feu Allumé
            if(alambic.State == 1) then
                if(alambic.FireTimer > 0)then
                    alambic.TimerDecreased()
                else
                    alambic.StopServerCampfire()
                end
            end

            -- SI Feu CoolDown
            if(alambic.State == 2) then
                if(alambic.CoolDownTimer > 0)then
                    alambic.CoolDownDecreased()
                else
                    alambic.FreezeServerCampfire()
                end  
            end

            TriggerClientEvent('MoonShine:RefreshClientList', -1, alambic.Coords.x, alambic.Coords.y, alambic.Coords.z, alambic.AlambicProp, 
                                                                          alambic.PropFire, alambic.State, alambic.FireTimer, alambic.CoolDownTimer)
        end
        Wait(1000)
    end        
end)



--check good item to addcoal
RegisterServerEvent('MoonShine:CheckItems_addcoal')
AddEventHandler('MoonShine:CheckItems_addcoal', function(x, y, z)
	local _source = source
    local count = VorpInv.getItemCount(_source, Config.firewood)
    if count >= 1 then
        VorpInv.subItem(_source, Config.firewood, 1)
        TriggerClientEvent('MoonShine:addcoal', _source, x, y, z)
    else
        TriggerClientEvent("vorp:TipBottom", _source, "Vous n'avez plus de bois", 4500)
	end		
end)

--add time to fire
RegisterServerEvent('MoonShine:AddCoal')
AddEventHandler('MoonShine:AddCoal', function(x, y, z)
	local _source = source
    for i, v in pairs(AlambicList) do
        if v.Equals(x,y,z)then
            v.TimerInscreased(Config.woodAddTime)
        end
    end
end)