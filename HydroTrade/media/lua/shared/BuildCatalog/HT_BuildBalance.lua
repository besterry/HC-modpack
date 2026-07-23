-- Single place to rebalance catalog recipes after import.
-- Content files keep sprites/create; costs live here.
-- Policy: wood = cheap plank/nails; glass/masonry/metal = HC + welding tiers.

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

local function pn(planks, nails)
	return needs("Base.Plank", planks, "Base.Nails", nails)
end

local function weldUses(rods, torch)
	return {
		n("Base.WeldingRods", rods),
		n("Base.BlowTorch", torch),
	}
end

-- Tunable economy tiers (edit numbers here).
HT_BuildBalance.Tiers = {
	wood_frame = { needs = pn(2, 2), skills = { Woodwork = 2 }, tools = H },
	wood_wall = { needs = pn(3, 3), skills = { Woodwork = 2 }, tools = H },
	wood_door_frame = { needs = pn(4, 4), skills = { Woodwork = 2 }, tools = H },
	wood_window_frame = { needs = pn(3, 3), skills = { Woodwork = 2 }, tools = H },
	wood_door = {
		needs = needs("Base.Plank", 4, "Base.Nails", 4, "Base.Doorknob", 1, "Base.Hinge", 2),
		skills = { Woodwork = 3 },
		tools = H,
	},
	wood_double_door = {
		needs = needs("Base.Plank", 10, "Base.Nails", 10, "Base.Doorknob", 2, "Base.Hinge", 4),
		skills = { Woodwork = 6 },
		tools = H,
	},
	wood_floor = { needs = pn(1, 1), skills = { Woodwork = 1 }, tools = H },
	wood_roof = { needs = pn(2, 2), skills = { Woodwork = 2 }, tools = H },
	wood_fence = { needs = pn(2, 3), skills = { Woodwork = 2 }, tools = H },
	wood_stairs = { needs = pn(12, 12), skills = { Woodwork = 6 }, tools = H },
	wood_furn_s = { needs = pn(4, 3), skills = { Woodwork = 3 }, tools = H },
	wood_furn_m = { needs = pn(5, 4), skills = { Woodwork = 3 }, tools = H },
	wood_furn_l = { needs = pn(6, 4), skills = { Woodwork = 4 }, tools = H },
	wood_bed = {
		needs = needs("Base.Plank", 6, "Base.Nails", 4, "Base.Mattress", 1),
		skills = { Woodwork = 4 },
		tools = H,
	},
	wood_couch = {
		needs = needs("Base.Plank", 6, "Base.Nails", 4, "Base.Sheet", 1),
		skills = { Woodwork = 4 },
		tools = H,
	},
	wood_crate = { needs = pn(3, 3), skills = { Woodwork = 3 }, tools = H },
	wood_shelf = { needs = pn(5, 5), skills = { Woodwork = 3 }, tools = H },
	wood_dresser = {
		needs = needs("Base.Plank", 4, "Base.Nails", 4, "Base.Drawer", 1),
		skills = { Woodwork = 4 },
		tools = H,
	},
	wood_bar = { needs = pn(5, 4), skills = { Woodwork = 4 }, tools = H },
	low_door_frame = { needs = pn(2, 2), skills = { Woodwork = 2 }, tools = H },
	garage = {
		needs = needs(
			"Base.Plank", 8, "Base.Nails", 8, "Base.Doorknob", 2,
			"Base.Hinge", 4, "Base.Screws", 8, "Base.SmallSheetMetal", 2
		),
		skills = { Woodwork = 6 },
		tools = HS,
	},
	deco_s = { needs = pn(1, 2), skills = { Woodwork = 1 }, tools = H },
	deco_paper = {
		needs = needs("Base.SheetPaper2", 1, "Base.Nails", 2),
		skills = { Woodwork = 0 },
		tools = H,
	},
	flower = {
		needs = needs("Base.Plank", 1, "Base.Twigs", 2, "Base.Nails", 1),
		skills = { Woodwork = 1 },
		tools = H,
	},
	-- Metal
	metal_stairs = {
		needs = needs("Base.SheetMetal", 8, "Base.Screws", 12),
		skills = { MetalWelding = 5, Woodwork = 3 },
		tools = { "Hammer", "Screwdriver", "BlowTorch", "WeldingMask" },
		uses = weldUses(4, 8),
		xp = { MetalWelding = 15 },
	},
	metal_fence_s = {
		needs = needs("Base.SheetMetal", 2, "Base.Screws", 4),
		skills = { MetalWelding = 3 },
		tools = TWH,
		uses = weldUses(2, 5),
		xp = { MetalWelding = 10 },
	},
	metal_fence_hi = {
		needs = needs("Base.Wire", 4, "Base.SmallSheetMetal", 4, "Base.ScrapMetal", 8),
		skills = { MetalWelding = 4 },
		tools = TWH,
		uses = weldUses(4, 10),
		xp = { MetalWelding = 20, Woodwork = 10 },
	},
	metal_locker = {
		needs = needs("Base.SheetMetal", 3, "Base.Screws", 6, "Base.Hinge", 2),
		skills = { MetalWelding = 4, Woodwork = 2 },
		tools = { "Screwdriver", "BlowTorch", "WeldingMask" },
		uses = weldUses(3, 6),
		xp = { MetalWelding = 12 },
	},
	metal_sign = {
		needs = needs("Base.MetalBar", 2, "Base.SmallSheetMetal", 1),
		skills = { MetalWelding = 2 },
		tools = TWH,
		uses = weldUses(2, 4),
		xp = { MetalWelding = 8 },
	},
	metal_trash = {
		needs = needs("Base.SheetMetal", 2, "Base.Screws", 3),
		skills = { MetalWelding = 2 },
		tools = { "Screwdriver", "BlowTorch", "WeldingMask" },
		uses = weldUses(1, 3),
		xp = { MetalWelding = 5 },
	},
	metal_floor = {
		needs = needs("Base.SheetMetal", 1, "Base.Screws", 2),
		skills = { MetalWelding = 2 },
		tools = { "Hammer", "Screwdriver", "BlowTorch", "WeldingMask" },
		uses = weldUses(1, 3),
		xp = { MetalWelding = 5 },
	},
	-- MetalWelding (ISBlacksmith) soft scrap + torch uses
	mw_light = { uses = weldUses(1, 3), xp = { MetalWelding = 5 } },
	mw_mid = { uses = weldUses(2, 5), xp = { MetalWelding = 10 } },
	mw_heavy = { uses = weldUses(3, 8), xp = { MetalWelding = 15 } },
}

local function applyTier(recipe, tier)
	if not tier then
		return
	end
	if tier.needs then
		recipe.needs = tier.needs
	end
	if tier.skills then
		recipe.skills = tier.skills
	end
	if tier.tools then
		recipe.tools = tier.tools
	end
	if tier.uses then
		recipe.uses = tier.uses
	end
	if tier.xp then
		recipe.xp = tier.xp
	end
end

local function setWoodStyleVariants(recipe, T)
	if not recipe.variants then
		return
	end
	for _, v in ipairs(recipe.variants) do
		local rk = v.roleKey or ""
		if string.find(rk, "WindowFrame", 1, true) then
			applyTier(v, T.wood_window_frame)
		elseif string.find(rk, "DoorFrame", 1, true) then
			applyTier(v, T.wood_door_frame)
		else
			applyTier(v, T.wood_wall)
		end
	end
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

-- Direct overrides by recipe id (highest priority; skips economy if needs/hidden set).
HT_BuildBalance.byRecipe = {
	["hc_steel_stairs"] = { hidden = true },
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
	-- Vanilla wood anchors (close to ISBuildMenu)
	["v_wall_frame"] = { needs = pn(2, 2), skills = { Woodwork = 2 }, tools = H },
	["v_pillar"] = { needs = pn(2, 3), skills = { Woodwork = 2 }, tools = H },
	["v_door"] = {
		needs = needs("Base.Plank", 4, "Base.Nails", 4, "Base.Doorknob", 1, "Base.Hinge", 2),
		skills = { Woodwork = 3 },
		tools = H,
	},
	["v_stairs"] = { needs = pn(12, 12), skills = { Woodwork = 6 }, tools = H },
	["v_floor"] = { needs = pn(1, 1), skills = { Woodwork = 1 }, tools = H },
	-- Soften MW scrap spikes
	["mw_locker_b"] = {
		needs = needs("Base.MetalPipe", 6, "Base.SmallSheetMetal", 4, "Base.Hinge", 2),
		skills = { MetalWelding = 8 },
		tools = TW,
		uses = weldUses(4, 10),
		xp = { MetalWelding = 18 },
	},
	["mw_fence_big"] = {
		needs = needs("Base.MetalPipe", 4, "Base.ScrapMetal", 2, "Base.SmallSheetMetal", 2),
		skills = { MetalWelding = 6 },
		tools = TW,
		uses = weldUses(3, 8),
		xp = { MetalWelding = 15 },
	},
	["mw_wired_big"] = {
		needs = needs("Base.MetalPipe", 3, "Base.ScrapMetal", 2, "Base.Wire", 3),
		skills = { MetalWelding = 5 },
		tools = TW,
		uses = weldUses(2, 6),
		xp = { MetalWelding = 12 },
	},
}

-- Special rules (material / hide). Set _done to skip generic economy.
HT_BuildBalance.rules = {
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_glass_wall_", 1, true)
				and r.sprite == "walls_commercial_01_96"
		end,
		apply = function(r)
			r.hidden = true
			r._done = true
		end,
	},
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
			r._done = true
		end,
	},
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
			r._done = true
		end,
	},
	{
		match = function(r)
			return r.id and string.find(r.id, "mb_glass_wall_", 1, true)
		end,
		apply = function(r)
			r.needs = needs("Base.Plank", 2, "Base.Screws", 4, "Hydrocraft.HCGlasspanelarge", 1)
			r.tools = HS
			r.skills = { Woodwork = 4 }
			r._done = true
		end,
	},
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
			r._done = true
		end,
	},
	{
		match = function(r)
			local k = r.nameKey or ""
			return string.find(k, "Frame_Glass", 1, true)
				or string.find(k, "Glass_Door", 1, true)
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
			r._done = true
		end,
	},
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
			r.uses = weldUses(2, 5)
			r.xp = { MetalWelding = 10 }
			r._done = true
		end,
	},
	{
		match = function(r)
			local k = r.nameKey or ""
			return k == "ContextMenu_BrownCinder_BlockFence"
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
			r._done = true
		end,
	},
	{
		match = function(r)
			return r.id and (
				string.find(r.id, "mb_floor_", 1, true)
				or string.find(r.id, "mb_roof_", 1, true)
			)
		end,
		apply = function(r)
			local T = HT_BuildBalance.Tiers
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
				applyTier(r, T.metal_floor)
			elseif kind == "tile" then
				r.needs = needs("Base.Stone", 2, "Hydrocraft.HCMortar", 1)
				r.tools = TROWEL
				r.skills = { Woodwork = 2 }
			elseif kind == "roof" then
				applyTier(r, T.wood_roof)
			else
				applyTier(r, T.wood_floor)
			end
			r._done = true
		end,
	},
}

-- Generic economy for everything not marked _done.
HT_BuildBalance.applyEconomy = function(recipe)
	local T = HT_BuildBalance.Tiers
	local id = recipe.id or ""
	local k = recipe.nameKey or ""

	-- Wood wall styles
	if string.find(id, "mb_style_", 1, true) then
		applyTier(recipe, T.wood_wall)
		setWoodStyleVariants(recipe, T)
		return
	end

	-- Metal stairs (MB)
	if string.find(id, "mb_stairs_", 1, true) and hasNeed(recipe, "Base.SheetMetal") then
		recipe.section = "Metal"
		recipe.group = "Stairs"
		applyTier(recipe, T.metal_stairs)
		return
	end
	if string.find(id, "mb_stairs_", 1, true) then
		applyTier(recipe, T.wood_stairs)
		return
	end

	-- High metal fence
	if string.find(id, "mb_hmfence_", 1, true) then
		recipe.section = "Metal"
		recipe.group = "Fences"
		applyTier(recipe, T.metal_fence_hi)
		return
	end

	-- Green / sheet metal fence
	if k == "ContextMenu_GreenMetal_Fence"
		or (string.find(id, "mb_fence_", 1, true) and hasNeed(recipe, "Base.SheetMetal") and not hasNeed(recipe, "Base.Plank"))
	then
		recipe.section = "Metal"
		recipe.group = "Fences"
		applyTier(recipe, T.metal_fence_s)
		return
	end

	-- Wood fences
	if string.find(id, "mb_fence_", 1, true) or id == "mb_fence_gray_rail2" then
		applyTier(recipe, T.wood_fence)
		return
	end

	-- Metal signs / lockers / barrel / trash metal
	if string.find(id, "mb_msign_", 1, true) then
		recipe.section = "Metal"
		recipe.group = "Fences"
		applyTier(recipe, T.metal_sign)
		return
	end
	if string.find(id, "mb_locker_", 1, true) or id == "mb_metal_barrel" then
		recipe.section = "Metal"
		recipe.group = "Containers"
		applyTier(recipe, T.metal_locker)
		return
	end
	if string.find(id, "mb_trash_m_", 1, true) or id == "mb_post_box" then
		recipe.section = "Metal"
		recipe.group = "Containers"
		applyTier(recipe, T.metal_trash)
		return
	end

	-- Doors
	if id == "mb_low_door_frame" then
		applyTier(recipe, T.low_door_frame)
		return
	end
	if string.find(id, "mb_garage_", 1, true) then
		applyTier(recipe, T.garage)
		return
	end
	if string.find(id, "mb_door_", 1, true) then
		if string.find(k, "Double", 1, true) then
			applyTier(recipe, T.wood_double_door)
		else
			applyTier(recipe, T.wood_door)
		end
		return
	end

	-- Furniture
	if string.find(id, "mb_bed_", 1, true) then
		applyTier(recipe, T.wood_bed)
		return
	end
	if string.find(id, "mb_couch_", 1, true) then
		applyTier(recipe, T.wood_couch)
		return
	end
	if string.find(id, "mb_ltable_", 1, true) then
		applyTier(recipe, T.wood_furn_l)
		return
	end
	if string.find(id, "mb_stable_", 1, true) or string.find(id, "mb_seat_", 1, true) then
		applyTier(recipe, T.wood_furn_s)
		return
	end

	-- Containers (wood)
	if string.find(id, "mb_dresser_", 1, true) or string.find(id, "mb_ofurn_", 1, true) then
		applyTier(recipe, T.wood_dresser)
		return
	end
	if string.find(id, "mb_shelf_", 1, true) then
		applyTier(recipe, T.wood_shelf)
		return
	end
	if string.find(id, "mb_bar_", 1, true) then
		applyTier(recipe, T.wood_bar)
		return
	end
	if string.find(id, "mb_crate_", 1, true)
		or string.find(id, "mb_cardboard_", 1, true)
		or string.find(id, "mb_trash_w_", 1, true)
		or id == "mb_recycle_bin"
	then
		applyTier(recipe, T.wood_crate)
		return
	end
	if string.find(id, "mb_trash_s_", 1, true) or id == "mb_brick_pallet" then
		applyTier(recipe, T.wood_furn_m)
		return
	end

	-- Decoration
	if string.find(id, "mb_wdeco_", 1, true) then
		applyTier(recipe, T.deco_paper)
		return
	end
	if string.find(id, "mb_flower", 1, true) then
		applyTier(recipe, T.flower)
		return
	end
	if string.find(id, "mb_road_", 1, true) or string.find(id, "mb_sign_", 1, true) then
		applyTier(recipe, T.deco_s)
		return
	end

	-- Vanilla leftovers by group (only if still plank-cheap outliers)
	if string.find(id, "v_", 1, true) then
		local g = recipe.group or ""
		if g == "Furniture" then
			if id == "v_bed" then
				applyTier(recipe, T.wood_bed)
			elseif hasNeed(recipe, "Base.Drawer") then
				applyTier(recipe, T.wood_dresser)
			elseif id == "v_shelf" or id == "v_shelf_d" then
				applyTier(recipe, T.wood_shelf)
			else
				applyTier(recipe, T.wood_furn_m)
			end
			return
		end
		if g == "Containers" and (id == "v_crate" or string.find(id, "barrel", 1, true)) then
			if id == "v_crate" then
				applyTier(recipe, T.wood_crate)
			end
			return
		end
		if g == "Fences" and hasNeed(recipe, "Base.Plank") then
			applyTier(recipe, T.wood_fence)
			return
		end
		if g == "Doors" and id == "v_door_frame" then
			applyTier(recipe, T.wood_door_frame)
			return
		end
		if g == "Windows" and id == "v_window_frame" then
			applyTier(recipe, T.wood_window_frame)
			return
		end
		if g == "Walls" and recipe.kind == "frame" then
			applyTier(recipe, T.wood_frame)
			return
		end
	end

	-- MetalWelding: add torch uses by weight; keep vanilla material lists unless overridden
	if string.find(id, "mw_", 1, true) then
		local sk = (recipe.skills and recipe.skills.MetalWelding) or 0
		if sk >= 7 then
			applyTier(recipe, T.mw_heavy)
		elseif sk >= 4 then
			applyTier(recipe, T.mw_mid)
		else
			applyTier(recipe, T.mw_light)
		end
		recipe.tools = recipe.tools or TW
		return
	end
end

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
	recipe._done = nil
	local oldSection, oldGroup = recipe.section, recipe.group
	local ov = HT_BuildBalance.byRecipe[recipe.id]
	local skipEconomy = false
	if ov then
		copyFields(recipe, ov)
		if recipe.variants and ov.variants then
			recipe.variants = ov.variants
		end
		if ov.needs or ov.hidden then
			skipEconomy = true
			recipe._done = true
		end
	end
	if not recipe.hidden and not recipe._done then
		for _, rule in ipairs(HT_BuildBalance.rules) do
			if rule.match(recipe) then
				rule.apply(recipe)
				break
			end
		end
	end
	if recipe.hidden then
		hideRecipe(recipe)
		return
	end
	if not skipEconomy and not recipe._done then
		HT_BuildBalance.applyEconomy(recipe)
	end
	-- HC glass: byRecipe sets section/tools but not needs; keep content needs
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
