--***********************************************************
--**              	  ROBERT JOHNSON                       **
--***********************************************************

ToxicZonePanel = ISPanel:derive("ToxicZonePanel");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** ToxicZonePanel:initialise
--**
--************************************************************************--

function ToxicZonePanel:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2
    local padBottom = 10

    local listY = 20 + FONT_HGT_MEDIUM + 20
    self.nonPvpList = ISScrollingListBox:new(10, listY, self.width - 20, (FONT_HGT_SMALL + 2 * 2) * 16);
    self.nonPvpList:initialise();
    self.nonPvpList:instantiate();
    self.nonPvpList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.nonPvpList.selected = 0;
    self.nonPvpList.joypadParent = self;
    self.nonPvpList.font = UIFont.NewSmall;
    self.nonPvpList.doDrawItem = self.drawList;
    self.nonPvpList.drawBorder = true;
    self:addChild(self.nonPvpList);

    self.removeZone = ISButton:new(self.nonPvpList.x + self.nonPvpList.width - 70, self.nonPvpList.y + self.nonPvpList.height + 5, 70, btnHgt2, getText("ContextMenu_Remove"), self, ToxicZonePanel.onClick);
    self.removeZone.internal = "REMOVEZONE";
    self.removeZone:initialise();
    self.removeZone:instantiate();
    self.removeZone.borderColor = self.buttonBorderColor;
    self:addChild(self.removeZone);
    self.removeZone.enable = false;

    self.teleportToZone = ISButton:new(self.nonPvpList.x + self.nonPvpList.width - 70, self.removeZone.y + btnHgt2 + 5, 70, btnHgt2, getText("IGUI_PvpZone_TeleportToZone"), self, ToxicZonePanel.onClick);
    self.teleportToZone:setX(self.nonPvpList.x + self.nonPvpList.width - self.teleportToZone.width)
    self.teleportToZone.internal = "TELEPORTTOZONE";
    self.teleportToZone:initialise();
    self.teleportToZone:instantiate();
    self.teleportToZone.borderColor = self.buttonBorderColor;
    self:addChild(self.teleportToZone);
    self.teleportToZone.enable = false;

    self.addZone = ISButton:new(self.nonPvpList.x, self.nonPvpList.y + self.nonPvpList.height + 5, 70, btnHgt2, getText("IGUI_PvpZone_AddZone"), self, ToxicZonePanel.onClick);
    self.addZone.internal = "ADDZONE";
    self.addZone:initialise();
    self.addZone:instantiate();
    self.addZone.borderColor = self.buttonBorderColor;
    self:addChild(self.addZone);

    self.seeZoneOnGround = ISButton:new(self.nonPvpList.x, self.addZone.y + btnHgt2 + 5, 70, btnHgt2, getText("IGUI_PvpZone_SeeZone"), self, ToxicZonePanel.onClick);
    self.seeZoneOnGround.internal = "SEEZONE";
    self.seeZoneOnGround:initialise();
    self.seeZoneOnGround:instantiate();
    self.seeZoneOnGround.borderColor = self.buttonBorderColor;
    self:addChild(self.seeZoneOnGround);

    self.no = ISButton:new(self:getWidth() - btnWid - 10, self.seeZoneOnGround:getBottom() + 20, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, ToxicZonePanel.onClick);
    self.no.internal = "OK";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);

    self:setHeight(self.no:getBottom() + padBottom)

    self:populateList();

end

function ToxicZonePanel:populateList()
    self.nonPvpList:clear();

    local zonesTable = ToxicZonePanel:requestModData()
    for i, w in pairs(zonesTable) do
        local zone = w;
        local newZone = {};
        newZone.title = i;
        newZone.zone = zone;
        self.nonPvpList:addItem(i, newZone);
    end
end

function ToxicZonePanel:requestModData()
	ModData.request("ToxicZone")
	self.ToxicZone = ModData.get("ToxicZone")
	return self.ToxicZone
end

function ToxicZonePanel:drawList(y, item, alt)
    local a = 0.9;
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText(item.item.title, 10, y + 2, 1, 1, 1, a, self.font);
--    self:drawText(item.item.zone:getSize() .. "", 100, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ToxicZonePanel:render()

end

function ToxicZonePanel:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_ToxicZone_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_ToxicZone_Title")) / 2), z, 1,1,1,1, UIFont.Medium);
end

function ToxicZonePanel:updateButtons()
end

function ToxicZonePanel:render()
    self:updateButtons();

    self.removeZone.enable = false;
    self.teleportToZone.enable = false;
    self.seeZoneOnGround.enable = false;
    if self.nonPvpList.selected > 0 then
        self.removeZone.enable = true;
        self.teleportToZone.enable = false;
    	self.seeZoneOnGround.enable = true;
        self.selectedZone = self.nonPvpList.items[self.nonPvpList.selected].item.zone;
		self.selectedZoneTitle = self.nonPvpList.items[self.nonPvpList.selected].item.title;
    else
        self.selectedZone = nil;
    end
end

function ToxicZonePanel:onClick(button)
    if button.internal == "OK" then
        self:setVisible(false);
        self:removeFromUIManager();
        --self.player:setSeeNonPvpZone(false);
    end
    if button.internal == "REMOVEZONE" then
        local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_ToxicZone_RemoveConfirm", self.selectedZoneTitle), true, nil, ToxicZonePanel.onRemoveZone, self.player:getPlayerNum());
        modal:initialise()
        modal:addToUIManager()
        modal.ui = self;
        modal.selectedZone = self.selectedZone;
		modal.selectedTitle = self.selectedZoneTitle;
        modal.moveWithMouse = true;
    end
    if button.internal == "ADDZONE" then
        local addPvpZone = ISAddToxicZoneUI:new(10,10, 400, 350, self.player);
        addPvpZone:initialise()
        addPvpZone:addToUIManager()
        addPvpZone.parentUI = self;
        self:setVisible(false);
    end
    if button.internal == "SEEZONE" then
		local toxicZone = ToxicZonePanel:requestModData();
			
		if toxicZone[self.selectedZoneTitle] and toxicZone[self.selectedZoneTitle].startX then
			local startX = toxicZone[self.selectedZoneTitle].startX
			local startY = toxicZone[self.selectedZoneTitle].startY
			local endX = toxicZone[self.selectedZoneTitle].endX
			local endY = toxicZone[self.selectedZoneTitle].endY
			
		for x2=startX, endX do
			for y=startY, endY do
				local sq = getCell():getGridSquare(x2,y,0);
				if sq then
					for n = 0,sq:getObjects():size()-1 do
						local obj = sq:getObjects():get(n);
						obj:setHighlighted(true);
						obj:setHighlightColor(0.6,1,0.6,0.5);
					end
				end
			end
		end
		end
    end
    if button.internal == "TELEPORTTOZONE" then
		local toxicZone = ToxicZonePanel:requestModData();
		
		if toxicZone[self.selectedZoneTitle].startX then
			local startX = toxicZone[self.selectedZoneTitle].startX
			local startY = toxicZone[self.selectedZoneTitle].startY
			SendCommandToServer("/teleportto " .. startX .. "," .. startY .. ",0");
		end
    end
end

function ToxicZonePanel:onRemoveZone(button)
    if button.internal == "YES" then
		local zoneTable = ToxicZonePanel:requestModData()
		local index = tostring(button.parent.selectedTitle);
		print("TRYING TO REMOVE A TOXIC ZONE:  " .. index);
		zoneTable[index] = nil;
		ModData.remove("ToxicZone")
		ModData.getOrCreate("ToxicZone")
		ModData.add("ToxicZone", zoneTable)
		if isClient() then
			ModData.transmit("ToxicZone")
		else
			local regionsTable = ToxicUpdate.createRegionsModData(zoneTable)
			ModData.getOrCreate("ToxicZoneRegions")
			ModData.add("ToxicZoneRegions", regionsTable)
		end
        button.parent.ui:populateList();
	--self.nonPvpList.joypadListIndex = 1;
	--self.nonPvpList.selected = 1;
    end
end

--************************************************************************--
--** ToxicZonePanel:new
--**
--************************************************************************--
function ToxicZonePanel:new(x, y, width, height, player)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.player = player;
    o.moveWithMouse = true;
    ToxicZonePanel.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    ModData.request("ToxicZone")
    --[[ if not ModData.get("ToxicZone") then
	ModData.getOrCreate("ToxicZone")
    end ]]--
    o.ToxicZone = ModData.get("ToxicZone")
	o.startX = nil;
	o.endX = nil;
	o.startY = nil;
	o.endY = nil;
    return o;
end
