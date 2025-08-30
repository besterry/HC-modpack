--***********************************************************
--**                    MarketUI - Smart Market             **
--***********************************************************

MarketUI = ISPanel:derive("MarketUI")
MarketUI.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local TOP_N = 15

local DEMAND_COLORS = {
	HIGH = {r=1, g=0.2, b=0.2, a=1},
	NORMAL = {r=1, g=1, b=0.2, a=1},
	LOW = {r=0.2, g=1, b=0.2, a=1}
}

local nameCache = {}
local function displayName(fullType)
	if nameCache[fullType] then return nameCache[fullType] end
	local sm = getScriptManager()
	local si = (sm and (sm:getItem(fullType) or sm:FindItem(fullType))) or nil
	local name = si and si:getDisplayName() or fullType
	nameCache[fullType] = name
	return name
end

local function fmtPrice(p)
	if Currency and Currency.format then return Currency.format(p) end
	return tostring(math.floor(p or 0))
end

-- после fmtPrice()
local ROW_H = 22 -- компактная строка под 15 без скролла
local REFRESH_COOLDOWN = 10 -- сек

local function localTimeStr()
	local t = os.date("*t")
	return string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
end

local function computeColX(w)
	local pad = 10
	local deltaW, baseW = 40, 80
	local xDelta = w - pad
	local xBase  = xDelta - baseW
	local nameMax = xBase - 10
	return { base = xBase, delta = xDelta, nameMax = nameMax }
end

local function ellipsize(text, maxW)
	local tm = getTextManager()
	local t = tostring(text or "")
	if tm:MeasureStringX(UIFont.Small, t) <= maxW then return t end
	while #t > 1 and tm:MeasureStringX(UIFont.Small, t .. "...") > maxW do
		t = string.sub(t, 1, #t - 1)
	end
	return t .. "..."
end

function MarketUI:show(player)
	if MarketUI.instance then MarketUI.instance:close() end
	local w, h = 800, 650
	local x = getCore():getScreenWidth()/2 - w/2
	local y = getCore():getScreenHeight()/2 - h/2
	local ui = MarketUI:new(x, y, w, h, player)
	ui:initialise()
	ui:addToUIManager()
	ui:setVisible(true)
	MarketUI.instance = ui
	return ui
end

function MarketUI:new(x,y,w,h,player)
	local o = ISPanel:new(x,y,w,h)
	setmetatable(o,self); self.__index = self
	o.player = player
	o.moveWithMouse = true
	o.backgroundColor = {r=0.06, g=0.06, b=0.08, a=0.95}
	o.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9}
	return o
end

function MarketUI:initialise()
	ISPanel.initialise(self)

	-- Заголовок
	self.title = ISLabel:new(0, 8, FONT_HGT_MEDIUM, "Smart Market - Price Analysis", 1,1,1,1, UIFont.Medium, true)
	self.title:initialise(); self.title:instantiate(); self:addChild(self.title)

	-- Статус: крупный заголовок + цветное время
	local statusY = 36
	self.statusTitle = ISLabel:new(0, statusY, FONT_HGT_MEDIUM, "Market status at ", 0.92,0.92,0.98,1, UIFont.Medium, true)
	self.statusTitle:initialise(); self.statusTitle:instantiate(); self:addChild(self.statusTitle)
	self.statusTime = ISLabel:new(0, statusY, FONT_HGT_MEDIUM, localTimeStr(), 0.5,0.9,1,1, UIFont.Medium, true)
	self.statusTime:initialise(); self.statusTime:instantiate(); self:addChild(self.statusTime)

	-- Кнопки под статусом
	local startY = statusY + 18
	self.refreshButton = ISButton:new(10, startY, 120, 25, "Refresh", self, MarketUI.onRefresh)
	self.refreshButton:initialise(); self.refreshButton:instantiate(); self:addChild(self.refreshButton)

	self.closeButton = ISButton:new(self.width - 130, startY, 120, 25, "Close", self, MarketUI.onClose)
	self.closeButton:initialise(); self.closeButton:instantiate(); self:addChild(self.closeButton)

	-- Колонки TOP Rising / TOP Falling
	local infoY = startY + 32
	local listsY = infoY + 30
	local colW = math.floor((self.width - 30) / 2)

	self.leftLabel = ISLabel:new(10, listsY, FONT_HGT_SMALL, "Top Rising", 0.6,1,0.6,1, UIFont.Small, true)
	self.leftLabel:initialise(); self.leftLabel:instantiate(); self:addChild(self.leftLabel)
	self.rightLabel = ISLabel:new(20 + colW, listsY, FONT_HGT_SMALL, "Top Falling", 1,0.6,0.6,1, UIFont.Small, true)
	self.rightLabel:initialise(); self.rightLabel:instantiate(); self:addChild(self.rightLabel)

	local function addHeaders(self, rootX, listW, y)
		local cols = computeColX(listW)
		local hItem = ISLabel:new(rootX, y, FONT_HGT_SMALL, "Item", 0.8,0.8,0.9,1, UIFont.Small, true)
		hItem:initialise(); hItem:instantiate(); self:addChild(hItem)
		local wBase = getTextManager():MeasureStringX(UIFont.Small, "Base")
		local hBase = ISLabel:new(rootX + cols.base - wBase, y, FONT_HGT_SMALL, "Base", 0.8,0.8,0.9,1, UIFont.Small, true)
		hBase:initialise(); hBase:instantiate(); self:addChild(hBase)
		local wPct = getTextManager():MeasureStringX(UIFont.Small, "%")
		local hPct = ISLabel:new(rootX + cols.delta - wPct, y, FONT_HGT_SMALL, "%", 0.8,0.8,0.9,1, UIFont.Small, true)
		hPct:initialise(); hPct:instantiate(); self:addChild(hPct)
	end

	local headerH = 16
	addHeaders(self, 10, (colW - 10),                listsY + headerH)
	addHeaders(self, 20 + colW, (colW - 10),         listsY + headerH)

	-- размеры списков под 15 строк
	local listTop = listsY + headerH + 14
	local listH = ROW_H * TOP_N

	self.gainersList = ISScrollingListBox:new(10, listTop, colW - 10, listH)
	self.gainersList:initialise(); self.gainersList:instantiate()
	self.gainersList.itemheight = ROW_H
	self.gainersList.font = UIFont.Small
	self.gainersList.drawBorder = true
	self.gainersList.doDrawItem = MarketUI.doDrawRow
	self:addChild(self.gainersList)

	self.losersList = ISScrollingListBox:new(20 + colW, listTop, colW - 10, listH)
	self.losersList:initialise(); self.losersList:instantiate()
	self.losersList.itemheight = ROW_H
	self.losersList.font = UIFont.Small
	self.losersList.drawBorder = true
	self.losersList.doDrawItem = MarketUI.doDrawRow
	self:addChild(self.losersList)

	-- Лента новостей
	local newsY = listTop + listH + 10
	self.newsLabel = ISLabel:new(10, newsY, FONT_HGT_SMALL, "Market News", 0.9,0.9,1,1, UIFont.Small, true)
	self.newsLabel:initialise(); self.newsLabel:instantiate(); self:addChild(self.newsLabel)

	local newsMinH = 110 -- чтобы поместилось в 600px
	self.newsList = ISScrollingListBox:new(10, newsY + 14, self.width - 20, math.max(newsMinH, self.height - (newsY + 20)))
	self.newsList:initialise(); self.newsList:instantiate()
	self.newsList.itemheight = 22
	self.newsList.font = UIFont.Small
	self.newsList.drawBorder = true
	self.newsList.doDrawItem = MarketUI.doDrawNews
	self:addChild(self.newsList)

	-- Тестовая строка на старте (видно сразу)
	self:addTestItems()
	self:loadMarketData()
	self.refreshCooldown = REFRESH_COOLDOWN
	self.nextRefreshAt = 0
end

function MarketUI:update()
	ISPanel.update(self)
	-- центрирование заголовка
	local tm = getTextManager()
	local tw = tm:MeasureStringX(UIFont.Medium, self.title.name)
	self.title:setX((self.width - tw) / 2)
	-- центрирование статуса как одной строки (две части)
	if self.statusTitle and self.statusTime then
		local t1w = tm:MeasureStringX(UIFont.Medium, self.statusTitle.name)
		local t2w = tm:MeasureStringX(UIFont.Medium, self.statusTime.name)
		local totalW = t1w + 8 + t2w
		local sx = (self.width - totalW) / 2
		self.statusTitle:setX(sx)
		self.statusTime:setX(sx + t1w + 8)
	end
	-- кулдаун refresh
	local now = os.time()
	if self.nextRefreshAt and now < self.nextRefreshAt then
		local remain = self.nextRefreshAt - now
		self.refreshButton.enable = false
		self.refreshButton:setTitle(string.format("Refresh (%ds)", remain))
	else
		if not self.refreshButton.enable then
			self.refreshButton.enable = true
			self.refreshButton:setTitle("Refresh")
		end
	end
end

function MarketUI:prerender()
	ISPanel.prerender(self)
	self:drawRectBorder(0,0,self.width,self.height,1,self.borderColor.r,self.borderColor.g,self.borderColor.b)
end

function MarketUI:onClose() self:close() end
function MarketUI:close() self:removeFromUIManager(); MarketUI.instance = nil end
function MarketUI:onRefresh()
	local now = os.time()
	if self.nextRefreshAt and now < self.nextRefreshAt then return end
	self.nextRefreshAt = now + (self.refreshCooldown or REFRESH_COOLDOWN)
	self:loadMarketData()
end

-- Строка сводки (без колонок и цветного фона)
function MarketUI.doDrawRow(list, y, v, alt)
	if y + list:getYScroll() >= list:getHeight() then return y + v.height end
	if y + v.height + list:getYScroll() <= 0 then return y + v.height end

	local row = v.item or {}
	local w = list:getWidth()
	local cols = computeColX(w)
	local textY = y + (v.height - FONT_HGT_SMALL) / 2

	if alt then list:drawRect(0, y, w, v.height - 1, 0.04, 1, 1, 1) end
	list:drawRectBorder(0, y, w, v.height - 1, 0.8, 0.55, 0.55, 0.65)
	if list.selected == v.index then
		list:drawRect(0, y, w, v.height - 1, 0.22, 0.7, 0.5, 0.2)
	end

	local name = ellipsize(row.displayName or row.fullType or "Unknown", cols.nameMax - 6)
	list:drawText(name, 6, textY, 1,1,1,1, UIFont.Small)

	-- Base
	if row.isSP then
		local spW = getTextManager():MeasureStringX(UIFont.Small, " SP")
		list:drawTextRight(row.baseNumFmt or "-", cols.base - spW - 3, textY, 0.9,0.9,0.9,1, UIFont.Small)
		list:drawTextRight(" SP", cols.base, textY, 0.5,0.9,1,1, UIFont.Small)
	else
		list:drawTextRight(row.baseNumFmt or row.baseFmt or "-", cols.base, textY, 0.9,0.9,0.9,1, UIFont.Small)
	end

	-- % только цветом текста (без Now)
	local c = row.deltaColor or { r = 1, g = 1, b = 1, a = 1 }
	list:drawTextRight(row.deltaTxt or "0%", cols.delta, textY, c.r, c.g, c.b, c.a, UIFont.Small)

	return y + v.height
end

-- Строка новости
function MarketUI.doDrawNews(list, y, v, alt)
	if y + list:getYScroll() >= list:getHeight() then return y + v.height end
	if y + v.height + list:getYScroll() <= 0 then return y + v.height end
	local n = v.item or {}
	list:drawRectBorder(0, y, list:getWidth(), v.height - 1, 0.8, 0.5,0.5, 0.6)
	local textY = y + (v.height - FONT_HGT_SMALL) / 2
	list:drawText(n.text or "", 6, textY, 0.9,0.9,0.9,1, UIFont.Small)
	return y + v.height
end

-- ДАННЫЕ
function MarketUI:addTestItems()
	self.gainersList:clear(); self.losersList:clear(); self.newsList:clear()
	local row = {
		displayName = "Test Item",
		baseFmt = fmtPrice(100),
		nowFmt = fmtPrice(120),
		deltaTxt = "+20.0%",
		deltaColor = {r=0.2,g=1,b=0.2,a=1},
		height = 24
	}
	self.gainersList:addItem(row.displayName, row)
	self.newsList:addItem("news", { text = "Very High Demand: Test Item (+20%)", height = 22 })
	if self.statusTime then self.statusTime:setName(localTimeStr()) end
end

function MarketUI:loadMarketData()
	if self.statusTime then
		self.statusTime:setName(localTimeStr() .. " — loading...")
	end
	local selfRef = self
	sendClientCommand(getPlayer(), 'shopItems', 'getData', {})
	local receiveServerCommand
	receiveServerCommand = function(module, command, args)
		if module ~= 'shopItems' then return end
		if command == 'onGetData' then
			Shop.Items = args['shopItems']
			Shop.Sell = args['forSellItems']
			Events.OnServerCommand.Remove(receiveServerCommand)
			if selfRef and selfRef.processMarketData then selfRef:processMarketData() end
		end
	end
	Events.OnServerCommand.Add(receiveServerCommand)
end

function MarketUI:processMarketData()
	if not Shop or not Shop.Sell then
		if self.statusTime then self.statusTime:setName(localTimeStr() .. " — error") end
		return
	end
	self:fillListsFromSell()
	if self.statusTime then
		self.statusTime:setName(localTimeStr())
	end
end

function MarketUI:fillListsFromSell()
	self.gainersList:clear()
	self.losersList:clear()
	self.newsList:clear()

	local gainers, losers = {}, {}
	for fullType, d in pairs(Shop.Sell) do
		if not d.blacklisted and d.price and d.defaultPrice and d.defaultPrice > 0 then
			local base, now = d.defaultPrice, d.price
			local delta = ((now - base) / base) * 100.0
			local isSP = d.specialCoin == true
			local row = {
				fullType = fullType,
				displayName = displayName(fullType),
				isSP = isSP,
				baseNumFmt = fmtPrice(base),
				nowNumFmt  = fmtPrice(now),
				delta = delta,
				deltaTxt = string.format("%+.1f%%", delta),
				deltaColor = (delta >= 0) and {r=0.2,g=1,b=0.2,a=1} or {r=1,g=0.3,b=0.3,a=1},
				height = ROW_H,
				_d = d
			}
			if delta >= 0 then table.insert(gainers, row) else table.insert(losers, row) end
		end
	end

	table.sort(gainers, function(a,b) return a.delta > b.delta end)
	table.sort(losers, function(a,b) return a.delta < b.delta end)

	for i=1, math.min(TOP_N, #gainers) do
		local it = gainers[i]; self.gainersList:addItem(it.displayName, it)
	end
	for i=1, math.min(TOP_N, #losers) do
		local it = losers[i]; self.losersList:addItem(it.displayName, it)
	end

	self:buildNewsFromSell(gainers, losers)
end

function MarketUI:buildNewsFromSell(gainers, losers)
	self.newsList:clear()
	local added = 0

	local function addNews(line)
		if line and line ~= "" then
			self.newsList:addItem("news"..added, { text = line, height = 22 })
			added = added + 1
		end
	end

	for _, src in ipairs({gainers, losers}) do
		for i = 1, math.min(6, #src) do
			local it = src[i]
			local d = it._d
			local line = nil

			if d.demandLevel and d.demandLevel > 1.2 then
				line = string.format("Very High Demand: %s (%s)", it.displayName, it.deltaTxt)
			elseif d.demandLevel and d.demandLevel < 0.8 then
				line = string.format("Demand Falling: %s (%s)", it.displayName, it.deltaTxt)
			elseif d.sellCount and d.demandThreshold and d.sellCount > d.demandThreshold * 2 then
				line = string.format("Large batch sold: %s", it.displayName)
			end
			addNews(line)
		end
	end
end
			-- else
			-- 	line = string.format("Market move: %s (%s)", it.displayName, it.deltaTxt)
-- Вспомогательные расчёты (оставлены для совместимости)
function MarketUI:calculateDemandStatus(d)
	local lvl = d.demandLevel or 1.0
	if lvl > 1.1 then return {type="HIGH", color=DEMAND_COLORS.HIGH, text="[HIGH] High Demand"}
	elseif lvl < 0.9 then return {type="LOW", color=DEMAND_COLORS.LOW, text="[LOW] Low Demand"}
	else return {type="NORMAL", color=DEMAND_COLORS.NORMAL, text="[NORMAL] Normal Demand"} end
end

function MarketUI:calculatePriceChange(d)
	local base = d.defaultPrice or 1
	local cur = d.price or base
	if base <= 0 then return {text="0%", color={r=1,g=1,b=1,a=1}} end
	local change = ((cur - base)/base)*100
	local txt = string.format("%+.1f%%", change)
	if change > 5 then return {text=txt, color={r=1,g=0.2,b=0.2,a=1}}
	elseif change < -5 then return {text=txt, color={r=0.2,g=1,b=0.2,a=1}}
	else return {text=txt, color={r=1,g=1,b=1,a=1}} end
end

function MarketUI:generateMarketNews(d)
	local lvl = d.demandLevel or 1.0
	local cnt = d.sellCount or 0
	local thr = d.demandThreshold or 10
	if lvl > 1.2 then return "Very High Demand!"
	elseif lvl > 1.1 then return "Demand Rising"
	elseif lvl < 0.8 then return "Demand Falling"
	elseif cnt > thr * 2 then return "High Sales"
	elseif cnt > thr then return "Active Sales"
	else return "Quiet Market" end
end

function ShowMarketUI(player) return MarketUI:show(player) end
