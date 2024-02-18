require "ISUI/Maps/ISMiniMap"

function ISMiniMapOuter:onButton6()
	local player = getSpecificPlayer(0)
	if itemGPSmod.gps then itemGPSmod.playSoundGPS(player, itemGPSmod.gps:getType().."_Beep_OFF") ; itemGPSmod.ToggleMiniMap (player, false, itemGPSmod.gps) end
	if isAdmin() and not itemGPSmod.gps then ISMiniMap.ToggleMiniMap(self.playerNum) end
end

function ISMiniMap.ToggleMiniMap(playerNum)
	local mm = getPlayerMiniMap(playerNum)	
	if not mm then return end
	if not isAdmin() then getSpecificPlayer(0):Say(getText("IGUI_No_miniMap")) return end

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
--[[-------------------------------------------------------------------------------------------------------------
--CONCERT BUTTON COLOR
function ISMiniMapOuter:createChildren()
	self.inner = ISMiniMapInner:new(self.borderSize, self.borderSize, self.width - self.borderSize * 2,
		self.height - self.borderSize * 2, self.playerNum)
	self:addChild(self.inner)

	self.titleBar = ISMiniMapTitleBar:new(self)
	self:addChild(self.titleBar)
	self.titleBar:setVisible(false)

	local btnWid = 31
	local btnHgt = self.bottomHeight - 1

	self.bottomPanel = ISPanel:new(self.borderSize, self.inner:getBottom() + 1, self.inner.width, btnHgt)
	self:addChild(self.bottomPanel)
	self.bottomPanel:setVisible(false)

	self.button1 = ISButton:new(0, 0, btnWid, btnHgt, "M", self, ISMiniMapOuter.onButton1)
	self.button1.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button1.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button1.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.bottomPanel:addChild(self.button1)

	self.button2 = ISButton:new(self.button1:getRight() + 2, self.button1.y, btnWid, btnHgt, "-", self, function(self) end)
	self.button2.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button2.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button2.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.button2:setRepeatWhilePressed(ISMiniMapOuter.onButton2)
	self.bottomPanel:addChild(self.button2)

	self.button3 = ISButton:new(self.button2:getRight() + 2, self.button1.y, btnWid, btnHgt, "+", self, function(self) end)
	self.button3.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button3.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button3.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.button3:setRepeatWhilePressed(ISMiniMapOuter.onButton3)
	self.bottomPanel:addChild(self.button3)

	self.button4 = ISButton:new(self.button3:getRight() + 2, self.button1.y, btnWid, btnHgt, "~", self, ISMiniMapOuter.onButton4)
	self.button4.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button4.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button4.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.bottomPanel:addChild(self.button4)

	self.button5 = ISButton:new(self.button4:getRight() + 2, self.button1.y, btnWid, btnHgt, "S", self, ISMiniMapOuter.onButton5)
	self.button5.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button5.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button5.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.bottomPanel:addChild(self.button5)

	self.button6 = ISButton:new(self.button5:getRight() + 2, self.button1.y, btnWid, btnHgt, "X", self, ISMiniMapOuter.onButton6)
	self.button6.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	self.button6.backgroundColor = {r=0.4, g=0.8, b=0.3, a=0.0};         ------ADDED MODIFIED
	self.button6.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
	self.bottomPanel:addChild(self.button6)

	self:insertNewLineOfButtons(self.button1, self.button2, self.button3, self.button4, self.button5, self.button6)
	self.joypadIndex = 1
	self.joypadIndexY = 1
end
--]]------------------------------------------------------------------------------------------------------------