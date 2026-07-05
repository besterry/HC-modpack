ShopTabUI = ISPanelJoypad:derive("ShopTabUI");
require "ISUI/ShopUIMode"
require "ISUI/ShopSellSourceBar"
ShopTabUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
ShopTabUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
ShopTabUI.addButtonX = 380
ShopTabUI.previewButtonX = ShopTabUI.addButtonX + 25
ShopTabUI.favoriteButtonX = ShopTabUI.addButtonX - 20

local addBtn = Shop.textures.AddButton;
local previewBtn = Shop.textures.PreviewButton;

function ShopTabUI:initialise()
    ISPanelJoypad.initialise(self);
    self:create();
end

function ShopTabUI:setShopUI(instance)
    self.ShopUI = instance
end

function ShopTabUI:setShopAdminEditUI(instance)
    self.ShopUI = instance
end

function ShopTabUI:isSellTab()
    return self.ShopUI and ShopUIMode.isSellMode(self.ShopUI)
end

function ShopTabUI:onFilterChange()
    self.parent:filter()
end

function ShopTabUI:getPanelW()
    local parent = self:getParent()
    if parent and parent:getWidth() > 100 then
        return parent:getWidth()
    end
    if self.ShopUI and self.ShopUI._contentW and self.ShopUI._contentW > 0 then
        return self.ShopUI._contentW
    end
    return self:getWidth()
end

function ShopTabUI:getPanelH()
    local parent = self:getParent()
    if parent and parent:getHeight() > 100 then
        return parent:getHeight()
    end
    if self.ShopUI and self.ShopUI._contentH and self.ShopUI._contentH > 0 then
        return self.ShopUI._contentH
    end
    return self:getHeight()
end

function ShopTabUI:getListW()
    return math.max(80, self:getWidth() - 16)
end

function ShopTabUI:buildShopList(pad, top, listW, listH)
    local old = self.shopItems
    local items = old and old.items or {}
    local selected = old and old.selected or 0
    local yscroll = old and old:getYScroll() or 0

    if old then
        self:removeChild(old)
    end

    local list = ISScrollingListBox:new(pad, top, listW, listH)
    list:initialise()
    list:instantiate()
    list.font = UIFont.Small
    list.itemheight = 2 + self.MEDIUM_FONT_HGT + 4
    list.selected = selected
    list.joypadParent = self
    list.drawBorder = false
    list.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    list.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    list.shopTab = self
    list.items = items
    list:setYScroll(yscroll)
    list:setAnchorLeft(true)
    list:setAnchorRight(true)
    list:setAnchorBottom(true)
    list.doDrawItem = ShopTabUI.doDrawShopItem
    list.onMouseMove = ShopTabUI.onMouseMoveShopItem
    list.onMouseDown = ShopTabUI.onMouseDownShopItem
    self.shopItems = list
    self:addChild(list)
end

function ShopTabUI:ensureShopListSize(listW, listH, pad, top)
    if not self.shopItems then
        self:buildShopList(pad, top, listW, listH)
        return
    end
    local wDiff = math.abs(self.shopItems:getWidth() - listW)
    local hDiff = math.abs(self.shopItems:getHeight() - listH)
    if wDiff > 2 or hDiff > 2 then
        self:buildShopList(pad, top, listW, listH)
        return
    end
    self.shopItems:setX(pad)
    self.shopItems:setY(top)
    self.shopItems.shopTab = self
end

function ShopTabUI:syncPanelSize()
    local w = self:getPanelW()
    local h = self:getPanelH()
    if self:getWidth() ~= w then self:setWidth(w) end
    if self:getHeight() ~= h then self:setHeight(h) end
end

function ShopTabUI:setCategoryType(tabType)
    self.tabType = tabType
end

function ShopTabUI:doDrawShopItem(y, item, alt)
    local list = self
    local tab = list.shopTab
    local listW = list:getWidth()
    local hasPreview = item.item.VehicleID ~= nil
    local lay = ShopUIMode.getShopRowLayout(listW, hasPreview)
    local baseItemDY = 0
    if item.item.name then
        baseItemDY = self.SMALL_FONT_HGT
        item.height = self.itemheight + baseItemDY
    end

    if y + self:getYScroll() >= self.height then return y + item.height end
    if y + item.height + self:getYScroll() <= 0 then return y + item.height end

    local a = 0.9;
    self:drawRectBorder(0, (y), listW, item.height - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), listW, item.height - 1, 0.3, 0.7, 0.35, 0.15);
    end
    
    if tab and not tab:isSellTab() then
        local alpha = 0.3
        local favTexture = nil
        if item.index == self.selectedRow and not self:isMouseOverScrollBar() and self:isMouseOver() then
            local mouseX = self:getMouseX()
            local favRight = hasPreview and lay.previewX or lay.addX
            favTexture = tab.favNotCheckedTex
            if mouseX >= lay.favX and mouseX < favRight then
                favTexture = tab.favCheckedTex
                alpha = 1
            end
        end
        if item.item.favorite then
            favTexture = tab.favoriteStar
            alpha = 1 
        end
        if favTexture then
            self:drawTexture(favTexture, lay.favX, y + 10, alpha, 1, 1, 1);
        end
    end

    local quantity = ""
    if item.item.quantity then
        quantity = " ("..item.item.quantity..")"
    end
    self:drawText(item.item.name..quantity, 40, y + 10, 1, 1, 1, a, UIFont.Small);
    if item.item.price then
        local coinImg = Currency.CoinsTexture.Coin
        if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
        self:drawTextureScaledAspect(coinImg.texture, lay.coinX, y + 10, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
        self:drawText(""..item.item.price, lay.textX, y + 8, 1, 1, 1, a, UIFont.Small);
    end

    if item.item.invItem or item.item.texture then
        local texture = item.item.texture
        if not texture then
            texture = item.item.invItem:getTex()
        end
        self:drawTextureScaledAspect(texture, 6, y+5, 30, 30, 1, 1, 1, 1)
    end

    self:drawTextureScaledAspect(addBtn.texture, lay.addX, y + 10, addBtn.scale, addBtn.scale, 1, 1, 1, 1)

    if hasPreview then
        self:drawTextureScaledAspect(previewBtn.texture, lay.previewX, y + 10, previewBtn.scale, previewBtn.scale, 1, 1, 1, 1)
    end

    return y + item.height;
end

function ShopTabUI:onMouseDownShopItem(x, y)
    ISScrollingListBox.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
    local tab = self.shopTab
    if not tab then return end
	if self.selectedRow then
        local selectedRow = self.items[self.selectedRow]
        if not selectedRow then return end
        if self.previewBtn then
            if not selectedRow.item.VehicleID then return end
            PreviewUI:show(selectedRow.item.name,selectedRow.item.VehicleID)
            return
        end
        if self.favoriteBtn then
            if not tab:isSellTab() then
                tab:manageFavorites(self.selectedRow)
            end
            return
        end
        if self.addBtn then
		    tab:addToCart(self.selectedRow)
        end
    end
end

function ShopTabUI:manageFavorites(selectedRow)
    local item = self.shopItems.items[selectedRow].item
    local shopFavorites = self.ShopUI.player:getModData().shopFavorites
    local check = not item.favorite
    if check then
        local data = copyTable(item)
        data.name = nil
        data.invItem = nil
        if item.items then
            data.items = item.items
        end
        shopFavorites[item.type] = data
    else
        shopFavorites[item.type] = nil
    end
    item.favorite = check
    self.ShopUI.shopItemsCache[self.tabType] = nil
    self.ShopUI.reloadItems = true
    self.ShopUI:onActivateView()
end

function ShopTabUI:onMouseMoveShopItem(dx, dy)
    local list = self
    local tab = list.shopTab
    if not tab then return end
    list.selectedRow = nil
    list.previewBtn = nil
    list.favoriteBtn = nil
    list.addBtn = nil
	if list:isMouseOverScrollBar() or not list:isMouseOver() then tab.ShopUI:toggleTooltip(false) return end
	local rowIndex = list:rowAt(list:getMouseX(), list:getMouseY())
    if not rowIndex then tab.ShopUI:toggleTooltip(false) return end
    local selectedRow = list.items[rowIndex]
    if not selectedRow then tab.ShopUI:toggleTooltip(false) return end
    list.selectedRow = rowIndex
    local mouseX = self:getMouseX()
    local hasPreview = selectedRow.item.VehicleID ~= nil
    local lay = ShopUIMode.getShopRowLayout(list:getWidth(), hasPreview)
    if mouseX >= lay.addX then
        list.addBtn = true
    elseif hasPreview and mouseX >= lay.previewX and mouseX < lay.addX then
        list.previewBtn = true
    elseif not tab:isSellTab() and mouseX >= lay.favX and mouseX < (hasPreview and lay.previewX or lay.addX) then
        list.favoriteBtn = true
    end
    if not selectedRow.item then tab.ShopUI:toggleTooltip(false) return end
    tab.ShopUI:toggleTooltip(true,selectedRow.item)
end

function ShopTabUI:prerender()
    self:syncPanelSize()
    self:relayout()
    if not self:isSellTab() then
        ShopSellSourceBar.destroy(self)
        self.sellSourceBarH = 0
    end
    if not self.shopItems then return end
    self.shopItems.doDrawItem = ShopTabUI.doDrawShopItem;
    self.shopItems.onMouseMove = ShopTabUI.onMouseMoveShopItem;
    self.shopItems.onMouseDown = ShopTabUI.onMouseDownShopItem;
    local sellMode = self:isSellTab()
    if self.favoritesOnlyTick then
        self.favoritesOnlyTick:setVisible(not sellMode)
    end
    if self.sortPriceButton then
        self.sortPriceButton:setVisible(not sellMode)
    end
end

function ShopTabUI:addToCart(selectedRow)
    local item = self.shopItems.items[selectedRow]
    if self.ShopUI.actionInProgress then return end
    self.ShopUI:toggleTooltip(false)
    self.ShopUI.cartItems:addItem(item.text,item.item);
    if self:isSellTab() then
        self.shopItems:removeItemByIndex(selectedRow)
    end
    self.ShopUI.cartItems:setYScroll(-10000);
end

function ShopTabUI:onFavoritesOnlyToggle()
    self:applyListFilter()
end

function ShopTabUI:applyListFilter()
    local tabType = self.tabType
    local source = self.ShopUI.shopItemsCache[tabType]
    if not source then return end
    local filterText = string.lower(string.trim(self.filterEntry:getInternalText()))
    local favoritesOnly = self.favoritesOnlyTick and self.favoritesOnlyTick:isSelected(1)
    self.shopItems:clear()
    for i = 1, #source do
        local v = source[i]
        if favoritesOnly and not v.item.favorite then
        elseif filterText ~= "" and not string.contains(string.lower(v.item.name), filterText) then
        else
            self.shopItems:addItem(v.text, v.item)
        end
    end
end

function ShopTabUI:filter()
    self:applyListFilter()
end

function ShopTabUI:layoutSellSourceBar()
	if not self:isSellTab() or not self.ShopUI then
		ShopSellSourceBar.destroy(self)
		self.sellSourceBarH = 0
		return 0
	end
	local pad = 8
	local barY = 8
	local barH = ShopSellSourceBar.rebuild(self, self.ShopUI.player, self.ShopUI.sellSourceIndex, function(idx)
		self.ShopUI:onSellSourceSelected(idx)
	end, { x = pad, y = barY, maxW = self:getWidth() - pad * 2 })
	self.sellSourceBarH = barH > 0 and (barH + 6) or 0
	return self.sellSourceBarH
end

function ShopTabUI:relayout()
    self:syncPanelSize()
    local pad = 8
    local sourceBarH = 0
    if self:isSellTab() then
        sourceBarH = self.sellSourceBarH or 0
    end
    local top = 40 + sourceBarH
    local w = self:getWidth()
    local h = self:getHeight()
    if w < 80 then return end
    local listW = math.max(80, w - pad * 2)
    local listH = math.max(80, h - top - pad)

    local sortBtnW = 26
    local favBlockW = 138
    local sortX = w - pad - sortBtnW
    local favX = sortX - favBlockW - 4
    local entryX = pad + getTextManager():MeasureStringX(UIFont.Small, UIText.Search) + 6
    local entryW = math.max(60, favX - entryX - 6)

    if self.filterLabel then self.filterLabel:setX(pad); self.filterLabel:setY(top - 22) end
    if self.filterEntry then
        self.filterEntry:setX(entryX)
        self.filterEntry:setY(top - 28)
        self.filterEntry:setWidth(entryW)
    end
    if self.sortPriceButton then self.sortPriceButton:setX(sortX); self.sortPriceButton:setY(top - 30) end
    if self.favoritesOnlyTick then self.favoritesOnlyTick:setX(favX); self.favoritesOnlyTick:setY(top - 30) end
    if self.moveAllButton then self.moveAllButton:setX(w - pad - 52); self.moveAllButton:setY(top - 30) end

    self:ensureShopListSize(listW, listH, pad, top)
end

function ShopTabUI:create()
    local pad = 8
    local top = 40

    self.filterLabel = ISLabel:new(pad, top - 22, 1, UIText.Search, 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.filterLabel)

    self.filterEntry = ISTextEntryBox:new("", pad + 50, top - 28, 120, 1)
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setText("")
    self.filterEntry:setClearButton(true)
    local tabRef = self
    self.filterEntry.onTextChange = function()
        tabRef:applyListFilter()
    end
    self:addChild(self.filterEntry)
    self.lastText = self.filterEntry:getInternalText()

    self.sortPriceButton = ISButton:new(200, top - 30, 25, 25, "", self, ShopTabUI.sortPriceBtn)
    self.sortPriceButton.borderColor.a = 0.0
    self.sortPriceButton.backgroundColor.a = 0
    self.sortPriceButton.backgroundColorMouseOver.a = 0
    self.sortPriceButton:setImage(Shop.textures.Sort.texture)
    self.sortPriceButton:initialise()
    self.sortPriceButton.enable = true
    self:addChild(self.sortPriceButton)

    self.favoritesOnlyTick = ISTickBox:new(160, top - 30, 120, 20, "", self, ShopTabUI.onFavoritesOnlyToggle)
    self.favoritesOnlyTick:initialise()
    self.favoritesOnlyTick:addOption(getText("IGUI_Shop_FavoritesOnly"), false)
    self:addChild(self.favoritesOnlyTick)

    self.moveAllButton = ISButton:new(230, top - 30, 25, 25, "", self, ShopTabUI.moveAllBtn)
    self.moveAllButton.borderColor.a = 0.0
    self.moveAllButton.backgroundColor.a = 0
    self.moveAllButton.backgroundColorMouseOver.a = 0
    self.moveAllButton:setImage(Shop.textures.MoveAll.texture)
    self.moveAllButton:initialise()
    self.moveAllButton.enable = false
    self.moveAllButton:setVisible(false)
    self:addChild(self.moveAllButton)

    local pw = self._panelW or self:getWidth() or 400
    local ph = self._panelH or self:getHeight() or 400
    self:buildShopList(pad, top, math.max(80, pw - pad * 2), math.max(80, ph - top - pad))
    self:relayout()
end

local sortToggle = true
function ShopTabUI:sortPriceBtn()
    local items = self.shopItems.items
    table.sort(items, function(v1,v2) if sortToggle then return v1.item.price<v2.item.price end return v1.item.price>v2.item.price end)
    self.shopItems.items = items
    sortToggle = not sortToggle
end

function ShopTabUI:moveAllBtn()
    local items = self.shopItems.items
    for k,v in pairs(items) do
        self.ShopUI.cartItems:addItem(v.item.text,v.item);
    end
    self.shopItems:clear()
end

function ShopTabUI:new (x, y, width, height)
    local o = {};
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.favoriteStar = getTexture("media/ui/FavoriteStar.png");
    o.favCheckedTex = getTexture("media/ui/FavoriteStarChecked.png");
    o.favNotCheckedTex = getTexture("media/ui/FavoriteStarUnchecked.png");
    o.favWidth = o.favoriteStar and o.favoriteStar:getWidth() or 13
    o._panelW = width
    o._panelH = height
    o:noBackground();
    return o;
end