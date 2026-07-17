-- Compact section header for clothing categories (replaces large category buttons).
require "ISUI/ISButton"
local utils = require "utils/utils"

myCategoryButton = ISButton:derive("myCategoryButton");

function myCategoryButton:new(x, y, width, height, category, locations)
    local nameOfCategory = utils.getCategoryButtonText(category);

    local o = ISButton:new(x, y, width, height, nameOfCategory);
    setmetatable(o, self)
    self.__index = self
    o.category = category
    o.locations = locations;
    o.contextMenu = nil;
    o.hasDamagedItems = false;
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
    o.backgroundColorMouseOver = { r = 0.25, g = 0.25, b = 0.25, a = 0.45 };
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 };
    o.defaultTextColor = { r = 0.75, g = 0.75, b = 0.75, a = 1 };
    o.warningTextColor = { r = 0.95, g = 0.55, b = 0.25, a = 1 };
    return o
end

function myCategoryButton:prerender()
    if self.hasDamagedItems then
        self.textColor = self.warningTextColor;
    else
        self.textColor = self.defaultTextColor;
    end
    ISButton.prerender(self);
end

function myCategoryButton:render()
    ISButton.render(self);
    local lineY = self.height - 1;
    if self.hasDamagedItems then
        self:drawRect(0, lineY, self.width, 1, 0.85, 0.95, 0.5, 0.2);
    else
        self:drawRect(0, lineY, self.width, 1, 0.35, 0.55, 0.55, 0.55);
    end
end

function myCategoryButton:onRightMouseUp(x, y)
    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        return;
    end

    local player = getPlayer();
    local playerNum = player:getPlayerNum();
    local playerInv = player:getInventory();
    local playerItems = playerInv:getItems();
    self.contextMenu = ISContextMenu.get(playerNum, getMouseX(), getMouseY());

    local sortedItems = {};
    local bfound = false;

    for i = 0, playerItems:size() - 1 do
        local loopitem = playerItems:get(i);
        local itemBodyLocation = loopitem:getBodyLocation();
        if (self.locations[itemBodyLocation]) and not loopitem:isEquipped() then
            local locationIndex = myClothingUI:getBodyLocationIndex(self.locations, itemBodyLocation)
            table.insert(sortedItems, {
                index = locationIndex,
                name = loopitem:getDisplayName(),
                bodyLocation = itemBodyLocation,
                itemData = loopitem
            })
            bfound = true;
        end
    end

    local sortFunc = function(a, b)
        return a.index < b.index
    end
    table.sort(sortedItems, sortFunc);

    if bfound then
        for k, loopitem in pairs(sortedItems) do
            local displayString = loopitem.name .. "  [" .. utils.getBodySlotText(loopitem.bodyLocation) .. "]";
            local option = self.contextMenu:addOption(displayString, self, self.equipItem, loopitem.itemData);
            ISInventoryPaneContextMenu.doWearClothingTooltip(player, loopitem.itemData, loopitem.itemData, option);
        end
    else
        self.contextMenu:addOption(getText("UI_CUI_no_items_avaliable"));
    end
end

function myCategoryButton:equipItem(item)
    ISInventoryPaneContextMenu.onWearItems({item}, getPlayer():getPlayerNum())
end
