-- Single place to rebalance catalog recipes after import.
-- Edit byRecipe[id] or rules{}. Content files stay as source sprites/create.
-- Policy: wood stays cheap (plank/nails); glass/masonry/metal lean on HC + welding.

HT_BuildBalance = HT_BuildBalance or {}

local TW = { "BlowTorch", "WeldingMask" }
local TWH = { "BlowTorch", "WeldingMask", "Hammer" }
local HS = { "Hammer", "Screwdriver" }
local H = { "Hammer" }
local TROWEL = { "Hydrocraft.HCMasontrowel" }

local function n(item, count)
	return { item = item, count = count }
end

local function needs(...)
	local out = {}
	local args = { ... }
	for i = 1, #args, 2 do
		table.insert(out, n(args[i], args[i + 1]))
	end
	return out
end

local function hasNeed(recipe, item)
	for _, x in ipairs(recipe.needs or {}) do
		if x.item == item then
			return true
		end
	end
	return false
end

local function removeFromGroup(recipe, section, group)
	local key = (section or "?") .. "/" .. (group or "?")
	local list = HT_BuildRecipes.byGroup[key]
	if not list then
		return
	end
	for i = #list, 1, -1 do
		if list[i] == recipe then
			table.remove(list, i)
		end
	end
end

local function hideRecipe(recipe)
	recipe.hidden = true
	removeFromGroup(recipe, recipe.section, recipe.group)
end

local function setVariantNeeds(recipe, wallNeeds, frameNeeds, doorNeeds)
	if not recipe.variants then
		return
	end
	for _, v in ipairs(recipe.variants) do
		local rk = v.roleKey or ""
		if string.find(rk, "WindowFrame", 1, true) then
			v.needs = frameNeeds
			v.tools = TROWEL
			v.skills = { Woodwork = 5 }
		elseif string.find(rk, "DoorFrame", 1, true) then
			v.needs = doorNeeds
			v.tools = TROWEL
			v.skills = { Woodwork = 5 }
		else
			v.needs = wallNeeds
			v.tools = TROWEL
			v.skills = { Woodwork = 5 }
		end
	end
end

local function floorTemplate(sprite)
	local spr = sprite or ""
	if string.find(spr, "roofs_02_", 1, true) then
		return "glass"
	end
	if string.find(spr, "industry_", 1, true)
		or string.find(spr, "location_sewer_", 1, true)
	then
		return "metal"
	end
	if string.find(spr, "floors_exterior_street_", 1, true)
		or string.find(spr, "floors_exterior_tilesandstone_", 1, true)
		or string.find(spr, "floors_interior_tilesandwood_", 1, true)
		or string.find(spr, "location_shop_mall_", 1, true)
		or string.find(spr, "location_restaurant_diner_", 1, true)
		or string.find(spr, "location_restaurant_pie_", 1, true)
		or string.find(spr, "location_restaurant_pizzawhirled_", 1, true)
		or string.find(spr, "location_restaurant_spiffos_", 1, true)
		or string.find(spr, "location_restaurant_bar_", 1, true)
		or string.find(spr, "location_hospitality_sunstarmotel_02_", 1, true)
	then
		return "tile"
	end
	return "wood"
end

-- Direct overrides by recipe id (highest priority).
HT_BuildBalance.byRecipe = {
	-- Same sprites as MB metal stairs (fixtures_stairs_01_3..); keep MB SheetMetal recipe.
	["hc_steel_stairs"] = { hidden = true },
	-- Soften absurd HC brick stone dump; keep HC bricks/mortar.
	["hc_brick_wall"] = {
		needs = {
			n("Hydrocraft.HCGreybrick", 15),
			n("Hydrocraft.HCRedbrick", 20),
			n("Hydrocraft.HCMortar", 4),
		},
		skills = { Woodwork = 6 },
		tools = TROWEL,
	},
	["hc_brick_win"] = {
		needs = {
			n("Hydrocraft.HCGreybrick", 12),
			n("Hydrocraft.HCRedbrick", 16),
			n("Hydrocraft.HCGlasspane", 1),
			n("Hydrocraft.HCMortar", 4),
		},
		skills = { Woodwork = 6 },
		tools = TROWEL,
	},
	["hc_glass_wall"] = {
		section = "Metal",
		group = "Walls",
		tools = TW,
		skills = { MetalWelding = 3 },
		uses = { n("Base.BlowTorch", 5) },
		xp = { MetalWelding = 10 },
	},
	["hc_glass_roof"] = {
		section = "Metal",
		group = "Roofs",
		tools = TW,
		skills = { MetalWelding = 3 },
		uses = { n("Base.BlowTorch", 5) },
		xp = { MetalWelding = 10 },
	},
}

-- Pattern rules when byRecipe has no entry.
HT_BuildBalance.rules = {
	-- MB glass wall twin of HC (walls_commercial_01_96)
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_glass_wall_", 1, true)
				and r.sprite == "walls_commercial_01_96"
		end,
		apply = function(r)
			r.hidden = true
		end,
	},
	-- MB glass floor = HC glass roof tile pair (roofs_02_54/55); keep HC
	{
		match = function(r)
			if not (r.id and string.find(r.id, "mb_floor_", 1, true)) then
				return false
			end
			local spr = r.sprite or ""
			return spr == "roofs_02_54" or spr == "roofs_02_55"
		end,
		apply = function(r)
			r.hidden = true
		end,
	},
	-- MB masonry wall styles (were plank fakes)
	{
		match = function(r)
			return r.id == "mb_style_bcinder"
				or r.id == "mb_style_gcinder"
				or r.id == "mb_style_wcinder"
				or r.id == "mb_style_rbrick"
		end,
		apply = function(r)
			local wallN, frameN, doorN
			if r.id == "mb_style_rbrick" then
				wallN = needs("Hydrocraft.HCRedbrick", 12, "Hydrocraft.HCGreybrick", 4, "Hydrocraft.HCMortar", 2)
				frameN = needs("Hydrocraft.HCRedbrick", 6, "Hydrocraft.HCMortar", 1)
				doorN = needs("Hydrocraft.HCRedbrick", 8, "Hydrocraft.HCMortar", 1)
			else
				wallN = needs("Hydrocraft.HCGreybrick", 12, "Hydrocraft.HCRedbrick", 4, "Hydrocraft.HCMortar", 2)
				frameN = needs("Hydrocraft.HCGreybrick", 6, "Hydrocraft.HCMortar", 1)
				doorN = needs("Hydrocraft.HCGreybrick", 8, "Hydrocraft.HCMortar", 1)
			end
			r.tools = TROWEL
			r.skills = { Woodwork = 5 }
			r.needs = wallN
			setVariantNeeds(r, wallN, frameN, doorN)
		end,
	},
	-- MB glass walls (remaining)
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_glass_wall_", 1, true)
		end,
		apply = function(r)
			r.needs = needs("Base.Plank", 2, "Base.Screws", 4, "Hydrocraft.HCGlasspanelarge", 1)
			r.tools = HS
			r.skills = { Woodwork = 4 }
		end,
	},
	-- MB windows + door-menu glass windows
	{
		match = function(r)
			return r.id and (
				string.find(r.id, "mb_window_", 1, true)
				or string.find(r.id, "mb_door_gwin_", 1, true)
			)
		end,
		apply = function(r)
			r.needs = needs("Base.Plank", 2, "Base.Screws", 4, "Hydrocraft.HCGlasspane", 1)
			r.tools = HS
			r.skills = { Woodwork = 3 }
		end,
	},
	-- Glass frame doors / glass doors
	{
		match = function(r)
			local k = r.nameKey or ""
			return string.find(k, "Frame_Glass", 1, true)
				or string.find(k, "Glass_Door", 1, true)
				or string.find(k, "Frame_Glass_Door", 1, true)
		end,
		apply = function(r)
			r.needs = needs(
				"Base.Plank", 2,
				"Base.Screws", 4,
				"Base.Doorknob", 1,
				"Base.Hinge", 2,
				"Hydrocraft.HCGlasspane", 1
			)
			r.tools = HS
			r.skills = { Woodwork = 4 }
		end,
	},
	-- Metal low door
	{
		match = function(r)
			return r.nameKey == "ContextMenu_Metal_LowDoor"
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Doors"
			r.needs = needs(
				"Base.SheetMetal", 2,
				"Base.Screws", 6,
				"Base.Hinge", 2,
				"Base.Doorknob", 1
			)
			r.tools = { "Hammer", "Screwdriver", "BlowTorch", "WeldingMask" }
			r.skills = { MetalWelding = 3, Woodwork = 2 }
			r.uses = {
				n("Base.WeldingRods", 2),
				n("Base.BlowTorch", 5),
			}
			r.xp = { MetalWelding = 10 }
		end,
	},
	-- Masonry / brick fences (fake plank costs)
	{
		match = function(r)
			local k = r.nameKey or ""
			return string.find(k, "Cinder_BlockFence", 1, true)
				or string.find(k, "CinderBlock", 1, true) and string.find(k, "Fence", 1, true)
				or k == "ContextMenu_BrownCinder_BlockFence"
				or k == "ContextMenu_GrayCinder_BlockFence"
				or k == "ContextMenu_WhiteCinder_BlockFence"
				or k == "ContextMenu_RedBrick_Fence"
				or k == "ContextMenu_RoughBrick_Fence"
		end,
		apply = function(r)
			local k = r.nameKey or ""
			if string.find(k, "RedBrick", 1, true) or string.find(k, "RoughBrick", 1, true) then
				r.needs = needs("Hydrocraft.HCRedbrick", 6, "Hydrocraft.HCMortar", 1)
			else
				r.needs = needs("Hydrocraft.HCGreybrick", 6, "Hydrocraft.HCMortar", 1)
			end
			r.tools = TROWEL
			r.skills = { Woodwork = 5 }
		end,
	},
	-- Floors / roofs by sprite material
	{
		match = function(r)
			return r.id and (
				string.find(r.id, "mb_floor_", 1, true)
				or string.find(r.id, "mb_roof_", 1, true)
			)
		end,
		apply = function(r)
			local kind = floorTemplate(r.sprite)
			if string.find(r.id, "mb_roof_", 1, true) and kind ~= "glass" then
				kind = "roof"
			end
			if kind == "glass" then
				r.needs = needs("Base.Screws", 2, "Hydrocraft.HCGlasspane", 1)
				r.tools = HS
				r.skills = { Woodwork = 3 }
			elseif kind == "metal" then
				r.section = "Metal"
				r.group = "Floors"
				r.needs = needs("Base.SheetMetal", 1, "Base.Screws", 2)
				r.tools = { "Hammer", "Screwdriver", "BlowTorch", "WeldingMask" }
				r.skills = { MetalWelding = 2 }
				r.uses = {
					n("Base.WeldingRods", 1),
					n("Base.BlowTorch", 3),
				}
				r.xp = { MetalWelding = 5 }
			elseif kind == "tile" then
				r.needs = needs("Base.Stone", 2, "Hydrocraft.HCMortar", 1)
				r.tools = TROWEL
				r.skills = { Woodwork = 2 }
			elseif kind == "roof" then
				r.needs = needs("Base.Plank", 2, "Base.Nails", 2)
				r.tools = H
				r.skills = { Woodwork = 2 }
			else
				-- wood / carpet: keep cheap
				r.needs = needs("Base.Plank", 1, "Base.Nails", 1)
				r.tools = H
				r.skills = { Woodwork = 1 }
			end
		end,
	},
	-- MB metal stairs -> welding (keep SheetMetal recipe)
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_stairs_", 1, true) and r.needs
		end,
		test = function(r)
			return hasNeed(r, "Base.SheetMetal")
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Stairs"
			r.tools = { "Hammer", "Screwdriver", "BlowTorch", "WeldingMask" }
			r.skills = { MetalWelding = 5, Woodwork = 3 }
			r.uses = r.uses or {
				n("Base.WeldingRods", 4),
				n("Base.BlowTorch", 8),
			}
			r.xp = r.xp or { MetalWelding = 15 }
		end,
	},
	-- MB green metal fence
	{
		match = function(r)
			return r.nameKey == "ContextMenu_GreenMetal_Fence"
				or (r.id and string.find(r.id, "mb_fence_", 1, true) and r.needs)
		end,
		test = function(r)
			if r.nameKey == "ContextMenu_GreenMetal_Fence" then
				return true
			end
			return hasNeed(r, "Base.SheetMetal") and not hasNeed(r, "Base.Plank")
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Fences"
			r.tools = TWH
			r.skills = { MetalWelding = 3 }
			r.uses = {
				n("Base.WeldingRods", 2),
				n("Base.BlowTorch", 5),
			}
			r.xp = { MetalWelding = 10 }
		end,
	},
	-- Metal signs
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_msign_", 1, true)
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Fences"
			r.tools = TWH
			r.skills = { MetalWelding = 2 }
			if r.needs then
				local kept = {}
				for _, x in ipairs(r.needs) do
					if x.item ~= "Base.WeldingRods" then
						table.insert(kept, x)
					end
				end
				r.needs = kept
			end
			r.uses = {
				n("Base.WeldingRods", 4),
				n("Base.BlowTorch", 8),
			}
			r.xp = { MetalWelding = 8 }
		end,
	},
	-- Metal lockers / metal containers from MB
	{
		match = function(r)
			return r.id and (
				string.find(r.id, "mb_locker_", 1, true)
				or r.id == "mb_metal_barrel"
			)
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Containers"
			r.tools = { "Screwdriver", "BlowTorch", "WeldingMask" }
			r.skills = { MetalWelding = 4, Woodwork = 2 }
			r.uses = r.uses or {
				n("Base.WeldingRods", 3),
				n("Base.BlowTorch", 6),
			}
			r.xp = r.xp or { MetalWelding = 12 }
		end,
	},
	-- High metal fences
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_hmfence_", 1, true)
		end,
		apply = function(r)
			r.section = "Metal"
			r.group = "Fences"
			r.tools = TWH
			r.skills = { MetalWelding = 4 }
			r.uses = {
				n("Base.WeldingRods", 4),
				n("Base.BlowTorch", 10),
			}
			r.xp = { MetalWelding = 20, Woodwork = 10 }
		end,
	},
}

local function copyFields(dst, src)
	if not src then
		return
	end
	for k, v in pairs(src) do
		dst[k] = v
	end
end

local function reindexGroup(recipe, oldSection, oldGroup)
	if recipe.hidden then
		removeFromGroup(recipe, oldSection, oldGroup)
		removeFromGroup(recipe, recipe.section, recipe.group)
		return
	end
	local oldKey = (oldSection or "?") .. "/" .. (oldGroup or "?")
	local newKey = (recipe.section or "?") .. "/" .. (recipe.group or "?")
	if oldKey == newKey then
		return
	end
	removeFromGroup(recipe, oldSection, oldGroup)
	if not HT_BuildRecipes.byGroup[newKey] then
		HT_BuildRecipes.byGroup[newKey] = {}
	end
	table.insert(HT_BuildRecipes.byGroup[newKey], recipe)
end

HT_BuildBalance.applyOne = function(recipe)
	if not recipe or not recipe.id then
		return
	end
	local oldSection, oldGroup = recipe.section, recipe.group
	local ov = HT_BuildBalance.byRecipe[recipe.id]
	if ov then
		copyFields(recipe, ov)
		if recipe.variants and ov.variants then
			recipe.variants = ov.variants
		end
	else
		for _, rule in ipairs(HT_BuildBalance.rules) do
			local ok = false
			if rule.test then
				ok = rule.match(recipe) and rule.test(recipe)
			else
				ok = rule.match(recipe)
			end
			if ok then
				rule.apply(recipe)
				break
			end
		end
	end
	if recipe.hidden then
		hideRecipe(recipe)
		return
	end
	reindexGroup(recipe, oldSection, oldGroup)
end

HT_BuildBalance.applyAll = function()
	if not HT_BuildRecipes or not HT_BuildRecipes.list then
		return
	end
	local metal = HT_BuildRecipes.getSection("Metal")
	if metal then
		local hasStairs, hasFloors = false, false
		for _, g in ipairs(metal.groups or {}) do
			if g.id == "Stairs" then
				hasStairs = true
			end
			if g.id == "Floors" then
				hasFloors = true
			end
		end
		if not hasStairs then
			table.insert(metal.groups, {
				id = "Stairs",
				icon = "media/ui/BuildCatalog/CategoryIcon/Stairs.png",
			})
		end
		if not hasFloors then
			table.insert(metal.groups, {
				id = "Floors",
				icon = "media/ui/BuildCatalog/CategoryIcon/Floors.png",
			})
		end
	end
	for _, recipe in ipairs(HT_BuildRecipes.list) do
		HT_BuildBalance.applyOne(recipe)
	end
end
