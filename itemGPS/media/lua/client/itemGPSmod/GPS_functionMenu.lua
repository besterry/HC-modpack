
itemGPSmod = itemGPSmod or {}
itemGPSmod.keyData = {
    key = Keyboard.KEY_K, -- No default value, user needs to configure it.
    name = "GPS_CheckBelt_key", -- Maps to UI_optionscreen_binding_RV_INTERIOR_ENTER in Translate files
}
if ModOptions and ModOptions.getInstance then
    ModOptions:AddKeyBinding("[HotkeyGPS]", itemGPSmod.keyData);
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function itemGPSmod.GPS_plug (player,gps)
	if not gps then return end
	local vehicleInside = player:getVehicle()
	local cable = player:getInventory():getItemFromType("GPScable") 
	if not vehicleInside or not cable then player:Say("do you glitch ?!") return end
	local seat = vehicleInside:getSeat(player)
	if seat > 1 then player:Say("do you glitch ?!") return end
	getSoundManager():PlayWorldSound("GPS_PLUG", player:getCurrentSquare(), 1, 20, 2, true)
	itemGPSmod.restartCounter = false
	itemGPSmod.chargeOn = false
	if vehicleInside:getBatteryCharge() > 0 and (vehicleInside:isKeysInIgnition() or vehicleInside:isHotwired()) then itemGPSmod.chargeOn = true ; itemGPSmod.playSoundGPS(player, gps:getType().."_Beep_chargePLUG") end 
	itemGPSmod.PlugedGps = gps
	Events.OnPlayerUpdate.Add(itemGPSmod.GPS_charge)
	itemGPSmod.gpsChargeCounter = 0
end
------------------------------------------
function itemGPSmod.GPS_UnPlug (player,gps)
	if not gps then return end
	local vehicleInside = player:getVehicle()
	local cable = player:getInventory():getItemFromType("GPScable")
	if not vehicleInside or not cable then player:Say("do you glitch ?!") return end
	local seat = vehicleInside:getSeat(player)
	if seat > 1 then player:Say("do you glitch ?!") return end
	getSoundManager():PlayWorldSound("GPS_UNPLUG", player:getCurrentSquare(), 1, 20, 2, true)
	itemGPSmod.restartCounter = false
	if vehicleInside:getBatteryCharge() > 0 and itemGPSmod.chargeOn == true then itemGPSmod.chargeOn = false ; itemGPSmod.playSoundGPS(player, gps:getType().."_Beep_chargeUNPLUG") end
	itemGPSmod.PlugedGps = nil
	Events.OnPlayerUpdate.Remove(itemGPSmod.GPS_charge)

end
-------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------
local function GPS_on(player,gps)
	if not gps then return end
	if gps:hasTag("GPSmod") and not gps:isEquipped() then
		local time = 100 
		local hotbar = getPlayerHotbar(player:getPlayerNum())
		if (not getActivatedMods():contains("addTransferItemSounds") or not getActivatedMods():contains("addSoundsTransferItemUSER")) and (not hotbar or (hotbar and not hotbar:isItemAttached(gps))) then-- time = 100 end
			--getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 20, 2, true)
			local name = "GPS_Check_" .. (ZombRand(4)+1)
			itemGPSmod.playSoundGPS(player, name)
		end
		ISTimedActionQueue.add(ISEquipWeaponAction:new(player, gps, time, false))
		--ISTimedActionQueue.add(ISEquipWeaponAction:new(player, gps, 50, false))
	end
	ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, gps, true))

end
------------------------------------------
local function GPS_off (player,gps)
	if not gps then return end
	ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, gps, false))
end
------------------------------------------
local function GPS_off_on(player,gps)
	if not gps then return end
	ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, itemGPSmod.gps, false))
	GPS_on(player,gps)
end
----------------------------------------
local function GPS_item_Context (player, context, items)
	local player = getSpecificPlayer(0)

	testItem = nil
	for i,v in ipairs(items) do
	    testItem = v;
	    if not instanceof(v, "InventoryItem") then
	        if #v.items == 2 then
	        end
	        testItem = v.items[1];
	    end
    end
    if not testItem or (testItem and (not testItem:hasTag("GPSmod") and not testItem:hasTag("GPSmodCar"))) then return end  --not player:getInventory():contains(testItem)

    local vehicleInside = player:getVehicle()
    if testItem and testItem:hasTag("GPSmodCar") then 
    	if not vehicleInside then return end
		local testPart = vehicleInside:getPartById("GloveBox");
		if not testPart then return end
		if not testPart:getItemContainer():contains(testItem) or (testPart:getItemContainer():contains(testItem) and (vehicleInside:getSeat(player) > 1 or not testPart:getItemContainer():containsType("GPScable"))) then return end
	elseif not testItem or (testItem and testItem:hasTag("GPSmod") and not player:getInventory():contains(testItem)) then 
		return 
	end

	if vehicleInside and vehicleInside:getSeat(player) < 2 and testItem:hasTag("GPSmod") then
		local cable = player:getInventory():getItemFromType("GPScable") 
		if vehicleInside and (testItem ~= itemGPSmod.PlugedGps or not itemGPSmod.PlugedGps) then
			option = context:addOption(getText("IGUI_Plug"), player, itemGPSmod.GPS_plug, testItem, vehicleInside);
			if testItem:getUsedDelta() == 0 then 
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
		elseif vehicleInside and testItem == itemGPSmod.PlugedGps then
			option = context:addOption(getText("IGUI_unPlug"), player, itemGPSmod.GPS_UnPlug, testItem, vehicleInside);
			option.toolTip = ISToolTip:new()
		    option.toolTip:initialise()
		    option.toolTip:setVisible(true)
		    option.toolTip:setName(getText("IGUI_Info"))
	        option.toolTip.description = getText("IGUI_autoUnplugInfo")
		end
	end

	if  not itemGPSmod.gps then
		option = context:addOption(getText("IGUI_itemGPSmod_On"), player, GPS_on, testItem)
	elseif itemGPSmod.gps and testItem ~= itemGPSmod.gps then
		option = context:addOption(getText("IGUI_itemGPSmod_On"), player, GPS_off_on, testItem)
	elseif testItem == itemGPSmod.gps then
		option = context:addOption(getText("IGUI_itemGPSmod_Off"), player, GPS_off, testItem)
	end
end
----------------------------------------------------------------
Events.OnPreFillInventoryObjectContextMenu.Add(GPS_item_Context)
------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
function itemGPSmod.counterHotkeyGPS()
	if counterGPS and counterGPS > 0 then counterGPS = counterGPS -1 return end
	local player = getSpecificPlayer(0)
	if itemGPSmod.gps ~= nil  then
		ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, itemGPSmod.gps, false))
	else
		itemGPSmod.GPS_function(player)
    end
    counterGPS = nil
    Events.OnPlayerUpdate.Remove(itemGPSmod.counterHotkeyGPS)
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function OnKeyStartPressedGPS(_key)
	if _key == itemGPSmod.keyData.key then
		if itemGPSmod.keyData.key == Keyboard.KEY_K then--
			if ISFPS.start then --isKeyDown(getCore():getKey("Display FPS"))
				ISFPS.start = false;
				ISEquippedItem.text = nil;
			end
		end 
		local player = getPlayer()
		if not player or (not player:getInventory():containsTag("GPSmod") and not player:getInventory():containsTag("GPSmodCar")) then return end
		if not counterGPS then
			counterGPS = 15 
			Events.OnPlayerUpdate.Add(itemGPSmod.counterHotkeyGPS)
		else
			local toolP = player:getPrimaryHandItem()
			local toolS = player:getSecondaryHandItem()
			if toolP and toolP:hasTag("GPSmod") then
				local time = 100 
				local hotbar = getPlayerHotbar(player:getPlayerNum())
				if itemGPSmod.gps and itemGPSmod.gps == toolP then ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, toolP, false)) end --itemGPSmod.ToggleMiniMap(player, false, toolP) end
				if (not getActivatedMods():contains("addTransferItemSounds") or not getActivatedMods():contains("addSoundsTransferItemUSER")) and (not hotbar or (hotbar and not hotbar:isItemAttached(toolP))) then --time = 100 end
					--getSoundManager():PlayWorldSound("GPS_unCheck_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 20, 2, true)
					local name = "GPS_unCheck_" .. (ZombRand(4)+1)
					itemGPSmod.playSoundGPS(player, name)
				end
				ISTimedActionQueue.add(ISUnequipAction:new(player, toolP, time))
			elseif toolS and toolS:hasTag("GPSmod") then
				local time = 100 
				local hotbar = getPlayerHotbar(player:getPlayerNum())
				if itemGPSmod.gps and itemGPSmod.gps == toolS then ISTimedActionQueue.add(GPS_TimedAction_ON_OFF:new(player, toolS, false)) end --itemGPSmod.ToggleMiniMap(player, false, toolS) end
				if (not getActivatedMods():contains("addTransferItemSounds") or not getActivatedMods():contains("addSoundsTransferItemUSER")) and (not hotbar or (hotbar and not hotbar:isItemAttached(toolS))) then --time = 100 end
					--getSoundManager():PlayWorldSound("GPS_unCheck_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 20, 2, true)
					local name = "GPS_unCheck_" .. (ZombRand(4)+1)
					itemGPSmod.playSoundGPS(player, name)
				end
				ISTimedActionQueue.add(ISUnequipAction:new(player, toolS, time))
			elseif itemGPSmod.gps == nil then
				local gps = itemGPSmod.findInInvGPS(player,true)
				if not gps then gps = itemGPSmod.findGPS(player) end
				if not gps then gps = itemGPSmod.findInInvGPS(player,false) end
				if gps then 
					--getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 20, 2, true)
					GPS_on(player,gps)
				end 
			end
			Events.OnPlayerUpdate.Remove(itemGPSmod.counterHotkeyGPS)
			counterGPS = nil
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------		
Events.OnKeyStartPressed.Add(OnKeyStartPressedGPS)
-------------------------------------------------------------------------------------------------------------------------------------------		
local function OnKeyPressedGPS(_key)
	if _key == itemGPSmod.keyData.key then
		if itemGPSmod.keyData.key == Keyboard.KEY_K then
			if ISFPS.start then
				ISFPS.start = false;
				ISEquippedItem.text = nil;
			end
		end 
		local player = getSpecificPlayer(0)
		if not player then return end
		local playerNum = player:getPlayerNum()
    	local mm = getPlayerMiniMap(playerNum)
		local mm = getPlayerMiniMap(playerNum)
    	if not mm then 
			local msg = "you need to activate the minimap option in your sandbox parameters"
    	    player:setHaloNote(msg, 222, 70, 40, 600)
    		return 
    	end
	end
end
Events.OnKeyPressed.Add(OnKeyPressedGPS) 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function preLaunchGPS_function(_player)
	if not _player then return end
	local player = getSpecificPlayer(0)
	local playerNum = player:getPlayerNum()
    local mm = getPlayerMiniMap(playerNum)
    if not mm then 
		local msg = "you need to activate the minimap in your server parameters"
        player:setHaloNote(msg, 222, 100, 50, 600)
    	return 
    end
    local settings = WorldMapSettings.getInstance()
	settings:setBoolean("MiniMap.StartVisible", false)
end
Events.OnCreatePlayer.Add(preLaunchGPS_function)












	--	----------------------------------------------------------------------test
	--if (not vehicleInside or vehicleInside:getSeat(player) > 1 or not cable and gpsINV) then itemGPSmod.PlugedGps = nil ; getSoundManager():PlayWorldSound(itemGPSmod.PlugedGps:getType().."_Beep_gpsunPLUG", player:getCurrentSquare(), 1, 25, 2, true) end
	--if not gpsINV then
	--	--if not GPS_vehicleInside then print "no origine car" return end
	--	--local vehicle = itemGPSmod.PlugedGps:getVehicleContainer()	
	--	local gpsPresent = false
	--	for partIndex=1,GPS_vehicleInside:getPartCount() do
	--		local vehiclePart = GPS_vehicleInside:getPartByIndex(partIndex-1)
	--		if vehiclePart:getItemContainer() then
	--			if vehiclePart:getItemContainer():contains(itemGPSmod.PlugedGps) and vehiclePart:getItemContainer():containsType("GPScable") then
	--				player:Say("container cable")
	--				gpsPresent = true
	--			end
	--			if vehiclePart:getItemContainer():contains(itemGPSmod.PlugedGps) and (cable and player:getVehicle() == GPS_vehicleInside) then
	--				player:Say("container gps")
	--				gpsPresent = true
	--			end
	--			
	--		end
	--	end
	--	--if gpsPresent == false then print "no gps and cable in veh" ; itemGPSmod.PlugedGps = nil ;getSoundManager():PlayWorldSound(itemGPSmod.PlugedGps:getType().."_Beep_gpsunPLUG", GPS_vehicleInside:getCurrentSquare(), 1, 25, 2, true) return end
	--end