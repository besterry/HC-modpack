local npcShopState = ShopProximity.newState()

local function canUseNpcShop(player)
	return ShopProximity.defaultCanUse(player, ShopUI and ShopUI.instance)
end

local function getNpcShopHintText(player, shop)
	local keyName = getKeyName(getCore():getKey("Interact"))
	return getText("IGUI_Shop_NearHint", keyName)
end

local npcShopProximityOpts = {
	spritePrefix = Shop.spritePrefix,
	canUse = canUseNpcShop,
	getHintText = getNpcShopHintText,
	open = function(player, shop)
		local sq = shop:getSquare()
		if not sq then return end
		Shop.shopUI({ shop }, player:getPlayerNum(), false, sq)
	end,
}

function Shop.openNearbyNpcShop(player)
	ShopProximity.tryOpen(player, npcShopState, npcShopProximityOpts)
end

local function seekShopTiles(worldobject,spritePrefix)
    local wo = worldobject
    local found = false
    if not wo then return wo,found end
    local sprite = wo:getSprite()
    local spriteName = sprite:getName()
    if spriteName then
        if(string.find(spriteName,spritePrefix)) then 
            found = true
        end
    end
    return wo, found
end

function Shop.addShop(worldobjects, playerNum,sprites)
    local player = getSpecificPlayer(playerNum)
    getCell():setDrag(ShopSpriteCursor:new(player,sprites),playerNum)
end

function Shop.removeShop(worldobject)
    worldobject:getSquare():transmitRemoveItemFromSquare(worldobject)
end

function Shop.ShopContextMenu(playerNum, context, worldobjects)
    if not (isClient() and isAdmin()) then return end
    local wo, found = seekShopTiles(worldobjects[1],Shop.spritePrefix)
    local player = getSpecificPlayer(playerNum)
    local shop = context:addOption(UIText.AddShop,worldobjects,nil);
    local subShop = context:getNew(context);
    context:addSubMenu(shop, subShop);
    for k,v in pairs(Shop.sprites) do
        subShop:addOption(k, worldobjects, Shop.addShop, playerNum,v);
    end
    if found then 
        context:addOption(UIText.RemoveShop, wo, Shop.removeShop);
    end
end

function Shop.shopUI(worldobjects,playerNum,viewMode,clickedSquare)
    local player = getSpecificPlayer(playerNum)
    if not viewMode then
        clickedSquare = luautils.getCorrectSquareForWall(player, clickedSquare);
        local adjacent = AdjacentFreeTileFinder.Find(clickedSquare, player);
        if adjacent then
            local action = ISWalkToTimedAction:new(player, adjacent)
            local shop = worldobjects[1]
            action:setOnComplete(function() ShopUI:show(player,viewMode,shop) end)
            ISTimedActionQueue.add(action)
        end
    else
        ShopUI:show(player,viewMode)
    end
end

function Shop.ShopUIContextMenu(playerNum, context, worldobjects)
    if not isClient() then return end
    local _,found = seekShopTiles(worldobjects[1],Shop.spritePrefix)
    if not found then return end
    local option = context:addOptionOnTop(UIText.Shop, worldobjects, Shop.shopUI, playerNum, false, clickedSquare)
    ShopProximity.addShopIcon(option)
end

ShopProximity.register({ state = npcShopState, opts = npcShopProximityOpts })
ShopProximity.initGlobalEvents()

Events.OnFillWorldObjectContextMenu.Add(Shop.ShopViewContextMenu)
Events.OnPreFillWorldObjectContextMenu.Add(Shop.ShopContextMenu)
Events.OnPreFillWorldObjectContextMenu.Add(Shop.ShopUIContextMenu)
