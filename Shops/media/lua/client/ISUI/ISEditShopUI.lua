--require "ISEditShopUI.lua"

--***********************************************************
--**                    FD created 26/06/23                **
--***********************************************************

ISEditShopUI = ISPanel:derive("ISEditShopUI");

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local msg = nil
local player = nil
local EditShopLog= {}

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
    self.cancel.tooltip = getText("IGUI_CancelShopTooltip")
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    --кнопка Сохранить
    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_SaveShop"), self, ISEditShopUI.onClick);
    self.ok.internal = "OK";
    self.ok.tooltip = getText("IGUI_SaveShopTooltip")
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    self.loadButton = ISButton:new(self.ok.x + self.ok.width + 10, self.ok.y, btnWid, btnHgt, getText("IGUI_LoadItem"), self, ISEditShopUI.onClick);
    self.loadButton.internal = "RELOADING";
    self.loadButton.anchorTop = false;
    self.loadButton.anchorBottom = true;
    self.loadButton.tooltip = getText("IGUI_ReloadShopTooltip")
    self.loadButton:initialise();
    self.loadButton:instantiate();
    self.loadButton.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.loadButton);


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

    local entryWidth = 150
    local entryHeight = 20
    local entryX = self.scrollingList.x + self.scrollingList.width - entryWidth
    local entryY = self.scrollingList.y - entryHeight - 10
    self.findEntry = ISTextEntryBox:new("", entryX, entryY, entryWidth, entryHeight)
    self.findEntry:initialise()
    self.findEntry:instantiate();
    self:addChild(self.findEntry)

    local findLabel = ISLabel:new(entryX - 40, entryY + 10, 1, "Find:", 1, 1, 1, 1, UIFont.Medium, true)
    findLabel:initialise()
    self:addChild(findLabel)
    
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

    self.AddButton = ISButton:new(self.ChangeButton.x, self.ChangeButton:getBottom() + 10, self.ChangeButton.width, btnHgt, "Add new item", self, ISEditShopUI.onAddButtonClicked)
    self.AddButton:initialise()
    self.AddButton:instantiate()
    self:addChild(self.AddButton)

    local deleteButtonX = self.ChangeButton.x + self.ChangeButton.width + 10
    self.DeleteButton = ISButton:new(deleteButtonX, self.ChangeButton.y, 60, btnHgt, "Delete", self, ISEditShopUI.onDeleteButtonClicked)
    self.DeleteButton:initialise()
    self.DeleteButton:instantiate()
    self:addChild(self.DeleteButton)

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

    self.findEntry.onTextChange = function()
        self:filterScrollingList()
    end
    player = getPlayer():getUsername()
    self:onClickTab() -- Просто вызываем клик на таб чтоб он отрисовал список
end


function ISEditShopUI:filterScrollingList()    
    -- Мы будем работать с данными и отрисовывать их. Это проще чем удалять и добавлять их по отдельности в уже отрисованный интерфейс. Чем проще код тем лучше
    local searchText = self.findEntry:getInternalText()
    local filteredItems = {} -- Сюда сохраняем отфильтрованые айтемы
    if searchText ~= "" then
        for _, listItem in pairs(self.initialList) do
            local itemName = getItemNameFromFullType(listItem.item.value.name) 
            if itemName:lower():find(searchText:lower()) then -- Можно использовать такую нотацию, чтобы обращаться к разным методам одного и того же инстанса (string) по цепочке. Просто показываю что можно так. Твой способ тоже нормальный и рабочий
                table.insert(filteredItems, listItem) -- Собираем фильтрованный список
            end           
        end
    else
        filteredItems = self.initialList -- если текста в поиске нет то показываем весь список
    end
    self.scrollingList:clear(); -- очищаем список
    for _, listItem in pairs(filteredItems) do --Собираем список
        local text = listItem.text
        local item = listItem.item
        self.scrollingList:addItem(text, item)
    end
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
    if self.BlockBox.selected[1] then
        self.PriceEntry:setVisible(false)
        self.priceLabel:setVisible(false)
        self.SpecialCoinBox:setVisible(false)
    else
        self.PriceEntry:setVisible(true)
        self.SpecialCoinBox:setVisible(true)
        self.priceLabel:setVisible(true)
    end
end

    --local seletedData = self.comboBox:getOptionData(selectedId) -- данные, если есть
function ISEditShopUI:onClickTab() --Подгрузка содержимого вкладок
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)
    local sp
    local count
    self.SpecialCoinBox:setVisible(false)
    self.BlockBox:setVisible(false)
    self.scrollingList:clear();
    if seletedName == "Sell" then
        self.BlockBox:setVisible(true)  
        self.SpecialCoinBox:setVisible(false)         
        for key, value in pairs(Shop.Sell) do
            value.name = key
            if value.specialCoin and value.specialCoin == true then
                sp = " SC"
            else
                sp = ""
            end            
            local itemName = getItemNameFromFullType(key)
            if value.price then
                self.scrollingList:addItem(itemName .. " - " .. value.price .. sp , { value = value }) 
            else
                self.scrollingList:addItem(itemName .. " - " .. "blocked", { value = value }) 
            end
        end    
    else    
        for key, value in pairs(Shop.Items) do -- это не работает или я сломал?
            if  value.tab == seletedName then
                if value.specialCoin and value.specialCoin == true then
                    sp = " SC"
                else
                    sp = ""
                end
                if value.quantity then
                    count = value.quantity
                else
                    count = "1"
                end
                value.name = key
                local itemName = getItemNameFromFullType(key)                
                self.scrollingList:addItem(itemName .." (" .. count .. ") " .. " - " .. value.price .. sp, { value = value })
            end    
        end
    end
    self.initialList = {} -- Копируем сюда оригинальный список, чтоб не потерять и случайно не мутировать его. Он нам пригодится для фильтрации.
                          -- Лучше было бы конечно изначально собрать список, а потом отрисовать его. Потому что полезно отделять данные от интерфейса.
                          -- Но мне лень переписывать ISEditShopUI:onClickTab
    for _, listItem in pairs(self.scrollingList.items) do
        table.insert(self.initialList, listItem)
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
        self.BlockBox.selected[1] = item.value.blacklisted or false
    else
        self.ItemEntry:setText("No item")
        self.PriceEntry:setVisible(false)
        self.TabEntry:setVisible(false)
    end
end

function ISEditShopUI:onChangeButtonClicked()
    local selected = self.scrollingList.items[self.scrollingList.selected]
    local selectedIndex = self.scrollingList.selected
    local selectedId = self.comboBox.selected
    local seletedtab = self.comboBox:getOptionText(selectedId)
    if self.ItemEntry:getInternalText() == "" then return end    
    if self.PriceEntry:getInternalText() == "" and self.PriceEntry:getIsVisible() ~= true then return end

    if selected ~= nil then
        selected.item.value.name = self.ItemEntry:getInternalText() -- получаем имя Base.Axe
        local modifiedParams = {}
        if selected.item.value.blacklisted ~= nil then --проверка существует ли поле            
            table.insert(modifiedParams, "blacklisted: true->false")
            selected.item.value.blacklisted = nil -- удаляем поле blacklisted
        end
        if self.BlockBox.selected[1] then --если блок выбран
            table.insert(modifiedParams, "blacklisted: false->true")
            selected.item.value.blacklisted = true --добавляем параметр blacklisted
            if selected.item.value.price then --если есть цена
                table.insert(modifiedParams, "price:" .. tostring(selected.item.value.price) .. "->nil")
                selected.item.value.price = nil --убираем
            end
            if selected.item.value.specialCoin then --если есть specialCoin                
                table.insert(modifiedParams, "specialCoin:" .. tostring(selected.item.value.specialCoin) .. "->nil")
                selected.item.value.specialCoin = nil --убираем
            end
        elseif self.SpecialCoinBox.selected[1] and self.SpecialCoinBox:getIsVisible() then --если стоит чекбокс SpecialCoinBox              
            table.insert(modifiedParams, "specialCoin: false -> true, price:" .. self.PriceEntry:getInternalText())           
            selected.item.value.specialCoin = true --добавляем поле SpecialCoinBox
            selected.item.value.price = tonumber(self.PriceEntry:getInternalText()) --устанавливаем цену
        else
            if selected.item.value.specialCoin then --если чекбокс SpecialCoinBox есть                
            table.insert(modifiedParams, "specialCoin: true -> nil")
                selected.item.value.specialCoin = nil --убираем
            end
            table.insert(modifiedParams, "price:" .. tostring(selected.item.value.price) .. "->" .. self.PriceEntry:getInternalText()) 
            selected.item.value.price = tonumber(self.PriceEntry:getInternalText()) --Ставим цену в Coin
        end
        if seletedtab == "Sell" then
            Shop.Sell[selected.item.value.name] = selected.item.value
        else
            Shop.Items[selected.item.value.name] = selected.item.value
        end
        self:onClickTab()
        msg = player .. " edit item:" .. tostring(selected.item.value.name)
        if #modifiedParams > 0 then
            msg = msg .. " [Modified: " .. table.concat(modifiedParams, ", ") .. "]"
        end
        table.insert(EditShopLog, msg)
        self.scrollingList.selected = selectedIndex
    end
end

function ISEditShopUI:onAddButtonClicked()
    local modal = ISModalDialog:new(0, 0, 250, 220, "Add new item", true, self, ISEditShopUI.onNewItemAdded)
    modal:initialise()
    modal:addToUIManager()

    local x = modal:getWidth() * 0.25
    local y = 50
    local width = modal:getWidth() * 0.5
    local height = 25
    
    self.NInameLabel = ISLabel:new(x - 40, y+10, 0, "Item:", 1, 1, 1, 1, UIFont.Small, true)
    self.NInameLabel:initialise()
    self.NInameLabel:instantiate()
    modal:addChild(self.NInameLabel)
    
    self.NInameEntry = ISTextEntryBox:new("", x, y, width, height)
    self.NInameEntry:initialise()
    self.NInameEntry:instantiate()
    modal:addChild(self.NInameEntry) 

    self.NIBlockBox = ISTickBox:new(x + width + 5, y, 10, 10, "", self, ISEditShopUI.onNIBlockBoxClicked)
    self.NIBlockBox:initialise()
    self.NIBlockBox:instantiate()
    self.NIBlockBox.selected[1] = false
    modal:addChild(self.NIBlockBox)
    self.NIBlockBox:addOption("Block")
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)
    if seletedName ~= "Sell" then self.NIBlockBox:setVisible(false) else self.NIBlockBox:setVisible(true) end

    self.NIpriceLabel = ISLabel:new(x - 40, y+50, 0, "Price:", 1, 1, 1, 1, UIFont.Small, true)
    self.NIpriceLabel:initialise()
    self.NIpriceLabel:instantiate()
    modal:addChild(self.NIpriceLabel)
    
    self.NIpriceEntry = ISTextEntryBox:new("", x, y+40, width, height)
    self.NIpriceEntry:initialise()
    self.NIpriceEntry:instantiate()
    modal:addChild(self.NIpriceEntry)

    self.NIcountLabel = ISLabel:new(x - 40, y+90, 0, "Count:", 1, 1, 1, 1, UIFont.Small, true)
    self.NIcountLabel:initialise()
    self.NIcountLabel:instantiate()
    modal:addChild(self.NIcountLabel)
    
    self.NIcountEntry = ISTextEntryBox:new("", x, y+80, width, height)
    self.NIcountEntry:initialise()
    self.NIcountEntry:instantiate()
    modal:addChild(self.NIcountEntry)

    self.NIerrorLabel = ISLabel:new(x+15, y+120, 0, "Item already exists", 1, 0, 0, 1, UIFont.Small, true)
    self.NIerrorLabel:initialise()
    self.NIerrorLabel:instantiate()
    modal:addChild(self.NIerrorLabel)
    self.NIerrorLabel:setVisible(false)

    self.NIerrorNameLabel = ISLabel:new(x+15, y+120, 0, "Invalid name", 1, 0, 0, 1, UIFont.Small, true)
    self.NIerrorNameLabel:initialise()
    self.NIerrorNameLabel:instantiate()
    modal:addChild(self.NIerrorNameLabel)
    self.NIerrorNameLabel:setVisible(false)

    self.NISpecialCoinBox = ISTickBox:new(x + width + 5, y + 40, 10, 10, "",nil,nil)
    self.NISpecialCoinBox:initialise()
    self.NISpecialCoinBox:instantiate()
    self.NISpecialCoinBox.selected[1] = false;
    modal:addChild(self.NISpecialCoinBox)
    self.NISpecialCoinBox:addOption("SC")
end

function ISEditShopUI:onNewItemAdded(button)
    if button.internal == "NO" then return end    
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)

    local itemName = self.NInameEntry:getText()
    local itemPrice = tonumber(self.NIpriceEntry:getText())
    local isBlocked = self.NIBlockBox.selected[1]
    local hasSpecialCoin = self.NISpecialCoinBox.selected[1]
    local count = nil
    if self.NIcountEntry:getText()~="" then 
        count = tonumber(self.NIcountEntry:getText())
    else
        count = 1
    end
    -- Проверка на существование предмета (оишбки в написании)
    -- if not getItemNameFromFullType(itemName) then 
    --     self.NIerrorNameLabel:setVisible(true) 
    --     return 
    -- else
    --      self.NIerrorNameLabel:setVisible(false) 
    -- end

    
    if itemName ~= "" then
        if seletedName == "Sell" then
            if Shop.Sell[itemName] then 
                self.NIerrorNameLabel:setVisible(true) 
                return 
            else 
                self.NIerrorNameLabel:setVisible(false)                
                local newItem = {
                    name = itemName,
                    price = itemPrice,            
                    blacklisted = isBlocked,
                    specialCoin = hasSpecialCoin
                }
                Shop.Sell[itemName] = newItem
                msg = player .. " add item:" .. tostring(newItem.name) .. " price:" .. tostring(newItem.price) .. " blacklisted:" .. tostring(newItem.blacklisted) .. " SpecialCoin:" .. tostring(newItem.specialCoin)
            end
        else
            if Shop.Items[itemName] then 
                self.NIerrorNameLabel:setVisible(true) 
                return 
            else 
                self.NIerrorNameLabel:setVisible(false) 
                local newItem = {
                    name = itemName,
                    price = itemPrice,
                    tab = seletedName,
                    specialCoin = hasSpecialCoin,
                    quantity = count
                }    
                Shop.Items[itemName] = newItem
                msg = player .. " add item:" .. tostring(newItem.name) .. " Tab:" .. tostring(newItem.tab) .. " price:" .. tostring(newItem.price) .. " blacklisted:" .. tostring(newItem.blacklisted) .. " SpecialCoin:" .. tostring(newItem.specialCoin) .. " Count:" .. tostring(newItem.quantity)
            end
        end        
        table.insert(EditShopLog, msg)
        self:onClickTab()         
    end
end

function ISEditShopUI:onNIBlockBoxClicked ()
    if self.NIBlockBox.selected[1] then
        self.NISpecialCoinBox:setVisible(false)
        self.NIpriceLabel:setVisible(false)
        self.NIpriceEntry:setVisible(false)
        self.NIcountEntry:setVisible(false)
        self.NIcountLabel:setVisible(false)
    else
        self.NISpecialCoinBox:setVisible(true)
        self.NIpriceLabel:setVisible(true)
        self.NIpriceEntry:setVisible(true)
        self.NIcountEntry:setVisible(true)
        self.NIcountLabel:setVisible(true)
    end
end

function ISEditShopUI:onDeleteButtonClicked()
    local selected = self.scrollingList.items[self.scrollingList.selected]
    local selectedId = self.comboBox.selected
    local seletedName = self.comboBox:getOptionText(selectedId)
    if selected ~= nil then
        if seletedName == "Sell" then           
            msg = player .. " delete item:" .. tostring(selected.item.value.name) .. " from sell"
            self.scrollingList:removeItem(selected)
            Shop.Sell[selected.item.value.name] = nil
            self:onClickTab()
            table.insert(EditShopLog, msg)
        else   
            msg = player .. " delete item:" .. tostring(selected.item.value.name) .. " Tab:" .. tostring(selected.item.value.tab) .. " Price:" .. tostring(selected.item.value.price) .." from buy" 
            self.scrollingList:removeItem(selected)
            Shop.Items[selected.item.value.name] = nil
            self:onClickTab()
            table.insert(EditShopLog, msg)
        end        
    end    
end

function ISEditShopUI:updateButtons()    
end

function ISEditShopUI:onClick(button)
    if button.internal == "OK" then           
        sendClientCommand(getPlayer(), "shopItems", "PushShopItems", {Shop.Items,Shop.Sell})
        sendClientCommand(getPlayer(), "shopItems", "LogEditShop", {EditShopLog})        
        self:setVisible(false);
        self:removeFromUIManager();        
    end
    if button.internal == "RELOADING" then        
        sendClientCommand(getPlayer(), "shopItems", "ReloadShopItems", {})
        self:setVisible(false);
        self:removeFromUIManager();
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
    o.moveWithMouse = true;
    ISEditShopUI.instance = o;
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    return o;
end
