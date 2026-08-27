require 'CHC_main'

CHC_menu = {}

--- called just after CHC_main.loadDatas
--- loads config and creates window instance
CHC_menu.createCraftHelper = function()
	local okLoad, errLoad = pcall(CHC_settings.Load)
	if not okLoad then
		print("[CHC] Load failed: " .. tostring(errLoad))
		CHC_settings.config = CHC_settings.config or {}
	end

	local options = CHC_settings.config or {}
	local mw = options.main_window
	if type(mw) ~= "table" then
		mw = { x = 100, y = 100, w = 1000, h = 600 }
		options.main_window = mw
	end

	local args = {
		x = tonumber(mw.x) or 100,
		y = tonumber(mw.y) or 100,
		width = tonumber(mw.w) or 1000,
		height = tonumber(mw.h) or 600,
		backgroundColor = { r = 0, g = 0, b = 0, a = 1 },
		minimumWidth = 400,
		minimumHeight = 350
	}

	local okWin, errWin = pcall(function()
		CHC_menu.CHC_window = CHC_window:new(args)
		CHC_menu.CHC_window:initialise()
		CHC_menu.CHC_window:setVisible(false)
	end)
	if not okWin then
		print("[CHC] window create failed: " .. tostring(errWin))
		CHC_menu.CHC_window = nil
	end
end

--- called on right-clicking item in inventory/hotbar
CHC_menu.doCraftHelperMenu = function(player, context, items)
	local itemsUsedInRecipes = {}

	local item
	-- Go through the items selected (because multiple selections in inventory is possible)
	for i = 1, #items do

		-- allows to get ctx option when clicking on hotbar/equipped item
		if not instanceof(items[i], "InventoryItem") then
			item = items[i].items[1]
		else
			item = items[i]
		end

		-- if item is used in any recipe OR there is a way to create this item - mark item as valid
		local cond1 = type(CHC_main.recipesByItem[item:getFullType()]) == 'table'
		local cond2 = type(CHC_main.recipesForItem[item:getFullType()]) == 'table'
		if cond1 or cond2 then
			table.insert(itemsUsedInRecipes, item)
		end
	end

	-- If one or more items tested above are used in a recipe
	-- we effectively add an option in the contextual menu
	if type(itemsUsedInRecipes) == 'table' and #itemsUsedInRecipes > 0 then
		context:addOption(getText("IGUI_chc_context_onclick"), itemsUsedInRecipes, CHC_menu.onCraftHelper, player);
	end
	if isShiftKeyDown() and CHC_menu.CHC_window ~= nil then
		local optName = getText("UI_servers_addToFavorite") .. " (" .. getText("IGUI_chc_context_onclick") .. ")"
		context:addOption(optName, items, CHC_menu.toggleItemFavorite)
	end
end

CHC_menu.onCraftHelper = function(items, player)
	local inst = CHC_menu.CHC_window
	if inst == nil then
		CHC_menu.createCraftHelper()
		inst = CHC_menu.CHC_window
	end
	if inst == nil then return end

	-- Show craft helper window
	for i = 1, #items do
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
			item = item.items[1]
		end
		inst:addItemView(item)
	end
	if not inst:getIsVisible() then
		inst:setVisible(true)
		inst:addToUIManager()
	end
end

--- window toggle logic
CHC_menu.toggleUI = function()
	local ui = CHC_menu.CHC_window
	if ui then
		if ui:getIsVisible() then
			ui:setVisible(false)
			ui:removeFromUIManager()
		else
			ui:setVisible(true)
			ui:addToUIManager()
		end
	end
end

CHC_menu.toggleItemFavorite = function(items)
	local modData = CHC_main.playerModData
	for i = 1, #items do
		local item
		if not instanceof(items[i], "InventoryItem") then
			item = items[i].items[1]
		else
			item = items[i]
		end
		local isFav = modData[CHC_main.getFavItemModDataStr(item)] == true
		isFav = not isFav
		modData[CHC_main.getFavItemModDataStr(item)] = isFav or nil
	end
	CHC_menu.CHC_window.updateQueue:push({
		targetView = 'fav_items',
		actions = { 'needUpdateFavorites', 'needUpdateObjects', 'needUpdateTypes', 'needUpdateCategories' }
	})
end

---Show/hide Craft Helper window keybind listener
---@param key number key code
CHC_menu.onPressKey = function(key)
	if not MainScreen.instance or not MainScreen.instance.inGame or MainScreen.instance:getIsVisible() then
		return
	end
	if key == CHC_settings.keybinds.toggle_window.key then
		CHC_menu.toggleUI()
	end
end

-- region replace side-panel Crafting button / Crafting UI key with Craft Helper
require "ISUI/ISEquippedItem"
require "ISUI/ISCraftingUI"

local _CHC_vanillaToggleCraftingUI = ISCraftingUI.toggleCraftingUI

CHC_menu.isCraftHelperVisible = function()
	local ui = CHC_menu.CHC_window
	return ui ~= nil and ui:getIsVisible()
end

CHC_menu.openVanillaCraftingUI = function()
	_CHC_vanillaToggleCraftingUI()
end

--- Side button + "Crafting UI" key open Craft Helper. Shift+click keeps vanilla crafting.
ISCraftingUI.toggleCraftingUI = function()
	if isShiftKeyDown() then
		-- close helper if open, then toggle vanilla
		if CHC_menu.isCraftHelperVisible() then
			CHC_menu.toggleUI()
		end
		_CHC_vanillaToggleCraftingUI()
		return
	end
	-- close vanilla crafting if it was open
	local vanilla = getPlayerCraftingUI(0)
	if vanilla and vanilla:getIsVisible() then
		vanilla:setVisible(false)
		vanilla:removeFromUIManager()
	end
	if CHC_menu.CHC_window == nil then
		CHC_menu.createCraftHelper()
	end
	if CHC_menu.CHC_window == nil then
		-- last resort: vanilla crafting so player is not stuck
		print("[CHC] helper unavailable, opening vanilla crafting")
		_CHC_vanillaToggleCraftingUI()
		return
	end
	CHC_menu.toggleUI()
end

local _CHC_ISEquippedItem_prerender = ISEquippedItem.prerender
function ISEquippedItem:prerender()
	_CHC_ISEquippedItem_prerender(self)
	if not self.craftingBtn then return end
	if CHC_menu.isCraftHelperVisible() then
		self.craftingBtn:setImage(self.craftingIconOn)
	elseif not (getPlayerCraftingUI(0) and getPlayerCraftingUI(0):getIsVisible()) then
		self.craftingBtn:setImage(self.craftingIcon)
	end
end

CHC_menu.patchCraftingButtonTooltip = function()
	local eq = ISEquippedItem.instance
	if not eq or not eq.mouseOverList then return end
	local tip = getText("IGUI_chc_crafting_btn_tooltip")
	for i = 1, #eq.mouseOverList do
		local entry = eq.mouseOverList[i]
		if entry.object == eq.craftingBtn then
			entry.displayString = tip
			return
		end
	end
end

Events.OnGameStart.Add(function()
	-- delay one tick so ISEquippedItem.instance exists
	local done = false
	local function tryPatch()
		if done then return end
		if ISEquippedItem.instance then
			CHC_menu.patchCraftingButtonTooltip()
			done = true
			Events.OnTick.Remove(tryPatch)
		end
	end
	Events.OnTick.Add(tryPatch)
end)
-- endregion

Events.OnFillInventoryObjectContextMenu.Add(CHC_menu.doCraftHelperMenu)
Events.OnCustomUIKey.Add(CHC_menu.onPressKey)
