-- Hydrocraft / HydroTrade AdvancedBuild entries (original materials).

HT_BuildContent_HC = HT_BuildContent_HC or {}

local function add(r)
	HT_BuildRecipes.add(r)
end

HT_BuildContent_HC.register = function()
	if not Hydrocraft then
		return
	end

	if Hydrocraft.onBuildWallBrick then
		add({
			id = "hc_brick_wall", section = "Build", group = "Walls", kind = "item", sort = 90,
			nameKey = "ContextMenu_Brick_wall", sprite = "walls_exterior_house_02_64",
			showHp = true, hp = 2000,
			needs = {
				{ item = "Hydrocraft.HCGreybrick", count = 25 },
				{ item = "Hydrocraft.HCRedbrick", count = 30 },
				{ item = "Base.Stone", count = 50 },
				{ item = "Hydrocraft.HCMortar", count = 5 },
			},
			skills = {},
			tools = { "Hydrocraft.HCMasontrowel" },
			create = function(p) Hydrocraft.onBuildWallBrick(p) end,
		})
	end
	if Hydrocraft.onBuildWallBrickWin then
		add({
			id = "hc_brick_win", section = "Build", group = "Walls", kind = "item", sort = 91,
			nameKey = "ContextMenu_Brick_wall_with_window", sprite = "walls_exterior_house_02_72",
			showHp = true, hp = 2000,
			needs = {
				{ item = "Hydrocraft.HCGreybrick", count = 20 },
				{ item = "Hydrocraft.HCRedbrick", count = 25 },
				{ item = "Base.Stone", count = 40 },
				{ item = "Hydrocraft.HCMortar", count = 5 },
			},
			skills = {},
			tools = { "Hydrocraft.HCMasontrowel" },
			create = function(p) Hydrocraft.onBuildWallBrickWin(p) end,
		})
	end
	if Hydrocraft.onBuildGlassWall then
		add({
			id = "hc_glass_wall", section = "Metal", group = "Walls", kind = "item", sort = 92,
			nameKey = "ContextMenu_Glass_Wall", sprite = "walls_commercial_01_96",
			showHp = true, hp = 150,
			needs = {
				{ item = "Hydrocraft.HCSteelrod", count = 3 },
				{ item = "Hydrocraft.HCGlasspanelarge", count = 1 },
			},
			skills = {},
			tools = { "BlowTorch", "WeldingMask" },
			create = function(p) Hydrocraft.onBuildGlassWall(p) end,
		})
	end
	if Hydrocraft.onBuildGlassRoof then
		add({
			id = "hc_glass_roof", section = "Metal", group = "Roofs", kind = "item", sort = 90,
			nameKey = "ContextMenu_Glass_roof", sprite = "roofs_02_55",
			needs = {
				{ item = "Hydrocraft.HCSteelrod", count = 2 },
				{ item = "Hydrocraft.HCGlasspane", count = 1 },
			},
			skills = {},
			tools = { "BlowTorch", "WeldingMask" },
			create = function(p) Hydrocraft.onBuildGlassRoof(p) end,
		})
	end
	if Hydrocraft.onBuildMetalStairs then
		add({
			id = "hc_steel_stairs", section = "Build", group = "Stairs", kind = "item", sort = 90,
			nameKey = "ContextMenu_Build_Steel_Stairs", sprite = "fixtures_stairs_01_3",
			needs = {
				{ item = "Hydrocraft.HCSteelpole", count = 2 },
				{ item = "Hydrocraft.HCSteelrod", count = 6 },
				{ item = "Hydrocraft.HCSteelsheet", count = 5 },
			},
			skills = {},
			tools = { "BlowTorch", "WeldingMask" },
			create = function(p)
				local sprite = {}
				sprite.upToLeft01 = "fixtures_stairs_01_3"
				sprite.upToLeft02 = "fixtures_stairs_01_4"
				sprite.upToLeft03 = "fixtures_stairs_01_5"
				sprite.upToRight01 = "fixtures_stairs_01_11"
				sprite.upToRight02 = "fixtures_stairs_01_12"
				sprite.upToRight03 = "fixtures_stairs_01_13"
				sprite.pillar = "fixtures_stairs_01_10"
				sprite.pillarNorth = "fixtures_stairs_01_14"
				Hydrocraft.onBuildMetalStairs(sprite, p)
			end,
		})
	end

	local stations = {
		{ id = "hc_kiln", nameKey = "ContextMenu_Kiln", sprite = "hcBuildingKiln_01_0", item = "Hydrocraft.HCKiln", fn = "onBuildKiln" },
		{ id = "hc_tarkiln", nameKey = "ContextMenu_Tar_Kiln", sprite = "hcBuildingTarkiln_01_0", item = "Hydrocraft.HCTarkiln", fn = "onBuildTarkiln" },
		{ id = "hc_grind", nameKey = "ContextMenu_Grindstone", sprite = "hcBuildingGrindstone_01_0", item = "Hydrocraft.HCGrindstone", fn = "onBuildGrindstone" },
		{ id = "hc_carp", nameKey = "ContextMenu_Carpenters_Workbench", sprite = "hcBuildingCarpBench_01_0", item = "Hydrocraft.HCCarpenterbench", fn = "onBuildCarpybench" },
		{ id = "hc_herb", nameKey = "ContextMenu_Herbal_Table", sprite = "hcBuildingHerbtable_01_0", item = "Hydrocraft.HCHerbtable", fn = "onBuildHerbaltable" },
		{ id = "hc_cellar", nameKey = "ContextMenu_Cellar", sprite = "hcBuildingCellar_01_0", item = "Hydrocraft.HCCellar", fn = "onBuildCellar", section = "Build", group = "Containers" },
	}
	-- Stations use ISSimpleFurniture: hammer required unless noNeedHammer=true.
	local H = { "Hammer" }
	for i, s in ipairs(stations) do
		local entry = s
		if Hydrocraft[entry.fn] then
			add({
				id = entry.id,
				section = entry.section or "Stations",
				group = entry.group or "Stations",
				kind = "item",
				sort = i,
				nameKey = entry.nameKey,
				sprite = entry.sprite,
				containerType = entry.id == "hc_cellar" and "crate" or nil,
				needs = { { item = entry.item, count = 1 } },
				skills = {},
				tools = H,
				create = function(p) Hydrocraft[entry.fn](p) end,
			})
		end
	end

	if Hydrocraft.onBuildIBCTower then
		add({
			id = "hc_ibc", section = "Survival", group = "Survival", kind = "item", sort = 10,
			nameKey = "ContextMenu_IBC_Tower", sprite = "hcBuildingIBCTower_01_0",
			needs = { { item = "Hydrocraft.HCIBCtower", count = 1 } },
			tools = H,
			getWaterMax = function()
				if Hydrocraft and type(Hydrocraft.IBCTowerWaterMax) == "number" then
					return Hydrocraft.IBCTowerWaterMax
				end
				return nil
			end,
			create = function(p) Hydrocraft.onBuildIBCTower(p) end,
		})
	end
	if Hydrocraft.onBuildWaterPump then
		add({
			id = "hc_pump", section = "Survival", group = "Survival", kind = "item", sort = 11,
			nameKey = "ContextMenu_Water_Pump", sprite = "hcBuildingWaterPump_01_0",
			needs = { { item = "Hydrocraft.HCWaterpump", count = 1 } },
			tools = H,
			getWaterMax = function()
				if WaterPump and type(WaterPump.waterMax) == "number" then
					return WaterPump.waterMax
				end
				return nil
			end,
			create = function(p) Hydrocraft.onBuildWaterPump(p) end,
		})
	end
	if Hydrocraft.onBuildBeehive then
		add({
			id = "hc_bee", section = "Stations", group = "Stations", kind = "item", sort = 12,
			nameKey = "ContextMenu_Beehive", sprite = "hcBuildingBeehive_00_0",
			needs = { { item = "Hydrocraft.HCBeehive3", count = 1 } },
			-- HC sets noNeedHammer = true
			tools = {},
			create = function(p) Hydrocraft.onBuildBeehive(p) end,
		})
	end
end
