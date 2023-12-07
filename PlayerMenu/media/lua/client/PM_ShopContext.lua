-- Events.OnPreFillWorldObjectContextMenu.Remove(PlayerShop.PlayerShopContextMenu)

function PlayerShop.PlayerShopContextMenuEditShopTB(playerNum, context, worldobjects)
    local playerShop = PM.editshopTB
    if playerShop and (PM.ShopCount < PM.MaxShopCount) then
        context:addOption(UIText.AddPlayerShop, worldobjects, PlayerShop.addPlayerShop, playerNum,PlayerShop.sprites.NoSign);
        context:addOption(UIText.AddPlayerShopFreezer, worldobjects, PlayerShop.addPlayerShop, playerNum,PlayerShop.sprites.Freezer);
    end
end
Events.OnPreFillWorldObjectContextMenu.Add(PlayerShop.PlayerShopContextMenuEditShopTB)
