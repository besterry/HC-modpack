
require "ISUI/ISPanel"

ItemModDataPanel = ISPanel:derive("ItemModDataPanel");
ItemModDataPanel.instance = nil;
ItemModDataPanel.modDataList = {}

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
    self:addChild(self.infoList);

    local y, obj = ISDebugUtils.addButton(self,"close",self.width-200,self.height-40,180,20,getText("IGUI_CraftUI_Close"),ItemModDataPanel.onClickClose);
    y, obj = ISDebugUtils.addButton(self,"refresh",self.width-400,self.height-40,180,20,getText("IGUI_Refresh"),ItemModDataPanel.onClickRefresh);

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

function ItemModDataPanel:populateInfoList(obj)
    self.infoList:clear();
    -- print(obj)
    local modData
    if obj and obj:getModData() then modData = obj:getModData() else return; end
     

    if modData then
        self:parseTable(modData, "");
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
