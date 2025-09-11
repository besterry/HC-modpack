-- HydroTrade: Add Non-PvP (PvE) Zone by Coordinates via ISPvpZonePanel hook

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

-- UI: Add NonPvp Zone by Coordinates
ISAddNonPvpZoneByCoordUI = ISPanel:derive("ISAddNonPvpZoneByCoordUI");

function ISAddNonPvpZoneByCoordUI:initialise()
	ISPanel.initialise(self);

	local btnWid = 100
	local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
	local padBottom = 10

	self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISAddNonPvpZoneByCoordUI.onClick);
	self.cancel.internal = "CANCEL";
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self:addChild(self.cancel);

	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PvpZone_AddZone"), self, ISAddNonPvpZoneByCoordUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = { r = 1, g = 1, b = 1, a = 0.1 };
	self:addChild(self.ok);

	-- Inputs
	self.titleEntry = ISTextEntryBox:new("Zone #" .. (NonPvpZone.getAllZones():size() + 1), 10, 10, 150, FONT_HGT_SMALL + 2 * 2);
	self.titleEntry:initialise();
	self.titleEntry:instantiate();
	self:addChild(self.titleEntry);

	local inputWidth = 100;
	local inputHeight = FONT_HGT_SMALL + 2 * 2;

	self.x1Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight);
	self.x1Entry:initialise();
	self.x1Entry:instantiate();
	self:addChild(self.x1Entry);

	self.y1Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight);
	self.y1Entry:initialise();
	self.y1Entry:instantiate();
	self:addChild(self.y1Entry);

	self.x2Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight);
	self.x2Entry:initialise();
	self.x2Entry:instantiate();
	self:addChild(self.x2Entry);

	self.y2Entry = ISTextEntryBox:new("", 10, 10, inputWidth, inputHeight);
	self.y2Entry:initialise();
	self.y2Entry:instantiate();
	self:addChild(self.y2Entry);
end

function ISAddNonPvpZoneByCoordUI:prerender()
	local z = 20;
	local splitPoint = 180;
	local x = 10;
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	self:drawText(getText("IGUI_PvpZone_AddZone") .. " (coords)", self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_PvpZone_AddZone") .. " (coords)") / 2), z, 1, 1, 1, 1, UIFont.Medium);

	z = z + FONT_HGT_MEDIUM + 20;
	self:drawText(getText("IGUI_PvpZone_ZoneName"), x, z + 2, 1, 1, 1, 1, UIFont.Small);
	self.titleEntry:setY(z);
	self.titleEntry:setX(splitPoint);

	z = z + FONT_HGT_SMALL + 15;
	self:drawText("X1", x, z + 2, 1, 1, 1, 1, UIFont.Small);
	self.x1Entry:setX(splitPoint);
	self.x1Entry:setY(z);

	z = z + FONT_HGT_SMALL + 10;
	self:drawText("Y1", x, z + 2, 1, 1, 1, 1, UIFont.Small);
	self.y1Entry:setX(splitPoint);
	self.y1Entry:setY(z);

	z = z + FONT_HGT_SMALL + 10;
	self:drawText("X2", x, z + 2, 1, 1, 1, 1, UIFont.Small);
	self.x2Entry:setX(splitPoint);
	self.x2Entry:setY(z);

	z = z + FONT_HGT_SMALL + 10;
	self:drawText("Y2", x, z + 2, 1, 1, 1, 1, UIFont.Small);
	self.y2Entry:setX(splitPoint);
	self.y2Entry:setY(z);

	self:updateButtons();
end

local function parseNumber(text)
	if not text then return nil end
	local n = tonumber(text)
	return n
end

function ISAddNonPvpZoneByCoordUI:isValid()
	local x1 = parseNumber(self.x1Entry:getInternalText());
	local y1 = parseNumber(self.y1Entry:getInternalText());
	local x2 = parseNumber(self.x2Entry:getInternalText());
	local y2 = parseNumber(self.y2Entry:getInternalText());
	local title = self.titleEntry:getInternalText();
	if not (x1 and y1 and x2 and y2) then return false end
	if not title or title == "" then return false end
	return true
end

function ISAddNonPvpZoneByCoordUI:updateButtons()
	self.ok.enable = self:isValid();
end

function ISAddNonPvpZoneByCoordUI:onClick(button)
	if button.internal == "OK" then
		if not self:isValid() then return end
		local title = self.titleEntry:getInternalText();
		if NonPvpZone.getZoneByTitle(title) then
			local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_PvpZone_ZoneAlreadyExistTitle", title), false, nil, nil);
			modal:initialise();
			modal:addToUIManager();
			modal.moveWithMouse = true;
			return
		end
		local x1 = parseNumber(self.x1Entry:getInternalText());
		local y1 = parseNumber(self.y1Entry:getInternalText());
		local x2 = parseNumber(self.x2Entry:getInternalText());
		local y2 = parseNumber(self.y2Entry:getInternalText());
		if x1 > x2 then x1, x2 = x2, x1 end
		if y1 > y2 then y1, y2 = y2, y1 end
		NonPvpZone.addNonPvpZone(title, math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2));
		self:setVisible(false);
		self:removeFromUIManager();
		if self.parentUI and self.parentUI.populateList then
			self.parentUI:populateList();
			self.parentUI:setVisible(true);
		end
		return
	end
	if button.internal == "CANCEL" then
		self:setVisible(false);
		self:removeFromUIManager();
		if self.parentUI then
			self.parentUI:setVisible(true);
		end
		return
	end
end

function ISAddNonPvpZoneByCoordUI:new(x, y, width, height, player)
	local o = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self);
	self.__index = self;
	if y == 0 then
		o.y = o:getMouseY() - (height / 2)
		o:setY(o.y)
	end
	if x == 0 then
		o.x = o:getMouseX() - (width / 2)
		o:setX(o.x)
	end
	o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
	o.width = width;
	o.height = height;
	o.player = player;
	o.moveWithMouse = true;
	ISAddNonPvpZoneByCoordUI.instance = o;
	o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 };
	return o;
end

-- Hook ISPvpZonePanel: add button and handle click
local _ISPVP_initialise = ISPvpZonePanel.initialise;
function ISPvpZonePanel:initialise()
	_ISPVP_initialise(self);

	local btnHgt2 = FONT_HGT_SMALL + 2 * 2;
	local label = "Add by coords";
	self.addZoneByCoord = ISButton:new(self.nonPvpList.x, self.seeZoneOnGround.y + self.seeZoneOnGround.height + 5, 120, btnHgt2, label, self, ISPvpZonePanel.onClick);
	self.addZoneByCoord.internal = "ADDZONEBYCOORD";
	self.addZoneByCoord:initialise();
	self.addZoneByCoord:instantiate();
	self.addZoneByCoord.borderColor = self.buttonBorderColor;
	self:addChild(self.addZoneByCoord);
end

local _ISPVP_onClick = ISPvpZonePanel.onClick;
function ISPvpZonePanel:onClick(button)
	if button and button.internal == "ADDZONEBYCOORD" then
		local ui = ISAddNonPvpZoneByCoordUI:new(self.x, self.y, 380, 250, self.player);
		ui:initialise();
		ui:addToUIManager();
		ui.parentUI = self;
		self:setVisible(false);
		return;
	end
	return _ISPVP_onClick(self, button);
end


