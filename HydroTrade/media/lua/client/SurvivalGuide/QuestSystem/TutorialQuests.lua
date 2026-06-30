require "SurvivalGuide/QuestSystem/QuestStorage"
require "SurvivalGuide/QuestSystem/QuestsData"
require "SurvivalGuide/QuestSystem/TutorialQuestNavigation"
require "SurvivalGuide/QuestSystem/TutorialQuestHUD"
require "SurvivalGuide/QuestSystem/TutorialQuestBoard"

TutorialQuests = TutorialQuests or {}

local S = QuestStorage
local UPDATE_TICK_INTERVAL = 15
local HALO_MS = 400
local updateTick = 0

function TutorialQuests.ensureModules()
	if QuestsData and QuestsData.getTutorialChain then
		TutorialQuests._cachedQuestsData = TutorialQuests._cachedQuestsData or QuestsData
	end
	if QuestStorage and QuestStorage.ensure then
		TutorialQuests._cachedQuestStorage = TutorialQuests._cachedQuestStorage or QuestStorage
	end
	if QuestsData == nil or QuestsData.getTutorialChain == nil then
		if TutorialQuests._cachedQuestsData and TutorialQuests._cachedQuestsData.getTutorialChain then
			QuestsData = TutorialQuests._cachedQuestsData
		else
			require "SurvivalGuide/QuestSystem/QuestsData"
			TutorialQuests._cachedQuestsData = QuestsData
		end
	end
	if QuestStorage == nil or QuestStorage.ensure == nil then
		if TutorialQuests._cachedQuestStorage and TutorialQuests._cachedQuestStorage.ensure then
			QuestStorage = TutorialQuests._cachedQuestStorage
		else
			require "SurvivalGuide/QuestSystem/QuestStorage"
			TutorialQuests._cachedQuestStorage = QuestStorage
		end
	end
	return QuestStorage ~= nil and QuestsData ~= nil and QuestsData.getTutorialChain ~= nil
end

local function questId(order)
	if not TutorialQuests.ensureModules() then return nil end
	return QuestsData.getTutorialQuestId(order)
end

function TutorialQuests.getState()
	local player = getPlayer()
	local ui = S.getUi(player)
	return {
		optedIn = S.isTutorialOptedIn(player),
		collapsed = ui.collapsed,
		hidden = ui.hidden,
		hudX = ui.x,
		hudY = ui.y,
	}
end

function TutorialQuests.getEntry(order)
	return S.getEntry(getPlayer(), questId(order))
end

function TutorialQuests.getEntryStatus(order)
	return S.getStatus(getPlayer(), questId(order))
end

function TutorialQuests.getCurrentQuestId()
	if not TutorialQuests.ensureModules() then return nil end
	local player = getPlayer()
	if not player or not S.isTutorialOptedIn(player) then return nil end
	for _, quest in ipairs(QuestsData.getTutorialChain()) do
		local status = S.getStatus(player, quest.id)
		if status < S.S_CLAIMED then
			return quest.chainOrder
		end
	end
	return nil
end

function TutorialQuests.isChainComplete()
	if not TutorialQuests.ensureModules() then return false end
	local player = getPlayer()
	if not player then return false end
	for _, quest in ipairs(QuestsData.getTutorialChain()) do
		if S.getStatus(player, quest.id) ~= S.S_CLAIMED then
			return false
		end
	end
	return S.isTutorialOptedIn(player)
end

function TutorialQuests.needsClaimById(id)
	return S.getStatus(getPlayer(), id) == S.S_COMPLETE
end

function TutorialQuests.getHudQuest()
	if not TutorialQuests.ensureModules() then return nil end
	local player = getPlayer()
	if not player then return nil end
	local tutorialOrder = TutorialQuests.getCurrentQuestId()
	if tutorialOrder then
		return { mode = "tutorial", order = tutorialOrder }
	end
	if not TutorialQuests.isChainComplete() then return nil end
	for _, quest in ipairs(QuestsData.getStoryQuests()) do
		local status = S.getStatus(player, quest.id)
		if status == S.S_ACTIVE or status == S.S_COMPLETE then
			return { mode = "story", def = quest }
		end
	end
	if TutorialQuests.hasTrackedSideQuestsOnHud(player) then
		return { mode = "story_sides" }
	end
	if TutorialQuests.countOfferedSideQuests(player) > 0 then
		return { mode = "board_hint" }
	end
	return { mode = "idle" }
end

function TutorialQuests.completeStorySafehouseQuest(player, method)
	if not TutorialQuests.ensureModules() then return end
	local quest = QuestsData.getQuest("story_first_safehouse")
	if not quest or S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	p.safehouseDone = true
	if method then p.safehouseMethod = method end
	S.setStatus(player, quest.id, S.S_COMPLETE)
	TutorialQuests.showNotice(player, getText(quest.completeKey or "IGUI_StoryQuest_Safehouse_Complete"))
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.tryActivateStoryQuests(player)
	if not TutorialQuests.ensureModules() then return end
	if not player or not TutorialQuests.isChainComplete() then return end
	for _, quest in ipairs(QuestsData.getStoryQuests()) do
		local status = S.getStatus(player, quest.id)
		if status == S.S_CLAIMED then
			-- следующий сюжетный квест в цепочке
		elseif status ~= S.S_INACTIVE then
			return
		else
			local entry = S.ensureEntry(player, quest.id)
			entry.s = S.S_ACTIVE
			if quest.startGrants and not entry.p.startGranted then
				if TutorialQuests.grantQuestStart(player, quest) then
					entry.p.startGranted = true
					local summary = QuestsData.formatStartGrantSummary(quest.startGrants)
					if summary and summary ~= "" then
						TutorialQuests.showNotice(player, getText("IGUI_StoryQuest_StartItems", summary))
					end
				end
			end
			local instantComplete = quest.type == "first_safehouse" and TutorialQuests.playerHasSafehouse(player)
			if not instantComplete then
				TutorialQuests.showNotice(player, getText("IGUI_StoryQuest_Started"))
			end
			if instantComplete then
				local method = "detected"
				local username = player:getUsername()
				local list = SafeHouse.getSafehouseList()
				if list then
					for i = 0, list:size() - 1 do
						local sh = list:get(i)
						if sh:getOwner() ~= username and sh:getPlayers() and sh:getPlayers():contains(username) then
							method = "join"
							break
						end
					end
				end
				TutorialQuests.completeStorySafehouseQuest(player, method)
			end
			if TutorialQuests.instance then
				TutorialQuests.instance:updateLayout()
			end
			return
		end
	end
end

function TutorialQuests.getSurviveHoursProgress(player, quest)
	if not player or not quest then return 0, 24 end
	local need = quest.hoursRequired or 24
	local total = math.floor(player:getHoursSurvived())
	return total, need
end

function TutorialQuests.isSurviveHoursComplete(player, quest)
	local elapsed, need = TutorialQuests.getSurviveHoursProgress(player, quest)
	return elapsed >= need
end

function TutorialQuests.playerHasSafehouse(player)
	if not player then return false end
	if SafeHouse.hasSafehouse(player) then return true end
	local username = player:getUsername()
	local list = SafeHouse.getSafehouseList()
	if not list then return false end
	for i = 0, list:size() - 1 do
		local sh = list:get(i)
		if sh:getOwner() == username then return true end
		if sh:getPlayers() and sh:getPlayers():contains(username) then return true end
	end
	return false
end

function TutorialQuests.isFirstSafehouseComplete(player, quest)
	if not player or not quest then return false end
	local p = S.getProgress(player, quest.id)
	if p.safehouseDone then return true end
	return TutorialQuests.playerHasSafehouse(player)
end

function TutorialQuests.journalHasRecordedSkills(item)
	if not item or item:getType() ~= "SkillRecoveryJournal" then return false end
	local md = item:getModData()
	if not md or not md.SRJ then return false end
	local gained = md.SRJ.gainedXP
	if gained then
		for _, xp in pairs(gained) do
			if xp and xp > 0 then return true end
		end
	end
	local recipes = md.SRJ.learnedRecipes
	if recipes then
		for _, learned in pairs(recipes) do
			if learned then return true end
		end
	end
	return false
end

function TutorialQuests.hasSkillRecoveryJournal(player)
	if not player then return false end
	return player:getInventory():contains("SkillRecoveryJournal")
end

function TutorialQuests.hasTranscribedJournal(player)
	if not player then return false end
	local items = player:getInventory():getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if TutorialQuests.journalHasRecordedSkills(item) then
			return true
		end
	end
	return false
end

function TutorialQuests.getSkillJournalStage(player, quest)
	if not player or not quest then return 1 end
	local p = S.getProgress(player, quest.id)
	if p.journalTranscribed or TutorialQuests.hasTranscribedJournal(player) then return 3 end
	if p.journalCrafted or TutorialQuests.hasSkillRecoveryJournal(player) then return 2 end
	return 1
end

function TutorialQuests.isSkillJournalComplete(player, quest)
	return TutorialQuests.getSkillJournalStage(player, quest) >= 3
end

function TutorialQuests.onCraftActionPerform(player, action)
	if not player or not player:isLocalPlayer() or not action or not action.recipe then return end
	local quest = QuestsData.getQuest("story_skill_journal")
	if not quest or S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local recipeName = action.recipe:getOriginalname()
	local p = S.getProgress(player, quest.id)
	if recipeName == "Bind Journal" then
		p.journalCrafted = true
	elseif recipeName == "Transcribe Journal" and action.changesMade then
		p.journalTranscribed = true
	end
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.onSafehouseClaimed(player)
	if not player then return end
	TutorialQuests.completeStorySafehouseQuest(player, "claim")
end

function TutorialQuests.onSafehouseJoined(player)
	if not player then return end
	TutorialQuests.completeStorySafehouseQuest(player, "join")
end

function TutorialQuests.onSafehouseZoneCreated(player, cellCount)
	if not player then return end
	TutorialQuests.completeStorySafehouseQuest(player, "zone")
end

function TutorialQuests.isPhaseUnlocked(player, phaseId)
	if not player or not phaseId then return false end
	return S.getStatus(player, phaseId) >= S.S_ACTIVE
end

function TutorialQuests.isSideQuestDeclined(player, quest)
	if not quest then return false end
	local entry = S.getEntry(player, quest.id)
	return entry and entry.p and entry.p.declined == true
end

function TutorialQuests.isSideQuestAvailable(player, quest)
	if not quest or not quest.optional then return false end
	if S.getStatus(player, quest.id) == S.S_CLAIMED then return false end
	if TutorialQuests.isSideQuestDeclined(player, quest) then return false end
	if quest.phaseId and not TutorialQuests.isPhaseUnlocked(player, quest.phaseId) then return false end
	if quest.requiresQuestId and S.getStatus(player, quest.requiresQuestId) ~= S.S_CLAIMED then return false end
	if quest.requiresQuestMinComplete and S.getStatus(player, quest.requiresQuestMinComplete) < S.S_COMPLETE then return false end
	return true
end

function TutorialQuests.isSideQuestTracked(player, quest)
	if not quest then return false end
	local entry = S.getEntry(player, quest.id)
	return entry and entry.p and entry.p.tracked == true
end

function TutorialQuests.setSideQuestTracked(questId, tracked)
	local player = getPlayer()
	if not player then return end
	local entry = S.ensureEntry(player, questId)
	entry.p.tracked = tracked == true
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
	if TutorialQuestBoard and TutorialQuestBoard.instance then
		TutorialQuestBoard.instance:refresh()
	end
end

function TutorialQuests.isSideQuestOffered(player, quest)
	if not TutorialQuests.isSideQuestAvailable(player, quest) then return false end
	if quest.autoActivate then return false end
	return S.getStatus(player, quest.id) < S.S_ACTIVE
end

function TutorialQuests.isSideQuestVisibleOnHud(player, quest)
	if not TutorialQuests.isSideQuestAvailable(player, quest) then return false end
	if S.getStatus(player, quest.id) < S.S_ACTIVE then return false end
	return TutorialQuests.isSideQuestTracked(player, quest)
end

function TutorialQuests.getTrackedSideQuestsForHud(player)
	local list = {}
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if TutorialQuests.isSideQuestVisibleOnHud(player, quest) then
			table.insert(list, quest)
		end
	end
	return list
end

function TutorialQuests.countOfferedSideQuests(player)
	local count = 0
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if TutorialQuests.isSideQuestOffered(player, quest) then
			count = count + 1
		end
	end
	return count
end

function TutorialQuests.shouldShowQuestBoardButton(player)
	if not player or not S.isTutorialOptedIn(player) then return false end
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if TutorialQuests.isSideQuestAvailable(player, quest) then
			if S.getStatus(player, quest.id) < S.S_CLAIMED then
				return true
			end
		end
	end
	return false
end

function TutorialQuests.hasTrackedSideQuestsOnHud(player)
	return #TutorialQuests.getTrackedSideQuestsForHud(player) > 0
end

function TutorialQuests.ensureSideQuestTracking(player)
	if not player then return end
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		local status = S.getStatus(player, quest.id)
		if status >= S.S_ACTIVE and status < S.S_CLAIMED then
			local entry = S.ensureEntry(player, quest.id)
			if entry.p.tracked == nil then
				entry.p.tracked = true
			end
			if quest.type == "sew_patch" and entry.p.patchesAtStart == nil then
				entry.p.patchesAtStart = 0
			end
		end
	end
end

-- совместимость
function TutorialQuests.isSurvivePhaseOpen(player)
	return TutorialQuests.isPhaseUnlocked(player, "story_survive_24h")
end

function TutorialQuests.countFish(player)
	if not player then return 0 end
	local count = 0
	local items = player:getInventory():getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if QuestsData.isFishItem(item) then
			count = count + 1
		end
	end
	return count
end

function TutorialQuests.isSideQuestVisible(player, quest)
	return TutorialQuests.isSideQuestAvailable(player, quest)
end

function TutorialQuests.grantStartGrants(player, grants)
	if not player or not grants then return true end
	for _, grant in ipairs(grants) do
		local itemType = grant.item or grant[1]
		local count = grant.count or grant[2] or 1
		for _ = 1, count do
			if not player:getInventory():AddItem(itemType) then
				return false
			end
		end
	end
	return true
end

function TutorialQuests.grantStartItems(player, itemTypes)
	if not player or not itemTypes then return true end
	for _, itemType in ipairs(itemTypes) do
		if not player:getInventory():AddItem(itemType) then
			return false
		end
	end
	return true
end

function TutorialQuests.grantQuestStart(player, quest)
	if not player or not quest then return true end
	if quest.startGrants then
		return TutorialQuests.grantStartGrants(player, quest.startGrants)
	end
	if quest.startItems then
		return TutorialQuests.grantStartItems(player, quest.startItems)
	end
	return true
end

function TutorialQuests.announceQuestStart(player, quest)
	if not player or not quest then return end
	local summary
	if quest.startGrants then
		summary = QuestsData.formatStartGrantSummary(quest.startGrants)
	elseif quest.startItems then
		summary = QuestsData.formatStartGrantSummary(quest.startItems)
	end
	if not summary or summary == "" then return end
	player:Say(getText("IGUI_SideQuest_StartItems", summary))
end

function TutorialQuests.acceptSideQuest(id)
	local player = getPlayer()
	local quest = QuestsData.getQuest(id)
	if not player or not quest or not quest.optional then return end
	if not TutorialQuests.isSideQuestOffered(player, quest) then return end

	if not TutorialQuests.grantQuestStart(player, quest) then
		return
	end

	TutorialQuests.announceQuestStart(player, quest)

	if quest.navTarget or (quest.type == "visit_location" and quest.target) then
		TutorialQuests.showLocationArrow(player, quest.navTarget or quest.target)
	end

	local entry = S.ensureEntry(player, id)
	entry.s = S.S_ACTIVE
	entry.p.tracked = true
	if quest.type == "catch_fish" then
		entry.p.fishAtStart = TutorialQuests.countFish(player)
	elseif quest.type == "kill_count" then
		entry.p.killsAtStart = player:getZombieKills()
	elseif quest.type == "travel_distance" then
		entry.p.travelDistance = 0
		entry.p.travelLastX = player:getX()
		entry.p.travelLastY = player:getY()
	elseif quest.type == "run_distance" then
		entry.p.runDistance = 0
		entry.p.runLastX = player:getX()
		entry.p.runLastY = player:getY()
	elseif quest.type == "sneak_distance" then
		entry.p.sneakDistance = 0
		entry.p.sneakLastX = player:getX()
		entry.p.sneakLastY = player:getY()
	elseif quest.type == "look_around" then
		entry.p.lookedDirs = {}
	elseif quest.type == "flashlight_distance" then
		entry.p.flashDistance = 0
		entry.p.flashLastX = player:getX()
		entry.p.flashLastY = player:getY()
	elseif quest.type == "forage_count" then
		entry.p.searchForageCount = 0
	elseif quest.type == "collect_water" then
		entry.p.waterAtStart = TutorialQuests.countWaterContainers(player)
	elseif quest.type == "sew_patch" then
		entry.p.patchesAtStart = TutorialQuests.countClothingPatches(player)
		entry.p.patchesSewn = 0
	end

	TutorialQuests.showNotice(player, getText("IGUI_SideQuest_Accepted"))
	if TutorialQuestBoard and TutorialQuestBoard.instance then
		TutorialQuestBoard.instance:refresh()
	end
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.countZombiesNear(player, radius)
	if not player then return 999 end
	local cell = getCell()
	if not cell then return 999 end
	local px, py, pz = player:getX(), player:getY(), player:getZ()
	local pzFloor = math.floor(pz)
	local r2 = (radius or 30) * (radius or 30)
	local count = 0
	local zombies = cell:getZombieList()
	if not zombies then return 999 end
	for i = 0, zombies:size() - 1 do
		local zombie = zombies:get(i)
		if zombie and not zombie:isDead() and math.floor(zombie:getZ()) == pzFloor then
			local dx = zombie:getX() - px
			local dy = zombie:getY() - py
			if dx * dx + dy * dy <= r2 then
				count = count + 1
			end
		end
	end
	return count
end

function TutorialQuests.isQuietZoneClear(player, quest)
	if not player or not quest then return false end
	local radius = quest.zombieRadius or 30
	local maxZ = quest.zombieMax or 1
	return TutorialQuests.countZombiesNear(player, radius) <= maxZ
end

function TutorialQuests.updateQuietZoneQuest(player, quest)
	if not player or not quest or quest.type ~= "quiet_zone" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	if p.quietReady then return end
	p.quietTick = (p.quietTick or 0) + 1
	if p.quietTick % 15 ~= 0 then return end
	if TutorialQuests.isQuietZoneClear(player, quest) then
		p.quietReady = true
	end
end

function TutorialQuests.getCardinalDir(player)
	if not player or not player.getDir then return nil end
	local dir = player:getDir()
	if not dir then return nil end
	if dir == IsoDirections.N or dir == IsoDirections.NE or dir == IsoDirections.NW then
		return "N"
	end
	if dir == IsoDirections.E or dir == IsoDirections.SE then
		return "E"
	end
	if dir == IsoDirections.S or dir == IsoDirections.SW then
		return "S"
	end
	if dir == IsoDirections.W or dir == IsoDirections.SW then
		return "W"
	end
	return nil
end

function TutorialQuests.countLookedDirs(progress)
	local count = 0
	if progress and progress.lookedDirs then
		for _, seen in pairs(progress.lookedDirs) do
			if seen then count = count + 1 end
		end
	end
	return count
end

function TutorialQuests.updateLookAround(player, quest)
	if not player or not quest or quest.type ~= "look_around" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local card = TutorialQuests.getCardinalDir(player)
	if not card then return end
	local p = S.getProgress(player, quest.id)
	p.lookedDirs = p.lookedDirs or {}
	p.lookedDirs[card] = true
end

function TutorialQuests.getLookAroundProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.lookDirections or 4
	local current = TutorialQuests.countLookedDirs(p)
	return current, need
end

function TutorialQuests.hasFlashlightInHand(player)
	return QuestsData.hasFlashlightEquipped(player)
end

function TutorialQuests.updateFlashlightDistance(player, quest)
	if not player or not quest or quest.type ~= "flashlight_distance" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	local x, y = player:getX(), player:getY()
	if not TutorialQuests.hasFlashlightInHand(player) then
		p.flashLastX = nil
		p.flashLastY = nil
		return
	end
	if not player:isPlayerMoving() then
		p.flashLastX = x
		p.flashLastY = y
		return
	end
	if p.flashLastX and p.flashLastY then
		local dx = x - p.flashLastX
		local dy = y - p.flashLastY
		local step = math.sqrt(dx * dx + dy * dy)
		if step > 0.05 and step < 40 then
			p.flashDistance = (p.flashDistance or 0) + step
		end
	end
	p.flashLastX = x
	p.flashLastY = y
end

function TutorialQuests.getFlashlightDistanceProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.distanceRequired or 200
	local current = math.floor(p.flashDistance or 0)
	return current, need
end

function TutorialQuests.countInventoryItem(player, itemType)
	if not player or not itemType then return 0 end
	local count = 0
	local inv = player:getInventory()
	if not inv then return 0 end
	local items = inv:getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if item and (item.getFullType and item:getFullType() == itemType or item:getType() == itemType) then
			count = count + 1
		end
	end
	return count
end

function TutorialQuests.getSearchForageProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.forageRequired or 10
	local current = p.searchForageCount or 0
	return current, need
end

function TutorialQuests.updateRestStaminaQuest(player, quest)
	if not player or not quest then return end
	local p = S.getProgress(player, quest.id)
	if p.rested then return end
	if player:isSitOnGround() then
		p.sitTicks = (p.sitTicks or 0) + 1
	end
	local stats = player:getStats()
	if not stats then return end
	local endur = stats:getEndurance()
	local start = p.enduranceAtStart or endur
	if start < 0.4 and endur >= start + 0.18 then
		p.rested = true
	end
	if (p.sitTicks or 0) >= 8 then
		p.rested = true
	end
end

function TutorialQuests.tryAutoActivateRestQuest(player)
	local quest = QuestsData.getQuest("side_rest_stamina")
	if not quest or not TutorialQuests.isPhaseUnlocked(player, "tutorial_3") then return end
	if S.getStatus(player, quest.id) ~= S.S_INACTIVE then return end
	local stats = player:getStats()
	if not stats then return end
	local endur = stats:getEndurance()
	local trigger = quest.enduranceTrigger or 0.35
	if endur > trigger then return end
	local entry = S.ensureEntry(player, quest.id)
	entry.s = S.S_ACTIVE
	entry.p.tracked = true
	entry.p.enduranceAtStart = endur
	entry.p.sitTicks = 0
	TutorialQuests.showNotice(player, getText("IGUI_SideQuest_RestStamina_Start"))
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.onPlayerRest(player)
	if not player or not player:isLocalPlayer() then return end
	local quest = QuestsData.getQuest("side_rest_stamina")
	if not quest or S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	p.rested = true
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.getFishQuestProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.fishRequired or 5
	local caught = math.max(0, TutorialQuests.countFish(player) - (p.fishAtStart or 0))
	return caught, need
end

function TutorialQuests.forEachClothingItem(player, fn)
	if not player or not fn then return end
	local seen = {}
	local function visit(item)
		if not item or seen[item] then return end
		if not item.getPatchType then return end
		seen[item] = true
		fn(item)
	end
	local inv = player:getInventory()
	if inv then
		local items = inv:getItems()
		for i = 0, items:size() - 1 do
			visit(items:get(i))
		end
	end
	local worn = player:getWornItems()
	if worn then
		for i = 0, worn:size() - 1 do
			local wornItem = worn:get(i)
			if wornItem and wornItem.getItem then
				visit(wornItem:getItem())
			end
		end
	end
end

function TutorialQuests.countPatchesOnItem(item)
	if not item or not item.getPatchType or not BloodBodyPartType or not BloodBodyPartType.MAX then
		return 0
	end
	local count = 0
	local maxIndex = BloodBodyPartType.MAX:index()
	for bi = 0, maxIndex - 1 do
		local part = BloodBodyPartType.FromIndex(bi)
		local ok, patch = pcall(function()
			return item:getPatchType(part)
		end)
		if ok and patch then
			count = count + 1
		end
	end
	return count
end

function TutorialQuests.countClothingPatches(player)
	if not player then return 0 end
	local count = 0
	TutorialQuests.forEachClothingItem(player, function(item)
		count = count + TutorialQuests.countPatchesOnItem(item)
	end)
	return count
end

function TutorialQuests.getPatchQuestProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.patchesRequired or 1
	if p.patchesAtStart == nil then
		p.patchesAtStart = 0
	end
	local fromCount = math.max(0, TutorialQuests.countClothingPatches(player) - (p.patchesAtStart or 0))
	local fromHook = p.patchesSewn or 0
	local patches = math.max(fromCount, fromHook)
	return patches, need
end

function TutorialQuests.countWaterContainers(player)
	if not player then return 0 end
	local count = 0
	local items = player:getInventory():getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if item and item.isWaterSource and item:isWaterSource() then
			local used = item.getUsedDelta and item:getUsedDelta() or 1
			if used < 0.99 then
				count = count + 1
			end
		end
	end
	return count
end

function TutorialQuests.getKillQuestProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.killCount or 25
	local kills = math.max(0, player:getZombieKills() - (p.killsAtStart or 0))
	return kills, need
end

function TutorialQuests.getWaterQuestProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.waterRequired or 2
	local filled = math.max(0, TutorialQuests.countWaterContainers(player) - (p.waterAtStart or 0))
	return filled, need
end

function TutorialQuests.isPlayerRunning(player)
	if not player or not player:isPlayerMoving() then return false end
	if player.isSprinting and player:isSprinting() then return true end
	if player.IsRunning and player:IsRunning() then return true end
	if player.isRunning and player:isRunning() then return true end
	return false
end

function TutorialQuests.updateTravelDistance(player, quest)
	if not player or not quest or quest.type ~= "travel_distance" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	local x, y = player:getX(), player:getY()
	if p.travelLastX and p.travelLastY then
		local dx = x - p.travelLastX
		local dy = y - p.travelLastY
		local step = math.sqrt(dx * dx + dy * dy)
		if step > 0.05 and step < 40 then
			p.travelDistance = (p.travelDistance or 0) + step
		end
	end
	p.travelLastX = x
	p.travelLastY = y
end

function TutorialQuests.getTravelDistanceProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.distanceRequired or 500
	local current = math.floor(p.travelDistance or 0)
	return current, need
end

function TutorialQuests.updateRunDistance(player, quest)
	if not player or not quest or quest.type ~= "run_distance" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	local x, y = player:getX(), player:getY()
	if not TutorialQuests.isPlayerRunning(player) then
		p.runLastX = nil
		p.runLastY = nil
		return
	end
	if p.runLastX and p.runLastY then
		local dx = x - p.runLastX
		local dy = y - p.runLastY
		local step = math.sqrt(dx * dx + dy * dy)
		if step > 0.05 and step < 40 then
			p.runDistance = (p.runDistance or 0) + step
		end
	end
	p.runLastX = x
	p.runLastY = y
end

function TutorialQuests.getRunDistanceProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.distanceRequired or 500
	local current = math.floor(p.runDistance or 0)
	return current, need
end

function TutorialQuests.isPlayerSneaking(player)
	if not player or not player.isSneaking then return false end
	return player:isSneaking()
end

function TutorialQuests.updateSneakDistance(player, quest)
	if not player or not quest or quest.type ~= "sneak_distance" then return end
	if S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	local x, y = player:getX(), player:getY()
	if not TutorialQuests.isPlayerSneaking(player) then
		p.sneakLastX = nil
		p.sneakLastY = nil
		return
	end
	if not player:isPlayerMoving() then
		p.sneakLastX = x
		p.sneakLastY = y
		return
	end
	if p.sneakLastX and p.sneakLastY then
		local dx = x - p.sneakLastX
		local dy = y - p.sneakLastY
		local step = math.sqrt(dx * dx + dy * dy)
		if step > 0.05 and step < 40 then
			p.sneakDistance = (p.sneakDistance or 0) + step
		end
	end
	p.sneakLastX = x
	p.sneakLastY = y
end

function TutorialQuests.getSneakDistanceProgress(player, quest)
	local p = S.getProgress(player, quest.id)
	local need = quest.distanceRequired or 200
	local current = math.floor(p.sneakDistance or 0)
	return current, need
end

function TutorialQuests.isPlayerIndoors(player)
	if not player then return false end
	local sq = player:getSquare()
	if not sq then return false end
	if sq.isOutside and not sq:isOutside() then return true end
	if player.getBuilding and player:getBuilding() then return true end
	return false
end

function TutorialQuests.getSideQuestDisplay(player, quest)
	if not player or not quest then return nil end
	if quest.type == "catch_fish" then
		local current, need = TutorialQuests.getFishQuestProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "forage_food" then
		local p = S.getProgress(player, quest.id)
		local need = quest.forageRequired or 1
		local current = p.forageCount or 0
		return { done = current >= need, text = getText(quest.goalKey) }
	end
	if quest.type == "kill_count" then
		local current, need = TutorialQuests.getKillQuestProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "travel_distance" then
		local current, need = TutorialQuests.getTravelDistanceProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "run_distance" then
		local current, need = TutorialQuests.getRunDistanceProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "sneak_distance" then
		local current, need = TutorialQuests.getSneakDistanceProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "collect_water" then
		local current, need = TutorialQuests.getWaterQuestProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "sew_patch" then
		local current, need = TutorialQuests.getPatchQuestProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "light_campfire" then
		local p = S.getProgress(player, quest.id)
		local done = p.campfireLit == true
		return { done = done, text = getText(quest.goalKey) }
	end
	if quest.type == "find_shelter" then
		local done = TutorialQuests.isPlayerIndoors(player)
		return { done = done, text = getText(quest.goalKey) }
	end
	if quest.type == "shop_buy" then
		local p = S.getProgress(player, quest.id)
		local done = p.shopBought == true
		return { done = done, text = getText(quest.goalKey) }
	end
	if quest.type == "visit_location" then
		local target = quest.target
		local radius = quest.visitRadius or 12
		local dist = math.floor(QuestsData.getDistanceToPoint(player:getX(), player:getY(), target))
		local done = QuestsData.isNearPoint(player:getX(), player:getY(), target, radius)
		local text = done and getText(quest.goalKey) or getText(quest.distanceKey or quest.goalKey, dist)
		return { done = done, text = text }
	end
	if quest.type == "quiet_zone" then
		local p = S.getProgress(player, quest.id)
		local done = p.quietReady == true
		return { done = done, text = getText(quest.goalKey) }
	end
	if quest.type == "look_around" then
		local current, need = TutorialQuests.getLookAroundProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "flashlight_distance" then
		local current, need = TutorialQuests.getFlashlightDistanceProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "forage_count" then
		local current, need = TutorialQuests.getSearchForageProgress(player, quest)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "collect_item" then
		local need = quest.collectRequired or 1
		local current = TutorialQuests.countInventoryItem(player, quest.collectItem)
		return { done = current >= need, text = getText(quest.goalKey, current, need) }
	end
	if quest.type == "rest_stamina" then
		local p = S.getProgress(player, quest.id)
		local done = p.rested == true
		return { done = done, text = getText(quest.goalKey) }
	end
	return nil
end

local function completeSideQuest(player, quest)
	if quest.rewardPool and #quest.rewardPool > 0 then
		QuestsData.getPooledRewardItem(quest, S.getProgress(player, quest.id))
	end
	S.setStatus(player, quest.id, S.S_COMPLETE)
	TutorialQuests.showNotice(player, getText(quest.completeKey or "IGUI_SideQuest_Complete"))
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.isSideQuestObjectiveMet(player, quest)
	local display = TutorialQuests.getSideQuestDisplay(player, quest)
	return display and display.done
end

function TutorialQuests.onCampfireLit(player)
	if not player or not player:isLocalPlayer() then return end
	local quest = QuestsData.getQuest("side_campfire")
	if not quest or S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	if p.campfireLit then return end
	p.campfireLit = true
	completeSideQuest(player, quest)
end

function TutorialQuests.onShopPurchase(player)
	if not player or not player:isLocalPlayer() then return end
	if not QuestsData.isInTradeZone(player:getX(), player:getY()) then return end
	local quest = QuestsData.getQuest("side_shop_buy")
	if not quest or S.getStatus(player, quest.id) ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, quest.id)
	if p.shopBought then return end
	p.shopBought = true
	completeSideQuest(player, quest)
end

function TutorialQuests.onPatchSewn(player)
	if not player or not player:isLocalPlayer() then return end
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if quest.type == "sew_patch" and S.getStatus(player, quest.id) == S.S_ACTIVE then
			local p = S.getProgress(player, quest.id)
			p.patchesSewn = (p.patchesSewn or 0) + 1
			local need = quest.patchesRequired or 1
			if p.patchesSewn >= need then
				completeSideQuest(player, quest)
			elseif TutorialQuests.instance then
				TutorialQuests.instance:updateLayout()
			end
			return
		end
	end
end

function TutorialQuests.onVanillaForageSuccess(player)
	if not player or not player:isLocalPlayer() then return end
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if quest.type == "forage_count" and S.getStatus(player, quest.id) == S.S_ACTIVE then
			local p = S.getProgress(player, quest.id)
			p.searchForageCount = (p.searchForageCount or 0) + 1
			local need = quest.forageRequired or 10
			if p.searchForageCount >= need then
				completeSideQuest(player, quest)
			elseif TutorialQuests.instance then
				TutorialQuests.instance:updateLayout()
			end
			return
		end
	end
end

function TutorialQuests.onForageSuccess(player)
	if not player or not player:isLocalPlayer() then return end
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if quest.type == "forage_food" and S.getStatus(player, quest.id) == S.S_ACTIVE then
			local p = S.getProgress(player, quest.id)
			p.forageCount = (p.forageCount or 0) + 1
			local need = quest.forageRequired or 1
			if p.forageCount >= need then
				completeSideQuest(player, quest)
			end
			return
		end
	end
end

function TutorialQuests.updateSideQuests(player)
	TutorialQuests.tryAutoActivateRestQuest(player)
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		local status = S.getStatus(player, quest.id)
		if quest.type == "travel_distance" and status == S.S_ACTIVE then
			TutorialQuests.updateTravelDistance(player, quest)
		elseif quest.type == "run_distance" and status == S.S_ACTIVE then
			TutorialQuests.updateRunDistance(player, quest)
		elseif quest.type == "sneak_distance" and status == S.S_ACTIVE then
			TutorialQuests.updateSneakDistance(player, quest)
		elseif quest.type == "quiet_zone" and status == S.S_ACTIVE then
			TutorialQuests.updateQuietZoneQuest(player, quest)
		elseif quest.type == "look_around" and status == S.S_ACTIVE then
			TutorialQuests.updateLookAround(player, quest)
		elseif quest.type == "flashlight_distance" and status == S.S_ACTIVE then
			TutorialQuests.updateFlashlightDistance(player, quest)
		elseif quest.type == "rest_stamina" and status == S.S_ACTIVE then
			TutorialQuests.updateRestStaminaQuest(player, quest)
		end
		if quest.rewardPool and status >= S.S_COMPLETE and status < S.S_CLAIMED then
			QuestsData.getPooledRewardItem(quest, S.getProgress(player, quest.id))
		end
		if status == S.S_ACTIVE and TutorialQuests.isSideQuestObjectiveMet(player, quest) then
			completeSideQuest(player, quest)
		end
	end
end

function TutorialQuests.saveHudPosition(x, y)
	S.saveHudPosition(getPlayer(), x, y)
end

function TutorialQuests.toggleCollapsed()
	local ui = S.getUi(getPlayer())
	ui.collapsed = not ui.collapsed
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.shouldShowHud()
	local player = getPlayer()
	if not player or not player:isLocalPlayer() then return false end
	if ClientTweaker and ClientTweaker.Options and not ClientTweaker.Options.GetBool("show_tutorial_quests") then
		return false
	end
	return true
end

function TutorialQuests.reopenHud()
	local ui = S.getUi(getPlayer())
	ui.hidden = false
	ui.collapsed = false
	TutorialQuests.ensureHud()
	if TutorialQuests.instance then
		TutorialQuests.instance:setVisible(true)
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.hasLinkedWallet(player)
	if not player or not Currency or not Currency.Wallets then return false end
	local username = player:getUsername()
	local items = player:getInventory():getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if item then
			local itemType = item:getFullType()
			if Currency.Wallets[itemType] then
				local md = item:getModData()
				if md.belongsTo == username and md.linkedTo then
					return true
				end
			end
		end
	end
	return false
end

function TutorialQuests.countJewelry(player)
	if not player then return 0 end
	local count = 0
	local items = player:getInventory():getItems()
	for i = 0, items:size() - 1 do
		local item = items:get(i)
		if item and QuestsData.isJewelry(item:getFullType()) then
			count = count + 1
		end
	end
	return count
end

function TutorialQuests.getQuest1Progress()
	local player = getPlayer()
	if not player then return 0, 0 end
	local p = S.getProgress(player, questId(1))
	local def = QuestsData.getQuestDef(1)
	local kills = math.max(0, player:getZombieKills() - (p.killsAtStart or 0))
	local jewelry = TutorialQuests.countJewelry(player)
	return kills, jewelry, def.killCount, def.jewelryCount
end

function TutorialQuests.isQuest1Complete()
	local kills, jewelry, killNeed, jewelNeed = TutorialQuests.getQuest1Progress()
	return kills >= killNeed and jewelry >= jewelNeed
end

function TutorialQuests.isQuest2Complete(player)
	player = player or getPlayer()
	if not player then return false end
	local p = S.getProgress(player, questId(2))
	return p.walletLinked and p.balanceDone
end

function TutorialQuests.ensureQuest2BalanceStart(player)
	if not player then return end
	local p = S.getProgress(player, questId(2))
	if p.balanceAtStart == nil and Balance and Balance.getUserBalance then
		local coin, _ = Balance.getUserBalance(player:getUsername())
		p.balanceAtStart = coin or 0
	end
end

function TutorialQuests.getQuest2BalanceProgress()
	local player = getPlayer()
	if not player then return 0, QuestsData.QUEST2_BALANCE_MIN end
	TutorialQuests.ensureQuest2BalanceStart(player)
	local p = S.getProgress(player, questId(2))
	local def = QuestsData.getQuestDef(2)
	local coin, _ = Balance.getUserBalance(player:getUsername())
	local gain = math.max(0, (coin or 0) - (p.balanceAtStart or 0))
	return gain, def.balanceMin or QuestsData.QUEST2_BALANCE_MIN
end

function TutorialQuests.updateQuest2Balance(player)
	if not player then return end
	local id = questId(2)
	local status = S.getStatus(player, id)
	if status ~= S.S_ACTIVE then return end
	local p = S.getProgress(player, id)
	if p.balanceDone then return end
	TutorialQuests.ensureQuest2BalanceStart(player)
	local gain, need = TutorialQuests.getQuest2BalanceProgress()
	if gain >= need then
		p.balanceDone = true
	end
end

function TutorialQuests.isQuest3Complete(player)
	if not player then return false end
	return QuestsData.isInTradeZone(player:getX(), player:getY())
end

function TutorialQuests.getTradeZoneDistance(player)
	if not player then return 0 end
	return QuestsData.getDistanceToTradeZone(player:getX(), player:getY())
end

function TutorialQuests.showNotice(player, text)
	if not player or not text then return end
	if string.len(text) > 50 then
		text = string.sub(text, 1, 47) .. "..."
	end
	player:setHaloNote(text, 255, 220, 120, HALO_MS)
end

function TutorialQuests.findNearestAtm()
	local player = getPlayer()
	if not player then return end
	local atm = TutorialQuestNavigation.searchAtm(player, QuestsData.ATM_SEARCH_RADIUS)
	if atm then
		TutorialQuestNavigation.showArrow(player, atm, QuestsData.ARROW_DURATION_MS)
	else
		TutorialQuests.showNotice(player, getText("IGUI_TutorialQuest_AtmNotFound"))
	end
end

function TutorialQuests.findTradeZone()
	local player = getPlayer()
	if not player then return end
	local tz = QuestsData.TRADE_ZONE
	TutorialQuestNavigation.showArrow(player, { x = tz.centerX, y = tz.centerY, z = 0 }, QuestsData.ARROW_DURATION_MS)
end

function TutorialQuests.findAdminShop()
	local player = getPlayer()
	if not player then return end
	local shop = QuestsData.ADMIN_SHOP
	TutorialQuestNavigation.showArrow(player, { x = shop.x, y = shop.y, z = shop.z or 0 }, QuestsData.ARROW_DURATION_MS)
end

function TutorialQuests.showLocationArrow(player, location)
	if not player or not location then return end
	TutorialQuestNavigation.showArrow(player, { x = location.x, y = location.y, z = location.z or 0 }, QuestsData.ARROW_DURATION_MS)
end

function TutorialQuests.findQuestLocation(questId)
	local quest = QuestsData.getQuest(questId)
	if not quest or not quest.target then return end
	TutorialQuests.showLocationArrow(getPlayer(), quest.target)
end

function TutorialQuests.needsClaim(order)
	return TutorialQuests.needsClaimById(questId(order))
end

function TutorialQuests.hasGrantableRewards(def)
	if not def then return false end
	if def.balanceReward and def.balanceReward > 0 then return true end
	if def.rewards and #def.rewards > 0 then return true end
	if def.rewardPool and #def.rewardPool > 0 then return true end
	return false
end

function TutorialQuests.grantRewardItem(player, reward)
	if not player or not reward then return false end
	local itemType = QuestsData.getRewardEntryItemType(reward)
	if not itemType then return false end
	local item = player:getInventory():AddItem(itemType)
	if not item then return false end
	if type(reward) == "table" and item.setCondition then
		if reward.conditionPercent then
			local maxCond = item:getConditionMax()
			local cond = math.max(1, math.floor(maxCond * reward.conditionPercent))
			item:setCondition(cond)
		elseif reward.condition then
			item:setCondition(reward.condition)
		end
	end
	return true
end

function TutorialQuests.grantQuestRewards(player, def)
	if not player or not def then return false end
	if def.balanceReward and def.balanceReward > 0 then
		sendClientCommand(player, "BS", "Deposit", { def.balanceReward, 0 })
	end
	if def.rewards then
		for _, reward in ipairs(def.rewards) do
			if not TutorialQuests.grantRewardItem(player, reward) then
				return false
			end
		end
	end
	if def.rewardPool and #def.rewardPool > 0 then
		local p = S.getProgress(player, def.id)
		local itemType = QuestsData.getPooledRewardItem(def, p)
		if itemType and not player:getInventory():AddItem(itemType) then
			return false
		end
	end
	return true
end

function TutorialQuests.claimRewardById(id)
	local player = getPlayer()
	if not player or not TutorialQuests.needsClaimById(id) then return end

	local def = QuestsData.getQuest(id)
	if not def or not TutorialQuests.hasGrantableRewards(def) then return end

	if not TutorialQuests.grantQuestRewards(player, def) then return end

	S.setStatus(player, id, S.S_CLAIMED)

	if def.category == QuestsData.CATEGORY_STORY and not def.optional then
		TutorialQuests.tryActivateStoryQuests(player)
	end

	if def.chain == QuestsData.CHAIN_TUTORIAL and def.chainOrder then
		local nextId = QuestsData.getTutorialQuestId(def.chainOrder + 1)
		if QuestsData.getQuest(nextId) then
			S.setStatus(player, nextId, S.S_ACTIVE)
			if nextId == "tutorial_2" then
				TutorialQuests.ensureQuest2BalanceStart(player)
			end
		else
			TutorialQuests.tryActivateStoryQuests(player)
		end
	end

	local rewardLabel = QuestsData.getRewardText(id, S.getProgress(player, id))
	TutorialQuests.showNotice(player, getText("IGUI_TutorialQuest_Reward_Got", rewardLabel))
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

function TutorialQuests.claimReward(order)
	TutorialQuests.claimRewardById(questId(order))
end

function TutorialQuests.acceptQuestChain()
	local player = getPlayer()
	if not player or S.isTutorialOptedIn(player) then return end

	S.setTutorialOptedIn(player, true)
	local entry = S.ensureEntry(player, questId(1))
	entry.s = S.S_ACTIVE
	entry.p.killsAtStart = player:getZombieKills()

	TutorialQuests.showNotice(player, getText("IGUI_TutorialQuest_Accepted"))
	TutorialQuests.reopenHud()
end

function TutorialQuests.dismissHud()
	local ui = S.getUi(getPlayer())
	ui.hidden = true
	ui.collapsed = true
	if TutorialQuests.instance then
		TutorialQuests.instance:updateLayout()
	end
end

local function completeQuest(order, noticeKey)
	local player = getPlayer()
	if not player then return end
	local id = questId(order)
	if S.getStatus(player, id) ~= S.S_ACTIVE then return end
	S.setStatus(player, id, S.S_COMPLETE)
	TutorialQuests.showNotice(player, getText(noticeKey))
end

function TutorialQuests.completeQuest1()
	completeQuest(1, "IGUI_TutorialQuest_Quest1_Complete")
end

function TutorialQuests.completeQuest2()
	completeQuest(2, "IGUI_TutorialQuest_Quest2_Complete")
end

function TutorialQuests.completeQuest3()
	local player = getPlayer()
	if not player then return end
	if S.getStatus(player, questId(3)) ~= S.S_ACTIVE then return end
	S.setStatus(player, questId(3), S.S_COMPLETE)
	TutorialQuestNavigation.clear()
	TutorialQuests.showNotice(player, getText("IGUI_TutorialQuest_Quest3_Complete"))
	local shopQuest = QuestsData.getQuest("side_shop_buy")
	if shopQuest and TutorialQuests.isSideQuestAvailable(player, shopQuest) then
		TutorialQuests.showNotice(player, getText("IGUI_SideQuest_ShopBuy_Available"))
		TutorialQuests.showLocationArrow(player, QuestsData.ADMIN_SHOP)
	end
end

function TutorialQuests.ensureHud()
	if TutorialQuests.instance then
		TutorialQuests.instance:setVisible(TutorialQuests.shouldShowHud())
		return
	end

	local hud = TutorialQuestHUD:new()
	hud:initialise()
	hud:instantiate()
	hud:addToUIManager()
	hud:setVisible(TutorialQuests.shouldShowHud())
	TutorialQuests.instance = hud

	local ui = S.getUi(getPlayer())
	if not ui.x or not ui.y then
		local core = getCore()
		hud:setX(TutorialQuestHUD.getDefaultX(core:getScreenWidth(), hud.width))
		hud:setY(TutorialQuestHUD.DEFAULT_Y)
	else
		hud:setX(ui.x)
		hud:setY(ui.y)
	end
	hud:updateLayout()
end

function TutorialQuests.hideHud()
	if TutorialQuests.instance then
		TutorialQuests.instance:setVisible(false)
	end
end

function TutorialQuests.update(player)
	if not player or not player:isLocalPlayer() then return end
	if not TutorialQuests.ensureModules() then
		TutorialQuests.hideHud()
		return
	end

	if not TutorialQuests.shouldShowHud() then
		TutorialQuests.hideHud()
		TutorialQuestNavigation.clear()
		return
	end

	TutorialQuests.ensureHud()
	if TutorialQuests.instance then
		TutorialQuests.instance:setVisible(true)
		TutorialQuests.instance:updateLayout()
	end

	if not S.isTutorialOptedIn(player) then return end

	TutorialQuests.ensureSideQuestTracking(player)

	if S.getStatus(player, questId(1)) == S.S_ACTIVE and TutorialQuests.isQuest1Complete() then
		TutorialQuests.completeQuest1()
	end

	if S.getStatus(player, questId(2)) == S.S_ACTIVE then
		local p = S.getProgress(player, questId(2))
		p.walletLinked = TutorialQuests.hasLinkedWallet(player)
		TutorialQuests.updateQuest2Balance(player)
		if TutorialQuests.isQuest2Complete(player) then
			TutorialQuests.completeQuest2()
		end
	end

	if S.getStatus(player, questId(3)) == S.S_ACTIVE and TutorialQuests.isQuest3Complete(player) then
		TutorialQuests.completeQuest3()
	end

	TutorialQuests.updateSideQuests(player)

	if TutorialQuests.isChainComplete() then
		TutorialQuests.tryActivateStoryQuests(player)
		for _, quest in ipairs(QuestsData.getStoryQuests()) do
			if S.getStatus(player, quest.id) == S.S_ACTIVE then
				if quest.type == "survive_hours" and TutorialQuests.isSurviveHoursComplete(player, quest) then
					S.setStatus(player, quest.id, S.S_COMPLETE)
					local noticeKey = quest.completeKey or "IGUI_StoryQuest_Survive24h_Complete"
					TutorialQuests.showNotice(player, getText(noticeKey))
				elseif quest.type == "first_safehouse" and TutorialQuests.isFirstSafehouseComplete(player, quest) then
					local p = S.getProgress(player, quest.id)
					if not p.safehouseDone then
						TutorialQuests.completeStorySafehouseQuest(player, p.safehouseMethod or "detected")
					end
				elseif quest.type == "skill_journal" then
					local p = S.getProgress(player, quest.id)
					if not p.journalCrafted and TutorialQuests.hasSkillRecoveryJournal(player) then
						p.journalCrafted = true
					end
					if not p.journalTranscribed and TutorialQuests.hasTranscribedJournal(player) then
						p.journalTranscribed = true
					end
					if TutorialQuests.isSkillJournalComplete(player, quest) then
						S.setStatus(player, quest.id, S.S_COMPLETE)
						TutorialQuests.showNotice(player, getText(quest.completeKey or "IGUI_StoryQuest_Journal_Complete"))
					end
				end
			end
		end
	end
end

local function onPlayerUpdate(player)
	updateTick = updateTick + 1
	if updateTick % UPDATE_TICK_INTERVAL ~= 0 then return end
	TutorialQuests.update(player)
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnGameStart.Add(function()
	TutorialQuests.ensureModules()
	if TutorialQuestHooks then
		TutorialQuestHooks.install()
	end
	local player = getPlayer()
	if player then
		TutorialQuests.update(player)
	end
end)

Events.OnCreatePlayer.Add(function()
	TutorialQuests.ensureModules()
	local player = getPlayer()
	if player and player:isLocalPlayer() then
		TutorialQuests.update(player)
	end
end)
