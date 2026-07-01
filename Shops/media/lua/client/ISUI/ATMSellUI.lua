-- \Shops\media\lua\client\ISUI\ATMSellUI.lua
require "ISUI/ShopUIMode"
local Nfunction = require "Nfunction"

ATMSellUI = ISCollapsableWindow:derive("ATMSellUI");
ATMSellUI.instance = nil;
ATMSellUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ATMSellUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

local width = 780
local height = 450

local addBtn = Shop.textures.AddButton
local removeBtn = Shop.textures.RemoveButton

local function GetSellItems(callback)
    sendClientCommand(getPlayer(), 'shopItems', 'getData', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'shopItems' then return; end
        if command == 'onGetData' then
            if callback then callback(args['forSellItems']) end
            Events.OnServerCommand.Remove(receiveServerCommand)
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end

local function buildSellList(character, sellItems, excludeIds)
	local list = {}
	local inv = character:getInventory():getItems()
	for i = 0, inv:size() - 1 do
		local item = inv:get(i)
		if not (item:isEquipped() or item:isFavorite()) then
			local itemId = item:getID()
			if not (excludeIds and excludeIds[itemId]) then
				local itemType = item:getFullType()
				local itemSell = sellItems[itemType]
				local isBroken = item:isBroken()
				if not (Shop.SellisBlacklist and itemSell) then
					if not Currency.Coins[itemType] then
						if not (itemSell and itemSell.blacklisted) then
							local v = {}
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
							v.price = Nfunction.drainablePrice(item, price)
							if v.price > 1 then
								v.id = itemId
								v.type = itemType
								v.name = Nfunction.trimString(item:getName(), 32)
								v.invItem = item
								table.insert(list, v)
							end
						end
					end
				end
			end
		end
	end
	return list
end

local function getCartIds(cartItems)
	local ids = {}
	if cartItems and cartItems.items then
		for i = 1, #cartItems.items do
			ids[cartItems.items[i].item.id] = true
		end
	end
	return ids
end

local function stackKeyFor(v)
	local spec = v.specialCoin and "s" or "c"
	return v.type .. "_" .. spec .. "_" .. tostring(v.priceFull) .. "_" .. tostring(v.price)
end

local function groupStacks(flatList)
	local groups = {}
	local order = {}
	for _, v in ipairs(flatList) do
		local key = stackKeyFor(v)
		local g = groups[key]
		if not g then
			g = {
				stackKey = key,
				type = v.type,
				name = v.name,
				specialCoin = v.specialCoin,
				price = v.price,
				priceFull = v.priceFull,
				invItem = v.invItem,
				entries = {},
				isStack = true,
			}
			groups[key] = g
			table.insert(order, g)
		end
		table.insert(g.entries, v)
	end
	for _, g in ipairs(order) do
		g.count = #g.entries
		if g.count > 1 then
			g.displayName = Nfunction.trimString(g.name, 26) .. " (x" .. g.count .. ")"
		else
			g.displayName = g.name
		end
	end
	return order
end

local function itemKey(item)
	return item.type .. "_" .. item.id
end

local BTN_SIZE = addBtn.scale
local BTN_RIGHT_MARGIN = 6
local PRICE_BTN_GAP = 8
local COIN_PRICE_GAP = 5

local function getAtmRowLayout(listW)
	local w = listW or 200
	local pad = ShopUIMode.LIST_SCROLL_PAD
	local rowW = w - pad
	return {
		btnX = rowW - BTN_RIGHT_MARGIN - BTN_SIZE,
		rowW = rowW,
	}
end

local function drawListItem(self, y, item, alt, isInventory)
	local a = 0.95
	local lay = getAtmRowLayout(self:getWidth())

	if self.selected == item.index then
		self:drawRect(0, (y), lay.rowW, self.itemheight - 1, 0.4, 0.2, 0.6, 0.3);
		self:drawRectBorder(0, (y), lay.rowW, self.itemheight - 1, a, 0.8, 0.4, 1.0);
	else
		self:drawRect(0, (y), lay.rowW, self.itemheight - 1, 0.1, 0.1, 0.1, 0.1);
		self:drawRectBorder(0, (y), lay.rowW, self.itemheight - 1, a, 0.3, 0.3, 0.3);
	end

	if item.item.invItem then
		self:drawRect(4, y+1, 36, 36, 0.2, 0.2, 0.2, 0.8);
		self:drawRectBorder(4, y+1, 36, 36, a, 0.5, 0.5, 0.5);
		self:drawTextureScaledAspect(item.item.invItem:getTex(), 6, y+3, 32, 32, 1, 1, 1, 1)
	end

	local coinImg = Currency.CoinsTexture.Coin
	if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
	local displayName = item.item.displayName or item.item.name
	local priceFormatted = Currency.format(item.item.price)
	local priceW = getTextManager():MeasureStringX(UIFont.Small, priceFormatted)
	local coinSz = coinImg.scale + 2
	local textX = lay.btnX - PRICE_BTN_GAP - priceW
	local coinX = textX - COIN_PRICE_GAP - coinSz
	self:drawText(displayName, 46, y + 8, 1, 1, 1, a, UIFont.Small);

	self:drawTextureScaledAspect(coinImg.texture, coinX, y + 6, coinSz, coinSz, 1, 1, 1, 1)
	self:drawText(priceFormatted, textX, y + 8, 1, 1, 1, a, UIFont.Small);

	local btnTex = isInventory and addBtn or removeBtn
	self:drawTextureScaledAspect(btnTex.texture, lay.btnX, y + 10, btnTex.scale, btnTex.scale, 1, 1, 1, 1)

	return y + self.itemheight
end

function ATMSellUI:rebuildInventoryList()
	if not self.sellItems then return end

	local cartIds = getCartIds(self.cartItems)
	local flat = buildSellList(self.player, self.sellItems, cartIds)
	self.inventoryStacks = groupStacks(flat)
	self.itemsList:clear()
	for _, stack in ipairs(self.inventoryStacks) do
		self.itemsList:addItem(stack.stackKey, stack)
	end
	self:updateTotals()
end

function ATMSellUI:refreshItems()
	self:rebuildInventoryList()
end

function ATMSellUI:addToCart(rowIndex, addAll)
	if self.actionInProgress then return end
	local row = self.itemsList.items[rowIndex]
	if not row then return end
	local stack = row.item
	if not stack.entries or #stack.entries == 0 then return end

	local toAdd = {}
	if addAll then
		for i = 1, #stack.entries do
			toAdd[i] = stack.entries[i]
		end
	else
		toAdd[1] = stack.entries[1]
	end

	for i = 1, #toAdd do
		local entry = toAdd[i]
		self.cartItems:addItem(itemKey(entry), entry)
	end
	self.cartItems:setYScroll(-10000)
	self:rebuildInventoryList()
end

function ATMSellUI:removeFromCart(rowIndex)
	if self.actionInProgress then return end
	local row = self.cartItems.items[rowIndex]
	if not row then return end
	self.cartItems:removeItemByIndex(rowIndex)
	self:rebuildInventoryList()
end

function ATMSellUI:moveAllToCart()
	if self.actionInProgress then return end
	local items = self.itemsList.items
	for i = 1, #items do
		local stack = items[i].item
		if stack and stack.entries then
			for j = 1, #stack.entries do
				local entry = stack.entries[j]
				self.cartItems:addItem(itemKey(entry), entry)
			end
		end
	end
	self.cartItems:setYScroll(-10000)
	self:rebuildInventoryList()
end

function ATMSellUI:clearCart()
	if self.actionInProgress then return end
	self.cartItems:clear()
	self:rebuildInventoryList()
end

function ATMSellUI:onMouseDownInventory(x, y)
	ISScrollingListBox.onMouseDown(self, x, y)
	if self.parentUI.actionInProgress then return end
	local rowIndex = self:rowAt(self:getMouseX(), self:getMouseY())
	if not rowIndex then return end
	local lay = getAtmRowLayout(self:getWidth())
	if self:getMouseX() >= lay.btnX - 2 then
		self.parentUI:addToCart(rowIndex, isShiftKeyDown())
	end
end

function ATMSellUI:onMouseDownCart(x, y)
	ISScrollingListBox.onMouseDown(self, x, y)
	if self.parentUI.actionInProgress then return end
	local rowIndex = self:rowAt(self:getMouseX(), self:getMouseY())
	if not rowIndex then return end
	local lay = getAtmRowLayout(self:getWidth())
	if self:getMouseX() >= lay.btnX - 2 then
		self.parentUI:removeFromCart(rowIndex)
	end
end

function ATMSellUI:show(player, atmWo)
	if ATMSellUI.instance == nil then
		ATMSellUI.instance = ATMSellUI:new(0, 0, width, height, player, atmWo)
		ATMSellUI.instance:initialise()
		ATMSellUI.instance:instantiate()
	else
		ATMSellUI.instance.cartItems:clear()
		ATMSellUI.instance.actionInProgress = false
		ATMSellUI.instance.player = player
		ATMSellUI.instance.atmWo = atmWo
	end

	GetSellItems(function(sellItems)
		ATMSellUI.instance.sellItems = sellItems
		ATMSellUI.instance:refreshItems()
	end)

	local sq = atmWo and atmWo:getSquare() or player:getSquare()
	ATMSellUI.instance.atmX = sq:getX()
	ATMSellUI.instance.atmY = sq:getY()

	ATMSellUI.instance:addToUIManager()
	ATMSellUI.instance:setVisible(true)
	return ATMSellUI.instance
end

function ATMSellUI:update()
	local x = self.atmX or self.player:getX()
	local y = self.atmY or self.player:getY()
	if self.player:DistTo(x, y) > 5 then
		self:close()
		return
	end
	self:updateTotals()
end

function ATMSellUI:updateTotals()
	local total = 0
	local totalSpecial = 0
	local cartCount = 0
	if self.cartItems and self.cartItems.items then
		for i = 1, #self.cartItems.items do
			local v = self.cartItems.items[i].item
			cartCount = cartCount + 1
			if v.specialCoin then totalSpecial = totalSpecial + v.price
			else total = total + v.price end
		end
	end

	self.totalCoinLabel:setName(Currency.format(total))
	self.totalSpecialCoinLabel:setName(Currency.format(totalSpecial))

	local username = self.player:getUsername()
	local coin, specialCoin = Balance.getUserBalance(username)
	self.balanceCoinLabel:setName(Currency.format(coin))
	self.balanceSpecialCoinLabel:setName(Currency.format(specialCoin))

	self.sellButton.enable = (not self.actionInProgress) and cartCount > 0
	self.clearCartButton.enable = (not self.actionInProgress) and cartCount > 0
	self.moveAllButton.enable = (not self.actionInProgress) and self.inventoryStacks and #self.inventoryStacks > 0

	if self.cartLabel then
		local cartText = getText("IGUI_ATM_Cart")
		if cartCount > 0 then
			cartText = cartText .. " (" .. cartCount .. ")"
		end
		self.cartLabel:setName(cartText)
	end
end

function ATMSellUI:onSell()
	if not self.cartItems or #self.cartItems.items == 0 then return end
	self.actionInProgress = true
	self.sellButton.enable = false
	local action = ATMSellAction:new(self.player, self, self.atmWo);
	ISTimedActionQueue.add(action);
end

function ATMSellUI:onClose()
	self:close()
end

function ATMSellUI:render()
	local q = ISTimedActionQueue.getTimedActionQueue(self.player)
	if q and q.queue and q.queue[1] and q.queue[1].Type == "ATMSellAction" then
		self.actionInProgress = true
		self:drawProgressBar(self.width - 260, self.height - 46, 120, 10, q.queue[1].action:getJobDelta(), self.fgBar)
	else
		self.actionInProgress = false
	end

	ISCollapsableWindow.render(self);
end

function ATMSellUI:createChildren()
	ISCollapsableWindow.createChildren(self);

	local x = 20
	local th = self:titleBarHeight();
	local gap = 10
	local listW = math.floor((self.width - 40 - gap) / 2)
	local cartX = x + listW + gap
	local labelY = th + 32
	local listY = labelY + ATMSellUI.SMALL_FONT_HGT + 4
	local btnH = 30
	local bottomPad = 4
	local btnY = self.height - bottomPad - btnH
	local helpIconSize = 16
	local helpRowH = ATMSellUI.SMALL_FONT_HGT + 2
	local helpH = helpRowH * 2
	local footerY = btnY - 2 - helpH
	local listH = footerY - 4 - listY
	local totalY = footerY + helpRowH - 2
	local headerBtnSize = 25
	local headerBtnY = labelY - 4

	local function addHeaderIconButton(btnX, y, texture, onClick)
		local btn = ISButton:new(btnX, y, headerBtnSize, headerBtnSize, "", self, onClick)
		btn.borderColor = { r = 0, g = 0, b = 0, a = 0 }
		btn.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
		btn.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.25, a = 0.45 }
		btn:setImage(texture)
		btn:initialise()
		btn.enable = false
		self:addChild(btn)
		return btn
	end

	local function addHelpLegend(btnX, y, texture, text)
		local icon = ISImage:new(btnX, y, 0, 0, texture)
		icon.scaledWidth = helpIconSize
		icon.scaledHeight = helpIconSize
		self:addChild(icon)
		local lbl = ISLabel:new(btnX + helpIconSize + 4, y + 1, ATMSellUI.SMALL_FONT_HGT, text, 0.75, 0.75, 0.75, 1, UIFont.Small, true)
		self:addChild(lbl)
	end

	self.inventoryLabel = ISLabel:new(x, labelY, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_ATM_Inventory"), 0.9, 0.9, 1.0, 1, UIFont.Small, true)
	self:addChild(self.inventoryLabel);

	self.cartLabel = ISLabel:new(cartX, labelY, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_ATM_Cart"), 0.9, 0.9, 1.0, 1, UIFont.Small, true)
	self:addChild(self.cartLabel);

	self.moveAllButton = addHeaderIconButton(x + listW - headerBtnSize, headerBtnY, Shop.textures.MoveAll.texture, ATMSellUI.moveAllToCart)
	self.clearCartButton = addHeaderIconButton(cartX + listW - headerBtnSize, headerBtnY, Shop.textures.Dell.texture, ATMSellUI.clearCart)

	self.itemsList = ISScrollingListBox:new(x, listY, listW, listH);
	self.itemsList:initialise();
	self.itemsList:instantiate();
	self.itemsList:setAnchorBottom(true)
	self.itemsList.font = UIFont.NewSmall;
	self.itemsList.itemheight = 2 + self.MEDIUM_FONT_HGT + 20;
	self.itemsList.joypadParent = self;
	self.itemsList.drawBorder = true;
	self.itemsList.parentUI = self
	self.itemsList.doDrawItem = function(list, y, item, alt)
		return drawListItem(list, y, item, alt, true)
	end
	self.itemsList.onMouseDown = ATMSellUI.onMouseDownInventory
	self:addChild(self.itemsList);

	self.cartItems = ISScrollingListBox:new(cartX, listY, listW, listH);
	self.cartItems:initialise();
	self.cartItems:instantiate();
	self.cartItems:setAnchorRight(true)
	self.cartItems:setAnchorBottom(true)
	self.cartItems.font = UIFont.NewSmall;
	self.cartItems.itemheight = 2 + self.MEDIUM_FONT_HGT + 20;
	self.cartItems.joypadParent = self;
	self.cartItems.drawBorder = true;
	self.cartItems.parentUI = self
	self.cartItems.doDrawItem = function(list, y, item, alt)
		return drawListItem(list, y, item, alt, false)
	end
	self.cartItems.onMouseDown = ATMSellUI.onMouseDownCart
	self:addChild(self.cartItems);

	self.balanceLabel = ISLabel:new(x, 25, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_Balance"), 0.9, 0.9, 1.0, 1, UIFont.Medium, true)
	self:addChild(self.balanceLabel);

	local coinImg = Currency.CoinsTexture.Coin
	self.balanceCoinTex = ISImage:new(x + 85, 23, 0, 0, coinImg.texture);
	self.balanceCoinTex.scaledWidth = coinImg.scale+6
	self.balanceCoinTex.scaledHeight = coinImg.scale+6
	self:addChild(self.balanceCoinTex);

	self.balanceCoinLabel = ISLabel:new(x + 110, 25, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self:addChild(self.balanceCoinLabel);

	local sImg = Currency.CoinsTexture.SpecialCoin
	self.balanceSpecialCoinTex = ISImage:new(x + 200, 23, 0, 0, sImg.texture);
	self.balanceSpecialCoinTex.scaledWidth = sImg.scale+6
	self.balanceSpecialCoinTex.scaledHeight = sImg.scale+6
	self:addChild(self.balanceSpecialCoinTex);

	self.balanceSpecialCoinLabel = ISLabel:new(x + 225, 25, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self:addChild(self.balanceSpecialCoinLabel);

	local helpMidX = x + math.floor(listW / 2)
	addHelpLegend(x, footerY, Shop.textures.MoveAll.texture, getText("IGUI_ATM_HelpMoveAll"))
	addHelpLegend(helpMidX, footerY, Shop.textures.Dell.texture, getText("IGUI_ATM_HelpClearCart"))

	local shiftIconY = footerY + helpRowH
	local shiftIcon = ISImage:new(x, shiftIconY, 0, 0, addBtn.texture)
	shiftIcon.scaledWidth = helpIconSize
	shiftIcon.scaledHeight = helpIconSize
	self:addChild(shiftIcon)
	self.helpShiftLabel = ISLabel:new(x + helpIconSize + 4, shiftIconY + 1, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_ATM_ShiftHint"), 0.65, 0.65, 0.65, 1, UIFont.Small, true)
	self:addChild(self.helpShiftLabel)

	self.totalText = ISLabel:new(cartX, totalY, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_Total"), 0.9, 0.9, 1.0, 1, UIFont.Medium, true)
	self.totalText:setAnchorBottom(true)
	self:addChild(self.totalText);

	self.totalCoinTex = ISImage:new(cartX + 55, totalY - 3, 0, 0, coinImg.texture);
	self.totalCoinTex.scaledWidth = coinImg.scale+6
	self.totalCoinTex.scaledHeight = coinImg.scale+6
	self.totalCoinTex:setAnchorBottom(true)
	self:addChild(self.totalCoinTex);

	self.totalCoinLabel = ISLabel:new(cartX + 80, totalY, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self.totalCoinLabel:setAnchorBottom(true)
	self:addChild(self.totalCoinLabel);

	self.totalSpecialCoinTex = ISImage:new(cartX + 165, totalY - 3, 0, 0, sImg.texture);
	self.totalSpecialCoinTex.scaledWidth = sImg.scale+6
	self.totalSpecialCoinTex.scaledHeight = sImg.scale+6
	self.totalSpecialCoinTex:setAnchorBottom(true)
	self:addChild(self.totalSpecialCoinTex);

	self.totalSpecialCoinLabel = ISLabel:new(cartX + 190, totalY, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self.totalSpecialCoinLabel:setAnchorBottom(true)
	self:addChild(self.totalSpecialCoinLabel);

	self.sellButton = ISButton:new(self.width - 260, btnY, 120, btnH, getText("IGUI_Sell"), self, ATMSellUI.onSell);
	self.sellButton:setAnchorRight(true)
	self.sellButton:setAnchorBottom(true)
	self.sellButton.enable = false
	self.sellButton.backgroundColor = {r=0.2, g=0.6, b=0.2, a=0.8}
	self.sellButton.borderColor = {r=0.4, g=0.8, b=0.4, a=1.0}
	self:addChild(self.sellButton);

	self.closeButton = ISButton:new(self.width - 130, btnY, 120, btnH, getText("UI_Cancel"), self, ATMSellUI.onClose);
	self.closeButton:setAnchorRight(true)
	self.closeButton:setAnchorBottom(true)
	self.closeButton.backgroundColor = {r=0.6, g=0.2, b=0.2, a=0.8}
	self.closeButton.borderColor = {r=0.8, g=0.4, b=0.4, a=1.0}
	self:addChild(self.closeButton);

	if not Currency.UseSpecialCoin then
		self.balanceSpecialCoinTex:setVisible(false)
		self.balanceSpecialCoinLabel:setVisible(false)
		self.totalSpecialCoinTex:setVisible(false)
		self.totalSpecialCoinLabel:setVisible(false)
	end

	self.inventoryStacks = {}
	self.itemsList:clear()
	self.cartItems:clear()
	self:updateTotals()
end

function ATMSellUI:close()
	ISCollapsableWindow.close(self);
	ATMSellUI.instance:removeFromUIManager()
	ATMSellUI.instance = nil
	self:removeFromUIManager()
end

function ATMSellUI:new(x, y, width, height, player, atmWo)
	local o = {}
	if x == 0 and y == 0 then
		x = (getCore():getScreenWidth() / 2) - (width / 2);
		y = (getCore():getScreenHeight() / 2) - (height / 2);
	end
	o = ISCollapsableWindow:new(x, y, width, height);
	setmetatable(o, self)
	self.__index = self
	o.title = getText("IGUI_ATM_Sell")
	o.player = player
	o.atmWo = atmWo
	o.resizable = false;
	o.fgBar = {r=0, g=0.6, b=0, a=0.7}
	return o
end
