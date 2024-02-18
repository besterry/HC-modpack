require "ISUI/Maps/ISMiniMap"
require "ISUI/ISUIElement"
--require "ISUI/ISUIElement"

local upperLayer = {}
upperLayer.ISMiniMapOuter = {}
upperLayer.ISMiniMapInner = {}

-------------------------------------------------------------------------------------------------------------

upperLayer.ISMiniMapOuter.onButton1 = ISMiniMapOuter.onButton1
function ISMiniMapOuter:onButton1()
	upperLayer.ISMiniMapOuter.onButton1(self)
	local playerObj = getSpecificPlayer(0)
	if not itemGPSmod.gps then return end
	itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneUP")
end
upperLayer.ISMiniMapOuter.onButton2 = ISMiniMapOuter.onButton2
function ISMiniMapOuter:onButton2()
	upperLayer.ISMiniMapOuter.onButton2(self)
	local playerObj = getSpecificPlayer(0)
	if not itemGPSmod.gps then return end
	itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneMIDLE")
end
upperLayer.ISMiniMapOuter.onButton3 = ISMiniMapOuter.onButton3
function ISMiniMapOuter:onButton3()
	upperLayer.ISMiniMapOuter.onButton3(self)
	local playerObj = getSpecificPlayer(0)
	if not itemGPSmod.gps then return end
	itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneUP")
end
upperLayer.ISMiniMapOuter.onButton4 = ISMiniMapOuter.onButton4
function ISMiniMapOuter:onButton4()
	local playerObj = getSpecificPlayer(0)
	if isAdmin() or SandboxVars.itemGPS.IsometricViewOnMiniMapIsAllowed == true then upperLayer.ISMiniMapOuter.onButton4(self)
		itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneMIDLE")
		return
	elseif self.inner.mapAPI:getBoolean("Isometric") then self.inner.mapAPI:setBoolean("Isometric", not self.inner.mapAPI:getBoolean("Isometric")) --MiniMap.Isometric
	end
	itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneDOWN")
end
upperLayer.ISMiniMapOuter.onButton5 = ISMiniMapOuter.onButton5
function ISMiniMapOuter:onButton5()
	upperLayer.ISMiniMapOuter.onButton5(self)
	local playerObj = getSpecificPlayer(0)
	if not itemGPSmod.gps then return end
	itemGPSmod.playSoundGPS(playerObj, itemGPSmod.gps:getType().."_Beep_toneDOWN")
end
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
function ISMiniMapInner:onMouseUp(x, y)
	if self.dragging then
		self.dragging = false
		if not itemGPSmod.gps then return end
		itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneUP")
		if self.dragMoved then return end
	end
	--REMOVE TOGGLE MAP
end
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapInner.onMouseDown = ISMiniMapInner.onMouseDown
function ISMiniMapInner:onMouseDown(x, y)
	upperLayer.ISMiniMapInner.onMouseDown(self,x, y)
	if not itemGPSmod.gps then return end
	itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneUP")
end
-------------------------------------------------------------------------------------------------------------




-------------------------------------------------------------------------------------------------------------
--upperLayer.ISMiniMapTitleBar.onMouseDown = ISMiniMapTitleBar.onMouseDown
--function ISMiniMapTitleBar:onMouseDown(x, y)
--	upperLayer.ISMiniMapTitleBar.onMouseDown(self)
--	local playerObj = getSpecificPlayer(0)
--	getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), playerObj:getCurrentSquare(), 1, 25, 2, true)
--	--itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_chargeLOW")
--end
--upperLayer.ISMiniMapTitleBar.onMouseUp = ISMiniMapTitleBar.onMouseUp
--function ISMiniMapTitleBar:onMouseUp(x, y)
--	upperLayer.ISMiniMapTitleBar.onMouseUp(self)
--	local playerObj = getSpecificPlayer(0)
--	getSoundManager():PlayWorldSound("GPS_unCheck_" .. (ZombRand(4)+1), playerObj:getCurrentSquare(), 1, 25, 2, true)
--	--itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_chargeLOW")
--end
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--upperLayer.ISMiniMapInner.onMouseUp = ISMiniMapInner.onMouseUp
--function ISMiniMapInner:onMouseUp(x, y)
--	upperLayer.ISMiniMapInner.onMouseUp(self,x, y)
--	local playerObj = getSpecificPlayer(0)
-- itemGPSmod.playSoundGPS(self.player, self.gpsType.."_Beep_toneMIDLE")
--end