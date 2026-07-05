require "ISUI/PlayerData/ISPlayerDataObject"

local function createConsumableHotbar(playerData)
    if getCore():getGameMode() == "Tutorial" then
        return
    end
    local playerObj = getSpecificPlayer(playerData.id)
    if not playerObj then
        return
    end
    local isMouse = playerData.id == 0 and playerObj:getJoypadBind() == -1
    playerData.consumableHotbar = ISConsumableHotbar:new(playerObj)
    playerData.consumableHotbar:initialise()
    playerData.consumableHotbar:addToUIManager()
    playerData.consumableHotbar:setVisible(isMouse)
end

local function onFillInventoryObjectContextMenu(playerIndex, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items or #items ~= 1 then
        return
    end

    local item = items[1]
    if not ConsumableHotbar.canBeInHotbar(item) then
        return
    end

    local hotbar = ConsumableHotbar.getHotbar(playerIndex)
    if not hotbar then
        return
    end

    if hotbar:isInHotbar(item) then
        context:addOptionOnTop(getText("IGUI_ConsumableHotbar_RemoveItem", item:getDisplayName()), hotbar, ISConsumableHotbar.removeItem, item)
        return
    end

    local subOption = context:addOptionOnTop(getText("IGUI_ConsumableHotbar_Add"), nil)
    local subMenu = context:getNew(context)
    context:addSubMenu(subOption, subMenu)
    for i = 1, ConsumableHotbar.SLOT_COUNT do
        local label = getText("IGUI_ConsumableHotbar_SlotN", tostring(i))
        local option = subMenu:addOption(label, hotbar, ISConsumableHotbar.setSlot, i, item)
        if hotbar.slots[i] then
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = getText("Tooltip_ReplaceWornItems") .. " <LINE> <INDENT:20> " .. hotbar.slots[i]:getDisplayName()
            option.toolTip = tooltip
        end
    end
end

local function installHooks()
    local originalCreateInventoryInterface = ISPlayerDataObject.createInventoryInterface
    function ISPlayerDataObject:createInventoryInterface()
        originalCreateInventoryInterface(self)
        createConsumableHotbar(self)
    end

    local originalRemoveInventoryUI = removeInventoryUI
    function removeInventoryUI(id)
        local data = getPlayerData(id)
        if data and data.consumableHotbar then
            data.consumableHotbar:hideTooltip()
            data.consumableHotbar:removeFromUIManager()
            data.consumableHotbar = nil
        end
        originalRemoveInventoryUI(id)
    end

    Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
end

Events.OnGameBoot.Add(installHooks)
