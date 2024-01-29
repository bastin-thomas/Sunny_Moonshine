RegisterServerEvent('MoonShine:CreateMout')
AddEventHandler('MoonShine:CreateMout', function()
    local _source = source
    local Mout = Config.Mout;
    TriggerClientEvent("Moonshine:HideAction", _source, true);
    TriggerClientEvent("Moonshine:FreezePlayer", _source, true);
    
    
    if(VorpInv.canCarryItems(_source, Mout.itemGain.qtyGain) and VorpInv.canCarryItem(_source, Mout.itemGain.id, Mout.itemGain.qtyGain))then    
        local iscountOK = true;

        for i, item in ipairs(Mout.itemUtil) do
            local count = VorpInv.getItemCount(_source, item.id);
            if count < item.qty then
                iscountOK = false;
                break;
            end
        end
       
        if(iscountOK == true) then
            -- Retrait item demandé
            for i, item in ipairs(Mout.itemUtil) do
                if(item.tool == false) then
                    VorpInv.subItem(_source, item.id, item.qty);
                end
            end    
            
            TriggerClientEvent("progressbar:moonshine", _source, ((Mout.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, 'Vous mettez de l\'eau dans le tonneau', (Mout.CraftingTime *1000) / 3)
            Wait((Mout.CraftingTime *1000) / 3)

            TriggerClientEvent("progressbar:moonshine", _source, ((Mout.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, 'Vous ajoutez les pommes de terre et le sucre dans l\'eau', (Mout.CraftingTime *1000) / 3)
            Wait((Mout.CraftingTime *1000) / 3)

            TriggerClientEvent("progressbar:moonshine", _source, ((Mout.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, 'Votre Moût fermente', (Mout.CraftingTime *1000) / 3)
            Wait((Mout.CraftingTime *1000) / 3)

            TriggerClientEvent("vorp:TipBottom", _source, 'Votre Moût est prêt', 4000)
            
            VorpInv.addItem(_source, Mout.itemGain.id, Mout.itemGain.qtyGain) --recompense
            VorpInv.addItem(_source, "canteenempty", 1) --recompense
            
            --Clear Animations
        else
            TriggerClientEvent("vorp:TipBottom", _source, "Vous avez besoin de " .. Mout.itemUtil[1].qty .. " pommes de terre, ".. Mout.itemUtil[2].qty .." sucre et 1 gourde pleine", 5000)
        end
    else
        TriggerClientEvent("vorp:TipBottom", _source, "Vous n'avez pas assez d'espace", 5000)
    end  

    TriggerClientEvent("Moonshine:HideAction", _source, false);
    TriggerClientEvent("Moonshine:FreezePlayer", _source, false);
end)





RegisterServerEvent('MoonShine:CreateMoonshine')
AddEventHandler('MoonShine:CreateMoonshine', function(x,y,z)
    local _source = source
    local Moonshine = Config.Moonshine;
    TriggerClientEvent("Moonshine:HideAction", _source, true);
    TriggerClientEvent("Moonshine:FreezePlayer", _source, true);
    
        
    if(VorpInv.canCarryItems(_source, Moonshine.itemGain.qtyGain) and VorpInv.canCarryItem(_source, Moonshine.itemGain.id, Moonshine.itemGain.qtyGain))then    
        local iscountOK = true;
        
        for i, item in ipairs(Moonshine.itemUtil) do
            local count = VorpInv.getItemCount(_source, item.id);
            if count < item.qty then
                iscountOK = false;
                break;
            end
        end
       
        if(iscountOK == true) then
            -- Retrait item demandé
            for i, item in ipairs(Moonshine.itemUtil) do
                if(item.tool == false) then
                    VorpInv.subItem(_source, item.id, item.qty);
                end
            end 

            CheckFireStatus(_source)

            TriggerClientEvent("progressbar:moonshine", _source, ((Moonshine.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, "Vous mettez le Moût à chauffer", (Moonshine.CraftingTime *1000) / 3)
            Wait((Moonshine.CraftingTime *1000) / 3)

            CheckFireStatus(_source)

            TriggerClientEvent("progressbar:moonshine", _source, ((Moonshine.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, 'Vous ajoutez le ginseng et le cassis', (Moonshine.CraftingTime *1000) / 3)
            Wait((Moonshine.CraftingTime *1000) / 3)

            CheckFireStatus(_source)

            TriggerClientEvent("progressbar:moonshine", _source, ((Moonshine.CraftingTime *1000) / 3) - 1000)
            TriggerClientEvent("vorp:TipBottom", _source, 'Votre Moonshine est en cours de distillation', (Moonshine.CraftingTime *1000) / 3)
            Wait((Moonshine.CraftingTime *1000) / 3)
            
            CheckFireStatus(_source)

            TriggerClientEvent("vorp:TipBottom", _source, 'Votre Moonshine est prête', 4000)
            
            VorpInv.addItem(_source, Moonshine.itemGain.id, Moonshine.itemGain.qtyGain) --recompense
            
            --Clear Animations
        else
            TriggerClientEvent("vorp:TipBottom", _source, "Vous avez besoin de " .. Moonshine.itemUtil[1].qty .. " Mout, ".. Moonshine.itemUtil[2].qty 
            .." ginseng, ".. Moonshine.itemUtil[3].qty .." cassis et "..Moonshine.itemUtil[4].qty.." bouteille", 5000)
        end
    else
        TriggerClientEvent("vorp:TipBottom", _source, "Vous n'avez pas assez d'espace", 5000)
    end  

    TriggerClientEvent("Moonshine:HideAction", _source, false);
    TriggerClientEvent("Moonshine:FreezePlayer", _source, false);
end)


function EndCraftFire(_source) 
    TriggerClientEvent("vorp:TipBottom", _source, 'Le feu c\'est éteint.', 4000)
    for i, item in ipairs(Config.Moonshine.itemUtil) do
        if(item.tool == false) then
            VorpInv.addItem(_source, item.id, item.qty);
        end
    end

    TriggerClientEvent("Moonshine:HideAction", _source, false);
    TriggerClientEvent("Moonshine:FreezePlayer", _source, false);
end

function CheckFireStatus(_source)
    for i, alambic in ipairs(AlambicList) do
        if(alambic.Equals(x,y,z))then
            if(alambic.State ~= 1) then
                EndCraftFire(_source);
                return;
            end
            break;
        end 
    end    
end


function GetCanteen(_source)
    if IsCanteenUsable(_source) then
        for i,canteen in pairs(Config.Canteen) do
            if VorpInv.getItemCount(_source, canteen) == 1 and  (canteen ~= Config.Canteen[#Config.Canteen])then
                return canteen
            end
        end
    end
    return "null"
end

function IsCanteenUsable(_source)
    local count = 0
    for i, can in pairs(Config.Canteen)do
        if(VorpInv.getItemCount(_source, can) >= 1)then
            count = count + 1
        end
    end
    
    if(count <= 1)then
        return true
    else
        return false
    end
end

function NextCanteen(canteen)
    local index = 0
    for i,can in pairs(Config.Canteen)do
        if(canteen == can)then
            index = i+1
            break
        end
    end

    if index == 0 then
        return "null"
    else
        return Config.Canteen[index]
    end
end