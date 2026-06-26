local Nfunction = require "Nfunction"
require "ISUI/ShopUIMode"
ShopUI = ISCollapsableWindow:derive("ShopUI");
ShopUI.instance = nil;
ShopUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ShopUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
ShopUI.removeButtonX = 380
ShopUI.previewButtonX = ShopUI.removeButtonX + 25
ShopUI.shopItemsCache = {}
ShopUI.total = 0
ShopUI.totalSpecial = 0
ShopUI.actionInProgress = false
ShopUI.reloadItems = false
ShopUI.lastTab = "none"
ShopUI.ItemInstanceCache = {}
local posX = 0
local posY = 0

local removeBtn = Shop.textures.RemoveButton;
local previewBtn = Shop.textures.PreviewButton;
local cartImg = Shop.textures.Cart;
local width = 995
local height = 550


function ShopUI:show(player,viewMode,shop) --Вызов интерфейса магазина
    sendClientCommand(getPlayer(), 'shopItems', 'getData', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'shopItems' then return; end
        if command == 'onGetData' then
            Shop.Items = args['shopItems']
            Shop.Sell = args['forSellItems']
            Events.OnServerCommand.Remove(receiveServerCommand)

            local square = player:getSquare()
            posX = square:getX()
            posY = square:getY()
            if ShopUI.instance == nil or not ShopUI.instance.totalCoinLabel or not ShopUI.instance.contentPanel then
                if ShopUI.instance then
                    ShopUI.instance:removeFromUIManager()
                end
                local inst = ShopUI:new(0, 0, width, height, player)
                inst.shop = shop
                inst.viewMode = viewMode
                inst:initialise()
                inst:instantiate()
                ShopUI.instance = inst
            end
            ShopUI.instance.reloadItems = true
            ShopUI.instance.shopMode = ShopUI.instance.shopMode or "buy"
            ShopUI.instance.pinButton:setVisible(false)
            ShopUI.instance.collapseButton:setVisible(false)
            ShopUIMode.updateModeButtons(ShopUI.instance)
            ShopUI.instance:addToUIManager();
            ShopUI.instance:setVisible(true);
            return ShopUI.instance;
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand);
end

function ShopUI:update()
    if not self.viewMode then
        local player = self.player
        if player:DistTo(posX, posY) > 2 then
            self:close()
        end
    end
    local username = self.player:getUsername()    
    local coin,specialCoin = Balance.getUserBalance(username)
    local coinFormatted = Currency.format(coin)
    if self.balanceCoinLabel then self.balanceCoinLabel:setName(""..coinFormatted) end
    if self.balanceSpecialCoinLabel and Currency.UseSpecialCoin then
        local specialCoinFormatted = Currency.format(specialCoin)
        self.balanceSpecialCoinLabel:setName(""..specialCoinFormatted)
    end
    if self.actionInProgress then 
        self.buyCartButton.enable = false
        self.buyCartButton:setVisible(false)
        self.sellCartButton.enable = false
        self.sellCartButton:setVisible(false)
        self.cancelBuyButton.enable = true
        self.cancelBuyButton:setVisible(true)
        return 
    end
    self:updateTotal()
end

function ShopUI:doDrawCartItem(y, item, alt)
    local baseItemDY = 0
    if item.item.name then
        baseItemDY = self.SMALL_FONT_HGT
        item.height = self.itemheight + baseItemDY
    end

    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local lay = ShopUIMode.getCartRowLayout(self:getWidth())
    local a = 0.9;
    self:drawRectBorder(0, (y), self:getWidth(), item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), item.height - 1, 0.3, 0.7, 0.35, 0.15);
    end

    local quantity = ""
    if item.item.quantity then
        quantity = " ("..item.item.quantity..")"
    end
    local displayName = Nfunction.trimString(item.item.name..quantity, lay.nameMaxChars)
    self:drawText(displayName, 40, y + 10, 1, 1, 1, a, UIFont.Small);
    if item.item.price then
        local coinImg = Currency.CoinsTexture.Coin
        if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
        self:drawTextureScaledAspect(coinImg.texture, lay.coinX, y + 10, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
        local priceFormatted = Currency.format(item.item.price)
        self:drawText(""..priceFormatted, lay.textX, y + 8, 1, 1, 1, a, UIFont.Small);
    end

    if item.item.invItem or item.item.texture then
        local texture = item.item.texture
        if not texture then
            texture = item.item.invItem:getTex()
        end
        self:drawTextureScaledAspect(texture, 6, y+5, 30, 30, 1, 1, 1, 1)
    end

    self:drawTextureScaledAspect(removeBtn.texture, lay.removeX, y + 10, removeBtn.scale, removeBtn.scale, 1, 1, 1, 1)

    if item.item.VehicleID then
        self:drawTextureScaledAspect(previewBtn.texture, lay.previewX, y + 10, previewBtn.scale, previewBtn.scale, 1, 1, 1, 1)
    end

    return y + item.height;
end

function ShopUI:getActiveTab()
    return ShopUIMode.getActiveTab(self)
end

function ShopUI:onMouseMove(dx, dy)
    self.mouseOver = true;
	if self.moving then
		self:setX(self.x + dx);
		self:setY(self.y + dy);
		self:bringToTop();
	end
    local tab = ShopUI.instance:getActiveTab()
    if tab and tab.shopItems and tab.shopItems:isMouseOver() then return end
    if ShopUI.instance.cartItems:isMouseOver() then return end
    ShopUI.instance:toggleTooltip(false)
end

function ShopUI:onMouseDown(x, y)
    ISCollapsableWindow.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
end

function ShopUI:onMouseDownCartItem(x, y)
    ISScrollingListBox.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
	if self.selectedRow then
        local selectedRow = self.items[self.selectedRow]
        if not selectedRow then return end
        if self.previewBtn then
            if not selectedRow.item.VehicleID then return end
            PreviewUI:show(selectedRow.item.name,selectedRow.item.VehicleID)
            return
        end
        if self.removeBtn then
		    ShopUI.instance:removeFromCart(selectedRow)
        end
    end
end

local currentTooltip = nil
local invTooltip = nil
local itemPackTooltip = nil
function ShopUI:toggleTooltip(show,item)
    if item then
        if item.invItem then
            if not invTooltip then
                invTooltip = ISToolTipInv:new(item.invItem)
            end
            currentTooltip = invTooltip
            item = item.invItem
            if itemPackTooltip then
                itemPackTooltip:removeFromUIManager()
                itemPackTooltip:setVisible(false)
            end
        else
            if not itemPackTooltip then
                itemPackTooltip = ShopUITooltip:new();
            end
            if invTooltip then
                invTooltip:removeFromUIManager()
                invTooltip:setVisible(false)
            end
            currentTooltip = itemPackTooltip
        end
        currentTooltip:initialise();
        currentTooltip:addToUIManager()
        currentTooltip:setItem(item);
        currentTooltip:setOwner(self)
        currentTooltip:render();
        currentTooltip:setVisible(true)  
    end
    if not show and currentTooltip then
        currentTooltip:removeFromUIManager()
        currentTooltip:setVisible(false)
    end
end

function ShopUI:onMouseMoveCartItem(dx, dy)
    local list = ShopUI.instance.cartItems
    if not list then return end
    list.selectedRow = nil
    list.previewBtn = nil
    list.removeBtn = nil
	if list:isMouseOverScrollBar() or not list:isMouseOver() then ShopUI.instance:toggleTooltip(false) return end
	local rowIndex = list:rowAt(list:getMouseX(), list:getMouseY())
    if not rowIndex then ShopUI.instance:toggleTooltip(false) return end
    local selectedRow = list.items[rowIndex]
    if not selectedRow then ShopUI.instance:toggleTooltip(false) return end
    local mouseX = self:getMouseX()
    list.selectedRow = rowIndex
    local lay = ShopUIMode.getCartRowLayout(list:getWidth())
    if mouseX > lay.removeX then
        list.removeBtn = true
    end
    if mouseX > lay.previewX and mouseX < lay.removeX then
        list.previewBtn = true
    end
    if not selectedRow.item.items then ShopUI.instance:toggleTooltip(false) return end
    ShopUI.instance:toggleTooltip(true,selectedRow.item)
end

---@return InventoryItem
function ShopUI:getItemInstance(type)
    local item = self.ItemInstanceCache[type]
    if not item then
        item = InventoryItemFactory.CreateItem(type)
        if item then
            self.ItemInstanceCache[type] = item
        end
    end
    return item
end

function ShopUI:isSellMode()
    return ShopUIMode.isSellMode(self)
end

function ShopUI:onActivateView()
    local character = self.player
    if not character:getModData().shopFavorites then
        character:getModData().shopFavorites = {}
    end
    local tab = self:getActiveTab()
    if not tab then return end
    local tabType = tab.tabType
    local shopItems = tab.shopItems

    if self.reloadItems then
        shopItems:clear() 
    end

    if self.lastTab == Tab.Sell or self:isSellMode() or tabType == Tab.Sell then
        self.cartItems:clear()
    end
    self.lastTab = tabType

    if self:isSellMode() or tabType == Tab.Sell then
        tab.moveAllButton.enable = true
        tab.moveAllButton:setVisible(true)
        shopItems:clear()
        if not self.viewMode then
            self.sellCartButton.enable = false
            self.sellCartButton:setVisible(true)
            self.buyCartButton.enable = false
            self.buyCartButton:setVisible(false)
        end
        local inventory = character:getInventory():getItems()
        for i = 0, inventory:size() -1 do
            local item = inventory:get(i)
            local itemType = item:getFullType()
            local itemSell = Shop.Sell[itemType]
            local isBroken = item:isBroken()
            if not (Shop.SellisBlacklist and itemSell) then
                if not (item:isEquipped() or item:isFavorite() or Currency.Coins[itemType]) then
                    if not (itemSell and itemSell.blacklisted) then
                        local v = {}
                        v.type = itemType
                        local price = Shop.defaultPrice
                        if isBroken then price = Shop.defaultPriceBroken end
                        if itemSell then
                            v.specialCoin = itemSell.specialCoin
                            if isBroken then
                                price = itemSell.priceBroken or Shop.defaultPriceBroken
                            else
                                price = itemSell.price or Shop.defaultPrice
                            end
                        end
                        v.priceFull = price
                        price = Nfunction.drainablePrice(item,price)
                        v.price = price
                        v.id = item:getID()
                        v.name = Nfunction.trimString(item:getName(),42)
                        v.invItem = item
                        if price > 0 then
                            if Shop.SellisWhitelist then 
                                if itemSell then
                                    shopItems:addItem(itemType,v);
                                end
                            else
                                shopItems:addItem(itemType,v);
                            end
                        end
                    end
                end
            end
        end
        if tab.relayout then tab:relayout() end
        return
    else
        if self.sellCartButton then
            self.sellCartButton.enable = false
            self.sellCartButton:setVisible(false)
            self.buyCartButton:setVisible(true)
        end
    end

    if not self.reloadItems then
        if self.shopItemsCache[tabType] then
            shopItems.items = self.shopItemsCache[tabType]
            ShopUIMode.sortFavoritesFirst(shopItems.items)
            if (tab.filterEntry and tab.filterEntry:getInternalText() ~= "") or (tab.favoritesOnlyTick and tab.favoritesOnlyTick:isSelected(1)) then
                tab:applyListFilter()
            end
            if tab.relayout then tab:relayout() end
            return
        end
    end

    shopItems:clear()
    for k,v in pairs(Shop.Items) do
        if v and (v.tab == tabType or tabType == Tab.All) then
            local item = self:getItemInstance(k)
            if item then
                local VehicleID = item:getModData().VehicleID
                if VehicleID then v.VehicleID = VehicleID end
                v.favorite = character:getModData().shopFavorites[k]
                v.type = k
                if not v.items then
                    v.invItem = item
                else
                    v.texture = item:getTex()
                end
                v.name = Nfunction.trimString(item:getName(),42)
                shopItems:addItem(k,v);
            end
        end
    end
    ShopUIMode.sortFavoritesFirst(shopItems.items)
    self.shopItemsCache[tabType] = shopItems.items
    self.reloadItems = false
    if (tab.filterEntry and tab.filterEntry:getInternalText() ~= "") or (tab.favoritesOnlyTick and tab.favoritesOnlyTick:isSelected(1)) then
        tab:applyListFilter()
    end
    if tab.relayout then tab:relayout() end
end

function ShopUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    ShopUIMode.setupShopLayout(self)
end

function ShopUI:removeFromCart(selectedRow)
    if self.actionInProgress then return end
    self:toggleTooltip(false)
    local tab = self:getActiveTab()
    if not tab then return end
    if self:isSellMode() or tab.tabType == Tab.Sell then
        tab.shopItems:addItem(selectedRow.item.type,selectedRow.item)
    end
    self.cartItems:removeItem(selectedRow.text)
end

function ShopUI:clearCartBtn()
    if self.actionInProgress then return end
    local tab = self:getActiveTab()
    if not tab then return end
    if self:isSellMode() or tab.tabType == Tab.Sell then
        for k,v in pairs(self.cartItems.items) do
            tab.shopItems:addItem(v.item.type,v.item)
        end
    end
    self.cartItems:clear()
end

function ShopUI:cancelBuyBtn()
    if self:isSellMode() then
        self.sellCartButton.enable = true
        self.sellCartButton:setVisible(true)
    else
        self.buyCartButton.enable = true
        self.buyCartButton:setVisible(true)
    end
    self.cancelBuyButton.enable = false
    self.cancelBuyButton:setVisible(false)
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then return end
    if not (currentAction.Type == "ShopBuyAction" or currentAction.Type == "ShopSellAction") then return end
    currentAction.action:forceStop()
end

function ShopUI:buyCartBtn()
    self.actionInProgress = true
    local ticket = {}
    ticket.coin = self.total
    ticket.specialCoin = self.totalSpecial
    local action = ShopBuyAction:new(self.player,self,ticket);
    ISTimedActionQueue.add(action);
    self.buyCartButton.enable = false
    self.buyCartButton:setVisible(false)
    self.cancelBuyButton.enable = true
    self.cancelBuyButton:setVisible(true)
end

function ShopUI:sellCartBtn()
    self.actionInProgress = true
    local action = ShopSellAction:new(self.player,self);
    ISTimedActionQueue.add(action);
    self.sellCartButton.enable = false
    self.sellCartButton:setVisible(false)
    self.cancelBuyButton.enable = true
    self.cancelBuyButton:setVisible(true)
end

function ShopUI:render()
    ISCollapsableWindow.render(self);
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then self.actionInProgress = false return end
    if not (currentAction.Type == "ShopBuyAction" or currentAction.Type == "ShopSellAction") then self.actionInProgress = false return end
    local barX, barY, barW, barH = ShopUIMode.getCartProgressBarLayout(self)
    self:drawProgressBar(barX, barY, barW, barH, currentAction.action:getJobDelta(), self.fgBar)
end

function ShopUI:updateTotal() --Обновление баланса
    if not self.totalCoinLabel then return end
    local total = 0
    local totalSpecial = 0
    self.totalCoinLabel:setName(""..total)
    if self.totalSpecialCoinLabel then self.totalSpecialCoinLabel:setName(""..totalSpecial) end
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
    if totalSpecial > 0 and self.totalSpecialCoinLabel then
        local totalSpecialFormat = Currency.format(totalSpecial)
        self.totalSpecialCoinLabel:setName(""..totalSpecialFormat)
    end
    ShopUIMode.pinCartFooter(self)
    if self.viewMode then return end

    local tab = self:getActiveTab()
    if not tab then return end
    local tabType = tab.tabType
    if self:isSellMode() or tabType == Tab.Sell then
        self.sellCartButton.enable = false
        self.sellCartButton:setVisible(true)
    else
        self.buyCartButton.enable = false
        self.buyCartButton:setVisible(true)
    end
    self.cancelBuyButton.enable = false
    self.cancelBuyButton:setVisible(false)
    self.total = total
    self.totalSpecial = totalSpecial
    if total == 0 and totalSpecial == 0 then return end

    local username = self.player:getUsername()
    local coin,specialCoin = Balance.getUserBalance(username)
    if (self:isSellMode() or tabType == Tab.Sell) and (total > 0 or totalSpecial > 0) then
        self.buyCartButton.enable = false
        self.buyCartButton:setVisible(false)
        self.sellCartButton.enable = true
        self.sellCartButton:setVisible(true)
        self.cancelBuyButton.enable = false
        self.cancelBuyButton:setVisible(false)
        return
    end
    if coin >= total and specialCoin >= totalSpecial and not self:isSellMode() and not (tabType==Tab.Sell) then
        self.buyCartButton.enable = true
        self.buyCartButton:setVisible(true)
        self.sellCartButton.enable = false
        self.sellCartButton:setVisible(false)
        self.cancelBuyButton.enable = false
        self.cancelBuyButton:setVisible(false)
    end
end

function ShopUI:close() --Закрытие окна
	ISCollapsableWindow.close(self);
    if PreviewUI.instance then PreviewUI.instance:close() end
    ShopUI.instance:removeFromUIManager()
    ShopUI.instance = nil
    self:removeFromUIManager()
end

function ShopUI:new(x, y, width, height, player) --Создание окна магазина
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2);
        y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    self.__index = self
    o.shopMode = "buy"
    o.title = UIText.ShopUITitle;
    o.player = player
    o.resizable = false
    o.shopItemsCache = {}
    o.ItemInstanceCache = {}
    return o
end