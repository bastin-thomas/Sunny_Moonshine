AlambicList = {}

loading = true;

Start_Group = GetRandomIntInRange(0, 0xffffff);
Hot_Group = GetRandomIntInRange(0, 0xffffff);
Cooldown_Group = GetRandomIntInRange(0, 0xffffff);

HideAction = false;

--Verify if you are at the end of the loading.
Citizen.CreateThread(function()
    Wait(10000)
    print("Chargement des Alambics")
    loading = false
end)

--// Gestion Debug //--
Citizen.CreateThread(function() 
    if(Config.Debug)then
    while true do
            print()
            print("AlambicList:")
            for i,v in pairs(AlambicList)do
                v.print()
            end
            Citizen.Wait(30000)
        end
    end
end)

function InitPrompt(promptgroup, promptname, touche)
    local prompt = PromptRegisterBegin() --Init Prompt
    PromptSetControlAction(prompt, touche) -- Set de la touche
    str = CreateVarString(10, 'LITERAL_STRING', promptname)
    PromptSetText(prompt, str)
    PromptSetEnabled(prompt, 1)
    PromptSetVisible(prompt, 1)
    PromptSetStandardMode(prompt,1)
    PromptSetGroup(prompt, promptgroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C,prompt, true)
    PromptRegisterEnd(prompt)
    return prompt
end

--// Gestion des prompts //--
Citizen.CreateThread(function()
    local playerPed = PlayerPedId()

    local start = InitPrompt(Start_Group, "Démarrer le feu", keys.G)
    local craftmout = InitPrompt(Start_Group, "Fabriquer du Moût", keys.R)
    local unmount = InitPrompt(Start_Group, "Démonter l'Alambic", keys.E)
    
    local coal = InitPrompt(Hot_Group, "Ajouter Bois", keys.G)
    local build = InitPrompt(Hot_Group, "Distiller", keys.R)
    local stopfire = InitPrompt(Hot_Group, "Eteindre le feu", keys.E)
    
    

    local restart = InitPrompt(Cooldown_Group, "Ralumer l'Alambic", keys.R)

    Citizen.Wait(10000)
    local coords

	while true do
        Citizen.Wait(0)
        coords = GetEntityCoords(PlayerPedId())

        for k, v in pairs(AlambicList) do
            if(v.BlockingAction == false and HideAction == false)then
                --Prompt, Alambic Froid
                if(v.State == 0) then
                    if GetDistanceBetweenCoords(coords, v.Coords.x, v.Coords.y, v.Coords.z, false) < 1.7 and not IsPedDeadOrDying(PlayerPedId()) and v.BlockingAction == false then
                        
                        local label = CreateVarString(10, 'LITERAL_STRING', "Alambic")
                        PromptSetActiveGroupThisFrame(Start_Group, label)
                        
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, start) then
                            --StartCampfire -> 1 alumette + 3 bois
                            TriggerServerEvent('MoonShine:StartCampfire', v.Coords.x, v.Coords.y, v.Coords.z);
                        end
                        
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, craftmout) then
                            if(Config.Debug == true) then
                                print("CraftMout") 
                            end
                            -- Création du mout
                            TriggerServerEvent("MoonShine:CreateMout");
                        end

                        if Citizen.InvokeNative(0xC92AC953F0A982AE, unmount) then
                            if(Config.Debug == true) then
                                print("Dismount")
                            end
                            FreezeEntityPosition(playerPed, true)
                            TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 7000, true, false, false, false)

                            TriggerEvent("vorp:TipBottom", 'Vous démontez l\'Alambic', 3500)
                            exports.gum_progressbars:DisplayProgressBar(5000)

                            TriggerServerEvent("MoonShine:DismountAlambic", v.Coords.x, v.Coords.y, v.Coords.z);
                            Citizen.Wait(1000);
                            
                            FreezeEntityPosition(playerPed, false)
                            ClearPedTasks(playerPed)
                        end
                    end
                    
                --Prompt, Alambic Chaud
                elseif(v.State == 1) then
                    if GetDistanceBetweenCoords(coords, v.Coords.x, v.Coords.y, v.Coords.z, false) < 1.7 and not IsPedDeadOrDying(PlayerPedId()) and v.BlockingAction == false then
                        local label = CreateVarString(10, 'LITERAL_STRING', "Alambic Allumé: " .. v.FireTimer)
                        PromptSetActiveGroupThisFrame(Hot_Group, label)
        
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, coal) then
                            TriggerServerEvent("MoonShine:CheckItems_addcoal", v.Coords.x, v.Coords.y, v.Coords.z)
                        end
        
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, build) then
                            TriggerServerEvent("MoonShine:CreateMoonshine", v.Coords.x, v.Coords.y, v.Coords.z)
                        end

                        if Citizen.InvokeNative(0xC92AC953F0A982AE, stopfire) then
                            HideAction = true;

                            FreezeEntityPosition(playerPed, true);
                            ClearPedTasks(playerPed);
                            
                            TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 7000, true, false, false, false)

                            TriggerEvent("vorp:TipBottom", 'Vous éteignez le feu', 3500)
                            exports.gum_progressbars:DisplayProgressBar(6500)

                            TriggerServerEvent('MoonShine:StopCampfire', v.Coords.x, v.Coords.y, v.Coords.z);
                            
                            FreezeEntityPosition(playerPed, false);
                            ClearPedTasks(playerPed);

                            HideAction = false;
                        end
                    end

                --Prompt, Alambic en Refroidissement
                elseif(v.State == 2) then
                    if GetDistanceBetweenCoords(coords, v.Coords.x, v.Coords.y, v.Coords.z, false) < 1.7 and not IsPedDeadOrDying(PlayerPedId()) and v.BlockingAction == false then
                        local label = CreateVarString(10, 'LITERAL_STRING', "Alambic Chaud: " .. v.CoolDownTimer)
                        PromptSetActiveGroupThisFrame(Cooldown_Group, label)
                        if Citizen.InvokeNative(0xC92AC953F0A982AE, restart) then
                            TriggerServerEvent('MoonShine:StartCampfire', v.Coords.x, v.Coords.y, v.Coords.z);
                        end
                    end
                end
            end
        end
    end
end)


RegisterNetEvent('progressbar:moonshine')
AddEventHandler('progressbar:moonshine', function(time)
    local playerPed = PlayerPedId();
    animationmooshine()  
    exports.gum_progressbars:DisplayProgressBar(time)
end)

RegisterNetEvent('Moonshine:HideAction')
AddEventHandler('Moonshine:HideAction', function(param)
    if(Config.Debug == true) then
        print("HideAction: " .. tostring(param))
    end
    HideAction = param;
end)

RegisterNetEvent('Moonshine:FreezePlayer')
AddEventHandler('Moonshine:FreezePlayer', function(param)
    if(Config.Debug == true) then
        print("FreezePlayer: " .. tostring(param))
    end

    local playerPed = PlayerPedId();
    ClearPedTasks(playerPed);
    FreezeEntityPosition(playerPed, param);
end)

function animationcampfire()
    RequestAnimDict("script_campfire@lighting_fire@male_female")
    while not HasAnimDictLoaded("script_campfire@lighting_fire@male_female") do
        Citizen.Wait(1)
		RequestAnimDict("script_campfire@lighting_fire@male_female")
    end
    TaskPlayAnim(PlayerPedId(), "script_campfire@lighting_fire@male_female", "light_fire_b_p2_male", 1.0, 8.0, -1, 1, 0, false, 0, false, 0, false)
end


function animationmooshine()
    RequestAnimDict("amb_camp@prop_camp_foodprep@working@seasoning@male_b@idle_c")
    while not HasAnimDictLoaded("amb_camp@prop_camp_foodprep@working@seasoning@male_b@idle_c") do
        Citizen.Wait(1)
		RequestAnimDict("amb_camp@prop_camp_foodprep@working@seasoning@male_b@idle_c")
    end
    TaskPlayAnim(PlayerPedId(), "amb_camp@prop_camp_foodprep@working@seasoning@male_b@idle_c", "idle_h", 1.0, 8.0, -1, 1, 0, false, 0, false, 0, false)
end