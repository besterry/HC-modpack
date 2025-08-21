-- require "loadzones.lua"
TZonePanel = ISPanel:derive("TZonePanel");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small) -- высота шрифта
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium) -- высота шрифта

-- Функция для получения зон из ModData
local function getTZonesFromModData()
    local tzones = ModData.get("TZone")
    if not tzones then
        return {}
    end
    return tzones -- возвращаем все зоны без фильтрации
end

function TZonePanel:initialise()
    ISPanel.initialise(self);
    
    -- Запрашиваем данные о зонах
    ModData.request("TZone")
    
    local btnWid = 100 -- ширина кнопки
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) -- высота кнопки
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2 -- высота кнопки
    local padBottom = 10 -- отступ снизу

    local listY = 20 + FONT_HGT_MEDIUM + 20 -- координата y списка
    self.TZoneList = ISScrollingListBox:new(10, listY, self.width - 20, (FONT_HGT_SMALL + 2 * 2) * 16); -- создаем список
    self.TZoneList:initialise(); -- инициализируем список
    self.TZoneList:instantiate(); -- инициализируем список
    self.TZoneList.itemheight = FONT_HGT_SMALL + 2 * 2; -- высота элемента списка
    self.TZoneList.selected = 0; -- выбранный элемент
    self.TZoneList.joypadParent = self; -- родительский элемент
    self.TZoneList.font = UIFont.NewSmall; -- шрифт
    self.TZoneList.doDrawItem = self.drawList; -- функция для рисования элемента списка
    self.TZoneList.drawBorder = true; -- рисовать границу
    self:addChild(self.TZoneList); -- добавляем список на панель

    self.removeZone = ISButton:new(self.TZoneList.x + self.TZoneList.width - 90, self.TZoneList.y + self.TZoneList.height + 5, 70, btnHgt2, getText("IGUI_PvpZone_RemoveZone"), self, TZonePanel.onClick); -- создаем кнопку для удаления зоны
    self.removeZone.internal = "REMOVEZONE"; -- внутреннее имя кнопки
    self.removeZone:initialise(); -- инициализируем кнопку
    self.removeZone:instantiate(); -- инициализируем кнопку
    self.removeZone.borderColor = self.buttonBorderColor; -- цвет границы кнопки
    self:addChild(self.removeZone); -- добавляем кнопку на панель
    self.removeZone.enable = false; -- кнопка не активна

    self.teleportToZone = ISButton:new(self.TZoneList.x + self.TZoneList.width - 70, self.removeZone.y + btnHgt2 + 5, 70, btnHgt2, getText("IGUI_PvpZone_TeleportToZone"), self, TZonePanel.onClick); -- создаем кнопку для телепорта к зоне
    self.teleportToZone:setX(self.TZoneList.x + self.TZoneList.width - self.teleportToZone.width) -- устанавливаем координату x кнопки
    self.teleportToZone.internal = "TELEPORTTOZONE"; -- внутреннее имя кнопки
    self.teleportToZone:initialise(); -- инициализируем кнопку
    self.teleportToZone:instantiate(); -- инициализируем кнопку
    self.teleportToZone.borderColor = self.buttonBorderColor; -- цвет границы кнопки
    self:addChild(self.teleportToZone); -- добавляем кнопку на панель
    self.teleportToZone.enable = false; -- кнопка не активна

    self.addZone = ISButton:new(self.TZoneList.x, self.TZoneList.y + self.TZoneList.height + 5, 70, btnHgt2, getText("IGUI_ToggleTZone"), self, TZonePanel.onClick); -- создаем кнопку для добавления зоны
    self.addZone.internal = "ADDZONE"; -- внутреннее имя кнопки
    self.addZone:initialise(); -- инициализируем кнопку
    self.addZone:instantiate(); -- инициализируем кнопку
    self.addZone.borderColor = self.buttonBorderColor; -- цвет границы кнопки
    self:addChild(self.addZone); -- добавляем кнопку на панель

    self.addZoneCoord = ISButton:new(self.TZoneList.x, self.TZoneList.y + self.TZoneList.height +self.addZone.height + 10, 70, btnHgt2, getText("IGUI_PvpZone_AddZoneCoord"), self, TZonePanel.onClick); -- создаем кнопку для добавления координат зоны
    self.addZoneCoord.internal = "ADDZONECOORD"; -- внутреннее имя кнопки
    self.addZoneCoord:initialise(); -- инициализируем кнопку
    self.addZoneCoord:instantiate(); -- инициализируем кнопку
    self.addZoneCoord.borderColor = self.buttonBorderColor; -- цвет границы кнопки
    self:addChild(self.addZoneCoord); -- добавляем кнопку на панель

    self.no = ISButton:new(self:getWidth() - btnWid - 10, self.teleportToZone:getBottom() + 20, btnWid, btnHgt, getText("IGUI_CraftUI_Close"), self, TZonePanel.onClick); -- создаем кнопку для закрытия панели
    self.no.internal = "OK"; -- внутреннее имя кнопки
    self.no:initialise(); -- инициализируем кнопку
    self.no:instantiate(); -- инициализируем кнопку
    self.no.borderColor = {r=1, g=1, b=1, a=0.1}; -- цвет границы кнопки
    self:addChild(self.no); -- добавляем кнопку на панель
    self:setHeight(self.no:getBottom() + padBottom) -- устанавливаем высоту панели
    self:populateList(); -- заполняем список
end

function TZonePanel:populateList() -- заполняем список
    self.TZoneList:clear(); -- очищаем список
    local tzones = getTZonesFromModData()
    for title, zone in pairs(tzones) do -- перебираем все зоны
        local newZone = {}; -- создаем новый элемент
        newZone.title = title; -- заполняем элемент
        newZone.zone = zone; -- заполняем элемент
        self.TZoneList:addItem(newZone.title, newZone); -- добавляем элемент в список
    end
end

function TZonePanel:drawList(y, item, alt) -- рисуем элемент списка
    local a = 0.9; -- прозрачность
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b); -- рисуем границу
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end
    
    -- Определяем цвет текста в зависимости от активности зоны
    local textColor = {r = 1, g = 1, b = 1} -- белый по умолчанию
    local statusText = ""
    
    if item.item.zone.enable then
        textColor = {r = 0.3, g = 1, b = 0.3} -- зеленый для активных
        statusText = " [ACTIVE]"
    else
        textColor = {r = 1, g = 0.3, b = 0.3} -- красный для неактивных
        statusText = " [INACTIVE]"
    end
    
    self:drawText(item.item.title .. " (" .. item.item.zone.x .. "/" .. item.item.zone.y .. " - " .. item.item.zone.x2 .. "/" .. item.item.zone.y2 .. ")" .. statusText, 10, y + 2, textColor.r, textColor.g, textColor.b, a, self.font);
    return y + self.itemheight;
end

function TZonePanel:prerender() --Отрисовка заголовка
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_TZone_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_TZone_Title")) / 2), z, 1,1,1,1, UIFont.Medium);
end

function TZonePanel:render() -- рисуем панель
    self.removeZone.enable = false;
    self.teleportToZone.enable = false;
    if self.TZoneList.selected > 0 and self.TZoneList.items[self.TZoneList.selected] then
        self.removeZone.enable = true;
        self.teleportToZone.enable = true;
        self.selectedZone = self.TZoneList.items[self.TZoneList.selected].item;
    else
        self.selectedZone = nil;
    end
end

function TZonePanel:onClick(button)
    if button.internal == "OK" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
    if button.internal == "REMOVEZONE" then
        local modal = ISModalDialog:new(0,0, 350, 150, getText("IGUI_PvpZone_RemoveConfirm", self.selectedZone.title), true, nil, TZonePanel.onRemoveZone);
        modal:initialise()
        modal:addToUIManager()
        modal.ui = self;
        modal.selectedZone = self.selectedZone;
        modal.moveWithMouse = true;
    end
    if button.internal == "ADDZONE" then -- добавление зоны
        sendClientCommand("TZone", "toggleTZone", {self.selectedZone.title})
    end
    if button.internal == "ADDZONECOORD" then -- добавление зоны по координатам
        local addTZone = TZone_AddTZoneCoordUI:new(self.x, self.y, 300, 250, self.player);
        addTZone:initialise()
        addTZone:addToUIManager()
        addTZone.parentUI = self;
        self:setVisible(false);
    end
    if button.internal == "TELEPORTTOZONE" then
        SendCommandToServer("/teleportto " .. self.selectedZone.zone.x .. "," .. self.selectedZone.zone.y .. ",0");
    end
end

function TZonePanel:onRemoveZone(button)
    if button.internal == "YES" then
        sendClientCommand("TZone", "removeTZone", {button.parent.selectedZone.title})
    end
end

function TZonePanel:new(x, y, width, height, player)
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
    TZonePanel.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    
    -- Добавляем обработчик события получения ModData
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if key == "TZone" and o.TZoneList then
            o:populateList()
        end
    end)
    
    return o;
end
