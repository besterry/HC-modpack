WalletContainers_Client = WalletContainers_Client or {}

local function isWalletItem(item)
    if not item or not instanceof(item, "InventoryItem") then return false end
    return item:canBeEquipped() == "Wallet" or item:getBodyLocation() == "Wallet"
end

local function onWearWallet(player, item)
    if not player or not item then return end
    ISInventoryPaneContextMenu.transferIfNeeded(player, item)
    ISInventoryPaneContextMenu.wearItem(item, player:getPlayerNum())
end

local function onFillInventoryObjectContextMenu(playerIndex, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items or #items ~= 1 then return end

    local item = items[1]
    if not isWalletItem(item) then return end

    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    if player:getWornItem("Wallet") then
        return
    end

    context:addOption(getText("ContextMenu_Wear"), player, onWearWallet, item)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)