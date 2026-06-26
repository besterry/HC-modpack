local Nfunction = require "Nfunction"
PlayerShopUI = ISCollapsableWindow:derive("PlayerShopUI");
PlayerShopUI.instance = nil;
PlayerShopUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
PlayerShopUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
PlayerShopUI.removeButtonX = 380
PlayerShopUI.previewButtonX = PlayerShopUI.removeButtonX + 25
PlayerShopUI.shopItemsCache = {}
PlayerShopUI.total = 0
PlayerShopUI.totalSpecial = 0
PlayerShopUI.actionInProgress = false
PlayerShopUI.cvUis = {}

local removeBtn = Shop.textures.RemoveButton;
local previewBtn = Shop.textures.PreviewButton;
local cartImg = Shop.textures.Cart;
local browseBtn = Shop.textures.Browse;
local addBtn = Shop.textures.AddButton;
local browseBtn = Shop.textures.Browse;
local width = 995
local height = 550
local posX = 0
local posY = 0

function PlayerShopUI:show(player,shop)
    local square = player:getSquare()
    posX = square:getX()
    posY = square:getY()
    if PlayerShopUI.instance==nil then
        local shopOwner = shop:getModData().owner
        PlayerShopUI.instance = PlayerShopUI:new (0, 0, width, height, player,shopOwner);
        PlayerShopUI.instance.shop = shop
        PlayerShopUI.instance.shopOwner = shopOwner
        PlayerShopUI.instance:initialise();
        PlayerShopUI.instance:instantiate();
    else
        PlayerShopUI.instance.shop = shop
        PlayerShopUI.instance.shopOwner = shop:getModData().owner
        PlayerShopUI.instance.player = player
        PlayerShopUI.instance:rebuildShopTabs()
    end
    PlayerShopUI.instance.pinButton:setVisible(false)
    PlayerShopUI.instance.collapseButton:setVisible(false)
    PlayerShopUI.instance:addToUIManager();
    PlayerShopUI.instance:setVisible(true);
    PlayerShop.toggleBusy(shop,player:getUsername(),true)
    return PlayerShopUI.instance;
end

function PlayerShopUI:update()
    local player = self.player
	if player:DistTo(posX, posY) > 2 then
		self:close()
    end
    local username = self.player:getUsername()    
    local coin,specialCoin = Balance.getUserBalance(username)
    local coinFormatted = Currency.format(coin)
    self.balanceCoinLabel:setName(""..coinFormatted)
    local specialCoinFormatted = Currency.format(specialCoin)
    self.balanceSpecialCoinLabel:setName(""..specialCoinFormatted)
    if self.actionInProgress then 
        self.buyCartButton.enable = false
        self.buyCartButton:setVisible(false)
        self.cancelBuyButton.enable = true
        self.cancelBuyButton:setVisible(true)
        return 
    end
    self:updateTotal()
end

function PlayerShopUI:doDrawCartItem(y, item, alt)
    local baseItemDY = 0
    if item.item.name then
        baseItemDY = self.SMALL_FONT_HGT
        item.height = self.itemheight + baseItemDY
    end

    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9;
    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15);
    end

    local nameToDraw = item.item.name
    if item.item.orderKey and item.item.units and item.item.units > 1 then
        nameToDraw = nameToDraw .. "  x" .. tostring(item.item.units)
    end
    self:drawText(nameToDraw, 40, y + 10, 1, 1, 1, a, UIFont.Small);
    if item.item.price then
        local coinImg = Currency.CoinsTexture.Coin
        if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
        self:drawTextureScaledAspect(coinImg.texture, 300, y + 10, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
        local priceFormatted = Currency.format(item.item.price)
        self:drawText(""..priceFormatted, 320, y + 8, 1, 1, 1, a, UIFont.Small);
    end

    if item.item.invItem then
        self:drawTextureScaledAspect(item.item.invItem:getTex(), 6, y+5, 30, 30, 1, 1, 1, 1)
        if item.item.invItem:IsInventoryContainer() then
            self:drawTextureScaledAspect(browseBtn.texture, self.parent.previewButtonX, y + 10, browseBtn.scale, browseBtn.scale, 1, 1, 1, 1)
        end
    end

    self:drawTextureScaledAspect(removeBtn.texture, self.parent.removeButtonX, y + 10, removeBtn.scale, removeBtn.scale, 1, 1, 1, 1)

    if item.item.VehicleID then
        self:drawTextureScaledAspect(previewBtn.texture, self.parent.previewButtonX, y + 10, previewBtn.scale, previewBtn.scale, 1, 1, 1, 1)
    end

    return y + item.height;
end

function PlayerShopUI:onMouseMove(dx, dy)
    self.mouseOver = true;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
		self:bringToTop();
	end
    if PlayerShopUI.instance and PlayerShopUI.instance.panel and PlayerShopUI.instance.panel.activeView and PlayerShopUI.instance.panel.activeView.view and PlayerShopUI.instance.panel.activeView.view.shopItems:isMouseOver() then return end
    if PlayerShopUI.instance.cartItems:isMouseOver() then return end
    PlayerShopUI.instance:toggleTooltip(false)
end

function PlayerShopUI:onMouseDown(x, y)
    ISCollapsableWindow.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
end

function PlayerShopUI:onMouseDownCartItem(x, y)
    ISScrollingListBox.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
    if ContainerViewerUI.instance then ContainerViewerUI.instance:close() end
	if self.selectedRow then
        local selectedRow = self.items[self.selectedRow]
        if not selectedRow then return end
        if self.previewBtn then
            if selectedRow.item.invItem:IsInventoryContainer() then
                ContainerViewerUI:show(selectedRow.item.invItem)
                return
            end
            if not selectedRow.item.VehicleID then return end
            PreviewUI:show(selectedRow.item.name,selectedRow.item.VehicleID)
            return
        end
        if self.removeBtn then
		    PlayerShopUI.instance:removeFromCart(selectedRow)
        end
    end
end

local currentTooltip = nil
function PlayerShopUI:toggleTooltip(show, item)
    -- скрыть/очистить
    if not show or not item then
        if currentTooltip then
            currentTooltip:removeFromUIManager()
            currentTooltip:setVisible(false)
            currentTooltip = nil
        end
        return
    end

    local needInv = item.invItem ~= nil
    -- убедимся, что тип тултипа соответствует содержимому
    if currentTooltip then
        local wrongType = false
        if needInv then
            wrongType = not instanceof(currentTooltip, "ISToolTipInv")
        else
            wrongType = not instanceof(currentTooltip, "ISToolTip")
        end
        if wrongType then
            currentTooltip:removeFromUIManager()
            currentTooltip:setVisible(false)
            currentTooltip = nil
        end
    end

    if not currentTooltip then
        if needInv then
            currentTooltip = ISToolTipInv:new(item.invItem)
        else
            currentTooltip = ISToolTip:new()
        end
        currentTooltip:initialise()
    end

    currentTooltip:addToUIManager()
    if needInv then
        currentTooltip:setItem(item.invItem)
    else
        local tooltipText = item.name or "Unknown Item"
        if item.onlyFull then
            tooltipText = tooltipText .. "\n" .. getText("IGUI_BuyOrders_OnlyFull")
        end
        currentTooltip:setName(tooltipText)
    end
    currentTooltip:setVisible(true)
    currentTooltip:setOwner(self)
end

function PlayerShopUI:onMouseMoveCartItem(dx, dy)
    local list = PlayerShopUI.instance.cartItems
    if not list then return end
    list.selectedRow = nil
    list.previewBtn = nil
    list.removeBtn = nil
	if list:isMouseOverScrollBar() or not list:isMouseOver() then PlayerShopUI.instance:toggleTooltip(false) return end
	local rowIndex = list:rowAt(list:getMouseX(), list:getMouseY())
    if not rowIndex then PlayerShopUI.instance:toggleTooltip(false)  return end
    local selectedRow = list.items[rowIndex]
    if not selectedRow then PlayerShopUI.instance:toggleTooltip(false) return end
    local mouseX = self:getMouseX()
    list.selectedRow = rowIndex
    if mouseX > self.parent.removeButtonX then
        list.removeBtn = true
    end
    if mouseX > self.parent.previewButtonX then
        list.previewBtn = true
    end
    if not selectedRow.item then PlayerShopUI.instance:toggleTooltip(false) return end
    PlayerShopUI.instance:toggleTooltip(true,selectedRow.item)
end

function PlayerShopUI:addShopTab(tabType, tabName)
    local tab = PlayerShopTabUI:new(0, 0, self.width, self.panel.height - self.panel.tabHeight);
    tab:initialise();
    tab:setAnchorRight(true)
    tab:setAnchorBottom(true)
    tab:setShopUI(PlayerShopUI.instance)
    tab:setCategoryType(tabType)
    self.panel:addView(tabName, tab);
    tab.parent = self;
end

function PlayerShopUI:rebuildShopTabs()
    if not self.panel or not self.shop then return end

    local toRemove = {}
    for _, viewObject in ipairs(self.panel.viewList) do
        table.insert(toRemove, viewObject.view)
    end
    for _, view in ipairs(toRemove) do
        self.panel:removeView(view)
    end

    self.shopItemsCache = {}
    self.lastActiveTab = nil

    local hasSale = PlayerShop.hasSaleItems(self.shop)
    local hasBuy = PlayerShop.hasBuyOrders(self.shop)

    if hasSale then
        self:addShopTab(Tab.All, getText("IGUI_Tab_All"))
    end
    if hasBuy then
        self:addShopTab(Tab.BuyOrders, getText("IGUI_Tab_SellToShop"))
    end

    if self.emptyShopLabel then
        self.emptyShopLabel:setVisible(not hasSale and not hasBuy)
    end

    if hasSale or hasBuy then
        self:activateFirstTab()
    elseif self.cartItems then
        self.cartItems:clear()
        self.total = 0
        self.totalSpecial = 0
    end
end

function PlayerShopUI:onActivateView()
    if not self.panel.activeView or not self.panel.activeView.view then return end
    local tabType = self.panel.activeView.view.tabType
    -- очистка корзины при переключении вкладок
    if self.lastActiveTab and self.lastActiveTab ~= tabType then
        if self.cartItems then self.cartItems:clear() end
        self.total = 0; self.totalSpecial = 0
    end
    self.lastActiveTab = tabType
    local shopItems = self.panel.activeView.view.shopItems
    -- вкладка скупки: показываем ордера
    if tabType == "BuyOrders" then
        local orders = self.shop:getModData().buyOrders or {}
        shopItems:clear()
        for key,ord in pairs(orders) do
            local invItem = InventoryItemFactory.CreateItem(ord.type)
            if invItem then
                local v = {}
                v.type = ord.type
                v.price = ord.price
                v.specialCoin = ord.specialCoin
                v.onlyFull = ord.onlyFull and true or false
                v.name = Nfunction.trimString(invItem:getName(),42)
                v.count = tonumber(ord.qty) or 0 -- показываем доступное кол-во отдельно, без включения в имя
                v.invItem = invItem
                v.orderKey = key
                shopItems:addItem(v.type,v);
            end
        end
        self.shopItemsCache[tabType] = shopItems.items
        return
    end
    local items = self.shop:getContainer():getItems()
    shopItems:clear()
    if self.cartItems then
        self.cartItems:clear()
    end
    local grouped = {}
    local ordered = {}
    for i=0, items:size() - 1 do
        local invItem = items:get(i)
        local modData = invItem:getModData()
        local VehicleID = modData.VehicleID
        if modData.price then
            local typeFull = invItem:getFullType()
            local nameTrimmed = Nfunction.trimString(invItem:getName(),42)
            local canStack = (not VehicleID) and (not invItem:IsInventoryContainer())
            local key = typeFull.."|"..tostring(modData.price).."|"..tostring(modData.specialCoin).."|"..nameTrimmed
            if canStack then
                local g = grouped[key]
                if not g then
                    local v = {}
                    v.type = typeFull
                    v.price = modData.price
                    v.specialCoin = modData.specialCoin
                    v.name = nameTrimmed
                    v.invItem = invItem
                    v.count = 1
                    v.stack = { invItem }
                    grouped[key] = v
                    table.insert(ordered, v)
                else
                    g.count = g.count + 1
                    table.insert(g.stack, invItem)
                    g.invItem = g.stack[#g.stack]
                end
            else
                local v = {}
                if VehicleID then v.VehicleID = VehicleID end
                v.type = typeFull
                v.price = modData.price
                v.specialCoin = modData.specialCoin
                v.name = nameTrimmed
                v.invItem = invItem
                table.insert(ordered, v)
            end
        end
    end
    for _,v in ipairs(ordered) do
        shopItems:addItem(v.type, v)
    end
    self.shopItemsCache[tabType] = shopItems.items
end

function PlayerShopUI:createChildren()
    ISCollapsableWindow.createChildren(self);
    local x = 30
    local y = 85

    local th = self:titleBarHeight();
    self.panel = ISTabPanel:new(0, th, (self.width/2)-25, self.height-10);
    self.panel:initialise();
    self.panel:setAnchorRight(true)
    self.panel:setAnchorBottom(true)
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0};
    self.panel.onActivateView = self.onActivateView;
    self.panel.target = self;
    self.panel:setEqualTabWidth(false)
    self:addChild(self.panel);

    self.emptyShopLabel = ISLabel:new(x + 40, y + 120, self.MEDIUM_FONT_HGT, getText("IGUI_PlayerShop_Empty"), 0.7, 0.7, 0.7, 1, UIFont.Medium, true)
    self.emptyShopLabel:setVisible(false)
    self:addChild(self.emptyShopLabel)

    self:rebuildShopTabs()

    -- вместо кнопки используем полноценную вкладку (Tab.BuyOrders)

    self.clearCartButton = ISButton:new((self.width / 2)+380, y+280, 80,25,UIText.ClearCart,self, PlayerShopUI.clearCartBtn);
    self.clearCartButton:initialise()
    self:addChild(self.clearCartButton);

    self.buyCartButton = ISButton:new((self.width / 2)+200, y+350, 80,25,UIText.BuyCart,self, PlayerShopUI.buyCartBtn);
    self.buyCartButton:initialise()
    self.buyCartButton.enable = false
    self.buyCartButton:setVisible(true)
    self:addChild(self.buyCartButton);

    -- подсказка о нехватке средств (красным), показывается над кнопкой
    self.buyHintLabel = ISLabel:new((self.width / 2)+200, y+330, PlayerShopUI.SMALL_FONT_HGT, "", 1, 0.25, 0.25, 1, UIFont.Small, true)
    self.buyHintLabel:setVisible(false)
    self:addChild(self.buyHintLabel)

    self.cancelBuyButton = ISButton:new((self.width / 2)+200, y+350, 80,25,UIText.Cancel,self, PlayerShopUI.cancelBuyBtn);
    self.cancelBuyButton:initialise()
    self.cancelBuyButton.enable = false
    self.cancelBuyButton:setVisible(false)
    self:addChild(self.cancelBuyButton);

    self.cartTex = ISImage:new(x+905, y-35, 0, 0, cartImg.texture);
    self.cartTex.scaledWidth = cartImg.scale
    self.cartTex.scaledHeight = cartImg.scale
    self:addChild(self.cartTex);

    self.cartItems = ISScrollingListBox:new(x+490, y, (self.width / 3) + 110, self.height/2);
    self.cartItems:initialise();
    self.cartItems:instantiate();
    self.cartItems:setAnchorRight(false)
    self.cartItems:setAnchorBottom(true)
    self.cartItems.font = UIFont.NewSmall;
    self.cartItems.itemheight = 2 + self.MEDIUM_FONT_HGT  + 4;
    self.cartItems.selected = 1;
    self.cartItems.joypadParent = self;
    self.cartItems.drawBorder = false;
    self.cartItems.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.cartItems.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    self.cartItems.doDrawItem = PlayerShopUI.doDrawCartItem;
    self.cartItems.onMouseMove = PlayerShopUI.onMouseMoveCartItem;
    self.cartItems.onMouseDown = PlayerShopUI.onMouseDownCartItem;
    self:addChild(self.cartItems);

    -- Кнопки управления (только для владельца)
    local ownerBtnY = y + 430 -- На 10 выше нижней границы окна (было y + 350)
    local ownerBtnX = 30--(self.width / 2) + 80
    self.manageIncomeBtn = ISButton:new(ownerBtnX, ownerBtnY, 140, 25, getText("IGUI_ViewIncomePlayerShop"), self, function()
        IncomeUI:show(self.player, self.shop)
    end)
    self.manageIncomeBtn:initialise(); self.manageIncomeBtn:setVisible(false)
    self:addChild(self.manageIncomeBtn)

    self.manageBuyBtn = ISButton:new(ownerBtnX + 150, ownerBtnY, 140, 25, getText("IGUI_ManageBuyOrders"), self, function()
        BuyOrdersUI:show(self.player, self.shop)
    end)
    self.manageBuyBtn:initialise(); self.manageBuyBtn:setVisible(false)
    self:addChild(self.manageBuyBtn)

    self.balanceLabel = ISLabel:new(x+490, 20, PlayerShopUI.SMALL_FONT_HGT, UIText.Balance, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.balanceLabel);

    local coinImg = Currency.CoinsTexture.Coin
    self.balanceCoinTex = ISImage:new(x+550, 20, 0, 0, coinImg.texture);
    self.balanceCoinTex.scaledWidth = coinImg.scale+5
    self.balanceCoinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.balanceCoinTex);

    self.balanceCoinLabel = ISLabel:new(x+575, 20, PlayerShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.balanceCoinLabel);

    self.coinTex = ISImage:new(x+535, y+280, 0, 0, coinImg.texture);
    self.coinTex.scaledWidth = coinImg.scale+5
    self.coinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.coinTex);

    self.totalLabel = ISLabel:new(x+490, y+280, PlayerShopUI.SMALL_FONT_HGT, UIText.Total, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalLabel);

    self.totalCoinLabel = ISLabel:new(x+560, y+280, PlayerShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalCoinLabel);

    coinImg = Currency.CoinsTexture.SpecialCoin
    self.balanceSpecialCoinTex = ISImage:new(x+550, 45, 0, 0, coinImg.texture);
    self.balanceSpecialCoinTex.scaledWidth = coinImg.scale+5
    self.balanceSpecialCoinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.balanceSpecialCoinTex);

    self.balanceSpecialCoinLabel = ISLabel:new(x+575, 45, PlayerShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.balanceSpecialCoinLabel);

    self.specialCoinTex = ISImage:new(x+535, y+305, 0, 0, coinImg.texture);
    self.specialCoinTex.scaledWidth = coinImg.scale+5
    self.specialCoinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.specialCoinTex);

    self.totalSpecialCoinLabel = ISLabel:new(x+560, y+305, PlayerShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalSpecialCoinLabel);

    if not Currency.UseSpecialCoin then
        self.balanceSpecialCoinTex:setVisible(false)
        self.balanceSpecialCoinLabel:setVisible(false)
        self.specialCoinTex:setVisible(false)
        self.totalSpecialCoinLabel:setVisible(false)
    end
    self:checkShopOwner()
end

-- Добавить выбранный ордер в корзину (продажа игроком в магазин): одна штука
function PlayerShopUI:addOrderToCart(row)
    local item = row.item
    if not item or not item.orderKey then return end
    -- ограничение: не больше, чем есть у игрока и чем осталось в ордере
    local inv = self.player and self.player:getInventory() or nil
    local have = 0
    if inv then
        if item.onlyFull then
            local list = inv:getAllTypeRecurse(item.type)
            if list then
                for i=0,list:size()-1 do
                    local it = list:get(i)
                    if it and it:getConditionMax() > 0 and it:getCondition() == it:getConditionMax() and not it:isFavorite() then
                        have = have + 1
                    end
                end
            end
        else
            local list = inv:getAllTypeRecurse(item.type)
            if list then 
                for i=0,list:size()-1 do
                    local it = list:get(i)
                    if not it:isFavorite() then
                        have = have + 1
                    end
                end
            end
        end
    end
    -- уже запланировано в корзине по типу (учитываем суммарно) и по всем ордерам
    local plannedAny = 0
    local plannedByOrderKey = 0
    for _,ci in ipairs(self.cartItems.items) do
        local it = ci.item
        if it then
            if it.type == item.type then plannedAny = plannedAny + (it.units or 1) end
            if it.orderKey == item.orderKey then plannedByOrderKey = plannedByOrderKey + (it.units or 1) end
        end
    end
    local remainingOrder = row.item.count or 0
    if plannedAny >= have then
        if self.player then self.player:setHaloNote(getText("IGUI_PlayerShop_NotEnoughItems"), 255,255,255,400) end
        return
    end
    if remainingOrder - plannedByOrderKey <= 0 then
        if self.player then self.player:setHaloNote(getText("IGUI_PlayerShop_OrderExhausted"), 255,255,255,400) end
        return
    end
    -- попробуем найти в корзине уже добавленный такой же ордер и увеличить количество
    local unitPrice = item.price
    for _,ci in ipairs(self.cartItems.items) do
        local it = ci.item
        if it and it.orderKey == item.orderKey then
            it.units = (it.units or 1) + 1
            it.price = unitPrice * it.units
            -- визуально уменьшим доступное количество в списке ордеров
            if row.item.count and row.item.count > 0 then row.item.count = row.item.count - 1 end
            self:updateTotal()
            self.cartItems:setYScroll(-10000)
            return
        end
    end
    -- впервые добавляем ордер в корзину
    local orderEntry = {
        name = item.name,
        price = unitPrice, -- общая цена = unitPrice * units
        unitPrice = unitPrice,
        units = 1,
        specialCoin = item.specialCoin,
        type = item.type,
        orderKey = item.orderKey,
        onlyFull = item.onlyFull and true or false,
        invItem = (pcall(InventoryItemFactory.CreateItem, item.type) and InventoryItemFactory.CreateItem(item.type)) or nil
    }
    if row.item.count and row.item.count > 0 then row.item.count = row.item.count - 1 end
    self.cartItems:addItem(item.type, orderEntry)
    self.cartItems:setYScroll(-10000)
end

-- Массовое добавление: максимум по предметам, остатку ордера и бюджету кассы
function PlayerShopUI:addOrderToCartAll(row)
    local item = row and row.item
    if not item or not item.orderKey then return end
    local unitPrice = tonumber(item.price) or 0
    if unitPrice <= 0 then return end

    -- сколько предметов у игрока по типу (и полных для onlyFull)
    local inv = self.player and self.player:getInventory() or nil
    local haveAll, haveFull = 0, 0
    if inv then
        local list = inv:getAllTypeRecurse(item.type)
        if list then
            for i = 0, list:size() - 1 do
                local it = list:get(i)
                if it and not it:isFavorite() then
                    haveAll = haveAll + 1
                    if it.getConditionMax and it:getConditionMax() > 0 and it:getCondition() == it:getConditionMax() then
                        haveFull = haveFull + 1
                    end
                end
            end
        end
    end

    -- уже запланировано в корзине по типу
    local plannedAny, plannedFull = 0, 0
    local cartSumCoin, cartSumSpec = 0, 0
    for _,ci in ipairs(self.cartItems.items) do
        local it = ci.item
        if it then
            if it.type == item.type then
                local u = it.units or 1
                plannedAny = plannedAny + u
                if it.onlyFull then plannedFull = plannedFull + u end
            end
            if it.orderKey then
                if it.specialCoin then cartSumSpec = cartSumSpec + (it.price or 0)
                else cartSumCoin = cartSumCoin + (it.price or 0) end
            end
        end
    end

    local remainingOrder = tonumber(row.item.count) or 0
    local haveEffective = item.onlyFull and haveFull or haveAll
    -- ВАЖНО: чтобы не превысить общее физическое количество,
    -- считаем зарезервированное всегда по plannedAny (консервативно)
    local plannedEffective = plannedAny
    local maxByItems = math.max(0, math.min(haveEffective - plannedEffective, remainingOrder))
    if maxByItems <= 0 then
        if remainingOrder <= 0 then
            if self.player then self.player:setHaloNote(getText("IGUI_PlayerShop_OrderExhausted"), 255,255,255,400) end
        else
            if self.player then self.player:setHaloNote(getText("IGUI_PlayerShop_NotEnoughItems"), 255,255,255,400) end
        end
        return
    end

    -- бюджет кассы (учитываем доход, если включен)
    local md = self.shop and self.shop:getModData() or {}
    md.cash = md.cash or { coin = 0, specialCoin = 0 }
    local availCoin = tonumber(md.cash.coin) or 0
    local availSpec = tonumber(md.cash.specialCoin) or 0
    if md.useIncome then
        local sumCoin, sumSpec = 0, 0
        for _,v in pairs(md.income or {}) do
            sumCoin = sumCoin + (v.t and v.t.tl or 0)
            sumSpec = sumSpec + (v.t and v.t.tls or 0)
        end
        availCoin = availCoin + sumCoin
        availSpec = availSpec + sumSpec
    end
    local budgetLeft = item.specialCoin and (availSpec - cartSumSpec) or (availCoin - cartSumCoin)
    budgetLeft = math.max(0, budgetLeft)
    local maxByCash = math.floor(budgetLeft / unitPrice)
    if maxByCash < 0 then maxByCash = 0 end

    local canAdd = math.min(maxByItems, maxByCash)
    if canAdd <= 0 then
        if self.player then self.player:setHaloNote(getText("IGUI_Shop_NotEnoughRegister"), 255,255,255,400) end
        return
    end

    -- агрегированно кладём в корзину
    for _,ci in ipairs(self.cartItems.items) do
        local it = ci.item
        if it and it.orderKey == item.orderKey then
            it.units = (it.units or 1) + canAdd
            it.price = unitPrice * it.units
            if row.item.count and row.item.count > 0 then row.item.count = math.max(0, row.item.count - canAdd) end
            self:updateTotal()
            self.cartItems:setYScroll(-10000)
            return
        end
    end

    local sample = nil
    pcall(function() sample = InventoryItemFactory.CreateItem(item.type) end)
    local orderEntry = {
        name = item.name,
        price = unitPrice * canAdd,
        unitPrice = unitPrice,
        units = canAdd,
        specialCoin = item.specialCoin,
        type = item.type,
        orderKey = item.orderKey,
        onlyFull = item.onlyFull and true or false,
        invItem = sample
    }
    if row.item.count and row.item.count > 0 then row.item.count = math.max(0, row.item.count - canAdd) end
    self.cartItems:addItem(item.type, orderEntry)
    self.cartItems:setYScroll(-10000)
end

function PlayerShopUI:activateFirstTab()
    if not self.panel or not self.panel.viewList[1] then return end
    self.panel:activateView(self.panel.viewList[1].name)
    self:onActivateView()
end

function PlayerShopUI:removeFromCart(selectedRow)
    if self.actionInProgress then return end
    if not self.panel.activeView or not self.panel.activeView.view then return end
    self:toggleTooltip(false)
    local tab = self.panel.activeView.view
    local item = selectedRow.item
    local rekey = item.type.."|"..tostring(item.price).."|"..tostring(item.specialCoin).."|"..item.name
    local items = tab.shopItems.items
    local stacked = false
    if item.orderKey then
        -- для ордеров на скупку уменьшаем units, либо удаляем строку
        if item.units and item.units > 1 then
            item.units = item.units - 1
            item.price = (item.unitPrice or item.price) * item.units
            -- вернем 1 в доступное количество на панели ордеров
            for _,row in ipairs(items) do
                local ritem = row.item
                if ritem and ritem.orderKey == item.orderKey then
                    ritem.count = (ritem.count or 0) + 1
                    break
                end
            end
            return
        else
            -- снимаем строку целиком
            for _,row in ipairs(items) do
                local ritem = row.item
                if ritem and ritem.orderKey == item.orderKey then
                    ritem.count = (ritem.count or 0) + 1
                    break
                end
            end
            self.cartItems:removeItem(selectedRow.text)
            return
        end
    else
        for _,row in ipairs(items) do
            local ritem = row.item
            if ritem and ritem.count and (ritem.type.."|"..tostring(ritem.price).."|"..tostring(ritem.specialCoin).."|"..ritem.name) == rekey then
                ritem.count = ritem.count + 1
                ritem.stack = ritem.stack or {}
                table.insert(ritem.stack, item.invItem or item)
                ritem.invItem = ritem.stack[#ritem.stack]
                stacked = true
                break
            end
        end
        if not stacked then
            if not item.VehicleID and (not (item.invItem and item.invItem:IsInventoryContainer())) then
                item.count = 1
                item.stack = { item.invItem or item }
            end
            tab.shopItems:addItem(item.type,item)
        end
        self.cartItems:removeItem(selectedRow.text)
    end
end

function PlayerShopUI:clearCartBtn()
    if self.actionInProgress then return end
    self.cartItems:clear()
    self:activateFirstTab()
end

function PlayerShopUI:cancelBuyBtn()
    self.buyCartButton.enable = true
    self.buyCartButton:setVisible(true)
    self.cancelBuyButton.enable = false
    self.cancelBuyButton:setVisible(false)
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then return end
    if not (currentAction.Type == "PlayerShopBuyAction") then return end
    currentAction.action:forceStop()
end

function PlayerShopUI:buyCartBtn()
    if not self.panel.activeView or not self.panel.activeView.view then return end
    -- Запускаем покупку без закрытия окна; блокировка магазина уже установлена при открытии
    self.actionInProgress = true
    local ticket = {}
    local tabType = self.panel.activeView.view.tabType
    if tabType == "BuyOrders" then
        -- при скупке игрок не платит
        ticket.coin = 0
        ticket.specialCoin = 0
    else
        ticket.coin = self.total
        ticket.specialCoin = self.totalSpecial
    end
    local action = PlayerShopBuyAction:new(self.player,self,ticket);
    ISTimedActionQueue.add(action);
    self.buyCartButton.enable = false
    self.buyCartButton:setVisible(false)
    self.cancelBuyButton.enable = true
    self.cancelBuyButton:setVisible(true)
end

function PlayerShopUI:render()
    ISCollapsableWindow.render(self);
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then self.actionInProgress = false return end
    if not (currentAction.Type == "PlayerShopBuyAction") then self.actionInProgress = false return end
    self:drawProgressBar((self.width / 2)+180, 420, 120, 10, currentAction.action:getJobDelta(), self.fgBar)
end

function PlayerShopUI:updateTotal()
    local total = 0
    local totalSpecial = 0
    self.totalCoinLabel:setName(""..total)
    self.totalSpecialCoinLabel:setName(""..totalSpecial)
    for k,v in pairs(self.cartItems.items) do
        local cost = v.item.price
        if not v.item.specialCoin then
            total = total + cost
        else
            totalSpecial = totalSpecial + cost
        end
    end
    if total > 0 then
        local totalFormat = Currency.format(total)
        self.totalCoinLabel:setName(""..totalFormat)
    end
    if totalSpecial > 0 then
        local totalSpecialFormat = Currency.format(totalSpecial)
        self.totalSpecialCoinLabel:setName(""..totalSpecialFormat)
    end

    self.buyCartButton.enable = false
    self.buyCartButton:setVisible(true)
    self.cancelBuyButton.enable = false
    self.cancelBuyButton:setVisible(false)
    self.total = total
    self.totalSpecial = totalSpecial
    self:checkShopOwner()
    if total == 0 and totalSpecial == 0 then return end
    if not self.panel.activeView or not self.panel.activeView.view then return end

    -- Вкл/выкл кнопки: для вкладки Скупка используем кассу магазина (+ доход, если разрешено), иначе баланс игрока
    local tabType = self.panel.activeView.view.tabType
    if tabType == "BuyOrders" then
        local md = self.shop:getModData()
        md.cash = md.cash or {coin=0,specialCoin=0}
        local coin = md.cash.coin or 0
        local specialCoin = md.cash.specialCoin or 0
        if md.useIncome then
            local sumCoin, sumSpec = 0, 0
            for _,v in pairs(md.income or {}) do
                sumCoin = sumCoin + (v.t and v.t.tl or 0)
                sumSpec = sumSpec + (v.t and v.t.tls or 0)
            end
            coin = coin + sumCoin
            specialCoin = specialCoin + sumSpec
        end
        if coin >= total and specialCoin >= totalSpecial then
            self.buyCartButton.enable = true
            self.buyCartButton:setVisible(true)
            self.cancelBuyButton.enable = false
            self.cancelBuyButton:setVisible(false)
            if self.buyHintLabel then self.buyHintLabel:setVisible(false) end
        end
        if (coin < total) or (specialCoin < totalSpecial) then
            if self.buyHintLabel then
                local msg = getText("IGUI_Shop_NotEnoughRegister")
                self.buyHintLabel:setName(msg)
                self.buyHintLabel:setVisible(true)
            end
        end
    else
        local username = self.player:getUsername()
        local coin,specialCoin = Balance.getUserBalance(username)
        if coin >= total and specialCoin >= totalSpecial then
            self.buyCartButton.enable = true
            self.buyCartButton:setVisible(true)
            self.cancelBuyButton.enable = false
            self.cancelBuyButton:setVisible(false)
            if self.buyHintLabel then self.buyHintLabel:setVisible(false) end
        end
        if (coin < total) or (specialCoin < totalSpecial) then
            if self.buyHintLabel then
                local msg = getText("IGUI_Shop_NotEnoughBalance")
                self.buyHintLabel:setName(msg)
                self.buyHintLabel:setVisible(true)
            end
        end
    end
    self:checkShopOwner()
end

function PlayerShopUI:checkShopOwner()
    if not PlayerShopUI.instance then
        return
    end
    local md = self.shop and self.shop:getModData() or {}
    local shopOwner = md.owner or PlayerShopUI.instance.shopOwner
    local playerName = self.player:getUsername()
    if shopOwner == playerName then
        self.buyCartButton.enable = false
        self.buyCartButton:setVisible(false)
    end
    if shopOwner == playerName or isAdmin() then
        if self.manageIncomeBtn then self.manageIncomeBtn:setVisible(true) end
        if self.manageBuyBtn then self.manageBuyBtn:setVisible(true) end
    else
        if self.manageIncomeBtn then self.manageIncomeBtn:setVisible(false) end
        if self.manageBuyBtn then self.manageBuyBtn:setVisible(false) end
    end
end

function PlayerShopUI:close()
	ISCollapsableWindow.close(self);
    local shop = PlayerShopUI.instance.shop
    local username = self.player:getUsername()
    if PlayerShop.isBlockByUser(shop,username) then
        PlayerShop.toggleBusy(shop,username,false)
    end
    if PreviewUI.instance then PreviewUI.instance:close() end
    if ContainerViewerUI.instance then ContainerViewerUI.instance:close() end
    for k,v in pairs(PlayerShopUI.cvUis) do
        if v then
            v:close()
        end
    end
    PlayerShopUI.cvUis = {}
    PlayerShopUI.instance:removeFromUIManager()
    PlayerShopUI.instance = nil
    self:removeFromUIManager()
end

function PlayerShopUI:new(x, y, width, height, player,shopOwner)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2);
        y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    self.__index = self
    local shopTitle = getText("IGUI_TitlePlayerShop",shopOwner)
    o.title = shopTitle
    o.player = player
    o.resizable = false;
    return o
end