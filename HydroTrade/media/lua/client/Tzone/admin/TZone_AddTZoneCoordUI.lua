TZone_AddTZoneCoordUI = ISPanel:derive("TZone_AddTZoneCoordUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local function parseNumber(text)
	if not text or text == "" then return nil end
	return tonumber(text)
end

local function getZoneCount()
	local tzones = ModData.get("TZone")
	if not tzones then return 0 end
	local count = 0
	for _ in pairs(tzones) do
		count = count + 1
	end
	return count
end

function TZone_AddTZoneCoordUI:initialise()
	ISPanel.initialise(self)

	local btnWid = 100
	local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
	local padBottom = 10
	local inputWidth = 100
	local inputHeight = FONT_HGT_SMALL + 2 * 2

	self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, TZone_AddTZoneCoordUI.onClick)
	self.cancel.internal = "CANCEL"
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise()
	self.cancel:instantiate()
	self.cancel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
	self:addChild(self.cancel)

	local okLabel = self.editMode and getText("IGUI_TZone_SaveZone") or getText("IGUI_PvpZone_AddZone")
	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, okLabel, self, TZone_AddTZoneCoordUI.onClick)
	self.ok.internal = "OK"
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise()
	self.ok:instantiate()
	self.ok.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
	self:addChild(self.ok)

	local defaultTitle = self.editMode and "" or ("TZone #" .. (getZoneCount() + 1))
	self.titleEntry = ISTextEntryBox:new(defaultTitle, 10, 10, 150, inputHeight)
	self.titleEntry:initialise()
	self.titleEntry:instantiate()
	self:addChild(self.titleEntry)

	self.x1Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight)
	self.x1Entry:initialise()
	self.x1Entry:instantiate()
	self:addChild(self.x1Entry)

	self.y1Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight)
	self.y1Entry:initialise()
	self.y1Entry:instantiate()
	self:addChild(self.y1Entry)

	self.x2Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight)
	self.x2Entry:initialise()
	self.x2Entry:instantiate()
	self:addChild(self.x2Entry)

	self.y2Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight)
	self.y2Entry:initialise()
	self.y2Entry:instantiate()
	self:addChild(self.y2Entry)

	if self.editMode and self.zoneData then
		self.oldTitle = self.zoneData.title
		self.titleEntry:setText(self.zoneData.title)
		self.x1Entry:setText(tostring(self.zoneData.zone.x))
		self.y1Entry:setText(tostring(self.zoneData.zone.y))
		self.x2Entry:setText(tostring(self.zoneData.zone.x2))
		self.y2Entry:setText(tostring(self.zoneData.zone.y2))
	end
end

function TZone_AddTZoneCoordUI:prerender()
	local z = 20
	local splitPoint = 180
	local x = 10
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

	local header = self.editMode and getText("IGUI_TZone_EditZoneTitle") or getText("IGUI_PvpZone_AddZoneCoord")
	self:drawText(header, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, header) / 2), z, 1, 1, 1, 1, UIFont.Medium)

	z = z + FONT_HGT_MEDIUM + 20
	self:drawText(getText("IGUI_PvpZone_ZoneName"), x, z + 2, 1, 1, 1, 1, UIFont.Small)
	self.titleEntry:setY(z)
	self.titleEntry:setX(splitPoint)

	z = z + FONT_HGT_SMALL + 15
	self:drawText("X1", x, z + 2, 1, 1, 1, 1, UIFont.Small)
	self.x1Entry:setX(splitPoint)
	self.x1Entry:setY(z)

	z = z + FONT_HGT_SMALL + 10
	self:drawText("Y1", x, z + 2, 1, 1, 1, 1, UIFont.Small)
	self.y1Entry:setX(splitPoint)
	self.y1Entry:setY(z)

	z = z + FONT_HGT_SMALL + 10
	self:drawText("X2", x, z + 2, 1, 1, 1, 1, UIFont.Small)
	self.x2Entry:setX(splitPoint)
	self.x2Entry:setY(z)

	z = z + FONT_HGT_SMALL + 10
	self:drawText("Y2", x, z + 2, 1, 1, 1, 1, UIFont.Small)
	self.y2Entry:setX(splitPoint)
	self.y2Entry:setY(z)

	self:updateButtons()
end

function TZone_AddTZoneCoordUI:isValid()
	local x1 = parseNumber(self.x1Entry:getInternalText())
	local y1 = parseNumber(self.y1Entry:getInternalText())
	local x2 = parseNumber(self.x2Entry:getInternalText())
	local y2 = parseNumber(self.y2Entry:getInternalText())
	local title = string.trim(self.titleEntry:getInternalText() or "")
	if not (x1 and y1 and x2 and y2) then return false end
	if title == "" then return false end
	return true
end

function TZone_AddTZoneCoordUI:isDuplicateTitle(title)
	local tzones = ModData.get("TZone")
	if not tzones or not tzones[title] then return false end
	if self.editMode and self.oldTitle and title == self.oldTitle then return false end
	return true
end

function TZone_AddTZoneCoordUI:updateButtons()
	self.ok.enable = self:isValid()
end

function TZone_AddTZoneCoordUI:showDuplicateModal(title)
	local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_PvpZone_ZoneAlreadyExistTitle", title), false, nil, nil)
	modal:initialise()
	modal:addToUIManager()
	modal.moveWithMouse = true
end

function TZone_AddTZoneCoordUI:closeAndReturn()
	self:setVisible(false)
	self:removeFromUIManager()
	if self.parentUI then
		if self.parentUI.populateList then
			self.parentUI:populateList()
		end
		self.parentUI:setVisible(true)
	end
end

function TZone_AddTZoneCoordUI:onClick(button)
	if button.internal == "OK" then
		if not self:isValid() then return end

		local title = string.trim(self.titleEntry:getInternalText())
		if self:isDuplicateTitle(title) then
			self:showDuplicateModal(title)
			return
		end

		local x1 = parseNumber(self.x1Entry:getInternalText())
		local y1 = parseNumber(self.y1Entry:getInternalText())
		local x2 = parseNumber(self.x2Entry:getInternalText())
		local y2 = parseNumber(self.y2Entry:getInternalText())
		if x1 > x2 then x1, x2 = x2, x1 end
		if y1 > y2 then y1, y2 = y2, y1 end
		x1 = math.floor(x1)
		y1 = math.floor(y1)
		x2 = math.floor(x2)
		y2 = math.floor(y2)

		if self.editMode then
			sendClientCommand("TZone", "editTZone", { self.oldTitle, title, x1, y1, x2, y2 })
		else
			sendClientCommand("TZone", "addTZone", { title, x1, y1, x2, y2 })
		end

		self:closeAndReturn()
		return
	end

	if button.internal == "CANCEL" then
		self:closeAndReturn()
	end
end

function TZone_AddTZoneCoordUI:new(x, y, width, height, player, zoneData)
	local o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	if y == 0 then
		o.y = o:getMouseY() - (height / 2)
		o:setY(o.y)
	end
	if x == 0 then
		o.x = o:getMouseX() - (width / 2)
		o:setX(o.x)
	end
	o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 }
	o.width = width
	o.height = height
	o.player = player
	o.moveWithMouse = true
	o.editMode = zoneData ~= nil
	o.zoneData = zoneData
	o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
	TZone_AddTZoneCoordUI.instance = o
	return o
end
