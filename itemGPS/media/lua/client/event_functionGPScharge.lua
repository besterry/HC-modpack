
local GPSconso = 0.021
itemGPS_Pluged = nil
GPS_delay_charge = 0
GPS_Beep_Charge = false
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function GPS_charge()
	if not itemGPS_Pluged then GPS_delay_charge = 0 return end
	local player = getSpecificPlayer(0)
	if not player then return end
	local vehicleInside = player:getVehicle()
	local gpsINV = player:getInventory():contains(itemGPS_Pluged)
	local cable = player:getInventory():getItemFromType("GPScable")

	if not vehicleInside or vehicleInside:getSeat(player) > 1 or not cable or not gpsINV then 
		Events.OnPlayerUpdate.Remove(GPS_charge) ; 
		GPS_present_on_delay = false ; 
		itemGPS_Pluged = nil ; 
		getSoundManager():PlayWorldSound("GPS_Beep_gpsunPLUG", player:getCurrentSquare(), 1, 25, 2, true) 

		if GPS_Beep_Charge == true then GPS_Beep_Charge = false ; getSoundManager():PlayWorldSound("GPS_Beep_chargeUNPLUG", player:getCurrentSquare(), 1, 25, 2, true) end --vehicleInside and vehicleInside:getBatteryCharge() > 0 and 
	end
	--	----------------------------------------------------------------------test
	--if (not vehicleInside or vehicleInside:getSeat(player) > 1 or not cable and gpsINV) then itemGPS_Pluged = nil ; getSoundManager():PlayWorldSound("GPS_Beep_gpsunPLUG", player:getCurrentSquare(), 1, 25, 2, true) end
	--if not gpsINV then
	--	--if not GPS_vehicleInside then print "no origine car" return end
	--	--local vehicle = itemGPS_Pluged:getVehicleContainer()	
	--	local gpsPresent = false
	--	for partIndex=1,GPS_vehicleInside:getPartCount() do
	--		local vehiclePart = GPS_vehicleInside:getPartByIndex(partIndex-1)
	--		if vehiclePart:getItemContainer() then
	--			if vehiclePart:getItemContainer():contains(itemGPS_Pluged) and vehiclePart:getItemContainer():containsType("GPScable") then
	--				player:Say("container cable")
	--				gpsPresent = true
	--			end
	--			if vehiclePart:getItemContainer():contains(itemGPS_Pluged) and (cable and player:getVehicle() == GPS_vehicleInside) then
	--				player:Say("container gps")
	--				gpsPresent = true
	--			end
	--			
	--		end
	--	end
	--	--if gpsPresent == false then print "no gps and cable in veh" ; itemGPS_Pluged = nil ;getSoundManager():PlayWorldSound("GPS_Beep_gpsunPLUG", GPS_vehicleInside:getCurrentSquare(), 1, 25, 2, true) return end
	--end
		----------------------------------------------------------------------test
	if vehicleInside and (((not vehicleInside:isKeysInIgnition() and not vehicleInside:isHotwired())) or vehicleInside:getBatteryCharge() == 0) then 
		if GPS_Beep_Charge == true then getSoundManager():PlayWorldSound("GPS_Beep_chargeUNPLUG", player:getCurrentSquare(), 1, 25, 2, true) end --and vehicleInside:getBatteryCharge() > 0 
		GPS_Beep_Charge = false ; 
		return 
	end

	if vehicleInside and vehicleInside:getBatteryCharge() > 0 and GPS_Beep_Charge == false then  GPS_Beep_Charge = true ; getSoundManager():PlayWorldSound("GPS_Beep_chargePLUG", player:getCurrentSquare(), 1, 25, 2, true) end

	GPS_delay_charge = GPS_delay_charge +1
	if GPS_delay_charge == 2499 and itemGPS_Pluged then	
		if vehicleInside:getBatteryCharge() > 0 and itemGPS_Pluged:getUsedDelta() < 1 then 
			VehicleUtils.chargeBattery(vehicleInside, -(GPSconso/7)); 
			itemGPS_Pluged:setUsedDelta(itemGPS_Pluged:getUsedDelta()+GPSconso)
			--player:Say("charge") 
		end 
		if itemGPS_Pluged:getUsedDelta() == 1 then 
			itemGPS_Pluged = nil ; 
			getSoundManager():PlayWorldSound("GPS_Beep_chargeOK", vehicleInside:getCurrentSquare(), 1, 25, 2, true) 
			Events.OnPlayerUpdate.Remove(GPS_charge)
		end  
	elseif GPS_delay_charge >= 2500 then
		
		GPS_delay_charge = 0
	end
end
-------------------------------------
--Events.OnPlayerUpdate.Add(GPS_charge)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function GPSdayz_plug (player,gps)
	local vehicleInside = player:getVehicle()
	local cable = player:getInventory():getItemFromType("GPScable") 
	if not vehicleInside or not cable then player:Say("do you glitch ?!") return end
	local seat = vehicleInside:getSeat(player)
	if seat > 1 then player:Say("do you glitch ?!") return end
	getSoundManager():PlayWorldSound("GPS_Beep_gpsPLUG", player:getCurrentSquare(), 1, 25, 2, true)
	GPS_Beep_Charge = false
	if vehicleInside:getBatteryCharge() > 0 and (vehicleInside:isKeysInIgnition() or vehicleInside:isHotwired()) then GPS_Beep_Charge = true ; getSoundManager():PlayWorldSound("GPS_Beep_chargePLUG", player:getCurrentSquare(), 1, 25, 2, true)  end
	itemGPS_Pluged = gps
	Events.OnPlayerUpdate.Add(GPS_charge)
	GPS_delay_charge = 0
end
------------------------------------------
local function GPSdayz_UnPlug (player,gps)
	local vehicleInside = player:getVehicle()
	local cable = player:getInventory():getItemFromType("GPScable")
	if not vehicleInside or not cable then player:Say("do you glitch ?!") return end
	local seat = vehicleInside:getSeat(player)
	if seat > 1 then player:Say("do you glitch ?!") return end
	getSoundManager():PlayWorldSound("GPS_Beep_gpsunPLUG", player:getCurrentSquare(), 1, 25, 2, true)
	if vehicleInside:getBatteryCharge() > 0 and GPS_Beep_Charge == true then GPS_Beep_Charge = false ; getSoundManager():PlayWorldSound("GPS_Beep_chargeUNPLUG", player:getCurrentSquare(), 1, 25, 2, true)  end
	itemGPS_Pluged = nil
	Events.OnPlayerUpdate.Remove(GPS_charge)

end
----------------------------------------
local function GPS_item_Context (player, context, items)
	local player = getSpecificPlayer(0)
	local vehicleInside = player:getVehicle()
	if not vehicleInside then return end
	local seat = vehicleInside:getSeat(player)
	local cable = player:getInventory():getItemFromType("GPScable") 
	if seat > 1 then return end -- not vehicleInside:isDriver(player) or 
	for i,v in ipairs(items) do
	    testItem = v;
	    if not instanceof(v, "InventoryItem") then
	        if #v.items == 2 then
	        end
	        testItem = v.items[1];
	    end
    end
    if not player:getInventory():contains(testItem) then return end

	if  testItem and testItem:getType() == "GPSdayz" and vehicleInside and (testItem ~= itemGPS_Pluged or not itemGPS_Pluged) then--GPS_charge_plug ~= true and (testItem ~= itemGPS_Pluged or not itemGPS_Pluged)then
		option = context:addOption(getText("IGUI_Plug"), player, GPSdayz_plug, testItem, vehicleInside);
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
		end
	elseif testItem and testItem:getType() == "GPSdayz" and vehicleInside and testItem == itemGPS_Pluged then--GPS_charge_plug ~= false and testItem == itemGPS_Pluged then
		option = context:addOption(getText("IGUI_unPlug"), player, GPSdayz_UnPlug, testItem, vehicleInside);
		option.toolTip = ISToolTip:new()
	    option.toolTip:initialise()
	    option.toolTip:setVisible(true)
	    option.toolTip:setName(getText("IGUI_Info"))
        option.toolTip.description = getText("IGUI_autoUnplugInfo")
	end
end
----------------------------------------------------------------
Events.OnPreFillInventoryObjectContextMenu.Add(GPS_item_Context)
------------------------------------------------------------------------------------------------------------------------
