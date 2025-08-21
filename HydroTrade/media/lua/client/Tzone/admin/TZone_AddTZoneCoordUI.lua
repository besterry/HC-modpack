-- Панель "Добавить зону"

require "TZone_ForceTZone.lua"

TZone_AddTZoneCoordUI = ISPanel:derive("TZone_AddTZoneCoordUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function TZone_AddTZoneCoordUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2
    local padBottom = 10

    self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, TZone_AddTZoneCoordUI.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PvpZone_AddZone"), self, TZone_AddTZoneCoordUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    local entryHeight = FONT_HGT_SMALL + 4;
    
    --Поле ввода названия зоны
    self.titleEntry = ISTextEntryBox:new("", 10, 10, 150, entryHeight);
    self.titleEntry:initialise();
    self.titleEntry:instantiate();
    self:addChild(self.titleEntry);
    
    --Поле ввода координаты x1 (min)
    self.x1Entry = ISTextEntryBox:new("", 10, 10, 80, entryHeight);
    self.x1Entry:initialise();
    self.x1Entry:instantiate();
    self:addChild(self.x1Entry);
    
    --Поле ввода координаты x2 (max)
    self.x2Entry = ISTextEntryBox:new("", 10, 10, 80, entryHeight);
    self.x2Entry:initialise();
    self.x2Entry:instantiate();
    self:addChild(self.x2Entry);
    
    --Поле ввода координаты y1 (min)
    self.y1Entry = ISTextEntryBox:new("", 10, 10, 80, entryHeight);
    self.y1Entry:initialise();
    self.y1Entry:instantiate();
    self:addChild(self.y1Entry);
    
    --Поле ввода координаты y2 (max)
    self.y2Entry = ISTextEntryBox:new("", 10, 10, 80, entryHeight);
    self.y2Entry:initialise();
    self.y2Entry:instantiate();
    self:addChild(self.y2Entry);

end

function TZone_AddTZoneCoordUI:prerender()
    local z = 15;
    local x = 10;
    local entryWidth = 80;
    local entryHeight = FONT_HGT_SMALL + 4;
    
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_PvpZone_AddZone"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_PvpZone_AddZone")) / 2), z, 1,1,1,1, UIFont.Medium);
    
    -- Название зоны
    z = z + FONT_HGT_MEDIUM + 15;
    self:drawText(getText("IGUI_PvpZone_ZoneName"), x, z + 2, 1,1,1,1, UIFont.Small);
    self.titleEntry:setY(z);
    self.titleEntry:setX(x + 120);
    self.titleEntry:setWidth(150);
    self.titleEntry:setHeight(entryHeight);
    
    -- Координаты в две колонки
    z = z + entryHeight + 20;
    
    -- Заголовки колонок
    self:drawText("Start X (min):", x, z, 1,1,1,1, UIFont.Small);
    self:drawText("End X (max):", x + 140, z, 1,1,1,1, UIFont.Small);
    z = z + FONT_HGT_SMALL + 5;
    
    -- X min и X max
    self.x1Entry:setX(x);
    self.x1Entry:setY(z);
    self.x1Entry:setWidth(entryWidth);
    self.x1Entry:setHeight(entryHeight);
    
    self.x2Entry:setX(x + 140);
    self.x2Entry:setY(z);
    self.x2Entry:setWidth(entryWidth);
    self.x2Entry:setHeight(entryHeight);
    
    z = z + entryHeight + 15;
    
    -- Заголовки второй строки
    self:drawText("Start Y (min):", x, z, 1,1,1,1, UIFont.Small);
    self:drawText("End Y (max):", x + 140, z, 1,1,1,1, UIFont.Small);
    z = z + FONT_HGT_SMALL + 5;
    
    -- Y min и Y max
    self.y1Entry:setX(x);
    self.y1Entry:setY(z);
    self.y1Entry:setWidth(entryWidth);
    self.y1Entry:setHeight(entryHeight);
    
    self.y2Entry:setX(x + 140);
    self.y2Entry:setY(z);
    self.y2Entry:setWidth(entryWidth);
    self.y2Entry:setHeight(entryHeight);

    self:updateButtons();
end

function TZone_AddTZoneCoordUI:updateButtons()
    self.ok.enable = 
        (tonumber(self.x1Entry:getInternalText()) ~= 0 and tonumber(self.x1Entry:getInternalText()) ~= nil) 
    and (tonumber(self.x2Entry:getInternalText()) ~= 0 and tonumber(self.x2Entry:getInternalText()) ~= nil) 
    and (tonumber(self.y1Entry:getInternalText()) ~= 0 and tonumber(self.y1Entry:getInternalText()) ~= nil)
    and (tonumber(self.y2Entry:getInternalText()) ~= 0 and tonumber(self.y2Entry:getInternalText()) ~= nil);
end

function TZone_AddTZoneCoordUI:onClick(button)
    if button.internal == "OK" then
        local doneIt = true;
        --Проверка не используется ли заданное название зоны
        -- if ForcePVPZone:getZoneByTitle(self.titleEntry:getInternalText()) then
        --     doneIt = false;
        --     local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_PvpZone_ZoneAlreadyExistTitle", self.selectedPlayer), false, nil, nil);
        --     modal:initialise()
        --     modal:addToUIManager()
        --     modal.moveWithMouse = true;
        -- end
        if doneIt then
            local title = self.titleEntry:getInternalText() -- считываем название зоны
            local x = tonumber(self.x1Entry:getInternalText()) or 0 -- считываем координату x1
            local x2 = tonumber(self.x2Entry:getInternalText()) or 0 -- считываем координату x2
            local y = tonumber(self.y1Entry:getInternalText()) or 0 -- считываем координату y1
            local y2 = tonumber(self.y2Entry:getInternalText()) or 0 -- считываем координату y2
            if x~=0 and y~=0 and x2~=0 and y2~=0 and x<x2 and y<y2 and x~=x2 and y~=y2 then -- проверяем координаты
                -- ForcePVPZone:addPvpZone(title, x, y, x2, y2) -- добавляем зону
                sendClientCommand("TZone", "addTZone", {title, x, y, x2, y2})
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
function TZone_AddTZoneCoordUI:new(x, y, width, height, player)
    local o = {}
    -- Компактные размеры окна
    width = width;
    height = height;
    x = x
    y = y
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
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
    TZone_AddTZoneCoordUI.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    return o;
end
