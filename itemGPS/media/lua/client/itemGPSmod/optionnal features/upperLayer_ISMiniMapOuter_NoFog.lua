
require "ISUI/Maps/ISMiniMap"
require "ISUI/ISUIElement"
local upperLayer = {}
upperLayer.ISMiniMapInner = {}

upperLayer.ISMiniMapInner.functionGPS = ISMiniMapInner.functionGPS
function ISMiniMapInner:functionGPS()
	upperLayer.ISMiniMapInner.functionGPS(self)
	local noFogOnMiniMap = SandboxVars.itemGPS.noFogOnMiniMap
	local hideUnvisitedAreas = self.mapAPI:getBoolean("HideUnvisited")
    if hideUnvisitedAreas == true and (noFogOnMiniMap == true or isAdmin()) then
		self.mapAPI:setBoolean("HideUnvisited", false)
	elseif hideUnvisitedAreas == false and noFogOnMiniMap == false and not isAdmin() then
		self.mapAPI:setBoolean("HideUnvisited", true)
	end

	if not isAdmin() and SandboxVars.itemGPS.IsometricViewOnMiniMapIsAllowed == false and self.mapAPI:getBoolean("Isometric") then 
		self.mapAPI:setBoolean("Isometric", not self.mapAPI:getBoolean("Isometric")) --MiniMap.Isometric
	end
end

--	upperLayer.ISMiniMapOuter.restoreSettings = ISMiniMapOuter.restoreSettings
--	function ISMiniMapOuter:restoreSettings()
--		upperLayer.ISMiniMapOuter.restoreSettings(self)
--		local noFogOnMiniMap = SandboxVars.itemGPS.noFogOnMiniMap
--		local hideUnvisitedAreas = self.inner.mapAPI:getBoolean("HideUnvisited")
--	    if hideUnvisitedAreas == true and noFogOnMiniMap == true then
--			self.inner.mapAPI:setBoolean("HideUnvisited", false)
--		elseif hideUnvisitedAreas == false and noFogOnMiniMap == false then
--			self.inner.mapAPI:setBoolean("HideUnvisited", true)
--		end
--	end