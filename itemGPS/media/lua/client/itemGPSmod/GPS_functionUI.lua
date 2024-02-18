require "ISUI/Maps/ISMiniMap"
require "ISUI/ISUIElement"
local upperLayer = {}
upperLayer.ISMiniMapInner = {}
upperLayer.ISMiniMapTitleBar = {}

-------------------------------------------------------------------------------------------------------------
--CREATE SECTION
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:removeAllChildGPS()

	if self.labelText_Date 				 then self:removeChild(self.labelText_Date) 			  ; self.labelText_Date 			  = nil end
	if self.labelText_Time 				 then self:removeChild(self.labelText_Time) 			  ; self.labelText_Time 			  = nil end
	if self.labelText_X 				 then self:removeChild(self.labelText_X) 				  ; self.labelText_X 				  = nil end
	if self.labelText_Y 				 then self:removeChild(self.labelText_Y) 				  ; self.labelText_Y 				  = nil end
	if self.labelText_Cell 				 then self:removeChild(self.labelText_Cell) 			  ; self.labelText_Cell 			  = nil end
	if self.labelText_Alt 				 then self:removeChild(self.labelText_Alt) 				  ; self.labelText_Alt 		 		  = nil end
	if self.labelText_Dir 				 then self:removeChild(self.labelText_Dir) 				  ; self.labelText_Dir 		 		  = nil end
	if self.labelText_Bat 				 then self:removeChild(self.labelText_Bat) 				  ; self.labelText_Bat 		 		  = nil end
	if self.labelText_Waypoint_1 		 then self:removeChild(self.labelText_Waypoint_1) 		  ; self.labelText_Waypoint_1 		  = nil end	
	if self.labelText_Waypoint_cell_1 	 then self:removeChild(self.labelText_Waypoint_cell_1) 	  ; self.labelText_Waypoint_cell_1 	  = nil end
	if self.labelText_Waypoint_DistDir_1 then self:removeChild(self.labelText_Waypoint_DistDir_1) ; self.labelText_Waypoint_DistDir_1 = nil end
	if self.labelText_Waypoint_2 		 then self:removeChild(self.labelText_Waypoint_2) 		  ; self.labelText_Waypoint_2 		  = nil end
	if self.labelText_Waypoint_cell_2 	 then self:removeChild(self.labelText_Waypoint_cell_2) 	  ; self.labelText_Waypoint_cell_2 	  = nil end
	if self.labelText_Waypoint_DistDir_2 then self:removeChild(self.labelText_Waypoint_DistDir_2) ; self.labelText_Waypoint_DistDir_2 = nil end
	if self.labelText_chargeUP1 		 then self:removeChild(self.labelText_chargeUP1) 		  ; self.labelText_chargeUP1 		  = nil end
	if self.labelText_chargeUP2 		 then self:removeChild(self.labelText_chargeUP2) 		  ; self.labelText_chargeUP2 		  = nil end
	if self.itemGPS_texture 		 	 then self:removeChild(self.itemGPS_texture) 		  	  ; self.itemGPS_texture 		  	  = nil end
	if self.PlugedGps_texture 			 then self:removeChild(self.PlugedGps_texture) 			  ; self.PlugedGps_texture = nil end
end
-------------------------------------------------------------------------------------------------------------
--function ISMiniMapInner:checkDisplayGPS()
--	if itemGPSmod.restartCounter == nil and not isAdmin() then
--		local settings = WorldMapSettings.getInstance()
--		settings:setBoolean("MiniMap.StartVisible", false) 
--	end
--end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:midleLoopGPS()
	if self.labelText_Dir then self:removeChild(self.labelText_Dir) ; self.labelText_Dir = nil end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:soundGPS()
	itemGPSmod.restartCounter = false
	if not self.counter_GPS2 or self.counter_GPS2 == 0 then 
		self.counter_GPS2 = 4
	end
	if self.counter_GPS2 == 2 or self.counter_GPS2 == 4 then
		itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_SIGNAL")

	elseif self.counter_GPS2 == 3 then
		if self.gps:hasTag("GPSmod") and self.gps:getUsedDelta() <= 0.12 then
			itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_chargeLOW")
		end
	end
	self.counter_GPS2 = self.counter_GPS2 -1
end
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:counterGPS()
	if  self.counter_GPS ~= nil and
		self.counter_GPS ~= 1   and 
		self.counter_GPS ~= 2   and 
		self.counter_GPS ~= 20  and
		self.counter_GPS ~= 40  and
		itemGPSmod.restartCounter == true and 
		self.gps == itemGPSmod.gps then 

		self.counter_GPS = self.counter_GPS +1
		if self.counter_GPS == 39 or self.counter_GPS == 19 then self:midleLoopGPS() end
		if self.counter_GPS == 60 then self:soundGPS() end

		return false				
	else
		return true
	end	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


                                    --START CODE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:update()
	if not isClient() and MainScreen.instance:getIsVisible() then return end
	if self:counterGPS() then
		self:functionGPS()	 
	end
end
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:functionGPS()
	--------------------------			
	--self:checkDisplayGPS()			
		
	if itemGPSmod.restartCounter ~= true or (self.gps ~= nil and self.gps ~= itemGPSmod.gps) then
		itemGPSmod.restartCounter = true
		self.counter_GPS = nil --new nil / 0 
		self:removeAllChildGPS() 
	end
	--------------------------
	self.player = getPlayer();
	--------------------------			
	if not self.player then return end
	--------------------------	
    if not isAdmin() and (not itemGPSmod.confirmGPS(self.player,itemGPSmod.gps) or self.player:isDead()) then	
    	if self.gps ~= nil then itemGPSmod.playSoundGPS(self.player, self.gps:getType().."_Beep_OFF") end
    	itemGPSmod.ToggleMiniMap(self.player, false, itemGPSmod.gps)
    	self.counter_GPS = nil
    	self.gps = nil
    	return 
    elseif isAdmin() and (not itemGPSmod.confirmGPS(self.player,itemGPSmod.gps) or self.player:isDead()) then
    	 self:removeAllChildGPS()
    	 itemGPSmod.restartCounter = true
    	 self.counter_GPS = 0 
    	 self.gps = nil	
    	return
    end
	self.gps = itemGPSmod.gps
	self.gpsType = self.gps:getType()
	--------------------------					
	if not self.itemGPS_texture then 
		self:loadTextureUIGPS()
	end
	--------------------------	Title   Small Medium Large Cred1 NewSmall NewMedium NewLarge 
	self:plugedGPS()
	if 	   self.gpsType == "GPSdayz"  then self.r = 0.5  ; self.g = 0.8  ; self.b = 0.3  ; self.UIFont = UIFont.Small 
	elseif self.gpsType == "GPS_315"  then self.r = 0.25 ; self.g = 0.15 ; self.b = 0.05 ; self.UIFont = UIFont.Medium
	elseif self.gpsType == "GPS_DAGR" then self.r = 0.2  ; self.g = 0.1  ; self.b = 0 	 ; self.UIFont = UIFont.Medium
	elseif self.gpsType == "GPS_G48"  then self.r = 0 	 ; self.g = 0.15 ; self.b = 0.1  ; self.UIFont = UIFont.Medium
	elseif self.gpsType == "GPS_H800" then self.r = 0.7  ; self.g = 1 	 ; self.b = 1    ; self.UIFont = UIFont.Small
	end

	--------------------------	 
	if self.counter_GPS == 1 then
		if self.gps:getModData()["waypointGPS1"] then self:waypointGPS(1) end
		if self.gps:getModData()["waypointGPS2"] then self:waypointGPS(2) end
		self:coordGPS()
		self:cellGPS()
		self:altGPS()
		self:timeGPS()
		if self.gps:hasTag("GPSmod") then self:chargeGPS() else end
	elseif self.counter_GPS == 40 or self.counter_GPS == 20 or self.counter_GPS == 2 then	
		
		self:dirGPS()
		if self.gps:hasTag("GPSmod") then self:rechargingGPS() end
	end
	----------------------------			
    if self.counter_GPS == nil then self.counter_GPS = 0 end	
    ----------------------------			
    self.counter_GPS = self.counter_GPS +1
	--------------------------
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:timeGPS()
	self.x 	= 0
	self.y 	= 0
	self.x2 = 0
	self.y2 = 0
	self.txt  = nil
	self.txt2 = nil
	self.UIFontLocal  = self.UIFont
	self.UIFontLocal2 = self.UIFont
	--------------------------------------------
	local minute = getGameTime():getMinutes()
	local hour 	 = getGameTime():getHour()
	local day 	 = getGameTime():getDay() +1
	local month  = getGameTime():getMonth() +1
	local year 	 = getGameTime():getYear()
	--------------------------------------------
	if minute < 10 then minute = "0"..minute end
	if hour   < 10 then hour   = "0"..hour   end
	if day    < 10 then day    = "0"..day    end
	--------------------------------------------
	if 	   month  == 1  then month = "Jan" 
	elseif month  == 2  then month = "Feb" 
	elseif month  == 3  then month = "Mar" 
	elseif month  == 4  then month = "Apr" 
	elseif month  == 5  then month = "May" 
	elseif month  == 6  then month = "Jun" 
	elseif month  == 7  then month = "Jul" 
	elseif month  == 8  then month = "Aug" 
	elseif month  == 9  then month = "Sep" 
	elseif month  == 10 then month = "Oct" 
	elseif month  == 11 then month = "Nov" 
	elseif month  == 12 then month = "Dec" 
	end
	--------------------------------------------
	--	if 	   self.gpsType == "GPSdayz"  then self.x = -49  ; self.y = -28	 ; self.txt  = txt = "| " .. hour ..":" .. minute .." | d" .. day .." | m" .. month .." | y" .. year .. " |"
	if 	   self.gpsType == "GPS_315"  then self.x = 110 ; self.y = 6 ; self.txt = hour..":"..minute 
	elseif self.gpsType == "GPS_DAGR" then self.x = -5 ; self.y = 119  ; self.txt = hour..":"..minute ; self.x2 = 33 ; self.y2 = 119 ; self.txt2 = "| "  ..day.."-"..month .."-"..year
	elseif self.gpsType == "GPS_G48"  then self.x = 60 ; self.y = 143 ; self.txt = hour..":"..minute ; self.x2 = 48 ; self.y2 = 168 ; self.txt2 = day.." | "..month .." | "..year; self.UIFontLocal = UIFont.Title ; self.UIFontLocal2 = UIFont.NewLarge
	elseif self.gpsType == "GPS_H800" then self.x = 187 ; self.y = 12	; self.txt = hour..":"..minute ; self.x2 = 102; self.y2 = 12; self.txt2 = "| "..day.." - "..month .." - "..year.." |"
	end
	if self.txt  == nil then return end
	--------------------------------------------
	--local currentHour = math.floor(math.floor(GameTime:getInstance():getTimeOfDay() * 3600) / 3600)
	--local txt = "| " .. hour ..":" .. minute .." | d" .. day .." | m" .. month .." | y" .. year .. " |"
	self.labelText_Time = ISLabel:new(self.x, self.y, 20, self.txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
	self:addChild(self.labelText_Time)
	if self.txt2  == nil then return end
	self.labelText_Date = ISLabel:new(self.x2, self.y2, 20, self.txt2, self.r, self.g, self.b, 1, self.UIFontLocal2, true);
	self:addChild(self.labelText_Date)
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:plugedGPS()
	self.x = 0
	self.y = 0
	if self.gps ~= itemGPSmod.gps and self.PlugedGps_texture then self:removeChild(self.PlugedGps_texture) end
	if not self.PlugedGps_texture and self.gpsType == "GPS_H800" then 
		self.x = 8 
		self.y = 275
		local texture = getTexture("media/ui/GPSdayz_Cable.png")
		self.PlugedGps_texture = ISImage:new(self.x, self.y, 0.5, 0.5, texture);
		self:addChild(self.PlugedGps_texture)
		return
	elseif self.gpsType == "GPS_H800" then
		return
	end
	self.vehicleInside = self.player:getVehicle()
	if not self.PlugedGps_texture and self.vehicleInside and itemGPSmod.PlugedGps and itemGPSmod.PlugedGps == self.gps then
		
		if 	   self.gpsType == "GPSdayz"  then self.x = 8 ; self.y = 254
		elseif self.gpsType == "GPS_315"  then self.x = 8 ; self.y = 423
		elseif self.gpsType == "GPS_DAGR" then self.x = 8 ; self.y = 486
		elseif self.gpsType == "GPS_G48"  then self.x = 8 ; self.y = 235
		end
		local texture = getTexture("media/ui/GPSdayz_Cable.png")
		self.PlugedGps_texture = ISImage:new(self.x, self.y, 0.5, 0.5, texture);
		self:addChild(self.PlugedGps_texture)
	elseif self.PlugedGps_texture and (not self.vehicleInside or not itemGPSmod.PlugedGps or (itemGPSmod.PlugedGps and itemGPSmod.PlugedGps ~= self.gps)) then
		self:removeChild(self.PlugedGps_texture)
		self.PlugedGps_texture = nil
	end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:rechargingGPS()
	if self.vehicleInside and self.vehicleInside:getBatteryCharge() > 0 and (self.vehicleInside:isKeysInIgnition() or self.vehicleInside:isHotwired()) then
		if self.counter_GPS == 2 and itemGPSmod.PlugedGps and self.gps == itemGPSmod.PlugedGps then
			self.x = 0
			self.y = 0
			self.r2 = self.r
			self.g2 = self.g
			self.b2 = self.b
			if 	   self.gpsType == "GPSdayz"  then self.x = 200 ; self.y = 12
			elseif self.gpsType == "GPS_315"  then self.x = 149 ; self.y = 14
			elseif self.gpsType == "GPS_DAGR" then self.x = 128 ; self.y = 127 ; self.r2 = 0.7 ; self.g2 = 0.5 ; self.b2 = 0
			elseif self.gpsType == "GPS_G48"  then self.x = 128 ; self.y = 36
			end 
			local text = "^"
			self.labelText_chargeUP1 = ISLabel:new(self.x, self.y, 20, text, self.r2, self.g2, self.b2, 1, self.UIFont, true);
			self:addChild(self.labelText_chargeUP1);
		elseif self.counter_GPS == 20 and itemGPSmod.PlugedGps and self.gps == itemGPSmod.PlugedGps then
			self.x = 0
			self.y = 0
			if 	   self.gpsType == "GPSdayz"  then self.x = 200 ; self.y = 7
			elseif self.gpsType == "GPS_315"  then self.x = 149 ; self.y = 7
			elseif self.gpsType == "GPS_DAGR" then self.x = 128 ; self.y = 120 ; self.r2 = 0.7 ; self.g2 = 0.5 ; self.b2 = 0
			elseif self.gpsType == "GPS_G48"  then self.x = 128 ; self.y = 30
			end 
			local text = "^"
			self.labelText_chargeUP2 = ISLabel:new(self.x, self.y, 20, text, self.r2, self.g2, self.b2, 1, self.UIFont, true);
			self:addChild(self.labelText_chargeUP2);
		elseif self.counter_GPS == 40 and itemGPSmod.PlugedGps and self.gps == itemGPSmod.PlugedGps then
			if self.labelText_chargeUP1 then self:removeChild(self.labelText_chargeUP1) ; self.labelText_chargeUP1 = nil end
	   		if self.labelText_chargeUP2 then self:removeChild(self.labelText_chargeUP2) ; self.labelText_chargeUP2 = nil end
		end
	end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:chargeGPS()
	self.x = 0
	self.y = 0
	self.txt = "Bat: "
	self.deltaUse = 0.001
	self.UIFontLocal = self.UIFont
	if 	   self.gpsType == "GPSdayz"  then self.x = 149 ; self.y = 7 ; self.deltaUse = 0.0003 ; 
	elseif self.gpsType == "GPS_315"  then self.x = 159 ; self.y = 7 ; self.deltaUse = 0.0004 ; self.txt = "" ; self.UIFontLocal = UIFont.NewSmall
	elseif self.gpsType == "GPS_DAGR" then self.x = 138 ; self.y = 119 ; self.deltaUse = 0.0002 ; self.txt = ""
	elseif self.gpsType == "GPS_G48"  then self.x = 140 ; self.y = 29 ; self.deltaUse = 0.0001 ; self.txt = ""
	end 
	self.bonusCharge = 1
	if itemGPSmod.PlugedGps and itemGPSmod.PlugedGps == self.gps then self.bonusCharge = 4 end
	if not isAdmin() then self.gps:setUsedDelta(self.gps:getUsedDelta()-((self.deltaUse*SandboxVars.itemGPS.UseBatteryMultiplier)/self.bonusCharge)) end
	local charge = self.gps:getUsedDelta()*100
	local txt = self.txt..string.format("%.0f",charge) .. "%"--charge .. "%"
	self.labelText_Bat = ISLabel:new(self.x, self.y, 20, txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
	self:addChild(self.labelText_Bat); 
end
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:loadTextureUIGPS()
	self.x = 0
	self.y = 0
	if 	   self.gpsType == "GPSdayz"  then self.x = -49  ; self.y = -28
	elseif self.gpsType == "GPS_315"  then self.x = -23  ; self.y = -247
	elseif self.gpsType == "GPS_DAGR" then self.x = -59  ; self.y = -106
	elseif self.gpsType == "GPS_H800" then self.x = -181 ; self.y = -57
	elseif self.gpsType == "GPS_G48"  then self.x = -22  ; self.y = -477
	end
	local GPSstyleOption = ""
	if SandboxVars.CartographyModifier and SandboxVars.CartographyModifier.itemGPSdarkMod == true then 
		GPSstyleOption = "Dark"
	end

	local texture = getTexture("media/ui/"..self.gpsType.. GPSstyleOption ..".png")
	self.itemGPS_texture = ISImage:new(self.x, self.y, 1, 1, texture);
	self:addChild(self.itemGPS_texture)
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:altGPS()
	self.x = 0
	self.y = 0
	self.txt  = nil
	if 	   self.gpsType == "GPSdayz"  then self.x = -7 ; self.y = 40 ; self.txt  = true ; self.txt = "Alt: "
	--elseif self.gpsType == "GPS_315"  then self.x = -7 ; self.y = 40 ; self.txt  = true ; self.txt = 
	elseif self.gpsType == "GPS_DAGR" then self.x = 98 ; self.y = 35 ; self.txt  = true ; self.txt = ""
	elseif self.gpsType == "GPS_G48"  then self.x = 36 ; self.y = 29 ; self.txt  = true ; self.txt = ""
	--elseif self.gpsType == "GPS_H800" then self.x = -7 ; self.y = 40 ; self.txt  = true ; self.txt = 
	end
	if not self.txt then return end
	local posZ = self.player:getZ()
	local txt0 = self.txt .. posZ;
	self.labelText_Alt = ISLabel:new(self.x, self.y, 20, txt0, self.r, self.g, self.b, 1, self.UIFont, true);
	self:addChild(self.labelText_Alt); 
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:dirGPS()
	self.x = 0
	self.y = 0
	self.txt  = nil
	if 	   self.gpsType == "GPSdayz"  then self.x = -7 ; self.y = 28 ; self.option  = true ; self.txt = "Dir: "
	--elseif self.gpsType == "GPS_315"  then self.x = -7 ; self.y = 28 ; self.option  = true
	elseif self.gpsType == "GPS_DAGR" then self.x = 143 ; self.y = 35 ; self.option  = true ; self.txt = ""
	elseif self.gpsType == "GPS_G48"  then self.x = 95 ; self.y = 10 ; self.option  = true ; self.txt = ""
	elseif self.gpsType == "GPS_H800" then self.x = -27 ; self.y = 81 ; self.option  = true ; self.txt = "Dir: "
	end
	if not self.txt then return end
	local dir = self.player:getDir()
	local IsoDirection_player = nil
	if dir == IsoDirections.N then
		IsoDirection_player = self.txt.."N" 
	elseif dir == IsoDirections.NE then
		IsoDirection_player = self.txt.."N.E" 
	elseif dir == IsoDirections.E then
		IsoDirection_player = self.txt.."E" 
	elseif dir == IsoDirections.SE then
		IsoDirection_player = self.txt.."S.E" 
	elseif dir == IsoDirections.S then
		IsoDirection_player = self.txt.."S" 
	elseif dir == IsoDirections.SW then
		IsoDirection_player = self.txt.."S.W" 
	elseif dir == IsoDirections.W then
		IsoDirection_player = self.txt.."W" 
	elseif dir == IsoDirections.NW then
		IsoDirection_player = self.txt.."N.W" 
	end
	if IsoDirection_player then 
		self.labelText_Dir = ISLabel:new(self.x, self.y, 20, IsoDirection_player, self.r, self.g, self.b, 1, self.UIFont, true);
	   	self:addChild(self.labelText_Dir);
	end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:coordGPS()
	self.x  = 0
	self.y  = 0
	self.x2 = 0
	self.y2 = 0
	self.option = false
	self.UIFontLocal = self.UIFont
	if 	   self.gpsType == "GPSdayz"  then self.x = -7 ; self.y = 4 ; self.x2 = 40 ; self.y2 = 4 ; self.option = true
	--elseif self.gpsType == "GPS_315"  then self.x = -7 ; self.y = 4 ; self.x2 = 15 ; self.y2 = 4 ; self.option = true
	elseif self.gpsType == "GPS_DAGR" then self.x = -5 ; self.y = 10 ; self.x2 = 58 ; self.y2 = 10 ; self.option = true
	elseif self.gpsType == "GPS_G48"  then self.x = 55 ; self.y = 52 ; self.x2 = 115 ; self.y2 = 53 ; self.option = true --; self.UIFontLocal = UIFont.NewLarge
	--elseif self.gpsType == "GPS_H800" then self.x = -7 ; self.y = 4 ; self.x2 = 15 ; self.y2 = 4
	end 
	if self.option  == false then return end
	local inaccuracy_X = self:getInaccuracy()
	local inaccuracy_Y = self:getInaccuracy()
	local posX = math.floor(self.player:getX())+inaccuracy_X
	local posY = math.floor(self.player:getY())+inaccuracy_Y
	local txtx = "x: " .. (posX)	
	local txty = "y: " .. (posY)
	self.labelText_X = ISLabel:new(self.x, self.y, 20, txtx, self.r, self.g, self.b, 1, self.UIFontLocal, true)
	self:addChild(self.labelText_X) 

	self.labelText_Y = ISLabel:new(self.x2, self.y2, 20, txty, self.r, self.g, self.b, 1, self.UIFontLocal, true)
	self:addChild(self.labelText_Y)
	
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:cellGPS()
	self.x  = 0
	self.y  = 0
	self.option = false
	if 	   self.gpsType == "GPSdayz"  then self.x = -7 ; self.y = 16 ; self.option = true
	elseif self.gpsType == "GPS_315"  then self.x = 10 ; self.y = 6 ; self.option = true
	elseif self.gpsType == "GPS_DAGR" then self.x = 123 ; self.y = 10 ; self.option = true
	elseif self.gpsType == "GPS_G48"  then self.x = 73 ; self.y = 70 ; self.option = true
	elseif self.gpsType == "GPS_H800" then self.x = -25 ; self.y = 12 ; self.option = true
	end 
	if self.option  == false then return end
	local inaccuracy_X = self:getInaccuracy()
	local inaccuracy_Y = self:getInaccuracy()
	local posX = math.floor(self.player:getX())+inaccuracy_X
	local posY = math.floor(self.player:getY())+inaccuracy_Y
	local posX = math.ceil(posX / 300)-- - 1
	local posY = math.ceil(posY / 300)-- - 1
	local txt2 = "Cell: " .. posX .. "x" .. posY
	self.labelText_Cell = ISLabel:new(self.x, self.y, 20, txt2, self.r, self.g, self.b, 1, self.UIFont, true)
	self:addChild(self.labelText_Cell)		
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:waypointGPS(num)
	local text_Dist_Dir = nil
	local worldX = self.gps:getModData()["waypointGPS"..num][1]
	local worldY = self.gps:getModData()["waypointGPS"..num][2]
	local waypointNUL = "......";
    if worldX ~= waypointNUL and worldY ~= waypointNUL then 
		-----------------------------------------
	   	local x = math.abs(self.player:getX()-worldX)
		local y = math.abs(self.player:getY()-worldY)
		local distance = ((x*x) + (y*y) )
		distance = math.floor(math.sqrt(distance))
		local kilos = false
		local kdistance = nil
		if distance > 1000 then			
			kilos = true
			kdistance = ((math.floor(distance/100)))
			kdistance = kdistance/10
		elseif distance > 100 then
			distance = ((math.floor(distance/10)) * 10)
		end
		-----------------------------------------
		local player_X = math.floor(self.player:getX())
		local player_Y = math.floor(self.player:getY())
		local text_dir = nil
		if (worldX == player_X 	  and worldY == player_Y)  								   or 
		   (worldX >  player_X-11 and worldX <  player_X+11 and worldY == player_Y)    or 
		   (worldX == player_X    and worldY >  player_Y-11 and worldY <  player_Y+11) or 
		   (worldX >  player_X-11 and worldX <  player_X+11 and worldY >  player_Y-11  and worldY <  player_Y+11) then
			text_dir = " | HERE"
		elseif (worldX == player_X or (worldX > player_X-(math.floor(distance/10)*3) and worldX < player_X+(math.floor(distance/10)*3) )) and worldY > player_Y then
			text_dir = " | S"
		elseif (worldX == player_X or (worldX > player_X-(math.floor(distance/10)*3) and worldX < player_X+(math.floor(distance/10)*3) )) and worldY < player_Y then
			text_dir = " | N"
		elseif worldX > player_X and (worldY == player_Y or (worldY > player_Y-(math.floor(distance/10)*3) and worldY < player_Y+(math.floor(distance/10)*3) )) then
			text_dir = " | E"
		elseif worldX < player_X and (worldY == player_Y or (worldY > player_Y-(math.floor(distance/10)*3) and worldY < player_Y+(math.floor(distance/10)*3) )) then
			text_dir = " | W"
		elseif worldX > player_X and worldY > player_Y then
			text_dir = " | S.E"
		elseif worldX > player_X and worldY < player_Y then
			text_dir = " | N.E"
		elseif worldX < player_X and worldY < player_Y then
			text_dir = " | N.W"
		elseif worldX < player_X and worldY > player_Y then
			text_dir = " | S.W"
		end
		if kilos then 
			--text_Dist_Dir = (("> Dist: " .. tostring(kdistance) .. " km" .. text_dir)) 
			text_Dist_Dir = (tostring(kdistance) .. " k" .. text_dir) 
		else 
			--text_Dist_Dir = ("> Dist: " .. tostring(distance) .. " m" .. text_dir)
			if distance <10 then distance = 0 end
			text_Dist_Dir = (tostring(distance) .. " m" .. text_dir)
		end
		self:setWaypoint(worldX, worldY, text_Dist_Dir, num)
	elseif num == 1 then 
		local worldX = "......";
		local worldY = "......";
		if self.gps:getModData()["waypointGPS"..num] == nil then self.gps:getModData()["waypointGPS"..num] = {} end
		if self.gps then self.gps:getModData()["waypointGPS"..num] = {worldX, worldY} end-- ; if isClient() and self.gps:getType() == "GPS_H800" then self.gps:transmitCompleteItemToServer() end end
		self:setWaypoint(worldX, worldY, nil, num)
	elseif num == 2 then
		if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) ; self.labelText_Waypoint_2 = nil end
	end
end
-------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:getInaccuracy()
	if self.gpsType == "GPS_315"  then local sandbox = SandboxVars.itemGPS.G315Inaccuracy   ; local inaccuracy = ZombRand(-sandbox,sandbox) return inaccuracy end
	if self.gpsType == "GPS_G48"  then local sandbox = SandboxVars.itemGPS.G48Inaccuracy    ; local inaccuracy = ZombRand(-sandbox,sandbox) return inaccuracy end
	if self.gpsType == "GPS_DAGR" then local sandbox = SandboxVars.itemGPS.DAGRInaccuracy   ; local inaccuracy = ZombRand(-sandbox,sandbox) return inaccuracy end
	if self.gpsType == "GPS_H800" then local sandbox = SandboxVars.itemGPS.H800Inaccuracy   ; local inaccuracy = ZombRand(-sandbox,sandbox) return inaccuracy end
	if self.gpsType == "GPSdayz"  then local sandbox = SandboxVars.itemGPS.DZ2012Inaccuracy ; local inaccuracy = ZombRand(-sandbox,sandbox) return inaccuracy end
	local inaccuracy = ZombRand(-11,11)
	return 
end
-------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:setWaypoint(worldX, worldY, textDir, num)
	self.x  = 0
	self.y  = 0
	self.x2 = 0
	self.y2 = 0
	self.x3 = 0
	self.y3 = 0
	self.txt    = nil
	self.option = false
	self.txt2   = nil
	self.UIFontLocal = self.UIFont

	if num == 1 then 
		if 	   self.gpsType == "GPSdayz"  then self.x = -7  ; self.y = 165 ; self.x2 = 146 ; self.y2 = 165 
		elseif self.gpsType == "GPS_315"  then self.x = 10  ; self.y = 167 ; self.x2 = 102 ; self.y2 = 167 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "WP: " ; self.option = true
		elseif self.gpsType == "GPS_DAGR" then self.x = 25  ; self.y = 54  ; self.x2 = 95  ; self.y2 = 70  ; self.x3 = 140 ; self.y3 = 65  ; self.txt = "| " ; self.txt2 = "" ; self.UIFontLocal = UIFont.NewSmall
		elseif self.gpsType == "GPS_G48"  then self.x = 55  ; self.y = 95  ; self.x2 = 75  ; self.y2 = 113 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "" 
		elseif self.gpsType == "GPS_H800" then self.x = -25 ; self.y = 156 ; self.x2 = 106 ; self.y2 = 156 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "Waypoint: " ; self.option = true
		end
		if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) ; self.labelText_Waypoint_1 = nil end
		if self.option == true and (worldY ~= "......" and worldX ~= "......") then 
			local worldX = math.ceil(worldX / 300)-- - 1
			local worldY = math.ceil(worldY / 300)-- - 1
			self.txt = self.txt .. worldX .. "x" .. worldY
		elseif self.txt and (worldY ~= "......" and worldX ~= "......") then
			self.txt = self.txt .. "x:"..worldX .. " | y:" .. worldY
		elseif self.txt then 
			self.txt = self.txt .. "..."
		else
			self.txt = "1.Waypoint x:" .. worldX .. " y:" .. worldY .. " |"
		end			
		--self.labelText_Waypoint_1 = ISLabel:new(self.x, self.y, 20, self.txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
		--self:addChild(self.labelText_Waypoint_1); 
		if self.txt2 and (worldY ~= "......" and worldX ~= "......") 	then
			local worldX = math.ceil(worldX / 300)-- - 1
			local worldY = math.ceil(worldY / 300)-- - 1
			self.txt2 = self.txt .." | " .. worldX .. "x" .. worldY	.. " |"		
			self.labelText_Waypoint_1 = ISLabel:new(self.x, self.y, 20, self.txt2, self.r, self.g, self.b, 1, self.UIFontLocal, true);
			self:addChild(self.labelText_Waypoint_1);
		else
			self.labelText_Waypoint_1 = ISLabel:new(self.x, self.y, 20, self.txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
			self:addChild(self.labelText_Waypoint_1); 
		end
		if textDir then
			self.labelText_Waypoint_DistDir_1 = ISLabel:new(self.x2, self.y2, 20, textDir, self.r, self.g, self.b, 1, self.UIFont, true);
			self:addChild(self.labelText_Waypoint_DistDir_1);
		end

	elseif num == 2 then 
		if 	   self.gpsType == "GPSdayz"  then self.x = -7 ; self.y = 153 ; self.x2 = 146 ; self.y2 = 153 ; 
		elseif self.gpsType == "GPS_315"  then self.x = -7 ; self.y = 153 ; self.x2 = 142 ; self.y2 = 153 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "WP: "
		elseif self.gpsType == "GPS_DAGR" then self.x = 25 ; self.y = 85  ; self.x2 = 95  ; self.y2 = 101 ; self.x3 = 140 ; self.y3 = 95  ; self.txt = "| " ; self.txt2 = "" ; self.UIFontLocal = UIFont.NewSmall
		--elseif self.gpsType == "GPS_G48"  then self.x = -7 ; self.y = 153 ; self.x2 = 142 ; self.y2 = 153 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "WP: "
		elseif self.gpsType == "GPS_H800" then self.x = -7 ; self.y = 153 ; self.x2 = 142 ; self.y2 = 153 ; self.x3 = 142 ; self.y3 = 165 ; self.txt = "Waypoint: "
		end
		if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) ; self.labelText_Waypoint_2 = nil end
		if self.option == true and (worldY ~= "......" and worldX ~= "......") then 
			local worldX = math.ceil(worldX / 300)-- - 1
			local worldY = math.ceil(worldY / 300)-- - 1
			self.txt = self.txt .. worldX .. "x" .. worldY
		elseif self.txt and (worldY ~= "......" and worldX ~= "......") then
			self.txt = self.txt .. "x:"..worldX .. " | y:" .. worldY
		elseif self.txt then 
			self.txt = self.txt .. "..."
		else
			self.txt = "2.Waypoint x:" .. worldX .. " y:" .. worldY .. " |"
		end			
		--self.labelText_Waypoint_2 = ISLabel:new(self.x, self.y, 20, self.txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
		--self:addChild(self.labelText_Waypoint_2); 
		if self.txt2 and (worldY ~= "......" and worldX ~= "......") 	then
			local worldX = math.ceil(worldX / 300)-- - 1
			local worldY = math.ceil(worldY / 300)-- - 1
			self.txt2 = self.txt .." | " .. worldX .. "x" .. worldY	.. " |"		
			self.labelText_Waypoint_2 = ISLabel:new(self.x, self.y, 20, self.txt2, self.r, self.g, self.b, 1, self.UIFontLocal, true);
			self:addChild(self.labelText_Waypoint_2);
		else
			self.labelText_Waypoint_2 = ISLabel:new(self.x, self.y, 20, self.txt, self.r, self.g, self.b, 1, self.UIFontLocal, true);
			self:addChild(self.labelText_Waypoint_2); 
		end
		if textDir then
			self.labelText_Waypoint_DistDir_2 = ISLabel:new(self.x2, self.y2, 20, textDir, self.r, self.g, self.b, 1, self.UIFont, true);
			self:addChild(self.labelText_Waypoint_DistDir_2);
		end
	end
end
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapInner.onRightMouseUp = ISMiniMapInner.onRightMouseUp
function ISMiniMapInner:onRightMouseUp(x, y)
	upperLayer.ISMiniMapInner.onRightMouseUp(self,x,y)
--	if not self.rightMouseDown then return end
--	self.rightMouseDown = false
	local playerNum = 0
	if not self.player then return end

	if not self.gps then return end 
	local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
	self.GPScontext = context
	local worldX = self.mapAPI:uiToWorldX(x, y)
	local worldY = self.mapAPI:uiToWorldY(x, y)
	if (getDebug() or isAdmin()) and getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
		local option = context:addOption("Teleport Here", self, self.onTeleport, worldX, worldY)
	end
	if self.gpsType then itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneMIDLE") end
	self.option  = false
	self.option2 = false
	self.option3 = false
	if 	   self.gpsType == "GPSdayz"  then self.option = true ; self.option2 = true	; self.option3 = true	
	elseif self.gpsType == "GPS_315"  then self.option = true	
	elseif self.gpsType == "GPS_DAGR" then self.option2 = true
	elseif self.gpsType == "GPS_G48"  then self.option2 = false	
	elseif self.gpsType == "GPS_H800" then self.option = true	
	end
	
	local keyMenu = context:addOption("1.waypoint >")
    local subMenu = ISContextMenu:getNew(context);
    context:addSubMenu(keyMenu, subMenu);
	if self.option == true then 
		
    	self.GPSsubmenu1 = subMenu
		local option = subMenu:addOption("1.Set waypoint click", self, self.Waypoint_clic, worldX, worldY, 1) 
		if not getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
			local color = " <RGB:0.9,0,0> "
			option.toolTip = ISToolTip:new()
			option.toolTip:initialise()
			option.toolTip:setVisible(true)
			option.toolTip:setName(getText("IGUI_Info"))
	    	option.toolTip.description = color .. getText("IGUI_itemGPS_invalidChunk")
			option.notAvailable = true 
		end
	end
	local option = subMenu:addOption("1.Set waypoint keypad", self, self.Waypoint_manual, 1) 
	local option = subMenu:addOption("1.Set cell keypad", self, self.WaypointCell_manual, 1) 
	if (getDebug() or isAdmin()) then 
		local option = subMenu:addOption("1.Teleport to",nil,function()
			self.gps:getModData()["waypointGPS1"] = self.gps:getModData()["waypointGPS1"] or {}
			local x = self.gps:getModData()["waypointGPS1"][1] or self.player:getX()
			local y = self.gps:getModData()["waypointGPS1"][2] or self.player:getY()
       	    self.player:setX(x)
       	    self.player:setY(y)
       	    self.player:setZ(0)
       	    self.player:setLx(x)
       	    self.player:setLy(y)
       	    self.player:setLz(0)
       	end)
	end
	local option = subMenu:addOption("1.Reset", self, self.Waypoint_reset, 1)


	if self.option2 == true then --return end
		local keyMenu = context:addOption("2.waypoint >")
    	local subMenu = ISContextMenu:getNew(context);
    	context:addSubMenu(keyMenu, subMenu);
    	self.GPSsubmenu2 = subMenu
		if self.option3 == true then 
			local option = subMenu:addOption("2.Set waypoint click", self, self.Waypoint_clic, worldX, worldY, 2) 
			if not getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
				local color = " <RGB:0.9,0,0> "
				option.toolTip = ISToolTip:new()
				option.toolTip:initialise()
				option.toolTip:setVisible(true)
				option.toolTip:setName(getText("IGUI_Info"))
	    		option.toolTip.description = color .. getText("IGUI_itemGPS_invalidChunk")
				option.notAvailable = true 
			end
		end
		local option = subMenu:addOption("2.Set waypoint keypad", self, self.Waypoint_manual, 2)
		local option = subMenu:addOption("2.Set cell keypad", self, self.WaypointCell_manual, 2)
		if (getDebug() or isAdmin()) then 
			local option = subMenu:addOption("2.Teleport to",nil,function()
				self.gps:getModData()["waypointGPS2"] = self.gps:getModData()["waypointGPS2"] or {}
				local x = self.gps:getModData()["waypointGPS2"][1] or self.player:getX()
				local y = self.gps:getModData()["waypointGPS2"][2] or self.player:getY()
        	    self.player:setX(x)
        	    self.player:setY(y)
        	    self.player:setZ(0)
        	    self.player:setLx(x)
        	    self.player:setLy(y)
        	    self.player:setLz(0)
        	end)
		end
		local option = subMenu:addOption("2.Reset", self, self.Waypoint_reset, 2)
	end



	if self.gps:hasTag("GPSmod") then
		local vehicleInside = self.player:getVehicle()
		if vehicleInside and vehicleInside:getSeat(self.player) < 2  then
			local cable = self.player:getInventory():getItemFromType("GPScable") 
			if vehicleInside and (self.gps ~= itemGPSmod.PlugedGps or not itemGPSmod.PlugedGps) then
				local option = context:addOption(getText("IGUI_Plug"), self.player, itemGPSmod.GPS_plug, self.gps, vehicleInside);
				if self.gps:getUsedDelta() == 0 then 
					local color = " <RGB:0.9,0,0> "
					option.toolTip = ISToolTip:new()
			    	option.toolTip:initialise()
			    	option.toolTip:setVisible(true)
			    	option.toolTip:setName(getText("IGUI_Info"))
		            option.toolTip.description = color .. getText("IGUI_noPlugIfnoBat")
					option.notAvailable = true 
				elseif not cable then
					local color = " <RGB:0.9,0,0> "
					option.toolTip = ISToolTip:new()
			    	option.toolTip:initialise()
			    	option.toolTip:setVisible(true)
			    	option.toolTip:setName(getText("IGUI_Info"))
		            option.toolTip.description = color .. getText("IGUI_noPlugIfnoCable")
					option.notAvailable = true 
				else
					option.toolTip = ISToolTip:new()
		    		option.toolTip:initialise()
		    		option.toolTip:setVisible(true)
		    		option.toolTip:setName(getText("IGUI_Info"))
	        		option.toolTip.description = getText("IGUI_autoUnplugInfo")
				end
			elseif vehicleInside and self.gps == itemGPSmod.PlugedGps then
				option = context:addOption(getText("IGUI_unPlug"), self.player, itemGPSmod.GPS_UnPlug, self.gps, vehicleInside);
				option.toolTip = ISToolTip:new()
			    option.toolTip:initialise()
			    option.toolTip:setVisible(true)
			    option.toolTip:setName(getText("IGUI_Info"))
		        option.toolTip.description = getText("IGUI_autoUnplugInfo")
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:Waypoint_clic(worldX, worldY, num)
	if not self.player or not self.gps then return end
	local inaccuracy_X = self:getInaccuracy()-- ZombRand(-(11-5),(11-5))
	local inaccuracy_Y = self:getInaccuracy()-- ZombRand(-(11-5),(11-5))
	local worldX = math.ceil(worldX) + (inaccuracy_X-5) -- -1
	local worldY = math.ceil(worldY) + (inaccuracy_Y-5) -- -1

	if self.gps:getModData()["waypointGPS"..num] == nil then self.gps:getModData()["waypointGPS"..num] = {} end
	if self.gps then self.gps:getModData()["waypointGPS"..num] = {worldX, worldY} end-- ; if isClient() and self.gps:getType() == "GPS_H800" then self.gps:transmitCompleteItemToServer() end end

	self:setWaypoint(worldX, worldY, nil, num)
	if self.gpsType then itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneUP") end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:Waypoint_manual(num)
	if not self.player or not self.gps then return end
	local modal = GPS_Waypoint_window:new(self.player, self.gps, num, "Set X Coordinate");
    modal:initialise();
    modal:addToUIManager();
	if self.gpsType then itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneUP") end
end
function ISMiniMapInner:WaypointCell_manual(num)
	if not self.player or not self.gps then return end
	local modal = GPS_WaypointCell_window:new(self.player, self.gps, num, "Set Cell X Coordinate");
    modal:initialise();
    modal:addToUIManager();
	if self.gpsType then itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneUP") end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:Waypoint_reset(num)
	if not self.player or not self.gps then return end
	local worldX = "......";
	local worldY = "......";
	
	if self.gps:getModData()["waypointGPS"..num] == nil then self.gps:getModData()["waypointGPS"..num] = {} end
	if self.gps then self.gps:getModData()["waypointGPS"..num] = {worldX, worldY} end-- ; if isClient() and self.gps:getType() == "GPS_H800" then self.gps:transmitCompleteItemToServer() end end

	self:setWaypoint(worldX, worldY, nil, num)
	if self.gpsType then itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneDOWN") end
end
-----------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapTitleBar.prerender = ISMiniMapTitleBar.prerender
function ISMiniMapTitleBar:prerender()
	upperLayer.ISMiniMapTitleBar.prerender(self)
	local th = self:titleBarHeight()
	if itemGPSmod.gps and itemGPSmod.gps:getType() then
		local GPS_DayZ_barre = getTexture("media/ui/"..itemGPSmod.gps:getType().."_barre.png")
		self:drawTextureScaled(GPS_DayZ_barre, 1, 1, self:getWidth() - 2, th - 2, 1, 1, 1, 1)
	end
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------