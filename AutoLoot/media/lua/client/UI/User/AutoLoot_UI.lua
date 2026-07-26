-- Author: FD --
-- Вариант A: пульт (статус → сумка → категории → подписка)

UI_AutoLoot = ISPanel:derive("UI_AutoLoot")
PM = PM or {}
Shop = Shop or {}
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {}
PM.Inventory = PM.Inventory or {}
PM.InventorySelected = PM.InventorySelected or {}
PM.TimeActivateAutoLoot = PM.TimeActivateAutoLoot or {}
PM.AutolootDurationAction = PM.AutolootDurationAction or {}
PM.AutoLootSandBoxBuy = PM.AutoLootSandBoxBuy or {}
PM.AutoLootMessage = PM.AutoLootMessage or {}
PM.AutolootCustomItems = PM.AutolootCustomItems or {}

local price
local remainingTime = 0

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local icon_money = getTexture("media/textures/pm_money.png")

-- Своя палитра (янтарь / олива), не стиль PlayerMenu
local COL = {
	bg = { r = 0.07, g = 0.08, b = 0.07, a = 0.94 },
	border = { r = 0.52, g = 0.42, b = 0.20, a = 1 },
	panel = { r = 0.12, g = 0.13, b = 0.11, a = 0.9 },
	text = { r = 0.88, g = 0.86, b = 0.78, a = 1 },
	muted = { r = 0.55, g = 0.52, b = 0.42, a = 1 },
	amber = { r = 0.72, g = 0.55, b = 0.22, a = 1 },
	olive = { r = 0.42, g = 0.52, b = 0.28, a = 1 },
	oliveDim = { r = 0.22, g = 0.26, b = 0.16, a = 0.95 },
	danger = { r = 0.45, g = 0.22, b = 0.16, a = 0.95 },
	barBg = { r = 0.18, g = 0.17, b = 0.14, a = 1 },
	barFill = { r = 0.62, g = 0.48, b = 0.18, a = 1 },
	barFull = { r = 0.65, g = 0.28, b = 0.18, a = 1 },
}

-- Группы категорий: UI-кнопка ↔ ключи DisplayCategory
local CATEGORY_DEFS = {
	{ label = "IGUI_Accessories", check = "ClothM", keys = { "ClothM", "ClothA" } },
	{ label = "IGUI_Tool",        check = "Tool",   keys = { "Tool" } },
	{ label = "IGUI_Money",       check = "Money",  keys = { "Junk", "Useless", "Money" } },
	{ label = "IGUI_WepFire",     check = "WepFire", keys = { "WepFire", "Ammo" } },
	{ label = "IGUI_WepMelee",    check = "WepMelee", keys = { "WepMelee" } },
	{ label = "IGUI_WepAmmoMag",  check = "WepAmmoMag", keys = { "WepAmmoMag" } },
	{ label = "IGUI_WeaponPart",  check = "WepPart", keys = { "WepPart" } },
	{ label = "IGUI_Cloth",       check = "Cloth",  keys = { "Cloth" } },
	{ label = "IGUI_Food",        check = "Food",   keys = { "Food", "FoodN" } },
}

-- DisplayCategory → текст кнопки автосбора
local DISPLAY_CAT_LABEL = {}
for _, def in ipairs(CATEGORY_DEFS) do
	for _, key in ipairs(def.keys) do
		DISPLAY_CAT_LABEL[key] = def.label
	end
end

local function getItemDisplayCategory(fullType)
	if not fullType then return nil end
	local sm = getScriptManager()
	if not sm then return nil end
	local si = sm:getItem(fullType) or sm:FindItem(fullType)
	if si and si.getDisplayCategory then
		return si:getDisplayCategory()
	end
	return nil
end

-- суффикс только для скупки: (скупка) или (скупка, Аксессуары)
local function formatItemMetaSuffix(fullType, displayCategory)
	if not (AutoLoot_IsShopSellItem and AutoLoot_IsShopSellItem(fullType)) then
		return ""
	end
	local parts = { getText("IGUI_AutoLoot_InShop") }
	local catKey = displayCategory or getItemDisplayCategory(fullType)
	local igui = catKey and DISPLAY_CAT_LABEL[catKey]
	if igui then
		table.insert(parts, getText(igui))
	end
	return " (" .. table.concat(parts, ", ") .. ")"
end

local function refreshSandbox()
	if not SandboxVars or not SandboxVars.AutoLoot then return end
	price = SandboxVars.AutoLoot.PriceAutoLoot
	PM.AutolootDurationAction = SandboxVars.AutoLoot.DurabilityAutoLoot
	PM.AutoLootSandBoxBuy = SandboxVars.AutoLoot.Buy
end

Events.EveryTenMinutes.Add(refreshSandbox)

local function isAutoLootBag(bag)
	if not bag or not bag.isEquipped or not bag:isEquipped() then
		return false
	end
	local bagType = bag:getType()
	if bagType == "KeyRing" then
		return false
	end
	-- Бумажник: только свои категории (WalletContainers)
	if bag.getBodyLocation and bag:getBodyLocation() == "Wallet" then
		return false
	end
	if bag.canBeEquipped and bag:canBeEquipped() == "Wallet" then
		return false
	end
	if bagType and string.find(bagType, "Wallet", 1, true) == 1 then
		return false
	end
	return true
end

local function BackpacksUser()
	local player = getPlayer()
	PM.Inventory = {}
	if not player then return end
	local containers = player:getInventory():getItemsFromCategory("Container")
	for i = containers:size() - 1, 0, -1 do
		local bag = containers:get(i)
		if isAutoLootBag(bag) then
			table.insert(PM.Inventory, bag)
		end
	end
end

local function saveConfig()
	AutoLoot_SaveConfig()
end

local function setCategoryGroup(def, enabled)
	for _, key in ipairs(def.keys) do
		PM.AutolootDisplayCategory[key] = enabled and true or nil
	end
end

local function isCategoryOn(def)
	return PM.AutolootDisplayCategory[def.check] == true
end

local function calculateTime()
	local durationDays = tonumber(PM.AutolootDurationAction) or 0
	local subscriptionDuration = durationDays * 24 * 60 * 60
	local activate = PM.TimeActivateAutoLoot
	if type(activate) == "table" or activate == nil then
		remainingTime = 0
		return 0, 0, 0
	end
	remainingTime = activate + subscriptionDuration - os.time()
	if remainingTime <= 0 then
		remainingTime = 0
		return 0, 0, 0
	end
	local d = math.floor(remainingTime / (24 * 60 * 60))
	local h = math.floor((remainingTime % (24 * 60 * 60)) / (60 * 60))
	local m = math.floor((remainingTime % (60 * 60)) / 60)
	return d, h, m
end

local function styleBtn(btn, fill, border)
	btn.backgroundColor = { r = fill.r, g = fill.g, b = fill.b, a = fill.a or 0.95 }
	btn.backgroundColorMouseOver = {
		r = math.min(1, fill.r + 0.08),
		g = math.min(1, fill.g + 0.08),
		b = math.min(1, fill.b + 0.08),
		a = 1
	}
	btn.borderColor = { r = border.r, g = border.g, b = border.b, a = border.a or 1 }
end

local function Purchase()
	sendClientCommand(getPlayer(), "BalanceAndSH", "getServerTime", {})
	local receiveServerCommand
	receiveServerCommand = function(module, command, args)
		if module ~= "BalanceAndSH" then return end
		if command == "onGetServerTime1" then
			PM.TimeActivateAutoLoot = args.time
			local saveData = {
				delta = price,
				balance = PM.Balance,
				autoloot = PM.TimeActivateAutoLoot,
				action = "buy autoloot",
			}
			sendClientCommand(getPlayer(), "BalanceAndSH", "saveUserData", saveData)
			sendClientCommand(getPlayer(), "AdminAutoLoot", "purchaseAutoLoot", saveData)
			LoadBalanceAndSafeHousePlayer()
			Events.OnServerCommand.Remove(receiveServerCommand)
			GetTimeActivateAutoLootForcalculateTime()
		end
	end
	Events.OnServerCommand.Add(receiveServerCommand)
end

function UI_AutoLoot:close()
	self:setVisible(false)
	self:removeFromUIManager()
	UI_AutoLoot.instance = nil
end

function UI_AutoLoot:initialise()
	ISPanel.initialise(self)
	refreshSandbox()
	BackpacksUser()
	PM.InventorySelected = PM.InventorySelected or self.player
	if type(PM.InventorySelected) == "table" then
		PM.InventorySelected = self.player
	end

	local pad = 12
	local y = pad

	-- Заголовок + закрыть
	self.titleLabel = ISLabel:new(pad, y, FONT_HGT_MEDIUM, getText("IGUI_AutoLoot"), COL.amber.r, COL.amber.g, COL.amber.b, 1, UIFont.Medium, true)
	self.titleLabel:initialise()
	self.titleLabel:instantiate()
	self:addChild(self.titleLabel)

	self.closeBtn = ISButton:new(self.width - pad - 24, y - 2, 24, 24, "X", self, UI_AutoLoot.onClick)
	self.closeBtn.internal = "CANCEL"
	self.closeBtn:initialise()
	self.closeBtn:instantiate()
	styleBtn(self.closeBtn, COL.danger, COL.border)
	self:addChild(self.closeBtn)
	y = y + FONT_HGT_MEDIUM + 10

	-- Блок статуса: большой вкл/выкл + текст
	self.powerBtn = ISButton:new(pad, y, 110, 44, getText("IGUI_AutoLoot_Off"), self, UI_AutoLoot.onClick)
	self.powerBtn.internal = "POWER"
	self.powerBtn:initialise()
	self.powerBtn:instantiate()
	self.powerBtn.font = UIFont.Medium
	styleBtn(self.powerBtn, COL.oliveDim, COL.border)
	self:addChild(self.powerBtn)

	self.statusLabel = ISLabel:new(pad + 122, y + 4, FONT_HGT_MEDIUM, "", COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Medium, true)
	self.statusLabel:initialise()
	self.statusLabel:instantiate()
	self:addChild(self.statusLabel)

	self.hintLabel = ISLabel:new(pad + 122, y + 24, FONT_HGT_SMALL, getText("IGUI_AutoLoot_Hint"), COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small, true)
	self.hintLabel:initialise()
	self.hintLabel:instantiate()
	self:addChild(self.hintLabel)

	self.msgBtn = ISButton:new(self.width - pad - 90, y + 8, 90, 28, getText("IGUI_ActivateMessage"), self, UI_AutoLoot.onClick)
	self.msgBtn.internal = "MSG"
	self.msgBtn:initialise()
	self.msgBtn:instantiate()
	styleBtn(self.msgBtn, COL.panel, COL.border)
	self:addChild(self.msgBtn)
	y = y + 56

	-- Куда класть
	self.destLabel = ISLabel:new(pad, y, FONT_HGT_SMALL, getText("IGUI_AutoLoot_Dest"), COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small, true)
	self.destLabel:initialise()
	self.destLabel:instantiate()
	self:addChild(self.destLabel)
	y = y + FONT_HGT_SMALL + 4

	self.bagButtons = {}
	self.bagRowY = y
	self:rebuildBagButtons()
	y = y + 52

	self.weightLabel = ISLabel:new(pad, y, FONT_HGT_SMALL, "", COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small, true)
	self.weightLabel:initialise()
	self.weightLabel:instantiate()
	self:addChild(self.weightLabel)
	y = y + FONT_HGT_SMALL + 4
	self.weightBarY = y
	self.weightBarH = 8
	y = y + self.weightBarH + 12

	-- Категории
	self.catLabel = ISLabel:new(pad, y, FONT_HGT_SMALL, getText("IGUI_Category"), COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small, true)
	self.catLabel:initialise()
	self.catLabel:instantiate()
	self:addChild(self.catLabel)

	local allW = 56
	self.allBtn = ISButton:new(self.width - pad - allW * 2 - 6, y - 2, allW, 20, getText("IGUI_AutoLoot_All"), self, UI_AutoLoot.onClick)
	self.allBtn.internal = "ALL"
	self.allBtn:initialise()
	self.allBtn:instantiate()
	styleBtn(self.allBtn, COL.panel, COL.border)
	self:addChild(self.allBtn)

	self.noneBtn = ISButton:new(self.width - pad - allW, y - 2, allW, 20, getText("IGUI_AutoLoot_None"), self, UI_AutoLoot.onClick)
	self.noneBtn.internal = "NONE"
	self.noneBtn:initialise()
	self.noneBtn:instantiate()
	styleBtn(self.noneBtn, COL.panel, COL.border)
	self:addChild(self.noneBtn)
	y = y + FONT_HGT_SMALL + 8

	self.categoryButtons = {}
	local cols = 3
	local gap = 6
	local catW = math.floor((self.width - pad * 2 - gap * (cols - 1)) / cols)
	local catH = 28
	for i, def in ipairs(CATEGORY_DEFS) do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local bx = pad + col * (catW + gap)
		local by = y + row * (catH + gap)
		local btn = ISButton:new(bx, by, catW, catH, getText(def.label), self, UI_AutoLoot.onCategoryClick)
		btn.internal = "CAT"
		btn.catIndex = i
		btn:initialise()
		btn:instantiate()
		btn:setFont(UIFont.Small)
		self:addChild(btn)
		self.categoryButtons[i] = btn
	end
	y = y + 3 * (catH + gap) + 8

	-- Свои предметы: поиск + список (как в скупке), без ПКМ
	self.customLabel = ISLabel:new(pad, y, FONT_HGT_SMALL, "", COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small, true)
	self.customLabel:initialise()
	self.customLabel:instantiate()
	self:addChild(self.customLabel)

	self.customClearBtn = ISButton:new(self.width - pad - 70, y - 2, 70, 20, getText("IGUI_AutoLoot_CustomClear"), self, UI_AutoLoot.onClick)
	self.customClearBtn.internal = "CUSTOM_CLEAR"
	self.customClearBtn:initialise()
	self.customClearBtn:instantiate()
	styleBtn(self.customClearBtn, COL.panel, COL.border)
	self:addChild(self.customClearBtn)
	y = y + FONT_HGT_SMALL + 6

	local searchLabelW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_AutoLoot_Search")) + 6
	self.customSearchLabel = ISLabel:new(pad, y + 3, FONT_HGT_SMALL, getText("IGUI_AutoLoot_Search"), COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small, true)
	self.customSearchLabel:initialise()
	self.customSearchLabel:instantiate()
	self:addChild(self.customSearchLabel)

	self.customSearchEntry = ISTextEntryBox:new("", pad + searchLabelW, y - 2, self.width - pad * 2 - searchLabelW, 20)
	self.customSearchEntry.font = UIFont.Small
	self.customSearchEntry:initialise()
	self.customSearchEntry:instantiate()
	self.customSearchEntry:setText("")
	self.customSearchEntry:setClearButton(true)
	self.customSearchEntry.onTextChange = function()
		if UI_AutoLoot.instance then
			UI_AutoLoot.instance:refreshCustomList()
		end
	end
	self:addChild(self.customSearchEntry)
	y = y + 24

	self.customHint = ISLabel:new(pad, y, FONT_HGT_SMALL, getText("IGUI_AutoLoot_CustomHint"), COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small, true)
	self.customHint:initialise()
	self.customHint:instantiate()
	self:addChild(self.customHint)
	y = y + FONT_HGT_SMALL + 4

	local listH = 110
	self.customList = ISScrollingListBox:new(pad, y, self.width - pad * 2, listH)
	self.customList:initialise()
	self.customList:instantiate()
	self.customList.itemheight = 22
	self.customList.font = UIFont.Small
	self.customList.drawBorder = true
	self.customList.backgroundColor = { r = 0.1, g = 0.1, b = 0.09, a = 0.9 }
	self.customList.borderColor = COL.border
	self.customList:setOnMouseDownFunction(self, UI_AutoLoot.onCustomListClick)
	self:addChild(self.customList)
	y = y + listH + 10

	self:refreshCustomList()

	-- Подписка: цена + Купить (без продления)
	self.subY = y
	self.buyInfoLabel = ISLabel:new(pad, y + 6, FONT_HGT_SMALL, "", COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small, true)
	self.buyInfoLabel:initialise()
	self.buyInfoLabel:instantiate()
	self:addChild(self.buyInfoLabel)

	self.Buy = ISButton:new(self.width - pad - 100, y, 100, 28, getText("IGUI_Buy"), self, UI_AutoLoot.onClick)
	self.Buy.internal = "Buy"
	self.Buy:initialise()
	self.Buy:instantiate()
	styleBtn(self.Buy, COL.amber, COL.border)
	self:addChild(self.Buy)

	self:refreshCategoryButtons()
	self:refreshPowerVisual()
	self:refreshMsgVisual()
	self.bagListSig = self:getBagListSignature()
end

function UI_AutoLoot:clearBagButtons()
	if not self.bagButtons then return end
	for _, btn in ipairs(self.bagButtons) do
		self:removeChild(btn)
	end
	self.bagButtons = {}
end

function UI_AutoLoot:rebuildBagButtons()
	self:clearBagButtons()
	BackpacksUser()
	local pad = 12
	local gap = 6
	local btnH = 44
	local entries = { { data = self.player, title = getText("IGUI_Main_Inventory") } }
	for _, bag in ipairs(PM.Inventory) do
		table.insert(entries, { data = bag, title = bag:getName() })
	end

	local n = #entries
	local btnW = math.floor((self.width - pad * 2 - gap * math.max(0, n - 1)) / math.max(1, n))
	btnW = math.min(btnW, 140)
	btnW = math.max(btnW, 70)

	for i, entry in ipairs(entries) do
		local bx = pad + (i - 1) * (btnW + gap)
		local shortTitle = entry.title
		if getTextManager():MeasureStringX(UIFont.Small, shortTitle) > btnW - 8 then
			while #shortTitle > 3 and getTextManager():MeasureStringX(UIFont.Small, shortTitle .. "..") > btnW - 8 do
				shortTitle = string.sub(shortTitle, 1, #shortTitle - 1)
			end
			shortTitle = shortTitle .. ".."
		end
		local btn = ISButton:new(bx, self.bagRowY, btnW, btnH, shortTitle, self, UI_AutoLoot.onBagClick)
		btn.internal = "BAG"
		btn.bagData = entry.data
		btn:initialise()
		btn:instantiate()
		btn:setFont(UIFont.Small)
		btn.tooltip = entry.title
		self:addChild(btn)
		table.insert(self.bagButtons, btn)
	end
	self:refreshBagVisual()
end

function UI_AutoLoot:refreshBagVisual()
	for _, btn in ipairs(self.bagButtons or {}) do
		local selected = (btn.bagData == PM.InventorySelected)
		if selected then
			styleBtn(btn, COL.olive, COL.amber)
		else
			styleBtn(btn, COL.panel, COL.border)
		end
	end
end

function UI_AutoLoot:refreshCategoryButtons()
	for i, btn in ipairs(self.categoryButtons or {}) do
		local def = CATEGORY_DEFS[i]
		if isCategoryOn(def) then
			styleBtn(btn, COL.olive, COL.amber)
			btn:setTitle(getText(def.label))
		else
			styleBtn(btn, COL.panel, COL.border)
			btn:setTitle(getText(def.label))
		end
	end
end

function UI_AutoLoot:refreshPowerVisual()
	if not self.powerBtn then return end
	local on = PM.Autoloot and remainingTime > 0
	if on then
		self.powerBtn:setTitle(getText("IGUI_AutoLoot_On"))
		styleBtn(self.powerBtn, COL.olive, COL.amber)
	else
		self.powerBtn:setTitle(getText("IGUI_AutoLoot_Off"))
		styleBtn(self.powerBtn, COL.oliveDim, COL.border)
	end
end

function UI_AutoLoot:refreshMsgVisual()
	if not self.msgBtn then return end
	if PM.AutoLootMessage then
		styleBtn(self.msgBtn, COL.olive, COL.amber)
	else
		styleBtn(self.msgBtn, COL.panel, COL.border)
	end
end

local function ensureAutoLootItemIndex()
	if UI_AutoLoot.itemsIndex then return end
	UI_AutoLoot.itemsIndex = {}
	local sm = getScriptManager()
	if not sm then return end
	local all = sm:getAllItems()
	if not all then return end
	for i = 0, all:size() - 1 do
		local si = all:get(i)
		if si and not si:getObsolete() and not si:isHidden() then
			local fullType = si:getFullName()
			if (not fullType or fullType == "") and si.getModule and si.getName then
				local mod = si:getModule()
				if mod then
					fullType = mod:getName() .. "." .. si:getName()
				end
			end
			if fullType and fullType ~= "" then
				local bodyLoc = (si.getBodyLocation and si:getBodyLocation()) or ""
				local canEq = (si.canBeEquipped and si:canBeEquipped()) or ""
				local typeName = si:getName() or ""
				local isWallet = bodyLoc == "Wallet" or canEq == "Wallet"
					or string.find(typeName, "Wallet", 1, true) == 1
				if not isWallet then
					local displayName = si:getDisplayName() or fullType
					local displayCategory = (si.getDisplayCategory and si:getDisplayCategory()) or nil
					table.insert(UI_AutoLoot.itemsIndex, {
						fullType = fullType,
						name = displayName,
						nameLower = string.lower(displayName),
						typeLower = string.lower(fullType),
						displayCategory = displayCategory,
					})
				end
			end
		end
	end
end

function UI_AutoLoot:refreshCustomList()
	if not self.customList then return end
	local count = AutoLoot_CountCustomItems and AutoLoot_CountCustomItems() or 0
	local maxN = AUTOLOOT_CUSTOM_MAX or 10
	if self.customLabel then
		self.customLabel.name = getText("IGUI_AutoLoot_Custom") .. " (" .. count .. "/" .. maxN .. ")"
	end

	self.customList:clear()
	local filter = ""
	if self.customSearchEntry then
		filter = string.lower(string.trim(self.customSearchEntry:getInternalText() or ""))
	end

	if filter == "" then
		if self.customHint then
			self.customHint.name = getText("IGUI_AutoLoot_CustomHintList")
		end
		local list = AutoLoot_GetCustomItemList and AutoLoot_GetCustomItemList() or {}
		if #list == 0 then
			self.customList:addItem(getText("IGUI_AutoLoot_CustomEmpty"), { fullType = nil, mode = "none" })
		else
			for _, fullType in ipairs(list) do
				local name = AutoLoot_GetItemDisplayName(fullType)
				local suffix = formatItemMetaSuffix(fullType, getItemDisplayCategory(fullType))
				self.customList:addItem("× " .. name .. suffix, { fullType = fullType, mode = "remove" })
			end
		end
		return
	end

	if string.len(filter) < 2 then
		if self.customHint then
			self.customHint.name = getText("IGUI_AutoLoot_SearchMin2")
		end
		self.customList:addItem(getText("IGUI_AutoLoot_SearchMin2"), { fullType = nil, mode = "none" })
		return
	end

	if self.customHint then
		self.customHint.name = getText("IGUI_AutoLoot_CustomHintSearch")
	end
	ensureAutoLootItemIndex()
	local added = 0
	for _, it in ipairs(UI_AutoLoot.itemsIndex or {}) do
		if string.contains(it.nameLower, filter) or string.contains(it.typeLower, filter) then
			local inCustom = PM.AutolootCustomItems and PM.AutolootCustomItems[it.fullType]
			local prefix = inCustom and "✓ " or "+ "
			local suffix = formatItemMetaSuffix(it.fullType, it.displayCategory)
			self.customList:addItem(prefix .. it.name .. suffix, { fullType = it.fullType, mode = "add" })
			added = added + 1
			if added >= 80 then break end
		end
	end
	if added == 0 then
		self.customList:addItem(getText("IGUI_AutoLoot_SearchNone"), { fullType = nil, mode = "none" })
	end
end

function UI_AutoLoot:onCustomListClick(item)
	if not item or not item.fullType or item.mode == "none" then return end
	if item.mode == "remove" then
		AutoLoot_RemoveCustomItem(item.fullType)
		self:refreshCustomList()
		return
	end
	if item.mode == "add" then
		if PM.AutolootCustomItems and PM.AutolootCustomItems[item.fullType] then
			AutoLoot_RemoveCustomItem(item.fullType)
			self:refreshCustomList()
			return
		end
		local ok, err = AutoLoot_AddCustomItem(item.fullType)
		if ok then
			self:refreshCustomList()
		elseif err == "full" then
			getPlayer():Say(getText("IGUI_AutoLoot_CustomFull"))
		end
	end
end

function UI_AutoLoot:getSelectedInv()
	local player = self.player or getPlayer()
	if type(PM.InventorySelected) == "table" or not PM.InventorySelected then
		PM.InventorySelected = player
	end
	if PM.InventorySelected ~= player and PM.InventorySelected.isEquipped and not PM.InventorySelected:isEquipped() then
		PM.InventorySelected = player
		saveConfig()
	end
	return PM.InventorySelected:getInventory()
end

-- Сигнатура одетых сумок: смена состава → пересобрать кнопки
function UI_AutoLoot:getBagListSignature()
	BackpacksUser()
	local parts = { "main" }
	for _, bag in ipairs(PM.Inventory) do
		local id = bag.getID and bag:getID() or tostring(bag)
		table.insert(parts, tostring(id))
	end
	return table.concat(parts, "|")
end

function UI_AutoLoot:ensureBagListFresh()
	local sig = self:getBagListSignature()
	if sig == self.bagListSig then return end
	self.bagListSig = sig

	local player = self.player or getPlayer()
	local stillEquipped = (PM.InventorySelected == player)
	if not stillEquipped then
		for _, bag in ipairs(PM.Inventory) do
			if bag == PM.InventorySelected then
				stillEquipped = true
				break
			end
		end
	end
	if not stillEquipped then
		PM.InventorySelected = player
		saveConfig()
	end
	self:rebuildBagButtons()
end

-- Реальный лимит как в ISInventoryPage
function UI_AutoLoot:getWeightStats()
	local player = self.player or getPlayer()
	local inv = self:getSelectedInv()
	if not inv or not player then
		return 0, 1
	end
	local curW = inv:getCapacityWeight() or 0
	local maxW
	if PM.InventorySelected == player then
		maxW = player:getMaxWeight() or inv:getCapacity() or 1
	else
		maxW = inv:getEffectiveCapacity(player) or inv:getCapacity() or 1
	end
	return curW, maxW
end

function UI_AutoLoot:onClick(button)
	if button.internal == "CANCEL" then
		self:close()
		return
	end
	if button.internal == "POWER" then
		if remainingTime <= 0 then return end
		PM.Autoloot = not PM.Autoloot
		if PM.Autoloot then
			getPlayer():setHaloNote(getText("IGUI_AutolootActivate"), 255, 255, 100, 300)
		else
			getPlayer():setHaloNote(getText("IGUI_AutolootDeActivate"), 255, 255, 100, 300)
		end
		self:refreshPowerVisual()
		saveConfig()
		return
	end
	if button.internal == "MSG" then
		PM.AutoLootMessage = not PM.AutoLootMessage
		if PM.AutoLootMessage then
			getPlayer():setHaloNote(getText("IGUI_AutolootMessageActivate"), 255, 255, 100, 300)
		else
			getPlayer():setHaloNote(getText("IGUI_AutolootMessageDeActivate"), 255, 255, 100, 300)
		end
		self:refreshMsgVisual()
		saveConfig()
		return
	end
	if button.internal == "ALL" then
		for _, def in ipairs(CATEGORY_DEFS) do
			setCategoryGroup(def, true)
		end
		self:refreshCategoryButtons()
		saveConfig()
		return
	end
	if button.internal == "NONE" then
		for _, def in ipairs(CATEGORY_DEFS) do
			setCategoryGroup(def, false)
		end
		self:refreshCategoryButtons()
		saveConfig()
		return
	end
	if button.internal == "CUSTOM_CLEAR" then
		AutoLoot_ClearCustomItems()
		self:refreshCustomList()
		return
	end
	if button.internal == "Buy" then
		if price ~= nil and PM.Balance ~= nil and PM.Balance >= price then
			Purchase()
		else
			getPlayer():Say(getText("IGUI_NoMoney"))
		end
	end
end

function UI_AutoLoot:onCategoryClick(button)
	local def = CATEGORY_DEFS[button.catIndex]
	if not def then return end
	setCategoryGroup(def, not isCategoryOn(def))
	self:refreshCategoryButtons()
	saveConfig()
end

function UI_AutoLoot:onBagClick(button)
	PM.InventorySelected = button.bagData
	self:refreshBagVisual()
	saveConfig()
end

function UI_AutoLoot:prerender()
	self:drawRect(0, 0, self.width, self.height, COL.bg.a, COL.bg.r, COL.bg.g, COL.bg.b)
	self:drawRectBorder(0, 0, self.width, self.height, COL.border.a, COL.border.r, COL.border.g, COL.border.b)
	self:drawRectBorder(1, 1, self.width - 2, self.height - 2, 0.35, COL.amber.r, COL.amber.g, COL.amber.b)
end

function UI_AutoLoot:render()
	self:ensureBagListFresh()

	local d, h, m = calculateTime()

	if remainingTime > 0 or not PM.AutoLootSandBoxBuy then
		self.Buy:setEnable(false)
	else
		self.Buy:setEnable(true)
	end

	if remainingTime <= 0 then
		self.powerBtn:setEnable(false)
		if PM.Autoloot then
			PM.Autoloot = false
			saveConfig()
		end
	else
		self.powerBtn:setEnable(true)
	end
	self:refreshPowerVisual()

	if remainingTime > 0 then
		local timeStr = string.format("%d%s %d%s %d%s", d, getText("IGUI_Day"), h, getText("IGUI_Hour"), m, getText("IGUI_Minute"))
		if PM.Autoloot then
			self.statusLabel.name = getText("IGUI_AutoLoot_Working") .. " · " .. timeStr
			self.statusLabel:setColor(COL.olive.r, COL.olive.g, COL.olive.b)
		else
			self.statusLabel.name = getText("IGUI_AutoLoot_Paused") .. " · " .. timeStr
			self.statusLabel:setColor(COL.amber.r, COL.amber.g, COL.amber.b)
		end
	else
		self.statusLabel.name = getText("IGUI_AutoLoot_NoSub")
		self.statusLabel:setColor(COL.danger.r, COL.danger.g, COL.danger.b)
	end

	local days = tostring(PM.AutolootDurationAction or "")
	local priceStr = tostring(price or 0)
	self.buyInfoLabel.name = getText("IGUI_BuyInfo") .. days .. getText("IGUI_BuyInfoDay") .. priceStr
	local textWid = getTextManager():MeasureStringX(UIFont.Small, self.buyInfoLabel.name)
	if icon_money then
		self:drawTextureScaledAspect(icon_money, 12 + textWid + 4, self.subY + 5, 16, 16, 1, 1, 1, 1)
	end

	local curW, maxW = self:getWeightStats()
	local ratio = math.min(1, curW / math.max(0.01, maxW))
	self.weightLabel.name = string.format("%.1f / %d", curW, maxW)
	local barX, barW = 12, self.width - 24
	self:drawRect(barX, self.weightBarY, barW, self.weightBarH, 1, COL.barBg.r, COL.barBg.g, COL.barBg.b)
	local fill = COL.barFill
	if ratio >= 0.95 then fill = COL.barFull end
	self:drawRect(barX, self.weightBarY, math.floor(barW * ratio), self.weightBarH, 1, fill.r, fill.g, fill.b)
	self:drawRectBorder(barX, self.weightBarY, barW, self.weightBarH, 0.7, COL.border.r, COL.border.g, COL.border.b)
end

function UI_AutoLoot:new(x, y, width, height, player)
	local o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.borderColor = COL.border
	o.backgroundColor = COL.bg
	o.width = width
	o.height = height
	o.player = player
	o.moveWithMouse = true
	UI_AutoLoot.instance = o
	o.buttonBorderColor = COL.border
	return o
end
