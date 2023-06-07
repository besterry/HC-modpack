require "ISUI/Maps/ISWorldMap"

local upperLayer = {}
upperLayer.ISWorldMap = {}

upperLayer.ISWorldMap.updateJoypad = ISWorldMap.updateJoypad
function ISWorldMap:updateJoypad()
    upperLayer.ISWorldMap.updateJoypad(self)
	if not isAdmin() then
		self.mapAPI:setBoolean("Players", false) 
		--return 
	elseif isAdmin() then
		self.mapAPI:setBoolean("Players", true) 
	end
end
--nothink
