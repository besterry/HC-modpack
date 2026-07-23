-- ISBlacksmithMenu MetalWelding entries (original materials).

HT_BuildContent_Metal = HT_BuildContent_Metal or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

local TW = { "BlowTorch", "WeldingMask" }

local function metal(def)
	add({
		id = def.id,
		section = "Metal",
		group = def.group,
		kind = def.kind or "item",
		sort = def.sort or 10,
		nameKey = def.nameKey,
		sprite = def.sprite,
		noteKey = def.noteKey,
		showHp = def.showHp,
		hp = def.hp,
		containerType = def.containerType,
		needs = def.needs,
		skills = def.skills,
		tools = TW,
		create = def.create,
	})
end

HT_BuildContent_Metal.register = function()
	if not ISBlacksmithMenu then
		return
	end

	metal({
		id = "mw_wall_frame", group = "Walls", kind = "frame", sort = 1,
		nameKey = "ContextMenu_MetalWallFrame", sprite = "constructedobjects_01_68",
		noteKey = "IGUI_HT_BuildCatalog_Note_WallFrame", showHp = true, hp = 120,
		needs = { { item = "Base.MetalBar", count = 3 } },
		skills = { MetalWelding = 3 },
		create = function(p) ISBlacksmithMenu.onMetalWallFrame(nil, p, "2") end,
	})

	metal({
		id = "mw_shelves", group = "Containers", sort = 1,
		nameKey = "ContextMenu_MetalShelves", sprite = "furniture_shelving_01_28",
		containerType = "shelves",
		needs = { { item = "Base.MetalPipe", count = 2 }, { item = "Base.SmallSheetMetal", count = 1 }, { item = "Base.ScrapMetal", count = 1 } },
		skills = { MetalWelding = 2 },
		create = function(p) ISBlacksmithMenu.onMetalShelves(nil, p, "2") end,
	})
	metal({
		id = "mw_crate", group = "Containers", sort = 2, showHp = true, hp = 350,
		nameKey = "ContextMenu_MetalCrate", sprite = "constructedobjects_01_44",
		containerType = "crate",
		needs = {
			{ item = "Base.MetalPipe", count = 2 }, { item = "Base.SmallSheetMetal", count = 2 },
			{ item = "Base.SheetMetal", count = 2 }, { item = "Base.ScrapMetal", count = 1 },
		},
		skills = { MetalWelding = 4 },
		create = function(p) ISBlacksmithMenu.onMetalCrate(nil, p, "2") end,
	})
	metal({
		id = "mw_counter", group = "Containers", sort = 3,
		nameKey = "ContextMenu_MetalCounter", sprite = "fixtures_counters_01_35",
		containerType = "counter",
		needs = { { item = "Base.MetalPipe", count = 2 }, { item = "Base.SmallSheetMetal", count = 4 }, { item = "Base.Hinge", count = 2 } },
		skills = { MetalWelding = 5 },
		create = function(p) ISBlacksmithMenu.onMetalCounter(nil, p, "2") end,
	})
	metal({
		id = "mw_counter_c", group = "Containers", sort = 4,
		nameKey = "ContextMenu_MetalCounterCorner", sprite = "fixtures_counters_01_36",
		containerType = "counter",
		needs = { { item = "Base.MetalPipe", count = 2 }, { item = "Base.SmallSheetMetal", count = 4 }, { item = "Base.Hinge", count = 2 } },
		skills = { MetalWelding = 5 },
		create = function(p) ISBlacksmithMenu.onMetalCounterCorner(nil, p, "2") end,
	})
	metal({
		id = "mw_locker_s", group = "Containers", sort = 5, showHp = true, hp = 300,
		nameKey = "ContextMenu_SmallLocker", sprite = "furniture_storage_02_8",
		containerType = "locker",
		needs = { { item = "Base.MetalPipe", count = 3 }, { item = "Base.SmallSheetMetal", count = 4 }, { item = "Base.Hinge", count = 2 } },
		skills = { MetalWelding = 6 },
		create = function(p) ISBlacksmithMenu.onSmallLocker(nil, p, "2") end,
	})
	metal({
		id = "mw_locker_b", group = "Containers", sort = 6, showHp = true, hp = 400,
		nameKey = "ContextMenu_BigLocker", sprite = "furniture_storage_02_12",
		containerType = "locker",
		needs = { { item = "Base.MetalPipe", count = 8 }, { item = "Base.SmallSheetMetal", count = 4 }, { item = "Base.Hinge", count = 2 } },
		skills = { MetalWelding = 9 },
		create = function(p) ISBlacksmithMenu.onBigLocker(nil, p, "3") end,
	})

	metal({
		id = "mw_fence", group = "Fences", sort = 1, showHp = true, hp = 200,
		nameKey = "ContextMenu_MetalFence", sprite = "constructedobjects_01_82",
		needs = { { item = "Base.MetalPipe", count = 1 }, { item = "Base.SmallSheetMetal", count = 2 }, { item = "Base.ScrapMetal", count = 3 } },
		skills = { MetalWelding = 3 },
		create = function(p)
			local spr = ISBlacksmithMenu.getFenceSprite(getSpecificPlayer(p))
			ISBlacksmithMenu.onMetalFence(nil, p, "1", spr)
		end,
	})
	metal({
		id = "mw_pole_fence", group = "Fences", sort = 2,
		nameKey = "ContextMenu_MetalPoleFence", sprite = "constructedobjects_01_62",
		needs = { { item = "Base.MetalPipe", count = 3 } },
		skills = { MetalWelding = 3 },
		create = function(p) ISBlacksmithMenu.onMetalPoleFence(nil, p, "1") end,
	})
	metal({
		id = "mw_wired", group = "Fences", sort = 3,
		nameKey = "ContextMenu_WiredFence", sprite = "fencing_01_25",
		needs = { { item = "Base.MetalPipe", count = 2 }, { item = "Base.ScrapMetal", count = 1 }, { item = "Base.Wire", count = 1 } },
		skills = { MetalWelding = 4 },
		create = function(p) ISBlacksmithMenu.onWiredFence(nil, p, "1") end,
	})
	metal({
		id = "mw_wired_big", group = "Fences", sort = 4,
		nameKey = "ContextMenu_BigWiredFence", sprite = "fencing_01_57",
		needs = { { item = "Base.MetalPipe", count = 3 }, { item = "Base.ScrapMetal", count = 4 }, { item = "Base.Wire", count = 3 } },
		skills = { MetalWelding = 5 },
		create = function(p) ISBlacksmithMenu.onBigWiredFence(nil, p, "1") end,
	})
	metal({
		id = "mw_fence_big", group = "Fences", sort = 5, showHp = true, hp = 400,
		nameKey = "ContextMenu_BigMetalFence", sprite = "constructedobjects_01_78",
		needs = { { item = "Base.MetalPipe", count = 5 }, { item = "Base.ScrapMetal", count = 2 } },
		skills = { MetalWelding = 7 },
		create = function(p) ISBlacksmithMenu.onBigMetalFence(nil, p, "2") end,
	})

	metal({
		id = "mw_gate", group = "Doors", sort = 1,
		nameKey = "ContextMenu_MetalFenceGate", sprite = "fixtures_doors_fences_01_28",
		needs = { { item = "Base.MetalPipe", count = 3 }, { item = "Base.Hinge", count = 2 }, { item = "Base.ScrapMetal", count = 2 } },
		skills = { MetalWelding = 4 },
		create = function(p) ISBlacksmithMenu.onFenceGate(nil, p, "1") end,
	})
	metal({
		id = "mw_gate_big", group = "Doors", sort = 2,
		nameKey = "ContextMenu_BigMetalFenceGate", sprite = "fixtures_doors_fences_01_24",
		needs = { { item = "Base.MetalPipe", count = 5 }, { item = "Base.Hinge", count = 2 }, { item = "Base.ScrapMetal", count = 4 } },
		skills = { MetalWelding = 7 },
		create = function(p) ISBlacksmithMenu.onBigMetalFenceGate(nil, p, "2") end,
	})
	metal({
		id = "mw_double_pole", group = "Doors", sort = 3,
		nameKey = "ContextMenu_BigMetalDoubleDoor", sprite = "fixtures_doors_fences_01_80",
		needs = { { item = "Base.MetalPipe", count = 10 }, { item = "Base.Hinge", count = 2 }, { item = "Base.ScrapMetal", count = 4 } },
		skills = { MetalWelding = 8 },
		create = function(p) ISBlacksmithMenu.onDoublePoleDoor(nil, p, "2") end,
	})
	metal({
		id = "mw_double_metal", group = "Doors", sort = 4,
		nameKey = "ContextMenu_Double_Metal_Door", sprite = "fixtures_doors_fences_01_64",
		needs = { { item = "Base.MetalPipe", count = 8 }, { item = "Base.Hinge", count = 2 }, { item = "Base.ScrapMetal", count = 2 }, { item = "Base.Wire", count = 4 } },
		skills = { MetalWelding = 7 },
		create = function(p) ISBlacksmithMenu.onDoubleMetalDoor(nil, p, "2") end,
	})

	metal({
		id = "mw_roof", group = "Roofs", sort = 1,
		nameKey = "ContextMenu_MetalRoof", sprite = "constructedobjects_01_86",
		needs = { { item = "Base.SmallSheetMetal", count = 1 }, { item = "Base.ScrapMetal", count = 1 } },
		skills = { MetalWelding = 0 },
		create = function(p) ISBlacksmithMenu.onMetalFloor(nil, p, "1") end,
	})
end
