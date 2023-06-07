require('ISUI/ISInventoryPage')
require('ISUI/ISInventoryPane')

ISInventoryPane.washList = {}

local TurnOnOff = {
    ClothingDryer = {
        isPowered = function(object)
            return object:getContainer() and object:getContainer():isPowered() or false
        end,
        isActivated = function(object)
            return object:isActivated()
        end
    },
    ClothingWasher = {
        isPowered = function(object)
            if object:getWaterAmount() <= 0 then return false end
            return object:getContainer() and object:getContainer():isPowered() or false
        end,
        isActivated = function(object)
            return object:isActivated()
        end
    }
}

local original_ISInventoryPage_createChildren = ISInventoryPage.createChildren
function ISInventoryPage:createChildren()
    original_ISInventoryPage_createChildren(self)

    if not self.onCharacter then
        local title = getText('IGUI_NFQOL_InventoryButton_LootDrop')
        local width = getTextManager():MeasureStringX(UIFont.Small, title)
        local height = self:titleBarHeight()

        self.dropAllBtn = ISButton:new(self.lootAll:getRight() + 16, 0, width, height, title, self, ISInventoryPage.dropAll)
        self.dropAllBtn:initialise()
        self.dropAllBtn.borderColor.a = 0.0
        self.dropAllBtn.backgroundColor.a = 0.0
        self.dropAllBtn.backgroundColorMouseOver.a = 0.7
        self:addChild(self.dropAllBtn)
        self.dropAllBtn:setVisible(false)

        if getActivatedMods():contains('eggonsHaveIFoundThisBook') then
            title = getText('IGUI_NFQOL_InventoryButton_LootBooks')
            width = getTextManager():MeasureStringX(UIFont.Small, title)

            self.lootBooksBtn = ISButton:new(self.dropAllBtn:getRight() + 16, 0, width, height, title, self, ISInventoryPage.lootBooks)
            self.lootBooksBtn:initialise()
            self.lootBooksBtn.borderColor.a = 0.0
            self.lootBooksBtn.backgroundColor.a = 0.0
            self.lootBooksBtn.backgroundColorMouseOver.a = 0.7
            self:addChild(self.lootBooksBtn)
            self.lootBooksBtn:setVisible(false)
        end

        title = getText('IGUI_NFQOL_InventoryButton_Wash')
        width = getTextManager():MeasureStringX(UIFont.Small, title)

        self.washBtn = ISButton:new(self.toggleStove:getRight() + 16, 0, width, height, title, self, ISInventoryPage.washClothing)
        self.washBtn:initialise()
        self.washBtn.borderColor.a = 0.0
        self.washBtn.backgroundColor.a = 0.0
        self.washBtn.backgroundColorMouseOver.a = 0.7
        self:addChild(self.washBtn)
        self.washBtn:setVisible(false)
    end
end

local original_ISInventoryPage_update = ISInventoryPage.update
function ISInventoryPage:update()
    original_ISInventoryPage_update(self)

    if self.onCharacter then return end

    self:updateDropAllButton()
    self:updateLootBooksButton()
    self:updateWashButton()
end

function ISInventoryPage:updateDropAllButton()
    if self.lootAll:getIsVisible() and self.inventory:getType() ~= "floor" then
        self.dropAllBtn:setVisible(true)
        self.toggleStove:setX(self.dropAllBtn:getRight() + 16)
        self.removeAll:setX(self.dropAllBtn:getRight() + 16)
    else
        self.dropAllBtn:setVisible(false)
        self.toggleStove:setX(self.lootAll:getRight() + 16)
        self.removeAll:setX(self.lootAll:getRight() + 16)
    end
    self.washBtn:setX(self.toggleStove:getRight() + 16)
end

function ISInventoryPage:updateLootBooksButton()
    if not self.lootBooksBtn then return end

    local shouldBeVisible = not (self.toggleStove:getIsVisible() or self.removeAll:getIsVisible() or self.inventory:getType() == "floor")
    if shouldBeVisible then
        local x = self.dropAllBtn:getIsVisible() and self.dropAllBtn:getRight() or self.lootAll:getRight()
        self.lootBooksBtn:setX(x + 16)
    end
    self.lootBooksBtn:setVisible(shouldBeVisible)
end

function ISInventoryPage:updateWashButton()
    local isVisible = self.washBtn:getIsVisible()
    local shouldBeVisible = false

    local object
    local isWasher = true
    if self.inventoryPane.inventory then
        object = self.inventoryPane.inventory:getParent()
        if object then
            local className = object:getObjectName()
            if TurnOnOff[className] and TurnOnOff[className].isPowered(object) and not TurnOnOff[className].isActivated(object) then
                shouldBeVisible = true
                if className == 'ClothingDryer' then
                    isWasher = false
                end
            end
        end
    end
    local containerButton
    for _, cb in ipairs(self.backpacks) do
        if cb.inventory == self.inventoryPane.inventory then
            containerButton = cb
            break
        end
    end
    if not containerButton then
        shouldBeVisible = false
    end
    if isVisible ~= shouldBeVisible then
        self.washBtn:setVisible(shouldBeVisible)
    end
    if shouldBeVisible then
        local title = getText('IGUI_NFQOL_InventoryButton_Wash')
        if #self.inventoryPane.washList > 0 then
            title = getText('IGUI_NFQOL_InventoryButton_Wear')
        else
            if not isWasher then
                title = getText('IGUI_NFQOL_InventoryButton_Dry')
            end
        end
        self.washBtn:setTitle(title)
        self.washBtn:setWidth(getTextManager():MeasureStringX(UIFont.Small, title))
        self.washBtn:setVisible(shouldBeVisible)
    end
end

function ISInventoryPane:dropAll()
    local lootInventory = self.inventory
    local lootInventoryItems = lootInventory:getItems()
    local itemsToDrop = {}
    if luautils.walkToContainer(lootInventory, 0) then
        for i = 0, lootInventoryItems:size() - 1 do
            local item = lootInventoryItems:get(i)
            local ok = true
            if instanceof(item, "Moveable") and item:getSpriteGrid() == nil and not item:CanBeDroppedOnFloor() then
                ok = false
            end
            if ok then
                table.insert(itemsToDrop, item)
            end
        end
        self:transferItemsByWeight(itemsToDrop, ISInventoryPage.GetFloorContainer(self.player))
    end
end

function ISInventoryPage:dropAll()
    self.inventoryPane:dropAll()
end

function ISInventoryPane:lootBooks()
    local playerInv = getPlayerInventory(self.player).inventory
    local allItems = self.inventory:getItems()

    local itemsToTake = {}
    for i = 0, allItems:size() - 1 do
        local item = allItems:get(i)
        local idType = EHIFTB.isValidEHIFTBItem(item, "grab")
        if idType then
            local identifier = EHIFTB.getItemIdentifier(item)
            if not EHIFTB.memory.rememberedBooks[identifier] and not itemsToTake[identifier]
                    and not EHIFTB.isValidItemInInventory(idType, identifier, item) then
                table.insert(itemsToTake, item)
                itemsToTake[identifier] = true
            end
        end
    end

    if #itemsToTake > 0 then
        if luautils.walkToContainer(self.inventory, self.player) then
            self:transferItemsByWeight(itemsToTake, playerInv)
        end
    end

    self.selected = {}
    getPlayerLoot(self.player).inventoryPane.selected = {}
    getPlayerInventory(self.player).inventoryPane.selected = {}
end

function ISInventoryPage:lootBooks()
    self.inventoryPane:lootBooks()
end

function ISInventoryPane:washClothing()
    local character = getSpecificPlayer(self.player)

    if #self.washList > 0 then
        local lootItems = self.inventory:getItems()
        local contains = false
        for _, item in ipairs(self.washList) do
            if lootItems:contains(item) then
                contains = true
                break
            end
        end
        if contains then
            for _, item in ipairs(self.washList) do
                ISInventoryPaneContextMenu.wearItem(item, self.player)
            end
            NFQOLUtils.wipe(self.washList)
            return
        end
    end

    local isWasher = self.inventory:getParent():getObjectName() == 'ClothingWasher'

    self.washList = {}
    local wornItems = character:getWornItems()
    for i = 0, wornItems:size() - 1 do
        local item = wornItems:get(i):getItem()
        if item:IsClothing() and not item:isHidden() then
            if isWasher then
                if item:hasBlood() or item:hasDirt() then
                    table.insert(self.washList, item)
                end
            else
                if item:getWetness() > 0 then
                    table.insert(self.washList, item)
                end
            end
        end
    end

    if #self.washList > 0 then
        if luautils.walkToContainer(self.inventory, self.player) then
            self:transferItemsByWeight(self.washList, self.inventory)
        end
    end

    self.selected = {}
    getPlayerLoot(self.player).inventoryPane.selected = {}
    getPlayerInventory(self.player).inventoryPane.selected = {}
end

function ISInventoryPage:washClothing()
    self.inventoryPane:washClothing()
end