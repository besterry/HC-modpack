require "ISUI/Maps/ISMiniMap"
require "ISUI/ISUIElement"
--require "ISUI/ISUIElement"

local upperLayer = {}
upperLayer.ISMiniMapOuter = {}
upperLayer.ISMiniMapTitleBar = {}
upperLayer.ISMiniMapInner = {}

-------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapTitleBar.onMouseDown = ISMiniMapTitleBar.onMouseDown
function ISMiniMapTitleBar:onMouseDown(x, y)
	upperLayer.ISMiniMapTitleBar.onMouseDown(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Check_" .. (ZombRand(4)+1), playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapTitleBar.onMouseUp = ISMiniMapTitleBar.onMouseUp
function ISMiniMapTitleBar:onMouseUp(x, y)
	upperLayer.ISMiniMapTitleBar.onMouseUp(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_unCheck_" .. (ZombRand(4)+1), playerObj:getCurrentSquare(), 1, 25, 2, true)
end
-------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapTitleBar.prerender = ISMiniMapTitleBar.prerender
function ISMiniMapTitleBar:prerender()
	upperLayer.ISMiniMapTitleBar.prerender(self)
	local th = self:titleBarHeight()
	local GPS_DayZ_barre = getTexture("media/ui/GPS_DayZ_barre.png")
	self:drawTextureScaled(GPS_DayZ_barre, 1, 1, self:getWidth() - 2, th - 2, 1, 1, 1, 1)
end
-------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapInner.instantiate = ISMiniMapInner.instantiate
function ISMiniMapInner:instantiate()
	upperLayer.ISMiniMapInner.instantiate(self)	
	self.GPS_DayZ_contour2 = getTexture("media/ui/GPS_DayZ_contour2.png")
	--self.image = self:drawTextureScaled(self.GPS_DayZ_contour2, -49, -30, 295, 285, 1, 1, 1, 1)
	self.image = ISImage:new(-19, -5, 1, 1, self.GPS_DayZ_contour2);
	self:addChild(self.image)
end
-------------------------------------------------------------------------------------------------------------
upperLayer.ISMiniMapInner.prerenderHack = ISMiniMapInner.prerenderHack
function ISMiniMapInner:prerenderHack()
	upperLayer.ISMiniMapInner.prerenderHack(self)
	local GPS_DayZ = getTexture("media/ui/GPS_DayZ.png")
	self:drawTextureScaled(GPS_DayZ, -49, -30, 295, 285, 1, 1, 1, 1)
end
-------------------------------------------------------------------------------------------------------------
--REWRTIE SECTION
-------------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

upperLayer.ISMiniMapOuter.onButton1 = ISMiniMapOuter.onButton1
function ISMiniMapOuter:onButton1()
	upperLayer.ISMiniMapOuter.onButton1(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapOuter.onButton2 = ISMiniMapOuter.onButton2
function ISMiniMapOuter:onButton2()
	upperLayer.ISMiniMapOuter.onButton2(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapOuter.onButton3 = ISMiniMapOuter.onButton3
function ISMiniMapOuter:onButton3()
	upperLayer.ISMiniMapOuter.onButton3(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapOuter.onButton4 = ISMiniMapOuter.onButton4
function ISMiniMapOuter:onButton4()
	upperLayer.ISMiniMapOuter.onButton4(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapOuter.onButton5 = ISMiniMapOuter.onButton5
function ISMiniMapOuter:onButton5()
	upperLayer.ISMiniMapOuter.onButton5(self)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
upperLayer.ISMiniMapInner.onMouseDown = ISMiniMapInner.onMouseDown
function ISMiniMapInner:onMouseDown(x, y)
	upperLayer.ISMiniMapInner.onMouseDown(self,x, y)
	local playerObj = getSpecificPlayer(0)
	getSoundManager():PlayWorldSound("GPS_Beep_2on", playerObj:getCurrentSquare(), 1, 25, 2, true)
end
--upperLayer.ISMiniMapInner.onMouseUp = ISMiniMapInner.onMouseUp
--function ISMiniMapInner:onMouseUp(x, y)
--	upperLayer.ISMiniMapInner.onMouseUp(self,x, y)
--	local playerObj = getSpecificPlayer(0)
--	getSoundManager():PlayWorldSound("GPS_Beep_2", playerObj:getCurrentSquare(), 1, 25, 2, true)
--end