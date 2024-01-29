--// Gestion Alambic //--
--Pose Alambic
RegisterNetEvent('MoonShine:setAlambic')
AddEventHandler('MoonShine:setAlambic', function()
    local playerPed = PlayerPedId();
    local Pcoords = GetEntityCoords(playerPed);
    local Water = Citizen.InvokeNative(0x5BA7A68A346A5A91,Pcoords.x, Pcoords.y, Pcoords.z);
    local inwater = IsEntityInWater(playerPed);

    --Check NearWater
    for i,water in pairs(Config.WaterTypes) do
        --Close to Water
        if Water == water.waterzone then
            if inwater == false then
               --Placement de l'alambic
                FreezeEntityPosition(playerPed, true);
                TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 7000, true, false, false, false);

                TriggerEvent("vorp:TipBottom", 'Vous placez l\'Alambic', 1500);
                exports.gum_progressbars:DisplayProgressBar(5000);

                local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, -1.55));
                TriggerServerEvent('MoonShine:PlaceAlambic', x, y, z);

                Citizen.Wait(1000);
                FreezeEntityPosition(playerPed, false);
                ClearPedTasks(playerPed);
                return; 
            end
        end
    end
    
    --NotClose to Water:
    TriggerServerEvent("MoonShine:PlaceAlambicFailed", inwater);
end)



--Refresh Liste feu de camp allumer
RegisterNetEvent('MoonShine:RefreshClientList')
AddEventHandler('MoonShine:RefreshClientList', function(x, y, z, prop, propfire, state, fireTimer, CooldownTimer)
    local found = false
    for i, v in pairs(AlambicList) do
        if(v.Equals(x,y,z))then
            v.State = state
            v.FireTimer = fireTimer
            v.CoolDownTimer = CooldownTimer
            found = true

            v.PlaceObjects()
        end
    end

    if(found == false and loading == false)then
        AlambicList[#AlambicList+1] = Alambic(x, y, z, nil, nil, state, campfireTimer, CooldownTimer)
    end
end)

-- Start the Minigame
RegisterNetEvent("MoonShine:StartMinigame")
AddEventHandler('MoonShine:StartMinigame', function(x, y, z) 
    if(Config.Debug == true) then
        print("Start Minigame Fire");
    end

    HideAction = true;

    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), true)

    animationcampfire()
    TriggerEvent("vorp:TipBottom", 'Vous allumez un feu', 1500)
    exports.gum_progressbars:DisplayProgressBar(5000)

    -- Minigame Allumette
    local test = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7) -- difficulty,skillGapSent
    if test == 100 then
        -- Si Bon StartFire
        TriggerServerEvent("MoonShine:InitCampfire", x, y, z)
        
        Citizen.Wait(1000)
        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasks(PlayerPedId())

    else
        -- Else Error Message
        TriggerServerEvent('MoonShine:campfire_failed',x,y,z)
        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasks(PlayerPedId())
    end

    HideAction = false;
end)

--Remove From Client List
RegisterNetEvent('MoonShine:DeleteClientAlambic')
AddEventHandler('MoonShine:DeleteClientAlambic', function(x, y, z)

    for i, alambic in pairs(AlambicList) do
        if(alambic.Equals(x,y,z))then
            local todel = alambic;

            if(Config.Debug == true) then
                print("Delete From Client List");
            end
            
            table.remove(AlambicList, i);
            todel.DeleteAlambic();
            break
        end
    end

    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
end)

-- Ajout du charbon
RegisterNetEvent('MoonShine:addcoal')
AddEventHandler('MoonShine:addcoal', function(x,y,z)
    HideAction = true;

    local playerPed = PlayerPedId()

    FreezeEntityPosition(PlayerPedId(), true)
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 2000, true, false, false, false)
    exports.gum_progressbars:DisplayProgressBar(2500)
    TriggerServerEvent('MoonShine:AddCoal', x,y,z)
    FreezeEntityPosition(PlayerPedId(), false)
    
    HideAction = false;
end)