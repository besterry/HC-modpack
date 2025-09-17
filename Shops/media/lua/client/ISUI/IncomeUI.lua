IncomeUI = ISCollapsableWindow:derive("IncomeUI");
IncomeUI.instance = nil;
IncomeUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
IncomeUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
IncomeUI.removeButtonX = 300
IncomeUI.transferInProgress = false
IncomeUI.ticketsCache = {}

local width = 560
local height = 420
local total = 0
local totalSpecial = 0

-- helpers
local function calcTotals(income)
    local sumCoin, sumSpec = 0, 0
    if income then
        for _,v in pairs(income) do
            sumCoin = sumCoin + (v.t and v.t.tl or 0)
            sumSpec = sumSpec + (v.t and v.t.tls or 0)
        end
    end
    return sumCoin, sumSpec
end

local function buildIncomeSignature(income)
    if not income then return "0:0:0" end
    local count = 0
    for _ in pairs(income) do count = count + 1 end
    local c, s = calcTotals(income)
    return tostring(count)..":"..tostring(c)..":"..tostring(s)
end

function IncomeUI:show(player,shop)
    if IncomeUI.instance==nil then
        IncomeUI.instance = IncomeUI:new (0, 0, width, height, player);
        IncomeUI.instance.shop = shop
        IncomeUI.instance:initialise();
        IncomeUI.instance:instantiate();
    end
    IncomeUI.instance.pinButton:setVisible(false)
    IncomeUI.instance.collapseButton:setVisible(false)
    IncomeUI.instance:addToUIManager();
    IncomeUI.instance:setVisible(true);
    local sq = shop and shop:getSquare()
    if sq then
        IncomeUI.instance.posX = sq:getX()
        IncomeUI.instance.posY = sq:getY()
        IncomeUI.instance.posZ = sq:getZ()
        IncomeUI.instance.shopSquare = sq
    end
    -- небольшая задержка перед автозакрытием, чтобы окно не хлопалось сразу
    IncomeUI.instance._skipCloseTicks = 30
    return IncomeUI.instance;
end

function IncomeUI:filter()
    local filterText = string.trim(self.filterEntry:getInternalText())
    self.tickets.items = self.ticketsCache 
    filterText = string.lower(filterText or "")
    local tickets = self.tickets.items
    self.tickets:clear()
    for k,v in ipairs(tickets) do
        local buyerName = v.item.b or v.item.buyer or ""
        if string.contains(string.lower(buyerName), filterText) then
            self.tickets:addItem(buyerName,v.item);
        end
    end
end

function IncomeUI:onFilterChange()
    IncomeUI.instance:filter()
end

function IncomeUI:doDrawItem(y, item, alt)
    local baseItemDY = 0
    if item.item.b then
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

    self:drawText(item.item.b, 10, y + 12, 1, 1, 1, a, UIFont.Small);
    -- детали показываем в отдельной панели справа

    local coinImg = Currency.CoinsTexture.Coin
    if item.item.t.tl then
        local fixedY = 4
        if not Currency.UseSpecialCoin then fixedY = 12 end
        self:drawTextureScaledAspect(coinImg.texture, 120, y + fixedY, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
        local totalFormatted = Currency.format(item.item.t.tl)
        self:drawText(""..totalFormatted, 140, y + fixedY-2, 1, 1, 1, a, UIFont.Small);
    end

    if Currency.UseSpecialCoin then
        coinImg = Currency.CoinsTexture.SpecialCoin
        if item.item.t.tls then
            local totalSpecialFormatted = Currency.format(item.item.t.tls)
            self:drawTextureScaledAspect(coinImg.texture, 120, y + 22, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
            self:drawText(""..totalSpecialFormatted, 140, y + 20, 1, 1, 1, a, UIFont.Small);
        end
    end

    return y + item.height;
end

function IncomeUI:rebuildTickets(preserveSelection)
    local md = self.shop and self.shop:getModData() or {}
    local income = md.income or {}
    local prevSelectedBuyer = nil
    if preserveSelection and self.tickets and self.tickets.items and self.tickets.selected then
        local cur = self.tickets.items[self.tickets.selected]
        if cur and cur.item then prevSelectedBuyer = cur.item.b or cur.item.buyer end
    end
    total, totalSpecial = calcTotals(income)
    self.tickets:clear()
    -- стабильный порядок для предсказуемых сумм и UI
    local tmp = {}
    for _,v in pairs(income) do table.insert(tmp, v) end
    table.sort(tmp, function(a,b)
        local sa = tostring(a.b or a.buyer or "")
        local sb = tostring(b.b or b.buyer or "")
        if sa == sb then return (a.t and a.t.tl or 0) > (b.t and b.t.tl or 0) end
        return sa < sb
    end)
    for _,v in ipairs(tmp) do
        self.tickets:addItem(v.b or v.buyer or "", v)
    end
    self.ticketsCache = self.tickets.items
    if prevSelectedBuyer then
        for i,row in ipairs(self.tickets.items) do
            if row and row.item and (row.item.b == prevSelectedBuyer or row.item.buyer == prevSelectedBuyer) then
                self.tickets.selected = i
                self:fillDetails(row.item)
                break
            end
        end
    end
    if self.getButton then
        self.getButton.enable = (total > 0 or totalSpecial > 0)
    end
    local totalFormatted = Currency.format(total)
    if self.totalCoinLabel then self.totalCoinLabel:setName(""..totalFormatted) end
    local totalSpecialFormatted = Currency.format(totalSpecial)
    if self.totalSpecialCoinLabel then self.totalSpecialCoinLabel:setName(""..totalSpecialFormatted) end
end

function IncomeUI:createChildren()
    ISCollapsableWindow.createChildren(self);
    local x = 20
    local y = 45

    self.filterLabel = ISLabel:new(x, y+3, 1,UIText.Search,1,1,1,1,UIFont.Small, true);
    self:addChild(self.filterLabel);

    self.filterEntry = ISTextEntryBox:new("", x+40, y-8, 150, 1);
    self.filterEntry.font = UIFont.Medium
    self.filterEntry:initialise();
    self.filterEntry:instantiate();
    self.filterEntry:setText("");
    self.filterEntry:setClearButton(true);
    self.filterEntry.onTextChange = IncomeUI.onFilterChange
    self:addChild(self.filterEntry);
    self.lastText = self.filterEntry:getInternalText();

    local ticketsWidth = 240
    self.tickets = ISScrollingListBox:new(x, y+30, ticketsWidth, 260);
    self.tickets:initialise();
    self.tickets:instantiate();
    self.tickets:setAnchorRight(false)
    self.tickets:setAnchorBottom(true)
    self.tickets.font = UIFont.NewSmall;
    self.tickets.itemheight = 2 + self.MEDIUM_FONT_HGT  + 4;
    self.tickets.selected = 1;
    self.tickets.joypadParent = self;
    self.tickets.drawBorder = false;
    self.tickets.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.tickets.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    self.tickets.doDrawItem = IncomeUI.doDrawItem;
    self.tickets.onMouseDown = function(listSelf, mx, my)
        ISScrollingListBox.onMouseDown(listSelf, mx, my)
        local row = listSelf.items[listSelf.selected]
        IncomeUI.instance:fillDetails(row and row.item or nil)
    end
    self:addChild(self.tickets);

    self:rebuildTickets(false)

    -- правая панель деталей
    local detailsX = x + ticketsWidth + 20
    local detailsW = self.width - detailsX - 20
    if detailsW < 120 then detailsW = 120 end
    self.details = ISScrollingListBox:new(detailsX, y+30, detailsW, 260)
    self.details:initialise(); self.details:instantiate();
    self.details.itemheight = 2 + self.MEDIUM_FONT_HGT + 4; self.details.font = UIFont.NewSmall
    self.details.doDrawItem = IncomeUI.doDrawDetail
    self.details.onMouseMove = function(listSelf, dx, dy)
        if listSelf:isMouseOverScrollBar() or not listSelf:isMouseOver() then
            if IncomeUI.tooltip then IncomeUI.tooltip:reset() end
            return
        end
        local rowIndex = listSelf:rowAt(listSelf:getMouseX(), listSelf:getMouseY())
        local row = rowIndex and listSelf.items[rowIndex]
        if not row then if IncomeUI.tooltip then IncomeUI.tooltip:reset() end return end
        local it = row.item
        if not it then if IncomeUI.tooltip then IncomeUI.tooltip:reset() end return end
        if not IncomeUI.tooltip then IncomeUI.tooltip = ShopUITooltip:new(); IncomeUI.tooltip:initialise(); end
        IncomeUI.tooltip:addToUIManager();
        IncomeUI.tooltip:setOwner(listSelf)
        IncomeUI.tooltip:setItem({ name = it.name or it.type, items = {}, type = it.type })
        IncomeUI.tooltip:setVisible(true)
    end
    self.details.onMouseOut = function()
        if IncomeUI.tooltip then IncomeUI.tooltip:reset() end
    end
    self:addChild(self.details)

    if #self.tickets.items > 0 then
        self.tickets.selected = 1
        self:fillDetails(self.tickets.items[1].item)
    end

    self.getButton = ISButton:new(self.width-90, 360, 70,25,UIText.Get,self, IncomeUI.getBtn);
    self.getButton:initialise()
    self.getButton.enable = false    
    self:addChild(self.getButton);

    if self.shop:getModData().income and #self.shop:getModData().income > 0 then
        self.getButton.enable = true  
    end

    self.totalLabel = ISLabel:new(x, 360, ShopUI.SMALL_FONT_HGT, UIText.Total, 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalLabel);

    local coinImg = Currency.CoinsTexture.Coin
    self.totalCoinTex = ISImage:new(x+60, 360, 0, 0, coinImg.texture);
    self.totalCoinTex.scaledWidth = coinImg.scale+5
    self.totalCoinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.totalCoinTex);

    self.totalCoinLabel = ISLabel:new(x+85, 360, ShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalCoinLabel);

    coinImg = Currency.CoinsTexture.SpecialCoin
    self.totalSpecialCoinTex = ISImage:new(x+60, 385, 0, 0, coinImg.texture);
    self.totalSpecialCoinTex.scaledWidth = coinImg.scale+5
    self.totalSpecialCoinTex.scaledHeight = coinImg.scale+5
    self:addChild(self.totalSpecialCoinTex);

    self.totalSpecialCoinLabel = ISLabel:new(x+85, 385, ShopUI.SMALL_FONT_HGT, "0", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.totalSpecialCoinLabel);

    -- перезаполним суммы теперь, когда лейблы уже созданы
    self:rebuildTickets(true)
    -- cache signature to update reactively in update()
    self._incomeSig = buildIncomeSignature(self.shop:getModData().income)

    if not Currency.UseSpecialCoin then
        self.totalSpecialCoinTex:setVisible(false)
        self.totalSpecialCoinLabel:setVisible(false)
    end
end
function IncomeUI:doDrawDetail(y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end
    local rawText = (item.item.name or item.item.type or "?")
    local coinImg = Currency.CoinsTexture.Coin
    if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
    local priceVal = item.item.price or 0
    local priceText = Currency and Currency.format and Currency.format(priceVal) or tostring(priceVal)
    local priceWidth = getTextManager():MeasureStringX(UIFont.Small, priceText)
    local rightPadding = 26
    local priceX = self:getWidth() - rightPadding - priceWidth
    self:drawText(priceText, priceX, y + 4, 1, 1, 1, a, UIFont.Small)
    self:drawTextureScaledAspect(coinImg.texture, priceX - 18, y + 6, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
    -- однострочное имя с многоточием по ширине
    local maxTextWidth = priceX - 30
    local nameText = rawText
    if getTextManager():MeasureStringX(UIFont.Small, nameText) > maxTextWidth then
        while #nameText > 1 and getTextManager():MeasureStringX(UIFont.Small, nameText.."…") > maxTextWidth do
            local cut = string.find(nameText:reverse(), " ")
            if cut then
                cut = #nameText - cut
                nameText = string.sub(nameText, 1, cut)
            else
                nameText = string.sub(nameText, 1, #nameText-1)
            end
        end
        nameText = nameText.."…"
    end
    self:drawText(nameText, 10, y + 8, 1, 1, 1, a, UIFont.Small)
    return y + self.itemheight
end

function IncomeUI:fillDetails(entry)
    if not self.details then return end
    self.details:clear()
    if not entry or not entry.items then return end
    for _,it in ipairs(entry.items) do
        self.details:addItem(it.name or it.type, it)
    end
end


function IncomeUI:getBtn()
    local account =  Balance.getUserAccount(self.character:getUsername())
    -- пересчитываем по актуальному modData прямо перед переводом
    local md = IncomeUI.instance.shop:getModData()
    local curCoin, curSpec = calcTotals(md.income or {})
    if account and (curCoin > 0 or curSpec > 0) then
        sendClientCommand("BS", "Deposit", {curCoin, curSpec})
        md.income = {}
        IncomeUI.instance.shop:transmitModData()
        self.character:playSound("CashRegister")
    elseif curCoin == 0 and curSpec == 0 then
        md.income = {}
        IncomeUI.instance.shop:transmitModData()
    else
        self.character:setHaloNote(UIText.AccountNeeded, 255,255,255,400);
    end
    -- обновим UI без закрытия окна
    self._incomeSig = buildIncomeSignature(md.income)
    self:rebuildTickets(true)
end

function IncomeUI:close()
	ISCollapsableWindow.close(self);
	if IncomeUI.instance then
		IncomeUI.instance:removeFromUIManager()
		IncomeUI.instance = nil
	end
end

function IncomeUI:new(x, y, width, height, player)
    local o = {}
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2);
        y = (getCore():getScreenHeight() / 2) - (height / 2);
    end
    o = ISCollapsableWindow:new(x, y, width, height);
    setmetatable(o, self)
    o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
    self.__index = self
    if type(player) == "number" then
        o.character = getPlayer(player)
    else
        o.character = player
    end
    o.title = UIText.Income;
    o.player = player
    o.recipient = nil
    o.resizable = false;
    return o
end

function IncomeUI:update()
    ISCollapsableWindow.update(self)
    if self.character and self.posX and self.posY then
        if self._skipCloseTicks and self._skipCloseTicks > 0 then
            self._skipCloseTicks = self._skipCloseTicks - 1
        elseif self.shopSquare and self.shopSquare:getChunk() == nil then
            -- тайм для прогрузки чанка магазина
            return
        elseif self.character:DistTo(self.posX, self.posY) > 8 then
            self:close()
            return
        end
    end
    -- реактивно обновляем список и суммы при изменении доходов в modData
    local md = self.shop and self.shop:getModData() or {}
    local sig = buildIncomeSignature(md.income)
    if sig ~= self._incomeSig then
        self._incomeSig = sig
        self:rebuildTickets(true)
        -- перефильтровать при открытом фильтре
        if self.filterEntry and (self.filterEntry:getInternalText() or "") ~= "" then
            self:filter()
        end
    end
end