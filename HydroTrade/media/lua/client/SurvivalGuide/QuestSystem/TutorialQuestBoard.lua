require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "SurvivalGuide/QuestSystem/QuestStorage"

TutorialQuestBoard = ISCollapsableWindow:derive("TutorialQuestBoard")

local S = QuestStorage

local PAD = 8
local BTN_H = 20
local TAB_H = 26
local BOARD_W = 360
local BOARD_H = 480

TutorialQuestBoard.TAB_MAIN = "main"
TutorialQuestBoard.TAB_DAILY = "daily"
TutorialQuestBoard.TAB_REPEATABLE = "repeatable"
TutorialQuestBoard.TAB_SPECIAL = "special"

function TutorialQuestBoard:wrapText(text, maxWidth, font)
	font = font or UIFont.Small
	local tm = getTextManager()
	local lines = {}
	local current = ""
	for word in string.gmatch(tostring(text) .. " ", "(%S+)%s*") do
		local test = current == "" and word or (current .. " " .. word)
		if tm:MeasureStringX(font, test) <= maxWidth then
			current = test
		else
			if current ~= "" then table.insert(lines, current) end
			current = word
		end
	end
	if current ~= "" then table.insert(lines, current) end
	if #lines == 0 then table.insert(lines, "") end
	return lines
end

function TutorialQuestBoard:drawWrapped(y, text, r, g, b, maxWidth)
	for _, line in ipairs(self:wrapText(text, maxWidth, UIFont.Small)) do
		self.contentPane:drawText(line, PAD, y, r, g, b, 1, UIFont.Small)
		y = y + self.lineHgt + 1
	end
	return y
end

function TutorialQuestBoard:measureWrapped(text, maxWidth)
	return #self:wrapText(text, maxWidth, UIFont.Small) * (self.lineHgt + 1)
end

function TutorialQuestBoard:resetZones()
	self.interactZones = {}
	self.tabZones = {}
end

function TutorialQuestBoard:registerZone(zone)
	table.insert(self.interactZones, zone)
end

function TutorialQuestBoard:registerTabZone(zone)
	table.insert(self.tabZones, zone)
end

function TutorialQuestBoard:panelToContentY(panelY)
	if not self.contentPane then return panelY end
	return panelY - self.contentPane:getYScroll()
end

function TutorialQuestBoard:hitZone(x, y)
	local cy = self:panelToContentY(y)
	for _, zone in ipairs(self.interactZones) do
		if x >= zone.x and x <= zone.x + zone.w and cy >= zone.y and cy <= zone.y + zone.h then
			return zone
		end
	end
	return nil
end

function TutorialQuestBoard:bringResizeHandlesToFront()
	if self.resizeWidget then self.resizeWidget:bringToTop() end
	if self.resizeWidget2 then self.resizeWidget2:bringToTop() end
	if self.tabPane then self.tabPane:bringToTop() end
end

function TutorialQuestBoard:resizeWidgetHeight()
	if self.rh then return self.rh end
	if ISCollapsableWindow.resizeWidgetHeight then
		self.rh = ISCollapsableWindow.resizeWidgetHeight(self)
	else
		self.rh = 16
	end
	return self.rh
end

function TutorialQuestBoard:handleZoneClick(zone)
	if not zone then return false end
	if zone.kind == "accept" then
		TutorialQuests.acceptQuest(zone.id)
		self:refresh()
		return true
	elseif zone.kind == "track" then
		TutorialQuests.setSideQuestTracked(zone.id, not zone.tracked)
		self:refresh()
		return true
	elseif zone.kind == "claim" then
		TutorialQuests.claimRewardById(zone.id)
		self:refresh()
		return true
	elseif zone.kind == "repeat" then
		TutorialQuests.claimAndRepeatCyclicQuest(zone.id)
		self:refresh()
		return true
	elseif zone.kind == "tab" then
		self.activeTab = zone.tab
		if self.contentPane then
			self.contentPane:setYScroll(0)
		end
		self:refresh()
		return true
	end
	return false
end

function TutorialQuestBoard:isCyclicTabsUnlocked(player)
	return TutorialQuests.isCyclicUnlocked(player)
end

function TutorialQuestBoard:getVisibleTabs(player)
	local tabs = { self.TAB_MAIN }
	if self:isCyclicTabsUnlocked(player) then
		table.insert(tabs, self.TAB_DAILY)
		table.insert(tabs, self.TAB_REPEATABLE)
		table.insert(tabs, self.TAB_SPECIAL)
	end
	return tabs
end

function TutorialQuestBoard:ensureActiveTab(player)
	local tabs = self:getVisibleTabs(player)
	local valid = false
	for _, tab in ipairs(tabs) do
		if tab == self.activeTab then
			valid = true
			break
		end
	end
	if not valid then
		self.activeTab = self.TAB_MAIN
	end
end

function TutorialQuestBoard:collectBoardQuestsForTab(player, tab)
	local offered = {}
	local active = {}

	if tab == self.TAB_MAIN then
		for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
			if TutorialQuests.isSideQuestOffered(player, quest) or TutorialQuests.isCyclicQuestOffered(player, quest) then
				table.insert(offered, quest)
			elseif S.getStatus(player, quest.id) >= S.S_ACTIVE
				and S.getStatus(player, quest.id) < S.S_CLAIMED then
				table.insert(active, quest)
			end
		end
	elseif tab == self.TAB_DAILY then
		TutorialQuests.ensureCyclicDaily(player)
		for _, quest in ipairs(QuestsData.getCyclicDailyQuests()) do
			if TutorialQuests.isCyclicQuestOffered(player, quest) then
				table.insert(offered, quest)
			elseif S.getStatus(player, quest.id) >= S.S_ACTIVE
				and S.getStatus(player, quest.id) < S.S_CLAIMED then
				table.insert(active, quest)
			end
		end
	elseif tab == self.TAB_REPEATABLE then
		for _, quest in ipairs(QuestsData.getCyclicBackgroundQuests()) do
			if TutorialQuests.isCyclicQuestOffered(player, quest) then
				table.insert(offered, quest)
			elseif S.getStatus(player, quest.id) >= S.S_ACTIVE
				and S.getStatus(player, quest.id) < S.S_CLAIMED then
				table.insert(active, quest)
			end
		end
	elseif tab == self.TAB_SPECIAL then
		for _, quest in ipairs(QuestsData.getSpecialQuests()) do
			if S.getStatus(player, quest.id) >= S.S_ACTIVE
				and S.getStatus(player, quest.id) < S.S_CLAIMED then
				table.insert(active, quest)
			end
		end
	end

	return offered, active
end

function TutorialQuestBoard:hitTabZoneLocal(x, localY)
	for _, zone in ipairs(self.tabZones) do
		if x >= zone.x and x <= zone.x + zone.w and localY >= zone.y and localY <= zone.y + zone.h then
			return zone
		end
	end
	return nil
end

function TutorialQuestBoard:contentPaneMouseDown(x, y)
	local zone = self:hitZone(x, y)
	if self:handleZoneClick(zone) then return true end
	if self.contentPane.vscroll and self.contentPane.vscroll:isMouseOver() then
		return ISPanel.onMouseDown(self.contentPane, x, y)
	end
	return false
end

function TutorialQuestBoard:contentWidth()
	if not self.contentPane then return BOARD_W - PAD * 2 end
	local scrollW = 0
	if self.contentPane:isVScrollBarVisible() and self.contentPane.vscroll then
		scrollW = self.contentPane.vscroll.width or 16
	end
	return self.contentPane.width - PAD * 2 - scrollW
end

function TutorialQuestBoard:estimateTabHeaderHeight(player, tab, maxW)
	local h = 0
	if tab == self.TAB_REPEATABLE then
		h = h + self.lineHgt + 4
	end
	if tab == self.TAB_DAILY then
		h = h + self.lineHgt + 2 + self.lineHgt + 4
	end
	if tab == self.TAB_SPECIAL then
		h = h + self:measureWrapped(getText("IGUI_TutorialQuest_Board_Special_Hint"), maxW) + 4
	end
	return h
end

function TutorialQuestBoard:estimateContentHeight()
	local player = getPlayer()
	self:ensureActiveTab(player)
	local tab = self.activeTab or self.TAB_MAIN
	local h = PAD
	local maxW = self:contentWidth()

	h = h + self:estimateTabHeaderHeight(player, tab, maxW)

	local offered, active = self:collectBoardQuestsForTab(player, tab)

	if #offered > 0 then
		h = h + self.lineHgt + 4
		for _, quest in ipairs(offered) do
			h = h + self.lineHgt + 2
			local progress = QuestStorage.getProgress(player, quest.id)
			local preview = QuestsData.getQuestPreviewText(quest, progress)
			if preview and preview ~= "" then
				h = h + self:measureWrapped(preview, maxW) + 2
			end
			local detail = QuestsData.getQuestDetail(quest, progress)
			if detail then
				h = h + self:measureWrapped(detail, maxW) + 2
			end
			h = h + BTN_H + 8
		end
	end

	if #active > 0 then
		h = h + self.lineHgt + 4
		for _, quest in ipairs(active) do
			h = h + self.lineHgt + BTN_H + 8
		end
	end

	if tab == self.TAB_DAILY then
		local claimed = TutorialQuests.getTodayClaimedDailyQuests(player)
		if #claimed > 0 and (#offered > 0 or #active > 0) then
			h = h + 4
		end
		for _ in ipairs(claimed) do
			h = h + self.lineHgt * 2 + 6
		end
	end

	if #offered == 0 and #active == 0 then
		h = h + self.lineHgt * 2
	end

	return h + PAD
end

function TutorialQuestBoard:updateScrollHeight(contentH)
	if not self.contentPane then return end
	contentH = math.max(contentH or 0, self.contentPane.height)
	if self._scrollContentH ~= contentH then
		self._scrollContentH = contentH
		self.contentPane:setScrollHeight(contentH)
		if self.contentPane.vscroll then
			self.contentPane.vscroll:setX(self.contentPane.width - self.contentPane.vscroll.width)
		end
	end
end

function TutorialQuestBoard:refresh()
	self:updateScrollHeight(self:estimateContentHeight())
end

function TutorialQuestBoard:layoutContentPane()
	if not self.contentPane then return end
	local th = self:titleBarHeight()
	local rh = self.resizable and self:resizeWidgetHeight() or 0
	local tabH = 0
	if self.tabPane then
		tabH = TAB_H
		self.tabPane:setX(0)
		self.tabPane:setY(th)
		self.tabPane:setWidth(self.width)
		self.tabPane:setHeight(tabH)
	end
	self.contentPane:setX(0)
	self.contentPane:setY(th + tabH)
	self.contentPane:setWidth(self.width)
	self.contentPane:setHeight(math.max(40, self.height - th - tabH - rh))
	if self.contentPane.vscroll then
		self.contentPane.vscroll:setX(self.contentPane.width - self.contentPane.vscroll.width)
		self.contentPane.vscroll:setHeight(self.contentPane.height)
	end
	self:bringResizeHandlesToFront()
	self:refresh()
end

function TutorialQuestBoard:renderClaimedDailyBlock(y, quest, player, maxW)
	local progress = QuestStorage.getProgress(player, quest.id)
	local tr = QuestsData.getQuestAccent(quest).title
	self.contentPane:drawText(QuestsData.getQuestTitle(quest, progress), PAD, y, tr[1], tr[2], tr[3], 1, UIFont.Small)
	y = y + self.lineHgt
	self.contentPane:drawText(getText("IGUI_Cyclic_Daily_ClaimedStatus"), PAD, y, 0.55, 0.75, 0.55, 1, UIFont.Small)
	return y + self.lineHgt + 6
end

function TutorialQuestBoard:drawClaimRepeatButtons(y, questId, showRepeat, maxW)
	if not showRepeat then
		self.contentPane:drawRect(PAD, y, maxW, BTN_H, 0.85, 0.15, 0.45, 0.2)
		self.contentPane:drawRectBorder(PAD, y, maxW, BTN_H, 0.9, 0.45, 0.8, 0.45)
		self.contentPane:drawTextCentre(getText("IGUI_TutorialQuest_Claim_Short"), PAD + maxW / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
		self:registerZone({ kind = "claim", id = questId, x = PAD, y = y, w = maxW, h = BTN_H })
		return y + BTN_H + 8
	end
	local gap = 4
	local btnW = math.floor((maxW - gap) / 2)
	self.contentPane:drawRect(PAD, y, btnW, BTN_H, 0.85, 0.15, 0.45, 0.2)
	self.contentPane:drawRectBorder(PAD, y, btnW, BTN_H, 0.9, 0.45, 0.8, 0.45)
	self.contentPane:drawTextCentre(getText("IGUI_TutorialQuest_Claim_Short"), PAD + btnW / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
	self:registerZone({ kind = "claim", id = questId, x = PAD, y = y, w = btnW, h = BTN_H })
	local rx = PAD + btnW + gap
	self.contentPane:drawRect(rx, y, btnW, BTN_H, 0.85, 0.18, 0.32, 0.42)
	self.contentPane:drawRectBorder(rx, y, btnW, BTN_H, 0.9, 0.42, 0.62, 0.72)
	self.contentPane:drawTextCentre(getText("IGUI_Cyclic_Repeat"), rx + btnW / 2, y + 4, 1, 0.92, 0.88, 1, UIFont.Small)
	self:registerZone({ kind = "repeat", id = questId, x = rx, y = y, w = btnW, h = BTN_H })
	return y + BTN_H + 8
end

function TutorialQuestBoard:renderQuestBlock(y, quest, player, maxW)
	local progress = QuestStorage.getProgress(player, quest.id)
	local tr = QuestsData.getQuestAccent(quest).title
	self.contentPane:drawText(QuestsData.getQuestTitle(quest, progress), PAD, y, tr[1], tr[2], tr[3], 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.isSideQuestOffered(player, quest) or TutorialQuests.isCyclicQuestOffered(player, quest) then
		local preview = QuestsData.getQuestPreviewText(quest, progress)
		if preview and preview ~= "" then
			y = self:drawWrapped(y, preview, 0.8, 0.85, 0.75, maxW)
			y = y + 2
		end
		local detail = QuestsData.getQuestDetail(quest, progress)
		if detail then
			y = self:drawWrapped(y, detail, 0.72, 0.8, 0.7, maxW)
			y = y + 2
		end
		self.contentPane:drawRect(PAD, y, maxW, BTN_H, 0.85, 0.12, 0.35, 0.35)
		self.contentPane:drawRectBorder(PAD, y, maxW, BTN_H, 0.9, 0.35, 0.65, 0.55)
		self.contentPane:drawTextCentre(getText("IGUI_TutorialQuest_Board_Accept"), PAD + maxW / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
		self:registerZone({ kind = "accept", id = quest.id, x = PAD, y = y, w = maxW, h = BTN_H })
		return y + BTN_H + 8
	end

	local tracked = TutorialQuests.isCyclicQuestTracked(player, quest) or TutorialQuests.isSideQuestTracked(player, quest)
	local status = QuestStorage.getStatus(player, quest.id)
	if status == QuestStorage.S_COMPLETE and TutorialQuests.isBackgroundCyclicQuest(quest) then
		local reward = QuestsData.getRewardText(quest.id, progress)
		if reward and reward ~= "" then
			self.contentPane:drawText(getText("IGUI_TutorialQuest_Reward", reward), PAD, y, 0.95, 0.82, 0.35, 1, UIFont.Small)
			y = y + self.lineHgt + 4
		end
		return self:drawClaimRepeatButtons(y, quest.id, TutorialQuests.canRepeatBackgroundCyclic(player, quest), maxW)
	end
	local statusKey = status == QuestStorage.S_COMPLETE and "IGUI_TutorialQuest_Board_Done" or "IGUI_TutorialQuest_Board_Active"
	self.contentPane:drawText(getText(statusKey), PAD, y, 0.7, 0.8, 0.7, 1, UIFont.Small)
	y = y + self.lineHgt + 2
	local trackLabel = tracked and "IGUI_TutorialQuest_Board_Untrack" or "IGUI_TutorialQuest_Board_Track"
	self.contentPane:drawRect(PAD, y, maxW, BTN_H, 0.85, 0.15, 0.28, 0.25)
	self.contentPane:drawRectBorder(PAD, y, maxW, BTN_H, 0.9, 0.45, 0.55, 0.45)
	self.contentPane:drawTextCentre(getText(trackLabel), PAD + maxW / 2, y + 4, 1, 0.95, 0.9, 1, UIFont.Small)
	self:registerZone({ kind = "track", id = quest.id, tracked = tracked, x = PAD, y = y, w = maxW, h = BTN_H })
	return y + BTN_H + 8
end

function TutorialQuestBoard:renderTabBar()
	if not self.tabPane then return end
	self.tabZones = {}
	local player = getPlayer()
	self:ensureActiveTab(player)
	local tabs = self:getVisibleTabs(player)
	local tabW = math.floor(self.width / math.max(#tabs, 1))
	local labels = {
		[self.TAB_MAIN] = "IGUI_TutorialQuest_Board_Tab_Main",
		[self.TAB_DAILY] = "IGUI_TutorialQuest_Board_Tab_Daily",
		[self.TAB_REPEATABLE] = "IGUI_TutorialQuest_Board_Tab_Repeatable",
		[self.TAB_SPECIAL] = "IGUI_TutorialQuest_Board_Tab_Special",
	}
	for i, tab in ipairs(tabs) do
		local x = (i - 1) * tabW
		local active = tab == self.activeTab
		local style = QuestsData.getBoardTabAccent(tab, active)
		local bg, border, text = style.bg, style.border, style.text
		self.tabPane:drawRect(x, 0, tabW - 1, TAB_H, 0.9, bg[1], bg[2], bg[3])
		self.tabPane:drawRectBorder(x, 0, tabW - 1, TAB_H, 0.85, border[1], border[2], border[3])
		self.tabPane:drawTextCentre(getText(labels[tab] or tab), x + tabW / 2, 6, text[1], text[2], text[3], 1, UIFont.Small)
		self:registerTabZone({ kind = "tab", tab = tab, x = x, y = 0, w = tabW - 1, h = TAB_H })
	end
end

function TutorialQuestBoard:renderContent()
	if not self.contentPane then return end

	self:resetZones()

	local player = getPlayer()
	if not player then return end

	self:ensureActiveTab(player)
	local tab = self.activeTab or self.TAB_MAIN
	local maxW = self:contentWidth()
	local y = PAD
	local offered, active = self:collectBoardQuestsForTab(player, tab)

	if tab == self.TAB_REPEATABLE then
		local activeCount = TutorialQuests.countActiveBackgroundCyclics(player)
		self.contentPane:drawText(getText("IGUI_Cyclic_Background_ActiveCount", activeCount, QuestsData.MAX_BACKGROUND_CYCLIC), PAD, y, 0.75, 0.85, 0.7, 1, UIFont.Small)
		y = y + self.lineHgt + 4
	end
	if tab == self.TAB_DAILY then
		self.contentPane:drawText(TutorialQuests.formatGameDayResetCountdown(), PAD, y, 0.75, 0.85, 0.7, 1, UIFont.Small)
		y = y + self.lineHgt + 2
		local done, total = TutorialQuests.getDailyClaimedCount(player)
		if total > 0 then
			self.contentPane:drawText(getText("IGUI_Cyclic_Daily_Progress", done, total), PAD, y, 0.75, 0.85, 0.7, 1, UIFont.Small)
			y = y + self.lineHgt + 4
		end
	end
	if tab == self.TAB_SPECIAL then
		local sp = QuestsData.getPoolAccent("special").title
		y = self:drawWrapped(y, getText("IGUI_TutorialQuest_Board_Special_Hint"), sp[1] * 0.85, sp[2] * 0.85, sp[3] * 0.85, maxW)
		y = y + 4
	end

	local stencilW = self.contentPane.width
	if self.contentPane:isVScrollBarVisible() and self.contentPane.vscroll then
		stencilW = self.contentPane.vscroll.x + 3
	end
	self.contentPane:setStencilRect(0, 0, stencilW, self.contentPane.height)

	if #offered > 0 then
		self.contentPane:drawText(getText("IGUI_TutorialQuest_Board_Available"), PAD, y, 0.85, 0.9, 0.75, 1, UIFont.Small)
		y = y + self.lineHgt + 4
		for i, quest in ipairs(offered) do
			if i > 1 then
				y = y + 4
				self.contentPane:drawRect(PAD, y, maxW, 1, 0.45, 0.35, 0.35, 0.5)
				y = y + 6
			end
			y = self:renderQuestBlock(y, quest, player, maxW)
		end
	end

	if #active > 0 then
		y = y + 4
		self.contentPane:drawText(getText("IGUI_TutorialQuest_Board_ActiveList"), PAD, y, 0.85, 0.9, 0.75, 1, UIFont.Small)
		y = y + self.lineHgt + 4
		for i, quest in ipairs(active) do
			if i > 1 then y = y + 4 end
			y = self:renderQuestBlock(y, quest, player, maxW)
		end
	end

	if tab == self.TAB_DAILY then
		local claimed = TutorialQuests.getTodayClaimedDailyQuests(player)
		if #claimed > 0 then
			if #offered > 0 or #active > 0 then
				y = y + 4
			end
			for i, quest in ipairs(claimed) do
				if i > 1 then
					y = y + 2
					self.contentPane:drawRect(PAD, y, maxW, 1, 0.45, 0.35, 0.35, 0.35)
					y = y + 6
				end
				y = self:renderClaimedDailyBlock(y, quest, player, maxW)
			end
		end
	end

	if #offered == 0 and #active == 0 then
		if tab == self.TAB_DAILY then
			if #TutorialQuests.getTodayClaimedDailyQuests(player) > 0 then
				y = y + 4
			end
			y = self:drawWrapped(y, TutorialQuests.getDailyBoardEmptyText(player), 0.7, 0.75, 0.7, maxW)
			y = y + 4
			y = self:drawWrapped(y, getText("IGUI_Cyclic_Daily_ResetHint"), 0.6, 0.7, 0.65, maxW)
		else
			self.contentPane:drawText(getText("IGUI_TutorialQuest_Board_Empty"), PAD, y, 0.7, 0.75, 0.7, 1, UIFont.Small)
			y = y + self.lineHgt
		end
	end

	self:updateScrollHeight(y + PAD)
	self.contentPane:clearStencilRect()
end

function TutorialQuestBoard:createChildren()
	if self.contentPane then return end
	ISCollapsableWindow.createChildren(self)

	local th = self:titleBarHeight()
	local rh = self.resizable and self:resizeWidgetHeight() or 0

	self.tabPane = ISPanel:new(0, th, self.width, TAB_H)
	self.tabPane.backgroundColor = { r = 0, g = 0, b = 0, a = 0.01 }
	self.tabPane.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	self.tabPane.drawBorder = false
	self.tabPane:initialise()
	self.tabPane:instantiate()
	self.tabPane:setAnchorRight(true)
	self:addChild(self.tabPane)

	self.contentPane = ISPanel:new(0, th + TAB_H, self.width, self.height - th - TAB_H - rh)
	self.contentPane.backgroundColor = { r = 0, g = 0, b = 0, a = 0.01 }
	self.contentPane.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	self.contentPane.drawBorder = false
	self.contentPane:initialise()
	self.contentPane:instantiate()
	self.contentPane:addScrollBars(false)
	self.contentPane:setScrollWithParent(false)
	self.contentPane:setAnchorRight(true)
	self.contentPane:setAnchorBottom(true)
	self:addChild(self.contentPane)
	self:bringResizeHandlesToFront()

	local board = self
	function self.tabPane:prerender()
		ISPanel.prerender(self)
		board:renderTabBar()
	end

	function self.tabPane:onMouseDown(x, y)
		local zone = board:hitTabZoneLocal(x, y)
		return board:handleZoneClick(zone)
	end

	function self.contentPane:prerender()
		ISPanel.prerender(self)
		board:renderContent()
	end

	function self.contentPane:onMouseDown(x, y)
		return board:contentPaneMouseDown(x, y)
	end

	function self.contentPane:onMouseWheel(del)
		self:setYScroll(self:getYScroll() - del * 24)
		return true
	end
end

function TutorialQuestBoard:onResize()
	ISCollapsableWindow.onResize(self)
	self:layoutContentPane()
end

function TutorialQuestBoard:onMouseDown(x, y)
	if not self.contentPane then return ISCollapsableWindow.onMouseDown(self, x, y) end
	local th = self:titleBarHeight()
	if self.tabPane and y >= th and y < th + TAB_H then
		local zone = self:hitTabZoneLocal(x, y - th)
		if self:handleZoneClick(zone) then return true end
	end
	local contentY = th + (self.tabPane and TAB_H or 0)
	if y >= contentY and y < self.contentPane:getY() + self.contentPane.height then
		if self:contentPaneMouseDown(x, y - contentY) then return true end
	end
	return ISCollapsableWindow.onMouseDown(self, x, y)
end

function TutorialQuestBoard:onMouseUp(x, y)
	return ISCollapsableWindow.onMouseUp(self, x, y)
end

function TutorialQuestBoard:onMouseWheel(del)
	if not self.contentPane then return false end
	if self.contentPane:isMouseOver() or self:isMouseOver() then
		self.contentPane:setYScroll(self.contentPane:getYScroll() - del * 24)
		return true
	end
	return false
end

function TutorialQuestBoard:initialise()
	ISCollapsableWindow.initialise(self)
	self.interactZones = {}
	self.tabZones = {}
	self.activeTab = self.TAB_MAIN
	self.lineHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
	self.resizable = true
	self:setResizable(true)
	self:setTitle(getText("IGUI_TutorialQuest_Board_Title"))
end

function TutorialQuestBoard:open()
	if not self.contentPane then
		self:createChildren()
	end
	self.resizable = true
	if self.setResizable then self:setResizable(true) end
	self:layoutContentPane()
	self:setVisible(true)
	self:bringToTop()
	self:refresh()
end

function TutorialQuestBoard:toggleVisible()
	if self:isVisible() then
		self:setVisible(false)
	else
		self:open()
	end
end

function TutorialQuestBoard.ensure()
	if TutorialQuestBoard.instance then
		TutorialQuestBoard.instance.resizable = true
		if TutorialQuestBoard.instance.setResizable then
			TutorialQuestBoard.instance:setResizable(true)
		end
		if not TutorialQuestBoard.instance.contentPane then
			TutorialQuestBoard.instance:createChildren()
		end
		TutorialQuestBoard.instance:layoutContentPane()
		return TutorialQuestBoard.instance
	end
	local core = getCore()
	local x = (core:getScreenWidth() - BOARD_W) / 2
	local y = (core:getScreenHeight() - BOARD_H) / 2
	local o = TutorialQuestBoard:new(x, y, BOARD_W, BOARD_H)
	o:initialise()
	o:createChildren()
	o:addToUIManager()
	o:setVisible(false)
	TutorialQuestBoard.instance = o
	return o
end

function TutorialQuestBoard.toggle()
	if not TutorialQuests.shouldShowHud() then return end
	TutorialQuestBoard.ensure():toggleVisible()
end

function TutorialQuestBoard:new(x, y, width, height)
	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.borderColor = { r = 0.4, g = 0.35, b = 0.35, a = 1 }
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.85 }
	o.resizable = true
	return o
end
