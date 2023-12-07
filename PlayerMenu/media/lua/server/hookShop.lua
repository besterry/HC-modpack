PM =PM or {}
local old_ShopSpriteCursor
-- if not PM.ShopCount then
--     LoadBalanceAndSafeHousePlayer()
-- end

local function OnGameStart()
	old_ShopSpriteCursor = ShopSpriteCursor.create
    function ShopSpriteCursor:create(x, y, z, north, sprite)
        local o = old_ShopSpriteCursor(self, x, y, z, north, sprite)  
        if PM.ShopCount < PM.MaxShopCount then 
            PM.ShopCount = PM.ShopCount+1	      
            local saveData = {}
            saveData.ShopCount = PM.ShopCount
            sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
            return o
        end
    end
end

Events.OnGameStart.Add(OnGameStart)

local old_PlayerShopPickupShop = PlayerShop.PickupShop
function PlayerShop.PickupShop(worldobjects,player,shop)
    --local o = old_PlayerShopPickupShop(worldobjects,player,shop)   
    --return o
    local items = shop:getContainer():getItems()
    if items and items:size() > 0 then
        player:setHaloNote(UIText.RemoveItemsPlayerShop, 255,255,255,400);
        return
    end
    local income = shop:getModData().income
    if #income and #income > 0 then
        player:setHaloNote(UIText.RemoveIncomePlayerShop, 255,255,255,400);
        return
    end
    shop:getSquare():transmitRemoveItemFromSquare(shop)
    PlayerShop.toggleBusy(shop,player:getUsername(),false)

    if PM.ShopCount > 0 then 
        PM.ShopCount = PM.ShopCount-1 
        local saveData = {}
        saveData.ShopCount = PM.ShopCount
        sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
    end
end
