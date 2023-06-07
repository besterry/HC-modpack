--require "ISUI/ISPanelJoypad"
--require "ISUI/Maps/ISMap"
--require "ISUI/Maps/ISWorldMapSymbols"

require "ISUI/Maps/ISWorldMap"

local upperLayer = {}
upperLayer.ISWorldMap = {}

upperLayer.ISWorldMap.onCenterOnPlayer = ISWorldMap.onCenterOnPlayer
function ISWorldMap:onCenterOnPlayer()
    upperLayer.ISWorldMap.onCenterOnPlayer(self)

	--if self.character:getInventory():containsType("GPSdayz") == false and self.character:getInventory():containsType("WalkieTalkie5") == false then
    --local player = getSpecificPlayer(0)
    local gps = self.character:getInventory():getItemFromType("GPSdayz")
    local PrimaryHand = self.character:getPrimaryHandItem()
    local SecondaryHand = self.character:getSecondaryHandItem()
    local hotbar = getPlayerHotbar(self.character:getPlayerNum())
    local fromHotbar = false;

	if gps and not isAdmin() then
        local modData = gps:getModData() 

        if not gps:isEquipped() then
            
            if hotbar then
                fromHotbar = hotbar:isItemAttached(gps)
            end

            if fromHotbar and gps:getUsedDelta() > 0.005 then
                self.character:setSecondaryHandItem(gps)
                gps:setActivated(true);
                getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), self.character:getCurrentSquare(), 1, 25, 2, true)--self.character:playSound("GPS_Beep_2") end
            elseif gps:getUsedDelta() > 0.005 then
                
                ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, gps, 100, false, twoHands)) --player:setSecondaryHandItem(gps) 
                getSoundManager():PlayWorldSound("GPS_Equip_1", self.character:getCurrentSquare(), 1, 25, 2, true)
            end
        elseif gps:getUsedDelta() > 0.005 and gps:isEquipped() then 
            gps:setActivated(true);
        end
		
		if not modData.ReceiveGPS or not gps:isActivated() or gps:getUsedDelta() <= 0.005 or (not(PrimaryHand and PrimaryHand:getType() == "GPSdayz") and not(SecondaryHand and SecondaryHand:getType() == "GPSdayz")) then

            if  BRIDE_centerPlayer == 0 then
               
                ISWorldMap_instance.mapAPI:setZoom(16) -- 15
    
                plyX_rand_posMAP = self.character:getX()+ZombRand(-250,250)+ ZombRand(-350,350)+ZombRand(-60,60) --100,100 90
                plyY_rand_posMAP = self.character:getY()+ZombRand(-250,250)+ ZombRand(-350,350)+ZombRand(-60,60) --80,80
    
                BRIDE_centerPlayer = 1
            end
    
            self.mapAPI:centerOn(plyX_rand_posMAP, plyY_rand_posMAP) 
        else
            self.character:playSound("GPS_Beep_2")
        end
    elseif not isAdmin() then
        if  BRIDE_centerPlayer == 0 then
    	   
            ISWorldMap_instance.mapAPI:setZoom(16) -- 15

            plyX_rand_posMAP = self.character:getX()+ZombRand(-250,250)+ ZombRand(-350,350)+ZombRand(-60,60) --100,100 90
            plyY_rand_posMAP = self.character:getY()+ZombRand(-250,250)+ ZombRand(-350,350)+ZombRand(-60,60) --80,80

            BRIDE_centerPlayer = 1
        end

        self.mapAPI:centerOn(plyX_rand_posMAP, plyY_rand_posMAP)     
    end
end

upperLayer.ISWorldMap.new = ISWorldMap.new
function ISWorldMap:new(x, y, width, height)
    local o = upperLayer.ISWorldMap.new( self, x, y, width, height)
    
    o.beep = 0
    if not isAdmin() then 
        o.showPlayers = false
    else
        o.showPlayers = true
    end
    return o
end


--upperLayer.ISWorldMap.close = ISWorldMap.close
--function ISWorldMap:close()
--    upperLayer.ISWorldMap.close(self)
--    --self.BRIDE_centerPlayer = 0
--end



--unpreciseCoordinateX = math.floor(preciseCoordinateX/precisionLoss)*precisionLoss
--with precisionLoss = 30 for exemple

BRIDE_centerPlayer = 0
local function DEBRIDE()
	if BRIDE_centerPlayer ~= 0 then BRIDE_centerPlayer = 0 end
end

------------------------------------------------------------------------------------------------------------------------
--Events.EveryOneMinute.Add(GPS_autorized)
--Events.EveryTenMinutes.Add(DEBRIDE)
Events.EveryHours.Add(DEBRIDE)
--Events.EveryDays.Add(transmissionEmitteur)
------------------------------------------------------------------------------------------------------------------------