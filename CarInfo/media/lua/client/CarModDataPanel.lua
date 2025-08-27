require "ISUI/ISPanel"

ModDataDebugPanel = ISPanel:derive("ModDataDebugPanel");
ModDataDebugPanel.instance = nil;
ModDataDebugPanel.modDataList = {}

local function roundstring(_val)
    return tostring(ISDebugUtils.roundNum(_val,2));
end

function ModDataDebugPanel.OnOpenPanel(obj)
    if ModDataDebugPanel.instance==nil then
        ModDataDebugPanel.modDataList = {}
        table.insert(ModDataDebugPanel.modDataList, obj)

        ModDataDebugPanel.instance = ModDataDebugPanel:new (100, 100, 700, 500, "Car Info");
        ModDataDebugPanel.instance:initialise();
        ModDataDebugPanel.instance:instantiate();
    else
        table.insert(ModDataDebugPanel.modDataList, obj)
    end

    ModDataDebugPanel.instance:addToUIManager();
    ModDataDebugPanel.instance:setVisible(true);
    ModDataDebugPanel.instance:onClickRefresh()

    return ModDataDebugPanel.instance;
end

function ModDataDebugPanel:initialise()
    ISPanel.initialise(self);
    self.firstTableData = false;
end

function ModDataDebugPanel:createChildren()
    ISPanel.createChildren(self);

    ISDebugUtils.addLabel(self, {}, 10, 20, "Car Info", UIFont.Medium, true)

    -- Компактные кнопки переключения
    self.playerLogButton = ISButton:new(10, 40, 90, 18, "Player Log", self, ModDataDebugPanel.onClickPlayerLog)
    self:addChild(self.playerLogButton)
    
    self.vehicleDataButton = ISButton:new(110, 40, 90, 18, "Vehicle Data", self, ModDataDebugPanel.onClickVehicleData)
    self:addChild(self.vehicleDataButton)

    -- Компактные таблицы
    self.tableNamesList = ISScrollingListBox:new(10, 65, 180, self.height - 110);
    self.tableNamesList:initialise();
    self.tableNamesList:instantiate();
    self.tableNamesList.itemheight = 18;
    self.tableNamesList.selected = 0;
    self.tableNamesList.joypadParent = self;
    self.tableNamesList.font = UIFont.NewSmall;
    self.tableNamesList.doDrawItem = self.drawTableNameList;
    self.tableNamesList.drawBorder = true;
    self.tableNamesList.onmousedown = ModDataDebugPanel.OnTableNamesListMouseDown;
    self.tableNamesList.target = self;
    self:addChild(self.tableNamesList);

    -- Правая таблица для основного контента
    self.infoList = ISScrollingListBox:new(200, 65, 490, self.height - 110);
    self.infoList:initialise();
    self.infoList:instantiate();
    self.infoList.itemheight = 20; -- Увеличиваем для лучшей читаемости
    self.infoList.selected = 0;
    self.infoList.joypadParent = self;
    self.infoList.font = UIFont.NewSmall;
    self.infoList.doDrawItem = self.drawInfoList;
    self.infoList.drawBorder = true;
    self:addChild(self.infoList);

    -- Кнопки управления
    local y, obj = ISDebugUtils.addButton(self,"close",self.width-180,self.height-30,160,22,getText("IGUI_CraftUI_Close"),ModDataDebugPanel.onClickClose);
    y, obj = ISDebugUtils.addButton(self,"refresh",self.width-360,self.height-30,160,22,getText("IGUI_Refresh"),ModDataDebugPanel.onClickRefresh);

    -- Устанавливаем активный раздел по умолчанию
    self.currentSection = "playerLog"
    self:updateButtonStates()
    self:populateList();
end

function ModDataDebugPanel:onClickClose()
    self:close();
end

function ModDataDebugPanel:onClickRefresh()
    self:populateList();
end

function ModDataDebugPanel:OnTableNamesListMouseDown(item)
    self:populateInfoList(self.tableNamesList.items[self.tableNamesList.selected].item);
end

function ModDataDebugPanel:populateList()
    self.tableNamesList:clear();

    if #ModDataDebugPanel.modDataList == 0 then
        self:populateInfoList(nil);
        return;
    end

    for i, obj in ipairs(ModDataDebugPanel.modDataList) do
        -- Создаем читаемое название для отображения
        local displayName = "Vehicle " .. i
        if obj then
            local script = obj:getScript()
            if script then
                displayName = script:getName()
                
                -- Добавляем ID из moddata
                local modData = obj:getModData()
                if modData and modData.sqlId then
                    displayName = displayName .. " (ID: " .. modData.sqlId .. ")"
                end
            end
        end
        
        self.tableNamesList:addItem(displayName, obj);
    end

    self.firstTableData=ModDataDebugPanel.modDataList[1];

    self:populateInfoList(self.firstTableData);
end

function ModDataDebugPanel:onClickPlayerLog()
    self.currentSection = "playerLog"
    self:updateButtonStates()
    self:populateInfoList(self.firstTableData)
end

function ModDataDebugPanel:onClickVehicleData()
    self.currentSection = "vehicleData"
    self:updateButtonStates()
    self:populateInfoList(self.firstTableData)
end

function ModDataDebugPanel:updateButtonStates()
    if self.currentSection == "playerLog" then
        self.playerLogButton.backgroundColor = {r=0.3, g=0.7, b=0.3, a=1}
        self.vehicleDataButton.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
    else
        self.playerLogButton.backgroundColor = {r=0.3, g=0.3, b=0.3, a=1}
        self.vehicleDataButton.backgroundColor = {r=0.3, g=0.7, b=0.3, a=1}
    end
end

function ModDataDebugPanel:drawTableNameList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    -- Получаем читаемое название автомобиля
    local vehicleName = "Unknown Vehicle"
    if item.item and item.item.getScript then
        local script = item.item:getScript()
        if script then
            vehicleName = script:getName()
        end
    end
    
    -- Добавляем номерной знак из moddata
    if item.item then
        local modData = item.item:getModData()
        if modData and modData.sqlId then
            vehicleName = vehicleName .. " (ID: " .. modData.sqlId .. ")"
        end
    end

    self:drawText(vehicleName, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ModDataDebugPanel:formatVal(_value, _func, _func2)
    return _func2 and (_func2(_func(_value))) or (_func(_value));
end

function ModDataDebugPanel:parseTable(_t, _ident)
    if not _ident then
        _ident = "";
    end
    
    -- Специальная обработка для playerLog
    if _ident == "" and _t.playerLog then
        self.infoList:addItem("=== Player Log ===", nil);
        self:parsePlayerLog(_t.playerLog);
        return;
    end
    
    local s;
    for k,v in pairs(_t) do
        if k == "playerLog" then
            -- Пропускаем playerLog, так как обрабатываем отдельно
        elseif type(v)=="table" then
            s = tostring(_ident).."["..tostring(k).."] -> ";
            self.infoList:addItem(s, nil);
            self:parseTable(v, _ident.."    ");
        else
            s = tostring(_ident).."["..tostring(k).."] -> "..tostring(v);
            self.infoList:addItem(s, nil);
        end
    end
end

function ModDataDebugPanel:parsePlayerLog(playerLog)
    if not playerLog or #playerLog == 0 then
        self.infoList:addItem("No data about players", nil);
        return;
    end
    
    -- Компактный заголовок
    self.infoList:addItem("=== Player Log ===", nil);
    
    for i, player in ipairs(playerLog) do
        local statusIcon = player.status == "active" and ">" or "X"
        
        -- Первая строка: только номер и ник (главная информация)
        local mainLine = string.format("[%d] %s", i, player.name)
        self.infoList:addItem(mainLine, nil);
        
        -- Вторая строка: время, координаты и дистанция
        local secondLine = string.format("    %s Enter: %s | Exit: %s", 
            statusIcon,
            player.timeEnter or "N/A", 
            player.timeExit or "N/A")
        
        -- Добавляем координаты входа
        -- if player.enterX and player.enterY then
        --     secondLine = secondLine .. string.format(" | Enter: (%d, %d)", player.enterX, player.enterY)
        -- end
        
        -- Добавляем координаты выхода
        -- if player.exitX and player.exitY then
        --     secondLine = secondLine .. string.format(" | Exit: (%d, %d)", player.exitX, player.exitY)
        -- end
        
        -- Добавляем дистанцию только если она есть
        if player.distance then
            secondLine = secondLine .. string.format(" | Distance: %d tiles", player.distance)
        end
        
        self.infoList:addItem(secondLine, nil);
    end
end

function ModDataDebugPanel:populateInfoList(obj)
    self.infoList:clear();

    if not obj then
        self.infoList:addItem("No vehicle selected.", nil);
        return;
    end

    local modData = obj:getModData() or {}

    if self.currentSection == "playerLog" then
        -- Показываем только Player Log
        if modData.playerLog then
            self:parsePlayerLog(modData.playerLog);
        else
            self.infoList:addItem("No player log data found.", nil);
        end
    else
        -- Показываем все данные моддаты кроме playerLog
        if modData then
            self.infoList:addItem("=== Vehicle ModData ===", nil);
            self.infoList:addItem("", nil);
            
            for k, v in pairs(modData) do
                if k ~= "playerLog" then -- Исключаем playerLog из общего списка
                    if type(v) == "table" then
                        self.infoList:addItem(string.format("[%s] ->", tostring(k)), nil);
                        self:parseTable(v, "    ");
                    else
                        self.infoList:addItem(string.format("[%s] -> %s", tostring(k), tostring(v)), nil);
                    end
                end
            end
        else
            self.infoList:addItem("No mod data found.", nil);
        end
    end
end


function ModDataDebugPanel:drawInfoList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ModDataDebugPanel:prerender()
    ISPanel.prerender(self);
    --self:populateList();
end

function ModDataDebugPanel:update()
    ISPanel.update(self);
end

function ModDataDebugPanel:close()
    self:setVisible(false);
    self:removeFromUIManager();
    ModDataDebugPanel.instance = nil
end

function ModDataDebugPanel:new(x, y, width, height, title)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o.panelTitle = title;
    ISDebugMenu.RegisterClass(self);
    return o;
end
