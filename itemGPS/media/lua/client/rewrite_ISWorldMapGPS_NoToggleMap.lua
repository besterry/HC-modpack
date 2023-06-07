require "ISUI/Maps/ISWorldMap"

function ISWorldMap.ToggleWorldMap(playerNum)
	if not ISWorldMap.IsAllowed() then
		return
	end
	if ISWorldMap.IsAllowed() then
		local gps
		local map1
		local player = getSpecificPlayer(0)
		local toolE = player:getPrimaryHandItem()
		local toolR = player:getSecondaryHandItem()		
		local toolsA = player:getAttachedItems()
		local toolP = player:getPrimaryHandItem()
		local toolS = player:getSecondaryHandItem()
		local toolsB = player:getAttachedItems()
		
		if toolP and (toolP:getType() == "GPSdayz" and toolP:isActivated()) then 
			gps = player:getPrimaryHandItem() 
	
		elseif toolS and (toolS:getType() == "GPSdayz" and toolS:isActivated()) then 
			gps = player:getSecondaryHandItem() 		
			
		elseif toolsB then 
		
			for i=1,toolsB:size() do
				local item = toolsB:getItemByIndex(i-1)
				if item:getType() == "GPSdayz" and item:isActivated() then
					gps = toolsB:getItemByIndex(i-1) 
					break
				end
			end		
		end
		
		if toolE and (toolP:getType() == "worldmap1") then 
			map1 = player:getPrimaryHandItem() 
	
		elseif toolR and (toolS:getType() == "worldmap1") then 
			map1 = player:getSecondaryHandItem() 		

		elseif toolsA then 
		
			for i=1,toolsA:size() do
				local item = toolsB:getItemByIndex(i-1)
				if item:getType() == "worldmap1" then
					map1 = toolsA:getItemByIndex(i-1) 
					break
				end
			end		
		end
		--------------------------------------------------
		if not gps and not map1 and not isAdmin() then return player:Say(getText("IGUI_No_GPS_on")) end
		--------------------------------------------------
		if ISPostDeathUI and ISPostDeathUI.instance and #ISPostDeathUI.instance > 0 then
			return
		end
		if ISWorldMap_instance and ISWorldMap_instance:isVisible() then
			ISWorldMap.HideWorldMap(playerNum)
		else
			local playerObj = getSpecificPlayer(playerNum)
			if playerObj then
				ISTimedActionQueue.clear(playerObj)
				ISTimedActionQueue.add(ISReadWorldMap:new(playerObj))
			else
				-- Debug: In the main menu
				ISWorldMap.ShowWorldMap(playerNum)
			end
		end
	end
end