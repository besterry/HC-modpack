-- Панель со списком всех PVP-зон

--***********************************************************
--**                  ROBERT JOHNSON                       **
--**                 edited by iBrRus                      **
--***********************************************************
require "PVPE_ForcePVPZone.lua"

PVPE_ISPvpZonePanel = ISPanel:derive("PVPE_ISPvpZonePanel");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

--************************************************************************--
--** PVPE_ISPvpZonePanel:initialise
--**
--************************************************************************--

function PVPE_ISPvpZonePanel:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2
    local padBottom = 10

    local listY = 20 + FONT_HGT_MEDIUM + 20
    self.truePvpList = ISScrollingListBox:new(10, listY, self.width - 20, (FONT_HGT_SMALL + 2 * 2) * 16);
    self.truePvpList:initialise();
    self.truePvpList:instantiate();
    self.truePvpList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.truePvpList.selected = 0;
    self.truePvpList.joypadParent = self;
    self.truePvpList.font = UIFont.NewSmall;
    self.truePvpList.doDrawItem = self.drawList;
    self.truePvpList.drawBorder = true;
    self:addChild(self.truePvpList);

    self.removeZone = ISButton:new(self.truePvpList.x + self.truePvpList.width - 70, self.truePvpList.y + self.truePvpList.height + 5, 70, btnHgt2, getText("ContextMenu_Remove"), self, PVPE_ISPvpZonePanel.onClick);
    self.removeZone.internal = "REMOVEZONE";
    self.removeZone:initialise();
    self.removeZone:instantiate();
    self.removeZone.borderColor = self.buttonBorderColor;
    self:addChild(self.removeZone);
    self.removeZone.enable = false;

    self.teleportToZone = ISButton:new(self.truePvpList.x + self.truePvpList.width - 70, self.removeZone.y + btnHgt2 + 5, 70, btnHgt2, getText("IGUI_PvpZone_TeleportToZone"), self, PVPE_ISPvpZonePanel.onClick);
    self.teleportToZone:setX(self.truePvpList.x + self.truePvpList.width - self.teleportToZone.width)
    self.teleportToZone.internal = "TELEPORTTOZONE";
    self.teleportToZone:initialise();
    self.teleportToZone:instantiate();
    self.teleportToZone.borderColor = self.buttonBorderColor;
    self:addChild(self.teleportToZone);
    self.teleportToZone.enable = false;

    self.addZone = ISButton:new(self.truePvpList.x, self.truePvpList.y + self.truePvpList.height + 5, 70, btnHgt2, getText("IGUI_PvpZone_AddZone"), self, PVPE_ISPvpZonePanel.onClick);
    self.addZone.internal = "ADDZONE";
    self.addZone:initialise();
    self.addZone:instantiate();
    self.addZone.borderColor = self.buttonBorderColor;
    self:addChild(self.addZone);

    -- self.seeZoneOnGround = ISButton:new(self.truePvpList.x, self.addZone.y + btnHgt2 + 5, 70, btnHgt2, getText("IGUI_PvpZone_SeeZone"), self, PVPE_ISPvpZonePanel.onClick);
    -- self.seeZoneOnGround.internal = "SEEZONE";
    -- self.seeZoneOnGround:initialise();
    -- self.seeZoneOnGround:instantiate();
    -- self.seeZoneOnGround.borderColor = self.buttonBorderColor;
    -- self:addChild(self.seeZoneOnGround);

    self.no = ISButton:new(self:getWidth() - btnWid - 10, self.teleportToZone:getBottom() + 20, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, PVPE_ISPvpZonePanel.onClick);
    self.no.internal = "OK";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);
    self:setHeight(self.no:getBottom() + padBottom)
    self:populateList();
end

function PVPE_ISPvpZonePanel:populateList()
    self.truePvpList:clear();
    for title, zone in pairs(ForcePVPZone.PvpZoneList) do
        local newZone = {};
        newZone.title = zone.title;
        newZone.zone = zone;
        self.truePvpList:addItem(newZone.title, newZone);
    end
end

function PVPE_ISPvpZonePanel:drawList(y, item, alt)
    local a = 0.9;
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end
    self:drawText(item.item.title .. " (x1=" .. item.item.zone.x .. " y1=" .. item.item.zone.y .. " x2=" .. item.item.zone.x2 .. " y2=" .. item.item.zone.y2 .. ")", 10, y + 2, 1, 1, 1, a, self.font);
    self:drawText(item.item.title, 10, y + 2, 1, 1, 1, a, self.font);
--    self:drawText(item.item.zone:getSize() .. "", 100, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function PVPE_ISPvpZonePanel:render()

end

function PVPE_ISPvpZonePanel:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_ForcePvpZone_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_ForcePvpZone_Title")) / 2), z, 1,1,1,1, UIFont.Medium);
end

function PVPE_ISPvpZonePanel:updateButtons()
end

function PVPE_ISPvpZonePanel:render()
    self:updateButtons();
    
    self.removeZone.enable = false;
    self.teleportToZone.enable = false;
    if self.truePvpList.selected > 0 then
        self.removeZone.enable = true;
        self.teleportToZone.enable = true;
        self.selectedZone = self.truePvpList.items[self.truePvpList.selected].item.zone;
    else
        self.selectedZone = nil;
    end
end

function PVPE_ISPvpZonePanel:onClick(button)
    if button.internal == "OK" then
        self:setVisible(false);
        self:removeFromUIManager();
        self.player:setSeeNonPvpZone(false);
    end
    if button.internal == "REMOVEZONE" then
        local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_PvpZone_RemoveConfirm", self.selectedZone.title), true, nil, PVPE_ISPvpZonePanel.onRemoveZone);
        modal:initialise()
        modal:addToUIManager()
        modal.ui = self;
        modal.selectedZone = self.selectedZone;
        modal.moveWithMouse = true;
    end
    if button.internal == "ADDZONE" then
        local addPvpZone = PVPE_ISAddNonPvpZoneUI:new(10,10, 400, 350, self.player);
        addPvpZone:initialise()
        addPvpZone:addToUIManager()
        addPvpZone.parentUI = self;
        self:setVisible(false);
        if not self.player:isInvisible() then
            SendCommandToServer("/invisible");
        end
    end
    -- if button.internal == "SEEZONE" then
        -- self.player:setSeeNonPvpZone(not self.player:isSeeNonPvpZone());
    -- end
    if button.internal == "TELEPORTTOZONE" then
        SendCommandToServer("/teleportto " .. self.selectedZone.x .. "," .. self.selectedZone.y .. ",0");
    end
end

function PVPE_ISPvpZonePanel:onRemoveZone(button)
    if button.internal == "YES" then
        ForcePVPZone:removePvpZone(button.parent.selectedZone.title)
        button.parent.ui:populateList();
    end
end

--************************************************************************--
--** PVPE_ISPvpZonePanel:new
--**
--************************************************************************--
function PVPE_ISPvpZonePanel:new(x, y, width, height, player)
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
    PVPE_ISPvpZonePanel.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    return o;
end
