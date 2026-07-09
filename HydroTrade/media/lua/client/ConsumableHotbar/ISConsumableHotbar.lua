require "ISUI/ISPanelJoypad"

local HydroHUDVehicle = require "HydroHUDVehicle"

ConsumableHotbar = ConsumableHotbar or {}
ConsumableHotbar.SLOT_COUNT = 2

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ConsumableHotbar.startWith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function ConsumableHotbar.isPill(item)
    return ConsumableHotbar.startWith(item:getType(), "Pills")
end

function ConsumableHotbar.canBeInHotbar(item)
    if not item or item:isBroken() then
        return false
    end
    if item:isWaterSource() and item:getUsedDelta() > 0 then
        return true
    end
    if item:getCategory() == "Food" and not item:getScriptItem():isCantEat() then
        return true
    end
    if ConsumableHotbar.isPill(item) then
        return true
    end
    if item:isCanBandage() then
        return true
    end
    return false
end

function ConsumableHotbar.getHotbar(playerNum)
    local data = getPlayerData(playerNum)
    if data then
        return data.consumableHotbar
    end
    return nil
end

function ConsumableHotbar.forEachItem(character, fn)
    local function search(container)
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if fn(item) then
                return true
            end
            if instanceof(item, "InventoryContainer") then
                if search(item:getInventory()) then
                    return true
                end
            end
        end
        return false
    end
    search(character:getInventory())
end

function ConsumableHotbar.findFirstByFullType(character, fullType)
    if not character or not fullType then
        return nil
    end
    local found = nil
    ConsumableHotbar.forEachItem(character, function(item)
        if item:getFullType() == fullType and ConsumableHotbar.canBeInHotbar(item) then
            found = item
            return true
        end
        return false
    end)
    return found
end

function ConsumableHotbar.countByFullType(character, fullType)
    if not character or not fullType then
        return 0
    end
    local count = 0
    ConsumableHotbar.forEachItem(character, function(item)
        if item:getFullType() == fullType and ConsumableHotbar.canBeInHotbar(item) then
            count = count + 1
        end
        return false
    end)
    return count
end

function ConsumableHotbar.collectEligibleByFullType(character, hotbar, excludeSlotIndex)
    local boundTypes = {}
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        if i ~= excludeSlotIndex and hotbar.slotTypes[i] then
            boundTypes[hotbar.slotTypes[i]] = true
        end
    end

    local byType = {}
    ConsumableHotbar.forEachItem(character, function(item)
        if not ConsumableHotbar.canBeInHotbar(item) then
            return false
        end
        local fullType = item:getFullType()
        if boundTypes[fullType] then
            return false
        end
        if not byType[fullType] then
            byType[fullType] = item
        end
        return false
    end)

    local result = {}
    for fullType, item in pairs(byType) do
        table.insert(result, {
            item = item,
            fullType = fullType,
            count = ConsumableHotbar.countByFullType(character, fullType),
        })
    end
    table.sort(result, function(a, b)
        return a.item:getDisplayName() < b.item:getDisplayName()
    end)
    return result
end

function ConsumableHotbar.findItemById(character, itemId)
    if not character or not itemId then
        return nil
    end
    local function search(container)
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item:getID() == itemId then
                return item
            end
            if instanceof(item, "InventoryContainer") then
                local found = search(item:getInventory())
                if found then
                    return found
                end
            end
        end
        return nil
    end
    return search(character:getInventory())
end

function ConsumableHotbar.isBicycle(vehicle)
    return HydroHUDVehicle.isBicycle(vehicle)
end

function ConsumableHotbar.useFull(playerObj, item)
    if not playerObj or not item then
        return false
    end
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        return false
    end
    local playerNum = playerObj:getPlayerNum()
    if ConsumableHotbar.isPill(item) then
        ISInventoryPaneContextMenu.takePill(item, playerNum)
        return true
    end
    if item:isCanBandage() then
        local damaged = ISInventoryPaneContextMenu.haveDamagePart(playerNum)
        if #damaged == 0 then
            return false
        end
        ISInventoryPaneContextMenu.applyBandage(item, damaged[1], playerNum)
        return true
    end
    if item:isWaterSource() and item:getUsedDelta() > 0 then
        ISInventoryPaneContextMenu.onDrinkForThirst(item, playerObj)
        return true
    end
    if item:getCategory() == "Food" then
        if item:isWaterSource() then
            ISInventoryPaneContextMenu.onDrinkForThirst(item, playerObj)
            return true
        end
        if playerObj:getMoodles():getMoodleLevel(MoodleType.FoodEaten) >= 3 and playerObj:getNutrition():getCalories() >= 1000 then
            return false
        end
        ISInventoryPaneContextMenu.eatItem(item, 1, playerNum)
        return true
    end
    return false
end

ISConsumableHotbar = ISPanelJoypad:derive("ISConsumableHotbar")

function ISConsumableHotbar:shouldShow()
    if self.playerNum > 0 or JoypadState.players[self.playerNum + 1] then
        return false
    end
    return true
end

function ISConsumableHotbar:render()
    if not self:shouldShow() then
        self:hideTooltip()
        self:setVisible(false)
        return
    end

    self:setVisible(true)

    self:drawRect(0, 0, self.width, self.height, self.panelBg.a, self.panelBg.r, self.panelBg.g, self.panelBg.b)
    self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local mouseOverSlotIndex = self:getSlotIndexAt(self:getMouseX(), self:getMouseY())
    local draggedItem = nil
    if ISMouseDrag.dragging and mouseOverSlotIndex ~= -1 then
        local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        for _, item in ipairs(dragging) do
            if ConsumableHotbar.canBeInHotbar(item) then
                draggedItem = item
                break
            end
        end
    end

    local slotX = self.margins
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        self:drawRect(slotX, self.margins, self.slotWidth, self.slotHeight, self.slotBg.a, self.slotBg.r, self.slotBg.g, self.slotBg.b)
        self:drawRectBorderStatic(slotX, self.margins, self.slotWidth, self.slotHeight, self.slotBorderColor.a, self.slotBorderColor.r, self.slotBorderColor.g, self.slotBorderColor.b)

        local item = self.slots[i]
        if i == mouseOverSlotIndex then
            local r, g, b = 0.55, 0.9, 0.6
            if draggedItem then
                item = draggedItem
            elseif ISMouseDrag.dragging then
                r, g, b = 1, 0.3, 0.3
            end
            self:drawRect(slotX, self.margins, self.slotWidth, self.slotHeight, 0.25, r, g, b, 1)
            local label = getText("IGUI_ConsumableHotbar_Title")
            if item then
                label = item:getDisplayName()
            end
            local textWid = getTextManager():MeasureStringX(UIFont.Small, label)
            self:drawText(label, slotX + (self.slotWidth - textWid) / 2, 0 - FONT_HGT_SMALL, self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a, self.font)
        elseif item == draggedItem then
            item = nil
        end

        if item then
            local tex = item:getTexture()
            self:drawTexture(tex, slotX + (tex:getWidth() / 2), (self.height - tex:getHeight()) / 2, 1, 1, 1, 1)
            self:drawRemainingOverlay(slotX, item)
            local fullType = self.slotTypes[i] or item:getFullType()
            local count = ConsumableHotbar.countByFullType(self.chr, fullType)
            if count > 1 then
                self:drawText(tostring(count), slotX + self.slotWidth - 16, self.margins + 2,
                    1, 1, 1, 1, self.font)
            end
        end

        slotX = slotX + self.slotWidth + self.slotPad
    end

    self:updateTooltip()
end

function ISConsumableHotbar:hideTooltip()
    if self.tooltipRender then
        self.tooltipRender:removeFromUIManager()
        self.tooltipRender:setVisible(false)
        self.tooltipRender = nil
    end
end

function ISConsumableHotbar:updateTooltip()
    if not self:shouldShow() or not self:isReallyVisible() then
        self:hideTooltip()
        return
    end

    local context = getPlayerContextMenu(self.playerNum)
    if context and context:isAnyVisible() then
        self:hideTooltip()
        return
    end

    local item
    local index = self:getSlotIndexAt(self:getMouseX(), self:getMouseY())
    if index ~= -1 then
        item = self:resolveSlot(index)
    end

    if item and self.tooltipRender and item == self.tooltipRender.item and self.tooltipRender:isVisible() then
        local slotX = self.margins + (self.slotWidth + self.slotPad) * (index - 1)
        self.tooltipRender.anchorBottomLeft = {
            x = self:getAbsoluteX() + slotX,
            y = self:getAbsoluteY() - FONT_HGT_SMALL,
        }
        return
    end

    if item then
        if self.tooltipRender then
            self.tooltipRender:setItem(item)
            self.tooltipRender:setVisible(true)
            self.tooltipRender:addToUIManager()
            self.tooltipRender:bringToTop()
        else
            self.tooltipRender = ISToolTipInv:new(item)
            self.tooltipRender.backgroundColor.a = 0.7
            self.tooltipRender.followMouse = false
            self.tooltipRender:initialise()
            self.tooltipRender:addToUIManager()
            self.tooltipRender:setVisible(true)
            self.tooltipRender:setOwner(self)
            self.tooltipRender:setCharacter(self.chr)
        end
        local slotX = self.margins + (self.slotWidth + self.slotPad) * (index - 1)
        self.tooltipRender.anchorBottomLeft = {
            x = self:getAbsoluteX() + slotX,
            y = self:getAbsoluteY() - FONT_HGT_SMALL,
        }
    else
        self:hideTooltip()
    end
end

function ISConsumableHotbar:getRemainingRatio(item)
    if item:getCategory() == "Food" and item:getBaseHunger() ~= 0 then
        return math.abs(item:getHungerChange() / item:getBaseHunger())
    end
    if instanceof(item, "Drainable") or item:IsDrainable() then
        return item:getUsedDelta()
    end
    return nil
end

function ISConsumableHotbar:drawRemainingOverlay(slotX, item)
    local ratio = self:getRemainingRatio(item)
    if not ratio then
        return
    end
    ratio = math.max(0, math.min(1, ratio))
    if ratio >= 0.999 then
        return
    end

    local innerW = self.slotWidth - 2
    local innerH = self.slotHeight - 2
    local barX = slotX + 1
    local barY = self.margins + self.slotHeight - 2

    if item:getCategory() == "Food" and item:getBaseHunger() ~= 0 then
        local barH = math.floor(innerH * (1 - ratio))
        if barH > 0 then
            self:drawRect(barX, self.margins + 1, innerW, barH, 0.45, 0.2, 0.2, 0.2)
        end
        return
    end

    local barH = 4
    local barW = math.max(2, math.floor(innerW * ratio))
    local r, g, b = 0.85, 0.25, 0.2
    if ratio > 0.5 then
        r, g, b = 0.35, 0.85, 0.45
    elseif ratio > 0.25 then
        r, g, b = 0.85, 0.75, 0.2
    end
    self:drawRect(barX, barY - barH, barW, barH, 0.9, r, g, b)
end

function ISConsumableHotbar:getSlotIndexAt(x, y)
    if x < 0 or x >= self.width or y < 0 or y >= self.height then
        return -1
    end
    local index = math.floor((x - self.margins) / (self.slotWidth + self.slotPad)) + 1
    index = math.max(index, 1)
    return math.min(index, ConsumableHotbar.SLOT_COUNT)
end

function ISConsumableHotbar:getAnchorPanel()
	return getPlayerHotbar(self.playerNum)
end

function ISConsumableHotbar:setSizeAndPosition()
    local slotsWidth = ConsumableHotbar.SLOT_COUNT * self.slotWidth
    slotsWidth = slotsWidth + (ConsumableHotbar.SLOT_COUNT - 1) * self.slotPad
    self:setWidth(slotsWidth + self.margins * 2)

    if HydroHUDVehicle.isVehicleGearHudMode(self.playerNum, self.chr) then
        HydroHUDVehicle.layoutConsumableHotbar(self.playerNum, self)
        return
    end

    local screenX = getPlayerScreenLeft(self.playerNum)
    local screenY = getPlayerScreenTop(self.playerNum)
    local screenW = getPlayerScreenWidth(self.playerNum)
    local screenH = getPlayerScreenHeight(self.playerNum)

    local anchorPanel = self:getAnchorPanel()
    if anchorPanel then
        local x = anchorPanel:getX() + anchorPanel:getWidth() + self.hotbarGap
        local screenRight = screenX + screenW
        if x + self.width > screenRight - 4 then
            x = anchorPanel:getX() - self.width - self.hotbarGap
        end
        self:setX(x)
        self:setY(anchorPanel:getY())
    else
        self:setX(screenX + (screenW - self.width) / 2)
        self:setY(screenY + screenH - self.height - 80)
    end
end

function ISConsumableHotbar:update()
    if not self:shouldShow() then
        self:hideTooltip()
        self:setVisible(false)
    else
        self:setVisible(true)
    end

    self:setSizeAndPosition()
    self:validateSlots()
end

function ISConsumableHotbar:resolveSlot(slotIndex)
    local fullType = self.slotTypes[slotIndex]
    local item = self.slots[slotIndex]
    if item and not fullType then
        fullType = item:getFullType()
        self.slotTypes[slotIndex] = fullType
    end
    if not fullType then
        return nil
    end

    if item and self.chr:getInventory():contains(item, true) and ConsumableHotbar.canBeInHotbar(item) then
        return item
    end

    item = ConsumableHotbar.findFirstByFullType(self.chr, fullType)
    if item then
        self.slots[slotIndex] = item
        return item
    end

    self.slots[slotIndex] = nil
    self.slotTypes[slotIndex] = nil
    return nil
end

function ISConsumableHotbar:validateSlots()
    local changed = false
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        if self.slots[i] or self.slotTypes[i] then
            local before = self.slots[i]
            local resolved = self:resolveSlot(i)
            if before ~= resolved or (before and not resolved) or (not before and resolved) then
                changed = true
            end
        end
    end
    if changed then
        self:saveSlots()
    end
end

function ISConsumableHotbar:isInHotbar(item)
    local fullType = item:getFullType()
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        if self.slots[i] == item or self.slotTypes[i] == fullType then
            return true
        end
    end
    return false
end

function ISConsumableHotbar:removeItem(item)
    local fullType = item:getFullType()
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        if self.slots[i] == item or self.slotTypes[i] == fullType then
            self.slots[i] = nil
            self.slotTypes[i] = nil
        end
    end
    self:saveSlots()
end

function ISConsumableHotbar:removeFromSlot(slotIndex)
    self.slots[slotIndex] = nil
    self.slotTypes[slotIndex] = nil
    self:saveSlots()
end

function ISConsumableHotbar:setSlot(slotIndex, item)
    if not ConsumableHotbar.canBeInHotbar(item) then
        return
    end
    self:removeItem(item)
    self.slots[slotIndex] = item
    self.slotTypes[slotIndex] = item:getFullType()
    self:saveSlots()
end

function ISConsumableHotbar:saveSlots()
    local modData = self.chr:getModData()
    modData.consumableHotbar = modData.consumableHotbar or {}
    modData.consumableHotbar.slots = {}
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        local fullType = self.slotTypes[i]
        local item = self.slots[i]
        if fullType then
            modData.consumableHotbar.slots[i] = {
                fullType = fullType,
                id = item and item:getID() or nil,
            }
        elseif item then
            modData.consumableHotbar.slots[i] = {
                fullType = item:getFullType(),
                id = item:getID(),
            }
        end
    end
end

function ISConsumableHotbar:loadSlots()
    self.slots = {}
    self.slotTypes = {}
    local modData = self.chr:getModData().consumableHotbar
    if not modData or not modData.slots then
        return
    end
    for i, slotData in pairs(modData.slots) do
        local slotIndex = tonumber(i)
        local fullType = nil
        local itemId = nil
        if type(slotData) == "table" then
            fullType = slotData.fullType
            itemId = slotData.id
        else
            itemId = slotData
        end
        local item = nil
        if itemId then
            item = ConsumableHotbar.findItemById(self.chr, itemId)
        end
        if (not item or not ConsumableHotbar.canBeInHotbar(item)) and fullType then
            item = ConsumableHotbar.findFirstByFullType(self.chr, fullType)
        end
        if item and ConsumableHotbar.canBeInHotbar(item) then
            self.slots[slotIndex] = item
            self.slotTypes[slotIndex] = fullType or item:getFullType()
        elseif fullType and ConsumableHotbar.findFirstByFullType(self.chr, fullType) then
            self.slotTypes[slotIndex] = fullType
        end
    end
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        self:resolveSlot(i)
    end
end

function ISConsumableHotbar:activateSlot(slotIndex)
    local item = self:resolveSlot(slotIndex)
    if not item then
        return
    end
    local queue = ISTimedActionQueue.queues[self.character]
    if queue and #queue.queue > 0 then
        return
    end
    ConsumableHotbar.useFull(self.chr, item)
end

function ISConsumableHotbar:doMenu(slotIndex)
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        return
    end

    self:hideTooltip()

    local item = self:resolveSlot(slotIndex)
    if item then
        ISInventoryPaneContextMenu.createMenu(self.playerNum, true, { item }, getMouseX(), getMouseY())
        return
    end

    local candidates = ConsumableHotbar.collectEligibleByFullType(self.chr, self, slotIndex)
    local context = ISContextMenu.get(self.playerNum, getMouseX(), getMouseY())
    if #candidates == 0 then
        local option = context:addOption(getText("IGUI_ConsumableHotbar_NoItems"))
        option.notAvailable = true
        return
    end

    local subOption = context:addOption(getText("IGUI_ConsumableHotbar_Add"), nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(subOption, subMenu)
    for _, entry in ipairs(candidates) do
        local label = entry.item:getDisplayName()
        if entry.count > 1 then
            label = label .. " (" .. tostring(entry.count) .. ")"
        end
        subMenu:addOption(label, self, ISConsumableHotbar.setSlot, slotIndex, entry.item)
    end
end

function ISConsumableHotbar:onMouseUp(x, y)
    if ISMouseDrag.dragging then
        local slotIndex = self:getSlotIndexAt(x, y)
        if slotIndex == -1 then
            return
        end
        local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
        for _, item in ipairs(dragging) do
            if ConsumableHotbar.canBeInHotbar(item) then
                self:setSlot(slotIndex, item)
                break
            end
        end
        return
    end

    local slotIndex = self:getSlotIndexAt(x, y)
    if slotIndex ~= -1 then
        self:activateSlot(slotIndex)
    end
end

function ISConsumableHotbar:onRightMouseUp(x, y)
    local slotIndex = self:getSlotIndexAt(x, y)
    if slotIndex ~= -1 then
        self:doMenu(slotIndex)
    end
end

function ISConsumableHotbar:new(character)
    local o = ISPanelJoypad:new(0, 0, 300, 70)
    setmetatable(o, self)
    self.__index = self

    o.slotWidth = 60
    o.slotHeight = 60
    o.slotPad = 4
    o.margins = 5
    o.hotbarGap = 6
    o.character = character
    o.chr = character
    o.playerNum = character:getPlayerNum()
    o.panelBg = { r = 0.06, g = 0.14, b = 0.08, a = 0.55 }
    o.slotBg = { r = 0.04, g = 0.1, b = 0.06, a = 0.7 }
    o.borderColor = { r = 0.35, g = 0.75, b = 0.45, a = 0.95 }
    o.slotBorderColor = { r = 0.3, g = 0.6, b = 0.38, a = 0.85 }
    o.textColor = { r = 0.75, g = 0.95, b = 0.78, a = 1 }
    o.font = UIFont.Small
    o.slots = {}
    o.slotTypes = {}
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true

    o:loadSlots()
    o:setSizeAndPosition()
    return o
end
