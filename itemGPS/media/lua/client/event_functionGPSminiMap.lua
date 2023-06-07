--require "ISUI/Maps/ISMiniMap"

local GPS_beep_BRIDE = 0
local SLB_delay = 0
local GPS_present_on_delay = false
local itemGPS_counter = 0

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
--local ISMiniMap = {}
local function ToggleMiniMap2 (player, gps, playerNum)
	--local playerNum = player:getPlayerNum()
	local mm = getPlayerMiniMap(playerNum)
	if not mm then return end

	local startVisible = false
	if not mm:isReallyVisible() then
		mm:addToUIManager()
		startVisible = true
		if ISUIHandler.allUIVisible == true and gps then getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 25, 2, true) end

	end
	if playerNum == 0 then
		local settings = WorldMapSettings.getInstance()
		settings:setBoolean("MiniMap.StartVisible", startVisible)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function ToggleMiniMap3 (player, gps, playerNum)
	--local playerNum = player:getPlayerNum()
	local mm = getPlayerMiniMap(playerNum)
	if not mm then return end
	if GPS_present_on_delay ~= false then GPS_present_on_delay = false end
	local startVisible = false
	if mm:isReallyVisible() then
		if mm.joyfocus then
			mm:clearJoypadFocus(mm.joyfocus)
			setJoypadFocus(playerNum, nil)
		end
		mm:removeFromUIManager()
		startVisible = false
		if gps then getSoundManager():PlayWorldSound("GPS_unCheck_" .. (ZombRand(4)+1), player:getCurrentSquare(), 1, 25, 2, true) end
		if gps and not gps:isActivated() and gps:getUsedDelta() > 0 then GPS_beep_BRIDE = 0 end
	end
	if playerNum == 0 then
		local settings = WorldMapSettings.getInstance()
		settings:setBoolean("MiniMap.StartVisible", startVisible)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local keyData = {
    key = Keyboard.KEY_K, -- No default value, user needs to configure it.
    name = "GPS_CheckBelt_key", -- Maps to UI_optionscreen_binding_RV_INTERIOR_ENTER in Translate files
}
if ModOptions and ModOptions.getInstance then
    ModOptions:AddKeyBinding("[HotkeyGPS]", keyData);
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function apply_GPS_function(player,mmVisible,playerNum)
	local toolP = player:getPrimaryHandItem()
	local toolS = player:getSecondaryHandItem()
	local toolsB = player:getAttachedItems()
	local fromHotbar = false
	gps = nil
	if toolP and (toolP:getType() == "GPSdayz" and toolP:isActivated()) then 
		gps = player:getPrimaryHandItem() 
	elseif toolS and (toolS:getType() == "GPSdayz" and toolS:isActivated()) then 
		gps = player:getSecondaryHandItem() 
	elseif toolsB then 
		for i=0,toolsB:size()-1 do
			local item = toolsB:getItemByIndex(i)
			if item:getType() == "GPSdayz" and item:isActivated() then
				gps = item 
				fromHotbar = true
				break
			end
		end
		if not gps then gps = player:getInventory():getItemFromType("GPSdayz") end		 
	else 
		gps = player:getInventory():getItemFromType("GPSdayz") 
	end		
	--------------------------------------------------	
	if gps and gps:isActivated() then 	
	--------------------------------------------------		
	   	local hotbar = getPlayerHotbar(player:getPlayerNum())
	   	--local fromHotbar = false;
		local modData = gps:getModData()
		local keyK = isKeyDown(keyData.key)-- or isKeyDown(37))
		local gpsEquiped = gps:isEquipped()
		local gpsBattery = gps:getUsedDelta()
		---------------------
		GPS_present_on = true
		---------------------			
		if hotbar and fromHotbar == false then fromHotbar = hotbar:isItemAttached(gps) end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		if gpsBattery <= 0.005 then gps:setActivated(not gps:isActivated()) ; player:Say(getText("IGUI_noBattery")) ; getSoundManager():PlayWorldSound("GPS_Beep_low", player:getCurrentSquare(), 1, 20, 2, true)  end  
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
		if gpsBattery > 0.005 and GPS_beep_BRIDE == 0 and (gpsEquiped or fromHotbar) then GPS_beep_BRIDE = 1 ; getSoundManager():PlayWorldSound("GPS_Beep_ON", player:getCurrentSquare(), 1, 25, 2, true) end -- GPS_beep_BRIDE = 1 ;
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		SLB_delay = SLB_delay +1
		GPS_beep_BRIDE = GPS_beep_BRIDE +1
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
		if GPS_beep_BRIDE > 0 and not gpsEquiped and not fromHotbar then
			getSoundManager():PlayWorldSound("GPS_Beep_OFF", player:getCurrentSquare(), 1, 25, 2, true) 
	  		gps:setActivated(not gps:isActivated()) 
	  		GPS_beep_BRIDE = 0 
	  	end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
	    if 		SLB_delay == 33 and gpsBattery <= 0.12 then SLB_delay = 0 ; getSoundManager():PlayWorldSound("GPS_Beep_low", player:getCurrentSquare(), 1, 20, 2, true) 
	    elseif 	SLB_delay > 40  then SLB_delay = 0 end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
		if modData.ReceiveGPS and gpsBattery > 0.005 and fromHotbar and not keyK and not gpsEquiped then 
	        if 		GPS_beep_BRIDE == 2 then getSoundManager():PlayWorldSound("GPS_Beep_hiddenDisplay", player:getCurrentSquare(), 1, 20, 2, true)		
			elseif 	GPS_beep_BRIDE > 25 then GPS_beep_BRIDE = 1 end
		end
		if modData.ReceiveGPS and gpsBattery > 0.005 and ((fromHotbar and keyK) or gpsEquiped) then
			if GPS_beep_BRIDE == 2 then getSoundManager():PlayWorldSound("GPS_Beep_1", player:getCurrentSquare(), 1, 30, 2, true) 	
			elseif 	GPS_beep_BRIDE > 12 then GPS_beep_BRIDE = 1 end

		  	if not mmVisible then ToggleMiniMap2(player, gps, playerNum) end			
	    else
	       	if keyData.key == Keyboard.KEY_K and ISFPS.start then
				ISFPS.start = false;
				ISEquippedItem.text = nil;
			end 
			if mmVisible then ToggleMiniMap3(player, gps, playerNum) end
			if GPS_present_on_delay ~= false then GPS_present_on_delay = false end
		end
		---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
	else
		if GPS_beep_BRIDE > 0 and gps:getUsedDelta() > 0 then GPS_beep_BRIDE = 0 ; getSoundManager():PlayWorldSound("GPS_Beep_OFF", player:getCurrentSquare(), 1, 25, 2, true) end 
		if mmVisible then ToggleMiniMap3(player, gps, playerNum) end
		if GPS_present_on_delay ~= false then GPS_present_on_delay = false end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function GPS_function()--player) retrait player pour getSpecificPlayer()
	if itemGPS_counter > 0 then itemGPS_counter = itemGPS_counter-1 return else itemGPS_counter = 110 end
	local player = getSpecificPlayer(0)
	if not player or player:isDead() or isAdmin() or not MainScreen.instance or not MainScreen.instance.inGame or MainScreen.instance:getIsVisible() then return end
	local gpsINV = player:getInventory():getItemFromType("GPSdayz")
	local playerNum = player:getPlayerNum()
    local mm = getPlayerMiniMap(playerNum)
    local mmVisible = mm:isReallyVisible()
	if gpsINV then --gps = nil
		apply_GPS_function(player,mmVisible,playerNum) -->> rajout transmission playerNum pour ToggleMiniMap
	else
		if GPS_beep_BRIDE ~= 0 then GPS_beep_BRIDE = 0 end
		if mmVisible then ToggleMiniMap3(player, gps, playerNum) end
		if GPS_present_on_delay ~= false then GPS_present_on_delay = false end
	end 
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
local function preLaunchGPS_function(_player)
	if not _player then return end
	local player = getSpecificPlayer(0)
	local playerNum = player:getPlayerNum()
    local mm = getPlayerMiniMap(playerNum)

    if not mm then return end
    Events.OnPlayerUpdate.Add(GPS_function)
end
Events.OnCreatePlayer.Add(preLaunchGPS_function)