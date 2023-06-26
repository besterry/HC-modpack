--require "ISEditShopUI.lua"

--***********************************************************
--**                    FD created 26/06/23                **
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

    --кнопка Сохранить
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
            self.scrollingList:addItem(itemName .. " - " .. value.price, { value = value }) 
        else
            self.scrollingList:addItem(itemName .. " - " .. "blocked", { value = value }) 
        end
    end  
    
    self.ItemEntry = ISTextEntryBox:new("", self.scrollingList.x + self.scrollingList.width + 10, 70, 220, btnHgt)
    self.ItemEntry:initialise();
    self.ItemEntry:instantiate();
    self:addChild(self.ItemEntry);

    self.PriceEntry = ISTextEntryBox:new("", self.ItemEntry.x, self.ItemEntry.y + self.ItemEntry.height + 25, 150, btnHgt)
    self.PriceEntry:initialise()
    self.PriceEntry:instantiate()
    self:addChild(self.PriceEntry)

    self.ChangeButton = ISButton:new(self.PriceEntry.x, self.PriceEntry.y + self.PriceEntry.height + 10, 60, btnHgt, "Change", self, ISEditShopUI.onChangeButtonClicked)
    self.ChangeButton:initialise()
    self.ChangeButton:instantiate()
    self:addChild(self.ChangeButton)

    self.SpecialCoinBox = ISTickBox:new(self.PriceEntry.x + self.PriceEntry.width + 10, self.PriceEntry.y, 10, 10, "", self, ISEditShopUI.onBlockBoxClicked)
    self.SpecialCoinBox:initialise()
    self.SpecialCoinBox:instantiate()
    self.SpecialCoinBox.selected[1] = false
    self:addChild(self.SpecialCoinBox)
    self.SpecialCoinBox:addOption("Special Coin")
    self.SpecialCoinBox:setVisible(false) 


    self.BlockBox = ISTickBox:new(self.ItemEntry.x + self.ItemEntry.width + 5, self.ItemEntry.y, 10, 10, "", nil, nil)
    self.BlockBox:initialise();
    self.BlockBox:instantiate();
    self.BlockBox.selected[1] = false;
    self:addChild(self.BlockBox);
    self.BlockBox:addOption("Block"); 

    self.itemLabel = ISLabel:new(self.ItemEntry.x, self.ItemEntry.y - 20, FONT_HGT_SMALL, "Item:", 1, 1, 1, 1, UIFont.Small, true)
    self.itemLabel:initialise()
    self.itemLabel:instantiate()
    self:addChild(self.itemLabel)

    self.priceLabel = ISLabel:new(self.PriceEntry.x, self.PriceEntry.y - 20, FONT_HGT_SMALL, "Price Coin:", 1, 1, 1, 1, UIFont.Small, true)
    self.priceLabel:initialise()
    self.priceLabel:instantiate()
    self:addChild(self.priceLabel)
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
end

    --local seletedData = self.comboBox:getOptionData(selectedId) -- данные, если есть
function ISEditShopUI:onClickTab() --Подгрузка содержимого вкладок
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)
    self.SpecialCoinBox:setVisible(false)
    self.BlockBox:setVisible(false)
    self.scrollingList:clear();
    if seletedName == "Sell" then
        self.BlockBox:setVisible(true)  
        self.SpecialCoinBox:setVisible(false)         
        for key, value in pairs(Shop.Sell) do
            value.name = key
            local itemName = getItemNameFromFullType(key)
            if value.price then
                self.scrollingList:addItem(itemName .. " - " .. value.price, { value = value }) 
            else
                self.scrollingList:addItem(itemName .. " - " .. "blocked", { value = value }) 
            end
        end    
    else    
        for key, value in pairs(Shop.Items) do
            if  value.tab == seletedName then
                value.name = key
                local itemName = getItemNameFromFullType(key)                
                self.scrollingList:addItem(itemName .. " - " .. value.price, { value = value })
            end    
        end
    end
end

function ISEditShopUI:onClickItem (item, doubleClick) --При выборе элемента в списке
    if item ~= nil and item.value ~= nil then
        self.ItemEntry:setText(item.value.name)

        if item.value.price ~= nil then
            self.PriceEntry:setVisible(true)
            self.priceLabel:setVisible(true)
            self.SpecialCoinBox:setVisible(true)
            self.PriceEntry:setText(tostring(item.value.price))
        else
            self.priceLabel:setVisible(false)
            self.SpecialCoinBox:setVisible(false)
            self.PriceEntry:setVisible(false)
        end

        self.SpecialCoinBox.selected[1] = item.value.specialCoin or false
        self.BlockBox.selected[1] = item.value.price == nil 
    else
        self.ItemEntry:setText("No item")
        self.PriceEntry:setVisible(false)
        self.TabEntry:setVisible(false)
    end
end

function ISEditShopUI:updateButtons()    
end

function ISEditShopUI:onClick(button) -- Дествия по нажатию кнопок
    if button.internal == "OK" then   
            print(bcUtils.dump(Shop.Items))
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
