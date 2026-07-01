local atmState = ShopProximity.newState()
local ATM_NEAR_RADIUS = 2.0

local function canUseATM(player)
	return ShopProximity.defaultCanUse(player, ATMSellUI and ATMSellUI.instance)
end

local function getATMHintText(player, atmWo)
	local keyName = getKeyName(getCore():getKey("Interact"))
	return getText("IGUI_ATM_NearHint", keyName)
end

function Shop.openATMSell(player, atmWo)
	if not player or not atmWo then return end
	local sq = atmWo:getSquare()
	if not sq then return end
	sq = luautils.getCorrectSquareForWall(player, sq)
	local adjacent = AdjacentFreeTileFinder.Find(sq, player)
	if not adjacent then return end
	local action = ISWalkToTimedAction:new(player, adjacent)
	action:setOnComplete(function() ATMSellUI:show(player, atmWo) end)
	ISTimedActionQueue.add(action)
end

local atmProximityOpts = {
	isObject = Shop.isATMTile,
	interactRadius = ATM_NEAR_RADIUS,
	hintRadius = ATM_NEAR_RADIUS,
	canUse = canUseATM,
	getHintText = getATMHintText,
	open = function(player, atmWo)
		Shop.openATMSell(player, atmWo)
	end,
}

local function findATM(worldobjects)
	if not worldobjects then return nil end
	for i = 1, #worldobjects do
		if Shop.isATMTile(worldobjects[i]) then
			return worldobjects[i]
		end
	end
	if clickedSquare then
		local objects = clickedSquare:getObjects()
		if objects then
			for i = 0, objects:size() - 1 do
				local o = objects:get(i)
				if Shop.isATMTile(o) then
					return o
				end
			end
		end
	end
	return nil
end

function Shop.ATMContextMenu(playerNum, context, worldobjects)
	if not isClient() then return end

	local atmWo = findATM(worldobjects)
	if not atmWo then return end

	local player = getSpecificPlayer(playerNum)
	local option = context:addOption(getText("IGUI_ATM_Sell"), worldobjects, function()
		Shop.openATMSell(player, atmWo)
	end)
	ShopProximity.addShopIcon(option)
end

ShopProximity.register({ state = atmState, opts = atmProximityOpts })

Events.OnPreFillWorldObjectContextMenu.Add(Shop.ATMContextMenu)
