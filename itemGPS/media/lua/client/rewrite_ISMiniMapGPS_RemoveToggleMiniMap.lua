require "ISUI/Maps/ISMiniMap"

function ISMiniMap.ToggleMiniMap(playerNum)
	local mm = getPlayerMiniMap(playerNum)	
	
	if (mm or not mm) and not isAdmin() then getSpecificPlayer(0):Say(getText("IGUI_No_miniMap")) return end

	local startVisible = false
	if mm:isReallyVisible() then
		if mm.joyfocus then
			mm:clearJoypadFocus(mm.joyfocus)
			setJoypadFocus(playerNum, nil)
		end
		mm:removeFromUIManager()
		startVisible = false
	else
		mm:addToUIManager()
		startVisible = true
	end
	if playerNum == 0 then
		local settings = WorldMapSettings.getInstance()
		settings:setBoolean("MiniMap.StartVisible", startVisible)
	end
end

--local upperLayer = {}
--upperLayer.ISMiniMapOuter = {}
--
--upperLayer.ISMiniMapOuter.setPosition = ISMiniMapOuter.setPosition
--function ISMiniMapOuterOuter:setPosition()
--	upperLayer.ISMiniMapOuter.setPosition(self)
--	local playerObj = getSpecificPlayer(0)
--	local gps = playerObj:getInventory():getItemFromType("PLGR")
--	local mm = getPlayerMiniMap(self.playerNum)
--	if not gps then 
--		mm:addToUIManager()
--		startVisible = false
--
--		settings:setBoolean("MiniMap.StartVisible", startVisible)
--		return
--	 end
--end
--upperLayer.ISMiniMap.ToggleMiniMap = ISMiniMap.ToggleMiniMap
--function ISMiniMap.ToggleMiniMap(playerNum)
--	    upperLayer.ISMiniMap.ToggleMiniMap(self)
--	    return
--	--local mm = getPlayerMiniMap(playerNum)
--	local playerObj = getSpecificPlayer(0)
--	local gps = playerObj:getInventory():getItemFromType("PLGR")
--    --local PrimaryHand = self.character:getPrimaryHandItem()
--    --local SecondaryHand = self.character:getSecondaryHandItem()
--    if not gps then return end
--	if not mm then return end
--	local startVisible = false
--	if mm:isReallyVisible() then
--		if mm.joyfocus then
--			mm:clearJoypadFocus(mm.joyfocus)
--			setJoypadFocus(playerNum, nil)
--		end
--		mm:removeFromUIManager()
--		startVisible = false
--	else
--		mm:addToUIManager()
--		startVisible = true
--	end
--	if playerNum == 0 then
--		local settings = WorldMapSettings.getInstance()
--		settings:setBoolean("MiniMap.StartVisible", startVisible)
--	end
--end
