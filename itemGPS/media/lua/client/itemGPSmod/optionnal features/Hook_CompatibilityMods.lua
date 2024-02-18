Events.OnGameStart.Add(function()
	-------------------------------------------------------------------------
	-- Darken Map mod compatibility
	-------------------------------------------------------------------------
	if DarkerMap_DarkenMap then
		Events.OnKeyPressed.Remove(DarkerMap_DarkenMap)
		DarkerMap_DarkenMap_Origin = DarkerMap_DarkenMap
		function DarkerMap_DarkenMap(key)
			if not ISWorldMap.checkKey(key) then return end
			local noMap = SandboxVars.itemGPS.WorldMap
			if not ISWorldMap.IsAllowed() or (ISWorldMap.IsAllowed() and noMap == 0 and not isAdmin()) then
				return
			end
			if noMap == 1 and not itemGPSmod.gps and not isAdmin() then return end
			DarkerMap_DarkenMap_Origin(key)	
		end
		Events.OnKeyPressed.Add(DarkerMap_DarkenMap)
	end
	-------------------------------------------------------------------------
	-- Military Grid Reference System compatibility
	-------------------------------------------------------------------------
	if getActivatedMods():contains("MGRS (FMCCYAYFGLE)") then
		local ISWorldMap_onMouseMove_Origin = ISWorldMap.onMouseMove
		function ISWorldMap:onMouseMove(dx, dy)
		    ISWorldMap_onMouseMove_Origin(self, dx, dy)
			if not itemGPSmod.gps and not isAdmin() then 
		        self.currentGridID = nil
		    end
		end
	end
end)