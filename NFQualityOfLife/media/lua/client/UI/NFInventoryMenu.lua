local function onTakePills(player, item, count)
    local character = getSpecificPlayer(player)
    ISInventoryPaneContextMenu.transferIfNeeded(character, item)
    ISTimedActionQueue.add(NFTakePillsAction:new(character, item, count))
end

local original_addDynamicalContextMenu = ISInventoryPaneContextMenu.addDynamicalContextMenu
function ISInventoryPaneContextMenu.addDynamicalContextMenu(selectedItem, context, recipeList, player, containerList)
    if selectedItem:getFullType() == "Base.PillsVitamins" then
        local option = context:getOptionFromName(getText("ContextMenu_Take_pills"))
        if not option then return end

        local usesLeft = math.ceil(selectedItem:getUsedDelta() / selectedItem:getUseDelta())
        if usesLeft > 1 then
            option.onSelect = nil
            local subMenu = ISContextMenu:getNew(context)
            context:addSubMenu(option, subMenu)

            for count = 1, usesLeft do
                local name = tostring(count)
                if count == usesLeft then
                    name = getText("ContextMenu_Eat_All")
                end
                local subOption = subMenu:addOption(name, player, onTakePills, selectedItem, count)
                local tooltip = ISInventoryPaneContextMenu.addToolTip()
                tooltip.description = getText("Tooltip_item_Fatigue") .. ": " .. " <RGB:0,1,0> " .. math.floor((selectedItem:getFatigueChange() * 100)) * count
                subOption.toolTip = tooltip
            end
        end
    end

    original_addDynamicalContextMenu(selectedItem, context, recipeList, player, containerList)
end