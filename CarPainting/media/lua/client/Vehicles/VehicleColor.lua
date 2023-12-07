local oldColorH
local oldColorS
local oldColorV
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

VehicleHSV = ISCollapsableWindow:derive("VehicleHSV")

function VehicleHSV:addLabel(_x, _y, _title, _font, _bLeft)
    local FONT_HGT = getTextManager():getFontHeight(_font)
    local label = ISLabel:new(_x, _y, FONT_HGT, _title, 1, 1, 1, 1.0, _font, _bLeft==nil and true or _bLeft)
    label:initialise()
    label:instantiate()
--    label.customData = _data
    self:addChild(label)
    return label:getY() + label:getHeight(), label
end

function VehicleHSV:addSlider(_x, _y, _w, _h, _func)
    local slider = ISSliderPanel:new(_x, _y, _w, _h, self, _func )
    slider:initialise()
    slider:instantiate()
--    slider.valueLabel = true
--    slider.customData = _data
    self:addChild(slider)
    return slider:getY() + slider:getHeight(), slider
end

function VehicleHSV:callbackAngleX(value, slider)
end

function VehicleHSV:callbackAngleY(value, slider)
end

function VehicleHSV:callbackAngleZ(value, slider)
end

function VehicleHSV:createChildren()
	ISCollapsableWindow.createChildren(self)

	self.scriptName = ISLabel:new(10, self:titleBarHeight() + 10, FONT_HGT_SMALL, "Script: ", 1, 1, 1, 1, UIFont.Small, true)
	self:addChild(self.scriptName)

	self:addLabel(10, self.scriptName:getBottom() + 16, getText("IGUI_Hue"), UIFont.Small, true)
	local y,slider = self:addSlider(80, self.scriptName:getBottom() + 16, 200, 20, self.callbackAngleX)
	slider:setValues(0, 100, 1, 10, true)
	self.colorHue = slider

	self:addLabel(10, y + 16, getText("IGUI_Saturation"), UIFont.Small, true)
	y,slider = self:addSlider(80, y + 16, 200, 20, self.callbackAngleY)
	slider:setValues(0, 100, 1, 10, true)
	self.colorSaturation = slider

	self:addLabel(10, y + 16, getText("IGUI_Value"), UIFont.Small, true)
	y,slider = self:addSlider(80, y + 16, 200, 20, self.callbackAngleZ)
	slider:setValues(0, 100, 1, 10, true)
	self.colorValue = slider

	local button = ISButton:new(10, y + 30, 60, 16, getText("IGUI_Red"), self, self.onButtonRed)
	button:initialise()
	button:instantiate()
	button.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(button)

	local button2 = ISButton:new(button:getRight() + 10, y + 30, 60, 16, getText("IGUI_Blue"), self, self.onButtonBlue)
	button2:initialise()
	button2:instantiate()
	button2.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(button2)

	local button3 = ISButton:new(button2:getRight() + 10, y + 30, 60, 16, getText("IGUI_White"), self, self.onButtonWhite)
	button3:initialise()
	button3:instantiate()
	button3.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(button3)

	local button4 = ISButton:new(button3:getRight() + 10, y + 30, 60, 16, getText("IGUI_Black"), self, self.onButtonBlack)
	button4:initialise()
	button4:instantiate()
	button4.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(button4)

	local button5 = ISButton:new(10, button:getBottom() + 10, 60, 16, getText("IGUI_Other"), self, self.onButtonOther)
	button5:initialise()
	button5:instantiate()
	button5.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(button5)

	self.nextSkinButton = ISButton:new(10, 230, 130, 25, getText("IGUI_Next_skin"), self, self.onButtonNextSkin)
	self.nextSkinButton:initialise()
	self.nextSkinButton:instantiate()
	self.nextSkinButton.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.nextSkinButton)

	self.prevSkinButton = ISButton:new(self.nextSkinButton:getRight() + 10, 230, 130, 25, getText("IGUI_previous_skin"), self, self.onButtonPrevSkin)
	self.prevSkinButton:initialise()
	self.prevSkinButton:instantiate()
	self.prevSkinButton.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.prevSkinButton)

	self.paintCar = ISButton:new(100, 265, 100, 25, getText("IGUI_Save_skin"), self, self.onButtonSaveSkin)
	self.paintCar:initialise()
	self.paintCar:instantiate()
	self.paintCar.borderColor = {r=1, g=1, b=1, a=0.1}
	self:addChild(self.paintCar)
end

function VehicleHSV:onButtonRed()
	if not self.vehicle then return end
	self.colorHue:setCurrentValue(ZombRand(0, 3))
	self.colorSaturation:setCurrentValue(ZombRand(85, 100))
	self.colorValue:setCurrentValue(ZombRand(55, 85))
end

function VehicleHSV:onButtonBlue()
	if not self.vehicle then return end
	self.colorHue:setCurrentValue(ZombRand(55, 61))
	self.colorSaturation:setCurrentValue(ZombRand(85, 100))
	self.colorValue:setCurrentValue(ZombRand(65, 75))
end

function VehicleHSV:onButtonWhite()
	if not self.vehicle then return end
	self.colorHue:setCurrentValue(15) -- ZombRand(0, 100)
	self.colorSaturation:setCurrentValue(ZombRand(000, 10))
	self.colorValue:setCurrentValue(ZombRand(70, 80))
end

function VehicleHSV:onButtonBlack()
	if not self.vehicle then return end
	self.colorHue:setCurrentValue(ZombRand(0, 100))
	self.colorSaturation:setCurrentValue(ZombRand(0, 10))
	self.colorValue:setCurrentValue(ZombRand(10, 25))
end

function VehicleHSV:onButtonOther()
	if not self.vehicle then return end
	self.colorHue:setCurrentValue(ZombRand(0, 100))
	self.colorSaturation:setCurrentValue(ZombRand(60, 75))
	self.colorValue:setCurrentValue(ZombRand(30, 70))
end

local args

function VehicleHSV:onButtonNextSkin()
	if not self.vehicle then return end
	local skinIndex = self.vehicle:getSkinIndex()
	skinIndex = skinIndex + 1
	if skinIndex >= self.vehicle:getSkinCount() then
		skinIndex = 0
	end
	self.vehicle:setSkinIndex(skinIndex)
	self.vehicle:updateSkin()
	args = { vehicle = self.vehicle:getId(), index = skinIndex }
	--print("skinIndex:",skinIndex)
end

function VehicleHSV:onButtonPrevSkin()
	if not self.vehicle then return end
	local skinIndex = self.vehicle:getSkinIndex()
	skinIndex = skinIndex - 1
	if skinIndex < 0 then
		skinIndex = self.vehicle:getSkinCount()-1
	end
	self.vehicle:setSkinIndex(skinIndex)
	self.vehicle:updateSkin()
	args = { vehicle = self.vehicle:getId(), index = skinIndex }	
	--print("skinIndex:",skinIndex)
end


function VehicleHSV:onButtonSaveSkin()
	--print("Click butoon")
	local item1 = getPlayer():getPrimaryHandItem()-- получаем предмет в правой руке игрока
    local item2 = getPlayer():getSecondaryHandItem() -- получаем предмет в левой руке игрока
    if (item1 and item1:getFullType()  == "Base.SprayPaint") or (item2 and item2:getFullType()  == "Base.SprayPaint") or isAdmin() then 
		if args then
			sendClientCommand(self.character, 'vehicle', 'setSkinIndex', args) --смена скина
		end
		local args2 = { vehicle = self.vehicle:getId(), h = self.colorHue.currentValue / 100, s = self.colorSaturation.currentValue / 100, v = self.colorValue.currentValue / 100}
		sendClientCommand(self.character, 'vehicle', 'setHSV', args2) --смена цвета
		--print("Send color to server")	
		if item1 and item1:getFullType()  == "Base.SprayPaint" then 
			getPlayer():getPrimaryHandItem():Use()
			getPlayer():getInventory():Remove(item1) end
		if item2 and item2:getFullType()  == "Base.SprayPaint" then 
			getPlayer():getSecondaryHandItem():Use()
			getPlayer():getInventory():Remove(item2) end
		args = nil
		args2 = nil
		ISCollapsableWindow.close(self)
	else
		getPlayer():Say(getText('IGUI_NeedPaint'))
	end
end

function VehicleHSV:clearVehicle()
	self.vehicle = nil
	self.scriptName.name = getText("IGUI_NoVehicleSelected")
end


function VehicleHSV:prerender()
	ISCollapsableWindow.prerender(self)
	if self.vehicle and (self.vehicle:getMovingObjectIndex() < 0) then
		self:clearVehicle()
	end
	if self.vehicle then
		self.vehicle:setColorHSV(self.colorHue.currentValue / 100, self.colorSaturation.currentValue / 100, self.colorValue.currentValue / 100)
		local x = 20
		self.colorHue:drawText(tostring(self.colorHue.currentValue), x, -20, 1, 1, 1, 1, UIFont.Small)
		self.colorSaturation:drawText(tostring(self.colorSaturation.currentValue), x, -20, 1, 1, 1, 1, UIFont.Small)
		self.colorValue:drawText(tostring(self.colorValue.currentValue), x, -20, 1, 1, 1, 1, UIFont.Small)
	end
end

function VehicleHSV:close()
	if self.vehicle then
		--print("Restore color")
		local args = { vehicle = self.vehicle:getId(), h = oldColorH / 100, s = oldColorS / 100, v = oldColorV / 100}
		sendClientCommand(self.character, 'vehicle', 'setHSV', args)		
		self:clearVehicle()
	end
	args = nil
	ISCollapsableWindow.close(self)
end


function VehicleHSV:setVehicle(vehicle)
	self.vehicle = vehicle
	self.script = vehicle and vehicle:getScript() or nil
	if self.vehicle then
		self.scriptName.name = getText("IGUI_AutoScript")..self.script:getName()
		self.colorHue:setCurrentValue(self.vehicle:getColorHue() * 100)
		oldColorH = self.vehicle:getColorHue() * 100
		self.colorSaturation:setCurrentValue(self.vehicle:getColorSaturation() * 100)
		oldColorS = self.vehicle:getColorSaturation() * 100
		self.colorValue:setCurrentValue(self.vehicle:getColorValue() * 100)
		oldColorV = self.vehicle:getColorValue() * 100
	end
	if self.vehicle:getSkinIndex() == -1 or self.vehicle:getSkinCount() <= 1 then
		self.nextSkinButton:setEnable(false)
	else
		self.nextSkinButton:setEnable(true)
	end
end

function VehicleHSV:new(playerObj)
	local width = 300
	local height = 300
	local x = (getCore():getScreenWidth() / 2) - (width / 2)
	local y = (getCore():getScreenHeight() / 2) - (height / 2)

	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o:setResizable(false)
	o.title = getText("IGUI_PaintLabel")
	o.character = playerObj
	return o
end

local ui = nil

function debugVehicleColor(playerObj, vehicle)
	ui = ui or VehicleHSV:new(playerObj)
	ui:setVisible(true)
	ui:addToUIManager()
	ui:setVehicle(vehicle or getSpecificPlayer(0):getVehicle())
end

