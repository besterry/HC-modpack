Events.OnGameStart.Add(function()
	local ISWorldMap_ToggleWorldMap_Origin = ISWorldMap.ToggleWorldMap
	function ISWorldMap.ToggleWorldMap(playerNum)
		local noMap = SandboxVars.itemGPS.WorldMap 
		if not ISWorldMap.IsAllowed() or (ISWorldMap.IsAllowed() and noMap == 0 and not isAdmin()) then
			getSpecificPlayer(0):Say(getText("IGUI_No_Map_IG"))
			return
		end
		if noMap == 1 and not itemGPSmod.gps and not isAdmin() then  getSpecificPlayer(0):Say(getText("IGUI_No_GPS_on")) return end
		
		ISWorldMap_ToggleWorldMap_Origin(playerNum)
	end	
end)