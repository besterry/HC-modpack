--require "ISEditShopUI.lua"

--***********************************************************
--**                  ROBERT JOHNSON                       **
--**                   edited by FD                        **
--***********************************************************

ISEditShopUI = ISPanel:derive("ISEditShopUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)


function LoadShopItems()
    sendClientCommand(getPlayer(), 'shopItems', 'getData', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'shopItems' then return; end
        if command == 'onGetData' then
            Shop.Items = args['shopItems']
            Shop.Sell = args['forSellItems']
            Events.OnServerCommand.Remove(receiveServerCommand)            
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end

function ISEditShopUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL + 2 * 2
    local padBottom = 10

    --кнопка Отмена (закрыть окно)
    self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISEditShopUI.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    --кнопка Добавить зону
    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_SaveShop"), self, ISEditShopUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    self.comboBox = ISComboBox:new(10, 50, 100, 20, self,self.onClickTab);
    self.comboBox:initialise();
    self.comboBox:instantiate();
    --self.comboBox:setOnMouseDownFunction = ISEditShopUI.onClickTab;
    --self.comboBox.onRightMouseUp = ISEditShopUI.onClickTab;
    self:addChild(self.comboBox);    
    
    
    local keys = {}
    for k, v in pairs(Shop.Tabs) do
        table.insert(keys, k)
    end
    for _, key in ipairs(keys) do
        if key ~= "Favorite" and key ~="All" then
        self.comboBox:addOption(key);
        end
    end
    LoadShopItems()
    local listHeight = self:getHeight() - self.comboBox.height - padBottom - btnHgt - 60 -- вычисляем высоту списка
    --X отступ слева, Y отступ сверху, wh - размер окна
    self.scrollingList = ISScrollingListBox:new(10, self.comboBox.height+60, 400, listHeight-10)
    self.scrollingList:initialise();
    self.scrollingList:instantiate();
    self.scrollingList.itemheight = 25;
    self.scrollingList.joypadParent = self;
    self.scrollingList.font = UIFont.Small;
    self.scrollingList:setOnMouseDownFunction(self, self.onClickItem);
    self.scrollingList.drawBorder = true;
    self:addChild(self.scrollingList);
    for key, value in pairs(Shop.Sell) do
        value.name = key
        local itemName = getItemNameFromFullType(key)
        if value.price then
<<<<<<< HEAD
            self.scrollingList:addItem(itemName .. " - " .. value.price, value) 
=======
            self.scrollingList:addItem(itemName .. " - " .. value.price,value) 
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
        else
            self.scrollingList:addItem(itemName .. " - " .. "blocked") 
        end
    end  
    
<<<<<<< HEAD
    self.ItemEntry = ISTextEntryBox:new("", self.scrollingList.x + self.scrollingList.width + 10, 70, 150, btnHgt)
=======
    self.ItemEntry = ISTextEntryBox:new("Item", self.scrollingList.x + self.scrollingList.width + 10, 70, 150, btnHgt)
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
    self.ItemEntry:initialise();
    self.ItemEntry:instantiate();
    self:addChild(self.ItemEntry);

<<<<<<< HEAD
    self.PriceEntry = ISTextEntryBox:new("", self.ItemEntry.x, self.ItemEntry.y + self.ItemEntry.height + 25, 150, btnHgt)
    self.PriceEntry:initialise()
    self.PriceEntry:instantiate()
    self:addChild(self.PriceEntry)

    self.TabEntry = ISTextEntryBox:new("", self.PriceEntry.x, self.PriceEntry.y + self.PriceEntry.height + 25, 150, btnHgt)
    self.TabEntry:initialise()
    self.TabEntry:instantiate()
    self:addChild(self.TabEntry)


=======
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
    self.BlockBox = ISTickBox:new(self.ItemEntry.x + self.ItemEntry.width + 10, self.ItemEntry.y, 10, 10, "", nil, nil)
    self.BlockBox:initialise();
    self.BlockBox:instantiate();
    self.BlockBox.selected[1] = false; -- Start false or not
    self:addChild(self.BlockBox);
<<<<<<< HEAD
    self.BlockBox:addOption("Block Sell"); -- To add a text at the left of the box
=======
    self.BlockBox:addOption("Block"); -- To add a text at the left of the box
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
end

function ISEditShopUI:prerender()
    local z = 20;
    local splitPoint = 200;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_Edit_Shop"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_Edit_Shop")) / 2), z, 1,1,1,1, UIFont.Medium);
    self:updateButtons();      
end

function ISEditShopUI:render () 
<<<<<<< HEAD
=======
    selectedTab = self.comboBox:getSelectedText()
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
end

    --local seletedData = self.comboBox:getOptionData(selectedId) -- данные, если есть
function ISEditShopUI:onClickTab() --Подгрузка содержимого вкладок
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)

    self.scrollingList:clear();
    if seletedName == "Sell" then
        for key, value in pairs(Shop.Sell) do
            value.name = key
            local itemName = getItemNameFromFullType(key)
            if value.price then
<<<<<<< HEAD
                self.scrollingList:addItem(itemName .. " - " .. value.price, value) 
=======
                self.scrollingList:addItem(itemName .. " - " .. value.price,value) 
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
            else
                self.scrollingList:addItem(itemName .. " - " .. "blocked") 
            end
        end    
    end    
    for key, value in pairs(Shop.Items) do
        if  value.tab == seletedName then
            value.name = key
            local itemName = getItemNameFromFullType(key)                
<<<<<<< HEAD
            self.scrollingList:addItem(itemName .. " - " .. value.price, value)
=======
            self.scrollingList:addItem(itemName .. " - " .. value.price,value)
>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
        end
    
    end
end

<<<<<<< HEAD

function ISEditShopUI:onClickItem () --При выборе элемента в списке
 
=======
function ISEditShopUI:onClickItem () --При выборе элемента в списке

>>>>>>> 7b33a2c7ac71f88c41e7eb4a1b74c70d602ea635
end

function ISEditShopUI:updateButtons()    
end

function ISEditShopUI:onClick(button) -- Дествия по нажатию кнопок
    if button.internal == "OK" then       
        for key, value in pairs(Shop.Items) do
            print(key, value.name)
        end
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

function ISEditShopUI:new(x, y, width, height, player) --Создание окна
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
