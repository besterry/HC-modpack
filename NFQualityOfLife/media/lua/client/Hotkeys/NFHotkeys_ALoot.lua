NFHotkeys = NFHotkeys or {}

local function getLoot()
    local loot = getPlayerLoot(0)
    if loot ~= nil and not loot.isCollapsed then
        if loot.inventoryPane.inventoryPage.lootAll:isReallyVisible() then
            return loot
        end
    end
    return nil
end

function NFHotkeys.lootAll()
    if not isCtrlKeyDown() then return end

    local loot = getLoot()
    if loot then
        loot.inventoryPane:lootAll()
    end
end

function NFHotkeys.lootDrop()
    if not isCtrlKeyDown() then return end

    local loot = getLoot()
    if loot then
        loot.inventoryPane:dropAll()
    end
end