local Nfunction = require "Nfunction"
PSClient = PSClient or {}
BuyOrdersUI = ISCollapsableWindow:derive("BuyOrdersUI");
BuyOrdersUI.instance = nil;
BuyOrdersUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
BuyOrdersUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

local width = 860
local height = 380

-- формируем сигнатуру набора ордеров для отслеживания изменений
local function buildOrdersSignature(orders)
    if not orders then return "" end
    local parts = {}
    for key, ord in pairs(orders) do
        local s = tostring(key)..":"..tostring(ord and ord.qty or 0)..":"..tostring(ord and ord.price or 0)..":"..tostring(ord and ord.specialCoin and 1 or 0)..":"..tostring(ord and ord.onlyFull and 1 or 0)
        table.insert(parts, s)
    end
    table.sort(parts)
    return table.concat(parts, ";")
end

-- draw row for orders list (name + xqty + price)
function BuyOrdersUI.doDrawOrderItem(self, y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    elseif item.item.onlyFull then
        -- выделяем ряды с флагом "только целые" зеленым фоном
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.1, 1.0, 1.0, 0.25)
    end
    local fullName = item.item.fullName or item.item.name or item.text or "?"
    local qtyVal = tonumber(item.item.qty) or 0
    local qtyText = "x" .. tostring(qtyVal)

    local coinImg = Currency.CoinsTexture.Coin
    if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
    local priceText = Currency and Currency.format and Currency.format(item.item.price or 0) or tostring(item.item.price or 0)

    local priceWidth = getTextManager():MeasureStringX(UIFont.Small, priceText)
    local qtyWidth = getTextManager():MeasureStringX(UIFont.Small, qtyText)
    local rightPadding = 12
    local coinWidth = 18

    -- positions from right to left: [price][coin][space][qty]
    local priceX = self:getWidth() - rightPadding - priceWidth
    local coinX = priceX - coinWidth
    local qtyGap = 8
    local qtyX = coinX - qtyGap - qtyWidth

    -- trim name to fit between left padding and qtyX
    local leftPadding = 10
    local maxTextWidth = qtyX - leftPadding
    local displayName = fullName
    if maxTextWidth < 50 then maxTextWidth = 50 end
    if getTextManager():MeasureStringX(UIFont.Small, displayName) > maxTextWidth then
        while #displayName > 1 and getTextManager():MeasureStringX(UIFont.Small, displayName.."…") > maxTextWidth do
            displayName = string.sub(displayName, 1, #displayName-1)
        end
        displayName = displayName.."…"
    end

    -- draw
    self:drawText(displayName, leftPadding, y + 8, 1, 1, 1, a, UIFont.Small)
    
    
    self:drawText(qtyText, qtyX, y + 8, 1, 1, 1, a, UIFont.Small)
    -- сначала цифры, затем значок монеты
    self:drawText(priceText, priceX, y + 6, 1, 1, 1, a, UIFont.Small)
    self:drawTextureScaledAspect(coinImg.texture, coinX, y + 8, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
    return y + self.itemheight
end

function BuyOrdersUI:show(player, shop)
    if BuyOrdersUI.instance==nil then
        BuyOrdersUI.instance = BuyOrdersUI:new (0, 0, width, height, player, shop);
        BuyOrdersUI.instance:initialise();
        BuyOrdersUI.instance:instantiate();
    end
    BuyOrdersUI.instance.pinButton:setVisible(false)
    BuyOrdersUI.instance.collapseButton:setVisible(false)
    BuyOrdersUI.instance:addToUIManager();
    BuyOrdersUI.instance:setVisible(true);
    -- запомним позицию магазина для авто-закрытия при уходе
    local sq = shop and shop:getSquare()
    if sq then
        BuyOrdersUI.instance.posX = sq:getX()
        BuyOrdersUI.instance.posY = sq:getY()
    end
    return BuyOrdersUI.instance;
end

local function twoDecimal(self)
    local quantity = self:getInternalText()
    local isNumber = tonumber(quantity)
    if not isNumber then return end
    local curPos = self:getCursorPos()
    if string.find(quantity,"%.") then
        self:setText(string.format('%.02f', quantity))
        self:setCursorPos(curPos)
    end
end

function BuyOrdersUI:onPriceChange()
    twoDecimal(self)
end

function BuyOrdersUI:onQtyChange()
    local qty = tonumber(self:getInternalText())
    if not qty then return end
    self:setText(tostring(math.max(0, math.floor(qty))))
end

function BuyOrdersUI:refreshOrders(preserveSelection)
    if not self.ordersList then return end
    local orders = self.shop and self.shop:getModData().buyOrders or {}
    local prevSelectedKey = nil
    if preserveSelection and self.ordersList.items and self.ordersList.selected then
        local cur = self.ordersList.items[self.ordersList.selected]
        if cur and cur.item then prevSelectedKey = cur.item.orderKey end
    end
    self.ordersList:clear()
    for key,ord in pairs(orders) do
        if ord and ord.type and ord.price and ord.qty then
            local ok, item = pcall(InventoryItemFactory.CreateItem, ord.type)
            if not ok then item = nil end
            local name = item and Nfunction.trimString(item:getName(),42) or tostring(ord.type)
            local v = {}
            v.type = tostring(ord.type)
            v.price = tonumber(ord.price) or 0
            v.specialCoin = ord.specialCoin and true or false
            v.qty = tonumber(ord.qty) or 0
            v.onlyFull = ord.onlyFull and true or false
            v.orderKey = key
            v.name = name.."  x"..tostring(v.qty)
            v.fullName = (item and item:getName()) or tostring(ord.type)
            v.invItem = item
            pcall(function() self.ordersList:addItem(v.type, v) end)
        end
    end
    if prevSelectedKey then
        for i,row in ipairs(self.ordersList.items) do
            if row and row.item and row.item.orderKey == prevSelectedKey then
                self.ordersList.selected = i
                break
            end
        end
    end
end

function BuyOrdersUI:createChildren()
    ISCollapsableWindow.createChildren(self);
    local x = 300 -- левая колонка под список предметов
    local y = 40

    -- форма ордера
    self.typeLabel = ISLabel:new(x, y, self.SMALL_FONT_HGT, getText("IGUI_BuyOrders_Name"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.typeLabel);
    self.nameValue = ISLabel:new(x+120, y, self.SMALL_FONT_HGT, "-", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.nameValue)
    self.selectedType = nil

    y = y + 30
    self.priceLabel = ISLabel:new(x, y, self.SMALL_FONT_HGT, getText("IGUI_BuyOrders_Price"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.priceLabel);
    self.priceEntry = ISTextEntryBox:new("0", x+120, y-2, 120, 20); self.priceEntry.font = UIFont.Medium
    self.priceEntry:initialise(); self.priceEntry:instantiate(); self.priceEntry:setOnlyNumbers(true); self.priceEntry.onTextChange = BuyOrdersUI.onPriceChange; self:addChild(self.priceEntry)

    self.specialChk = ISTickBox:new(x+120, y+20, 150, 20, "", self, nil)
    self.specialChk:initialise(); self.specialChk:instantiate(); self.specialChk.autoWidth = true; self.specialChk:addOption(getText("IGUI_BuyOrders_Special")); self:addChild(self.specialChk)

    y = y + 45
    self.qtyLabel = ISLabel:new(x, y, self.SMALL_FONT_HGT, getText("IGUI_BuyOrders_Qty"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.qtyLabel);
    self.qtyEntry = ISTextEntryBox:new("1", x+120, y-2, 120, 20); self.qtyEntry.font = UIFont.Medium
    self.qtyEntry:initialise(); self.qtyEntry:instantiate(); self.qtyEntry:setOnlyNumbers(true); self.qtyEntry.onTextChange = BuyOrdersUI.onQtyChange; self:addChild(self.qtyEntry)

    -- только предметы с максимальным состоянием
    self.onlyFullChk = ISTickBox:new(x+120, y+20, 200, 20, "", self, nil)
    self.onlyFullChk:initialise(); self.onlyFullChk:instantiate(); self.onlyFullChk.autoWidth = true; self.onlyFullChk:addOption(getText("IGUI_BuyOrders_OnlyFull")); self:addChild(self.onlyFullChk)

    y = y + 45
    self.addBtn = ISButton:new(x, y, 140, 25, getText("IGUI_BuyOrders_Add"), self, function()
        local typeFull = self.selectedType
        local price = tonumber(self.priceEntry:getInternalText()) or 0
        local qty = tonumber(self.qtyEntry:getInternalText()) or 0
        local special = self.specialChk:isSelected(1) or false
        if not typeFull or price <= 0 or qty <= 0 then return end
        local shopSquare = self.shop:getSquare()
        local coords = {x=shopSquare:getX(), y=shopSquare:getY(), z=shopSquare:getZ()}
        local order = {type = typeFull, price = price, specialCoin = special, qty = qty, from = 'shop', onlyFull = self.onlyFullChk:isSelected(1) and (self.onlyFullChk.enable ~= false)}
        PSClient.SetBuyOrder(self.player, {coords = coords, order = order})
        -- sendClientCommand('PS', 'SetBuyOrder', {coords = coords, order = order})
        -- оптимистичное обновление UI: добавим локально
        local md = self.shop:getModData(); md.buyOrders = md.buyOrders or {}
        local key = typeFull.."|"..tostring(price).."|"..tostring(special).."|"..tostring(order.onlyFull and 1 or 0)
        md.buyOrders[key] = order
        self.shop:transmitModData()
        self:refreshOrders()
    end)
    self.addBtn:initialise(); self:addChild(self.addBtn)

    self.removeBtn = ISButton:new(x+160, y, 140, 25, getText("IGUI_BuyOrders_Remove"), self, function()
        local selected = self.ordersList.items[self.ordersList.selected]
        if not selected then return end
        local key = selected.item.orderKey
        local shopSquare = self.shop:getSquare()
        local coords = {x=shopSquare:getX(), y=shopSquare:getY(), z=shopSquare:getZ()}
        PSClient.RemoveBuyOrder(self.player, {coords = coords, key = key})
        -- sendClientCommand('PS', 'RemoveBuyOrder', {coords = coords, key = key})
        self:refreshOrders()
    end)
    self.removeBtn:initialise(); self:addChild(self.removeBtn)

    y = y + 50
    -- доход (сумма по тикетам), отображается над кассой
    self.incomeLabel = ISLabel:new(x, y, self.SMALL_FONT_HGT, getText("IGUI_Shop_Income")..":", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.incomeLabel)
    -- icons + values (income)
    local coinImg = Currency.CoinsTexture.Coin
    self.incomeCoinTex = ISImage:new(x+74, y-2, 0, 0, coinImg.texture)
    self.incomeCoinTex.scaledWidth = coinImg.scale
    self.incomeCoinTex.scaledHeight = coinImg.scale
    self:addChild(self.incomeCoinTex)
    self.incomeCoin = ISLabel:new(x+90, y, self.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.incomeCoin)
    local sCoinImg = Currency.CoinsTexture.SpecialCoin
    self.incomeSpecTex = ISImage:new(x+144, y-2, 0, 0, sCoinImg.texture)
    self.incomeSpecTex.scaledWidth = sCoinImg.scale
    self.incomeSpecTex.scaledHeight = sCoinImg.scale
    self:addChild(self.incomeSpecTex)
    self.incomeSpec = ISLabel:new(x+160, y, self.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.incomeSpec)

    y = y + 20
    self.cashLabel = ISLabel:new(x, y, self.SMALL_FONT_HGT, getText("IGUI_Shop_Cash")..":", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.cashLabel);
    -- icons + values (cash)
    self.cashCoinTex = ISImage:new(x+74, y-2, 0, 0, coinImg.texture)
    self.cashCoinTex.scaledWidth = coinImg.scale
    self.cashCoinTex.scaledHeight = coinImg.scale
    self:addChild(self.cashCoinTex)
    self.cashCoin = ISLabel:new(x+90, y, self.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.cashCoin);
    self.cashSpecTex = ISImage:new(x+144, y-2, 0, 0, sCoinImg.texture)
    self.cashSpecTex.scaledWidth = sCoinImg.scale
    self.cashSpecTex.scaledHeight = sCoinImg.scale
    self:addChild(self.cashSpecTex)
    self.cashSpec = ISLabel:new(x+160, y, self.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.cashSpec);

    y = y + 30
    self.useIncomeChk = ISTickBox:new(x, y-4, 160, 20, "", self, nil)
    self.useIncomeChk:initialise(); self.useIncomeChk:instantiate(); self.useIncomeChk.autoWidth = true; self.useIncomeChk:addOption(getText("IGUI_Shop_Cash_UseIncome")); self:addChild(self.useIncomeChk)
    -- init from shop modData and persist on toggle
    local mdInit = self.shop:getModData(); mdInit.useIncome = mdInit.useIncome or false
    self.useIncomeChk:setSelected(1, mdInit.useIncome)
    self.useIncomeChk.onMouseUp = function(_, x, y)
        -- toggle selection manually, then persist
        local cur = self.useIncomeChk:isSelected(1)
        self.useIncomeChk:setSelected(1, not cur)
        local md = self.shop:getModData(); md.useIncome = self.useIncomeChk:isSelected(1) and true or false
        self.shop:transmitModData()
    end
    y = y + 20
    -- icons before deposit inputs
    self.depCoinIcon = ISImage:new(x-18, y+2, 0, 0, coinImg.texture); self.depCoinIcon.scaledWidth = coinImg.scale; self.depCoinIcon.scaledHeight = coinImg.scale; self:addChild(self.depCoinIcon)
    self.depCoin = ISTextEntryBox:new("0", x, y-2, 120, 20); self.depCoin.font = UIFont.Medium; self.depCoin:initialise(); self.depCoin:instantiate(); self.depCoin:setOnlyNumbers(true); self:addChild(self.depCoin)
    local secondInputX = x + 140
    self.depSpecIcon = ISImage:new(secondInputX-18, y+2, 0, 0, sCoinImg.texture); self.depSpecIcon.scaledWidth = sCoinImg.scale; self.depSpecIcon.scaledHeight = sCoinImg.scale; self:addChild(self.depSpecIcon)
    self.depSpec = ISTextEntryBox:new("0", secondInputX, y-2, 120, 20); self.depSpec.font = UIFont.Medium; self.depSpec:initialise(); self.depSpec:instantiate(); self.depSpec:setOnlyNumbers(true); self:addChild(self.depSpec)

    y = y + 25
    self.depBtn = ISButton:new(x, y, 120, 25, getText("IGUI_Shop_Cash_Deposit"), self, function()
        local coin = tonumber(self.depCoin:getInternalText()) or 0
        local spec = tonumber(self.depSpec:getInternalText()) or 0
        local md = self.shop:getModData(); md.cash = md.cash or {coin=0,specialCoin=0}
        -- if self.useIncomeChk:isSelected(1) then
        --     -- перевести из дохода в кассу
        --     local income = md.income or {}
        --     local sumCoin, sumSpec = 0, 0
        --     for _,v in pairs(income) do
        --         sumCoin = sumCoin + (v.t and v.t.tl or 0)
        --         sumSpec = sumSpec + (v.t and v.t.tls or 0)
        --     end
        --     if coin > 0 and sumCoin >= coin then
        --         md.cash.coin = (md.cash.coin or 0) + coin
        --         sumCoin = sumCoin - coin
        --     end
        --     if spec > 0 and sumSpec >= spec then
        --         md.cash.specialCoin = (md.cash.specialCoin or 0) + spec
        --         sumSpec = sumSpec - spec
        --     end
        --     -- перераспределим остаток дохода обратно в один агрегированный тикет
        --     md.income = {{ b = getText("IGUI_Shop"), t = { tl = sumCoin, tls = sumSpec }, items = {} }}
        -- else
        local username = self.player:getUsername()
        local balCoin, balSpec = Balance.getUserBalance(username)
        local wcoin = math.min(coin, balCoin)
        local wspec = math.min(spec, balSpec)
        if (wcoin < coin) or (wspec < spec) then
            local msg = getText("IGUI_CarShop_Need_Money")
            self.player:setHaloNote(msg, 255,255,255,400);
        end
        if wcoin > 0 or wspec > 0 then
            sendClientCommand('BS','Withdraw',{wcoin,wspec})
            md.cash.coin = (md.cash.coin or 0) + wcoin
            md.cash.specialCoin = (md.cash.specialCoin or 0) + wspec
        end
        -- end
        self.shop:transmitModData()
        self:updateCash()
    end)
    self.depBtn:initialise(); self:addChild(self.depBtn)

    self.wdBtn = ISButton:new(x+130, y, 120, 25, getText("IGUI_Shop_Cash_Withdraw"), self, function()
        local coin = tonumber(self.depCoin:getInternalText()) or 0
        local spec = tonumber(self.depSpec:getInternalText()) or 0
        local md = self.shop:getModData(); md.cash = md.cash or {coin=0,specialCoin=0}
        local haveCoin = md.cash.coin or 0
        local haveSpec = md.cash.specialCoin or 0
        local tcoin = math.min(coin, haveCoin)
        local tspec = math.min(spec, haveSpec)
        if (tcoin < coin) or (tspec < spec) then
            local msg = getText("IGUI_Loot_All_Coins") 
            self.player:setHaloNote(msg, 255,255,255,400);
        end
        if tcoin > 0 or tspec > 0 then
            md.cash.coin = haveCoin - tcoin
            md.cash.specialCoin = haveSpec - tspec
            sendClientCommand('BS','Deposit',{tcoin,tspec})
        end
        self.shop:transmitModData()
        self:updateCash()
    end)
    self.wdBtn:initialise(); self:addChild(self.wdBtn)

    -- список ордеров (справа)
    self.ordersList = ISScrollingListBox:new(self.width-220, 40, 200, height-70)
    self.ordersList:initialise(); self.ordersList:instantiate(); self.ordersList.itemheight = 2 + self.MEDIUM_FONT_HGT + 4; self.ordersList.font = UIFont.NewSmall
    self.ordersList.doDrawItem = BuyOrdersUI.doDrawOrderItem
    -- tooltip full name on hover
    self.ordersList.onMouseMove = function(listSelf, dx, dy)
        if listSelf:isMouseOverScrollBar() or not listSelf:isMouseOver() then
            if BuyOrdersUI.tooltip then BuyOrdersUI.tooltip:reset() end
            return
        end
        local rowIndex = listSelf:rowAt(listSelf:getMouseX(), listSelf:getMouseY())
        local row = rowIndex and listSelf.items[rowIndex]
        if not row then if BuyOrdersUI.tooltip then BuyOrdersUI.tooltip:reset() end return end
        local it = row.item
        if not it then if BuyOrdersUI.tooltip then BuyOrdersUI.tooltip:reset() end return end
        if not BuyOrdersUI.tooltip then BuyOrdersUI.tooltip = ShopUITooltip:new(); BuyOrdersUI.tooltip:initialise(); end
        BuyOrdersUI.tooltip:addToUIManager();
        BuyOrdersUI.tooltip:setOwner(listSelf)
        local tooltipName = it.fullName or it.name or row.text
        if it.onlyFull then
            tooltipName = tooltipName .. "\n \n" .. getText("IGUI_BuyOrders_OnlyFull")
        end
        BuyOrdersUI.tooltip:setItem({ name = tooltipName, items = {}, type = it.type })
        BuyOrdersUI.tooltip:setVisible(true)
    end
    self.ordersList.onMouseOut = function()
        if BuyOrdersUI.tooltip then BuyOrdersUI.tooltip:reset() end
    end
    self:addChild(self.ordersList)
    self:refreshOrders()
    self:updateCash()
    -- кешируем текущую сигнатуру ордеров, чтобы не дергать refresh каждый кадр
    local md = self.shop and self.shop:getModData() or {}
    self._ordersSig = buildOrdersSignature(md.buyOrders)

    -- левая колонка: поиск и список предметов
    local lx = 20
    local ly = 40
    self.searchLabel = ISLabel:new(lx, ly-20, self.SMALL_FONT_HGT, getText("IGUI_Shop_Search"), 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.searchLabel)
    self.searchEntry = ISTextEntryBox:new("", lx+60, ly-24, 200, 20); self.searchEntry.font = UIFont.Medium
    self.searchEntry:initialise(); self.searchEntry:instantiate(); self.searchEntry:setClearButton(true); self:addChild(self.searchEntry)
    self.itemList = ISScrollingListBox:new(lx, ly, 240, height-70)
    self.itemList:initialise(); self.itemList:instantiate(); self.itemList.itemheight = 2 + self.MEDIUM_FONT_HGT + 4; self.itemList.font = UIFont.NewSmall
    self.itemList.drawBorder = true
    self.itemList.onMouseDown = function(listSelf, x, y)
        ISScrollingListBox.onMouseDown(listSelf,x,y)
        local row = listSelf.items[listSelf.selected]
        if not row then return end
        self.selectedType = row.item.fullType
        self.nameValue:setName(row.text)
        -- включим чекбокс только если предмет поддерживает состояние
        local ok, sample = pcall(InventoryItemFactory.CreateItem, self.selectedType)
        local hasCond = ok and sample and (sample:getConditionMax() or 0) > 0
        if self.onlyFullChk.setEnable then
            self.onlyFullChk:setEnable(hasCond)
        else
            self.onlyFullChk.enable = hasCond
        end
        if not hasCond then self.onlyFullChk:setSelected(1, false) end
        if self.addBtn then
            local price = tonumber(self.priceEntry:getInternalText()) or 0
            local qty = tonumber(self.qtyEntry:getInternalText()) or 0
            self.addBtn.enable = (self.selectedType ~= nil and price > 0 and qty > 0)
        end
    end
    self:addChild(self.itemList)

	-- tooltip с полноценным описанием предмета, как в PlayerShopUI (ISToolTipInv)ыф
	self.itemList.onMouseMove = function(listSelf, dx, dy)
		if listSelf:isMouseOverScrollBar() or not listSelf:isMouseOver() then
			if BuyOrdersUI.invTooltip then BuyOrdersUI.invTooltip:removeFromUIManager(); BuyOrdersUI.invTooltip = nil end
			return
		end
		local rowIndex = listSelf:rowAt(listSelf:getMouseX(), listSelf:getMouseY())
		local row = rowIndex and listSelf.items[rowIndex]
		if not row or not row.item or not row.item.fullType then
			if BuyOrdersUI.invTooltip then BuyOrdersUI.invTooltip:removeFromUIManager(); BuyOrdersUI.invTooltip = nil end
			return
		end
		local ok, sample = pcall(InventoryItemFactory.CreateItem, row.item.fullType)
		if not ok or not sample then
			if BuyOrdersUI.invTooltip then BuyOrdersUI.invTooltip:removeFromUIManager(); BuyOrdersUI.invTooltip = nil end
			return
		end
		if not BuyOrdersUI.invTooltip then
			BuyOrdersUI.invTooltip = ISToolTipInv:new(sample)
			BuyOrdersUI.invTooltip:initialise()
		else
			BuyOrdersUI.invTooltip:addToUIManager()
			BuyOrdersUI.invTooltip:setItem(sample)
			BuyOrdersUI.invTooltip:setVisible(true)
			BuyOrdersUI.invTooltip:setOwner(listSelf)
			BuyOrdersUI.invTooltip:render()
		end
	end
	self.itemList.onMouseOut = function()
		if BuyOrdersUI.invTooltip then BuyOrdersUI.invTooltip:removeFromUIManager(); BuyOrdersUI.invTooltip = nil end
	end

    -- загрузка индекса предметов по требованию и фильтр
    local function ensureIndex()
        if BuyOrdersUI.itemsIndex then return end
        BuyOrdersUI.itemsIndex = {}
        local all = ScriptManager.instance:getAllItems()
        for i=0, all:size()-1 do
            local si = all:get(i)
            if not si:getObsolete() and not si:isHidden() then
                local fullType = si:getModule():getName() .. "." .. si:getName()
                local displayName = si:getDisplayName()
                table.insert(BuyOrdersUI.itemsIndex, {fullType=fullType, name=displayName})
            end
        end
    end
    self.onFilterChanged = function()
        local filter = string.lower(self.searchEntry:getInternalText() or "")
        self.itemList:clear()
        if string.len(filter) < 2 then
            self.itemList:addItem(getText("IGUI_Shop_Search_Min2"), {fullType=nil, name=nil})
            return
        end
        ensureIndex()
        local added = 0
        for _,it in ipairs(BuyOrdersUI.itemsIndex) do
            if string.contains(string.lower(it.name), filter) then
                self.itemList:addItem(it.name, it)
                added = added + 1
                if added >= 200 then break end
            end
        end
    end
    self.searchEntry.onTextChange = function() self:onFilterChanged() end
    self:onFilterChanged()
    -- tie enabling of Add button to inputs
    local function refreshAddEnabled()
        if not self.addBtn then return end
        local price = tonumber(self.priceEntry:getInternalText()) or 0
        local qty = tonumber(self.qtyEntry:getInternalText()) or 0
        self.addBtn.enable = (self.selectedType ~= nil and price > 0 and qty > 0)
    end
    local oldPriceChange = self.priceEntry.onTextChange
    self.priceEntry.onTextChange = function(entry)
        if oldPriceChange then oldPriceChange(entry) end
        refreshAddEnabled()
    end
    local oldQtyChange = self.qtyEntry.onTextChange
    self.qtyEntry.onTextChange = function(entry)
        if oldQtyChange then oldQtyChange(entry) end
        refreshAddEnabled()
    end
    refreshAddEnabled()
end

function BuyOrdersUI:updateCash()
    local md = self.shop:getModData(); md.cash = md.cash or {coin=0,specialCoin=0}
    -- cash
    self.cashCoin:setName(tostring(md.cash.coin or 0))
    self.cashSpec:setName(tostring(md.cash.specialCoin or 0))
    -- income totals
    local sumCoin, sumSpec = 0, 0
    for _,v in pairs(md.income or {}) do
        sumCoin = sumCoin + (v.t and v.t.tl or 0)
        sumSpec = sumSpec + (v.t and v.t.tls or 0)
    end
    if self.incomeCoin then self.incomeCoin:setName(tostring(sumCoin)) end
    if self.incomeSpec then self.incomeSpec:setName(tostring(sumSpec)) end
    -- монетки после цифр (переставлять не нужно, мы уже рисуем отдельные иконки слева)
    if self.useIncomeChk then
        self.useIncomeChk:setSelected(1, md.useIncome and true or false)
    end
    -- toggle visibility of special coin
    if self.incomeSpecTex then self.incomeSpecTex:setVisible(Currency.UseSpecialCoin) end
    if self.incomeSpec then self.incomeSpec:setVisible(Currency.UseSpecialCoin) end
    if self.cashSpecTex then self.cashSpecTex:setVisible(Currency.UseSpecialCoin) end
    if self.cashSpec then self.cashSpec:setVisible(Currency.UseSpecialCoin) end
    if self.depSpecIcon then self.depSpecIcon:setVisible(Currency.UseSpecialCoin) end
    if self.depSpec then self.depSpec:setVisible(Currency.UseSpecialCoin) end
end

function BuyOrdersUI:update()
    ISCollapsableWindow.update(self)
    -- авто-закрытие при уходе от магазина
    if self.player and self.posX and self.posY then
        if self.player:DistTo(self.posX, self.posY) > 5 then
            self:close()
            return
        end
    end
    -- автообновление отображения кассы/дохода
    self:updateCash()
    -- автообновление списка ордеров только при изменении данных
    local md = self.shop and self.shop:getModData() or {}
    local sig = buildOrdersSignature(md.buyOrders)
    if sig ~= self._ordersSig then
        self._ordersSig = sig
        self:refreshOrders(true)
    end
end

function BuyOrdersUI:close()
    ISCollapsableWindow.close(self);
    BuyOrdersUI.instance:removeFromUIManager()
    BuyOrdersUI.instance = nil
    self:removeFromUIManager()
end

function BuyOrdersUI:new(x, y, width, height, player, shop)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2);
        y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.title = getText("IGUI_BuyOrders_Title");
    o.player = player
    o.shop = shop
    o.resizable = false;
    return o
end


