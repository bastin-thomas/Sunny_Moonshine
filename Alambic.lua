function Alambic(nx, ny, nz, prop, propfire, state, campfireTimer, cooldownTimer)
    local self = {}

    self.Coords = {
        x = nx or 0, 
        y = ny or 0, 
        z = nz or 0
    }

    -- Prop de l'alambic
    self.AlambicProp = prop or 0

    -- Prop du feux de camp
    self.PropFire = propfire or 0

    --Etat de l'alambic
    self.State = state or 0
    -- 0 = Alambic éteint
    -- 1 = Alambic allumé
    -- 2 = Alambic en Refroidissement
    -- -1 = ToDelete

    
    -- Temps du feux de Camp
    self.FireTimer = campfireTimer or Config.fireBaseTime

    -- Temps du CoolDown
    self.CoolDownTimer = cooldownTimer or Config.CoolDownTimer
    
    -- Lors d'une action bloquante il est a true (Rallumage et Démontage)
    self.BlockingAction = false
    

    self.print = function()
        print("Coords: ".. self.Coords.x .. ", ".. self.Coords.y .. ", " .. self.Coords.z .. ",  Prop: ".. self.AlambicProp .. ",  PropFire: ".. self.PropFire .. ",  State: ".. self.State ..  ", FireTimer: "..self.FireTimer..", CoolDownTimer: "..self.CoolDownTimer)
    end

    self.PlaceObjects = function()
        --Si A supprimé, ne rien faire
        if(self.State == -1) then
            return;
        end

        if(DoesObjectOfTypeExistAtCoords(self.Coords.x, self.Coords.y, self.Coords.z, 2.0, Config.AlambicProp) == false and loading == false) then
            if Config.Debug == true then
                print("Create Alambic");
            end
            
            self.AlambicProp = myCreateObject(self.Coords.x, self.Coords.y, self.Coords.z, Config.AlambicProp)
            PlaceObjectOnGroundProperly(self.AlambicProp);
        end
        
        if(self.State == 1) then
            if(DoesObjectOfTypeExistAtCoords(self.Coords.x-0.70, self.Coords.y, self.Coords.z - 0.4, 2.0, Config.CampfireProp) == false and loading == false) then
                if Config.Debug == true then
                    print("PlaceFire");
                end
                
                self.PropFire = myCreateObject(self.Coords.x-0.70, self.Coords.y, self.Coords.z- 0.4, Config.CampfireProp)
            end
            return;
        end

        if(self.State == 2) then
            if(DoesObjectOfTypeExistAtCoords(self.Coords.x - 0.70, self.Coords.y, self.Coords.z - 0.4, 2.0, Config.CampfireProp) == 1 and loading == false) then
                if Config.Debug == true then
                    print("Delete Fire");
                end
                
                DeleteObject(self.PropFire);
                self.PropFire = 0;
            end
        end
    end


    self.DeleteAlambic = function()
        if(DoesObjectOfTypeExistAtCoords(self.Coords.x, self.Coords.y, self.Coords.z, 2.0, Config.AlambicProp) == 1 and loading == false) then
            DeleteObject(self.AlambicProp);
            self.AlambicProp = 0;
            self.State = -1;
        end
    end
    

    self.StartServerCampfire = function()
        self.State = 1;
        self.TimerReset();
    end

    self.StopServerCampfire = function()
        self.State = 2;
        self.CoolDownReset();
    end

    self.FreezeServerCampfire = function()
        self.State = 0;
    end


    self.TimerInscreased = function(Seconds)
        self.FireTimer = self.FireTimer + Seconds;
    end

    self.TimerDecreased = function()
        if(self.State == 1) then
            self.FireTimer = self.FireTimer - 1;
        end
    end



    self.TimerReset = function()
        self.FireTimer = Config.fireBaseTime;
    end


    self.CoolDownDecreased = function()
        if(self.State == 2) then
            self.CoolDownTimer = self.CoolDownTimer - 1;
        end
    end

    self.CoolDownReset = function()
        self.CoolDownTimer = Config.CoolDownTimer;
    end



    self.Equals = function(x, y, z)
        if(self.Coords.x == x and self.Coords.y == y and self.Coords.z == z)then
            return true;
        else
            return false;
        end
    end

    return self
end

--- Place a client object on the map
---@param x number
---@param y number
---@param z number
---@param prophash NameHash
function myCreateObject(x,y,z, prophash)
    local prop = CreateObject(GetHashKey(prophash), x, y, z, false, true, false);
    --RequestModel(prop, true);
    SetEntityAsMissionEntity(prop);
    SetEntityHeading(prop, 0);
    
    return prop
end