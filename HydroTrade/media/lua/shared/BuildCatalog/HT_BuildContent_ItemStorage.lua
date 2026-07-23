-- ItemStorage (ZipContainer): basement + zip box as placeable builds.

HT_BuildContent_ItemStorage = HT_BuildContent_ItemStorage or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

local function zipLoaded()
	if getActivatedMods and getActivatedMods():contains("ZipContainer") then
		return true
	end
	local sm = getScriptManager and getScriptManager()
	return sm and sm:FindItem("ZipContainer.ZipContainer") ~= nil
end

local function onBuildZipBasement(player)
	local o = ISSimpleFurniture:new("Basement", "ZipContainer_01_3", "ZipContainer_01_4")
	o.player = player
	o.name = "Basement"
	o.isContainer = true
	o.containerType = "ZipContainer"
	o.canBeLockedByPadlock = true
	o:setEastSprite("ZipContainer_01_3")
	o:setSouthSprite("ZipContainer_01_4")
	o:setNorthSprite("ZipContainer_01_4")
	getCell():setDrag(o, player)
end

local function onBuildZipBox(player)
	local o = ISSimpleFurniture:new("Box", "ZipContainer_01_0", "ZipContainer_01_0")
	o.player = player
	o.name = "Box"
	o.isContainer = true
	o.containerType = "ZipContainerBox"
	o.canBeLockedByPadlock = true
	o:setEastSprite("ZipContainer_01_0")
	o:setSouthSprite("ZipContainer_01_0")
	o:setNorthSprite("ZipContainer_01_0")
	getCell():setDrag(o, player)
end

HT_BuildContent_ItemStorage.register = function()
	if not zipLoaded() then
		return
	end

	local H = { "Hammer", "Saw" }
	local note = "IGUI_HT_BuildCatalog_Note_ItemStorage"

	add({
		id = "zip_box",
		section = "Build",
		group = "Containers",
		kind = "item",
		sort = 8,
		nameKey = "IGUI_HT_BuildCatalog_ZipBox",
		sprite = "ZipContainer_01_0",
		containerType = "ZipContainerBox",
		noteKey = note,
		needs = {
			{ item = "Base.Plank", count = 4 },
			{ item = "Base.Nails", count = 8 },
		},
		skills = { Woodwork = 2 },
		tools = H,
		create = function(p) onBuildZipBox(p) end,
	})

	-- Basement recipe uses Hydrocraft stoneworking mats.
	local sm = getScriptManager and getScriptManager()
	local hasHc = sm and sm:FindItem("Hydrocraft.HCStonepilebox") ~= nil
	if hasHc then
		add({
			id = "zip_basement",
			section = "Build",
			group = "Containers",
			kind = "item",
			sort = 9,
			nameKey = "IGUI_HT_BuildCatalog_ZipBasement",
			sprite = "ZipContainer_01_3",
			containerType = "ZipContainer",
			noteKey = note,
			needs = {
				{ item = "Hydrocraft.HCStonepilebox", count = 4 },
				{ item = "Hydrocraft.HCWoodenbucketconcrete", count = 2 },
				{ item = "Hydrocraft.HCWoodbeam", count = 4 },
				{ item = "Hydrocraft.HCLumberstack", count = 1 },
				{ item = "Base.MetalBar", count = 4 },
				{ item = "Base.Doorknob", count = 1 },
				{ item = "Base.Hinge", count = 2 },
				{ item = "Base.Nails", count = 18 },
			},
			skills = { Woodwork = 6 },
			tools = { "Hammer", "Saw", "Hydrocraft.HCMasontrowel", "Shovel" },
			create = function(p) onBuildZipBasement(p) end,
		})
	end
end
