require "ISUI/Maps/ISMiniMap"

local upperLayer = {}
upperLayer.ISMiniMapOuter = {}


upperLayer.ISMiniMapOuter.restoreSettings = ISMiniMapOuter.restoreSettings
function ISMiniMapOuter:restoreSettings()
	upperLayer.ISMiniMapOuter.restoreSettings(self)
	local hideUnvisitedAreas = self.inner.mapAPI:getBoolean("HideUnvisited")
    if hideUnvisitedAreas == true then
		self.inner.mapAPI:setBoolean("HideUnvisited", false)
	end
end