require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "SurvivalGuide/QuestSystem/QuestStorage"

TutorialQuestBoard = ISCollapsableWindow:derive("TutorialQuestBoard")

local S = QuestStorage

local PAD = 8
local BTN_H = 20
local BOARD_W = 360
local BOARD_H = 480

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
end

function TutorialQuestBoard:registerZone(zone)
	table.insert(self.interactZones, zone)
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
		TutorialQuests.acceptSideQuest(zone.id)
		self:refresh()
		return true
	elseif zone.kind == "track" then
		TutorialQuests.setSideQuestTracked(zone.id, not zone.tracked)
		self:refresh()
		return true
	end
	return false
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

function TutorialQuestBoard:estimateContentHeight()
	local player = getPlayer()
	local h = PAD
	local maxW = self:contentWidth()

	local offered = {}
	local active = {}
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if TutorialQuests.isSideQuestOffered(player, quest) then
			table.insert(offered, quest)
		elseif QuestStorage.getStatus(player, quest.id) >= QuestStorage.S_ACTIVE
			and QuestStorage.getStatus(player, quest.id) < QuestStorage.S_CLAIMED then
			table.insert(active, quest)
		end
	end

	if #offered > 0 then
		h = h + self.lineHgt + 4
		for _, quest in ipairs(offered) do
			h = h + self.lineHgt + 2
			if quest.previewKey then
				h = h + self:measureWrapped(QuestsData.getQuestPreviewText(quest), maxW) + 2
			end
			if quest.detailKey then
				h = h + self:measureWrapped(getText(quest.detailKey), maxW) + 2
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
	self.contentPane:setX(0)
	self.contentPane:setY(th)
	self.contentPane:setWidth(self.width)
	self.contentPane:setHeight(math.max(40, self.height - th - rh))
	if self.contentPane.vscroll then
		self.contentPane.vscroll:setX(self.contentPane.width - self.contentPane.vscroll.width)
		self.contentPane.vscroll:setHeight(self.contentPane.height)
	end
	self:bringResizeHandlesToFront()
	self:refresh()
end

function TutorialQuestBoard:renderQuestBlock(y, quest, player, maxW)
	self.contentPane:drawText(getText(quest.titleKey), PAD, y, 1, 0.92, 0.85, 1, UIFont.Small)
	y = y + self.lineHgt + 2

	if TutorialQuests.isSideQuestOffered(player, quest) then
		if quest.previewKey then
			y = self:drawWrapped(y, QuestsData.getQuestPreviewText(quest), 0.8, 0.85, 0.75, maxW)
			y = y + 2
		end
		if quest.detailKey then
			y = self:drawWrapped(y, getText(quest.detailKey), 0.72, 0.8, 0.7, maxW)
			y = y + 2
		end
		self.contentPane:drawRect(PAD, y, maxW, BTN_H, 0.85, 0.12, 0.35, 0.35)
		self.contentPane:drawRectBorder(PAD, y, maxW, BTN_H, 0.9, 0.35, 0.65, 0.55)
		self.contentPane:drawTextCentre(getText("IGUI_TutorialQuest_Board_Accept"), PAD + maxW / 2, y + 4, 1, 1, 0.9, 1, UIFont.Small)
		self:registerZone({ kind = "accept", id = quest.id, x = PAD, y = y, w = maxW, h = BTN_H })
		return y + BTN_H + 8
	end

	local tracked = TutorialQuests.isSideQuestTracked(player, quest)
	local status = QuestStorage.getStatus(player, quest.id)
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

function TutorialQuestBoard:renderContent()
	if not self.contentPane then return end

	self:resetZones()

	local player = getPlayer()
	if not player then return end

	local maxW = self:contentWidth()
	local y = PAD
	local offered = {}
	local active = {}
	for _, quest in ipairs(QuestsData.getAllOptionalQuests()) do
		if TutorialQuests.isSideQuestOffered(player, quest) then
			table.insert(offered, quest)
		elseif QuestStorage.getStatus(player, quest.id) >= QuestStorage.S_ACTIVE
			and QuestStorage.getStatus(player, quest.id) < QuestStorage.S_CLAIMED then
			table.insert(active, quest)
		end
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

	if #offered == 0 and #active == 0 then
		self.contentPane:drawText(getText("IGUI_TutorialQuest_Board_Empty"), PAD, y, 0.7, 0.75, 0.7, 1, UIFont.Small)
		y = y + self.lineHgt
	end

	self:updateScrollHeight(y + PAD)
	self.contentPane:clearStencilRect()
end

function TutorialQuestBoard:createChildren()
	if self.contentPane then return end
	ISCollapsableWindow.createChildren(self)

	local th = self:titleBarHeight()
	local rh = self.resizable and self:resizeWidgetHeight() or 0
	self.contentPane = ISPanel:new(0, th, self.width, self.height - th - rh)
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
	if y >= th and y < self.contentPane:getY() + self.contentPane.height then
		if self:contentPaneMouseDown(x, y - th) then return true end
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
