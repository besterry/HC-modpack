require "ISUI/ISPanel"
require "ISUI/ISModalDialog"

GlobalModDataDebug = ISPanel:derive("GlobalModDataDebug");
GlobalModDataDebug.instance = nil;

local MOD_NAME = "HT_GMD"
local serverModData = {}

local function roundstring(_val)
    return tostring(ISDebugUtils.roundNum(_val,2));
end

function GlobalModDataDebug.OnOpenPanel()
    if GlobalModDataDebug.instance==nil then
        GlobalModDataDebug.instance = GlobalModDataDebug:new (100, 100, 840, 600, "Global ModData Debugger");
        GlobalModDataDebug.instance:initialise();
        GlobalModDataDebug.instance:instantiate();
    end

    GlobalModDataDebug.instance:addToUIManager();
    GlobalModDataDebug.instance:setVisible(true);
    GlobalModDataDebug.instance:requestServerData();

    return GlobalModDataDebug.instance;
end

function GlobalModDataDebug:initialise()
    ISPanel.initialise(self);

    self.firstTableName = false;
end

function GlobalModDataDebug:createChildren()
    ISPanel.createChildren(self);

    ISDebugUtils.addLabel(self, {}, 10, 20, "Global ModData Debugger", UIFont.Medium, true)

    self.tableNamesList = ISScrollingListBox:new(10, 50, 200, self.height - 100);
    self.tableNamesList:initialise();
    self.tableNamesList:instantiate();
    self.tableNamesList.itemheight = 22;
    self.tableNamesList.selected = 0;
    self.tableNamesList.joypadParent = self;
    self.tableNamesList.font = UIFont.NewSmall;
    self.tableNamesList.doDrawItem = self.drawTableNameList;
    self.tableNamesList.drawBorder = true;
    self.tableNamesList.onmousedown = GlobalModDataDebug.OnTableNamesListMouseDown;
    self.tableNamesList.target = self;
    self:addChild(self.tableNamesList);

    self.infoList = ISScrollingListBox:new(220, 50, 600, self.height - 100);
    self.infoList:initialise();
    self.infoList:instantiate();
    self.infoList.itemheight = 22;
    self.infoList.selected = 0;
    self.infoList.joypadParent = self;
    self.infoList.font = UIFont.NewSmall;
    self.infoList.doDrawItem = self.drawInfoList;
    self.infoList.drawBorder = true;
    self:addChild(self.infoList);

    local y, obj = ISDebugUtils.addButton(self,"close",self.width-200,self.height-40,180,20,getText("IGUI_CraftUI_Close"),GlobalModDataDebug.onClickClose);
    y, obj = ISDebugUtils.addButton(self,"refresh",self.width-400,self.height-40,180,20,"Refresh",GlobalModDataDebug.onClickRefresh);
    y, obj = ISDebugUtils.addButton(self,"deleteTable",self.width-600,self.height-40,180,20,"Delete Table",GlobalModDataDebug.onClickDeleteTable);
    y, obj = ISDebugUtils.addButton(self,"deleteKey",self.width-800,self.height-40,180,20,"Delete Key",GlobalModDataDebug.onClickDeleteKey);

    self:populateList();
end

function GlobalModDataDebug:onClickClose()
    self:close();
end

function GlobalModDataDebug:onClickRefresh()
    self:requestServerData();
end

function GlobalModDataDebug:setUpdateTime(time)
    self.updateTime = time
end

function GlobalModDataDebug:onClickDeleteTable()
    local selectedIndex = self.tableNamesList.selected
    local selectedRow = selectedIndex and self.tableNamesList.items and self.tableNamesList.items[selectedIndex] or nil
    local selectedTable = selectedRow and selectedRow.item or nil
    if not selectedTable then
        -- print("No table selected")
        return
    end
    
    -- print("Delete table clicked for: " .. selectedTable)
    
    local function onConfirmDeleteTableCb(target, button)
        if button.internal == "YES" then
            sendClientCommand(getPlayer(), MOD_NAME, "deleteTable", { name = selectedTable })
            target:requestServerData()
        end
    end
    
    local modal = ISModalDialog:new(0, 0, 350, 150, 
        "Are you sure you want to delete the entire table '" .. selectedTable .. "'?\nThis action cannot be undone!", 
        true, self, onConfirmDeleteTableCb)
    modal:initialise()
    modal:addToUIManager()
    modal:setAlwaysOnTop(true)
    modal:setCapture(true)
end

function GlobalModDataDebug:onClickDeleteKey()
    local selectedTableIndex = self.tableNamesList.selected
    local selectedTableRow = selectedTableIndex and self.tableNamesList.items and self.tableNamesList.items[selectedTableIndex] or nil
    local selectedTable = selectedTableRow and selectedTableRow.item or nil
    local selectedInfoIndex = self.infoList.selected
    local selectedInfoRow = selectedInfoIndex and self.infoList.items and self.infoList.items[selectedInfoIndex] or nil
    local selectedText = selectedInfoRow and selectedInfoRow.text or nil
    if not selectedText or not selectedTable then
        -- print("No key or table selected")
        return
    end
    
    -- Извлекаем ключ из строки вида "[key] -> value"
    local key = selectedText:match("%[([^%]]+)%]")
    if not key then
        -- print("Could not extract key from: " .. selectedText)
        return
    end
    
    -- print("Delete key clicked for: " .. key .. " from table: " .. selectedTable)
    
    local function onConfirmDeleteKeyCb(target, button)
        if button.internal == "YES" then
            local numericKey = tonumber(key)
            local keyToSend = numericKey or key
            sendClientCommand(getPlayer(), MOD_NAME, "deleteKey", { tableName = selectedTable, key = keyToSend })
            target:requestServerData()
        end
    end
    
    local modal = ISModalDialog:new(0, 0, 350, 150, 
        "Are you sure you want to delete key '" .. key .. "' from table '" .. selectedTable .. "'?", 
        true, self, onConfirmDeleteKeyCb)
    modal:initialise()
    modal:addToUIManager()
    modal:setAlwaysOnTop(true)
    modal:setCapture(true)
end

function GlobalModDataDebug.onConfirmDeleteTable(tableName, instance)
    -- print("Confirming delete table: " .. tableName)
    sendClientCommand(getPlayer(), MOD_NAME, "deleteTable", { name = tableName })
    -- Обновляем данные через небольшую задержку
    instance:setUpdateTime(100)
end

function GlobalModDataDebug.onConfirmDeleteKey(args, instance)
    -- print("Confirming delete key: " .. args.key .. " from table: " .. args.table)
    sendClientCommand(getPlayer(), MOD_NAME, "deleteKey", { tableName = args.table, key = args.key })
    -- Обновляем данные через небольшую задержку
    instance:setUpdateTime(100)
end

function GlobalModDataDebug:OnTableNamesListMouseDown(item)
    self:populateInfoList(item);
end

function GlobalModDataDebug:populateList()
    self.tableNamesList:clear();

    if not serverModData then
        -- print("populateList: no serverModData, showing 'No data'")
        self:populateInfoList(nil);
        return;
    end

    local tableNames = {}
    for name, info in pairs(serverModData) do
        table.insert(tableNames, name)
    end

    if #tableNames == 0 then
        -- print("populateList: no tables found, showing 'No data'")
        self:populateInfoList(nil);
        return;
    end

    table.sort(tableNames)
    for _, name in ipairs(tableNames) do
        local displayName = name
        if serverModData[name] and serverModData[name].size then
            displayName = name .. " (" .. serverModData[name].size .. ")"
        end
        self.tableNamesList:addItem(displayName, name);
    end

    self.firstTableName = tableNames[1];
    self:populateInfoList(self.firstTableName);
end

function GlobalModDataDebug:drawTableNameList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function GlobalModDataDebug:formatVal(_value, _func, _func2)
    return _func2 and (_func2(_func(_value))) or (_func(_value));
end

function GlobalModDataDebug:parseTable(_t, _ident)
    if not _ident then
        _ident = "";
    end
    local s;
    for k,v in pairs(_t) do
        if type(v)=="table" then
            s = tostring(_ident).."["..tostring(k).."] -> ";
            self.infoList:addItem(s, nil);
            self:parseTable(v, _ident.."    ");
        else
            s = tostring(_ident).."["..tostring(k).."] -> "..tostring(v);
            self.infoList:addItem(s, nil);
        end
    end
end

function GlobalModDataDebug:populateInfoList(_name)
    self.infoList:clear();

    if not _name then
        self.infoList:addItem("No data.", nil);
        return;
    end

    local tableInfo = serverModData[_name];

    if tableInfo then
        if tableInfo.error then
            self.infoList:addItem("Error: " .. tableInfo.error, nil);
            if tableInfo.size then
                self.infoList:addItem("Size: " .. tableInfo.size .. " entries", nil);
            end
        elseif tableInfo.data then
            self:parseTable(tableInfo.data, "");
        else
            self.infoList:addItem("No data available.", nil);
        end
    else
        self.infoList:addItem("Table not found.", nil);
    end
end


function GlobalModDataDebug:drawInfoList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function GlobalModDataDebug:prerender()
    ISPanel.prerender(self);
    --self:populateList();
end

function GlobalModDataDebug:update()
    ISPanel.update(self);
    
    if self.updateTime and self.updateTime > 0 then
        self.updateTime = self.updateTime - 1
        if self.updateTime == 0 then
            self:requestServerData()
        end
    end
end

function GlobalModDataDebug:close()
    self:setVisible(false);
    self:removeFromUIManager();
    GlobalModDataDebug.instance = nil
end

function GlobalModDataDebug:new(x, y, width, height, title)
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

function GlobalModDataDebug:requestServerData()
    sendClientCommand(getPlayer(), MOD_NAME, "get", {});
end

local function onServerCommand(module, command, args)
    if module == MOD_NAME then
        if command == "onGet" then
            -- print("Client received complete ModData")
            if args.error then
                print("Client: Error: " .. args.error)
            end
            serverModData = args.data or {}
            if GlobalModDataDebug.instance then
                GlobalModDataDebug.instance:populateList();
            end
        elseif command == "onDeleteTable" then
            -- print("Client: Delete table result: " .. (args.success and "success" or "failed"))
            if args.message then
                print("Client: " .. args.message)
            end
            if args.success and GlobalModDataDebug.instance then
                GlobalModDataDebug.instance:requestServerData() -- Обновляем список
            end
        elseif command == "onDeleteKey" then
            -- print("Client: Delete key result: " .. (args.success and "success" or "failed"))
            if args.message then
                print("Client: " .. args.message)
            end
            if args.success and GlobalModDataDebug.instance then
                GlobalModDataDebug.instance:requestServerData() -- Обновляем данные
            end
        end
    end
end

Events.OnServerCommand.Add(onServerCommand);


