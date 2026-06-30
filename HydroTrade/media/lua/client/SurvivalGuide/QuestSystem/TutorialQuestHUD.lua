require "ISUI/ISPanel"

TutorialQuestHUD = ISPanel:derive("TutorialQuestHUD")

local HEADER_H = 22
local PAD = 6
local CONTENT_BOTTOM_PAD = 12
local DEFAULT_W = 280
TutorialQuestHUD.DEFAULT_W = DEFAULT_W
TutorialQuestHUD.DEFAULT_MARGIN_RIGHT = 60
TutorialQuestHUD.DEFAULT_Y = 72

function TutorialQuestHUD.getDefaultX(screenWidth, panelWidth)
	panelWidth = panelWidth or DEFAULT_W
	return screenWidth - panelWidth - TutorialQuestHUD.DEFAULT_MARGIN_RIGHT
end
local REWARD_RGB = { 1.0, 0.82, 0.35 }
local DONE_RGB = { 0.45, 1.0, 0.5 }
local CLAIM_BTN_H = 20
local SEPARATOR_PAD = 6

function TutorialQuestHUD:getTextMaxWidth()
	return (self.width or DEFAULT_W) - PAD * 2
end

function TutorialQuestHUD:wrapText(text, maxWidth, font)
	font = font or UIFont.Small
	local tm = getTextManager()
	local lines = {}
	local current = ""
	for word in string.gmatch(tostring(text) .. " ", "(%S+)%s*") do
		local test = current == "" and word or (current .. " " .. word)
		if tm:MeasureStringX(font, test) <= maxWidth then
			current = test
		else
			if current ~= "" then
				table.insert(lines, current)
			end
			current = word
		end
	end
	if current ~= "" then
		table.insert(lines, current)
	end
	if #lines == 0 then
		table.insert(lines, "")
	end
	return lines
end

function TutorialQuestHUD:measureWrappedText(text, font)
	font = font or UIFont.Small
	local lines = self:wrapText(text, self:getTextMaxWidth(), font)
	return #lines * (self.lineHgt + 1)
end

function TutorialQuestHUD:drawWrappedText(y, text, r, g, b, a, font)
	font = font or UIFont.Small
	for _, line in ipairs(self:wrapText(text, self:getTextMaxWidth(), font)) do
		self:drawText(line, PAD, y, r, g, b, a, font)
		y = y + self.lineHgt + 1
	end
	return y
end

function TutorialQuestHUD:measureRewardBlock(questRef)
	local h = self.lineHgt + 2
	local progress = nil
	if type(questRef) == "string" then
		local player = getPlayer()
		if player then
			progress = QuestStorage.getProgress(player, questRef)
		end
	end
	for _ in ipairs(QuestsData.getRewardLines(questRef, progress)) do
		h = h + self.lineHgt + 1
	end
	return h + 2
end

function TutorialQuestHUD:measureSideQuestSection()
	local h = 0
	local player = getPlayer()
	if not player then return 0 end
	local sideQuests = TutorialQuests.getTrackedSideQuestsForHud(player)
	local anySide = false
	for _, sideQuest in ipairs(sideQuests) do
		local qh = self:estimateSideQuestHeight(sideQuest, player)
		if qh > 0 then
			if not anySide then
				h = h + self:measureSeparator() + self:measureWrappedText(getText("IGUI_SideQuest_Tracked"))
				anySide = true
			else
				h = h + self:measureSeparator()
			end
			h = h + qh
		end
	end
	local offered = TutorialQuests.countOfferedSideQuests(player)
	if TutorialQuests.shouldShowQuestBoardButton(player) then
		h = h + self:measureSeparator() + CLAIM_BTN_H + 6
	end
	return h
end

function TutorialQuestHUD:drawSeparator(y)
	y = y + SEPARATOR_PAD
	self:drawRect(PAD, y, self.width - PAD * 2, 1, 0.45, 0.35, 0.35, 0.5)
	return y + SEPARATOR_PAD
end

function TutorialQuestHUD:measureSeparator()
	return SEPARATOR_PAD * 2 + 1
end

function TutorialQuestHUD:initialise()
	ISPanel.initialise(self)
	self.headerH = HEADER_H
	self.moveWithMouse = false
	self.moveStartX = 0
	self.moveStartY = 0
	self.claimBtnY = 0
	self.findBtnY = 0
	self.interactZones = {}
end

function TutorialQuestHUD:resetInteractZones()
	self.interactZones = {}
	self.claimBtnY = 0
	self.findBtnY = 0
end

function TutorialQuestHUD:registerZone(zone)
	table.insert(self.interactZones, zone)
end

function TutorialQuestHUD:hitZone(y)
	for _, zone in ipairs(self.interactZones) do
		if y >= zone.y and y <= zone.y + zone.h then
			return zone
		end
	end
	return nil
end
function TutorialQuestHUD:instantiate()
	ISPanel.instantiate(self)
	if self.javaObject then
		self.javaObject:setConsumeMouseEvents(false)
	end
end

function TutorialQuestHUD:drawRewardLine(y, questRef)
	self:drawText(getText("IGUI_TutorialQuest_Reward_Label"), PAD, y, REWARD_RGB[1], REWARD_RGB[2], REWARD_RGB[3], 1, UIFont.Small)
	y = y + self.lineHgt + 1
	local progress = nil
	if type(questRef) == "string" then
		local player = getPlayer()
		if player then
			progress = QuestStorage.getProgress(player, questRef)
		end
	end
	for _, name in ipairs(QuestsData.getRewardLines(questRef, progress)) do
		self:drawText("  - " .. name, PAD, y, REWARD_RGB[1], REWARD_RGB[2], REWARD_RGB[3], 1, UIFont.Small)
		y = y + self.lineHgt + 1
	end
	return y + 2
end

function TutorialQuestHUD:drawObjectiveLine(y, done, text)
	local mark = done and "[+]" or "[ ]"
	local color = done and DONE_RGB or { 0.95, 0.9, 0.85 }
	self:drawText(mark .. " " .. text, PAD, y, color[1], color[2], color[3], 1, UIFont.Small)
	return y + self.lineHgt + 2
end

function TutorialQuestHUD:drawNavButton(y, questId, labelKey)
	self:drawRect(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.85, 0.12, 0.28, 0.35)
	self:drawRectBorder(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.9, 0.35, 0.55, 0.55)
	self:drawTextCentre(getText(labelKey or "IGUI_TutorialQuest_FindZone"), self.width / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
	self:registerZone({ kind = "nav", id = questId, y = y, h = CLAIM_BTN_H })
	return y + CLAIM_BTN_H + 6
end

function TutorialQuestHUD:drawActionButton(y, labelKey)
	self.findBtnY = y
	self:drawRect(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.85, 0.12, 0.28, 0.35)
	self:drawRectBorder(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.9, 0.35, 0.55, 0.55)
	self:drawTextCentre(getText(labelKey), self.width / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
	return y + CLAIM_BTN_H + 6
end

function TutorialQuestHUD:drawClaimButton(y, questRef)
	self.claimBtnY = y
	self:drawRect(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.85, 0.15, 0.45, 0.2)
	self:drawRectBorder(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.9, 0.45, 0.8, 0.45)
	local label = getText("IGUI_TutorialQuest_Claim_Short")
	self:drawTextCentre(label, self.width / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
	self:registerZone({ kind = "claim", id = questRef, y = y, h = CLAIM_BTN_H })
	return y + CLAIM_BTN_H + 6
end

function TutorialQuestHUD:onMouseDown(x, y)
	local data = TutorialQuests.getState()
	if data.hidden then
		TutorialQuests.reopenHud()
		return true
	end

	local zone = self:hitZone(y)
	if zone then
		if zone.kind == "claim" then
			if type(zone.id) == "number" then
				TutorialQuests.claimReward(zone.id)
			else
				TutorialQuests.claimRewardById(zone.id)
			end
			return true
		elseif zone.kind == "accept" then
			TutorialQuests.acceptSideQuest(zone.id)
			return true
		elseif zone.kind == "board" then
			TutorialQuestBoard.toggle()
			return true
		elseif zone.kind == "nav" then
			TutorialQuests.findQuestLocation(zone.id)
			return true
		end
	end

	if self.findBtnY > 0 and y >= self.findBtnY and y <= self.findBtnY + CLAIM_BTN_H then
		local hudQuest = TutorialQuests.getHudQuest()
		local order = hudQuest and hudQuest.mode == "tutorial" and hudQuest.order
		if order == 2 then
			TutorialQuests.findNearestAtm()
			return true
		elseif order == 3 then
			TutorialQuests.findTradeZone()
			return true
		end
	end

	if y > self.headerH then
		if not data.optedIn then
			TutorialQuests.acceptQuestChain()
			return true
		end
		return false
	end
	if x >= self.width - 22 then
		TutorialQuests.toggleCollapsed()
		return true
	end
	self.moveWithMouse = true
	self.moveStartX = x
	self.moveStartY = y
	return true
end

function TutorialQuestHUD:onRightMouseDown(x, y)
	TutorialQuests.dismissHud()
	return true
end

function TutorialQuestHUD:onMouseMove(dx, dy)
	if not self.moveWithMouse then return end
	self:setX(self.x + dx)
	self:setY(self.y + dy)
	TutorialQuests.saveHudPosition(self.x, self.y)
end

function TutorialQuestHUD:onMouseUp(x, y)
	self.moveWithMouse = false
end

function TutorialQuestHUD:renderPrompt(y)
	self:drawText(getText("IGUI_TutorialQuest_Prompt"), PAD, y, 0.9, 0.85, 0.75, 1, UIFont.Small)
	y = y + self.lineHgt + 4
	for _, quest in ipairs(QuestsData.getTutorialChain()) do
		local line = getText("IGUI_TutorialQuest_PreviewLine", getText(quest.titleKey), QuestsData.getRewardText(quest.chainOrder))
		y = self:drawWrappedText(y, line, 0.8, 0.78, 0.72, 1)
		y = y + 1
	end
	y = y + 2
	self:drawText(getText("IGUI_TutorialQuest_AcceptHint"), PAD, y, 0.55, 0.8, 0.55, 1, UIFont.Small)
	return y + self.lineHgt
end

function TutorialQuestHUD:renderQuest1(y)
	local order = 1
	self:drawText(getText("IGUI_TutorialQuest_Quest1_Title"), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaim(order) then
		y = self:drawRewardLine(y, order)
		return self:drawClaimButton(y, order)
	end

	local kills, jewelry, killNeed, jewelNeed = TutorialQuests.getQuest1Progress()
	y = self:drawObjectiveLine(y, kills >= killNeed, getText("IGUI_TutorialQuest_Quest1_Kills", kills, killNeed))
	y = self:drawObjectiveLine(y, jewelry >= jewelNeed, getText("IGUI_TutorialQuest_Quest1_Jewelry", jewelry, jewelNeed))
	y = self:drawRewardLine(y, order)
	return y
end

function TutorialQuestHUD:renderQuest2(y)
	local order = 2
	local player = getPlayer()
	local p = QuestStorage.getProgress(player, QuestsData.getTutorialQuestId(2))

	self:drawText(getText("IGUI_TutorialQuest_Quest2_Title"), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaim(order) then
		y = self:drawRewardLine(y, order)
		return self:drawClaimButton(y, order)
	end

	y = self:drawObjectiveLine(y, p.walletLinked, getText("IGUI_TutorialQuest_Quest2_Wallet"))
	if not p.walletLinked then
		y = self:drawWrappedText(y, getText("IGUI_TutorialQuest_Quest2_WalletHint"), 0.55, 0.75, 0.95, 1)
		y = y + 2
	end
	local gain, need = TutorialQuests.getQuest2BalanceProgress()
	local gainText = (Currency and Currency.format) and Currency.format(gain) or tostring(gain)
	local needText = (Currency and Currency.format) and Currency.format(need) or tostring(need)
	local balanceDone = gain >= need
	y = self:drawObjectiveLine(y, balanceDone, getText("IGUI_TutorialQuest_Quest2_Balance", gainText, needText))
	if not balanceDone then
		y = self:drawWrappedText(y, getText("IGUI_TutorialQuest_Quest2_SellHint"), 0.55, 0.8, 0.55, 1)
		y = y + 2
		y = self:drawActionButton(y, "IGUI_TutorialQuest_FindAtm")
	end
	y = self:drawRewardLine(y, order)
	return y
end

function TutorialQuestHUD:renderQuest3(y)
	local quest = QuestsData.getQuestDef(3)
	self:drawText(getText("IGUI_TutorialQuest_Quest3_Title"), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaim(3) then
		y = self:drawRewardLine(y, 3)
		return self:drawClaimButton(y, 3)
	end

	local player = getPlayer()
	local inZone = player and TutorialQuests.isQuest3Complete(player)
	if quest and quest.detailKey and not inZone then
		y = self:drawWrappedText(y, getText(quest.detailKey), 0.7, 0.82, 0.7, 1)
		y = y + 2
	end
	y = self:drawObjectiveLine(y, inZone, getText("IGUI_TutorialQuest_Quest3_Go"))
	if player and not inZone then
		local dist = math.floor(TutorialQuests.getTradeZoneDistance(player))
		self:drawText(getText("IGUI_TutorialQuest_Quest3_Distance", dist), PAD, y, 0.55, 0.82, 0.95, 1, UIFont.Small)
		y = y + self.lineHgt + 2
		if quest.hintKey then
			y = self:drawWrappedText(y, getText(quest.hintKey), 0.55, 0.78, 0.55, 1)
			y = y + 2
		end
	end
	y = self:drawActionButton(y, "IGUI_TutorialQuest_FindZone")
	y = self:drawRewardLine(y, 3)
	return y
end

function TutorialQuestHUD:renderStorySurvive(y, quest)
	self:drawText(getText(quest.titleKey), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaimById(quest.id) then
		y = self:drawRewardLine(y, quest.id)
		return self:drawClaimButton(y, quest.id)
	end

	local player = getPlayer()
	local elapsed, need = TutorialQuests.getSurviveHoursProgress(player, quest)
	y = self:drawObjectiveLine(y, elapsed >= need, getText("IGUI_StoryQuest_Survive24h_Goal", elapsed, need))
	if quest.hintKey then
		y = self:drawWrappedText(y, getText(quest.hintKey), 0.55, 0.78, 0.55, 1)
		y = y + 2
	end
	y = self:drawRewardLine(y, quest.id)
	return y
end

function TutorialQuestHUD:renderStorySafehouse(y, quest)
	self:drawText(getText(quest.titleKey), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaimById(quest.id) then
		y = self:drawRewardLine(y, quest.id)
		return self:drawClaimButton(y, quest.id)
	end

	local player = getPlayer()
	local done = TutorialQuests.isFirstSafehouseComplete(player, quest)
	if quest.detailKey then
		y = self:drawWrappedText(y, getText(quest.detailKey), 0.7, 0.82, 0.7, 1)
		y = y + 2
	end
	if quest.goalKey then
		y = self:drawObjectiveLine(y, done, getText(quest.goalKey))
	end
	if quest.hintKey then
		y = self:drawWrappedText(y, getText(quest.hintKey), 0.55, 0.78, 0.55, 1)
		y = y + 2
	end
	y = self:drawRewardLine(y, quest.id)
	return y
end

function TutorialQuestHUD:renderStoryJournal(y, quest)
	self:drawText(getText(quest.titleKey), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaimById(quest.id) then
		y = self:drawRewardLine(y, quest.id)
		return self:drawClaimButton(y, quest.id)
	end

	local player = getPlayer()
	local stage = TutorialQuests.getSkillJournalStage(player, quest)

	if stage == 1 and quest.detailKey then
		y = self:drawWrappedText(y, getText(quest.detailKey), 0.7, 0.82, 0.7, 1)
		y = y + 2
	end

	local craftDone = stage >= 2
	y = self:drawObjectiveLine(y, craftDone, getText(quest.goalKey1))
	if stage == 1 and quest.hintKey1 then
		y = self:drawWrappedText(y, getText(quest.hintKey1), 0.55, 0.78, 0.55, 1)
		y = y + 2
	end

	if craftDone then
		if quest.detailKey2 then
			y = self:drawWrappedText(y, getText(quest.detailKey2), 0.7, 0.82, 0.7, 1)
			y = y + 2
		end
		local writeDone = stage >= 3
		y = self:drawObjectiveLine(y, writeDone, getText(quest.goalKey2))
		if stage == 2 and quest.hintKey2 then
			y = self:drawWrappedText(y, getText(quest.hintKey2), 0.55, 0.78, 0.55, 1)
			y = y + 2
		end
	end

	y = self:drawRewardLine(y, quest.id)
	return y
end

function TutorialQuestHUD:estimateTutorialQuestHeight(order)
	if TutorialQuests.needsClaim(order) then
		return self.lineHgt + 2 + self:measureRewardBlock(order) + CLAIM_BTN_H + 6
	end
	local h = self.lineHgt + 2
	if order == 1 then
		h = h + (self.lineHgt + 2) * 2
		h = h + self:measureRewardBlock(order)
	elseif order == 2 then
		local player = getPlayer()
		local p = QuestStorage.getProgress(player, QuestsData.getTutorialQuestId(2))
		h = h + self.lineHgt + 2
		if not p.walletLinked then
			h = h + self:measureWrappedText(getText("IGUI_TutorialQuest_Quest2_WalletHint")) + 2
		end
		h = h + self.lineHgt + 2
		local gain, need = TutorialQuests.getQuest2BalanceProgress()
		if gain < need then
			h = h + self:measureWrappedText(getText("IGUI_TutorialQuest_Quest2_SellHint")) + 2
			h = h + CLAIM_BTN_H + 6
		end
		h = h + self:measureRewardBlock(order)
	elseif order == 3 then
		h = h + self.lineHgt + 2
		local player = getPlayer()
		local quest3 = QuestsData.getQuestDef(3)
		if quest3 and quest3.detailKey then
			h = h + self:measureWrappedText(getText(quest3.detailKey)) + 2
		end
		if player and not TutorialQuests.isQuest3Complete(player) then
			h = h + self.lineHgt + 2
			if quest3 and quest3.hintKey then
				h = h + self:measureWrappedText(getText(quest3.hintKey)) + 2
			end
		end
		h = h + CLAIM_BTN_H + 6
		h = h + self:measureRewardBlock(order)
	end
	return h
end

function TutorialQuestHUD:estimateSideQuestHeight(quest, player)
	if not TutorialQuests.isSideQuestVisibleOnHud(player, quest) then return 0 end
	local h = self.lineHgt + 2
	if TutorialQuests.needsClaimById(quest.id) then
		return h + self:measureRewardBlock(quest.id) + CLAIM_BTN_H + 6
	end
	h = h + self.lineHgt + 2
	if quest.detailKey then
		h = h + self:measureWrappedText(getText(quest.detailKey)) + 2
	end
	if quest.hintKey then
		h = h + self:measureWrappedText(getText(quest.hintKey))
	end
	if quest.navTarget then
		h = h + CLAIM_BTN_H + 6
	end
	return h + self:measureRewardBlock(quest.id) + 6
end

function TutorialQuestHUD:renderSideQuestBlock(y, quest, player)
	if not TutorialQuests.isSideQuestVisibleOnHud(player, quest) then return y end

	self:drawText(getText(quest.titleKey), PAD, y, 0.85, 0.9, 0.8, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.needsClaimById(quest.id) then
		y = self:drawRewardLine(y, quest.id)
		return self:drawClaimButton(y, quest.id)
	end

	local display = TutorialQuests.getSideQuestDisplay(player, quest)
	if display then
		y = self:drawObjectiveLine(y, display.done, display.text)
		if quest.detailKey then
			y = self:drawWrappedText(y, getText(quest.detailKey), 0.72, 0.8, 0.7, 1)
			y = y + 2
		end
		if quest.hintKey then
			y = self:drawWrappedText(y, getText(quest.hintKey), 0.55, 0.78, 0.55, 1)
			y = y + 2
		end
	end
	if quest.navTarget and (not display or not display.done) then
		y = self:drawNavButton(y, quest.id, quest.navButtonKey)
	end
	y = self:drawRewardLine(y, quest.id)
	return y + 6
end

function TutorialQuestHUD:drawBoardButton(y)
	local count = TutorialQuests.countOfferedSideQuests(getPlayer())
	local label
	if count > 0 then
		label = getText("IGUI_TutorialQuest_Board_OpenCount", count)
	else
		label = getText("IGUI_TutorialQuest_Board_Open")
	end
	self:drawRect(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.85, 0.18, 0.22, 0.32)
	self:drawRectBorder(PAD, y, self.width - PAD * 2, CLAIM_BTN_H, 0.9, 0.4, 0.5, 0.55)
	self:drawTextCentre(label, self.width / 2, y + 4, 1, 0.92, 0.88, 1, UIFont.Small)
	self:registerZone({ kind = "board", y = y, h = CLAIM_BTN_H })
	return y + CLAIM_BTN_H + 6
end

function TutorialQuestHUD:renderBoardButton(y, skipSeparator)
	if not TutorialQuests.shouldShowQuestBoardButton(getPlayer()) then return y end
	if not skipSeparator then
		y = self:drawSeparator(y)
	end
	return self:drawBoardButton(y)
end

function TutorialQuestHUD:renderBoardHint(y)
	return self:renderBoardButton(y)
end

function TutorialQuestHUD:renderSideQuests(y)
	local player = getPlayer()
	local sideQuests = TutorialQuests.getTrackedSideQuestsForHud(player)
	if #sideQuests == 0 then return y end

	y = self:drawSeparator(y)
	y = self:drawWrappedText(y, getText("IGUI_SideQuest_Tracked"), 0.7, 0.75, 0.85, 1)
	y = y + 2
	for i, quest in ipairs(sideQuests) do
		if i > 1 then
			y = self:drawSeparator(y)
		end
		y = self:renderSideQuestBlock(y, quest, player)
	end
	return y
end

function TutorialQuestHUD:renderChainDone(y)
	self:drawText(getText("IGUI_TutorialQuest_AllDone"), PAD, y, DONE_RGB[1], DONE_RGB[2], DONE_RGB[3], 1, UIFont.Small)
	return y + self.lineHgt
end

function TutorialQuestHUD:prerender()
	if not TutorialQuests.ensureModules() then
		self:setVisible(false)
		return
	end
	if not TutorialQuests.shouldShowHud() then
		self:setVisible(false)
		return
	end
	self:setVisible(true)
	self:resetInteractZones()

	local data = TutorialQuests.getState()
	if data.hudX and data.hudY then
		self:setX(data.hudX)
		self:setY(data.hudY)
	end

	self:drawRect(0, 0, self.width, self.height, 0.75, 0.05, 0.05, 0.08)
	self:drawRectBorder(0, 0, self.width, self.height, 0.9, 0.35, 0.35, 0.45)

	self:drawRect(0, 0, self.width, self.headerH, 0.85, 0.12, 0.08, 0.12)
	self:drawText(getText("IGUI_TutorialQuest_Title"), PAD, 4, 1, 0.9, 0.85, 1, UIFont.Small)

	local collapseLabel = data.hidden and "+" or (data.collapsed and "+" or "-")
	self:drawText(collapseLabel, self.width - 16, 3, 1, 1, 1, 1, UIFont.Medium)

	if data.hidden or data.collapsed then
		return
	end

	local y = self.headerH + 6
	if not data.optedIn then
		self:renderPrompt(y)
		return
	end

	local hudQuest = TutorialQuests.getHudQuest()
	if hudQuest and hudQuest.mode == "tutorial" then
		local order = hudQuest.order
		if order == 1 then
			self:renderQuest1(y)
		elseif order == 2 then
			self:renderQuest2(y)
		elseif order == 3 then
			y = self:renderQuest3(y)
			y = self:renderSideQuests(y)
			y = self:renderBoardHint(y)
		end
		return
	end

	if hudQuest and hudQuest.mode == "story" then
		local quest = hudQuest.def
		if quest.type == "survive_hours" then
			y = self:renderStorySurvive(y, quest)
		elseif quest.type == "first_safehouse" then
			y = self:renderStorySafehouse(y, quest)
		elseif quest.type == "skill_journal" then
			y = self:renderStoryJournal(y, quest)
		end
		y = self:renderSideQuests(y)
		y = self:renderBoardHint(y)
		return
	end

	if hudQuest and hudQuest.mode == "story_sides" then
		y = self:renderSideQuests(y)
		y = self:renderBoardHint(y)
		return
	end

	if hudQuest and hudQuest.mode == "board_hint" then
		self:renderBoardButton(y, true)
		return
	end

	self:renderChainDone(y)
end

function TutorialQuestHUD:createChildren()
	ISPanel.createChildren(self)
	self.lineHgt = self.SMALL_FONT_HGT or getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
end

function TutorialQuestHUD:estimateContentHeight(data)
	if not TutorialQuests.ensureModules() then
		return self.headerH + PAD
	end
	local chainLen = #QuestsData.getTutorialChain()
	if not data.optedIn then
		return self.headerH + self.lineHgt * (chainLen + 3) + PAD * 2
	end

	local hudQuest = TutorialQuests.getHudQuest()
	if hudQuest and hudQuest.mode == "tutorial" then
		local order = hudQuest.order
		local h = self.headerH + 6 + self:estimateTutorialQuestHeight(order)
		if order == 3 then
			h = h + self:measureSideQuestSection()
		end
		return h
	elseif hudQuest and hudQuest.mode == "story" then
		local h = self.headerH + PAD + 6
		local quest = hudQuest.def
		if TutorialQuests.needsClaimById(quest.id) then
			h = h + self:measureRewardBlock(quest.id) + CLAIM_BTN_H + PAD
		else
			h = h + self.lineHgt + 2
			if quest.type == "skill_journal" then
				local player = getPlayer()
				local stage = TutorialQuests.getSkillJournalStage(player, quest)
				if stage == 1 and quest.detailKey then
					h = h + self:measureWrappedText(getText(quest.detailKey)) + 2
				end
				h = h + self.lineHgt + 2
				if stage == 1 and quest.hintKey1 then
					h = h + self:measureWrappedText(getText(quest.hintKey1)) + 2
				end
				if stage >= 2 then
					if quest.detailKey2 then
						h = h + self:measureWrappedText(getText(quest.detailKey2)) + 2
					end
					h = h + self.lineHgt + 2
					if stage == 2 and quest.hintKey2 then
						h = h + self:measureWrappedText(getText(quest.hintKey2)) + 2
					end
				end
			else
				if quest.detailKey then
					h = h + self:measureWrappedText(getText(quest.detailKey)) + 2
				end
				if quest.goalKey then
					h = h + self.lineHgt + 2
				end
				if quest.hintKey then
					h = h + self:measureWrappedText(getText(quest.hintKey))
				end
			end
			h = h + self:measureRewardBlock(quest.id) + PAD
		end
		local player = getPlayer()
		local sideQuests = TutorialQuests.getTrackedSideQuestsForHud(player)
		local anySide = false
		for _, sideQuest in ipairs(sideQuests) do
			local qh = self:estimateSideQuestHeight(sideQuest, player)
			if qh > 0 then
				if not anySide then
					h = h + self:measureSeparator() + self:measureWrappedText(getText("IGUI_SideQuest_Tracked"))
					anySide = true
				else
					h = h + self:measureSeparator()
				end
				h = h + qh
			end
		end
		if TutorialQuests.shouldShowQuestBoardButton(player) then
			h = h + self:measureSeparator() + CLAIM_BTN_H + 6
		end
		return h
	elseif hudQuest and hudQuest.mode == "story_sides" then
		local h = self.headerH + PAD + 6
		local player = getPlayer()
		local sideQuests = TutorialQuests.getTrackedSideQuestsForHud(player)
		if #sideQuests > 0 then
			h = h + self:measureSeparator() + self:measureWrappedText(getText("IGUI_SideQuest_Tracked"))
			local blockIndex = 0
			for _, sideQuest in ipairs(sideQuests) do
				local qh = self:estimateSideQuestHeight(sideQuest, player)
				if qh > 0 then
					if blockIndex > 0 then
						h = h + self:measureSeparator()
					end
					h = h + qh
					blockIndex = blockIndex + 1
				end
			end
		end
		if TutorialQuests.shouldShowQuestBoardButton(player) then
			h = h + self:measureSeparator() + CLAIM_BTN_H + 6
		end
		return h
	elseif hudQuest and hudQuest.mode == "board_hint" then
		return self.headerH + PAD + 6 + CLAIM_BTN_H + 6
	end
	return self.headerH + self.lineHgt + PAD
end

function TutorialQuestHUD:updateLayout()
	local data = TutorialQuests.getState()
	self:setWidth(DEFAULT_W)
	local h = self.headerH
	if data.hidden or data.collapsed then
		h = self.headerH
	else
		h = self:estimateContentHeight(data) + CONTENT_BOTTOM_PAD
	end
	self:setHeight(h)
end

function TutorialQuestHUD:new()
	local core = getCore()
	local w = core:getScreenWidth()
	local o = ISPanel:new(TutorialQuestHUD.getDefaultX(w), TutorialQuestHUD.DEFAULT_Y, DEFAULT_W, 80)
	setmetatable(o, self)
	self.__index = self
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.6 }
	o.moveWithMouse = false
	return o
end
