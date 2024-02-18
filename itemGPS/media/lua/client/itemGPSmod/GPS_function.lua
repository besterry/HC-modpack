---@diagnostic disable-next-line: lowercase-global
itemGPSmod = itemGPSmod or {}
-----------------------------------
itemGPSmod.funcCounter = 0
itemGPSmod.restartCounter = nil
itemGPSmod.fromHotbar = false
itemGPSmod.scriptCounter = 0
itemGPSmod.gps = nil
-----------------------------------
itemGPSmod.PlugedGps = nil
itemGPSmod.gpsChargeCounter = 0
itemGPSmod.chargeOn = false
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.playSoundGPS(player, name)
	if not player or not name then return end
	local square = player:getCurrentSquare()
	local vehicleInside = player:getVehicle()
	local GPSsound_prefix = "out_"
	local GPSsound_Dist = 25
	if vehicleInside then GPSsound_prefix = "in_" ; GPSsound_Dist = GPSsound_Dist /2 end
	if square then getSoundManager():PlayWorldSound(GPSsound_prefix..name, square, 1, GPSsound_Dist, 2, true) end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.ToggleMiniMap (player, toStart, gps)
	local playerNum = player:getPlayerNum()
	local mm = getPlayerMiniMap(playerNum)
	if not mm then return end
	local startVisible = false
	if mm:isReallyVisible() and not toStart then
		
		ISMiniMapInner:removeAllChildGPS() 
		itemGPSmod.gps = nil
		if mm.joyfocus then
			mm:clearJoypadFocus(mm.joyfocus)
			setJoypadFocus(playerNum, nil)
		end
		mm:removeFromUIManager()
	elseif not mm:isReallyVisible() and toStart then

		itemGPSmod.gps = gps
		itemGPSmod.LastGps = gps
		mm:addToUIManager()
		startVisible = true
	else
		return
	end
	if playerNum == 0 then
---@diagnostic disable-next-line: undefined-global
		local settings = WorldMapSettings.getInstance()
		settings:setBoolean("MiniMap.StartVisible", startVisible)
		itemGPSmod.restartCounter = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.GPS_charge()
	local GPSdelta = (0.001*SandboxVars.itemGPS.ChargeBatteryMultiplier)*(SandboxVars.itemGPS.UseBatteryMultiplier/2)
	if not itemGPSmod.PlugedGps then itemGPSmod.gpsChargeCounter = 0 return end
	local player = getSpecificPlayer(0)
	if not player then return end
	local vehicleInside = player:getVehicle()
	local gpsINV = player:getInventory():contains(itemGPSmod.PlugedGps)
	local cable = player:getInventory():getItemFromType("GPScable")

	if not vehicleInside or vehicleInside:getSeat(player) > 1 or not cable or not gpsINV then 
		Events.OnPlayerUpdate.Remove(itemGPSmod.GPS_charge) ; 
		itemGPSmod.restartCounter = false ;  
		getSoundManager():PlayWorldSound("GPS_UNPLUG", square, 1, 20, 2, true)

		if itemGPSmod.chargeOn == true then itemGPSmod.chargeOn = false ; itemGPSmod.playSoundGPS(player, itemGPSmod.PlugedGps:getType().."_Beep_chargeUNPLUG") end 
		itemGPSmod.PlugedGps = nil ;
		return
	end
	if vehicleInside and (((not vehicleInside:isKeysInIgnition() and not vehicleInside:isHotwired())) or vehicleInside:getBatteryCharge() == 0) then 
		if itemGPSmod.chargeOn == true then itemGPSmod.playSoundGPS(player, itemGPSmod.PlugedGps:getType().."_Beep_chargeUNPLUG") end
		itemGPSmod.chargeOn = false ; 
		return 
	end
	if vehicleInside and vehicleInside:getBatteryCharge() > 0 and itemGPSmod.chargeOn == false then  itemGPSmod.chargeOn = true ; itemGPSmod.playSoundGPS(player, itemGPSmod.PlugedGps:getType().."_Beep_chargePLUG") end

	itemGPSmod.gpsChargeCounter = itemGPSmod.gpsChargeCounter +1
	if itemGPSmod.gpsChargeCounter == 1249 and itemGPSmod.PlugedGps then	
		if vehicleInside:getBatteryCharge() > 0 and itemGPSmod.PlugedGps:getUsedDelta() < 1 then 
			local delta = -(GPSdelta/10)
			if isClient() then
				sendClientCommand(player, 'GPScommands', 'GPSchargeBattery',{vehicleInside:getId(),delta}) ; 
			else
				VehicleUtils.chargeBattery(vehicleInside, delta);
			end 
			itemGPSmod.PlugedGps:setUsedDelta(itemGPSmod.PlugedGps:getUsedDelta()+GPSdelta)
		end 
		if itemGPSmod.PlugedGps:getUsedDelta() == 1 then  
			itemGPSmod.playSoundGPS(player, itemGPSmod.PlugedGps:getType().."_Beep_chargeOK")
			itemGPSmod.PlugedGps = nil ;
			Events.OnPlayerUpdate.Remove(itemGPSmod.GPS_charge)
		end  
	elseif itemGPSmod.gpsChargeCounter >= 1250 then
		
		itemGPSmod.gpsChargeCounter = 0
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.confirmGPS(player,gps)
	if not gps then return false end
	if gps:hasTag("GPSmod") then 
		local gpsEquiped = gps:isEquipped()
		local hotbar = getPlayerHotbar(player:getPlayerNum())
		local keyK = isKeyDown(itemGPSmod.keyData.key)
		fromHotbar = false
		if hotbar then fromHotbar = hotbar:isItemAttached(gps) end
		if gps:getUsedDelta() > 0.005 and (gpsEquiped or (fromHotbar and (keyK or SandboxVars.itemGPS.KeyKShunter))) then return true 
		elseif gps:getUsedDelta() > 0 and gps:getUsedDelta() <= 0.12 then itemGPSmod.playSoundGPS(player, gps:getType().."_Beep_chargeLOW")
		end
	else
		local vehicleInside = player:getVehicle()
		if vehicleInside and vehicleInside:getBatteryCharge() > 0 and (vehicleInside:isKeysInIgnition() or vehicleInside:isHotwired()) and vehicleInside:getSeat(player) < 2 then
			local testPart = vehicleInside:getPartById("GloveBox");
			if testPart and testPart:getItemContainer():contains(gps) and testPart:getItemContainer():containsType("GPScable") then return true end
		end
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.findGPS(player)
	local toolP = player:getPrimaryHandItem()
	local toolS = player:getSecondaryHandItem()
	local toolsB = player:getAttachedItems()
	local keyK = isKeyDown(itemGPSmod.keyData.key)
	local gps = nil
	local vehicleInside = player:getVehicle()
	if toolP and (toolP:hasTag("GPSmod") and toolP:getUsedDelta() > 0.005) then
		local gps = player:getPrimaryHandItem() 
		return gps
	elseif toolS and (toolS:hasTag("GPSmod") and toolS:getUsedDelta() > 0.005) then
		local gps = player:getSecondaryHandItem()
		return gps 
	elseif toolsB then 
		for i=0,toolsB:size()-1 do
			local item = toolsB:getItemByIndex(i)
			if item:hasTag("GPSmod") and item:getUsedDelta() > 0.005 and keyK then
				local gps = item 
				return gps
			end
		end
	end
	if vehicleInside and vehicleInside:getBatteryCharge() > 0 and vehicleInside:getSeat(player) < 2 and (vehicleInside:isKeysInIgnition() or vehicleInside:isHotwired()) then
		local testPart = vehicleInside:getPartById("GloveBox");
	
		if testPart:getItemContainer():containsTag("GPSmodCar") and testPart:getItemContainer():containsType("GPScable") then
			local gps = testPart:getItemContainer():getFirstTagRecurse("GPSmodCar")
			return gps
		end
	end
	if toolP and (toolP:hasTag("GPSmod") and toolP:getUsedDelta() > 0) then
		local gps = player:getPrimaryHandItem() 
		return gps
	elseif toolS and (toolS:hasTag("GPSmod") and toolS:getUsedDelta() > 0) then
		local gps = player:getSecondaryHandItem()
		return gps 
	elseif toolsB then 
		for i=0,toolsB:size()-1 do
			local item = toolsB:getItemByIndex(i)
			if item:hasTag("GPSmod") and item:getUsedDelta() > 0 and keyK then
				local gps = item 
				return gps
			end
		end
	end
	return gps
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.findInInvGPS(player,containBattery)
	local toolP = player:getPrimaryHandItem()
	local toolS = player:getSecondaryHandItem()
	local toolsB = player:getAttachedItems()
	local keyK = isKeyDown(itemGPSmod.keyData.key)
	local gps = nil

	if toolP and (toolP:hasTag("GPSmod") and (containBattery == false or (containBattery == true and toolP:getUsedDelta() > 0.005))) then
		local gps = player:getPrimaryHandItem() 
		return gps
	elseif toolS and (toolS:hasTag("GPSmod") and (containBattery == false or (containBattery == true and toolS:getUsedDelta() > 0.005))) then
		local gps = player:getSecondaryHandItem()
		return gps 
	elseif toolsB then 
		for i=0,toolsB:size()-1 do
			local item = toolsB:getItemByIndex(i)
			if item:hasTag("GPSmod") and (containBattery == false or (containBattery == true and item:getUsedDelta() > 0.005)) then
				local gps = item 
				return gps
			end
		end
	end		
	for i=0, player:getInventory():getItems():size()-1 do
		local item = player:getInventory():getItems():get(i)
		if item:hasTag("GPSmod") and (containBattery == false or (containBattery == true and item:getUsedDelta() > 0.005)) then
			local gps = item
			return gps
		end
	end
	return gps
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.GPS_function(player)
	local gps = itemGPSmod.findGPS(player)
	if gps then 
	   	ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, gps, true))
	elseif isAdmin() then
		ISMiniMap.ToggleMiniMap(player:getPlayerNum())
	else
		local gps = player:getInventory():getFirstTagRecurse("GPSmod")
		if gps and player:isEquipped(gps) or player:isAttachedItem(gps) then getSoundManager():PlayWorldSound("GPS_Key_1", player:getSquare(), 1, 20, 2, true) end
		itemGPSmod.ToggleMiniMap(player, false, gps)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
