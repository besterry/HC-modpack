-- MoreBuilds catalog entries (original materials / onBuild* signatures).

HT_BuildContent_MB = HT_BuildContent_MB or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

local function mb()
	return getMoreBuildInstance()
end

local function sk(key, fallback)
	local M = mb()
	if M and M.skillLevel and M.skillLevel[key] ~= nil then
		return M.skillLevel[key]
	end
	return fallback
end

local function disp(sprite, fallback)
	local M = mb()
	if M and M.getMoveableDisplayName then
		local n = M.getMoveableDisplayName(sprite)
		if n and n ~= "" then
			return n
		end
	end
	return fallback or sprite
end

local function need(...)
	local out = {}
	local args = { ... }
	for i = 1, #args, 2 do
		table.insert(out, { item = args[i], count = args[i + 1] })
	end
	return out
end

local H = { "Hammer" }
local HS = { "Hammer", "Screwdriver" }
local HSS = { "Hammer", "Screwdriver", "Saw" }
local SS = { "Screwdriver", "Saw" }
local HShS = { "Hammer", "Shovel", "Saw" }
local HHS = { "Hammer", "HandShovel" }
local SD = { "Screwdriver" }
local HB = { "Hammer", "BlowTorch" }

HT_BuildContent_MB._regStyles = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- A) Style packs: 7 wood + 4 masonry
	local styles = {
		{
			id = "mb_style_lbrown", nameKey = "ContextMenu_Light_BrownWood", masonry = false,
			wall = { sprite = "location_restaurant_pileocrepe_01_0", northSprite = "location_restaurant_pileocrepe_01_1", corner = "location_restaurant_pileocrepe_01_3" },
			windowFrame = { sprite = "location_restaurant_pileocrepe_01_8", northSprite = "location_restaurant_pileocrepe_01_9", corner = "location_restaurant_pileocrepe_01_3" },
			doorFrame = { sprite = "location_restaurant_pileocrepe_01_10", northSprite = "location_restaurant_pileocrepe_01_11", corner = "location_restaurant_pileocrepe_01_3" },
		},
		{
			id = "mb_style_dbrown", nameKey = "ContextMenu_Dark_BrownWood", masonry = false,
			wall = { sprite = "location_shop_bargNclothes_01_24", northSprite = "location_shop_bargNclothes_01_25", corner = "location_shop_bargNclothes_01_27" },
			windowFrame = { sprite = "location_shop_bargNclothes_01_32", northSprite = "location_shop_bargNclothes_01_33", corner = "location_shop_bargNclothes_01_27" },
			doorFrame = { sprite = "location_shop_bargNclothes_01_34", northSprite = "location_shop_bargNclothes_01_35", corner = "location_shop_bargNclothes_01_27" },
		},
		{
			id = "mb_style_gplaster", nameKey = "ContextMenu_Gray_Plaster", masonry = false,
			wall = { sprite = "walls_garage_02_16", northSprite = "walls_garage_02_17", corner = "walls_garage_02_19" },
			windowFrame = { sprite = "walls_garage_02_24", northSprite = "walls_garage_02_25", corner = "walls_garage_02_19" },
			doorFrame = { sprite = "walls_garage_02_26", northSprite = "walls_garage_02_27", corner = "walls_garage_02_19" },
		},
		{
			id = "mb_style_gwood", nameKey = "ContextMenu_Gray_Wood", masonry = false,
			wall = { sprite = "walls_exterior_wooden_01_28", northSprite = "walls_exterior_wooden_01_29", corner = "walls_exterior_wooden_01_31" },
			windowFrame = { sprite = "walls_exterior_wooden_01_36", northSprite = "walls_exterior_wooden_01_37", corner = "walls_exterior_wooden_01_31" },
			doorFrame = { sprite = "walls_exterior_wooden_01_38", northSprite = "walls_exterior_wooden_01_39", corner = "walls_exterior_wooden_01_31" },
		},
		{
			id = "mb_style_rbarn", nameKey = "ContextMenu_Red_Barnwood", masonry = false,
			wall = { sprite = "walls_exterior_wooden_01_0", northSprite = "walls_exterior_wooden_01_1", corner = "walls_exterior_wooden_01_3" },
			windowFrame = { sprite = "walls_exterior_wooden_01_8", northSprite = "walls_exterior_wooden_01_9", corner = "walls_exterior_wooden_01_3" },
			doorFrame = { sprite = "walls_exterior_wooden_01_10", northSprite = "walls_exterior_wooden_01_11", corner = "walls_exterior_wooden_01_3" },
		},
		{
			id = "mb_style_wplaster", nameKey = "ContextMenu_White_Plaster", masonry = false,
			wall = { sprite = "location_shop_mall_01_0", northSprite = "location_shop_mall_01_1", corner = "location_shop_mall_01_3" },
			windowFrame = { sprite = "location_shop_mall_01_8", northSprite = "location_shop_mall_01_9", corner = "location_shop_mall_01_3" },
			doorFrame = { sprite = "location_shop_mall_01_10", northSprite = "location_shop_mall_01_11", corner = "location_shop_mall_01_3" },
		},
		{
			id = "mb_style_wwood", nameKey = "ContextMenu_White_Wood", masonry = false,
			wall = { sprite = "walls_exterior_wooden_02_0", northSprite = "walls_exterior_wooden_02_1", corner = "walls_exterior_wooden_02_3" },
			windowFrame = { sprite = "walls_exterior_wooden_02_8", northSprite = "walls_exterior_wooden_02_9", corner = "walls_exterior_wooden_02_3" },
			doorFrame = { sprite = "walls_exterior_wooden_02_10", northSprite = "walls_exterior_wooden_02_11", corner = "walls_exterior_wooden_02_3" },
		},
		{
			id = "mb_style_bcinder", nameKey = "ContextMenu_Brown_Cinder_Block", masonry = true,
			wall = { sprite = "walls_commercial_03_0", northSprite = "walls_commercial_03_1", corner = "walls_commercial_03_3" },
			windowFrame = { sprite = "walls_commercial_03_8", northSprite = "walls_commercial_03_9", corner = "walls_commercial_03_3" },
			doorFrame = { sprite = "walls_commercial_03_10", northSprite = "walls_commercial_03_11", corner = "walls_commercial_03_3" },
		},
		{
			id = "mb_style_gcinder", nameKey = "ContextMenu_Gray_Cinder_Block", masonry = true,
			wall = { sprite = "walls_commercial_03_32", northSprite = "walls_commercial_03_33", corner = "walls_commercial_03_35" },
			windowFrame = { sprite = "walls_commercial_03_40", northSprite = "walls_commercial_03_41", corner = "walls_commercial_03_35" },
			doorFrame = { sprite = "walls_commercial_03_42", northSprite = "walls_commercial_03_43", corner = "walls_commercial_03_35" },
		},
		{
			id = "mb_style_wcinder", nameKey = "ContextMenu_White_CinderBlock", masonry = true,
			wall = { sprite = "walls_commercial_01_48", northSprite = "walls_commercial_01_49", corner = "walls_commercial_01_51" },
			windowFrame = { sprite = "walls_commercial_01_56", northSprite = "walls_commercial_01_57", corner = "walls_commercial_01_51" },
			doorFrame = { sprite = "walls_commercial_01_58", northSprite = "walls_commercial_01_59", corner = "walls_commercial_01_51" },
		},
		{
			id = "mb_style_rbrick", nameKey = "ContextMenu_RedBrick_Wall", masonry = true,
			wall = { sprite = "walls_exterior_house_01_4", northSprite = "walls_exterior_house_01_5", corner = "walls_exterior_house_01_7" },
			windowFrame = { sprite = "walls_exterior_house_01_12", northSprite = "walls_exterior_house_01_13", corner = "walls_exterior_house_01_7" },
			doorFrame = { sprite = "walls_exterior_house_01_14", northSprite = "walls_exterior_house_01_15", corner = "walls_exterior_house_01_7" },
		},
	}

	for si, style in ipairs(styles) do
		local st = style
		local wallSkill = st.masonry and sk("stoneArchitecture", 5) or sk("wallObject", 2)
		local wallNeeds = st.masonry and need("Base.Plank", 6, "Base.Nails", 3) or need("Base.Plank", 3, "Base.Nails", 3)
		local dfNeeds = st.masonry and need("Base.Plank", 2, "Base.Nails", 3) or need("Base.Plank", 4, "Base.Nails", 4)
		local wallFn = st.masonry and "onBuildStoneWall" or "onBuildWoodenWall"
		local dfFn = st.masonry and "onBuildStoneDoorFrame" or "onBuildWoodenDoorFrame"
		local wfFn = st.masonry and "onBuildStoneWindowFrame" or "onBuildWoodenWindowFrame"
		local wSpr = st.wall
		local wfSpr = st.windowFrame
		local dfSpr = st.doorFrame
		add({
			id = st.id, section = "Build", group = "Walls", kind = "style", sort = sortWall + si,
			nameKey = st.nameKey, sprite = wSpr.sprite, showHp = true, hp = st.masonry and 600 or 250,
			variants = {
				{
					roleKey = "IGUI_HT_BuildCatalog_Role_Wall", sprite = wSpr.sprite,
					needs = wallNeeds, skills = { Woodwork = wallSkill }, tools = H,
					create = function(p)
						local name = getText(st.nameKey)
						mb()[wallFn](nil, wSpr, p, name)
					end,
				},
				{
					roleKey = "IGUI_HT_BuildCatalog_Role_WindowFrame", sprite = wfSpr.sprite,
					needs = need("Base.Plank", 4, "Base.Nails", 4), skills = { Woodwork = wallSkill }, tools = H,
					create = function(p)
						local name = getText(st.nameKey)
						mb()[wfFn](nil, wfSpr, p, name)
					end,
				},
				{
					roleKey = "IGUI_HT_BuildCatalog_Role_DoorFrame", sprite = dfSpr.sprite,
					needs = dfNeeds, skills = { Woodwork = wallSkill }, tools = H,
					create = function(p)
						local name = getText(st.nameKey)
						mb()[dfFn](nil, dfSpr, p, name)
					end,
				},
			},
		})
	end

end

HT_BuildContent_MB._regDoors = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- B) Doors from _gen_doors + glass + garage + low frame
	local doors = {
		{ "fixtures_doors_02_0", "fixtures_doors_02_1", "fixtures_doors_02_2", "fixtures_doors_02_3", "ContextMenu_Blue_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_4", "fixtures_doors_01_5", "fixtures_doors_01_6", "fixtures_doors_01_7", "ContextMenu_Brown_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_12", "fixtures_doors_01_13", "fixtures_doors_01_14", "fixtures_doors_01_15", "ContextMenu_DarkBrown_WoodenDoor", "onBuildWoodenDoor" },
		{ "location_community_church_small_01_64", "location_community_church_small_01_65", "location_community_church_small_01_66", "location_community_church_small_01_67", "ContextMenu_FancyBrown_Door", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_0", "fixtures_doors_01_1", "fixtures_doors_01_2", "fixtures_doors_01_3", "ContextMenu_White_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_02_16", "fixtures_doors_02_17", "fixtures_doors_02_18", "fixtures_doors_02_19", "ContextMenu_Brown_PanelDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_02_24", "fixtures_doors_02_25", "fixtures_doors_02_26", "fixtures_doors_02_27", "ContextMenu_Gray_PanelDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_02_20", "fixtures_doors_02_21", "fixtures_doors_02_22", "fixtures_doors_02_23", "ContextMenu_White_PanelDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_02_12", "fixtures_doors_02_13", "fixtures_doors_02_14", "fixtures_doors_02_15", "ContextMenu_Black_IndustrialDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_24", "fixtures_doors_01_25", "fixtures_doors_01_26", "fixtures_doors_01_27", "ContextMenu_Blue_IndustrialDoor", "onBuildWoodenDoor" },
		{ "location_restaurant_pizzawhirled_01_60", "location_restaurant_pizzawhirled_01_61", "location_restaurant_pizzawhirled_01_62", "location_restaurant_pizzawhirled_01_63", "ContextMenu_Green_IndustrialDoor", "onBuildWoodenDoor" },
		{ "location_restaurant_pileocrepe_01_52", "location_restaurant_pileocrepe_01_53", "location_restaurant_pileocrepe_01_54", "location_restaurant_pileocrepe_01_55", "ContextMenu_Orange_IndustrialDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_02_8", "fixtures_doors_02_9", "fixtures_doors_02_10", "fixtures_doors_02_11", "ContextMenu_Red_IndustrialDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_60", "fixtures_doors_01_61", "fixtures_doors_01_62", "fixtures_doors_01_63", "ContextMenu_White_IndustrialDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_56", "fixtures_doors_01_57", "fixtures_doors_01_58", "fixtures_doors_01_59", "ContextMenu_Beige_ExteriorDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_52", "fixtures_doors_01_53", "fixtures_doors_01_54", "fixtures_doors_01_55", "ContextMenu_Gray_ExteriorDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_64", "fixtures_doors_01_65", "fixtures_doors_01_66", "fixtures_doors_01_67", "ContextMenu_Orange_ExteriorDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_28", "fixtures_doors_01_29", "fixtures_doors_01_30", "fixtures_doors_01_31", "ContextMenu_Rough_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_fences_01_12", "fixtures_doors_fences_01_13", "fixtures_doors_fences_01_14", "fixtures_doors_fences_01_15", "ContextMenu_Wood_FortressDoor", "onBuildWoodenDoor" },
		{ "location_restaurant_spiffos_01_52", "location_restaurant_spiffos_01_53", "location_restaurant_spiffos_01_54", "location_restaurant_spiffos_01_55", "ContextMenu_Spiffos_Door", "onBuildWoodenDoor" },
		{ "fixtures_bathroom_02_32", "fixtures_bathroom_02_33", "fixtures_bathroom_02_34", "fixtures_bathroom_02_35", "ContextMenu_Outhouse_Door", "onBuildWoodenDoor" },
		{ "fixtures_doors_01_32", "fixtures_doors_01_33", "fixtures_doors_01_34", "fixtures_doors_01_35", "ContextMenu_Safety_Door", "onBuildWoodenDoor" },
		{ "fixtures_doors_fences_01_4", "fixtures_doors_fences_01_5", "fixtures_doors_fences_01_6", "fixtures_doors_fences_01_7", "ContextMenu_Low_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_fences_01_8", "fixtures_doors_fences_01_9", "fixtures_doors_fences_01_10", "fixtures_doors_fences_01_11", "ContextMenu_White_Low_WoodenDoor", "onBuildWoodenDoor" },
		{ "fixtures_doors_fences_01_16", "fixtures_doors_fences_01_17", "fixtures_doors_fences_01_18", "fixtures_doors_fences_01_19", "ContextMenu_Metal_LowDoor", "onBuildLowdoorframe" },
		{ "fixtures_doors_01_36", "fixtures_doors_01_37", "fixtures_doors_01_38", "fixtures_doors_01_39", "ContextMenu_Red_Frame_Glass", "onBuildWoodenDoor", metal = true },
		{ "fixtures_doors_01_40", "fixtures_doors_01_41", "fixtures_doors_01_42", "fixtures_doors_01_43", "ContextMenu_Black_Frame_Glass", "onBuildWoodenDoor", metal = true },
		{ "fixtures_doors_01_48", "fixtures_doors_01_49", "fixtures_doors_01_50", "fixtures_doors_01_51", "ContextMenu_Black_Frame_Glass2", "onBuildWoodenDoor", metal = true },
		{ "fixtures_doors_01_116", "fixtures_doors_01_117", "fixtures_doors_01_118", "fixtures_doors_01_119", "ContextMenu_White_Frame_Glass_Door", "onBuildGlassDoor", metal = true },
		{ "fixtures_doors_01_108", "fixtures_doors_01_109", "fixtures_doors_01_110", "fixtures_doors_01_111", "ContextMenu_Brown_Frame_Glass_Door", "onBuildGlassDoor", metal = true },
	}

	local doorNeeds = need("Base.Plank", 4, "Base.Nails", 4, "Base.Doorknob", 1, "Base.Hinge", 2)
	local metalLowNeeds = need("Base.Wire", 4, "Base.Nails", 4, "Base.Hinge", 1, "Base.Doorknob", 2)
	local doorSkill = sk("doorObject", 3)

	for di, d in ipairs(doors) do
		local entry = d
		local spr = {
			sprite = entry[1], northSprite = entry[2],
			openSprite = entry[3], openNorthSprite = entry[4],
		}
		local fn = entry[6]
		local isMetalLow = (fn == "onBuildLowdoorframe")
		local toMetal = entry.metal or isMetalLow
		add({
			id = "mb_door_" .. di, section = toMetal and "Metal" or "Build", group = "Doors", kind = "item", sort = sortDoor + di,
			nameKey = entry[5], sprite = entry[1], showHp = true, hp = isMetalLow and 1000 or 200,
			needs = isMetalLow and metalLowNeeds or doorNeeds,
			skills = { Woodwork = doorSkill }, tools = H,
			create = function(p)
				local name = getText(entry[5])
				mb()[fn](nil, spr, p, name)
			end,
		})
	end

	-- Glass windows from door menu (onBuildWindowWall)
	local glassWins = {
		{ "fixtures_doors_01_112", "fixtures_doors_01_113", "ContextMenu_White_Frame_Glass_Window" },
		{ "fixtures_doors_01_104", "fixtures_doors_01_105", "ContextMenu_Brown_Frame_Glass_Window" },
	}
	for gi, gw in ipairs(glassWins) do
		local entry = gw
		local spr = { sprite = entry[1], northSprite = entry[2] }
		add({
			id = "mb_door_gwin_" .. gi, section = "Metal", group = "Doors", kind = "item", sort = sortDoor + 80 + gi,
			nameKey = entry[3], sprite = entry[1],
			needs = need("Base.Plank", 4, "Base.Screws", 4),
			skills = { Woodwork = doorSkill }, tools = H,
			create = function(p)
				local name = getText(entry[3])
				mb().onBuildWindowWall(nil, spr, p, name)
			end,
		})
	end

	-- Low door frame
	do
		local spr = { sprite = "fixtures_doors_frames_01_0", northSprite = "fixtures_doors_frames_01_1", corner = "" }
		add({
			id = "mb_low_door_frame", section = "Build", group = "Doors", kind = "frame", sort = sortDoor + 1,
			nameKey = "ContextMenu_Low_DoorFrame", sprite = spr.sprite,
			needs = need("Base.Plank", 1, "Base.Nails", 1),
			skills = { Woodwork = sk("wallObject", 2) }, tools = H,
			create = function(p)
				mb().onBuildLowDoorFrame(nil, spr, p, getText("ContextMenu_Low_DoorFrame"))
			end,
		})
	end

	-- Garage doors
	local garages = {
		{ "ContextMenu_White_Garage_Door", "walls_garage_01_", 0, 1 },
		{ "ContextMenu_Green_Garage_Door", "walls_garage_01_", 16, 17 },
		{ "ContextMenu_Grey_Garage_Door", "walls_garage_01_", 48, 49 },
		{ "ContextMenu_Rolling_Garage_Door", "walls_garage_02_", 0, 1 },
		{ "ContextMenu_Red_Window_Garage_Door", "walls_garage_02_", 32, 33 },
		{ "ContextMenu_Gray_Window_Garage_Door", "walls_garage_02_", 48, 49 },
	}
	local garageNeeds = need(
		"Base.Plank", 8, "Base.Nails", 8, "Base.Doorknob", 2,
		"Base.Hinge", 4, "Base.Screws", 8, "Base.SmallSheetMetal", 4
	)
	for gi, g in ipairs(garages) do
		local entry = g
		local prefix = entry[2]
		local idx = entry[3]
		add({
			id = "mb_garage_" .. gi, section = "Build", group = "Doors", kind = "item", sort = sortDoor + 90 + gi,
			nameKey = entry[1], sprite = prefix .. entry[4], showHp = true, hp = 1000,
			needs = garageNeeds, skills = { Woodwork = sk("garageDoorObject", 6) }, tools = HSS,
			create = function(p)
				mb().onBuildGarageDoor(nil, { sprite = prefix }, idx, p)
			end,
		})
	end

end

HT_BuildContent_MB._regGlassWalls = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- C) Glass walls
	if M.getWindowsWallData then
		local gwData = M.getWindowsWallData()
		for k, list in pairs(gwData) do
			local idx = k
			local spr = { sprite = list[1], northSprite = list[2], corner = list[3] }
			add({
				id = "mb_glass_wall_" .. tostring(idx), section = "Metal", group = "Walls", kind = "item",
				sort = sortWall + 100 + (tonumber(idx) or 0),
				name = getText("ContextMenu_Glass_Wall") .. tostring(idx), sprite = list[1],
				showHp = true, hp = 150,
				needs = need("Base.Plank", 4, "Base.Screws", 4),
				skills = { Woodwork = sk("stoneArchitecture", 5) }, tools = H,
				create = function(p)
					local name = getText("ContextMenu_Glass_Wall") .. tostring(idx)
					mb().onBuildWindowWall(nil, spr, p, name)
				end,
			})
		end
	end

end

HT_BuildContent_MB._regWindows = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- D) Windows
	if M.getWindowsData then
		for wi, list in ipairs(M.getWindowsData()) do
			local entry = list
			local spr = { sprite = entry[1], northSprite = entry[2] }
			add({
				id = "mb_window_" .. wi, section = "Build", group = "Windows", kind = "item", sort = sortWin + wi,
				name = disp(entry[1], entry[1]), sprite = entry[1],
				needs = need("Base.Plank", 4, "Base.Screws", 4),
				skills = { Woodwork = sk("windowsObject", 2) }, tools = SS,
				create = function(p)
					local name = disp(entry[1], entry[1])
					mb().onBuildWindow(nil, spr, p, name)
				end,
			})
		end
	end

end

HT_BuildContent_MB._regFloorsRoofs = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- E) Floors only (roofs are style packs in HT_BuildContent_Roofs)
	if M.getFloorsData then
		local roofKey = getText("ContextMenu_Roofing_Styles")
		local fi = 0
		for subName, subData in pairs(M.getFloorsData()) do
			if subName ~= roofKey then
				for _, list in pairs(subData) do
					local entry = list
					local spr = { sprite = entry[1], northSprite = entry[2] }
					local name = disp(entry[1], entry[3])
					fi = fi + 1
					local localFi = fi
					add({
						id = "mb_floor_" .. localFi, section = "Build", group = "Floors", kind = "item", sort = sortFloor + localFi,
						name = name, sprite = entry[1],
						needs = need("Base.Plank", 1, "Base.Nails", 1),
						skills = { Woodwork = sk("floorObject", 1) }, tools = H,
						create = function(p)
							mb().onBuildTwoSpriteFloor(nil, spr, p, name)
						end,
					})
				end
			end
		end
	end

end

HT_BuildContent_MB._regStairs = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- F) Stairs (7)
	local stairs = {
		{
			key = "ContextMenu_LightBrown_Stairs", metal = false,
			upToLeft01 = "fixtures_stairs_01_64", upToLeft02 = "fixtures_stairs_01_65", upToLeft03 = "fixtures_stairs_01_66",
			upToRight01 = "fixtures_stairs_01_72", upToRight02 = "fixtures_stairs_01_73", upToRight03 = "fixtures_stairs_01_74",
			pillar = "fixtures_stairs_01_70", pillarNorth = "fixtures_stairs_01_70",
		},
		{
			key = "ContextMenu_Brown_Stairs", metal = false,
			upToLeft01 = "fixtures_stairs_01_32", upToLeft02 = "fixtures_stairs_01_33", upToLeft03 = "fixtures_stairs_01_34",
			upToRight01 = "fixtures_stairs_01_40", upToRight02 = "fixtures_stairs_01_41", upToRight03 = "fixtures_stairs_01_42",
			pillar = "fixtures_stairs_01_38", pillarNorth = "fixtures_stairs_01_39",
		},
		{
			key = "ContextMenu_DarkBrown_Stairs", metal = false,
			upToLeft01 = "fixtures_stairs_01_16", upToLeft02 = "fixtures_stairs_01_17", upToLeft03 = "fixtures_stairs_01_18",
			upToRight01 = "fixtures_stairs_01_24", upToRight02 = "fixtures_stairs_01_25", upToRight03 = "fixtures_stairs_01_26",
			pillar = "fixtures_stairs_01_22", pillarNorth = "fixtures_stairs_01_23",
		},
		{
			key = "ContextMenu_WhiteMotel_Stairs", metal = false,
			upToLeft01 = "location_hospitality_sunstarmotel_01_40", upToLeft02 = "location_hospitality_sunstarmotel_01_41", upToLeft03 = "location_hospitality_sunstarmotel_01_42",
			upToRight01 = "location_hospitality_sunstarmotel_01_48", upToRight02 = "location_hospitality_sunstarmotel_01_49", upToRight03 = "location_hospitality_sunstarmotel_01_50",
			pillar = "location_hospitality_sunstarmotel_01_43", pillarNorth = "location_hospitality_sunstarmotel_01_51",
		},
		{
			key = "ContextMenu_WhiteIndustrial_Stairs", metal = false,
			upToLeft01 = "fixtures_stairs_01_48", upToLeft02 = "fixtures_stairs_01_49", upToLeft03 = "fixtures_stairs_01_50",
			upToRight01 = "fixtures_stairs_01_56", upToRight02 = "fixtures_stairs_01_57", upToRight03 = "fixtures_stairs_01_58",
			pillar = "location_hospitality_sunstarmotel_01_43", pillarNorth = "location_hospitality_sunstarmotel_01_51",
		},
		{
			key = "ContextMenu_Yellow_Stairs", metal = false,
			upToLeft01 = "fixtures_stairs_01_19", upToLeft02 = "fixtures_stairs_01_20", upToLeft03 = "fixtures_stairs_01_21",
			upToRight01 = "fixtures_stairs_01_27", upToRight02 = "fixtures_stairs_01_28", upToRight03 = "fixtures_stairs_01_29",
			pillar = "fixtures_stairs_01_30", pillarNorth = "fixtures_stairs_01_31",
		},
		{
			key = "ContextMenu_Metal_Stairs", metal = true,
			upToLeft01 = "fixtures_stairs_01_3", upToLeft02 = "fixtures_stairs_01_4", upToLeft03 = "fixtures_stairs_01_5",
			upToRight01 = "fixtures_stairs_01_11", upToRight02 = "fixtures_stairs_01_12", upToRight03 = "fixtures_stairs_01_13",
			pillar = "fixtures_stairs_01_14", pillarNorth = "fixtures_stairs_01_14",
		},
	}
	for si, st in ipairs(stairs) do
		local entry = st
		local spr = {
			upToLeft01 = entry.upToLeft01, upToLeft02 = entry.upToLeft02, upToLeft03 = entry.upToLeft03,
			upToRight01 = entry.upToRight01, upToRight02 = entry.upToRight02, upToRight03 = entry.upToRight03,
			pillar = entry.pillar, pillarNorth = entry.pillarNorth,
		}
		add({
			id = "mb_stairs_" .. si, section = "Build", group = "Stairs", kind = "item", sort = sortStairs + si,
			nameKey = entry.key, sprite = entry.upToLeft01,
			needs = entry.metal and need("Base.SheetMetal", 10, "Base.Screws", 15) or need("Base.Plank", 15, "Base.Nails", 15),
			skills = { Woodwork = sk("stairsObject", 6) },
			tools = entry.metal and HS or H,
			create = function(p)
				local name = getText(entry.key)
				if entry.metal then
					mb().onBuildMetalStairs(nil, spr, p, name)
				else
					mb().onBuildWoodenStairs(nil, spr, p, name)
				end
			end,
		})
	end

	-- High metal fences (catalog costs; section Metal)
	if M.getHighMetalFenceData then
		local hfNeeds = need("Base.Wire", 4, "Base.SmallSheetMetal", 4, "Base.ScrapMetal", 20)
		local hfUses = {
			{ item = "Base.WeldingRods", count = 4 },
			{ item = "Base.BlowTorch", count = 10 },
		}
		local hfTools = { "BlowTorch", "WeldingMask", "Hammer" }
		for k, list in pairs(M.getHighMetalFenceData()) do
			local idx = k
			local spr = {
				sprite1 = list[1], sprite2 = list[2],
				northSprite1 = list[3], northSprite2 = list[4],
			}
			add({
				id = "mb_hmfence_" .. tostring(idx), section = "Metal", group = "Fences", kind = "item",
				sort = sortFence + 100 + (tonumber(idx) or 0),
				name = getText("ContextMenu_HighMetal_Fence") .. tostring(idx), sprite = list[1],
				showHp = true, hp = 1400,
				needs = hfNeeds,
				uses = hfUses,
				skills = { MetalWelding = 4 },
				tools = hfTools,
				xp = { MetalWelding = 20, Woodwork = 10 },
				create = function(p)
					local name = getText("ContextMenu_HighMetal_Fence") .. tostring(idx)
					mb().onBuildHighMetalFence(nil, spr, p, name)
				end,
			})
		end
	end

end

HT_BuildContent_MB._regFences = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- G) Fences (style pack + extras + green metal)
	local styleFences = {
		{ "ContextMenu_Light_BrownWood_Fence", "location_restaurant_pileocrepe_01_44", "location_restaurant_pileocrepe_01_45", "location_restaurant_pileocrepe_01_47", "wood", sk("wallObject", 2) },
		{ "ContextMenu_GrayFence_WithRail", "walls_garage_02_20", "walls_garage_02_21", "walls_garage_02_23", "wood", sk("wallObject", 2) },
		{ "ContextMenu_Gray_WoodFence", "walls_exterior_wooden_01_60", "walls_exterior_wooden_01_61", "walls_exterior_wooden_01_63", "wood", sk("wallObject", 2) },
		{ "ContextMenu_BrownCinder_BlockFence", "walls_commercial_03_4", "walls_commercial_03_5", "walls_commercial_03_7", "wood", sk("stoneArchitecture", 5) },
		{ "ContextMenu_GrayCinder_BlockFence", "walls_commercial_03_36", "walls_commercial_03_37", "walls_commercial_03_38", "wood", sk("stoneArchitecture", 5) },
		{ "ContextMenu_WhiteCinder_BlockFence", "walls_commercial_01_52", "walls_commercial_01_53", "walls_commercial_01_55", "wood", sk("stoneArchitecture", 5) },
		{ "ContextMenu_RedBrick_Fence", "walls_exterior_house_01_36", "walls_exterior_house_01_37", "walls_exterior_house_01_39", "stone", sk("stoneArchitecture", 5) },
		{ "ContextMenu_WhitePicket_FencePost", "fencing_01_4", "fencing_01_5", "fencing_01_7", "wood", sk("wallObject", 2) },
		{ "ContextMenu_BeigeFence_WithRail", "fixtures_railings_01_112", "fixtures_railings_01_113", "fixtures_railings_01_115", "wood", sk("wallObject", 2) },
		{ "ContextMenu_GrayFence_WithRail", "fixtures_railings_01_116", "fixtures_railings_01_117", "fixtures_railings_01_119", "wood", sk("wallObject", 2), "mb_fence_gray_rail2" },
		{ "ContextMenu_GreenMetal_Fence", "industry_railroad_05_40", "industry_railroad_05_41", "industry_railroad_05_43", "metal", sk("metalArchitecture", 5) },
		{ "ContextMenu_RoughBrick_Fence", "construction_01_0", "construction_01_1", "construction_01_3", "stone", sk("stoneArchitecture", 5) },
	}
	for fi, f in ipairs(styleFences) do
		local entry = f
		local spr = { sprite = entry[2], northSprite = entry[3], corner = entry[4] }
		local kind = entry[5]
		local needsF
		local toolsF = H
		local fn
		if kind == "metal" then
			needsF = need("Base.SheetMetal", 2, "Base.Screws", 3)
			toolsF = SD
			fn = "onBuildMetalFence"
		elseif kind == "stone" then
			needsF = need("Base.Plank", 4, "Base.Nails", 3)
			fn = "onBuildStoneFence"
		else
			needsF = need("Base.Plank", 2, "Base.Nails", 3)
			fn = "onBuildWoodenFence"
		end
		add({
			id = entry[7] or ("mb_fence_" .. fi), section = "Build", group = "Fences", kind = "item", sort = sortFence + fi,
			nameKey = entry[1], sprite = entry[2], showHp = true, hp = kind == "metal" and 1400 or (kind == "stone" and 600 or 100),
			needs = needsF, skills = { Woodwork = entry[6] }, tools = toolsF,
			create = function(p)
				mb()[fn](nil, spr, p, getText(entry[1]))
			end,
		})
	end

end

HT_BuildContent_MB._regFurniture = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- H) Furniture
	if M.getSmallTableData then
		for ti, list in ipairs(M.getSmallTableData()) do
			local entry = list
			local spr = { sprite = entry[1], northSprite = entry[2] }
			add({
				id = "mb_stable_" .. ti, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + ti,
				name = disp(entry[1], entry[3]), sprite = entry[1],
				needs = need("Base.Plank", 5, "Base.Nails", 4),
				skills = { Woodwork = sk("simpleFurniture", 3) }, tools = H,
				create = function(p)
					local name = disp(entry[1], entry[3])
					mb().onBuildSingleTileWoodenTable(nil, spr, p, name)
				end,
			})
		end
	end

	if M.getLargeTableData then
		for ti, list in ipairs(M.getLargeTableData()) do
			local entry = list
			local spr = {
				sprite = entry[1], sprite2 = entry[2],
				northSprite = entry[3], northSprite2 = entry[4],
			}
			add({
				id = "mb_ltable_" .. ti, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + 50 + ti,
				name = disp(entry[1], entry[1]), sprite = entry[1],
				needs = need("Base.Plank", 6, "Base.Nails", 4),
				skills = { Woodwork = sk("complexFurniture", 4) }, tools = H,
				create = function(p)
					local name = disp(entry[1], entry[1])
					mb().onBuildDoubleTileWoodenTable(nil, spr, p, name)
				end,
			})
		end
	end

	if M.getSeatingData then
		local ci = 0
		for _, subData in pairs(M.getSeatingData()) do
			for _, list in pairs(subData) do
				ci = ci + 1
				local entry = list
				local localCi = ci
				local spr = {
					sprite = entry[1], northSprite = entry[2],
					eastSprite = entry[3], southSprite = entry[4],
				}
				add({
					id = "mb_seat_" .. localCi, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + 100 + localCi,
					name = entry[5], sprite = entry[1],
					needs = need("Base.Plank", 5, "Base.Nails", 4),
					skills = { Woodwork = sk("simpleFurniture", 3) }, tools = H,
					create = function(p)
						mb().onBuildWoodenChair(nil, spr, p, entry[5])
					end,
				})
			end
		end
	end

	if M.getCouchesData then
		for ci, list in ipairs(M.getCouchesData()) do
			local entry = list
			local name = entry[9]
			local front = {
				sprite = entry[1], sprite2 = entry[2],
				northSprite = entry[3], northSprite2 = entry[4],
			}
			local back = {
				sprite = entry[5], sprite2 = entry[6],
				northSprite = entry[7], northSprite2 = entry[8],
			}
			local couchNeeds = need("Base.Plank", 6, "Base.Nails", 4, "Base.Sheet", 1)
			add({
				id = "mb_couch_f_" .. ci, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + 200 + ci,
				name = name, sprite = entry[1],
				needs = couchNeeds, skills = { Woodwork = sk("complexFurniture", 4) }, tools = H,
				create = function(p)
					mb().onBuildCouch(nil, front, p, name)
				end,
			})
			add({
				id = "mb_couch_b_" .. ci, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + 220 + ci,
				name = name .. " (B)", sprite = entry[5],
				needs = couchNeeds, skills = { Woodwork = sk("complexFurniture", 4) }, tools = H,
				create = function(p)
					mb().onBuildCouch(nil, back, p, name)
				end,
			})
		end
	end

	if M.getBedData then
		for bi, list in ipairs(M.getBedData()) do
			local entry = list
			local spr = {
				sprite = entry[1], sprite2 = entry[2],
				northSprite = entry[3], northSprite2 = entry[4],
			}
			add({
				id = "mb_bed_" .. bi, section = "Build", group = "Furniture", kind = "item", sort = sortFurn + 250 + bi,
				name = entry[5], sprite = entry[1],
				needs = need("Base.Plank", 6, "Base.Nails", 4, "Base.Mattress", 1),
				skills = { Woodwork = sk("complexFurniture", 4) }, tools = H,
				create = function(p)
					mb().onBuildBed(nil, spr, p, entry[5])
				end,
			})
		end
	end

end

HT_BuildContent_MB._regContainers = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- I) Containers
	if M.getDresserData then
		for di, list in ipairs(M.getDresserData()) do
			local entry = list
			local spr = {
				sprite = entry[1], northSprite = entry[2],
				eastSprite = entry[3], southSprite = entry[4],
			}
			add({
				id = "mb_dresser_" .. di, section = "Build", group = "Containers", kind = "item", sort = sortCont + di,
				name = entry[5], sprite = entry[1], showHp = true, hp = 200,
				containerType = "wardrobe",
				needs = need("Base.Plank", 4, "Base.Nails", 4, "Base.Drawer", 1),
				skills = { Woodwork = sk("advancedContainer", 7) }, tools = H,
				create = function(p)
					mb().onBuildDresser(nil, spr, p, entry[5])
				end,
			})
		end
	end

	if M.getOtherFurnitureData then
		for oi, list in ipairs(M.getOtherFurnitureData()) do
			local entry = list
			local spr = {
				sprite = entry[1], northSprite = entry[2],
				eastSprite = entry[3], southSprite = entry[4],
			}
			add({
				id = "mb_ofurn_" .. oi, section = "Build", group = "Containers", kind = "item", sort = sortCont + 20 + oi,
				name = entry[5], sprite = entry[1], showHp = true, hp = 200,
				containerType = "wardrobe",
				needs = need("Base.Plank", 4, "Base.Nails", 4, "Base.Drawer", 1),
				skills = { Woodwork = sk("advancedContainer", 7) }, tools = H,
				create = function(p)
					mb().onBuildDresser(nil, spr, p, entry[5])
				end,
			})
		end
	end

	if M.getBarElementData then
		local bi = 0
		for _, subData in pairs(M.getBarElementData()) do
			for _, list in pairs(subData) do
				bi = bi + 1
				local entry = list
				local localBi = bi
				local spr = {
					sprite = entry[1], northSprite = entry[2],
					eastSprite = entry[3], southSprite = entry[4],
				}
				add({
					id = "mb_bar_" .. localBi, section = "Build", group = "Containers", kind = "item", sort = sortCont + 40 + localBi,
					name = entry[5], sprite = entry[1], showHp = true, hp = 200,
					containerType = "counter",
					needs = need("Base.Plank", 4, "Base.Nails", 4),
					skills = { Woodwork = sk("advancedContainer", 7) }, tools = H,
					create = function(p)
						mb().onBuildBarElement(nil, spr, p, entry[5])
					end,
				})
			end
		end
	end

	-- Bookshelves
	local shelves = {
		{ "furniture_shelving_01_41", "furniture_shelving_01_40", "furniture_shelving_01_42", "furniture_shelving_01_43" },
		{ "furniture_shelving_01_45", "furniture_shelving_01_44", "furniture_shelving_01_46", "furniture_shelving_01_47" },
	}
	for si, s in ipairs(shelves) do
		local entry = s
		local spr = {
			sprite = entry[1], northSprite = entry[2],
			southSprite = entry[3], eastSprite = entry[4],
		}
		add({
			id = "mb_shelf_" .. si, section = "Build", group = "Containers", kind = "item", sort = sortCont + 80 + si,
			name = disp(entry[1], entry[1]), sprite = entry[1],
			containerType = "shelves",
			needs = need("Base.Plank", 6, "Base.Nails", 6),
			skills = { Woodwork = sk("complexFurniture", 4) }, tools = H,
			create = function(p)
				local name = disp(entry[1], entry[1])
				mb().onBuildBookShelf(nil, spr, p, name)
			end,
		})
	end

	-- Crates
	local crates = {
		{ "ContextMenu_Half_Crate", "location_shop_greenes_01_35", "location_shop_greenes_01_36", nil, nil, "smallcrate", "wood", 3 },
		{ "ContextMenu_Grocery_Box", "location_shop_greenes_01_37", "location_shop_greenes_01_38", nil, nil, "smallbox", "pass", 3 },
		{ "ContextMenu_Outhouse_Box", "fixtures_bathroom_02_24", "fixtures_bathroom_02_25", nil, nil, "bin", "pass", 3 },
		{ "ContextMenu_Theatre_Storage", "location_entertainment_theatre_01_16", "location_entertainment_theatre_01_16", nil, nil, "counter", "wood", 3 },
		{ "ContextMenu_Dog_House", "location_farm_accesories_01_8", "location_farm_accesories_01_9", "location_farm_accesories_01_10", "location_farm_accesories_01_11", "officedrawers", "wood", 3 },
		{ "ContextMenu_ArmyGreen_MilitaryCrate", "morebuild_01_3", "morebuild_01_9", nil, nil, "militarycrate", "wood", 6 },
		{ "ContextMenu_ArmyGray_MilitaryCrate", "morebuild_01_6", "morebuild_01_12", nil, nil, "militarycrate", "wood", 6 },
	}
	for ci, c in ipairs(crates) do
		local entry = c
		local spr = {
			sprite = entry[2], northSprite = entry[3],
			eastSprite = entry[4], southSprite = entry[5],
		}
		local icon = entry[6]
		local mode = entry[7]
		local skillLvl = entry[8]
		add({
			id = "mb_crate_" .. ci, section = "Build", group = "Containers", kind = "item", sort = sortCont + 100 + ci,
			nameKey = entry[1], sprite = entry[2], showHp = true, hp = 200,
			containerType = icon,
			needs = need("Base.Plank", 2, "Base.Nails", 2),
			skills = { Woodwork = skillLvl }, tools = H,
			create = function(p)
				local name = getText(entry[1])
				if mode == "pass" then
					mb().onBuildPassThroughContainer(nil, spr, p, name, icon)
				else
					mb().onBuildWoodenContainer(nil, spr, p, name, icon)
				end
			end,
		})
	end

	if M.getCardboardBoxesData then
		for ci, list in ipairs(M.getCardboardBoxesData()) do
			local entry = list
			local spr = { sprite = entry[1], northSprite = entry[2] }
			add({
				id = "mb_cardboard_" .. ci, section = "Build", group = "Containers", kind = "item", sort = sortCont + 120 + ci,
				name = entry[3], sprite = entry[1], showHp = true, hp = 200,
				containerType = entry[4],
				needs = need("Base.Plank", 2, "Base.Nails", 2),
				skills = { Woodwork = sk("simpleContainer", 3) }, tools = H,
				create = function(p)
					mb().onBuildWoodenContainer(nil, spr, p, entry[3], entry[4])
				end,
			})
		end
	end

	-- Metal lockers
	local lockers = {
		{ "ContextMenu_Gun_Locker", "furniture_storage_02_9", "furniture_storage_02_8", "furniture_storage_02_11", "furniture_storage_02_10", "vendingsnack" },
		{ "ContextMenu_MetalLocker_Menu", "furniture_storage_02_1", "furniture_storage_02_0", "furniture_storage_02_3", "furniture_storage_02_2", "vendingsnack" },
		{ "ContextMenu_Lock_Boxes", "location_business_bank_01_43", "location_business_bank_01_42", "location_business_bank_01_45", "location_business_bank_01_44", "vendingsnack" },
		{ "ContextMenu_Blue_Lockers", "furniture_storage_02_4", "furniture_storage_02_5", "furniture_storage_02_6", "furniture_storage_02_7", "filingcabinet" },
		{ "ContextMenu_Yellow_Lockers", "furniture_storage_02_12", "furniture_storage_02_13", "furniture_storage_02_14", "furniture_storage_02_15", "filingcabinet" },
		{ "ContextMenu_Military_Lockers", "location_military_generic_01_23", "location_military_generic_01_22", "location_military_generic_01_30", "location_military_generic_01_31", "filingcabinet" },
	}
	local lockerNeeds = need("Base.SheetMetal", 2, "Base.Screws", 6, "Base.Hinge", 2)
	for li, L in ipairs(lockers) do
		local entry = L
		local spr = {
			sprite = entry[2], northSprite = entry[3],
			eastSprite = entry[4], southSprite = entry[5],
		}
		local hang = entry[6] == "filingcabinet"
		add({
			id = "mb_locker_" .. li, section = "Build", group = "Containers", kind = "item", sort = sortCont + 140 + li,
			nameKey = entry[1], sprite = entry[2], showHp = true, hp = 350,
			containerType = entry[6],
			needs = lockerNeeds, skills = { Woodwork = sk("complexFurniture", 4) }, tools = SD,
			create = function(p)
				local name = getText(entry[1])
				if hang then
					mb().onBuildHangingMetalLocker(nil, spr, p, name)
				else
					mb().onBuildMetalLocker(nil, spr, p, name)
				end
			end,
		})
	end

	-- Laundry / brick pallet / metal barrel / post box / recycling
	do
		local laundrySpr = { sprite = "appliances_laundry_01_24", northSprite = "appliances_laundry_01_25" }
		add({
			id = "mb_laundry", section = "Build", group = "Containers", kind = "item", sort = sortCont + 160,
			nameKey = "ContextMenu_Laundry_Cart", sprite = laundrySpr.sprite, showHp = true, hp = 200,
			containerType = "officedrawers",
			needs = need("Base.Sheet", 1, "Base.Screws", 2, "Base.SheetMetal", 1),
			skills = { Woodwork = sk("simpleContainer", 3) }, tools = SD,
			create = function(p)
				mb().onBuildLaundryCart(nil, laundrySpr, p, getText("ContextMenu_Laundry_Cart"))
			end,
		})
		local brickSpr = { sprite = "construction_01_4", northSprite = "construction_01_4" }
		add({
			id = "mb_brick_pallet", section = "Build", group = "Containers", kind = "item", sort = sortCont + 161,
			nameKey = "ContextMenu_Pallet_of_Bricks", sprite = brickSpr.sprite, showHp = true, hp = 250,
			containerType = "fireplace",
			needs = need("Base.Plank", 4, "Base.Nails", 2),
			skills = { Woodwork = sk("complexContainer", 5) }, tools = H,
			create = function(p)
				mb().onBuildStoneContainer(nil, brickSpr, p, getText("ContextMenu_Pallet_of_Bricks"), "fireplace")
			end,
		})
		local barrelSpr = { sprite = "industry_01_22", northSprite = "industry_01_23" }
		add({
			id = "mb_metal_barrel", section = "Build", group = "Containers", kind = "item", sort = sortCont + 162,
			nameKey = "ContextMenu_Metal_Barrel", sprite = barrelSpr.sprite, showHp = true, hp = 350,
			containerType = "bin",
			needs = need("Base.SheetMetal", 2, "Base.Screws", 2),
			skills = { Woodwork = sk("advancedContainer", 7) }, tools = SD,
			create = function(p)
				mb().onBuildMetalContainer(nil, barrelSpr, p, getText("ContextMenu_Metal_Barrel"), "bin")
			end,
		})
		local postSpr = {
			sprite = "street_decoration_01_8", northSprite = "street_decoration_01_9",
			eastSprite = "street_decoration_01_10", southSprite = "street_decoration_01_11",
		}
		add({
			id = "mb_post_box", section = "Build", group = "Containers", kind = "item", sort = sortCont + 163,
			nameKey = "ContextMenu_Post_Box", sprite = postSpr.sprite, showHp = true, hp = 350,
			containerType = "vendingpop",
			needs = need("Base.SheetMetal", 2, "Base.Screws", 2),
			skills = { Woodwork = sk("advancedContainer", 7) }, tools = SD,
			create = function(p)
				mb().onBuildMetalContainer(nil, postSpr, p, getText("ContextMenu_Post_Box"), "vendingpop")
			end,
		})
		local recycleSpr = {
			sprite = "trashcontainers_01_0", northSprite = "trashcontainers_01_1",
			eastSprite = "trashcontainers_01_2", southSprite = "trashcontainers_01_3",
		}
		add({
			id = "mb_recycle_bin", section = "Build", group = "Containers", kind = "item", sort = sortCont + 164,
			nameKey = "ContextMenu_Recycling_Bin", sprite = recycleSpr.sprite, showHp = true, hp = 200,
			containerType = "bin",
			needs = need("Base.Plank", 2, "Base.Nails", 2),
			skills = { Woodwork = sk("simpleContainer", 3) }, tools = H,
			create = function(p)
				mb().onBuildWoodenContainer(nil, recycleSpr, p, getText("ContextMenu_Recycling_Bin"), "bin")
			end,
		})
	end

	-- Trash cans
	if M.getTrashCanData then
		local trash = M.getTrashCanData()
		local ti = 0
		if trash.Wood then
			for _, list in pairs(trash.Wood) do
				ti = ti + 1
				local entry = list
				local localTi = ti
				local spr = { sprite = entry[1], northSprite = entry[2] }
				add({
					id = "mb_trash_w_" .. localTi, section = "Build", group = "Containers", kind = "item", sort = sortCont + 180 + localTi,
					name = entry[3], sprite = entry[1], showHp = true, hp = 200,
					needs = need("Base.Plank", 2, "Base.Nails", 2),
					skills = { Woodwork = sk("simpleContainer", 3) }, tools = H,
					create = function(p)
						mb().onBuildWoodenContainer(nil, spr, p, entry[3], "bin")
					end,
				})
			end
		end
		if trash.Metal then
			for _, list in pairs(trash.Metal) do
				ti = ti + 1
				local entry = list
				local localTi = ti
				local spr = { sprite = entry[1], northSprite = entry[2] }
				add({
					id = "mb_trash_m_" .. localTi, section = "Build", group = "Containers", kind = "item", sort = sortCont + 190 + localTi,
					name = entry[3], sprite = entry[1], showHp = true, hp = 350,
					needs = need("Base.SheetMetal", 2, "Base.Screws", 2),
					skills = { Woodwork = sk("complexContainer", 5) }, tools = SD,
					create = function(p)
						mb().onBuildMetalContainer(nil, spr, p, entry[3], "bin")
					end,
				})
			end
		end
		if trash.Stone then
			for _, list in pairs(trash.Stone) do
				ti = ti + 1
				local entry = list
				local localTi = ti
				local spr = { sprite = entry[1], northSprite = entry[2] }
				add({
					id = "mb_trash_s_" .. localTi, section = "Build", group = "Containers", kind = "item", sort = sortCont + 200 + localTi,
					name = entry[3], sprite = entry[1], showHp = true, hp = 250,
					needs = need("Base.Plank", 4, "Base.Nails", 2),
					skills = { Woodwork = sk("complexContainer", 5) }, tools = H,
					create = function(p)
						mb().onBuildStoneContainer(nil, spr, p, entry[3], "bin")
					end,
				})
			end
		end
	end

end

HT_BuildContent_MB._regDecorSurvival = function()
	local M = mb()
	if not M then
		return
	end
	local sortWall = 20
	local sortDoor = 20
	local sortWin = 20
	local sortFloor = 20
	local sortRoof = 20
	local sortFence = 20
	local sortStairs = 20
	local sortFurn = 20
	local sortCont = 20
	local sortSurv = 20
	local sortLight = 20
	local sortDeco = 20

	-- J) Decor / survival
	if M.getRoadwayData then
		for ri, list in ipairs(M.getRoadwayData()) do
			local entry = list
			local spr = {
				sprite = entry[1], northSprite = entry[2],
				eastSprite = entry[3], southSprite = entry[4],
			}
			add({
				id = "mb_road_" .. ri, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + ri,
				name = entry[5], sprite = entry[1],
				needs = need("Base.Plank", 1, "Base.Nails", 1),
				skills = { Woodwork = sk("simpleObject", 1) }, tools = H,
				create = function(p)
					mb().onBuildSign(nil, spr, p, entry[5])
				end,
			})
		end
	end

	if M.getSignData then
		for si, list in ipairs(M.getSignData()) do
			local entry = list
			local spr = {
				sprite = entry[1], northSprite = entry[2],
				eastSprite = entry[3], southSprite = entry[4],
			}
			add({
				id = "mb_sign_" .. si, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + 20 + si,
				name = entry[5], sprite = entry[1],
				needs = need("Base.Plank", 1, "Base.Nails", 1),
				skills = { Woodwork = sk("simpleObject", 1) }, tools = H,
				create = function(p)
					mb().onBuildSign(nil, spr, p, entry[5])
				end,
			})
		end
	end

	if M.getMetalSignData then
		for si, list in ipairs(M.getMetalSignData()) do
			local entry = list
			local spr = {
				sprite = entry[1], northSprite = entry[2],
				eastSprite = entry[3], southSprite = entry[4],
			}
			add({
				id = "mb_msign_" .. si, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + 40 + si,
				name = entry[5], sprite = entry[1],
				needs = need("Base.MetalBar", 2, "Base.WeldingRods", 4),
				skills = { MetalWelding = sk("simpleObject", 1) }, tools = HB,
				create = function(p)
					mb().onBuildMetalSign(nil, spr, p, entry[5])
				end,
			})
		end
	end

	if M.getWallDecorationsData then
		local di = 0
		for _, subData in pairs(M.getWallDecorationsData()) do
			for _, list in pairs(subData) do
				di = di + 1
				local entry = list
				local localDi = di
				-- getWallDecorationsData: [1]=north, [2]=sprite
				local spr = { sprite = entry[2], northSprite = entry[1] }
				add({
					id = "mb_wdeco_" .. localDi, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + 60 + localDi,
					name = disp(entry[2], entry[3]), sprite = entry[2], showHp = true, hp = 50,
					needs = need("Base.SheetPaper2", 1, "Base.Nails", 1),
					skills = { Woodwork = sk("simpleDecoration", 1) }, tools = H,
					create = function(p)
						local name = disp(entry[2], entry[3])
						mb().onBuildWallDecoration(nil, spr, p, name)
					end,
				})
			end
		end
	end

	if M.getFlowerBedsData then
		local flowerData = M.getFlowerBedsData()
		local justKey = getText("ContextMenu_Just_Flowers")
		local borderKey = getText("ContextMenu_Stone_Border")
		local fi = 0
		if flowerData[justKey] then
			for _, list in pairs(flowerData[justKey]) do
				fi = fi + 1
				local entry = list
				local localFi = fi
				local spr = { sprite = entry[1] }
				add({
					id = "mb_flower_" .. localFi, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + 120 + localFi,
					name = disp(entry[1], entry[2]), sprite = entry[1],
					needs = need("Base.Plank", 1, "Base.Twigs", 1),
					skills = { Woodwork = sk("landscaping", 1) }, tools = { "HandShovel" },
					create = function(p)
						local name = disp(entry[1], entry[2])
						mb().onBuildFlowerFloor(nil, spr, p, name)
					end,
				})
			end
		end
		if flowerData[borderKey] then
			for _, list in pairs(flowerData[borderKey]) do
				fi = fi + 1
				local entry = list
				local localFi = fi
				local spr = {
					sprite = entry[1], northSprite = entry[2],
					eastSprite = entry[3], southSprite = entry[4],
				}
				add({
					id = "mb_flower_b_" .. localFi, section = "Survival", group = "Decoration", kind = "item", sort = sortDeco + 140 + localFi,
					name = entry[5], sprite = entry[1],
					needs = need("Base.Plank", 1, "Base.Twigs", 1),
					skills = { Woodwork = sk("landscaping", 1) }, tools = { "HandShovel" },
					create = function(p)
						mb().onBuildFourSpriteFlowerFloor(nil, spr, p, entry[5])
					end,
				})
			end
		end
	end

	-- Light poles
	if M.getLightPoleData then
		local lightNeeds = need(
			"Base.ScrapMetal", 10, "Base.Screws", 4, "Base.LightBulb", 1,
			"Radio.ElectricWire", 1, "Base.ElectronicsScrap", 5
		)
		for li, list in ipairs(M.getLightPoleData()) do
			local entry = list
			local spr = { sprite = entry[1] }
			add({
				id = "mb_light_" .. li, section = "Survival", group = "Lights", kind = "item", sort = sortLight + li,
				name = entry[2], sprite = entry[1],
				needs = lightNeeds,
				skills = { Woodwork = sk("lighting", 4), Electricity = sk("lightingObject", 2) },
				tools = HS,
				create = function(p)
					mb().onBuildLightPole(nil, spr, p, entry[2])
				end,
			})
		end
	end

	do
		local lampSpr = {
			sprite = "lighting_outdoor_01_49", northSprite = "lighting_outdoor_01_48",
			southSprite = "lighting_outdoor_01_50", eastSprite = "lighting_outdoor_01_51",
		}
		add({
			id = "mb_emergency_lamp", section = "Survival", group = "Lights", kind = "item", sort = sortLight + 10,
			nameKey = "ContextMenu_Emergency_Lamp", sprite = lampSpr.sprite,
			needs = need(
				"Base.ScrapMetal", 15, "Base.Screws", 5, "Base.LightBulb", 2,
				"Radio.ElectricWire", 1, "Base.ElectronicsScrap", 5
			),
			skills = { Woodwork = sk("lighting", 4), Electricity = sk("lightingObject", 2) },
			tools = HS,
			create = function(p)
				mb().onBuildOutdoorLight(nil, lampSpr, p, getText("ContextMenu_Emergency_Lamp"))
			end,
		})
	end

	-- Survival: water well, fridge, bbq, generator, stove, fireplace
	-- Sprites verified from Type_Survivas.lua
	do
		add({
			id = "mb_water_well", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 1,
			nameKey = "ContextMenu_Water_Well", sprite = "morebuild_01_0",
			needs = need("Base.Nails", 10, "Base.Rope", 5, "Base.Plank", 5, "Base.Gravelbag", 2, "Base.BucketEmpty", 1),
			skills = { Woodwork = sk("waterwellObject", 7) }, tools = HShS,
			create = function(p)
				-- onBuildWaterWell(ignore, player, sprite, waterMax)
				mb().onBuildWaterWell(nil, p, "morebuild_01_0", nil)
			end,
		})

		local fridgeSpr = {
			sprite = "appliances_refrigeration_01_24",
			northSprite = "appliances_refrigeration_01_25",
			eastSprite = "appliances_refrigeration_01_26",
			southSprite = "appliances_refrigeration_01_27",
		}
		add({
			id = "mb_fridge", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 2,
			name = disp(fridgeSpr.sprite, "Fridge"), sprite = fridgeSpr.sprite,
			showHp = true, hp = 350,
			containerType = "fridge",
			needs = need("Base.SheetMetal", 4, "Base.Screws", 5, "Radio.ElectricWire", 2, "Base.ElectronicsScrap", 10),
			skills = {
				Woodwork = sk("advancedContainer", 7),
				Electricity = sk("fridgeObject", 3),
				MetalWelding = 1,
			},
			tools = HSS,
			create = function(p)
				local name = disp(fridgeSpr.sprite, "Fridge")
				mb().onBuildfridge(nil, fridgeSpr, p, name, "fridge")
			end,
		})

		local bbqSpr = { sprite = "appliances_cooking_01_35", northSprite = "appliances_cooking_01_35" }
		add({
			id = "mb_bbq", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 3,
			name = disp(bbqSpr.sprite, "Barbecue"), sprite = bbqSpr.sprite,
			needs = need("Base.SheetMetal", 2, "Base.Screws", 3, "Base.Plank", 2),
			skills = { Woodwork = sk("barbecueObject", 4), MetalWelding = 3 }, tools = HS,
			create = function(p)
				local name = disp(bbqSpr.sprite, "Barbecue")
				mb().onBuildBarbecue(nil, bbqSpr, p, name)
			end,
		})

		local genSpr = { sprite = "appliances_misc_01_0", northSprite = "appliances_misc_01_0" }
		add({
			id = "mb_generator", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 4,
			nameKey = "ContextMenu_Fuel_Generator", sprite = genSpr.sprite,
			needs = need(
				"Radio.ElectricWire", 2, "Base.Aluminum", 10, "Base.SheetMetal", 4,
				"Base.Screws", 10, "Base.ElectronicsScrap", 100
			),
			skills = {
				Woodwork = sk("barbecueObject", 4),
				Electricity = sk("generatorObject", 3),
				MetalWelding = sk("generatorObject", 3),
			},
			tools = SS,
			create = function(p)
				local perk = 0
				local po = getSpecificPlayer(p)
				if po then
					perk = po:getPerkLevel(Perks.Electricity)
				end
				mb().onBuildGenerator(nil, genSpr, perk, getText("ContextMenu_Fuel_Generator"), p)
			end,
		})

		local stoveSpr = { sprite = "appliances_cooking_01_17", northSprite = "appliances_cooking_01_16" }
		add({
			id = "mb_stove", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 5,
			name = disp(stoveSpr.sprite, "Stove"), sprite = stoveSpr.sprite,
			needs = need("Base.SheetMetal", 6, "Base.Nails", 20, "Base.Screws", 10),
			skills = { Woodwork = 7 }, tools = HS,
			create = function(p)
				local name = disp(stoveSpr.sprite, "Stove")
				mb().onBuildStove(nil, stoveSpr, p, name)
			end,
		})

		local fpSpr = { sprite = "fixtures_fireplaces_01_0", northSprite = "fixtures_fireplaces_01_3" }
		add({
			id = "mb_fireplace", section = "Survival", group = "Survival", kind = "item", sort = sortSurv + 6,
			nameKey = "ContextMenu_Fireplace", sprite = fpSpr.sprite,
			needs = need("Base.Stone", 10, "Base.Dirtbag", 1, "Base.BucketWaterFull", 1),
			skills = { Woodwork = 7 }, tools = HHS,
			create = function(p)
				mb().onBuildFireplace(nil, fpSpr, p, getText("ContextMenu_Fireplace"))
			end,
		})
	end
end

HT_BuildContent_MB.register = function()
	if not getMoreBuildInstance then
		return
	end
	if not mb() then
		return
	end
	HT_BuildContent_MB._regStyles()
	HT_BuildContent_MB._regDoors()
	HT_BuildContent_MB._regGlassWalls()
	HT_BuildContent_MB._regWindows()
	HT_BuildContent_MB._regFloorsRoofs()
	HT_BuildContent_MB._regStairs()
	HT_BuildContent_MB._regFences()
	HT_BuildContent_MB._regFurniture()
	HT_BuildContent_MB._regContainers()
	HT_BuildContent_MB._regDecorSurvival()
end

