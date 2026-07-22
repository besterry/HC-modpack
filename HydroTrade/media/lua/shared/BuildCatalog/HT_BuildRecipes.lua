-- Hierarchical catalog data:
-- Section (Строительство) -> Group (Стены) -> Entry (стиль / каркас) -> Variants

HT_BuildRecipes = HT_BuildRecipes or {}
HT_BuildRecipes.list = {}
HT_BuildRecipes.byGroup = {}

HT_BuildRecipes.sections = {
	{
		id = "Build",
		icon = "media/ui/BuildCatalog/CategoryIcon/Carpentry.png",
		groups = {
			{ id = "Walls", icon = "media/ui/BuildCatalog/CategoryIcon/Walls.png" },
			{ id = "Doors", icon = "media/ui/BuildCatalog/CategoryIcon/Doors.png" },
			{ id = "Windows", icon = "media/ui/BuildCatalog/CategoryIcon/Windows.png" },
			{ id = "Floors", icon = "media/ui/BuildCatalog/CategoryIcon/Floors.png" },
			{ id = "Roofs", icon = "media/ui/BuildCatalog/CategoryIcon/Masonry.png" },
			{ id = "Fences", icon = "media/ui/BuildCatalog/CategoryIcon/Fences.png" },
			{ id = "Stairs", icon = "media/ui/BuildCatalog/CategoryIcon/Stairs.png" },
			{ id = "Furniture", icon = "media/ui/BuildCatalog/CategoryIcon/Furniture.png" },
			{ id = "Containers", icon = "media/ui/BuildCatalog/CategoryIcon/Packing.png" },
		},
	},
	{
		id = "Metal",
		icon = "media/ui/BuildCatalog/CategoryIcon/Welding.png",
		groups = {
			{ id = "Walls", icon = "media/ui/BuildCatalog/CategoryIcon/Walls.png" },
			{ id = "Fences", icon = "media/ui/BuildCatalog/CategoryIcon/Fences.png" },
			{ id = "Containers", icon = "media/ui/BuildCatalog/CategoryIcon/Packing.png" },
			{ id = "Doors", icon = "media/ui/BuildCatalog/CategoryIcon/Doors.png" },
			{ id = "Roofs", icon = "media/ui/BuildCatalog/CategoryIcon/Masonry.png" },
		},
	},
	{
		id = "Survival",
		icon = "media/ui/BuildCatalog/CategoryIcon/Outdoors.png",
		groups = {
			{ id = "Survival", icon = "media/ui/BuildCatalog/CategoryIcon/Outdoors.png" },
			{ id = "Lights", icon = "media/ui/BuildCatalog/CategoryIcon/Electrical.png" },
			{ id = "Decoration", icon = "media/ui/BuildCatalog/CategoryIcon/Miscellaneous.png" },
		},
	},
	{
		id = "Stations",
		icon = "media/ui/BuildCatalog/CategoryIcon/Assembly.png",
		groups = {
			{ id = "Stations", icon = "media/ui/BuildCatalog/CategoryIcon/Assembly.png" },
		},
	},
}

HT_BuildRecipes.add = function(recipe)
	if not recipe or not recipe.id then
		return
	end
	table.insert(HT_BuildRecipes.list, recipe)
	local key = (recipe.section or "?") .. "/" .. (recipe.group or "?")
	if not HT_BuildRecipes.byGroup[key] then
		HT_BuildRecipes.byGroup[key] = {}
	end
	table.insert(HT_BuildRecipes.byGroup[key], recipe)
end

HT_BuildRecipes.getSection = function(sectionId)
	for _, s in ipairs(HT_BuildRecipes.sections) do
		if s.id == sectionId then
			return s
		end
	end
	return nil
end

HT_BuildRecipes.getDisplayName = function(entry)
	if not entry then
		return "?"
	end
	if entry.name and entry.name ~= "" then
		return entry.name
	end
	if entry.nameKey then
		local t = getText(entry.nameKey)
		if t and t ~= entry.nameKey then
			return t
		end
	end
	if entry.labelKey then
		local t = getText(entry.labelKey)
		if t and t ~= entry.labelKey then
			return t
		end
	end
	return entry.id or "?"
end

HT_BuildRecipes.getActive = function(recipe, variantIndex)
	if recipe and recipe.variants and #recipe.variants > 0 then
		return recipe.variants[variantIndex or 1] or recipe.variants[1]
	end
	return recipe
end

local function countItem(playerObj, fullType)
	if not playerObj then
		return 0
	end
	local inv = playerObj:getInventory()
	local n = inv:getCountTypeRecurse(fullType)
	if fullType == "Base.Nails" then
		n = n + inv:getCountTypeRecurse("Base.NailsBox") * 100
	end
	return n
end

local function countUses(playerObj, fullType)
	if not playerObj or not fullType then
		return 0
	end
	local inv = playerObj:getInventory()
	local total = 0
	local list = inv:getAllTypeRecurse(fullType)
	if not list then
		return countItem(playerObj, fullType)
	end
	for i = 0, list:size() - 1 do
		local item = list:get(i)
		if item then
			if item.getDrainableUsesInt then
				total = total + item:getDrainableUsesInt()
			elseif item.IsDrainable and item:IsDrainable() and item.getUsedDelta and item.getUseDelta then
				local useDelta = item:getUseDelta()
				if useDelta and useDelta > 0 then
					total = total + math.floor((item:getUsedDelta() / useDelta) + 0.001)
				else
					total = total + 1
				end
			else
				total = total + 1
			end
		end
	end
	return total
end

local function hasTool(playerObj, toolName)
	if not playerObj then
		return false
	end
	local inv = playerObj:getInventory()
	local function notBroken(item)
		return not item:isBroken()
	end
	if toolName == "Hammer" then
		return inv:getFirstTagEvalRecurse("Hammer", notBroken) ~= nil
	end
	if toolName == "Screwdriver" then
		return inv:getFirstTagEvalRecurse("Screwdriver", notBroken) ~= nil
			or inv:containsTypeEvalRecurse("Base.Screwdriver", notBroken)
	end
	if toolName == "Saw" then
		return inv:getFirstTagEvalRecurse("Saw", notBroken) ~= nil
			or inv:containsTypeEvalRecurse("Base.Saw", notBroken)
	end
	if toolName == "BlowTorch" then
		return inv:containsTypeEvalRecurse("Base.BlowTorch", notBroken)
	end
	if toolName == "WeldingMask" then
		return inv:containsTypeRecurse("Base.WeldingMask")
			or inv:getFirstTagRecurse("WeldingMask") ~= nil
	end
	if toolName == "Shovel" then
		return inv:getFirstTagEvalRecurse("DigPlow", notBroken) ~= nil
			or inv:containsTypeEvalRecurse("Base.Shovel", notBroken)
	end
	if toolName == "HandShovel" then
		return inv:containsTypeEvalRecurse("Base.HandShovel", notBroken)
			or inv:containsTypeEvalRecurse("farming.HandShovel", notBroken)
			or inv:containsTypeEvalRecurse("Base.Trowel", notBroken)
	end
	local full = toolName
	if not string.find(toolName, ".", 1, true) then
		full = "Base." .. toolName
	end
	return inv:containsTypeRecurse(full) or inv:containsTypeRecurse(toolName)
end

HT_BuildRecipes.countItem = countItem
HT_BuildRecipes.countUses = countUses
HT_BuildRecipes.hasTool = hasTool

HT_BuildRecipes.getToolFullType = function(toolName)
	if not toolName or toolName == "" then
		return nil
	end
	if string.find(toolName, ".", 1, true) then
		return toolName
	end
	local map = {
		Hammer = "Base.Hammer",
		Screwdriver = "Base.Screwdriver",
		Saw = "Base.Saw",
		Shovel = "Base.Shovel",
		HandShovel = "farming.HandShovel",
		BlowTorch = "Base.BlowTorch",
		WeldingMask = "Base.WeldingMask",
	}
	return map[toolName] or ("Base." .. toolName)
end

HT_BuildRecipes.getToolLabel = function(toolName)
	if not toolName then
		return "?"
	end
	local key = "IGUI_HT_BuildCatalog_Tool_" .. toolName
	local t = nil
	if getTextOrNull then
		t = getTextOrNull(key)
	elseif getText then
		t = getText(key)
		if t == key then
			t = nil
		end
	end
	if t and t ~= "" and t ~= key then
		return t
	end
	local full = toolName
	if not string.find(toolName, ".", 1, true) then
		full = "Base." .. toolName
	end
	if getItemNameFromFullType then
		local itemName = getItemNameFromFullType(full)
		if itemName and itemName ~= "" and itemName ~= full then
			return itemName
		end
	end
	return toolName
end

HT_BuildRecipes.evaluate = function(recipe, playerObj, variantIndex)
	local active = HT_BuildRecipes.getActive(recipe, variantIndex)
	local ok = true
	local lines = {}
	if not playerObj or not active then
		return false, lines
	end
	if ISBuildMenu and ISBuildMenu.cheat then
		return true, lines
	end
	if active.needs then
		for _, need in ipairs(active.needs) do
			local have = countItem(playerObj, need.item)
			local good = have >= need.count
			if not good then
				ok = false
			end
			table.insert(lines, {
				kind = "item",
				item = need.item,
				have = have,
				need = need.count,
				ok = good,
			})
		end
	end
	if active.uses then
		for _, use in ipairs(active.uses) do
			local have = countUses(playerObj, use.item)
			local good = have >= use.count
			if not good then
				ok = false
			end
			table.insert(lines, {
				kind = "use",
				item = use.item,
				have = have,
				need = use.count,
				ok = good,
			})
		end
	end
	if active.skills then
		for perkId, level in pairs(active.skills) do
			local perk = Perks.FromString(perkId)
			local have = playerObj:getPerkLevel(perk)
			local good = have >= level
			if not good then
				ok = false
			end
			table.insert(lines, {
				kind = "skill",
				perkId = perkId,
				have = have,
				need = level,
				ok = good,
			})
		end
	end
	if active.tools then
		for _, tool in ipairs(active.tools) do
			local good = hasTool(playerObj, tool)
			if not good then
				ok = false
			end
			table.insert(lines, { kind = "tool", tool = tool, ok = good })
		end
	end
	return ok, lines
end

HT_BuildRecipes.startBuild = function(recipe, playerNum, variantIndex)
	local active = HT_BuildRecipes.getActive(recipe, variantIndex)
	local createFn = nil
	if active and active.create then
		createFn = active.create
	elseif recipe and recipe.create then
		createFn = recipe.create
	end
	if not createFn then
		return
	end
	HT_BuildRecipes._pendingCreate = {
		fn = createFn,
		playerNum = playerNum,
		active = active,
	}
end

HT_BuildRecipes._onTickPending = function()
	local pending = HT_BuildRecipes._pendingCreate
	if not pending then
		return
	end
	if isMouseButtonDown and isMouseButtonDown(0) then
		return
	end
	HT_BuildRecipes._pendingCreate = nil
	if pending.fn then
		if HT_BuildFactory and HT_BuildFactory.runCreate then
			HT_BuildFactory.runCreate(pending.playerNum, pending.active, pending.fn)
		else
			pending.fn(pending.playerNum)
		end
	end
end

if not HT_BuildRecipes._tickHooked then
	HT_BuildRecipes._tickHooked = true
	Events.OnTick.Add(HT_BuildRecipes._onTickPending)
end

HT_BuildRecipes.getEntries = function(sectionId, groupId, searchText)
	local key = (sectionId or "?") .. "/" .. (groupId or "?")
	local source = HT_BuildRecipes.byGroup[key] or {}
	local out = {}
	local q = searchText and string.lower(searchText) or ""
	for _, recipe in ipairs(source) do
		if not recipe.hidden then
			local name = HT_BuildRecipes.getDisplayName(recipe)
			if q == "" or string.find(string.lower(name), q, 1, true) then
				table.insert(out, recipe)
			end
		end
	end
	table.sort(out, function(a, b)
		local oa = a.sort or 100
		local ob = b.sort or 100
		if oa ~= ob then
			return oa < ob
		end
		return HT_BuildRecipes.getDisplayName(a) < HT_BuildRecipes.getDisplayName(b)
	end)
	return out
end

HT_BuildRecipes.init = function()
	HT_BuildRecipes.list = {}
	HT_BuildRecipes.byGroup = {}
	HT_BuildRecipes._pendingCreate = nil
	if HT_BuildContent and HT_BuildContent.register then
		HT_BuildContent.register()
	end
	if HT_BuildBalance and HT_BuildBalance.applyAll then
		HT_BuildBalance.applyAll()
	end
end
