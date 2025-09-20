-- Блокировка крафта из контейнеров магазина игрока
PlayerShop = PlayerShop or {}
PlayerShop.spritePrefix = "playershop_"
local RecipeManager_base = {
	IsRecipeValid = RecipeManager.IsRecipeValid,
	getAvailableItemsNeeded = RecipeManager.getAvailableItemsNeeded,
	getNumberOfTimesRecipeCanBeDone = RecipeManager.getNumberOfTimesRecipeCanBeDone,
	getAvailableItemsAll = RecipeManager.getAvailableItemsAll,
}

---@param container ItemContainer
---@return boolean
local function isShopContainer(container)
	if not container then return false end
	local parent = container:getParent()
	if not parent then return false end
	-- проверка по имени спрайта
	local sprite = parent:getSprite()
	if sprite and PlayerShop.spritePrefix then
		local name = sprite:getName()
		if name and string.find(name, PlayerShop.spritePrefix) then
			return true
		end
	end
	-- запасная проверка по modData владельца
	-- if parent.getModData then
	-- 	local md = parent:getModData()
	-- 	if md and md.owner and PlayerShop then
	-- 		return true
	-- 	end
	-- end
	return false
end

---@param containersArr ArrayList
---@return ArrayList
local function removeShopContainersFromList(containersArr)
	if not containersArr then return containersArr end
	local copy = containersArr:clone()
	copy:trimToSize()
	for i = copy:size() - 1, 0, -1 do
		local c = copy:get(i)
		if isShopContainer(c) then
			copy:remove(c)
			copy:trimToSize()
		end
	end
	return copy
end

---@param recipe Recipe
---@param player IsoGameCharacter
---@param item InventoryItem
---@param containersArr ArrayList
---@return boolean
function RecipeManager.IsRecipeValid(recipe, player, item, containersArr)
	if containersArr == nil then
		return RecipeManager_base.IsRecipeValid(recipe, player, item, containersArr)
	end
	local filtered = removeShopContainersFromList(containersArr)
	if item and isShopContainer(item:getContainer()) then
		return false
	end
	return RecipeManager_base.IsRecipeValid(recipe, player, item, filtered)
end

---@param recipe Recipe
---@param player IsoGameCharacter
---@param containersArr ArrayList
---@param selectedItem InventoryItem
---@param ignoreItems ArrayList
---@return ArrayList
function RecipeManager.getAvailableItemsNeeded(recipe, player, containersArr, selectedItem, ignoreItems)
	local filtered = removeShopContainersFromList(containersArr)
	if selectedItem and isShopContainer(selectedItem:getContainer()) then
		selectedItem = nil
	end
	return RecipeManager_base.getAvailableItemsNeeded(recipe, player, filtered, selectedItem, ignoreItems)
end

---@param recipe Recipe
---@param player IsoGameCharacter
---@param containersArr ArrayList
---@param item InventoryItem
---@return int
function RecipeManager.getNumberOfTimesRecipeCanBeDone(recipe, player, containersArr, item)
	local filtered = removeShopContainersFromList(containersArr)
	if item and isShopContainer(item:getContainer()) then
		return 0
	end
	return RecipeManager_base.getNumberOfTimesRecipeCanBeDone(recipe, player, filtered, item)
end

---@param recipe Recipe
---@param player IsoGameCharacter
---@param containersArr ArrayList
---@param selectedItem InventoryItem
---@param ignoreItems ArrayList
---@return ArrayList
function RecipeManager.getAvailableItemsAll(recipe, player, containersArr, selectedItem, ignoreItems)
	local filtered = removeShopContainersFromList(containersArr)
	if selectedItem and isShopContainer(selectedItem:getContainer()) then
		selectedItem = nil
	end
	return RecipeManager_base.getAvailableItemsAll(recipe, player, filtered, selectedItem, ignoreItems)
end


