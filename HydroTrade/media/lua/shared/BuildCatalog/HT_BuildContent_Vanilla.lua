-- Vanilla ISBuildMenu entries (original materials).

HT_BuildContent_Vanilla = HT_BuildContent_Vanilla or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

local H = { "Hammer" }

HT_BuildContent_Vanilla.register = function()
	if not ISBuildMenu then
		return
	end

	add({
		id = "v_wall_frame", section = "Build", group = "Walls", kind = "frame", sort = 1,
		nameKey = "ContextMenu_Wooden_Wall_Frame", sprite = "walls_exterior_wooden_01_27",
		noteKey = "IGUI_HT_BuildCatalog_Note_WallFrame", showHp = true, hp = 50,
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 2 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenWallFrame(nil, ISBuildMenu.getWoodenWallFrameSprites(p), p) end,
	})
	add({
		id = "v_pillar", section = "Build", group = "Walls", kind = "item", sort = 2,
		nameKey = "ContextMenu_Wooden_Pillar", sprite = "walls_exterior_wooden_01_27",
		showHp = true, hp = 50,
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 3 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenPillar(nil, p) end,
	})
	add({
		id = "v_log_wall", section = "Build", group = "Walls", kind = "item", sort = 3,
		nameKey = "ContextMenu_Log_Wall", sprite = "carpentry_02_80",
		showHp = true, hp = 100,
		needs = { { item = "Base.Log", count = 4 } },
		skills = { Woodwork = 0 }, tools = H,
		create = function(p) ISBuildMenu.onLogWall(nil, p) end,
	})

	add({
		id = "v_door_frame", section = "Build", group = "Doors", kind = "frame", sort = 1,
		nameKey = "ContextMenu_Door_Frame", sprite = "walls_exterior_wooden_01_50",
		noteKey = "IGUI_HT_BuildCatalog_Note_WallFrame", showHp = true, hp = 80,
		needs = { { item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenDoorFrame(nil, nil, ISBuildMenu.getWoodenDoorFrameSprites(p), p) end,
	})
	add({
		id = "v_door", section = "Build", group = "Doors", kind = "item", sort = 2,
		nameKey = "ContextMenu_Door", sprite = "carpentry_01_48", showHp = true, hp = 200,
		needs = {
			{ item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 },
			{ item = "Base.Doorknob", count = 1 }, { item = "Base.Hinge", count = 2 },
		},
		skills = { Woodwork = 3 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenDoor(nil, nil, ISBuildMenu.getWoodenDoorSprites(p), p) end,
	})
	if ISBuildMenu.onDoubleWoodenDoor then
		add({
			id = "v_double_door", section = "Build", group = "Doors", kind = "item", sort = 3,
			nameKey = "ContextMenu_Double_Wooden_Door", sprite = "fixtures_doors_fences_01_104", showHp = true, hp = 300,
			needs = {
				{ item = "Base.Plank", count = 12 }, { item = "Base.Nails", count = 12 },
				{ item = "Base.Hinge", count = 4 }, { item = "Base.Doorknob", count = 2 },
			},
			skills = { Woodwork = 6 }, tools = H,
			create = function(p) ISBuildMenu.onDoubleWoodenDoor(nil, nil, p) end,
		})
	end

	if ISBuildMenu.onWoodenWindowsFrame then
		add({
			id = "v_window_frame", section = "Build", group = "Windows", kind = "frame", sort = 1,
			nameKey = "ContextMenu_Windows_Frame", sprite = "walls_exterior_wooden_01_52",
			noteKey = "IGUI_HT_BuildCatalog_Note_WallFrame",
			needs = { { item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 } },
			skills = { Woodwork = 2 }, tools = H,
			create = function(p) ISBuildMenu.onWoodenWindowsFrame(nil, nil, ISBuildMenu.getWoodenWindowsFrameSprites(p), p) end,
		})
	end

	add({
		id = "v_floor", section = "Build", group = "Floors", kind = "item", sort = 1,
		nameKey = "ContextMenu_Wooden_Floor", sprite = "carpentry_02_58",
		needs = { { item = "Base.Plank", count = 1 }, { item = "Base.Nails", count = 1 } },
		skills = { Woodwork = 1 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenFloor(nil, nil, ISBuildMenu.getWoodenFloorSprites(p), p) end,
	})

	add({
		id = "v_stairs", section = "Build", group = "Stairs", kind = "item", sort = 1,
		nameKey = "ContextMenu_Stairs", sprite = "carpentry_02_88",
		needs = { { item = "Base.Plank", count = 15 }, { item = "Base.Nails", count = 15 } },
		skills = { Woodwork = 6 }, tools = H,
		create = function(p)
			if ISBuildMenu.onBrownWoodenStairs then
				ISBuildMenu.onBrownWoodenStairs(nil, nil, p)
			else
				ISBuildMenu.onLightBrownWoodenStairs(nil, nil, p)
			end
		end,
	})

	add({
		id = "v_fence", section = "Build", group = "Fences", kind = "item", sort = 1,
		nameKey = "ContextMenu_Wooden_Fence", sprite = "carpentry_02_40", showHp = true, hp = 100,
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 3 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenFence(nil, nil, ISBuildMenu.getWoodenFenceSprites(p), p) end,
	})
	add({
		id = "v_fence_stake", section = "Build", group = "Fences", kind = "item", sort = 2,
		nameKey = "ContextMenu_Wooden_Stake", sprite = "fencing_01_36",
		needs = { { item = "Base.Plank", count = 1 }, { item = "Base.Nails", count = 2 } },
		skills = { Woodwork = 5 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenFenceStake(nil, nil, p) end,
	})
	add({
		id = "v_barbed", section = "Build", group = "Fences", kind = "item", sort = 3,
		nameKey = "ContextMenu_Barbed_Fence", sprite = "fencing_01_28",
		needs = { { item = "Base.BarbedWire", count = 1 } },
		skills = { Woodwork = 5 }, tools = H,
		create = function(p) ISBuildMenu.onBarbedFence(nil, nil, p) end,
	})
	add({
		id = "v_sandbag", section = "Build", group = "Fences", kind = "item", sort = 4,
		nameKey = "ContextMenu_Sang_Bag_Wall", sprite = "carpentry_02_12",
		needs = { { item = "Base.Sandbag", count = 3 } },
		skills = { Woodwork = 0 }, tools = H,
		create = function(p) ISBuildMenu.onSangBagWall(nil, nil, p) end,
	})
	add({
		id = "v_gravelbag", section = "Build", group = "Fences", kind = "item", sort = 5,
		nameKey = "ContextMenu_Gravel_Bag_Wall", sprite = "carpentry_02_12",
		needs = { { item = "Base.Gravelbag", count = 3 } },
		skills = { Woodwork = 0 }, tools = H,
		create = function(p) ISBuildMenu.onGravelBagWall(nil, nil, p) end,
	})

	add({
		id = "v_crate", section = "Build", group = "Containers", kind = "item", sort = 1,
		nameKey = "ContextMenu_Wooden_Crate", sprite = "carpentry_01_16", showHp = true, hp = 150,
		needs = { { item = "Base.Plank", count = 3 }, { item = "Base.Nails", count = 3 } },
		skills = { Woodwork = 3 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenCrate(nil, nil, ISBuildMenu.getWoodenCrateSprites(p), p) end,
	})
	add({
		id = "v_barrel_s", section = "Build", group = "Containers", kind = "item", sort = 2,
		nameKey = "ContextMenu_Rain_Collector_Barrel", sprite = "carpentry_02_54",
		needs = { { item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 }, { item = "Base.Garbagebag", count = 4 } },
		skills = { Woodwork = 4 }, tools = H,
		create = function(p) ISBuildMenu.onCreateBarrel(nil, p, "carpentry_02_54", RainCollectorBarrel and RainCollectorBarrel.smallWaterMax or 40) end,
	})
	add({
		id = "v_barrel_l", section = "Build", group = "Containers", kind = "item", sort = 3,
		name = getText("ContextMenu_Rain_Collector_Barrel") .. " (L)", sprite = "carpentry_02_52",
		needs = { { item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 }, { item = "Base.Garbagebag", count = 4 } },
		skills = { Woodwork = 7 }, tools = H,
		create = function(p) ISBuildMenu.onCreateBarrel(nil, p, "carpentry_02_52", RainCollectorBarrel and RainCollectorBarrel.largeWaterMax or 100) end,
	})

	add({
		id = "v_table", section = "Build", group = "Furniture", kind = "item", sort = 1,
		nameKey = "ContextMenu_Small_Table", sprite = "carpentry_01_60",
		needs = { { item = "Base.Plank", count = 5 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 3 }, tools = H,
		create = function(p) ISBuildMenu.onSmallWoodTable(nil, nil, ISBuildMenu.getWoodenTableSprites(p), p) end,
	})
	add({
		id = "v_table_l", section = "Build", group = "Furniture", kind = "item", sort = 2,
		nameKey = "ContextMenu_Large_Table", sprite = "carpentry_01_61",
		needs = { { item = "Base.Plank", count = 6 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 4 }, tools = H,
		create = function(p) ISBuildMenu.onLargeWoodTable(nil, nil, ISBuildMenu.getLargeWoodTableSprites(p), p) end,
	})
	add({
		id = "v_table_d", section = "Build", group = "Furniture", kind = "item", sort = 3,
		nameKey = "ContextMenu_Table_with_Drawer", sprite = "carpentry_01_60",
		needs = { { item = "Base.Plank", count = 5 }, { item = "Base.Nails", count = 4 }, { item = "Base.Drawer", count = 1 } },
		skills = { Woodwork = 5 }, tools = H,
		create = function(p) ISBuildMenu.onSmallWoodTableWithDrawer(nil, nil, ISBuildMenu.getTableWithDrawerSprites(p), p) end,
	})
	add({
		id = "v_chair", section = "Build", group = "Furniture", kind = "item", sort = 4,
		nameKey = "ContextMenu_Wooden_Chair", sprite = "carpentry_01_36",
		needs = { { item = "Base.Plank", count = 5 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onWoodChair(nil, nil, ISBuildMenu.getWoodenChairSprites(p), p) end,
	})
	add({
		id = "v_bookcase", section = "Build", group = "Furniture", kind = "item", sort = 5,
		nameKey = "ContextMenu_Bookcase", sprite = "furniture_shelving_01_40",
		needs = { { item = "Base.Plank", count = 5 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 5 }, tools = H,
		create = function(p) ISBuildMenu.onBookcase(nil, nil, ISBuildMenu.getBookcaseSprite(p), p) end,
	})
	add({
		id = "v_bookcase_s", section = "Build", group = "Furniture", kind = "item", sort = 6,
		nameKey = "ContextMenu_SmallBookcase", sprite = "furniture_shelving_01_41",
		needs = { { item = "Base.Plank", count = 3 }, { item = "Base.Nails", count = 3 } },
		skills = { Woodwork = 3 }, tools = H,
		create = function(p) ISBuildMenu.onSmallBookcase(nil, nil, ISBuildMenu.getSmallBookcaseSprite(p), p) end,
	})
	add({
		id = "v_shelf", section = "Build", group = "Furniture", kind = "item", sort = 7,
		nameKey = "ContextMenu_Shelves", sprite = "furniture_shelving_01_0",
		needs = { { item = "Base.Plank", count = 1 }, { item = "Base.Nails", count = 2 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onShelve(nil, nil, ISBuildMenu.getShelveSprite(p), p) end,
	})
	add({
		id = "v_shelf_d", section = "Build", group = "Furniture", kind = "item", sort = 8,
		nameKey = "ContextMenu_DoubleShelves", sprite = "furniture_shelving_01_0",
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onDoubleShelve(nil, nil, ISBuildMenu.getDoubleShelveSprite(p), p) end,
	})
	add({
		id = "v_bed", section = "Build", group = "Furniture", kind = "item", sort = 9,
		nameKey = "ContextMenu_Bed", sprite = "furniture_bedding_01_0",
		needs = { { item = "Base.Plank", count = 6 }, { item = "Base.Nails", count = 4 }, { item = "Base.Mattress", count = 1 } },
		skills = { Woodwork = 4 }, tools = H,
		create = function(p) ISBuildMenu.onBed(nil, nil, ISBuildMenu.getBedSprite(p), p) end,
	})
	add({
		id = "v_sign", section = "Build", group = "Furniture", kind = "item", sort = 10,
		nameKey = "ContextMenu_Sign", sprite = "constructedobjects_signs_01_0",
		needs = { { item = "Base.Plank", count = 3 }, { item = "Base.Nails", count = 3 } },
		skills = { Woodwork = 1 }, tools = H,
		create = function(p) ISBuildMenu.onSign(nil, nil, ISBuildMenu.getSignSprite(p), p) end,
	})
	add({
		id = "v_bar", section = "Build", group = "Furniture", kind = "item", sort = 11,
		nameKey = "ContextMenu_Bar_Element", sprite = "location_restaurant_bar_01_0",
		needs = { { item = "Base.Plank", count = 4 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 7 }, tools = H,
		create = function(p) ISBuildMenu.onBarElement(nil, nil, ISBuildMenu.getBarElementSprites(p), p) end,
	})
	add({
		id = "v_compost", section = "Build", group = "Furniture", kind = "item", sort = 12,
		nameKey = "ContextMenu_Compost", sprite = "camping_01_19",
		needs = { { item = "Base.Plank", count = 5 }, { item = "Base.Nails", count = 4 } },
		skills = { Woodwork = 2 }, tools = H,
		create = function(p) ISBuildMenu.onCompost(nil, p, "camping_01_19") end,
	})
	add({
		id = "v_lamp_pillar", section = "Build", group = "Lights", kind = "item", sort = 1,
		nameKey = "ContextMenu_Lamp_on_Pillar", sprite = "carpentry_02_59",
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 4 }, { item = "Base.Rope", count = 1 }, { item = "Base.Torch", count = 1 } },
		skills = { Woodwork = 4 }, tools = H,
		create = function(p) ISBuildMenu.onPillarLamp(nil, nil, ISBuildMenu.getPillarLampSprite(p), p) end,
	})
	add({
		id = "v_cross", section = "Build", group = "Decoration", kind = "item", sort = 1,
		nameKey = "ContextMenu_Wooden_Cross", sprite = "location_community_cemetary_01_22",
		needs = { { item = "Base.Plank", count = 2 }, { item = "Base.Nails", count = 2 } },
		skills = { Woodwork = 0 }, tools = H,
		create = function(p) ISBuildMenu.onWoodenCross(nil, nil, p) end,
	})
	add({
		id = "v_stone_pile", section = "Build", group = "Decoration", kind = "item", sort = 2,
		nameKey = "ContextMenu_Stone_Pile", sprite = "location_community_cemetary_01_30",
		needs = { { item = "Base.Stone", count = 6 } },
		skills = { Woodwork = 0 }, tools = {},
		create = function(p) ISBuildMenu.onStonePile(nil, nil, p) end,
	})
	add({
		id = "v_picket", section = "Build", group = "Decoration", kind = "item", sort = 3,
		nameKey = "ContextMenu_Wooden_Picket", sprite = "location_community_cemetary_01_31",
		needs = { { item = "Base.Plank", count = 1 }, { item = "Base.SheetRope", count = 1 } },
		skills = { Woodwork = 0 }, tools = {},
		create = function(p) ISBuildMenu.onWoodenPicket(nil, nil, p) end,
	})
end
