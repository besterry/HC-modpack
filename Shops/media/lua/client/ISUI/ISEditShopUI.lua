-- Панель "Добавить зону"

require "PVPE_ForcePVPZone.lua"

--***********************************************************
--**                  ROBERT JOHNSON                       **
--**                 edited by FD                      **
--***********************************************************

ISEditShopUI = ISPanel:derive("ISEditShopUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISEditShopUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2
    local padBottom = 10

    self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISEditShopUI.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PvpZone_AddZone"), self, ISEditShopUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    local title = "Zone #" .. ForcePVPZone.listSize;
    local titlexmin = "X min";
    local titleymax = "Y max";
    local titleymin = "Y min";
    local titlexmax = "X max";
    --Поле ввода названия зоны
    self.titleEntry = ISTextEntryBox:new(title, 10, 10, 100, FONT_HGT_SMALL + 2 * 2);
    self.titleEntry:initialise();
    self.titleEntry:instantiate();
    self:addChild(self.titleEntry);
    --Поле ввода координаты x1
    self.x1Entry = ISTextEntryBox:new(titlexmin, 10, 10, 100, FONT_HGT_SMALL + 2 * 2);
    self.x1Entry:initialise();
    self.x1Entry:instantiate();
    self:addChild(self.x1Entry);
    --Поле ввода координаты y2
    self.y2Entry = ISTextEntryBox:new(titleymax, 10, 10, 100, FONT_HGT_SMALL + 2 * 2);
    self.y2Entry:initialise();
    self.y2Entry:instantiate();
    self:addChild(self.y2Entry);
     --Поле ввода координаты x2
     self.x2Entry = ISTextEntryBox:new(titlexmax, 10, 10, 100, FONT_HGT_SMALL + 2 * 2);
     self.x2Entry:initialise();
     self.x2Entry:instantiate();
     self:addChild(self.x2Entry);
     --Поле ввода координаты y1
     self.y1Entry = ISTextEntryBox:new(titleymin, 10, 10, 100, FONT_HGT_SMALL + 2 * 2);
     self.y1Entry:initialise();
     self.y1Entry:instantiate();
     self:addChild(self.y1Entry);

end

function ISEditShopUI:prerender()
    local z = 20;
    local splitPoint = 200;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_PvpZone_AddZone"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_PvpZone_AddZone")) / 2), z, 1,1,1,1, UIFont.Medium);
    --Название зоны
    z = z + FONT_HGT_MEDIUM + 20;
    self:drawText(getText("IGUI_PvpZone_ZoneName"), x, z + 2,1,1,1,1,UIFont.Small);
    self.titleEntry:setY(z);
    self.titleEntry:setX(splitPoint);
    z = z + FONT_HGT_SMALL + 35;
    --Координата x1 (min)
    self:drawText(getText("IGUI_PvpZone_ZoneCoordx1"), x, z + 2,1,1,1,1,UIFont.Small);
    self.x1Entry:setY(z);
    self.x1Entry:setX(splitPoint);
    z = z + FONT_HGT_SMALL + 15;
    --Координата у2 (max)
    self:drawText(getText("IGUI_PvpZone_ZoneCoordy2"), x, z + 2,1,1,1,1,UIFont.Small);
    self.y2Entry:setY(z);
    self.y2Entry:setX(splitPoint);
    z = z + FONT_HGT_SMALL + 15;
    --Координата x2 (max)
    self:drawText(getText("IGUI_PvpZone_ZoneCoordx2"), x, z + 2,1,1,1,1,UIFont.Small);
    self.x2Entry:setY(z);
    self.x2Entry:setX(splitPoint);
    z = z + FONT_HGT_SMALL + 15;
    --Координата у1 (min)
    self:drawText(getText("IGUI_PvpZone_ZoneCoordy1"), x, z + 2,1,1,1,1,UIFont.Small);
    self.y1Entry:setY(z);
    self.y1Entry:setX(splitPoint);
    z = z + FONT_HGT_SMALL + 15;

    self:updateButtons();
end

function ISEditShopUI:updateButtons()
    self.ok.enable = 
        (tonumber(self.x1Entry:getInternalText()) ~= 0 and tonumber(self.x1Entry:getInternalText()) ~= nil) 
    and (tonumber(self.x2Entry:getInternalText()) ~= 0 and tonumber(self.x2Entry:getInternalText()) ~= nil) 
    and (tonumber(self.y1Entry:getInternalText()) ~= 0 and tonumber(self.y1Entry:getInternalText()) ~= nil)
    and (tonumber(self.y2Entry:getInternalText()) ~= 0 and tonumber(self.y2Entry:getInternalText()) ~= nil);
end

function ISEditShopUI:onClick(button)
    if button.internal == "OK" then
        local doneIt = true;
        --Проверка не используется ли заданное название зоны
        if ForcePVPZone:getZoneByTitle(self.titleEntry:getInternalText()) then
            doneIt = false;
            local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_PvpZone_ZoneAlreadyExistTitle", self.selectedPlayer), false, nil, nil);
            modal:initialise()
            modal:addToUIManager()
            modal.moveWithMouse = true;
        end
        if doneIt then
            local title = self.titleEntry:getInternalText()
            local x = tonumber(self.x1Entry:getInternalText()) or 0
            local y2 = tonumber(self.y2Entry:getInternalText()) or 0
            local x2 = tonumber(self.x2Entry:getInternalText()) or 0
            local y = tonumber(self.y1Entry:getInternalText()) or 0
            if x~=0 and y~=0 and x2~=0 and y2~=0 and x<x2 and y<y2 and x~=x2 and y~=y2 then
                ForcePVPZone:addPvpZone(title, x, y, x2, y2)           
                self:setVisible(false);
                self:removeFromUIManager();    
                self.parentUI:populateList();
                self.parentUI:setVisible(true);
                self.player:setSeeNonPvpZone(false); 
            else 
                local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_CoordIncorrectly", self.selectedPlayer), false, nil, nil);
                modal:initialise()
                modal:addToUIManager()
                modal.moveWithMouse = true;
            end
        else
            return;
        end
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        self.parentUI:populateList();
        self.parentUI:setVisible(true);
        self.player:setSeeNonPvpZone(false);
    end
end

--Создание окна
function ISEditShopUI:new(x, y, width, height, player)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    -- if y == 0 then
    --     o.y = o:getMouseY() - (height / 2)
    --     o:setY(o.y)
    -- end
    -- if x == 0 then
    --     o.x = o:getMouseX() - (width / 2)
    --     o:setX(o.x)
    -- end
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.player = player;
    o.startingX = player:getX();
    o.startingY = player:getY();
    o.endX = player:getX();
    o.endY = player:getY();
    player:setSeeNonPvpZone(false);
    o.moveWithMouse = true;
    ISEditShopUI.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    return o;
end
