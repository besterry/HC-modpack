
require "ISUI/ISPanel"

ItemModDataPanel = ISPanel:derive("ItemModDataPanel");
ItemModDataPanel.instance = nil;
ItemModDataPanel.modDataList = {}
local MOD_NAME = "HT_GMD"

local function roundstring(_val)
    return tostring(ISDebugUtils.roundNum(_val,2));
end

function ItemModDataPanel.OnOpenPanel(obj)
    if ItemModDataPanel.instance==nil then
        ItemModDataPanel.modDataList = {}
        table.insert(ItemModDataPanel.modDataList, obj)

        ItemModDataPanel.instance = ItemModDataPanel:new (100, 100, 840, 600, "Car ModData");
        ItemModDataPanel.instance:initialise();
        ItemModDataPanel.instance:instantiate();
    else
        table.insert(ItemModDataPanel.modDataList, obj)
    end

    ItemModDataPanel.instance:addToUIManager();
    ItemModDataPanel.instance:setVisible(true);

    ItemModDataPanel.instance:onClickRefresh()

    return ItemModDataPanel.instance;
end

function ItemModDataPanel:initialise()
    ISPanel.initialise(self);

    self.firstTableData = false;
end

function ItemModDataPanel:createChildren()
    ISPanel.createChildren(self);

    ISDebugUtils.addLabel(self, {}, 10, 20, "ModData", UIFont.Medium, true)

    self.tableNamesList = ISScrollingListBox:new(10, 50, 200, self.height - 100);
    self.tableNamesList:initialise();
    self.tableNamesList:instantiate();
    self.tableNamesList.itemheight = 22;
    self.tableNamesList.selected = 0;
    self.tableNamesList.joypadParent = self;
    self.tableNamesList.font = UIFont.NewSmall;
    self.tableNamesList.doDrawItem = self.drawTableNameList;
    self.tableNamesList.drawBorder = true;
    self.tableNamesList.onmousedown = ItemModDataPanel.OnTableNamesListMouseDown;
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
    self.infoList.onmousedown = ItemModDataPanel.OnInfoListMouseDown;
    self.infoList.target = self;
    self:addChild(self.infoList);

    -- Edit controls
    ISDebugUtils.addLabel(self, {}, 225, self.height-86, "Key", UIFont.Small, true)
    self.keyEntry = ISTextEntryBox:new("", 250, self.height-90, 150, 22)
    self.keyEntry:initialise();
    self:addChild(self.keyEntry)

    ISDebugUtils.addLabel(self, {}, 410, self.height-86, "Value", UIFont.Small, true)
    self.valueEntry = ISTextEntryBox:new("", 455, self.height-90, 180, 22)
    self.valueEntry:initialise();
    self:addChild(self.valueEntry)

    ISDebugUtils.addLabel(self, {}, 655, self.height-86, "Type", UIFont.Small, true)
    self.typeCombo = ISComboBox:new(690, self.height-90, 90, 22, nil, nil)
    self.typeCombo:initialise();
    self.typeCombo:addOption("string")
    self.typeCombo:addOption("number")
    self.typeCombo:addOption("boolean")
    self.typeCombo:addOption("nil")
    self.typeCombo.selected = 1
    self:addChild(self.typeCombo)

    local y, obj = ISDebugUtils.addButton(self,"close",self.width-200,self.height-40,180,20,getText("IGUI_CraftUI_Close"),ItemModDataPanel.onClickClose);
    y, obj = ISDebugUtils.addButton(self,"refresh",self.width-400,self.height-40,180,20,getText("IGUI_Refresh"),ItemModDataPanel.onClickRefresh);
    y, obj = ISDebugUtils.addButton(self,"save",self.width-600,self.height-40,180,20,getText("IGUI_SaveShop"),ItemModDataPanel.onClickSave);
    y, obj = ISDebugUtils.addButton(self,"delete",self.width-800,self.height-40,180,20,getText("IGUI_AM_Delete"),ItemModDataPanel.onClickDelete);

    self:populateList();
end

function ItemModDataPanel:onClickClose()
    self:close();
end

function ItemModDataPanel:onClickRefresh()
    self:populateList();
end

function ItemModDataPanel:OnTableNamesListMouseDown(item)
    self:populateInfoList(self.tableNamesList.items[self.tableNamesList.selected].item);
end

function ItemModDataPanel:populateList()
    self.tableNamesList:clear();

    if #ItemModDataPanel.modDataList == 0 then
        self:populateInfoList(nil);
        return;
    end

    --print("haha", #ItemModDataPanel.modDataList)

    for i, obj in ipairs(ItemModDataPanel.modDataList) do
        self.tableNamesList:addItem(tostring(obj), obj);
    end

    self.firstTableData=ItemModDataPanel.modDataList[1];

    self:populateInfoList(self.firstTableData);
end

function ItemModDataPanel:drawTableNameList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ItemModDataPanel:formatVal(_value, _func, _func2)
    return _func2 and (_func2(_func(_value))) or (_func(_value));
end

function ItemModDataPanel:parseTable(_t, _ident)
    -- deprecated
end

function ItemModDataPanel:populateInfoList(obj)
    self.infoList:clear();
    -- print(obj)
    local modData
    if type(obj) == "table" then
        modData = obj
    elseif obj and obj:getModData() then 
        modData = obj:getModData() 
    else
        return; 
    end
     

    if modData then
        self.indexToPath = {}
        local function parseRec(t, indent, path)
            indent = indent or ""
            path = path or ""
            for k,v in pairs(t) do
                local display = tostring(indent).."["..tostring(k).."] -> "
                local newPath = path ~= "" and (path.."."..tostring(k)) or tostring(k)
                if type(v) == "table" then
                    local row = self.infoList:addItem(display, { path = newPath, isTable = true })
                    parseRec(v, indent.."    ", newPath)
                else
                    local row = self.infoList:addItem(display..tostring(v), { path = newPath, isTable = false })
                end
            end
        end
        parseRec(modData, "", "")
        --[[
        local s;
        for k,v in pairs(modData) do
            s = "["..tostring(k).."] -> "..tostring(v);
            self.infoList:addItem(s, nil);
        end
        --]]
    else
        self.infoList:addItem("Table not found.", nil);
    end
end


function ItemModDataPanel:drawInfoList(y, item, alt)
    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

function ItemModDataPanel:prerender()
    ISPanel.prerender(self);
    --self:populateList();
end

function ItemModDataPanel:update()
    ISPanel.update(self);
end

function ItemModDataPanel:close()
    self:setVisible(false);
    self:removeFromUIManager();
    ItemModDataPanel.instance = nil
end

function ItemModDataPanel:new(x, y, width, height, title)
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

-- Helpers
local function splitPath(path)
    local parts = {}
    if not path or path == "" then return parts end
    for part in string.gmatch(path, "[^%.]+") do
        table.insert(parts, part)
    end
    return parts
end

local function getValueByPath(root, path)
    if not root then return nil end
    local current = root
    for _, key in ipairs(splitPath(path)) do
        if type(current) ~= "table" then return nil end
        current = current[key]
    end
    return current
end

local function setValueByPath(root, path, value)
    local keys = splitPath(path)
    if #keys == 0 then return false end
    local current = root
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(current[k]) ~= "table" then current[k] = {} end
        current = current[k]
    end
    current[keys[#keys]] = value
    return true
end

local function deleteByPath(root, path)
    local keys = splitPath(path)
    if #keys == 0 then return false end
    local current = root
    for i = 1, #keys - 1 do
        local k = keys[i]
        current = type(current) == "table" and current[k] or nil
        if current == nil then return false end
    end
    current[keys[#keys]] = nil
    return true
end

function ItemModDataPanel:OnInfoListMouseDown(item)
    local row = self.infoList.items[self.infoList.selected]
    if not row or not row.item then return end
    local path = row.item.path or ""
    self.keyEntry:setText(path)
    local obj = self.tableNamesList.items[self.tableNamesList.selected] and self.tableNamesList.items[self.tableNamesList.selected].item
    if obj and obj.getModData then
        local md = obj:getModData()
        local v = getValueByPath(md, path)
        if type(v) == "number" then
            self.typeCombo.selected = 2
            self.valueEntry:setText(tostring(v))
        elseif type(v) == "boolean" then
            self.typeCombo.selected = 3
            self.valueEntry:setText(v and "true" or "false")
        elseif v == nil then
            self.typeCombo.selected = 4
            self.valueEntry:setText("")
        else
            self.typeCombo.selected = 1
            self.valueEntry:setText(tostring(v))
        end
    end
end

local function toTypedValue(str, vtype)
    if vtype == "number" then return tonumber(str)
    elseif vtype == "boolean" then return tostring(str):lower() == "true"
    elseif vtype == "nil" then return nil
    else return tostring(str or "") end
end

function ItemModDataPanel:onClickSave()
    local selectedObjRow = self.tableNamesList.items[self.tableNamesList.selected]
    if not selectedObjRow then return end
    local obj = selectedObjRow.item
    if not obj or not obj.getModData then return end

    local path = self.keyEntry:getText()
    if not path or path == "" then return end
    local vtype = self.typeCombo.options[self.typeCombo.selected]
    local value = toTypedValue(self.valueEntry:getText(), vtype)

    -- Inventory items can be changed client-side
    if instanceof(obj, "InventoryItem") then
        local md = obj:getModData()
        if value == nil then
            deleteByPath(md, path)
        else
            setValueByPath(md, path, value)
        end
        self:onClickRefresh()
        return
    end

    -- Fallback: try client-side
    local md = obj:getModData()
    if value == nil then
        deleteByPath(md, path)
    else
        setValueByPath(md, path, value)
    end
    self:onClickRefresh()
end

function ItemModDataPanel:onClickDelete()
    self.valueEntry:setText("")
    self.typeCombo.selected = 4 -- nil
    self:onClickSave()
end

local function onServerCommand(module, command, args)
    if module == MOD_NAME and command == "onSetObjModData" then
        if ItemModDataPanel.instance then
            ItemModDataPanel.instance:onClickRefresh()
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)
