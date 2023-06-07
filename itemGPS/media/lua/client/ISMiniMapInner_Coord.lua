require "ISUI/Maps/ISMiniMap"
require "ISUI/ISUIElement"
local upperLayer = {}
upperLayer.ISMiniMapInner = {}
-------------------------------------------------------------------------------------------------------------
--CREATE SECTION
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:update()

    if GPS_present_on == nil and not self.imageGPSoff and not isAdmin()then 
		self.GPS_DayZ_cache = getTexture("media/ui/GPS_DayZ_cache.png") 
		self.imageGPSoff = ISImage:new(-19, -5, 1, 1, self.GPS_DayZ_cache);
		self:addChild(self.imageGPSoff) 

	elseif (GPS_present_on == true and self.imageGPSoff) or (self.imageGPSoff and isAdmin())then
		self:removeChild(self.imageGPSoff)
		self.imageGPSoff = nil
	end
	if GPS_present_on_delay ~= true then
		GPS_present_on_delay = true
		self.counter = 0 
		if self.labelText_XY then self:removeChild(self.labelText_XY) end
	    if self.labelText_Cell then self:removeChild(self.labelText_Cell) end
	    if self.labelText_Alt then self:removeChild(self.labelText_Alt) end
		if self.labelText_Dir then self:removeChild(self.labelText_Dir) end
		if self.labelText_Bat then self:removeChild(self.labelText_Bat) end
		if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) end
		if self.labelText_Waypoint_DistDir_1 then self:removeChild(self.labelText_Waypoint_DistDir_1) end
		if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) end
		if self.labelText_Waypoint_DistDir_2 then self:removeChild(self.labelText_Waypoint_DistDir_2) end
		if self.labelText_chargeUP1 then self:removeChild(self.labelText_chargeUP1) end
		if self.labelText_chargeUP2 then self:removeChild(self.labelText_chargeUP2) end
		if self.itemGPS_Pluged_texture then self:removeChild(self.itemGPS_Pluged_texture) end
		--if self.labelText_chargeUP3 then self:removeChild(self.labelText_chargeUP3) end

	end
	--------------------------			
	if not GPS_present_on or not GPS_present_on_delay then return end
	--------------------------			
	local player = getSpecificPlayer(0);
    if not player then GPS_present_on_delay = false return end
	--------------------------	
	local gps = player:getInventory():getItemFromType("GPSdayz")
	if not gps then GPS_present_on_delay = false return end	
	--------------------------	
	local vehicleInside = player:getVehicle()
	local toolP = player:getPrimaryHandItem()
	local toolS = player:getSecondaryHandItem()
	local toolsB = player:getAttachedItems()
	local gpsTEST = nil
	if toolP and (toolP:getType() == "GPSdayz" and toolP:isActivated()) then 
		gpsTEST = player:getPrimaryHandItem() 
	elseif toolS and (toolS:getType() == "GPSdayz" and toolS:isActivated()) then 
		gpsTEST = player:getSecondaryHandItem() 
	elseif toolsB then 
		for i=1,toolsB:size() do
			local item = toolsB:getItemByIndex(i-1)
			if item:getType() == "GPSdayz" and item:isActivated() then
				gpsTEST = toolsB:getItemByIndex(i-1) 
				break
			end
		end
		--if not self.gps then self.gps = player:getInventory():getItemFromType("GPSdayz") end	 
	else 
		--self.gps = player:getInventory():getItemFromType("GPSdayz") 
		GPS_present_on_delay = false
		return
	end	
	if not gpsTEST then GPS_present_on_delay = false return end 
	if self.gps == nil or gpsTEST ~= self.gps then self.gps = gpsTEST ; GPS_present_on_delay = false return end

	if self.itemGPS_Pluged_texture then self:removeChild(self.itemGPS_Pluged_texture) end
	if vehicleInside and itemGPS_Pluged and itemGPS_Pluged == self.gps then
		local texture = getTexture("media/ui/GPSdayz_Cable.png")
		self.itemGPS_Pluged_texture = ISImage:new(8, 255, 0.5, 0.5, texture);
		self:addChild(self.itemGPS_Pluged_texture)
	end
    --------------------------			
    if self.counter == nil then self.counter = 0 end	
    --------------------------			
    self.counter = self.counter +1
	--------------------------		    	
	if self.counter == 1 then 	
		--------------------------
		local posZ = player:getZ()
		local txt0 = "Alt: ".. posZ;
	   	--self.labelText_Alt = ISLabel:new(-7, 19, 20, txt0, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
	   	self.labelText_Alt = ISLabel:new(-7, 40, 20, txt0, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
	    self:addChild(self.labelText_Alt); 
		--------------------------
	    local posX = math.floor(player:getX());
	    local posY = math.floor(player:getY());
	    local txt1 = "x:" .. (posX+ZombRand(-11,11)) .. " y:" .. (posY+ZombRand(-11,11));	
	    posX = math.ceil(posX / 300) - 1;
	    posY = math.ceil(posY / 300) - 1;
	    local txt2 = "Cell: " .. posX .. "x" .. posY;
	    --self.labelText_XY = ISLabel:new(-7, 165, 20, txt1, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
	    self.labelText_XY = ISLabel:new(-7, 4, 20, txt1, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
	    self:addChild(self.labelText_XY); 
	    --self.labelText_Cell = ISLabel:new(-7, 153, 20, txt2, 0.5, 0.8, 0.3, 1, UIFont.Small, true);
	    self.labelText_Cell = ISLabel:new(-7, 16, 20, txt2, 0.5, 0.8, 0.3, 1, UIFont.Small, true);
	    self:addChild(self.labelText_Cell); 		
		--------------------------			
		local charge = self.gps:getUsedDelta()*100
		local txt = "Bat: "..string.format("%.0f",charge) .. "%"--charge .. "%"
		--self.labelText_Bat = ISLabel:new(150, 165, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
		self.labelText_Bat = ISLabel:new(149, 7, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	    self:addChild(self.labelText_Bat); 

	    if self.gps:getModData()["waypointGPS1"] then 
	    	local text_Dist_Dir = nil
	    	local waypoint_X = self.gps:getModData()["waypointGPS1"][1]
	    	local waypoint_Y = self.gps:getModData()["waypointGPS1"][2]
			local waypointNUL = "......";
    		if waypoint_X ~= waypointNUL and waypoint_Y ~= waypointNUL then 
				-----------------------------------------
	    		local x = math.abs(player:getX()-waypoint_X)
				local y = math.abs(player:getY()-waypoint_Y)
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
				local player_X = math.floor(player:getX())
				local player_Y = math.floor(player:getY())
				local text_dir = nil
				--if waypoint_X == player_X and waypoint_Y == player_Y then
				if (waypoint_X == player_X 	 and waypoint_Y == player_Y)  								or 
				   (waypoint_X >  player_X-11 and waypoint_X <  player_X+11 and waypoint_Y == player_Y) 	or 
				   (waypoint_X == player_X   and waypoint_Y >  player_Y-11 and waypoint_Y <  player_Y+11) or 
				   (waypoint_X >  player_X-11 and waypoint_X <  player_X+11 and waypoint_Y >  player_Y-11 and waypoint_Y <  player_Y+11) then
					
					text_dir = " | HERE"

				elseif (waypoint_X == player_X or (waypoint_X >  player_X-(math.floor(distance/10)*3) and waypoint_X <  player_X+(math.floor(distance/10)*3) )) and 
						waypoint_Y > player_Y then

					text_dir = " | S"

				elseif (waypoint_X == player_X or (waypoint_X >  player_X-(math.floor(distance/10)*3) and waypoint_X <  player_X+(math.floor(distance/10)*3) ))and 
					waypoint_Y < player_Y then

					text_dir = " | N"

				elseif waypoint_X > player_X and 
					(waypoint_Y == player_Y or(waypoint_Y >  player_Y-(math.floor(distance/10)*3) and waypoint_Y <  player_Y+(math.floor(distance/10)*3) )) then

					text_dir = " | E"

				elseif waypoint_X < player_X and 
					(waypoint_Y == player_Y or(waypoint_Y >  player_Y-(math.floor(distance/10)*3) and waypoint_Y <  player_Y+(math.floor(distance/10)*3) )) then

					text_dir = " | W"

				elseif waypoint_X > player_X and 
					waypoint_Y > player_Y then

					text_dir = " | S.E"

				elseif waypoint_X > player_X and 
					waypoint_Y < player_Y then

					text_dir = " | N.E"

				elseif waypoint_X < player_X and 
					waypoint_Y < player_Y then

					text_dir = " | N.W"

				elseif waypoint_X < player_X and 
					waypoint_Y > player_Y then

					text_dir = " | S.W"

				end
				
				if kilos then 
					--text_Dist_Dir = (("> Dist: " .. tostring(kdistance) .. " km" .. text_dir)) 
					text_Dist_Dir = ("| "..tostring(kdistance) .. " k" .. text_dir) 
				else 
					--text_Dist_Dir = ("> Dist: " .. tostring(distance) .. " m" .. text_dir)
					if distance <10 then distance = 0 end
					text_Dist_Dir = ("| "..tostring(distance) .. " m" .. text_dir)
				end
			end

			if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) end
			local txt = "1.Waypoint x:" .. waypoint_X .. " y:" .. waypoint_Y;	-- "Bat: ".. worldX .. worldY --string.format("%.0f",charge) .. "%"--charge .. "%"			
			--self.labelText_Waypoint_1 = ISLabel:new(65, 8, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true); 
			self.labelText_Waypoint_1 = ISLabel:new(-7, 165, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
			self:addChild(self.labelText_Waypoint_1); 
			
			--if not text_Dist_Dir then text_Dist_Dir = "> Dist: .... Dir: ..." end
			if text_Dist_Dir then
				--self.labelText_Waypoint_DistDir_1 = ISLabel:new(68, 19, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				--self.labelText_Waypoint_DistDir_1 = ISLabel:new(-5, 153, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self.labelText_Waypoint_DistDir_1 = ISLabel:new(142, 165, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self:addChild(self.labelText_Waypoint_DistDir_1);
			end
		else
			local worldX = "......";
			local worldY = "......";
		
			if self.gps:getModData()["waypointGPS1"] == nil then self.gps:getModData()["waypointGPS1"] = {} end
			if self.gps then self.gps:getModData()["waypointGPS1"] = {worldX, worldY}end
		
			local txt = "1.Waypoint x:" .. worldX .. " y:" .. worldY;
			if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) end
			self.labelText_Waypoint_1 = ISLabel:new(-7, 165, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
			self:addChild(self.labelText_Waypoint_1); 
		end
		----------------------------------------------------------------
		----------------------------------------------------------------
		if self.gps:getModData()["waypointGPS2"] then 
	    	local text_Dist_Dir = nil
	    	local waypoint_X = self.gps:getModData()["waypointGPS2"][1]
	    	local waypoint_Y = self.gps:getModData()["waypointGPS2"][2]
			local waypointNUL = "......";
    		if waypoint_X ~= waypointNUL and waypoint_Y ~= waypointNUL then 
				-----------------------------------------
	    		local x = math.abs(player:getX()-waypoint_X)
				local y = math.abs(player:getY()-waypoint_Y)
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
				local player_X = math.floor(player:getX())
				local player_Y = math.floor(player:getY())
				local text_dir = nil
				--if waypoint_X == player_X and waypoint_Y == player_Y then
				--	text_dir = " | HERE"
				--elseif waypoint_X == player_X and waypoint_Y > player_Y then
				--	text_dir = " | S"
				--elseif waypoint_X == player_X and waypoint_Y < player_Y then
				--	text_dir = " | N"
				--elseif waypoint_X > player_X and waypoint_Y == player_Y then
				--	text_dir = " | E"
				--elseif waypoint_X < player_X and waypoint_Y == player_Y then
				--	text_dir = " | W"
				--elseif waypoint_X > player_X and waypoint_Y > player_Y then
				--	text_dir = " | S.E"
				--elseif waypoint_X > player_X and waypoint_Y < player_Y then
				--	text_dir = " | N.E"
				--elseif waypoint_X < player_X and waypoint_Y < player_Y then
				--	text_dir = " | N.W"
				--elseif waypoint_X < player_X and waypoint_Y > player_Y then
				--	text_dir = " | S.W"
				--end
				if (waypoint_X == player_X 	 and waypoint_Y == player_Y)  								or 
				   (waypoint_X >  player_X-11 and waypoint_X <  player_X+11 and waypoint_Y == player_Y) 	or 
				   (waypoint_X == player_X   and waypoint_Y >  player_Y-11 and waypoint_Y <  player_Y+11) or 
				   (waypoint_X >  player_X-11 and waypoint_X <  player_X+11 and waypoint_Y >  player_Y-11 and waypoint_Y <  player_Y+11) then
					
					text_dir = " | HERE"

				elseif (waypoint_X == player_X or (waypoint_X >  player_X-(math.floor(distance/10)*3) and waypoint_X <  player_X+(math.floor(distance/10)*3) )) and 
						waypoint_Y > player_Y then

					text_dir = " | S"

				elseif (waypoint_X == player_X or (waypoint_X >  player_X-(math.floor(distance/10)*3) and waypoint_X <  player_X+(math.floor(distance/10)*3) ))and 
					waypoint_Y < player_Y then

					text_dir = " | N"

				elseif waypoint_X > player_X and 
					(waypoint_Y == player_Y or(waypoint_Y >  player_Y-(math.floor(distance/10)*3) and waypoint_Y <  player_Y+(math.floor(distance/10)*3) )) then

					text_dir = " | E"

				elseif waypoint_X < player_X and 
					(waypoint_Y == player_Y or(waypoint_Y >  player_Y-(math.floor(distance/10)*3) and waypoint_Y <  player_Y+(math.floor(distance/10)*3) )) then

					text_dir = " | W"

				elseif waypoint_X > player_X and 
					waypoint_Y > player_Y then

					text_dir = " | S.E"

				elseif waypoint_X > player_X and 
					waypoint_Y < player_Y then

					text_dir = " | N.E"

				elseif waypoint_X < player_X and 
					waypoint_Y < player_Y then

					text_dir = " | N.W"

				elseif waypoint_X < player_X and 
					waypoint_Y > player_Y then

					text_dir = " | S.W"

				end
				if kilos then 
					text_Dist_Dir = (("| ".. tostring(kdistance) .. " k" .. text_dir)) 
				else 
					if distance <10 then distance = 0 end
					text_Dist_Dir = ("| ".. tostring(distance) .. " m" .. text_dir)
				end
				-------------------------------------
				if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) end
				local txt = "2.Waypoint x:" .. waypoint_X .. " y:" .. waypoint_Y;	-- "Bat: ".. worldX .. worldY --string.format("%.0f",charge) .. "%"--charge .. "%"			
				--self.labelText_Waypoint_2 = ISLabel:new(65, 30, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				--self.labelText_Waypoint_2 = ISLabel:new(-7, 143, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self.labelText_Waypoint_2 = ISLabel:new(-7, 153, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self:addChild(self.labelText_Waypoint_2); 
				-------------------------------------
				--if not text_Dist_Dir then text_Dist_Dir = "> Dist: .... Dir: ..." end
				if text_Dist_Dir then
					--self.labelText_Waypoint_DistDir_2 = ISLabel:new(68, 41, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
					--self.labelText_Waypoint_DistDir_2 = ISLabel:new(-5, 132, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
					self.labelText_Waypoint_DistDir_2 = ISLabel:new(142, 153, 20, text_Dist_Dir, 0.5, 0.8, 0.3, 1, UIFont.small, true);
					self:addChild(self.labelText_Waypoint_DistDir_2);
				end
			else
				if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) end
			end
		end
	elseif self.counter == 39 or self.counter == 19 then
			if self.labelText_Dir then self:removeChild(self.labelText_Dir) end
			--if self.labelText_chargeUP then self:removeChild(self.labelText_chargeUP) end
	elseif self.counter == 40 or self.counter == 20 or self.counter == 2 then	
		local dir = player:getDir()
		--local vehicleInside = player:getVehicle()
		local IsoDirection_player = nil
		if dir == IsoDirections.N then
			IsoDirection_player = "Dir: N" 
		elseif dir == IsoDirections.NE then
			IsoDirection_player = "Dir: N.E" 
		elseif dir == IsoDirections.E then
			IsoDirection_player = "Dir: E" 
		elseif dir == IsoDirections.SE then
			IsoDirection_player = "Dir: S.E" 
		elseif dir == IsoDirections.S then
			IsoDirection_player = "Dir: S" 
		elseif dir == IsoDirections.SW then
			IsoDirection_player = "Dir: S.W" 
		elseif dir == IsoDirections.W then
			IsoDirection_player = "Dir: W" 
		elseif dir == IsoDirections.NW then
			IsoDirection_player = "Dir: N.W" 
		end
		if IsoDirection_player then 
			--self.labelText_Dir = ISLabel:new(-7, 8, 20, IsoDirection_player, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
			self.labelText_Dir = ISLabel:new(-7, 28, 20, IsoDirection_player, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
	    	self:addChild(self.labelText_Dir);
		end
		if vehicleInside and vehicleInside:getBatteryCharge() > 0 and (vehicleInside:isKeysInIgnition() or vehicleInside:isHotwired()) then
			if self.counter == 2 and itemGPS_Pluged and self.gps == itemGPS_Pluged then 
				local text = "^"
				self.labelText_chargeUP1 = ISLabel:new(200, 12, 20, text, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self:addChild(self.labelText_chargeUP1);
			elseif self.counter == 20 and itemGPS_Pluged and self.gps == itemGPS_Pluged then
				local text = "^"
				self.labelText_chargeUP2 = ISLabel:new(200, 7, 20, text, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				self:addChild(self.labelText_chargeUP2);
			elseif self.counter == 40 and itemGPS_Pluged and self.gps == itemGPS_Pluged then
				--local text = "^"
				--self.labelText_chargeUP3 = ISLabel:new(205, 161, 20, text, 0.5, 0.8, 0.3, 1, UIFont.small, true);
				--self:addChild(self.labelText_chargeUP3);
				if self.labelText_chargeUP1 then self:removeChild(self.labelText_chargeUP1) end
	    		if self.labelText_chargeUP2 then self:removeChild(self.labelText_chargeUP2) end
			end
		end
	elseif self.counter == 60 then 
				--GPS_charge_plug = false
		GPS_present_on_delay = false
		if self.labelText_Waypoint_DistDir_2 then self:removeChild(self.labelText_Waypoint_DistDir_2) end
		if self.labelText_Waypoint_DistDir_1 then self:removeChild(self.labelText_Waypoint_DistDir_1) end
		if self.labelText_XY then self:removeChild(self.labelText_XY) end
	    if self.labelText_Cell then self:removeChild(self.labelText_Cell) end
	    if self.labelText_Alt then self:removeChild(self.labelText_Alt) end
	    if self.labelText_Bat then self:removeChild(self.labelText_Bat) end		
	    if self.labelText_Dir then self:removeChild(self.labelText_Dir) end
	    --if self.labelText_chargeUP1 then self:removeChild(self.labelText_chargeUP1) end
	    --if self.labelText_chargeUP2 then self:removeChild(self.labelText_chargeUP2) end
	    --if self.labelText_chargeUP3 then self:removeChild(self.labelText_chargeUP3) end
	    --self.counter = 0
	end
end
---------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapInner.onRightMouseUp = ISMiniMapInner.onRightMouseUp
function ISMiniMapInner:onRightMouseUp(x, y)
	upperLayer.ISMiniMapInner.onRightMouseUp(self,x,y)
--	if not self.rightMouseDown then return end
--	self.rightMouseDown = false
	local playerNum = 0
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	local gps = playerObj:getInventory():getItemFromType("GPSdayz")
	if not gps or not gps:isActivated() then return end
	local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
	--local context2 = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
	local worldX = self.mapAPI:uiToWorldX(x, y)
	local worldY = self.mapAPI:uiToWorldY(x, y)
	if getDebug() and getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
		option = context:addOption("Teleport Here", self, self.onTeleport, worldX, worldY)
	end
	if getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
		getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
		option = context:addOption("1.Set waypoint click", self, self.Waypoint_1, worldX, worldY)
		option = context:addOption("1.Set waypoint keypad", self, self.Waypoint_manual_1)
		option = context:addOption("1.Reset waypoint", self, self.RESET_Waypoint_1)
		option = context:addOption("2.Set waypoint click", self, self.Waypoint_2, worldX, worldY)
		option = context:addOption("2.Set waypoint keypad", self, self.Waypoint_manual_2)
		option = context:addOption("2.Reset waypoint", self, self.RESET_Waypoint_2)
	end
--	if context.numOptions == 1 then
--		context:setVisible(false)
--	end
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:Waypoint_1(worldX, worldY)
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	local worldX = math.ceil(worldX) - 1;
	local worldY = math.ceil(worldY) - 1;

	local worldXimprecision = (worldX+ZombRand(-6,6))
	local worldYimprecision = (worldY+ZombRand(-6,6))

	if self.gps:getModData()["waypointGPS1"] == nil then self.gps:getModData()["waypointGPS1"] = {} end

	if self.gps then self.gps:getModData()["waypointGPS1"] = {worldXimprecision, worldYimprecision}end

	local txt = "1.Waypoint x:" .. worldXimprecision .. " y:" .. worldYimprecision;
	if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) end
	--self.labelText_Waypoint_1 = ISLabel:new(65, 8, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true); 
	self.labelText_Waypoint_1 = ISLabel:new(-7, 165, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self:addChild(self.labelText_Waypoint_1); 

	getSoundManager():PlayWorldSound("GPS_Beep_2on", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
function ISMiniMapInner:Waypoint_manual_1()
	local player = getPlayer()
	if not player then return end
	getSoundManager():PlayWorldSound("GPS_Beep_2on", player:getCurrentSquare(), 1, 25, 2, true)
	local modal = GPS_Waypoint_window:new(player, self.gps, 1, "Set X Coordinate");
    modal:initialise();
    modal:addToUIManager();
end
function ISMiniMapInner:RESET_Waypoint_1()
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	local worldX = "......";
	local worldY = "......";
	local player = getPlayer()
	
	if self.gps:getModData()["waypointGPS1"] == nil then self.gps:getModData()["waypointGPS1"] = {} end
	if self.gps then self.gps:getModData()["waypointGPS1"] = {worldX, worldY}end

	local txt = "1.Waypoint x:" .. worldX .. " y:" .. worldY;
	if self.labelText_Waypoint_1 then self:removeChild(self.labelText_Waypoint_1) end
	--self.labelText_Waypoint_1 = ISLabel:new(65, 8, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self.labelText_Waypoint_1 = ISLabel:new(-7, 165, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self:addChild(self.labelText_Waypoint_1); 

	getSoundManager():PlayWorldSound("GPS_Beep_2off", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
-----------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

function ISMiniMapInner:Waypoint_2(worldX, worldY)
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	local worldX = math.ceil(worldX) - 1;
	local worldY = math.ceil(worldY) - 1;

	local worldXimprecision = (worldX+ZombRand(-6,6))
	local worldYimprecision = (worldY+ZombRand(-6,6))

	if self.gps:getModData()["waypointGPS2"] == nil then self.gps:getModData()["waypointGPS2"] = {} end

	if self.gps then self.gps:getModData()["waypointGPS2"] = {worldXimprecision, worldYimprecision} end

	local txt = "1.Waypoint x:" .. worldXimprecision .. " y:" .. worldYimprecision;
	if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) end
	--self.labelText_Waypoint_2 = ISLabel:new(65, 30, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self.labelText_Waypoint_2 = ISLabel:new(-7, 153, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self:addChild(self.labelText_Waypoint_2); 

	getSoundManager():PlayWorldSound("GPS_Beep_2on", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
function ISMiniMapInner:Waypoint_manual_2()
	local player = getPlayer()
	if not player then return end
	getSoundManager():PlayWorldSound("GPS_Beep_2on", player:getCurrentSquare(), 1, 25, 2, true)
	local modal = GPS_Waypoint_window:new(player, self.gps, 2, "Set X Coordinate");
    modal:initialise();
    modal:addToUIManager();
end
function ISMiniMapInner:RESET_Waypoint_2()
	local playerObj = getSpecificPlayer(0)
	if not playerObj then return end
	local worldX = "......";
	local worldY = "......";

	if self.gps:getModData()["waypointGPS2"] == nil then self.gps:getModData()["waypointGPS2"] = {} end
	if self.gps then self.gps:getModData()["waypointGPS2"] = {worldX, worldY}end

	local txt = "2.Waypoint x:" .. worldX .. " y:" .. worldY;
	if self.labelText_Waypoint_2 then self:removeChild(self.labelText_Waypoint_2) end
	--self.labelText_Waypoint_2 = ISLabel:new(65, 30, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self.labelText_Waypoint_2 = ISLabel:new(-7, 153, 20, txt, 0.5, 0.8, 0.3, 1, UIFont.small, true);
	self:addChild(self.labelText_Waypoint_2); 

	getSoundManager():PlayWorldSound("GPS_Beep_2off", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
-----------------------------------------------------------------------------------------------------------------