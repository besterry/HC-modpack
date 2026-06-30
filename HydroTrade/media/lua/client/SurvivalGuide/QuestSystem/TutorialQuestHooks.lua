require "SurvivalGuide/QuestSystem/TutorialQuestsData"

TutorialQuestHooks = TutorialQuestHooks or {}

local function wrapPerform(className, requirePath, onDone)
	TutorialQuestHooks._wrapped = TutorialQuestHooks._wrapped or {}
	if TutorialQuestHooks._wrapped[className] then return true end
	local ok = pcall(require, requirePath)
	if not ok then return false end
	local cls = _G[className]
	if not cls or not cls.perform then return false end
	local oldPerform = cls.perform
	function cls:perform()
		oldPerform(self)
		if onDone and self.character then
			onDone(self.character, self)
		end
	end
	TutorialQuestHooks._wrapped[className] = true
	return true
end

function TutorialQuestHooks.install()
	if TutorialQuestHooks._installed then return true end
	TutorialQuestHooks._installed = true

	local campfirePaths = {
		{ "ISLightFromKindle", "TimedActions/ISLightFromKindle" },
		{ "ISLightFromLiterature", "TimedActions/ISLightFromLiterature" },
		{ "ISLightFromPetrol", "TimedActions/ISLightFromPetrol" },
		{ "ISLightFromKindle", "Camping/TimedActions/ISLightFromKindle" },
		{ "ISLightFromLiterature", "Camping/TimedActions/ISLightFromLiterature" },
		{ "ISLightFromPetrol", "Camping/TimedActions/ISLightFromPetrol" },
	}
	for _, entry in ipairs(campfirePaths) do
		wrapPerform(entry[1], entry[2], function(character)
			if TutorialQuests and TutorialQuests.onCampfireLit then
				TutorialQuests.onCampfireLit(character)
			end
		end)
	end

	local patchPaths = {
		{ "ISRepairClothing", "TimedActions/ISRepairClothing" },
		{ "ISAddFabricToClothing", "TimedActions/ISAddFabricToClothing" },
	}
	for _, entry in ipairs(patchPaths) do
		wrapPerform(entry[1], entry[2], function(character)
			if TutorialQuests and TutorialQuests.onPatchSewn then
				TutorialQuests.onPatchSewn(character)
			end
		end)
	end

	wrapPerform("ShopBuyAction", "TimedActions/ShopBuyAction", function(character)
		if TutorialQuests and TutorialQuests.onShopPurchase then
			TutorialQuests.onShopPurchase(character)
		end
	end)

	wrapPerform("ISCraftAction", "TimedActions/ISCraftAction", function(character, action)
		if TutorialQuests and TutorialQuests.onCraftActionPerform then
			TutorialQuests.onCraftActionPerform(character, action)
		end
	end)

	wrapPerform("ISRestAction", "TimedActions/ISRestAction", function(character)
		if TutorialQuests and TutorialQuests.onPlayerRest then
			TutorialQuests.onPlayerRest(character)
		end
	end)

	local foragePaths = {
		{ "ISForageAction", "Foraging/TimedActions/ISForageAction" },
		{ "ISForageAction", "TimedActions/ISForageAction" },
	}
	for _, entry in ipairs(foragePaths) do
		wrapPerform(entry[1], entry[2], function(character)
			if TutorialQuests and TutorialQuests.onVanillaForageSuccess then
				TutorialQuests.onVanillaForageSuccess(character)
			end
		end)
	end

	if Events.AcceptedSafehouseInvite then
		Events.AcceptedSafehouseInvite.Add(function()
			local player = getPlayer()
			if TutorialQuests and TutorialQuests.onSafehouseJoined and player then
				TutorialQuests.onSafehouseJoined(player)
			end
		end)
	end

	return true
end

Events.OnGameStart.Add(TutorialQuestHooks.install)
