require "ISUI/Maps/ISMiniMap"
--require "ISUI/ISUIElement"


function ISMiniMapInner:onMouseUp(x, y)
	if self.dragging then
		local player = getSpecificPlayer(0)
		self.dragging = false
		getSoundManager():PlayWorldSound("GPS_Beep_2", player:getCurrentSquare(), 1, 25, 2, true)
		if self.dragMoved then return end
	end
	--REMOVE TOGGLE MAP
end
---------------------------------------------------------------------------------------------------------------
function ISMiniMapOuter:onButton6()
	local player = getSpecificPlayer(0)
	local toolP = player:getPrimaryHandItem()
	local toolS = player:getSecondaryHandItem()
	local toolsB = player:getAttachedItems()
	if toolP and (toolP:getType() == "GPSdayz" and toolP:isActivated()) then 
		self.gps = player:getPrimaryHandItem() 

	elseif toolS and (toolS:getType() == "GPSdayz" and toolS:isActivated()) then 
		self.gps = player:getSecondaryHandItem() 

	elseif toolsB 							   then 
	
		for i=1,toolsB:size() do
			local item = toolsB:getItemByIndex(i-1)
			if item:getType() == "GPSdayz" and item:isActivated() then
				self.gps = toolsB:getItemByIndex(i-1) 
				break
			end
		end
		if not self.gps then self.gps = player:getInventory():getItemFromType("GPSdayz") end
					 
	else 
		self.gps = player:getInventory():getItemFromType("GPSdayz") 
	end
	if isAdmin() and not self.gps then ISMiniMap.ToggleMiniMap(self.playerNum) return end
	self.gps:setActivated(not self.gps:isActivated()) 
end
---------------------------------------------------------------------------------------------------------------
----CREATE SECTION
---------------------------------------------------------------------------------------------------------------
--function ISMiniMapInner:update()
--
--    local player = getSpecificPlayer(0);
--    if not player then return end
--
--    if self.counter == nil then self.counter = 0 end
--    self.counter = self.counter +1
--
--	if self.counter == 1 then 
--	    local posX = math.floor(player:getX());
--	    local posY = math.floor(player:getY());
--	    local txt1 = "x:" .. posX .. " y:" .. posY;
--	
--	    posX = math.ceil(posX / 300) - 1;
--	    posY = math.ceil(posY / 300) - 1;
--	    local txt2 = "Cell: " .. posX .. "x" .. posY;
--	    self.labelText1 = ISLabel:new(-7, 165, 20, txt1, 0.5, 0.8, 0.3 , 1, UIFont.Small, true);
--	    self:addChild(self.labelText1); 
--	    self.labelText2 = ISLabel:new(-7, 154, 20, txt2, 0.5, 0.8, 0.3, 1, UIFont.Small, true);
--	    self:addChild(self.labelText2); 
--	elseif self.counter == 100 then 
--		self.counter = 0
--		self:removeChild(self.labelText1)
--	    self:removeChild(self.labelText2)
--	end
--end
-------------------------------------------------------------------------------------------------------------
-- upperLayer SECTION
---------------------------------------------------------------------------------------------------------------
--upperLayer.ISMiniMapTitleBar.prerender = ISMiniMapTitleBar.prerender
--function ISMiniMapTitleBar:prerender()
--	upperLayer.ISMiniMapTitleBar.prerender(self)
--	local th = self:titleBarHeight()
--	local GPS_DayZ_barre = getTexture("media/ui/GPS_DayZ_barre.png")
--	self:drawTextureScaled(GPS_DayZ_barre, 1, 1, self:getWidth() - 2, th - 2, 1, 1, 1, 1)
--
--end
---------------------------------------------------------------------------------------------------------------
--upperLayer.ISMiniMapInner.instantiate = ISMiniMapInner.instantiate
--function ISMiniMapInner:instantiate()
--	upperLayer.ISMiniMapInner.instantiate(self)
--
--	self.GPS_DayZ_contour = getTexture("media/ui/GPS_DayZ_contour.png")
--	--self.image = self:drawTextureScaled(self.GPS_DayZ_contour, -49, -30, 295, 285, 1, 1, 1, 1)
--	self.image = ISImage:new(-19, -5, 1, 1, self.GPS_DayZ_contour);
--	self:addChild(self.image)
--end
---------------------------------------------------------------------------------------------------------------
--upperLayer.ISMiniMapInner.prerenderHack = ISMiniMapInner.prerenderHack
--function ISMiniMapInner:prerenderHack()
--	upperLayer.ISMiniMapInner.prerenderHack(self)
--
--	local GPS_DayZ = getTexture("media/ui/GPS_DayZ.png")
--	self:drawTextureScaled(GPS_DayZ, -49, -30, 295, 285, 1, 1, 1, 1)
--end
---------------------------------------------------------------------------------------------------------------
--REWRTIE SECTION
-------------------------------------------------------------------------------------------------------------
--NO MAP ON CLICK GPS

-------------------------------------------------------------------------------------------------------------
----CONCERT BUTTON COLOR
--function ISMiniMapOuter:createChildren()
--	self.inner = ISMiniMapInner:new(self.borderSize, self.borderSize, self.width - self.borderSize * 2,
--		self.height - self.borderSize * 2, self.playerNum)
--	self:addChild(self.inner)
--
--	self.titleBar = ISMiniMapTitleBar:new(self)
--	self:addChild(self.titleBar)
--	self.titleBar:setVisible(false)
--
--	local btnWid = 31
--	local btnHgt = self.bottomHeight - 1
--
--	self.bottomPanel = ISPanel:new(self.borderSize, self.inner:getBottom() + 1, self.inner.width, btnHgt)
--	self:addChild(self.bottomPanel)
--	self.bottomPanel:setVisible(false)
--
--	self.button1 = ISButton:new(0, 0, btnWid, btnHgt, "M", self, ISMiniMapOuter.onButton1)
--	self.button1.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button1.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button1.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.bottomPanel:addChild(self.button1)
--
--	self.button2 = ISButton:new(self.button1:getRight() + 2, self.button1.y, btnWid, btnHgt, "-", self, function(self) end)
--	self.button2.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button2.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button2.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.button2:setRepeatWhilePressed(ISMiniMapOuter.onButton2)
--	self.bottomPanel:addChild(self.button2)
--
--	self.button3 = ISButton:new(self.button2:getRight() + 2, self.button1.y, btnWid, btnHgt, "+", self, function(self) end)
--	self.button3.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button3.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button3.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.button3:setRepeatWhilePressed(ISMiniMapOuter.onButton3)
--	self.bottomPanel:addChild(self.button3)
--
--	self.button4 = ISButton:new(self.button3:getRight() + 2, self.button1.y, btnWid, btnHgt, "~", self, ISMiniMapOuter.onButton4)
--	self.button4.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button4.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button4.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.bottomPanel:addChild(self.button4)
--
--	self.button5 = ISButton:new(self.button4:getRight() + 2, self.button1.y, btnWid, btnHgt, "S", self, ISMiniMapOuter.onButton5)
--	self.button5.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button5.backgroundColor = {r=0.4, g=0.7, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button5.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.bottomPanel:addChild(self.button5)
--
--	self.button6 = ISButton:new(self.button5:getRight() + 2, self.button1.y, btnWid, btnHgt, "X", self, ISMiniMapOuter.onButton6)
--	self.button6.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
--	self.button6.backgroundColor = {r=0.4, g=0.8, b=0.3, a=0.0};         ------ADDED MODIFIED
--	self.button6.backgroundColorMouseOver = {r=0.4, g=0.8, b=0.3, a=0.1};         ------ADDED MODIFIED
--	self.bottomPanel:addChild(self.button6)
--
--	self:insertNewLineOfButtons(self.button1, self.button2, self.button3, self.button4, self.button5, self.button6)
--	self.joypadIndex = 1
--	self.joypadIndexY = 1
--end
---------------------------------------------------------------------------------------------------------------
--CONVERT EXIT BUTTON INTO GPS OFF
