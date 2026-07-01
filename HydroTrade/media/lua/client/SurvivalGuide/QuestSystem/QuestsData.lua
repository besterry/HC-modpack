QuestsData = QuestsData or {}

QuestsData.CATEGORY_TUTORIAL = "tutorial"
QuestsData.CATEGORY_STORY = "story"
QuestsData.CATEGORY_CYCLIC = "cyclic"
QuestsData.CATEGORY_SPECIAL = "special"
QuestsData.CYCLIC_BACKGROUND = "background"
QuestsData.CYCLIC_DAILY = "daily"
QuestsData.MAX_BACKGROUND_CYCLIC = 2

QuestsData.CHAIN_TUTORIAL = "tutorial"

QuestsData.TRADE_ZONE = {
	x1 = 8560,
	x2 = 8760,
	y1 = 7020,
	y2 = 7120,
	centerX = 8660,
	centerY = 7070,
}

QuestsData.ADMIN_SHOP = {
	x = 8662,
	y = 7079,
	z = 0,
}

QuestsData.PLAYER_SHOP_HUB = {
	x = 8626,
	y = 7082,
	z = 0,
}

QuestsData.CAR_MARKET = {
	x = 8723,
	y = 7097,
	z = 0,
}

QuestsData.ATM_SEARCH_RADIUS = 70
QuestsData.ARROW_DURATION_MS = 10000

QuestsData.DAILY_SECTORS = {
	{
		x = 10380, y = 10090, z = 0,
		titleKey = "IGUI_DailySector_MuldrahStructure_Title",
		previewKey = "IGUI_DailySector_MuldrahStructure_Preview",
		detailKey = "IGUI_DailySector_MuldrahStructure_Detail",
		hintKey = "IGUI_DailySector_MuldrahStructure_Hint",
	},
	{
		x = 11670, y = 10030, z = 0,
		titleKey = "IGUI_DailySector_MuldrahRailWarehouse_Title",
		previewKey = "IGUI_DailySector_MuldrahRailWarehouse_Preview",
		detailKey = "IGUI_DailySector_MuldrahRailWarehouse_Detail",
		hintKey = "IGUI_DailySector_MuldrahRailWarehouse_Hint",
	},
	{
		x = 7670, y = 11880, z = 0,
		titleKey = "IGUI_DailySector_RosewoodPrison_Title",
		previewKey = "IGUI_DailySector_RosewoodPrison_Preview",
		detailKey = "IGUI_DailySector_RosewoodPrison_Detail",
		hintKey = "IGUI_DailySector_RosewoodPrison_Hint",
	},
	{
		x = 7500, y = 12320, z = 0,
		titleKey = "IGUI_DailySector_RosewoodSouthRoad_Title",
		previewKey = "IGUI_DailySector_RosewoodSouthRoad_Preview",
		detailKey = "IGUI_DailySector_RosewoodSouthRoad_Detail",
		hintKey = "IGUI_DailySector_RosewoodSouthRoad_Hint",
	},
	{
		x = 4675, y = 8600, z = 0,
		titleKey = "IGUI_DailySector_RangerPark_Title",
		previewKey = "IGUI_DailySector_RangerPark_Preview",
		detailKey = "IGUI_DailySector_RangerPark_Detail",
		hintKey = "IGUI_DailySector_RangerPark_Hint",
	},
	{
		x = 3630, y = 5720, z = 0,
		titleKey = "IGUI_DailySector_FishermanHouse_Title",
		previewKey = "IGUI_DailySector_FishermanHouse_Preview",
		detailKey = "IGUI_DailySector_FishermanHouse_Detail",
		hintKey = "IGUI_DailySector_FishermanHouse_Hint",
	},
	{
		x = 5740, y = 6450, z = 0,
		titleKey = "IGUI_DailySector_GolfClub_Title",
		previewKey = "IGUI_DailySector_GolfClub_Preview",
		detailKey = "IGUI_DailySector_GolfClub_Detail",
		hintKey = "IGUI_DailySector_GolfClub_Hint",
	},
	{
		x = 5570, y = 5890, z = 0,
		titleKey = "IGUI_DailySector_LectomaxWarehouse_Title",
		previewKey = "IGUI_DailySector_LectomaxWarehouse_Preview",
		detailKey = "IGUI_DailySector_LectomaxWarehouse_Detail",
		hintKey = "IGUI_DailySector_LectomaxWarehouse_Hint",
	},
	{
		x = 6440, y = 5440, z = 0,
		titleKey = "IGUI_DailySector_RiversideSchool_Title",
		previewKey = "IGUI_DailySector_RiversideSchool_Preview",
		detailKey = "IGUI_DailySector_RiversideSchool_Detail",
		hintKey = "IGUI_DailySector_RiversideSchool_Hint",
	},
	{
		x = 11900, y = 6940, z = 0,
		titleKey = "IGUI_DailySector_WestPointPolice_Title",
		previewKey = "IGUI_DailySector_WestPointPolice_Preview",
		detailKey = "IGUI_DailySector_WestPointPolice_Detail",
		hintKey = "IGUI_DailySector_WestPointPolice_Hint",
	},
	{
		x = 13600, y = 5890, z = 0,
		titleKey = "IGUI_DailySector_StareplexCinema_Title",
		previewKey = "IGUI_DailySector_StareplexCinema_Preview",
		detailKey = "IGUI_DailySector_StareplexCinema_Detail",
		hintKey = "IGUI_DailySector_StareplexCinema_Hint",
	},
	{
		x = 12410, y = 3670, z = 0,
		titleKey = "IGUI_DailySector_StPeregrinHospital_Title",
		previewKey = "IGUI_DailySector_StPeregrinHospital_Preview",
		detailKey = "IGUI_DailySector_StPeregrinHospital_Detail",
		hintKey = "IGUI_DailySector_StPeregrinHospital_Hint",
	},
	{
		x = 10270, y = 8750, z = 0,
		titleKey = "IGUI_DailySector_RadioStation_Title",
		previewKey = "IGUI_DailySector_RadioStation_Preview",
		detailKey = "IGUI_DailySector_RadioStation_Detail",
		hintKey = "IGUI_DailySector_RadioStation_Hint",
	},
}

QuestsData.DAILY_CYCLIC_IDS = {
	"daily_visit_sector",
	"daily_quiet_zone",
	"daily_flashlight_300",
	"daily_night_patrol",
	"daily_homebody",
	"daily_drive",
	"daily_fitness",
	"daily_auto_bulbs",
	"daily_dismantle_electronics",
	"daily_rip_clothing",
}

-- Дневные и повторяемые не пересекаются по type (см. CYCLIC_BACKGROUND types в REGISTRY).

QuestsData.DAILY_PER_DAY = 3

QuestsData.CYCLIC_CONSUMABLE_POOL = {
	"Base.Bandage",
	"Base.AlcoholWipes",
	"Base.Disinfectant",
	"Base.Pills",
	"Base.TinnedBeans",
	"Base.CannedCorn",
	"Base.TinnedSoup",
	"Base.CannedMilk",
	"Base.WaterBottleFull",
	"Base.Crisps",
	"Base.Chocolate",
	"Base.PeanutButter",
	"Base.JuiceBox",
	"Base.Battery",
	"Base.Matches",
	"Base.Lighter",
	"Base.Rope",
	"Base.DuctTape",
	"Base.Thread",
	"Base.Soap2",
	"Base.ToiletPaper",
	"Base.HandTorch",
	"Hydrocraft.HCEnergydrink",
	"Hydrocraft.HCPurifyingtablets",
}

QuestsData.ATM_SPRITES = {
	["location_business_bank_01_64"] = true,
	["location_business_bank_01_65"] = true,
	["location_business_bank_01_66"] = true,
	["location_business_bank_01_67"] = true,
}

-- category: tutorial | story | cyclic
-- type: kill_jewelry | wallet_balance | trade_zone | (future)
QuestsData.REGISTRY = {
	{
		id = "tutorial_1",
		category = QuestsData.CATEGORY_TUTORIAL,
		chain = QuestsData.CHAIN_TUTORIAL,
		chainOrder = 1,
		type = "kill_jewelry",
		titleKey = "IGUI_TutorialQuest_Quest1_Title",
		killCount = 10,
		jewelryCount = 5,
		rewards = { "Base.HandAxe" },
	},
	{
		id = "tutorial_2",
		category = QuestsData.CATEGORY_TUTORIAL,
		chain = QuestsData.CHAIN_TUTORIAL,
		chainOrder = 2,
		type = "wallet_balance",
		titleKey = "IGUI_TutorialQuest_Quest2_Title",
		balanceMin = 1,
		rewards = { "Base.Bag_MoneyBag" },
	},
	{
		id = "tutorial_3",
		category = QuestsData.CATEGORY_TUTORIAL,
		chain = QuestsData.CHAIN_TUTORIAL,
		chainOrder = 3,
		type = "trade_zone",
		titleKey = "IGUI_TutorialQuest_Quest3_Title",
		detailKey = "IGUI_TutorialQuest_Quest3_Detail",
		hintKey = "IGUI_TutorialQuest_Quest3_Hint",
		balanceReward = 20000,
	},
	{
		id = "side_travel_distance",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "travel_distance",
		titleKey = "IGUI_SideQuest_TravelDist_Title",
		previewKey = "IGUI_SideQuest_TravelDist_Preview",
		hintKey = "IGUI_SideQuest_TravelDist_Hint",
		goalKey = "IGUI_SideQuest_TravelDist_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_TravelDist_Complete",
		distanceRequired = 1500,
		rewards = { "Base.TinnedBeans", "Base.WaterBottleFull" },
	},
	{
		id = "side_quiet_place",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestId = "side_travel_distance",
		type = "quiet_zone",
		titleKey = "IGUI_SideQuest_QuietPlace_Title",
		previewKey = "IGUI_SideQuest_QuietPlace_Preview",
		detailKey = "IGUI_SideQuest_QuietPlace_Detail",
		hintKey = "IGUI_SideQuest_QuietPlace_Hint",
		goalKey = "IGUI_SideQuest_QuietPlace_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_QuietPlace_Complete",
		zombieRadius = 30,
		zombieMax = 1,
		rewards = { "Hydrocraft.HCAdultmagazine" },
	},
	{
		id = "side_find_watch",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestId = "side_quiet_place",
		type = "look_around",
		titleKey = "IGUI_SideQuest_Watch_Title",
		previewKey = "IGUI_SideQuest_Watch_Preview",
		detailKey = "IGUI_SideQuest_Watch_Detail",
		hintKey = "IGUI_SideQuest_Watch_Hint",
		goalKey = "IGUI_SideQuest_Watch_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Watch_Complete",
		lookDirections = 4,
		rewards = { "Base.WristWatch_Left_ClassicBlack" },
	},
	{
		id = "side_collect_battery",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestId = "side_quiet_place",
		type = "collect_item",
		titleKey = "IGUI_SideQuest_Battery_Title",
		previewKey = "IGUI_SideQuest_Battery_Preview",
		hintKey = "IGUI_SideQuest_Battery_Hint",
		goalKey = "IGUI_SideQuest_Battery_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Battery_Complete",
		collectItem = "Base.Battery",
		collectRequired = 1,
		startGrants = {
			{ item = "Base.Screwdriver", count = 1 },
		},
		rewards = { "Base.Battery", "Base.Battery" },
	},
	{
		id = "side_forage_search",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "forage_count",
		titleKey = "IGUI_SideQuest_ForageSearch_Title",
		previewKey = "IGUI_SideQuest_ForageSearch_Preview",
		detailKey = "IGUI_SideQuest_ForageSearch_Detail",
		hintKey = "IGUI_SideQuest_ForageSearch_Hint",
		goalKey = "IGUI_SideQuest_ForageSearch_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_ForageSearch_Complete",
		forageRequired = 10,
		rewards = { "Base.BookForaging1" },
	},
	{
		id = "side_rest_stamina",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		autoActivate = true,
		type = "rest_stamina",
		titleKey = "IGUI_SideQuest_RestStamina_Title",
		detailKey = "IGUI_SideQuest_RestStamina_Detail",
		hintKey = "IGUI_SideQuest_RestStamina_Hint",
		goalKey = "IGUI_SideQuest_RestStamina_Goal",
		completeKey = "IGUI_SideQuest_RestStamina_Complete",
		enduranceTrigger = 0.35,
		rewards = { "Base.Crisps" },
	},
	{
		id = "side_travel_kill_15",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "kill_count",
		titleKey = "IGUI_SideQuest_TravelKill_Title",
		previewKey = "IGUI_SideQuest_TravelKill_Preview",
		hintKey = "IGUI_SideQuest_TravelKill_Hint",
		goalKey = "IGUI_SideQuest_Kill_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_TravelKill_Complete",
		killCount = 15,
		rewards = { "Base.Bandage", "Base.AlcoholWipes", "Base.Crisps" },
	},
	{
		id = "side_ninja_sneak",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "sneak_distance",
		titleKey = "IGUI_SideQuest_Ninja_Title",
		previewKey = "IGUI_SideQuest_Ninja_Preview",
		hintKey = "IGUI_SideQuest_Ninja_Hint",
		goalKey = "IGUI_SideQuest_Ninja_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Ninja_Complete",
		distanceRequired = 250,
		rewards = {
			{ item = "Base.Katana", conditionPercent = 0.65 },
		},
	},
	{
		id = "side_travel_flashlight",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "run_distance",
		titleKey = "IGUI_SideQuest_Light_Title",
		previewKey = "IGUI_SideQuest_Light_Preview",
		hintKey = "IGUI_SideQuest_Light_Hint",
		goalKey = "IGUI_SideQuest_Run_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Light_Complete",
		distanceRequired = 1000,
		rewards = { "Hydrocraft.HCEnergydrink", "Hydrocraft.HCEnergydrink" },
	},
	{
		id = "side_find_shelter",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "find_shelter",
		titleKey = "IGUI_SideQuest_Shelter_Title",
		previewKey = "IGUI_SideQuest_Shelter_Preview",
		hintKey = "IGUI_SideQuest_Shelter_Hint",
		goalKey = "IGUI_SideQuest_Shelter_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Shelter_Complete",
		rewards = { "Base.HandTorch", "Base.Battery" },
	},
	{
		id = "side_water",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "collect_water",
		titleKey = "IGUI_SideQuest_Water_Title",
		previewKey = "IGUI_SideQuest_Water_Preview",
		hintKey = "IGUI_SideQuest_Water_Hint",
		goalKey = "IGUI_SideQuest_Water_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Water_Complete",
		waterRequired = 1,
		startGrants = {
			{ item = "Base.WaterBottleEmpty", count = 1 },
		},
		rewards = { "Hydrocraft.HCPurifyingtablets", "Base.WaterBottleFull" },
	},
	{
		id = "side_forage_food",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "forage_food",
		titleKey = "IGUI_SideQuest_Forage_Title",
		previewKey = "IGUI_SideQuest_Forage_Preview",
		hintKey = "IGUI_SideQuest_Forage_Hint",
		goalKey = "IGUI_SideQuest_Forage_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Forage_Complete",
		forageRequired = 1,
		rewards = { "Base.TinnedBeans", "Base.CannedCorn", "Base.TinnedSoup" },
	},
	{
		id = "side_shop_buy",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestMinComplete = "tutorial_3",
		type = "shop_buy",
		titleKey = "IGUI_SideQuest_ShopBuy_Title",
		previewKey = "IGUI_SideQuest_ShopBuy_Preview",
		hintKey = "IGUI_SideQuest_ShopBuy_Hint",
		goalKey = "IGUI_SideQuest_ShopBuy_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_ShopBuy_Complete",
		navTarget = QuestsData.ADMIN_SHOP,
		navButtonKey = "IGUI_SideQuest_ShopBuy_FindShop",
		balanceReward = 1500,
	},
	{
		id = "side_intro_player_shops",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestMinComplete = "tutorial_3",
		type = "visit_location",
		titleKey = "IGUI_SideQuest_PlayerShops_Title",
		previewKey = "IGUI_SideQuest_PlayerShops_Preview",
		detailKey = "IGUI_SideQuest_PlayerShops_Detail",
		hintKey = "IGUI_SideQuest_PlayerShops_Hint",
		goalKey = "IGUI_SideQuest_PlayerShops_Goal",
		distanceKey = "IGUI_SideQuest_Visit_Distance",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_PlayerShops_Complete",
		target = QuestsData.PLAYER_SHOP_HUB,
		visitRadius = 15,
		balanceReward = 1000,
	},
	{
		id = "side_intro_car_market",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestId = "side_intro_player_shops",
		type = "visit_location",
		titleKey = "IGUI_SideQuest_CarMarket_Title",
		previewKey = "IGUI_SideQuest_CarMarket_Preview",
		detailKey = "IGUI_SideQuest_CarMarket_Detail",
		hintKey = "IGUI_SideQuest_CarMarket_Hint",
		goalKey = "IGUI_SideQuest_CarMarket_Goal",
		distanceKey = "IGUI_SideQuest_Visit_Distance",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_CarMarket_Complete",
		target = QuestsData.CAR_MARKET,
		visitRadius = 15,
		balanceReward = 1000,
	},
	{
		id = "story_survive_24h",
		category = QuestsData.CATEGORY_STORY,
		type = "survive_hours",
		titleKey = "IGUI_StoryQuest_Survive24h_Title",
		completeKey = "IGUI_StoryQuest_Survive24h_Complete",
		hoursRequired = 24, -- общее getHoursSurvived(); ~3 ч реального времени
		hintKey = "IGUI_StoryQuest_Survive24h_Hint",
		rewards = { "Base.GPSdayz" , "Base.Crowbar", "Base.Bag_NormalHikingBag" },
	},
	{
		id = "story_first_safehouse",
		category = QuestsData.CATEGORY_STORY,
		type = "first_safehouse",
		titleKey = "IGUI_StoryQuest_Safehouse_Title",
		goalKey = "IGUI_StoryQuest_Safehouse_Goal",
		detailKey = "IGUI_StoryQuest_Safehouse_Detail",
		hintKey = "IGUI_StoryQuest_Safehouse_Hint",
		completeKey = "IGUI_StoryQuest_Safehouse_Complete",
		zoneCellsMin = 625,
		rewards = { "Base.Hammer", "Base.Saw", "Base.NailsBox", "Base.NailsBox" },
	},
	{
		id = "story_skill_journal",
		category = QuestsData.CATEGORY_STORY,
		type = "skill_journal",
		titleKey = "IGUI_StoryQuest_Journal_Title",
		detailKey = "IGUI_StoryQuest_Journal_Detail",
		detailKey2 = "IGUI_StoryQuest_Journal_Detail2",
		goalKey1 = "IGUI_StoryQuest_Journal_Goal1",
		goalKey2 = "IGUI_StoryQuest_Journal_Goal2",
		hintKey1 = "IGUI_StoryQuest_Journal_Hint1",
		hintKey2 = "IGUI_StoryQuest_Journal_Hint2",
		completeKey = "IGUI_StoryQuest_Journal_Complete",
		startGrants = {
			{ item = "Base.Thread", count = 1 },
			{ item = "Base.LeatherStrips", count = 3 },
			{ item = "Base.Notebook", count = 1 },
			{ item = "Base.Glue", count = 1 },
			{ item = "Base.Pencil", count = 1 },
		},
		rewards = { "Base.Eraser", "Base.Pen" },
	},
	{
		id = "side_fish_5",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestMinComplete = "tutorial_3",
		type = "catch_fish",
		titleKey = "IGUI_SideQuest_Fish_Title",
		goalKey = "IGUI_SideQuest_Fish_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Fish_Complete",
		fishRequired = 5,
		previewKey = "IGUI_SideQuest_Fish_Preview",
		hintKey = "IGUI_SideQuest_Fish_Hint",
		startGrants = {
			{ item = "Base.FishingRod", count = 1 },
			{ item = "Base.FishingTackle", count = 2 },
			{ item = "Base.Worm", count = 10 },
		},
		rewards = { "camping.CampfireKit", "Base.Matches", "Base.TreeBranch", "Base.RippedSheets" },
	},
	{
		id = "side_campfire",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "light_campfire",
		titleKey = "IGUI_SideQuest_Campfire_Title",
		previewKey = "IGUI_SideQuest_Campfire_Preview",
		hintKey = "IGUI_SideQuest_Campfire_Hint",
		goalKey = "IGUI_SideQuest_Campfire_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Campfire_Complete",
		requiresQuestId = "side_fish_5",
		rewards = { "Base.Log", "Base.Log" },
	},
	{
		id = "side_repair_clothing",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestMinComplete = "tutorial_3",
		type = "sew_patch",
		titleKey = "IGUI_SideQuest_Repair_Title",
		previewKey = "IGUI_SideQuest_Repair_Preview",
		detailKey = "IGUI_SideQuest_Repair_Detail",
		hintKey = "IGUI_SideQuest_Repair_Hint",
		goalKey = "IGUI_SideQuest_Repair_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Repair_Complete",
		patchesRequired = 1,
		startGrants = {
			{ item = "Base.DenimStrips", count = 2 },
			{ item = "Base.Thread", count = 1 },
			{ item = "Base.Needle", count = 1 },
		},
		rewards = { "Base.Scissors", "Base.Thread" },
	},
	{
		id = "side_kill_25",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		requiresQuestMinComplete = "tutorial_3",
		type = "kill_count",
		titleKey = "IGUI_SideQuest_Kill25_Title",
		previewKey = "IGUI_SideQuest_Kill25_Preview",
		hintKey = "IGUI_SideQuest_Kill25_Hint",
		goalKey = "IGUI_SideQuest_Kill_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Kill25_Complete",
		killCount = 25,
		rewards = { "Base.Bandage", "Base.Bandage", "Base.AlcoholWipes" },
	},
	{
		id = "side_kill_100",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "tutorial_3",
		type = "kill_count",
		titleKey = "IGUI_SideQuest_Kill100_Title",
		previewKey = "IGUI_SideQuest_Kill100_Preview",
		hintKey = "IGUI_SideQuest_Kill100_Hint",
		goalKey = "IGUI_SideQuest_Kill_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Kill100_Complete",
		killCount = 100,
		requiresQuestId = "side_kill_25",
		rewards = { "Base.Axe" },
	},
	-- cyclic: фоновые (повторяемые, до 2 одновременно)
	{
		id = "cyclic_kill_50",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "kill_count",
		titleKey = "IGUI_Cyclic_Kill50_Title",
		previewKey = "IGUI_Cyclic_Kill50_Preview",
		hintKey = "IGUI_Cyclic_Kill50_Hint",
		goalKey = "IGUI_SideQuest_Kill_Goal",
		completeKey = "IGUI_Cyclic_Kill50_Complete",
		killCount = 200,
		balanceReward = 2500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "cyclic_travel_3k",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "travel_distance",
		titleKey = "IGUI_Cyclic_Travel3k_Title",
		previewKey = "IGUI_Cyclic_Travel3k_Preview",
		hintKey = "IGUI_Cyclic_Travel3k_Hint",
		goalKey = "IGUI_SideQuest_TravelDist_Goal",
		completeKey = "IGUI_Cyclic_Travel3k_Complete",
		distanceRequired = 2000,
		balanceReward = 500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "cyclic_run_2k",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "run_distance",
		titleKey = "IGUI_Cyclic_Run2k_Title",
		previewKey = "IGUI_Cyclic_Run2k_Preview",
		hintKey = "IGUI_Cyclic_Run2k_Hint",
		goalKey = "IGUI_SideQuest_Run_Goal",
		completeKey = "IGUI_Cyclic_Run2k_Complete",
		distanceRequired = 1000,
		balanceReward = 500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "cyclic_fish_10",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "catch_fish",
		titleKey = "IGUI_Cyclic_Fish10_Title",
		previewKey = "IGUI_Cyclic_Fish10_Preview",
		hintKey = "IGUI_Cyclic_Fish10_Hint",
		goalKey = "IGUI_SideQuest_Fish_Goal",
		completeKey = "IGUI_Cyclic_Fish10_Complete",
		fishRequired = 12,
		balanceReward = 600,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "cyclic_forage_20",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "forage_count",
		titleKey = "IGUI_Cyclic_Forage20_Title",
		previewKey = "IGUI_Cyclic_Forage20_Preview",
		hintKey = "IGUI_Cyclic_Forage20_Hint",
		goalKey = "IGUI_SideQuest_ForageSearch_Goal",
		completeKey = "IGUI_Cyclic_Forage20_Complete",
		forageRequired = 25,
		balanceReward = 500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "cyclic_sneak_500",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_BACKGROUND,
		type = "sneak_distance",
		titleKey = "IGUI_Cyclic_Sneak500_Title",
		previewKey = "IGUI_Cyclic_Sneak500_Preview",
		hintKey = "IGUI_Cyclic_Sneak500_Hint",
		goalKey = "IGUI_SideQuest_Ninja_Goal",
		completeKey = "IGUI_Cyclic_Sneak500_Complete",
		distanceRequired = 500,
		balanceReward = 500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	-- cyclic: дневные (1 в игровой день, свои механики)
	{
		id = "daily_visit_sector",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "visit_location",
		dynamicVisit = true,
		titleKey = "IGUI_Cyclic_DailyVisit_Title",
		goalKey = "IGUI_Cyclic_DailyVisit_Goal",
		distanceKey = "IGUI_SideQuest_Visit_Distance",
		completeKey = "IGUI_Cyclic_DailyVisit_Complete",
		navButtonKey = "IGUI_TutorialQuest_FindZone",
		visitRadius = 25,
		balanceReward = 1000,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_quiet_zone",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "quiet_zone",
		titleKey = "IGUI_Cyclic_DailyQuiet_Title",
		previewKey = "IGUI_Cyclic_DailyQuiet_Preview",
		detailKey = "IGUI_Cyclic_DailyQuiet_Detail",
		hintKey = "IGUI_Cyclic_DailyQuiet_Hint",
		goalKey = "IGUI_SideQuest_QuietPlace_Goal",
		completeKey = "IGUI_Cyclic_DailyQuiet_Complete",
		zombieRadius = 40,
		zombieMax = 1,
		balanceReward = 700,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_flashlight_300",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "flashlight_distance",
		titleKey = "IGUI_Cyclic_DailyFlash_Title",
		previewKey = "IGUI_Cyclic_DailyFlash_Preview",
		detailKey = "IGUI_Cyclic_DailyFlash_Detail",
		hintKey = "IGUI_Cyclic_DailyFlash_Hint",
		goalKey = "IGUI_Cyclic_DailyFlash_Goal",
		completeKey = "IGUI_Cyclic_DailyFlash_Complete",
		distanceRequired = 300,
		balanceReward = 750,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_rest",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "rest_stamina",
		titleKey = "IGUI_Cyclic_DailyRest_Title",
		previewKey = "IGUI_Cyclic_DailyRest_Preview",
		detailKey = "IGUI_Cyclic_DailyRest_Detail",
		hintKey = "IGUI_Cyclic_DailyRest_Hint",
		goalKey = "IGUI_SideQuest_RestStamina_Goal",
		completeKey = "IGUI_Cyclic_DailyRest_Complete",
		balanceReward = 500,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_night_patrol",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "night_distance",
		titleKey = "IGUI_Cyclic_DailyNight_Title",
		previewKey = "IGUI_Cyclic_DailyNight_Preview",
		detailKey = "IGUI_Cyclic_DailyNight_Detail",
		hintKey = "IGUI_Cyclic_DailyNight_Hint",
		goalKey = "IGUI_Cyclic_DailyNight_Goal",
		completeKey = "IGUI_Cyclic_DailyNight_Complete",
		distanceRequired = 200,
		nightStartHour = 21,
		nightEndHour = 5,
		balanceReward = 700,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_homebody",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "indoor_minutes",
		titleKey = "IGUI_Cyclic_DailyHomebody_Title",
		previewKey = "IGUI_Cyclic_DailyHomebody_Preview",
		detailKey = "IGUI_Cyclic_DailyHomebody_Detail",
		hintKey = "IGUI_Cyclic_DailyHomebody_Hint",
		goalKey = "IGUI_Cyclic_DailyHomebody_Goal",
		completeKey = "IGUI_Cyclic_DailyHomebody_Complete",
		indoorHoursRequired = 6,
		balanceReward = 600,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_drive",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "drive_distance",
		titleKey = "IGUI_Cyclic_DailyDrive_Title",
		previewKey = "IGUI_Cyclic_DailyDrive_Preview",
		detailKey = "IGUI_Cyclic_DailyDrive_Detail",
		hintKey = "IGUI_Cyclic_DailyDrive_Hint",
		goalKey = "IGUI_Cyclic_DailyDrive_Goal",
		completeKey = "IGUI_Cyclic_DailyDrive_Complete",
		distanceRequired = 1500,
		balanceReward = 700,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_fitness",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "fitness_minutes",
		titleKey = "IGUI_Cyclic_DailyFitness_Title",
		previewKey = "IGUI_Cyclic_DailyFitness_Preview",
		detailKey = "IGUI_Cyclic_DailyFitness_Detail",
		hintKey = "IGUI_Cyclic_DailyFitness_Hint",
		goalKey = "IGUI_Cyclic_DailyFitness_Goal",
		completeKey = "IGUI_Cyclic_DailyFitness_Complete",
		fitnessMinutesRequired = 10,
		balanceReward = 600,
		rewardPool = QuestsData.CYCLIC_CONSUMABLE_POOL,
		rewardPoolLabel = "IGUI_Cyclic_RewardPool_Bonus",
	},
	{
		id = "daily_auto_bulbs",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "vehicle_bulb_swap",
		titleKey = "IGUI_Cyclic_DailyAutoBulbs_Title",
		previewKey = "IGUI_Cyclic_DailyAutoBulbs_Preview",
		detailKey = "IGUI_Cyclic_DailyAutoBulbs_Detail",
		hintKey = "IGUI_Cyclic_DailyAutoBulbs_Hint",
		goalKey = "IGUI_Cyclic_DailyAutoBulbs_Goal",
		completeKey = "IGUI_Cyclic_DailyAutoBulbs_Complete",
		bulbSwapsRequired = 4,
		xpReward = { perkName = "Mechanics", amount = 40 },
	},
	{
		id = "daily_dismantle_electronics",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "dismantle_electronics",
		titleKey = "IGUI_Cyclic_DailyScrapElec_Title",
		previewKey = "IGUI_Cyclic_DailyScrapElec_Preview",
		detailKey = "IGUI_Cyclic_DailyScrapElec_Detail",
		hintKey = "IGUI_Cyclic_DailyScrapElec_Hint",
		goalKey = "IGUI_Cyclic_DailyScrapElec_Goal",
		completeKey = "IGUI_Cyclic_DailyScrapElec_Complete",
		dismantleRequired = 10,
		xpReward = { perkName = "Electricity", amount = 40, previewKey = "IGUI_Cyclic_XpReward_Electricity" },
	},
	{
		id = "daily_rip_clothing",
		category = QuestsData.CATEGORY_CYCLIC,
		cyclicTier = QuestsData.CYCLIC_DAILY,
		type = "rip_clothing",
		titleKey = "IGUI_Cyclic_DailyRipClothing_Title",
		previewKey = "IGUI_Cyclic_DailyRipClothing_Preview",
		detailKey = "IGUI_Cyclic_DailyRipClothing_Detail",
		hintKey = "IGUI_Cyclic_DailyRipClothing_Hint",
		goalKey = "IGUI_Cyclic_DailyRipClothing_Goal",
		completeKey = "IGUI_Cyclic_DailyRipClothing_Complete",
		ripsRequired = 15,
		xpReward = { perkName = "Tailoring", amount = 30, previewKey = "IGUI_Cyclic_XpReward_Tailoring" },
	},
}

QuestsData._byId = {}
QuestsData._jewelryCache = {}

for _, quest in ipairs(QuestsData.REGISTRY) do
	QuestsData._byId[quest.id] = quest
end

-- Акценты вкладок/квестов: main, daily, repeatable, special
QuestsData.POOL_ACCENT = {
	main = {
		stripe = { 0.82, 0.58, 0.28 },
		title = { 0.98, 0.88, 0.72 },
		tabActive = { bg = { 0.36, 0.24, 0.14 }, border = { 0.62, 0.42, 0.22 }, text = { 0.98, 0.88, 0.72 } },
		tabInactive = { bg = { 0.18, 0.14, 0.10 }, border = { 0.38, 0.30, 0.22 }, text = { 0.78, 0.72, 0.64 } },
	},
	daily = {
		stripe = { 0.38, 0.68, 0.95 },
		title = { 0.78, 0.90, 1.0 },
		tabActive = { bg = { 0.14, 0.26, 0.40 }, border = { 0.32, 0.52, 0.72 }, text = { 0.82, 0.92, 1.0 } },
		tabInactive = { bg = { 0.10, 0.16, 0.24 }, border = { 0.24, 0.36, 0.48 }, text = { 0.68, 0.76, 0.86 } },
	},
	repeatable = {
		stripe = { 0.72, 0.48, 0.92 },
		title = { 0.90, 0.78, 0.98 },
		tabActive = { bg = { 0.26, 0.16, 0.36 }, border = { 0.48, 0.32, 0.62 }, text = { 0.92, 0.82, 0.98 } },
		tabInactive = { bg = { 0.14, 0.10, 0.20 }, border = { 0.30, 0.22, 0.38 }, text = { 0.74, 0.68, 0.82 } },
	},
	special = {
		stripe = { 0.95, 0.78, 0.28 },
		title = { 1.0, 0.88, 0.42 },
		tabActive = { bg = { 0.48, 0.36, 0.10 }, border = { 0.92, 0.76, 0.28 }, text = { 1.0, 0.92, 0.55 } },
		tabInactive = { bg = { 0.24, 0.18, 0.08 }, border = { 0.55, 0.44, 0.16 }, text = { 0.88, 0.78, 0.48 } },
	},
}

function QuestsData.getQuestPoolKind(quest)
	if not quest then return "main" end
	if quest.category == QuestsData.CATEGORY_SPECIAL then return "special" end
	if quest.category == QuestsData.CATEGORY_CYCLIC then
		if quest.cyclicTier == QuestsData.CYCLIC_DAILY then return "daily" end
		return "repeatable"
	end
	return "main"
end

function QuestsData.getPoolAccent(poolKind)
	return QuestsData.POOL_ACCENT[poolKind] or QuestsData.POOL_ACCENT.main
end

function QuestsData.getQuestAccent(quest)
	return QuestsData.getPoolAccent(QuestsData.getQuestPoolKind(quest))
end

function QuestsData.getBoardTabAccent(tabId, active)
	local pool = tabId
	if pool ~= "main" and pool ~= "daily" and pool ~= "repeatable" and pool ~= "special" then
		pool = "main"
	end
	local accent = QuestsData.getPoolAccent(pool)
	return active and accent.tabActive or accent.tabInactive
end

function QuestsData.isElectronicsDismantleRecipe(recipe, item)
	if not recipe then return false end
	local name = recipe:getOriginalname() or ""
	if string.find(name, "Dismantle", 1, true) ~= 1 then return false end
	if item and item.getDisplayCategory and item:getDisplayCategory() == "Electronics" then
		return true
	end
	return QuestsData._electronicsDismantleRecipeNames[name] == true
end

QuestsData._electronicsDismantleRecipeNames = {
	["Dismantle Flashlight"] = true,
	["Dismantle TV Remote"] = true,
	["Dismantle Video Game"] = true,
	["Dismantle Cordless Phone"] = true,
	["Dismantle Speaker"] = true,
	["Dismantle Home Alarm"] = true,
	["Dismantle Digital Watch"] = true,
	["Dismantle Earbuds"] = true,
	["Dismantle Headphones"] = true,
	["Dismantle CD Player"] = true,
	["Dismantle Camera"] = true,
	["Dismantle Radio"] = true,
	["Dismantle Two-way Radio"] = true,
	["Dismantle HAM Radio"] = true,
	["Dismantle Television"] = true,
}

function QuestsData.isRipClothingRecipe(recipe)
	if not recipe then return false end
	local name = recipe:getOriginalname() or ""
	if name == "Rip Sheets" then return true end
	return string.find(name, "Rip Clothing", 1, true) == 1
end

function QuestsData.getQuest(questId)
	return QuestsData._byId[questId]
end

function QuestsData.getTutorialChain()
	local chain = {}
	for _, quest in ipairs(QuestsData.REGISTRY) do
		if quest.chain == QuestsData.CHAIN_TUTORIAL then
			table.insert(chain, quest)
		end
	end
	table.sort(chain, function(a, b) return a.chainOrder < b.chainOrder end)
	return chain
end

function QuestsData.getStoryQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.REGISTRY) do
		if quest.category == QuestsData.CATEGORY_STORY and not quest.optional then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getOptionalQuests(phaseId)
	local list = {}
	for _, quest in ipairs(QuestsData.REGISTRY) do
		if quest.optional and (not phaseId or quest.phaseId == phaseId) then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getAllOptionalQuests()
	return QuestsData.getOptionalQuests(nil)
end

function QuestsData.getCyclicQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.REGISTRY) do
		if quest.category == QuestsData.CATEGORY_CYCLIC then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getCyclicBackgroundQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.getCyclicQuests()) do
		if quest.cyclicTier == QuestsData.CYCLIC_BACKGROUND then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getCyclicDailyQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.getCyclicQuests()) do
		if quest.cyclicTier == QuestsData.CYCLIC_DAILY then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getSpecialQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.REGISTRY) do
		if quest.category == QuestsData.CATEGORY_SPECIAL then
			table.insert(list, quest)
		end
	end
	return list
end

function QuestsData.getAllTrackableQuests()
	local list = {}
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		table.insert(list, quest)
	end
	for _, quest in ipairs(QuestsData.getCyclicQuests()) do
		table.insert(list, quest)
	end
	for _, quest in ipairs(QuestsData.getSpecialQuests()) do
		table.insert(list, quest)
	end
	return list
end

function QuestsData.getGameDay()
	if not getGameTime then return 0 end
	return getGameTime():getDay()
end

function QuestsData.getDailyCyclicIdsForDay(day)
	local ids = QuestsData.DAILY_CYCLIC_IDS
	if not ids or #ids == 0 then return {} end
	local perDay = QuestsData.DAILY_PER_DAY or 1
	if perDay > #ids then perDay = #ids end
	day = math.floor(day or 0)
	local result = {}
	for i = 1, perDay do
		local index = ((day * perDay + i - 1) % #ids) + 1
		table.insert(result, ids[index])
	end
	return result
end

function QuestsData.getDailyCyclicIdForDay(day)
	local list = QuestsData.getDailyCyclicIdsForDay(day)
	return list[1]
end

function QuestsData.getDailySectorForDay(day)
	local sectors = QuestsData.DAILY_SECTORS
	if not sectors or #sectors == 0 then return nil end
	local index = (math.floor(day or 0) % #sectors) + 1
	return sectors[index]
end

function QuestsData.resolveVisitTarget(quest, progress, day)
	if quest.dynamicVisit then
		if progress and progress.visitTarget and progress.visitTarget.x then
			return progress.visitTarget
		end
		return QuestsData.getDailySectorForDay(day or QuestsData.getGameDay())
	end
	if progress and progress.visitTarget then
		return progress.visitTarget
	end
	return quest.target or quest.navTarget
end

function QuestsData.getActiveDailySector(progress, day)
	day = day or QuestsData.getGameDay()
	if progress and progress.visitTarget and progress.visitTarget.x then
		return progress.visitTarget
	end
	return QuestsData.getDailySectorForDay(day)
end

function QuestsData.getQuestTitle(quest, progress, day)
	if not quest then return "" end
	if quest.dynamicVisit then
		local sector = QuestsData.getActiveDailySector(progress, day)
		if sector and sector.titleKey then
			return getText(sector.titleKey)
		end
	end
	return getText(quest.titleKey)
end

function QuestsData.getQuestDetail(quest, progress, day)
	if not quest then return nil end
	if quest.dynamicVisit then
		local sector = QuestsData.getActiveDailySector(progress, day)
		if sector and sector.detailKey then
			return getText(sector.detailKey)
		end
	end
	if quest.detailKey then
		return getText(quest.detailKey)
	end
	return nil
end

function QuestsData.getQuestHint(quest, progress, day)
	if not quest then return nil end
	if quest.dynamicVisit then
		local sector = QuestsData.getActiveDailySector(progress, day)
		if sector and sector.hintKey then
			return getText(sector.hintKey)
		end
	end
	if quest.hintKey then
		return getText(quest.hintKey)
	end
	return nil
end

function QuestsData.isFishItem(item)
	if not item then return false end
	if item.isFish and item:isFish() then return true end
	if item.getDisplayCategory and item:getDisplayCategory() == "Fish" then return true end
	local ft = item:getFullType()
	if not ft then return false end
	if ft == "Base.BaitFish" then return true end
	local name = ft
	local dot = string.find(ft, "%.")
	if dot then
		name = string.sub(ft, dot + 1)
	end
	return string.find(name, "Fish", 1, true) ~= nil
		or name == "Bass" or name == "Trout" or name == "Perch" or name == "Panfish"
		or name == "Pike" or name == "Crappie" or name == "Catfish"
end

function QuestsData.getTutorialQuestId(order)
	return "tutorial_" .. tostring(order)
end

function QuestsData.getQuestDef(order)
	return QuestsData.getQuest(QuestsData.getTutorialQuestId(order))
end

function QuestsData.getRewardEntryItemType(reward)
	if type(reward) == "string" then return reward end
	if type(reward) == "table" then
		return reward.item or reward[1]
	end
	return nil
end

function QuestsData.getRewardEntryDisplayName(reward)
	local itemType = QuestsData.getRewardEntryItemType(reward)
	if not itemType then return "?" end
	local name = QuestsData.getRewardName(itemType)
	if type(reward) == "table" and reward.conditionPercent then
		name = name .. " (" .. getText("IGUI_SideQuest_Reward_Worn") .. ")"
	end
	return name
end

function QuestsData.getRewardName(itemType)
	if not itemType then return "?" end
	if getItemNameFromFullType then
		local name = getItemNameFromFullType(itemType)
		if name and name ~= "" and not string.find(name, "Base%.", 1, true) then
			return name
		end
	end
	if getScriptManager then
		local scriptItem = getScriptManager():getItem(itemType)
		if scriptItem then
			local name = scriptItem:getDisplayName()
			if name and name ~= "" then return name end
		end
	end
	return itemType
end

function QuestsData.getCurrencyUnitLabel()
	return getText("IGUI_TutorialQuest_Currency_Unit")
end

function QuestsData.formatCoinAmount(amount)
	local formatted = amount
	if Currency and Currency.format then
		formatted = Currency.format(amount)
	end
	return formatted .. " " .. QuestsData.getCurrencyUnitLabel()
end

function QuestsData.getCyclicRewardPreview(quest)
	local parts = {}
	if quest.balanceReward and quest.balanceReward > 0 then
		table.insert(parts, QuestsData.formatCoinAmount(quest.balanceReward))
	end
	if quest.xpReward and quest.xpReward.amount and quest.xpReward.amount > 0 then
		local xpKey = quest.xpReward.previewKey or "IGUI_Cyclic_XpReward_Mechanics"
		table.insert(parts, getText(xpKey, quest.xpReward.amount))
	end
	if quest.rewardPool and #quest.rewardPool > 0 then
		table.insert(parts, getText("IGUI_Cyclic_RewardPool_Bonus"))
	end
	if #parts == 0 then return "" end
	return table.concat(parts, " + ")
end

function QuestsData.getBalanceRewardText(amount)
	return QuestsData.formatCoinAmount(amount)
end

function QuestsData.getRewardText(questIdOrOrder, progress)
	local quest
	if type(questIdOrOrder) == "number" then
		quest = QuestsData.getQuestDef(questIdOrOrder)
	else
		quest = QuestsData.getQuest(questIdOrOrder)
	end
	if not quest then
		return getText("IGUI_TutorialQuest_Reward_None")
	end
	local parts = {}
	if quest.balanceReward and quest.balanceReward > 0 then
		table.insert(parts, QuestsData.getBalanceRewardText(quest.balanceReward))
	end
	if quest.xpReward and quest.xpReward.amount and quest.xpReward.amount > 0 then
		local xpKey = quest.xpReward.previewKey or "IGUI_Cyclic_XpReward_Mechanics"
		table.insert(parts, getText(xpKey, quest.xpReward.amount))
	end
	local poolDisplay = QuestsData.getPoolRewardDisplay(quest, progress)
	if poolDisplay then
		table.insert(parts, poolDisplay)
	end
	if quest.rewards then
		for _, reward in ipairs(quest.rewards) do
			table.insert(parts, QuestsData.getRewardEntryDisplayName(reward))
		end
	end
	if #parts == 0 then
		return getText("IGUI_TutorialQuest_Reward_None")
	end
	return table.concat(parts, ", ")
end

function QuestsData.getRewardLines(questIdOrOrder, progress)
	local quest
	if type(questIdOrOrder) == "number" then
		quest = QuestsData.getQuestDef(questIdOrOrder)
	else
		quest = QuestsData.getQuest(questIdOrOrder)
	end
	if not quest then
		return { getText("IGUI_TutorialQuest_Reward_None") }
	end
	local lines = {}
	if quest.balanceReward and quest.balanceReward > 0 then
		table.insert(lines, QuestsData.getBalanceRewardText(quest.balanceReward))
	end
	if quest.xpReward and quest.xpReward.amount and quest.xpReward.amount > 0 then
		local xpKey = quest.xpReward.previewKey or "IGUI_Cyclic_XpReward_Mechanics"
		table.insert(lines, getText(xpKey, quest.xpReward.amount))
	end
	local poolDisplay = QuestsData.getPoolRewardDisplay(quest, progress)
	if poolDisplay then
		table.insert(lines, poolDisplay)
	end
	if quest.rewards then
		for _, reward in ipairs(quest.rewards) do
			table.insert(lines, QuestsData.getRewardEntryDisplayName(reward))
		end
	end
	if #lines == 0 then
		return { getText("IGUI_TutorialQuest_Reward_None") }
	end
	return lines
end

function QuestsData.getQuestPreviewText(quest, progress, day)
	if not quest then return "" end
	local rewardPreview = nil
	if quest.category == QuestsData.CATEGORY_CYCLIC then
		rewardPreview = QuestsData.getCyclicRewardPreview(quest)
	end
	if quest.dynamicVisit then
		local sector = QuestsData.getActiveDailySector(progress, day)
		local parts = {}
		if sector and sector.previewKey then
			table.insert(parts, getText(sector.previewKey))
		end
		if rewardPreview and rewardPreview ~= "" then
			table.insert(parts, getText("IGUI_Cyclic_DailyVisit_RewardLine", rewardPreview))
		end
		return table.concat(parts, " ")
	end
	if not quest.previewKey then return rewardPreview or "" end
	if quest.type == "catch_fish" then
		if rewardPreview then
			return getText(quest.previewKey, quest.fishRequired or 5, rewardPreview)
		end
		return getText(quest.previewKey, quest.fishRequired or 5)
	end
	if quest.type == "kill_count" then
		if rewardPreview then
			return getText(quest.previewKey, quest.killCount or 25, rewardPreview)
		end
		return getText(quest.previewKey, quest.killCount or 25)
	end
	if quest.type == "travel_distance" then
		if rewardPreview then
			return getText(quest.previewKey, quest.distanceRequired or 500, rewardPreview)
		end
		return getText(quest.previewKey, quest.distanceRequired or 500)
	end
	if quest.type == "run_distance" then
		if rewardPreview then
			return getText(quest.previewKey, quest.distanceRequired or 500, rewardPreview)
		end
		return getText(quest.previewKey, quest.distanceRequired or 500)
	end
	if quest.type == "sneak_distance" then
		if rewardPreview then
			return getText(quest.previewKey, quest.distanceRequired or 200, rewardPreview)
		end
		return getText(quest.previewKey, quest.distanceRequired or 200)
	end
	if quest.type == "flashlight_distance" then
		if rewardPreview then
			return getText(quest.previewKey, quest.distanceRequired or 200, rewardPreview)
		end
		return getText(quest.previewKey, quest.distanceRequired or 200)
	end
	if quest.type == "forage_count" then
		if rewardPreview then
			return getText(quest.previewKey, quest.forageRequired or 10, rewardPreview)
		end
		return getText(quest.previewKey, quest.forageRequired or 10)
	end
	if quest.type == "forage_food" then
		if rewardPreview then
			return getText(quest.previewKey, quest.forageRequired or 1, rewardPreview)
		end
		return getText(quest.previewKey, quest.forageRequired or 1)
	end
	if quest.type == "look_around" then
		if rewardPreview then
			return getText(quest.previewKey, quest.lookDirections or 4, rewardPreview)
		end
		return getText(quest.previewKey, quest.lookDirections or 4)
	end
	if quest.type == "night_distance" or quest.type == "drive_distance" then
		if rewardPreview then
			return getText(quest.previewKey, quest.distanceRequired or 200, rewardPreview)
		end
		return getText(quest.previewKey, quest.distanceRequired or 200)
	end
	if quest.type == "indoor_minutes" then
		local hours = quest.indoorHoursRequired or math.ceil((quest.indoorMinutesRequired or 20) / 60)
		if rewardPreview then
			return getText(quest.previewKey, hours, rewardPreview)
		end
		return getText(quest.previewKey, hours)
	end
	if quest.type == "fitness_minutes" then
		if rewardPreview then
			return getText(quest.previewKey, quest.fitnessMinutesRequired or 10, rewardPreview)
		end
		return getText(quest.previewKey, quest.fitnessMinutesRequired or 10)
	end
	if quest.type == "vehicle_bulb_swap" then
		if rewardPreview then
			return getText(quest.previewKey, quest.bulbSwapsRequired or 4, rewardPreview)
		end
		return getText(quest.previewKey, quest.bulbSwapsRequired or 4)
	end
	if quest.type == "dismantle_electronics" then
		if rewardPreview then
			return getText(quest.previewKey, quest.dismantleRequired or 10, rewardPreview)
		end
		return getText(quest.previewKey, quest.dismantleRequired or 10)
	end
	if quest.type == "rip_clothing" then
		if rewardPreview then
			return getText(quest.previewKey, quest.ripsRequired or 15, rewardPreview)
		end
		return getText(quest.previewKey, quest.ripsRequired or 15)
	end
	if quest.type == "quiet_zone" or quest.type == "rest_stamina" then
		if rewardPreview then
			return getText(quest.previewKey, rewardPreview)
		end
		return getText(quest.previewKey)
	end
	if rewardPreview then
		return getText(quest.previewKey, rewardPreview)
	end
	return getText(quest.previewKey)
end

function QuestsData.pickRewardPoolItem(quest)
	if not quest or not quest.rewardPool or #quest.rewardPool == 0 then return nil end
	return quest.rewardPool[ZombRand(#quest.rewardPool) + 1]
end

function QuestsData.getPooledRewardItem(quest, progress)
	if not quest or not quest.rewardPool or #quest.rewardPool == 0 then return nil end
	if progress and progress.rewardItem then return progress.rewardItem end
	local itemType = QuestsData.pickRewardPoolItem(quest)
	if progress then
		progress.rewardItem = itemType
	end
	return itemType
end

function QuestsData.getPoolRewardDisplay(quest, progress)
	if not quest or not quest.rewardPool then return nil end
	if progress and progress.rewardItem then
		return QuestsData.getRewardName(progress.rewardItem)
	end
	if quest.rewardPoolLabel then
		return getText(quest.rewardPoolLabel)
	end
	local parts = {}
	for _, itemType in ipairs(quest.rewardPool) do
		table.insert(parts, QuestsData.getRewardName(itemType))
	end
	if #parts == 0 then return nil end
	return table.concat(parts, " / ")
end

function QuestsData.formatStartGrantSummary(grantsOrItems)
	if not grantsOrItems or #grantsOrItems == 0 then return "" end
	local grants = grantsOrItems
	if type(grantsOrItems[1]) == "string" then
		grants = {}
		for _, itemType in ipairs(grantsOrItems) do
			table.insert(grants, { item = itemType, count = 1 })
		end
	end
	local merged = {}
	local order = {}
	for _, grant in ipairs(grants) do
		local itemType = grant.item or grant[1]
		local count = grant.count or grant[2] or 1
		if itemType then
			if not merged[itemType] then
				merged[itemType] = 0
				table.insert(order, itemType)
			end
			merged[itemType] = merged[itemType] + count
		end
	end
	local parts = {}
	for _, itemType in ipairs(order) do
		local name = QuestsData.getRewardName(itemType)
		local count = merged[itemType]
		if count > 1 then
			table.insert(parts, name .. " x" .. count)
		else
			table.insert(parts, name)
		end
	end
	return table.concat(parts, ", ")
end

function QuestsData.isJewelry(fullType)
	if not fullType then return false end
	local cached = QuestsData._jewelryCache[fullType]
	if cached ~= nil then return cached end

	local itemName = fullType
	local dot = string.find(fullType, "%.")
	if dot then
		itemName = string.sub(fullType, dot + 1)
	end

	local result = false
	if itemName == "Locket" or itemName == "Necklace_DogTag" then
		result = true
	elseif string.find(itemName, "Friendship", 1, true) then
		result = false
	elseif string.find(itemName, "Ring_", 1, true)
		or string.find(itemName, "Necklace", 1, true)
		or string.find(itemName, "Earring_", 1, true)
		or string.find(itemName, "WristWatch_", 1, true)
		or string.find(itemName, "Bracelet_", 1, true)
		or string.find(itemName, "BellyButton_", 1, true)
		or string.find(itemName, "NoseRing_", 1, true)
		or string.find(itemName, "NoseStud_", 1, true)
	then
		result = true
	end

	QuestsData._jewelryCache[fullType] = result
	return result
end

function QuestsData.isFlashlightItem(item)
	if not item then return false end
	local t = item:getType() or ""
	if t == "HandTorch" or t == "Torch" or t == "Rubberducky2" then return true end
	local fullType = item.getFullType and item:getFullType() or ""
	if fullType == "Base.HandTorch" or fullType == "Base.Torch" then return true end
	if string.find(fullType, "HandTorch", 1, true) then return true end
	if string.find(fullType, "Rubberducky2", 1, true) then return true end
	if string.find(fullType, "Flashlight", 1, true) then return true end
	if string.find(fullType, "Torch", 1, true) and not string.find(fullType, "BlowTorch", 1, true) then return true end
	return false
end

function QuestsData.hasFlashlightEquipped(player)
	if not player then return false end
	if QuestsData.isFlashlightItem(player:getPrimaryHandItem()) then return true end
	if QuestsData.isFlashlightItem(player:getSecondaryHandItem()) then return true end
	local inv = player:getInventory()
	if not inv then return false end
	local items = inv:getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if QuestsData.isFlashlightItem(item) and item.isEquipped and item:isEquipped() then
			return true
		end
	end
	return false
end

function QuestsData.isQuartzWatchItem(item)
	if not item then return false end
	local fullType = item.getFullType and item:getFullType() or item:getType()
	if not fullType then return false end
	if string.find(fullType, "Digital", 1, true) then return false end
	if string.find(fullType, "WristWatch", 1, true) and string.find(fullType, "Classic", 1, true) then
		return true
	end
	return false
end

function QuestsData.isInTradeZone(x, y)
	local z = QuestsData.TRADE_ZONE
	local x1 = math.min(z.x1, z.x2)
	local x2 = math.max(z.x1, z.x2)
	local y1 = math.min(z.y1, z.y2)
	local y2 = math.max(z.y1, z.y2)
	return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

function QuestsData.getDistanceToTradeZone(x, y)
	if not x or not y then return 0 end
	local z = QuestsData.TRADE_ZONE
	if QuestsData.isInTradeZone(x, y) then return 0 end
	local x1 = math.min(z.x1, z.x2)
	local x2 = math.max(z.x1, z.x2)
	local y1 = math.min(z.y1, z.y2)
	local y2 = math.max(z.y1, z.y2)
	local nearestX = math.max(x1, math.min(x, x2))
	local nearestY = math.max(y1, math.min(y, y2))
	local dx = x - nearestX
	local dy = y - nearestY
	return math.sqrt(dx * dx + dy * dy)
end

function QuestsData.getDistanceToPoint(x, y, point)
	if not x or not y or not point then return 0 end
	local dx = x - point.x
	local dy = y - point.y
	return math.sqrt(dx * dx + dy * dy)
end

function QuestsData.isNearPoint(x, y, point, radius)
	if not x or not y or not point then return false end
	return QuestsData.getDistanceToPoint(x, y, point) <= (radius or 12)
end

function QuestsData.isAtmSprite(spriteName)
	if not spriteName then return false end
	if QuestsData.ATM_SPRITES[spriteName] then return true end
	return string.find(spriteName, "bank_01_6", 1, true) ~= nil
end

-- Совместимость со старым именем в HUD
QuestsData.QUESTS = QuestsData.getTutorialChain()
QuestsData.QUEST1_KILL_COUNT = 10
QuestsData.QUEST1_JEWELRY_COUNT = 5
QuestsData.QUEST2_BALANCE_MIN = 1
QuestsData.QUEST3_BALANCE_REWARD = 20000
