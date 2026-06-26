ShopUIMode = ShopUIMode or {}

require "ISUI/ShopCategoryButton"

ShopUIMode.SIDEBAR_W = 154
ShopUIMode.CART_W = 330
ShopUIMode.PAD = 6
ShopUIMode.CAT_BTN_H = 28
ShopUIMode.CAT_BTN_GAP = 3
ShopUIMode.ICON_SLOT = 26
ShopUIMode.COIN_ICON_DY = -6
ShopUIMode.CART_HEADER_H = 30
ShopUIMode.CART_FOOTER_H = 106
ShopUIMode.CART_VALUE_W = 96
ShopUIMode.CART_FOOTER_LABEL_OFF = 66
ShopUIMode.CART_FOOTER_ROW1_OFF = 40
ShopUIMode.CART_FOOTER_ROW2_OFF = 18
ShopUIMode.CART_FOOTER_TEXT_DY = -3
ShopUIMode.CART_FOOTER_COIN_DY = -4

function ShopUIMode.getCartProgressBarLayout(ui)
	local geom = ShopUIMode.getGeometry(ui)
	local innerX = geom.cartX + 6
	local innerW = geom.cartW - 12
	local btnY = geom.cartY + geom.cartH - 32
	local btnW = (innerW - 6) / 2
	local payColX = innerX + btnW + 6
	local barH = 10
	local barY = btnY - barH - 4
	return payColX, barY, btnW, barH
end

function ShopUIMode.pinCartFooter(ui)
	if not ui.cartItems then return end
	local geom = ShopUIMode.getGeometry(ui)
	local cx, cy, cw, ch = geom.cartX, geom.cartY, geom.cartW, geom.cartH
	local innerX = cx + 6
	local innerW = cw - 12
	local headerH = ShopUIMode.CART_HEADER_H
	local footerH = ShopUIMode.CART_FOOTER_H
	local listTop = cy + 4 + headerH
	local listH = ch - 4 - footerH - headerH
	local btnY = cy + ch - 32
	local btnW = (innerW - 6) / 2
	local payColX = innerX + btnW + 6
	local labelY = btnY - ShopUIMode.CART_FOOTER_LABEL_OFF
	local row1Y = btnY - ShopUIMode.CART_FOOTER_ROW1_OFF
	local row2Y = btnY - ShopUIMode.CART_FOOTER_ROW2_OFF
	local coinDy = ShopUIMode.CART_FOOTER_COIN_DY
	local textDy = ShopUIMode.CART_FOOTER_TEXT_DY
	local balanceX = innerX + 4
	local totalColX = payColX + 4

	if ui.cartPanel then
		ui.cartPanel:setX(cx)
		ui.cartPanel:setY(cy)
		ui.cartPanel:setWidth(cw)
		ui.cartPanel:setHeight(ch)
	end

	ui.cartItems:setX(innerX)
	ui.cartItems:setY(listTop)
	ui.cartItems:setWidth(innerW)
	ui.cartItems:setHeight(listH)

	if ui.cartHeaderTex then
		local cartImg = Shop.textures.Cart
		local iconSize = math.min(cartImg.scale, headerH - 6)
		ui.cartHeaderTex.scaledWidth = iconSize
		ui.cartHeaderTex.scaledHeight = iconSize
		ui.cartHeaderTex:setX(innerX + (innerW - iconSize) / 2)
		ui.cartHeaderTex:setY(cy + 4 + (headerH - iconSize) / 2)
		ui.cartHeaderTex:setVisible(true)
		ui.cartHeaderTex:bringToTop()
	end

	if ui.balanceLabel then ui.balanceLabel:setX(balanceX); ui.balanceLabel:setY(labelY) end
	if ui.balanceCoinTex then ui.balanceCoinTex:setX(balanceX); ui.balanceCoinTex:setY(row1Y + coinDy) end
	if ui.balanceCoinLabel then ui.balanceCoinLabel:setX(balanceX + 20); ui.balanceCoinLabel:setY(row1Y + textDy) end
	if ui.balanceSpecialCoinTex then ui.balanceSpecialCoinTex:setX(balanceX); ui.balanceSpecialCoinTex:setY(row2Y + coinDy) end
	if ui.balanceSpecialCoinLabel then ui.balanceSpecialCoinLabel:setX(balanceX + 20); ui.balanceSpecialCoinLabel:setY(row2Y + textDy) end

	if ui.totalLabel then ui.totalLabel:setX(totalColX); ui.totalLabel:setY(labelY) end
	if ui.coinTex then ui.coinTex:setX(totalColX); ui.coinTex:setY(row1Y + coinDy) end
	if ui.totalCoinLabel then ui.totalCoinLabel:setX(totalColX + 20); ui.totalCoinLabel:setY(row1Y + textDy) end
	if ui.specialCoinTex then ui.specialCoinTex:setX(totalColX); ui.specialCoinTex:setY(row2Y + coinDy) end
	if ui.totalSpecialCoinLabel then ui.totalSpecialCoinLabel:setX(totalColX + 20); ui.totalSpecialCoinLabel:setY(row2Y + textDy) end

	if ui.clearCartButton then ui.clearCartButton:setX(innerX); ui.clearCartButton:setY(btnY); ui.clearCartButton:setWidth(btnW) end
	if ui.buyCartButton then ui.buyCartButton:setX(payColX); ui.buyCartButton:setY(btnY); ui.buyCartButton:setWidth(btnW) end
	if ui.sellCartButton then ui.sellCartButton:setX(payColX); ui.sellCartButton:setY(btnY); ui.sellCartButton:setWidth(btnW) end
	if ui.cancelBuyButton then ui.cancelBuyButton:setX(payColX); ui.cancelBuyButton:setY(btnY); ui.cancelBuyButton:setWidth(btnW) end
	if ui.viewModeLabel then ui.viewModeLabel:setX(innerX); ui.viewModeLabel:setY(btnY) end

	local rowLayout = ShopUIMode.getCartRowLayout(innerW)
	ui.cartRemoveButtonX = rowLayout.removeX
	ui.cartPreviewButtonX = rowLayout.previewX
	ui.cartPriceX = rowLayout.coinX
	ui.cartPriceTextX = rowLayout.textX
	ui.cartItems.rowLayout = rowLayout
end

local MODE_ACTIVE = { r = 0.25, g = 0.55, b = 0.3, a = 0.95 }
local MODE_INACTIVE = { r = 0.18, g = 0.18, b = 0.18, a = 0.9 }
local SIDEBAR_BG = { r = 0.1, g = 0.1, b = 0.1, a = 0.92 }
local CART_BG = { r = 0.08, g = 0.08, b = 0.08, a = 0.85 }

function ShopUIMode.isLayoutReady(ui)
	return ui and ui.contentPanel and ui.cartItems and ui.totalCoinLabel and ui.totalSpecialCoinLabel
end

function ShopUIMode.getActiveTab(ui)
	if not ui then return nil end
	if ShopUIMode.isSellMode(ui) then return ui.sellTab end
	return ui.buyTab
end

function ShopUIMode.showActiveTab(ui)
	if not ui.contentPanel then return end
	if ui.buyTab then ui.buyTab:setVisible(false) end
	if ui.sellTab then ui.sellTab:setVisible(false) end
	local tab = ShopUIMode.getActiveTab(ui)
	if not tab then return end
	if tab:getParent() ~= ui.contentPanel then
		ui.contentPanel:addChild(tab)
	end
	tab:setX(0)
	tab:setY(0)
	tab:setWidth(ui.contentPanel:getWidth())
	tab:setHeight(ui.contentPanel:getHeight())
	tab:setVisible(true)
	if tab.relayout then tab:relayout() end
end

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

function ShopUIMode.getGeometry(ui)
	local th = ui:titleBarHeight()
	local pad = ShopUIMode.PAD
	local contentY = th + pad
	local contentH = ui.height - contentY - pad
	local contentX = ShopUIMode.SIDEBAR_W + pad * 2
	local contentW = ui.width - ShopUIMode.SIDEBAR_W - ShopUIMode.CART_W - pad * 4
	local cartX = ui.width - ShopUIMode.CART_W - pad
	return {
		contentX = contentX,
		contentY = contentY,
		contentW = contentW,
		contentH = contentH,
		cartX = cartX,
		cartY = contentY,
		cartW = ShopUIMode.CART_W,
		cartH = contentH,
		sidebarY = contentY,
		sidebarH = contentH,
	}
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

ShopUIMode.LIST_SCROLL_PAD = 18

function ShopUIMode.getCartRowLayout(listW)
	local w = listW or 200
	local pad = ShopUIMode.LIST_SCROLL_PAD
	return {
		removeX = w - pad - 22,
		previewX = w - pad - 46,
		coinX = w - pad - 92,
		textX = w - pad - 72,
		nameMaxChars = math.max(6, math.floor((w - pad - 100) / 7)),
	}
end

function ShopUIMode.getShopRowLayout(listW, hasPreview)
	local w = listW or 200
	local pad = ShopUIMode.LIST_SCROLL_PAD
	local addX = w - pad - 22
	local previewX = addX - 24
	local favX = hasPreview and (previewX - 22) or (addX - 24)
	return {
		addX = addX,
		previewX = previewX,
		favX = favX,
		coinX = favX - 62,
		textX = favX - 44,
		scrollPad = pad,
	}
end

function ShopUIMode.getCategoryIcon(tabType)
	if not tabType then return nil end
	if ShopUIMode._categoryIconCache == nil then
		ShopUIMode._categoryIconCache = {}
	end
	if ShopUIMode._categoryIconCache[tabType] then
		return ShopUIMode._categoryIconCache[tabType]
	end
	local itemType = Shop.CategoryIconItems and Shop.CategoryIconItems[tabType]
	if not itemType then return nil end
	local ok, item = pcall(InventoryItemFactory.CreateItem, itemType)
	if ok and item then
		local tex = item:getTex()
		ShopUIMode._categoryIconCache[tabType] = tex
		return tex
	end
	return nil
end

function ShopUIMode.createTab(ui, tabType)
	local w = ui._contentW or 400
	local h = ui._contentH or 400
	local tab = ShopTabUI:new(0, 0, w, h)
	tab:initialise()
	tab:setAnchorRight(false)
	tab:setAnchorBottom(false)
	tab:setShopUI(ui)
	tab:setCategoryType(tabType)
	tab:relayout()
	return tab
end

function ShopUIMode.updateCategoryButtons(ui)
	if not ui.categoryButtons then return end
	for tabType, btn in pairs(ui.categoryButtons) do
		local active = not ShopUIMode.isSellMode(ui) and ui.activeBuyTabType == tabType
		btn.backgroundColor = active and MODE_ACTIVE or MODE_INACTIVE
	end
	if ui.sellCategoryBtn then
		local sellActive = ShopUIMode.isSellMode(ui)
		ui.sellCategoryBtn.backgroundColor = sellActive and MODE_ACTIVE or MODE_INACTIVE
		ui.sellCategoryBtn:setVisible(Shop.hasSellCatalog())
	end
	if ui.categorySellSep then
		ui.categorySellSep:setVisible(Shop.hasSellCatalog())
	end
end

function ShopUIMode.selectBuyCategory(ui, tabType)
	if not ui or not tabType then return end
	local wasSell = ShopUIMode.isSellMode(ui)
	ui.shopMode = "buy"
	ui.activeBuyTabType = tabType
	if ui.buyTab then
		ui.buyTab:setCategoryType(tabType)
	end
	if wasSell then
		ui.cartItems:clear()
		ui.shopItemsCache = {}
		ShopUIMode.rebuildTabs(ui)
	else
		ui.reloadItems = (ui.shopItemsCache[tabType] == nil)
		ShopUIMode.layoutContent(ui)
		ShopUIMode.showActiveTab(ui)
		local tab = ShopUIMode.getActiveTab(ui)
		if tab and tab.relayout then tab:relayout() end
		ui:onActivateView()
	end
	ShopUIMode.updateCategoryButtons(ui)
end

function ShopUIMode.createCategorySidebar(ui, geom)
	ui.categorySidebar = ISPanel:new(ShopUIMode.PAD, geom.sidebarY, ShopUIMode.SIDEBAR_W, geom.sidebarH)
	ui.categorySidebar:initialise()
	ui.categorySidebar.backgroundColor = SIDEBAR_BG
	ui.categorySidebar.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.5 }
	ui:addChild(ui.categorySidebar)

	ui.categoryButtons = {}
	local btnY = 6
	local btnW = ShopUIMode.SIDEBAR_W - 12
	for i = 1, #Shop.TabsBuyOrder do
		local tabType = Shop.TabsBuyOrder[i]
		local label = Shop.TabsBuy[tabType]
		local btn = ShopCategoryButton:new(6, btnY, btnW, ShopUIMode.CAT_BTN_H, label, ShopUIMode.getCategoryIcon(tabType), ui, function(target, button)
			ShopUIMode.selectBuyCategory(target, button.shopTabType)
		end)
		btn:initialise()
		btn.shopTabType = tabType
		btn.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.6 }
		btn.backgroundColor = MODE_INACTIVE
		ui.categorySidebar:addChild(btn)
		ui.categoryButtons[tabType] = btn
		btnY = btnY + ShopUIMode.CAT_BTN_H + ShopUIMode.CAT_BTN_GAP
	end

	btnY = btnY + 6
	ui.categorySellSep = ISPanel:new(8, btnY, btnW, 1)
	ui.categorySellSep:initialise()
	ui.categorySellSep.backgroundColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.8 }
	ui.categorySidebar:addChild(ui.categorySellSep)
	btnY = btnY + 8

	ui.sellCategoryBtn = ShopCategoryButton:new(6, btnY, btnW, ShopUIMode.CAT_BTN_H, getText("IGUI_Tab_Sell"), ShopUIMode.getCategoryIcon(Tab.Sell), ui, function(target)
		ShopUIMode.setShopMode(target, "sell")
	end)
	ui.sellCategoryBtn:initialise()
	ui.sellCategoryBtn.borderColor = { r = 0.45, g = 0.35, b = 0.2, a = 0.8 }
	ui.sellCategoryBtn.backgroundColor = MODE_INACTIVE
	ui.categorySidebar:addChild(ui.sellCategoryBtn)

	ui.activeBuyTabType = ui.activeBuyTabType or Tab.All
	ShopUIMode.updateCategoryButtons(ui)
end

function ShopUIMode.layoutContent(ui)
	if not ui.contentPanel then return end
	local geom = ShopUIMode.getGeometry(ui)
	ui._contentW = geom.contentW
	ui._contentH = geom.contentH

	ui.contentPanel:setX(geom.contentX)
	ui.contentPanel:setY(geom.contentY)
	ui.contentPanel:setWidth(geom.contentW)
	ui.contentPanel:setHeight(geom.contentH)

	if ui.categorySidebar then
		ui.categorySidebar:setY(geom.sidebarY)
		ui.categorySidebar:setHeight(geom.sidebarH)
	end

	ShopUIMode.showActiveTab(ui)
	ShopUIMode.layoutCart(ui, geom)
end

function ShopUIMode.layoutCart(ui, geom)
	ShopUIMode.pinCartFooter(ui)
end

function ShopUIMode.createCartColumn(ui, geom)
	local cx, cy, cw, ch = geom.cartX, geom.cartY, geom.cartW, geom.cartH
	local innerX = cx + 6
	local innerW = cw - 12

	ui.cartPanel = ISPanel:new(cx, cy, cw, ch)
	ui.cartPanel:initialise()
	ui.cartPanel.backgroundColor = CART_BG
	ui.cartPanel.borderColor = { r = 0.35, g = 0.35, b = 0.35, a = 0.5 }
	ui:addChild(ui.cartPanel)

	local labelH = ui.SMALL_FONT_HGT or 14
	local balanceX = innerX + 4

	ui.balanceLabel = ISLabel:new(balanceX, cy + 4, labelH, UIText.Balance, 0.85, 0.85, 0.85, 1, UIFont.Small, true)
	ui:addChild(ui.balanceLabel)

	local coinImg = Currency.CoinsTexture.Coin
	ui.balanceCoinTex = ISImage:new(balanceX, cy + 22 + ShopUIMode.COIN_ICON_DY, 0, 0, coinImg.texture)
	ui.balanceCoinTex.scaledWidth = coinImg.scale + 3
	ui.balanceCoinTex.scaledHeight = coinImg.scale + 3
	ui:addChild(ui.balanceCoinTex)

	ui.balanceCoinLabel = ISLabel:new(balanceX + 20, cy + 22, labelH, "0", 1, 1, 1, 1, UIFont.Small, true)
	ui:addChild(ui.balanceCoinLabel)

	coinImg = Currency.CoinsTexture.SpecialCoin
	ui.balanceSpecialCoinTex = ISImage:new(balanceX, cy + 40 + ShopUIMode.COIN_ICON_DY, 0, 0, coinImg.texture)
	ui.balanceSpecialCoinTex.scaledWidth = coinImg.scale + 3
	ui.balanceSpecialCoinTex.scaledHeight = coinImg.scale + 3
	ui:addChild(ui.balanceSpecialCoinTex)

	ui.balanceSpecialCoinLabel = ISLabel:new(balanceX + 20, cy + 40, labelH, "0", 1, 1, 1, 1, UIFont.Small, true)
	ui:addChild(ui.balanceSpecialCoinLabel)

	ui.cartItems = ISScrollingListBox:new(innerX, cy + 4 + ShopUIMode.CART_HEADER_H, innerW, ch - 4 - ShopUIMode.CART_FOOTER_H - ShopUIMode.CART_HEADER_H)
	ui.cartItems:initialise()
	ui.cartItems:instantiate()
	ui.cartItems.font = UIFont.NewSmall
	ui.cartItems.itemheight = 2 + ui.MEDIUM_FONT_HGT + 4
	ui.cartItems.selected = 1
	ui.cartItems.joypadParent = ui
	ui.cartItems.drawBorder = true
	ui.cartItems.SMALL_FONT_HGT = ui.SMALL_FONT_HGT
	ui.cartItems.MEDIUM_FONT_HGT = ui.MEDIUM_FONT_HGT
	ui.cartItems.doDrawItem = ui.doDrawCartItem
	ui.cartItems.onMouseMove = ui.onMouseMoveCartItem
	ui.cartItems.onMouseDown = ui.onMouseDownCartItem
	ui:addChild(ui.cartItems)

	local totalY = cy + ch - 86
	ui.totalLabel = ISLabel:new(innerX, totalY, labelH, UIText.Total, 0.85, 0.85, 0.85, 1, UIFont.Small, true)
	ui:addChild(ui.totalLabel)

	coinImg = Currency.CoinsTexture.Coin
	ui.coinTex = ISImage:new(innerX + 4, totalY + 18 + ShopUIMode.COIN_ICON_DY, 0, 0, coinImg.texture)
	ui.coinTex.scaledWidth = coinImg.scale + 3
	ui.coinTex.scaledHeight = coinImg.scale + 3
	ui:addChild(ui.coinTex)

	ui.totalCoinLabel = ISLabel:new(innerX + 24, totalY + 18, labelH, "0", 1, 1, 1, 1, UIFont.Small, true)
	ui:addChild(ui.totalCoinLabel)

	coinImg = Currency.CoinsTexture.SpecialCoin
	ui.specialCoinTex = ISImage:new(innerX + 4, totalY + 36 + ShopUIMode.COIN_ICON_DY, 0, 0, coinImg.texture)
	ui.specialCoinTex.scaledWidth = coinImg.scale + 3
	ui.specialCoinTex.scaledHeight = coinImg.scale + 3
	ui:addChild(ui.specialCoinTex)

	ui.totalSpecialCoinLabel = ISLabel:new(innerX + 24, totalY + 36, labelH, "0", 1, 1, 1, 1, UIFont.Small, true)
	ui:addChild(ui.totalSpecialCoinLabel)

	local btnY = cy + ch - 32
	local btnW = (innerW - 6) / 2
	ui.clearCartButton = ISButton:new(innerX, btnY, btnW, 28, UIText.ClearCart, ui, function(o) o:clearCartBtn() end)
	ui.clearCartButton:initialise()
	ui:addChild(ui.clearCartButton)

	if not ui.viewMode then
		ui.buyCartButton = ISButton:new(innerX + btnW + 6, btnY, btnW, 28, UIText.BuyCart, ui, function(o) o:buyCartBtn() end)
		ui.buyCartButton:initialise()
		ui.buyCartButton.enable = false
		ui:addChild(ui.buyCartButton)

		ui.sellCartButton = ISButton:new(innerX + btnW + 6, btnY, btnW, 28, UIText.Sell, ui, function(o) o:sellCartBtn() end)
		ui.sellCartButton:initialise()
		ui.sellCartButton.enable = false
		ui.sellCartButton:setVisible(false)
		ui:addChild(ui.sellCartButton)

		ui.cancelBuyButton = ISButton:new(innerX + btnW + 6, btnY, btnW, 28, UIText.Cancel, ui, function(o) o:cancelBuyBtn() end)
		ui.cancelBuyButton:initialise()
		ui.cancelBuyButton.enable = false
		ui.cancelBuyButton:setVisible(false)
		ui:addChild(ui.cancelBuyButton)
	else
		ui.viewModeLabel = ISLabel:new(innerX, btnY, ui.SMALL_FONT_HGT, UIText.ShopViewOnly, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
		ui:addChild(ui.viewModeLabel)
	end

	if not Currency.UseSpecialCoin then
		ui.balanceSpecialCoinTex:setVisible(false)
		ui.balanceSpecialCoinLabel:setVisible(false)
		ui.specialCoinTex:setVisible(false)
		ui.totalSpecialCoinLabel:setVisible(false)
	end

	local cartImg = Shop.textures.Cart
	ui.cartHeaderTex = ISImage:new(innerX, cy + 4, 0, 0, cartImg.texture)
	ui.cartHeaderTex.scaledWidth = cartImg.scale
	ui.cartHeaderTex.scaledHeight = cartImg.scale
	ui:addChild(ui.cartHeaderTex)

	ShopUIMode.pinCartFooter(ui)
end

function ShopUIMode.setupShopLayout(ui)
	local geom = ShopUIMode.getGeometry(ui)
	ui.shopMode = ui.shopMode or "buy"
	ui.activeBuyTabType = ui.activeBuyTabType or Tab.All
	ui._contentW = geom.contentW
	ui._contentH = geom.contentH

	ShopUIMode.createCategorySidebar(ui, geom)

	ui.contentPanel = ISPanel:new(geom.contentX, geom.contentY, geom.contentW, geom.contentH)
	ui.contentPanel:initialise()
	ui.contentPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	ui.contentPanel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	ui:addChild(ui.contentPanel)

	ShopUIMode.createCartColumn(ui, geom)
	ShopUIMode.rebuildTabs(ui)
end

function ShopUIMode.rebuildTabs(ui)
	if not ui.contentPanel then return end
	if ShopUIMode.isSellMode(ui) then
		if not ui.sellTab then
			ui.sellTab = ShopUIMode.createTab(ui, Tab.Sell)
		end
	else
		ui.activeBuyTabType = ui.activeBuyTabType or Tab.All
		if not ui.buyTab then
			ui.buyTab = ShopUIMode.createTab(ui, ui.activeBuyTabType)
		else
			ui.buyTab:setCategoryType(ui.activeBuyTabType)
		end
	end
	ShopUIMode.showActiveTab(ui)
	ShopUIMode.layoutContent(ui)
	ShopUIMode.updateCategoryButtons(ui)
	ui:onActivateView()
end

function ShopUIMode.updateModeButtons(ui)
	ShopUIMode.updateCategoryButtons(ui)
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
	if mode == "buy" then
		ui.activeBuyTabType = ui.activeBuyTabType or Tab.All
	end
	ShopUIMode.rebuildTabs(ui)
end
