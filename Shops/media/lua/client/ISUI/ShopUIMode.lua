ShopUIMode = ShopUIMode or {}

ShopUIMode.MODE_BAR_H = 28

local MODE_ACTIVE = { r = 0.25, g = 0.55, b = 0.3, a = 0.95 }
local MODE_INACTIVE = { r = 0.2, g = 0.2, b = 0.2, a = 0.85 }

function ShopUIMode.isSellMode(ui)
	return ui and ui.shopMode == "sell"
end

function ShopUIMode.sortFavoritesFirst(items)
	table.sort(items, function(a, b)
		local af = (a.item and a.item.favorite) and 1 or 0
		local bf = (b.item and b.item.favorite) and 1 or 0
		if af ~= bf then return af > bf end
		local an = a.item and a.item.name or ""
		local bn = b.item and b.item.name or ""
		return an < bn
	end)
end

function ShopUIMode.clearPanelTabs(ui)
	if not ui.panel then return end
	local toRemove = {}
	for _, viewObject in ipairs(ui.panel.viewList) do
		table.insert(toRemove, viewObject.view)
	end
	for _, view in ipairs(toRemove) do
		ui.panel:removeView(view)
	end
end

function ShopUIMode.createTab(ui, tabType, panelHeight)
	local tab = ShopTabUI:new(0, 0, ui.width, panelHeight)
	tab:initialise()
	tab:setAnchorRight(true)
	tab:setAnchorBottom(true)
	tab:setShopUI(ui)
	tab:setCategoryType(tabType)
	tab.parent = ui
	return tab
end

function ShopUIMode.rebuildTabs(ui)
	if not ui.panel then return end
	ShopUIMode.clearPanelTabs(ui)

	local tabHeaderH = ui._defaultTabHeight or ui.panel.tabHeight
	if ShopUIMode.isSellMode(ui) then
		ui.panel.tabHeight = 0
		tabHeaderH = 0
		local tab = ShopUIMode.createTab(ui, Tab.Sell, ui.panel.height)
		ui.panel:addView("", tab)
		ui.panel:activateView("")
	else
		ui.panel.tabHeight = ui._defaultTabHeight
		local panelHeight = ui.panel.height - ui.panel.tabHeight
		for i = 1, #Shop.TabsBuyOrder do
			local tabType = Shop.TabsBuyOrder[i]
			local tabName = Shop.TabsBuy[tabType]
			local tab = ShopUIMode.createTab(ui, tabType, panelHeight)
			ui.panel:addView(tabName, tab)
		end
		ui.panel:activateView(Shop.TabsBuy[Tab.All])
	end
	ui:onActivateView()
end

function ShopUIMode.updateModeButtons(ui)
	if not ui.modeBuyBtn or not ui.modeSellBtn then return end
	local buyActive = ui.shopMode == "buy"
	ui.modeBuyBtn.backgroundColor = buyActive and MODE_ACTIVE or MODE_INACTIVE
	ui.modeSellBtn.backgroundColor = (not buyActive) and MODE_ACTIVE or MODE_INACTIVE
	if ui.modeSellBtn then
		local hasSell = Shop.hasSellCatalog()
		ui.modeSellBtn.enable = hasSell
		ui.modeSellBtn:setVisible(hasSell)
	end
	if ui.shopMode == "sell" and not Shop.hasSellCatalog() then
		ShopUIMode.setShopMode(ui, "buy")
	end
end

function ShopUIMode.setShopMode(ui, mode)
	if not ui or ui.shopMode == mode then return end
	if mode == "sell" and not Shop.hasSellCatalog() then return end
	ui.shopMode = mode
	ui.cartItems:clear()
	ui.shopItemsCache = {}
	ui.reloadItems = true
	ui.lastTab = "none"
	ShopUIMode.rebuildTabs(ui)
	ShopUIMode.updateModeButtons(ui)
end

function ShopUIMode.onModeBuy(ui)
	ShopUIMode.setShopMode(ui, "buy")
end

function ShopUIMode.onModeSell(ui)
	ShopUIMode.setShopMode(ui, "sell")
end

function ShopUIMode.createModeButtons(ui, th)
	local y = th + 4
	ui.modeBuyBtn = ISButton:new(8, y, 100, 22, getText("IGUI_Shop_Mode_Buy"), ui, function(target)
		ShopUIMode.onModeBuy(target)
	end)
	ui.modeBuyBtn:initialise()
	ui.modeBuyBtn.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
	ui:addChild(ui.modeBuyBtn)

	ui.modeSellBtn = ISButton:new(114, y, 100, 22, getText("IGUI_Shop_Mode_Sell"), ui, function(target)
		ShopUIMode.onModeSell(target)
	end)
	ui.modeSellBtn:initialise()
	ui.modeSellBtn.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
	ui:addChild(ui.modeSellBtn)

	ShopUIMode.updateModeButtons(ui)
end
