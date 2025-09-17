PlayerShopTabUI = ISPanelJoypad:derive("PlayerShopTabUI");
PlayerShopTabUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
PlayerShopTabUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
PlayerShopTabUI.addButtonX = 380
PlayerShopTabUI.previewButtonX = PlayerShopTabUI.addButtonX + 25

local addBtn = Shop.textures.AddButton;
local previewBtn = Shop.textures.PreviewButton;
local browseBtn = Shop.textures.Browse;

function PlayerShopTabUI:initialise()
    ISPanelJoypad.initialise(self);
    self:create();
end

function PlayerShopTabUI:setShopUI(instance)
    self.ShopUI = instance
end

function PlayerShopTabUI:onFilterChange()
    self.parent:filter()
end

function PlayerShopTabUI:setCategoryType(tabType)
    self.tabType = tabType
end

function PlayerShopTabUI:doDrawShopItem(y, item, alt)
    local baseItemDY = 0
    if item.item.name then
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
    
    local nameToDraw = item.item.name
    if item.item.count and item.item.count > 1 then
        nameToDraw = item.item.name .. "  x" .. tostring(item.item.count)
    end
    self:drawText(nameToDraw, 40, y + 10, 1, 1, 1, a, UIFont.Small);
    if item.item.price then
        local coinImg = Currency.CoinsTexture.Coin
        if item.item.specialCoin then coinImg = Currency.CoinsTexture.SpecialCoin end
        self:drawTextureScaledAspect(coinImg.texture, 300, y + 10, coinImg.scale, coinImg.scale, 1, 1, 1, 1)
        self:drawText(""..item.item.price, 320, y + 8, 1, 1, 1, a, UIFont.Small);
    end

    if item.item.invItem then
        self:drawTextureScaledAspect(item.item.invItem:getTex(), 6, y+5, 30, 30, 1, 1, 1, 1)
        if item.item.invItem:IsInventoryContainer() then
            self:drawTextureScaledAspect(browseBtn.texture, self.parent.previewButtonX, y + 10, previewBtn.scale, previewBtn.scale, 1, 1, 1, 1)
        end
    end

    -- show + only if player has required item when on BuyOrders tab
    local canAdd = true
    if self.parent and self.parent.tabType == Tab.BuyOrders then
        canAdd = false
        local remainingOrder = item.item.count or 0
        if remainingOrder > 0 then
            local inv = self.parent and self.parent.ShopUI and self.parent.ShopUI.player and self.parent.ShopUI.player:getInventory()
            local have = 0
            if inv then
                local list = inv:getAllTypeRecurse(item.item.type)
                if list then have = list:size() end
            end
            local planned = 0
            local cart = self.parent and self.parent.ShopUI and self.parent.ShopUI.cartItems and self.parent.ShopUI.cartItems.items or {}
            for _,ci in ipairs(cart) do
                local it = ci.item
                if it and it.orderKey == (item.item.orderKey or item.text) then
                    planned = planned + (it.units or 1)
                end
            end
            if have > planned then canAdd = true end
        end
    end
    if canAdd then
        self:drawTextureScaledAspect(addBtn.texture, self.parent.addButtonX, y + 10, addBtn.scale, addBtn.scale, 1, 1, 1, 1)
    end

    if item.item.VehicleID then
        self:drawTextureScaledAspect(previewBtn.texture, self.parent.previewButtonX, y + 10, previewBtn.scale, previewBtn.scale, 1, 1, 1, 1)
    end

    return y + item.height;
end

function PlayerShopTabUI:onMouseDownShopItem(x, y)
    ISScrollingListBox.onMouseDown(self,x, y)
    if PreviewUI.instance then PreviewUI.instance:close() end
    if ContainerViewerUI.instance then ContainerViewerUI.instance:close() end
	if self.selectedRow then
        local selectedRow = self.items[self.selectedRow]
        if not selectedRow then return end
        if self.previewBtn then
            if selectedRow.item.invItem:IsInventoryContainer() then
                ContainerViewerUI:show(selectedRow.item.invItem)
                return
            end
            if not selectedRow.item.VehicleID then return end
            PreviewUI:show(selectedRow.item.name,selectedRow.item.VehicleID)
            return
        end
        if self.addBtn then
            if self.tabType == Tab.BuyOrders then
                self.parent.ShopUI:addOrderToCart(selectedRow)
            else
		        self.parent:addToCart(self.selectedRow)
            end
        end
    end
end

function PlayerShopTabUI:onMouseMoveShopItem(dx, dy)
    local list = self.parent.shopItems
    if not list then return end
    list.selectedRow = nil
    list.previewBtn = nil
    list.addBtn = nil
	if list:isMouseOverScrollBar() or not list:isMouseOver() then self.parent.ShopUI:toggleTooltip(false) return end
	local rowIndex = list:rowAt(list:getMouseX(), list:getMouseY())
    if not rowIndex then self.parent.ShopUI:toggleTooltip(false) return end
    local selectedRow = list.items[rowIndex]
    if not selectedRow then self.parent.ShopUI:toggleTooltip(false) return end
    list.selectedRow = rowIndex
    local mouseX = self:getMouseX()
    if mouseX > self.parent.addButtonX then
        local canAdd = true
        if self.parent and self.parent.tabType == Tab.BuyOrders then
            canAdd = false
            local inv = self.parent and self.parent.ShopUI and self.parent.ShopUI.player and self.parent.ShopUI.player:getInventory()
            if inv and selectedRow and selectedRow.item and selectedRow.item.type then
                local have = 0
                local list = inv:getAllTypeRecurse(selectedRow.item.type)
                if list then have = list:size() end
                local planned = 0
                for _,ci in ipairs(self.parent.ShopUI.cartItems.items) do
                    local it = ci.item
                    if it and it.orderKey == (selectedRow.item.orderKey or selectedRow.text) then
                        planned = planned + (it.units or 1)
                    end
                end
                local remainingOrder = selectedRow.item.count or 0
                if have > planned and remainingOrder > 0 then canAdd = true end
            end
        end
        list.addBtn = canAdd
    else
        list.addBtn = false
    end
    if mouseX > self.parent.previewButtonX then
        list.previewBtn = true
    end
    if not selectedRow.item then self.parent.ShopUI:toggleTooltip(false) return end
    self.parent.ShopUI:toggleTooltip(true,selectedRow.item)
end

function PlayerShopTabUI:prerender()
    self.shopItems.doDrawItem = PlayerShopTabUI.doDrawShopItem;
    self.shopItems.onMouseMove = PlayerShopTabUI.onMouseMoveShopItem;
    self.shopItems.onMouseDown = PlayerShopTabUI.onMouseDownShopItem;
end

function PlayerShopTabUI:addToCart(selectedRow)
    local row = self.shopItems.items[selectedRow]
    if self.ShopUI.actionInProgress then return end
    self.ShopUI:toggleTooltip(false)
    if row and row.item and row.item.count and row.item.count > 1 then
        -- ensure stack exists; if lost, rebuild from container by criteria
        if (not row.item.stack) or (#row.item.stack or 0) == 0 then
            local rebuilt = {}
            local cont = self.ShopUI.shop and self.ShopUI.shop:getContainer()
            if cont then
                local items = cont:getItems()
                for i=0, items:size()-1 do
                    local it = items:get(i)
                    local md = it:getModData()
                    if it:getFullType() == row.item.type and md and md.price == row.item.price and md.specialCoin == row.item.specialCoin then
                        table.insert(rebuilt, it)
                    end
                end
            end
            if #rebuilt > 0 then
                row.item.stack = rebuilt
                row.item.count = #rebuilt
                row.item.invItem = rebuilt[#rebuilt]
            end
        end
        local v = {}
        for k,val in pairs(row.item) do v[k] = val end
        v.count = nil
        v.stack = nil
        if row.item.stack and #row.item.stack > 0 then
            v.invItem = table.remove(row.item.stack)
        else
            v.invItem = row.item.invItem
        end
        self.ShopUI.cartItems:addItem(row.text, v)
        row.item.count = math.max(0, (row.item.count or 1) - 1)
        if row.item.stack and #row.item.stack > 0 then
            row.item.invItem = row.item.stack[#row.item.stack]
        end
        if row.item.count <= 1 then
            row.item.count = nil
        end
    else
        self.ShopUI.cartItems:addItem(row.text,row.item)
        self.shopItems:removeItemByIndex(selectedRow)
    end
    self.ShopUI.cartItems:setYScroll(-10000)
end

function PlayerShopTabUI:filter()
    local filterText = string.trim(self.filterEntry:getInternalText())
    local tabType = self.tabType
    self.shopItems.items = self.ShopUI.shopItemsCache[tabType]
    filterText = string.lower(filterText)
    local shopItems = self.shopItems.items
    self.shopItems:clear()
    for k,v in ipairs(shopItems) do
        if string.contains(string.lower(v.item.name), filterText) then
            self.shopItems:addItem(v.text,v.item);
        end
    end
end

function PlayerShopTabUI:create()
    local x = 30
    local y = 50

    self.filterLabel = ISLabel:new(x, y-20, 1,UIText.Search,1,1,1,1,UIFont.Small, true);
    self:addChild(self.filterLabel);

    local width = ((self.width/3) - getTextManager():MeasureStringX(UIFont.Small, UIText.Search)) - 98;
    self.filterEntry = ISTextEntryBox:new("", getTextManager():MeasureStringX(UIFont.Small,UIText.Search) + 40, y-28, width, 1);
    self.filterEntry:initialise();
    self.filterEntry:instantiate();
    self.filterEntry:setText("");
    self.filterEntry:setClearButton(true);
    self.filterEntry.onTextChange = PlayerShopTabUI.onFilterChange
    self:addChild(self.filterEntry);
    self.lastText = self.filterEntry:getInternalText();

    self.sortPriceButton = ISButton:new((self.width / 2)-160, y-30, 25,25,"",self, PlayerShopTabUI.sortPriceBtn);
    self.sortPriceButton.borderColor.a = 0.0;
    self.sortPriceButton.backgroundColor.a = 0;
    self.sortPriceButton.backgroundColorMouseOver.a = 0;
    self.sortPriceButton:setImage(Shop.textures.Sort.texture)
    self.sortPriceButton:initialise()
    self.sortPriceButton.enable = true
    self:addChild(self.sortPriceButton);
    
    self.shopItems = ISScrollingListBox:new(x, y, (self.width / 3) + 110, self.height - 100);
    self.shopItems:initialise();
    self.shopItems:instantiate();
    self.shopItems.font = UIFont.NewSmall;
    self.shopItems.itemheight = 2 + self.MEDIUM_FONT_HGT  + 4;
    self.shopItems.selected = 0;
    self.shopItems.joypadParent = self;
    self.shopItems.drawBorder = false;
    self.shopItems.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.shopItems.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    self:addChild(self.shopItems);
end

local sortToggle = true
function PlayerShopTabUI:sortPriceBtn()
    local items = self.shopItems.items
    table.sort(items, function(v1,v2) if sortToggle then return v1.item.price<v2.item.price end return v1.item.price>v2.item.price end)
    self.shopItems.items = items
    sortToggle = not sortToggle
end

function PlayerShopTabUI:new (x, y, width, height)
    local o = {};
    o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o:noBackground();
    self.parent = o;
    return o;
end