-- \Shops\media\lua\client\ISUI\ATMSellUI.lua
local Nfunction = require "Nfunction"

ATMSellUI = ISCollapsableWindow:derive("ATMSellUI");
ATMSellUI.instance = nil;
ATMSellUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ATMSellUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

local width = 650
local height = 450

-- функция для получения актуального списка продажи
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

local function buildSellList(character, sellItems)
	local list = {}
	local inv = character:getInventory():getItems()
	for i = 0, inv:size() - 1 do
		local item = inv:get(i)
		if not (item:isEquipped() or item:isFavorite()) then
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
						if v.price > 0 then
							v.id = item:getID()
							v.type = itemType
							v.name = Nfunction.trimString(item:getName(), 42)
							v.invItem = item
							table.insert(list, v)
						end
					end
				end
			end
		end
	end
	return list
end

function ATMSellUI:refreshItems()
	if not self.sellItems then return end
	
	self.itemsToSell = buildSellList(self.player, self.sellItems)
	self.itemsList:clear()
	for _, v in ipairs(self.itemsToSell) do
		self.itemsList:addItem(v.type, v)
	end
	self:updateTotals()
end

local function drawSellItem(self, y, item, alt)
	local a = 0.95
	-- Фон элемента с градиентом
	if self.selected == item.index then
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.4, 0.2, 0.6, 0.3);
		self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, 0.8, 0.4, 1.0);
	else
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.1, 0.1, 0.1, 0.1);
		self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, 0.3, 0.3, 0.3);
	end
	
	-- Иконка предмета с рамкой
	if item.item.invItem then
		self:drawRect(4, y+1, 36, 36, 0.2, 0.2, 0.2, 0.8);
		self:drawRectBorder(4, y+1, 36, 36, a, 0.5, 0.5, 0.5);
		self:drawTextureScaledAspect(item.item.invItem:getTex(), 6, y+3, 32, 32, 1, 1, 1, 1)
	end
	
	-- Название предмета с лучшим шрифтом
	self:drawText(item.item.name, 50, y + 8, 1, 1, 1, a, UIFont.Medium);

	-- Иконка валюты
	local coinImg = Currency.CoinsTexture.Coin
	if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
	self:drawTextureScaledAspect(coinImg.texture, self:getWidth() - 80, y + 6, coinImg.scale + 2, coinImg.scale + 2, 1, 1, 1, 1)

	-- Цена с лучшим форматированием
	local priceFormatted = Currency.format(item.item.price)
	self:drawText(""..priceFormatted, self:getWidth() - 60, y + 8, 1, 1, 1, a, UIFont.Medium);

	return y + self.itemheight
end

function ATMSellUI:show(player, atmWo)
	if ATMSellUI.instance == nil then
		ATMSellUI.instance = ATMSellUI:new(0, 0, width, height, player, atmWo)
		ATMSellUI.instance:initialise()
		ATMSellUI.instance:instantiate()
	end
	
	-- Получаем актуальный список продажи
	GetSellItems(function(sellItems)
		ATMSellUI.instance.sellItems = sellItems
		ATMSellUI.instance:refreshItems()
	end)
	
	-- координаты банкомата для авто‑закрытия
	local sq = atmWo and atmWo:getSquare() or player:getSquare()
	ATMSellUI.instance.atmX = sq:getX()
	ATMSellUI.instance.atmY = sq:getY()

	ATMSellUI.instance:addToUIManager()
	ATMSellUI.instance:setVisible(true)
	return ATMSellUI.instance
end

function ATMSellUI:update()
	-- закрываем, если игрок отошёл от банкомата
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
	for _, v in ipairs(self.itemsToSell) do
		if v.specialCoin then totalSpecial = totalSpecial + v.price
		else total = total + v.price end
	end

	self.totalCoinLabel:setName(Currency.format(total))
	self.totalSpecialCoinLabel:setName(Currency.format(totalSpecial))

	local username = self.player:getUsername()
	local coin,specialCoin = Balance.getUserBalance(username)
	self.balanceCoinLabel:setName(Currency.format(coin))
	self.balanceSpecialCoinLabel:setName(Currency.format(specialCoin))

    self.sellButton.enable = (not self.actionInProgress) and (#self.itemsToSell > 0)
end

function ATMSellUI:onSell()
	self.actionInProgress = true
	self.sellButton.enable = false
	local action = ATMSellAction:new(self.player, self, self.atmWo);
	ISTimedActionQueue.add(action);
end

function ATMSellUI:onClose()
	self:close()
end

function ATMSellUI:render()
	-- фон
	-- self:drawRect(0, 0, self.width, self.height, 0.08, 0.08, 0.08, 0.95);
	-- self:drawRectBorder(0, 0, self.width, self.height, 0.8, 0.8, 0.8, 0.6);

	-- прогресс продажи
	local q = ISTimedActionQueue.getTimedActionQueue(self.player)
	if q and q.queue and q.queue[1] and q.queue[1].Type == "ATMSellAction" then
		self.actionInProgress = true
		self:drawProgressBar(self.width - 260, self.height - 58, 120, 10, q.queue[1].action:getJobDelta(), self.fgBar)
	else
		self.actionInProgress = false
	end

	ISCollapsableWindow.render(self);
end

function ATMSellUI:createChildren()
	ISCollapsableWindow.createChildren(self);

	local x = 20
	local y = 50

	local th = self:titleBarHeight();

	self.itemsList = ISScrollingListBox:new(x, th + 50, self.width - 40, self.height - 160);
	self.itemsList:initialise();
	self.itemsList:instantiate();
	self.itemsList:setAnchorRight(true)
	self.itemsList:setAnchorBottom(true)
	self.itemsList.font = UIFont.NewSmall;
	self.itemsList.itemheight = 2 + self.MEDIUM_FONT_HGT + 20;
	self.itemsList.joypadParent = self;
	self.itemsList.drawBorder = true;
	self.itemsList.doDrawItem = drawSellItem;
	self:addChild(self.itemsList);

	-- Разделитель перед балансом
	self:drawRect(x, 15, self.width - 40, 2, 0.4, 0.4, 0.4, 0.8);
	
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

	-- Разделитель перед итогами
	self:drawRect(x, self.height - 90, self.width - 40, 2, 0.4, 0.4, 0.4, 0.8);
	
	self.totalText = ISLabel:new(x, self.height - 80, ATMSellUI.SMALL_FONT_HGT, getText("IGUI_Total"), 0.9, 0.9, 1.0, 1, UIFont.Medium, true)
	self.totalText:setAnchorBottom(true)
	self:addChild(self.totalText);

	self.totalCoinTex = ISImage:new(x + 70, self.height - 83, 0, 0, coinImg.texture);
	self.totalCoinTex.scaledWidth = coinImg.scale+6
	self.totalCoinTex.scaledHeight = coinImg.scale+6
	self.totalCoinTex:setAnchorBottom(true)
	self:addChild(self.totalCoinTex);

	self.totalCoinLabel = ISLabel:new(x + 95, self.height - 80, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self.totalCoinLabel:setAnchorBottom(true)
	self:addChild(self.totalCoinLabel);

	self.totalSpecialCoinTex = ISImage:new(x + 180, self.height - 83, 0, 0, sImg.texture);
	self.totalSpecialCoinTex.scaledWidth = sImg.scale+6
	self.totalSpecialCoinTex.scaledHeight = sImg.scale+6
	self.totalSpecialCoinTex:setAnchorBottom(true)
	self:addChild(self.totalSpecialCoinTex);

	self.totalSpecialCoinLabel = ISLabel:new(x + 205, self.height - 80, ATMSellUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
	self.totalSpecialCoinLabel:setAnchorBottom(true)
	self:addChild(self.totalSpecialCoinLabel);

	self.sellButton = ISButton:new(self.width - 260, self.height - 50, 120, 35, getText("IGUI_Sell"), self, ATMSellUI.onSell);
	self.sellButton:setAnchorRight(true)
	self.sellButton:setAnchorBottom(true)
	self.sellButton.enable = false
	self.sellButton.backgroundColor = {r=0.2, g=0.6, b=0.2, a=0.8}
	self.sellButton.borderColor = {r=0.4, g=0.8, b=0.4, a=1.0}
	self:addChild(self.sellButton);

	self.closeButton = ISButton:new(self.width - 130, self.height - 50, 120, 35, getText("UI_Cancel"), self, ATMSellUI.onClose);
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

	-- Убираем инициализацию списка отсюда - она будет в refreshItems
	self.itemsToSell = {}
	self.itemsList:clear()
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