QuestsData = QuestsData or {}

QuestsData.CATEGORY_TUTORIAL = "tutorial"
QuestsData.CATEGORY_STORY = "story"
QuestsData.CATEGORY_CYCLIC = "cyclic"

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
		type = "flashlight_distance",
		titleKey = "IGUI_SideQuest_Battery_Title",
		previewKey = "IGUI_SideQuest_Battery_Preview",
		hintKey = "IGUI_SideQuest_Battery_Hint",
		goalKey = "IGUI_SideQuest_Battery_Goal",
		acceptKey = "IGUI_SideQuest_AcceptHint",
		completeKey = "IGUI_SideQuest_Battery_Complete",
		distanceRequired = 200,
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
		rewards = { "Base.Hammer", "Base.NailsBox", "Base.Plank", "Base.Plank", "Base.Plank" },
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
		phaseId = "story_survive_24h",
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
			{ item = "Base.FishingTackle", count = 1 },
			{ item = "Base.Worm", count = 5 },
		},
		rewards = { "camping.CampfireKit", "Base.Matches", "Base.TreeBranch", "Base.RippedSheets" },
	},
	{
		id = "side_campfire",
		category = QuestsData.CATEGORY_STORY,
		optional = true,
		phaseId = "story_survive_24h",
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
		phaseId = "story_survive_24h",
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
		phaseId = "story_survive_24h",
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
		phaseId = "story_survive_24h",
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
	-- cyclic: повторяемые (позже, принятие у NPC)
	-- { id = "cyclic_kill_100", category = "cyclic", type = "kill_count", killCount = 100, rewardPool = {...} }
}

QuestsData._byId = {}
QuestsData._jewelryCache = {}

for _, quest in ipairs(QuestsData.REGISTRY) do
	QuestsData._byId[quest.id] = quest
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

function QuestsData.getBalanceRewardText(amount)
	local formatted = amount
	if Currency and Currency.format then
		formatted = Currency.format(amount)
	end
	return getText("IGUI_TutorialQuest_Reward_Balance", formatted)
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
	if quest.rewards then
		for _, reward in ipairs(quest.rewards) do
			table.insert(parts, QuestsData.getRewardEntryDisplayName(reward))
		end
	end
	local poolDisplay = QuestsData.getPoolRewardDisplay(quest, progress)
	if poolDisplay then
		table.insert(parts, poolDisplay)
	end
	if quest.balanceReward and quest.balanceReward > 0 then
		table.insert(parts, QuestsData.getBalanceRewardText(quest.balanceReward))
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
	if quest.rewards then
		for _, reward in ipairs(quest.rewards) do
			table.insert(lines, QuestsData.getRewardEntryDisplayName(reward))
		end
	end
	local poolDisplay = QuestsData.getPoolRewardDisplay(quest, progress)
	if poolDisplay then
		table.insert(lines, poolDisplay)
	end
	if quest.balanceReward and quest.balanceReward > 0 then
		table.insert(lines, QuestsData.getBalanceRewardText(quest.balanceReward))
	end
	if #lines == 0 then
		return { getText("IGUI_TutorialQuest_Reward_None") }
	end
	return lines
end

function QuestsData.getQuestPreviewText(quest)
	if not quest or not quest.previewKey then return "" end
	if quest.type == "catch_fish" then
		return getText(quest.previewKey, quest.fishRequired or 5)
	end
	if quest.type == "kill_count" then
		return getText(quest.previewKey, quest.killCount or 25)
	end
	if quest.type == "travel_distance" then
		return getText(quest.previewKey, quest.distanceRequired or 500)
	end
	if quest.type == "run_distance" then
		return getText(quest.previewKey, quest.distanceRequired or 500)
	end
	if quest.type == "sneak_distance" then
		return getText(quest.previewKey, quest.distanceRequired or 200)
	end
	if quest.type == "flashlight_distance" then
		return getText(quest.previewKey, quest.distanceRequired or 200)
	end
	if quest.type == "forage_count" then
		return getText(quest.previewKey, quest.forageRequired or 10)
	end
	if quest.type == "collect_water" then
		return getText(quest.previewKey, quest.waterRequired or 2)
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
