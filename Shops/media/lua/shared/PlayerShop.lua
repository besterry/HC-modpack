require "Shop"

PlayerShop = PlayerShop or {}
PlayerShop.Tabs = PlayerShop.Tabs or {}
PlayerShop.Tabs[Tab.All] = getText("IGUI_Tab_All")
Tab["BuyOrders"] = "BuyOrders"
PlayerShop.Tabs[Tab.BuyOrders] = getText("IGUI_Tab_SellToShop")
PlayerShop.status= {}
PlayerShop.spritePrefix = "playershop_"

function PlayerShop.hasSaleItems(shop)
	if not shop then return false end
	local container = shop:getContainer()
	if not container then return false end
	local items = container:getItems()
	for i = 0, items:size() - 1 do
		if items:get(i):getModData().price then
			return true
		end
	end
	return false
end

function PlayerShop.hasBuyOrders(shop)
	if not shop then return false end
	local orders = shop:getModData().buyOrders
	if not orders then return false end
	for _, ord in pairs(orders) do
		if ord and ord.type and (tonumber(ord.qty) or 0) > 0 then
			return true
		end
	end
	return false
end

function PlayerShop.getTradeState(shop)
	local hasSell = PlayerShop.hasSaleItems(shop)
	local hasBuy = PlayerShop.hasBuyOrders(shop)
	if hasSell and hasBuy then
		return "both"
	elseif hasBuy then
		return "buy"
	elseif hasSell then
		return "sell"
	end
	return "empty"
end

function PlayerShop.isTradeable(shop)
	return PlayerShop.getTradeState(shop) ~= "empty"
end

function PlayerShop.notifyEmptyShop(player)
	if not player then return end
	player:setHaloNote(getText("IGUI_PlayerShop_Empty"), 255, 220, 120, 2000)
end

function PlayerShop.getTradeIndicatorText(shop)
	local state = PlayerShop.getTradeState(shop)
	if state == "both" then
		return getText("IGUI_PlayerShop_Indicator_Both")
	elseif state == "buy" then
		return getText("IGUI_PlayerShop_Indicator_Buy")
	elseif state == "sell" then
		return getText("IGUI_PlayerShop_Indicator_Sell")
	end
	return getText("IGUI_PlayerShop_Indicator_Empty")
end

function PlayerShop.getTradeIndicator(shop)
	return PlayerShop.getTradeState(shop)
end

PlayerShop.sprites = {
	NoSign = {
		"playershop_0",
		"playershop_1",
	},
	FirstAid = {
		"playershop_2",
		"playershop_3",
	},
	Food = {
		"playershop_4",
		"playershop_5",
	},
	Clothes = {
		"playershop_18",
		"playershop_19",
	},
	Melee = {
		"playershop_6",
		"playershop_7",
	},
	Guns = {
		"playershop_8",
		"playershop_9",
	},
	Ammo = {
		"playershop_16",
		"playershop_17",
	},
	Furniture = {
		"playershop_10",
		"playershop_11",
	},
	Materials = {
		"playershop_12",
		"playershop_13",
	},
	Misc = {
		"playershop_14",
		"playershop_15",
	},
	Freezer = {
		"playershop_20",
		"playershop_21",
	},
}