Events.OnGameStart.Add(function()
	local ISWorldMap_ToggleWorldMap_Origin = ISWorldMap.ToggleWorldMap
	function ISWorldMap.ToggleWorldMap(playerNum)
		local noMap = SandboxVars.itemGPS.WorldMap 
		local wmap = CheckMapItem()
		if not ISWorldMap.IsAllowed() or (ISWorldMap.IsAllowed() and noMap == 0 and not isAdmin()) then
			getSpecificPlayer(0):Say(getText("IGUI_No_Map_IG"))
			return
		end
		if noMap == 1 and not itemGPSmod.gps and not wmap and not isAdmin() then getSpecificPlayer(0):Say(getText("IGUI_No_GPS_on")) return end
		
		ISWorldMap_ToggleWorldMap_Origin(playerNum)
	end	
end)

function CheckMapItem()
    local player = getPlayer()
	if player then
		local wmap = player:getInventory():getFirstTypeRecurse("worldmap1")
		--print("MAP:",wmap)
		return wmap
	end
end