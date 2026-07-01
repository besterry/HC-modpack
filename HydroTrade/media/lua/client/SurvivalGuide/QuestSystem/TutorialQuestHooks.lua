require "SurvivalGuide/QuestSystem/TutorialQuestsData"

TutorialQuestHooks = TutorialQuestHooks or {}

local function wrapMethod(className, requirePath, methodName, keySuffix, wrapper)
	TutorialQuestHooks._wrapped = TutorialQuestHooks._wrapped or {}
	local key = className .. "." .. (keySuffix or methodName)
	if TutorialQuestHooks._wrapped[key] then return true end
	local ok = pcall(require, requirePath)
	if not ok then return false end
	local cls = _G[className]
	if not cls or not cls[methodName] then return false end
	local oldMethod = cls[methodName]
	cls[methodName] = function(self, ...)
		return wrapper(oldMethod, self, ...)
	end
	TutorialQuestHooks._wrapped[key] = true
	return true
end

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

	local fishingPaths = {
		{ "ISFishingAction", "Fishing/TimedActions/ISFishingAction" },
	}
	for _, entry in ipairs(fishingPaths) do
		wrapMethod(entry[1], entry[2], "createFish", "createFish", function(oldCreateFish, self, fishType, fish)
			local fishItem = oldCreateFish(self, fishType, fish)
			if fishItem and self.character and TutorialQuests and TutorialQuests.onFishCaught then
				TutorialQuests.onFishCaught(self.character, fishItem)
			end
			return fishItem
		end)
	end

	wrapMethod("ISFitnessAction", "TimedActions/ISFitnessAction", "perform", "fitness.perform", function(oldPerform, self, ...)
		oldPerform(self, ...)
		if self.character and TutorialQuests and TutorialQuests.onFitnessSessionEnd then
			TutorialQuests.onFitnessSessionEnd(self.character, self)
		end
	end)
	wrapMethod("ISFitnessAction", "TimedActions/ISFitnessAction", "stop", "fitness.stop", function(oldStop, self, ...)
		oldStop(self, ...)
		if self.character and TutorialQuests and TutorialQuests.onFitnessSessionEnd then
			TutorialQuests.onFitnessSessionEnd(self.character, self)
		end
	end)

	wrapMethod("ISUninstallVehiclePart", "Vehicles/TimedActions/ISUninstallVehiclePart", "perform", "vehicle.uninstall", function(oldPerform, self, ...)
		oldPerform(self, ...)
		if self.character and self.part and TutorialQuests and TutorialQuests.onVehicleHeadlightUninstalled then
			TutorialQuests.onVehicleHeadlightUninstalled(self.character, self.part)
		end
	end)
	wrapMethod("ISInstallVehiclePart", "Vehicles/TimedActions/ISInstallVehiclePart", "perform", "vehicle.install", function(oldPerform, self, ...)
		oldPerform(self, ...)
		if self.character and self.part and TutorialQuests and TutorialQuests.onVehicleHeadlightInstalled then
			TutorialQuests.onVehicleHeadlightInstalled(self.character, self.part)
		end
	end)

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
