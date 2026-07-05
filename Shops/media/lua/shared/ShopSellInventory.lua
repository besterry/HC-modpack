require "Shop"

ShopSellInventory = ShopSellInventory or {}
ShopSellInventory.MAIN_SOURCE_ID = "main"

local Nfunction = require "Nfunction"

local function getBagContainer(item)
	if not item then return nil end
	if item.getItemContainer then
		local inv = item:getItemContainer()
		if inv then return inv end
	end
	if item.getInventory then
		return item:getInventory()
	end
	return nil
end

function ShopSellInventory.shouldSkipItem(item, fromMainInventory)
	if not item then return true end
	if item:isFavorite() then return true end
	if Currency.Coins[item:getFullType()] then return true end
	if fromMainInventory and item:isEquipped() then return true end
	return false
end

function ShopSellInventory.getSources(character)
	local sources = {}
	if not character then return sources end

	table.insert(sources, {
		id = ShopSellInventory.MAIN_SOURCE_ID,
		label = getText("IGUI_Sell_Source_Main"),
		container = character:getInventory(),
	})

	local worn = character:getWornItems()
	if not worn then return sources end

	for i = 0, worn:size() - 1 do
		local wornEntry = worn:get(i)
		if wornEntry then
			local wornItem = wornEntry:getItem()
			local bagInv = getBagContainer(wornItem)
			if bagInv then
				table.insert(sources, {
					id = "bag_" .. tostring(wornItem:getID()),
					label = Nfunction.trimString(wornItem:getName(), 18),
					container = bagInv,
					bagItem = wornItem,
				})
			end
		end
	end

	return sources
end

function ShopSellInventory.getSourceByIndex(character, index)
	local sources = ShopSellInventory.getSources(character)
	if not index or index < 1 or index > #sources then
		return sources[1]
	end
	return sources[index]
end

function ShopSellInventory.forEachSellableInSource(source, fn)
	if not source or not source.container or not fn then return end
	local fromMain = source.id == ShopSellInventory.MAIN_SOURCE_ID
	local items = source.container:getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if not ShopSellInventory.shouldSkipItem(item, fromMain) then
			fn(item)
		end
	end
end

function ShopSellInventory.passesSellPriceFilter(v)
	if not v then return false end
	if v.specialCoin then
		return v.price > 0
	end
	return v.price > 1
end

function ShopSellInventory.tryBuildEntry(item, sellItems, opts)
	opts = opts or {}
	local itemType = item:getFullType()
	local itemSell = sellItems and sellItems[itemType] or Shop.Sell[itemType]
	local isBroken = item:isBroken()

	if Shop.SellisBlacklist and itemSell then return nil end
	if itemSell and itemSell.blacklisted then return nil end

	local price = Shop.defaultPrice
	if isBroken then price = Shop.defaultPriceBroken end
	if itemSell then
		if isBroken then
			price = itemSell.priceBroken or Shop.defaultPriceBroken
		else
			price = itemSell.price or Shop.defaultPrice
		end
	end

	local v = {}
	v.type = itemType
	v.specialCoin = itemSell and itemSell.specialCoin or nil
	v.priceFull = price
	price = Nfunction.drainablePrice(item, price)
	v.price = price
	v.id = item:getID()
	v.name = Nfunction.trimString(item:getName(), opts.nameLen or 42)
	v.invItem = item

	if Shop.SellisWhitelist and not itemSell then return nil end
	if not ShopSellInventory.passesSellPriceFilter(v) then return nil end
	return v
end

function ShopSellInventory.collectFromSource(character, sourceIndex, sellItems, excludeIds, opts)
	local list = {}
	local source = ShopSellInventory.getSourceByIndex(character, sourceIndex)
	if not source then return list end

	ShopSellInventory.forEachSellableInSource(source, function(item)
		local itemId = item:getID()
		if excludeIds and excludeIds[itemId] then return end
		local entry = ShopSellInventory.tryBuildEntry(item, sellItems, opts)
		if entry then
			table.insert(list, entry)
		end
	end)

	return list
end

function ShopSellInventory.buildItemMap(character)
	local map = {}
	local sources = ShopSellInventory.getSources(character)
	for i = 1, #sources do
		ShopSellInventory.forEachSellableInSource(sources[i], function(item)
			map[item:getID()] = item
		end)
	end
	return map
end
