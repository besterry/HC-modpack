require "ISUI/ISCollapsableWindow"
require "ISUI/ISTextEntryBox"
require "ISUI/ISTickBox"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISToolTip"

-- Hierarchical mockup:
-- Section rail -> Group tiles -> Entry grid -> Detail (variants / build)

HT_BuildCatalogUI = ISCollapsableWindow:derive("HT_BuildCatalogUI")
HT_BuildCatalogUI.instance = nil

HT_BuildGridPanel = ISPanel:derive("HT_BuildGridPanel")

local PANEL_W = 1020
local PANEL_H = 640
local RAIL_W = 70
local DETAIL_W = 320
local PAD = 8
local CELL = 104
local CELL_GAP = 8

local COL = {
	bg = { r = 0.07, g = 0.08, b = 0.09, a = 1 },
	panel = { r = 0.11, g = 0.12, b = 0.13, a = 1 },
	panelSoft = { r = 0.15, g = 0.16, b = 0.17, a = 1 },
	border = { r = 0.32, g = 0.34, b = 0.36, a = 1 },
	accent = { r = 0.88, g = 0.58, b = 0.22, a = 1 },
	text = { r = 0.93, g = 0.93, b = 0.9, a = 1 },
	muted = { r = 0.62, g = 0.62, b = 0.58, a = 1 },
	ok = { r = 0.45, g = 0.82, b = 0.5, a = 1 },
	bad = { r = 0.85, g = 0.4, b = 0.35, a = 1 },
	hp = { r = 0.9, g = 0.82, b = 0.4, a = 1 },
	frame = { r = 0.45, g = 0.65, b = 0.85, a = 1 },
	style = { r = 0.75, g = 0.55, b = 0.35, a = 1 },
}

local function utf8Len(text)
	local n = 0
	local i = 1
	local len = #text
	while i <= len do
		local c = string.byte(text, i)
		if not c then
			break
		end
		if c < 128 then
			i = i + 1
		elseif c < 224 then
			i = i + 2
		elseif c < 240 then
			i = i + 3
		else
			i = i + 4
		end
		n = n + 1
	end
	return n
end

local function utf8Sub(text, maxChars)
	local n = 0
	local i = 1
	local len = #text
	local last = 0
	while i <= len and n < maxChars do
		local c = string.byte(text, i)
		if not c then
			break
		end
		if c < 128 then
			i = i + 1
		elseif c < 224 then
			i = i + 2
		elseif c < 240 then
			i = i + 3
		else
			i = i + 4
		end
		n = n + 1
		last = i - 1
	end
	return string.sub(text, 1, last)
end

local function truncate(text, maxChars)
	if not text then
		return ""
	end
	if utf8Len(text) <= maxChars then
		return text
	end
	return utf8Sub(text, math.max(1, maxChars - 2)) .. ".."
end

local function truncateToWidth(text, font, maxW)
	if not text or text == "" then
		return ""
	end
	local tm = getTextManager()
	if tm:MeasureStringX(font, text) <= maxW then
		return text
	end
	local left = 1
	local right = utf8Len(text)
	local best = ".."
	while left <= right do
		local mid = math.floor((left + right) / 2)
		local candidate = utf8Sub(text, mid) .. ".."
		if tm:MeasureStringX(font, candidate) <= maxW then
			best = candidate
			left = mid + 1
		else
			right = mid - 1
		end
	end
	return best
end

-- Word-wrap by pixel width (ASCII spaces). Avoids mid-word / mid-UTF-8 cuts.
local function wrapWordsToWidth(text, font, maxW, maxLines)
	local out = {}
	if not text or text == "" or maxW < 8 then
		return out
	end
	local tm = getTextManager()
	local cur = ""
	for w in string.gmatch(text, "%S+") do
		local trial = (cur == "") and w or (cur .. " " .. w)
		if tm:MeasureStringX(font, trial) <= maxW then
			cur = trial
		else
			if cur ~= "" then
				table.insert(out, cur)
				if #out >= maxLines then
					return out
				end
			end
			if tm:MeasureStringX(font, w) <= maxW then
				cur = w
			else
				table.insert(out, truncateToWidth(w, font, maxW))
				cur = ""
				if #out >= maxLines then
					return out
				end
			end
		end
	end
	if cur ~= "" and #out < maxLines then
		table.insert(out, cur)
	end
	return out
end

local function drawSpriteInBox(panel, tex, boxX, boxY, boxW, boxH)
	if not tex or boxW < 8 or boxH < 8 then
		return
	end
	-- Fit inside the tile; slight upscale via a tighter box feels larger without leaking out.
	panel:drawTextureScaledAspect(tex, boxX, boxY, boxW, boxH, 1, 1, 1, 1)
end

local function getSpriteTex(spriteName)
	if not spriteName then
		return nil
	end
	if HT_BuildCatalogUI._texCache and HT_BuildCatalogUI._texCache[spriteName] ~= nil then
		local cached = HT_BuildCatalogUI._texCache[spriteName]
		if cached == false then
			return nil
		end
		return cached
	end
	HT_BuildCatalogUI._texCache = HT_BuildCatalogUI._texCache or {}
	local tex = getTexture(spriteName)
	if not tex then
		local spr = getSprite(spriteName)
		if spr then
			tex = spr:getTextureForCurrentFrame(IsoDirections.E)
		end
	end
	HT_BuildCatalogUI._texCache[spriteName] = tex or false
	return tex
end

local truncCache = {}
local function truncateToWidthCached(text, font, maxW)
	if not text or text == "" then
		return ""
	end
	local key = tostring(maxW) .. "|" .. text
	local cached = truncCache[key]
	if cached then
		return cached
	end
	local out = truncateToWidth(text, font, maxW)
	-- Bound cache size roughly
	if truncCache._n and truncCache._n > 800 then
		truncCache = {}
	end
	truncCache[key] = out
	truncCache._n = (truncCache._n or 0) + 1
	return out
end

local function getItemTex(fullType)
	if not fullType or not ISBuildMenu or not ISBuildMenu.GetItemInstance then
		return nil
	end
	local item = ISBuildMenu.GetItemInstance(fullType)
	if item and item.getTex then
		return item:getTex()
	end
	return nil
end

-- -------------------- Grid (groups OR entries) --------------------

function HT_BuildGridPanel:new(x, y, w, h, parentUI)
	local o = ISPanel:new(x, y, w, h)
	setmetatable(o, self)
	self.__index = self
	o.parentUI = parentUI
	o.background = true
	o.backgroundColor = { r = COL.bg.r, g = COL.bg.g, b = COL.bg.b, a = 1 }
	o.borderColor = { r = COL.border.r, g = COL.border.g, b = COL.border.b, a = 1 }
	o.items = {}
	o.selectedId = nil
	o.mode = "groups" -- groups | entries
	-- Engine scroll only (setYScroll). Do not also offset draw coords.
	o:setScrollChildren(false)
	o:setScrollWithParent(false)
	return o
end

function HT_BuildGridPanel:scrollBarW()
	if self.vscroll then
		return self.vscroll:getWidth() or 13
	end
	return 0
end

function HT_BuildGridPanel:columns()
	local inner = math.max(1, self.width - 16 - self:scrollBarW())
	return math.max(1, math.floor((inner + CELL_GAP) / (CELL + CELL_GAP)))
end

function HT_BuildGridPanel:contentHeight()
	local cols = self:columns()
	local rows = math.max(1, math.ceil(math.max(#(self.items or {}), 1) / cols))
	return rows * (CELL + CELL_GAP) + 16
end

function HT_BuildGridPanel:clampScroll()
	local sh = self:contentHeight()
	self:setScrollHeight(sh)
	local y = self:getYScroll()
	local minScroll = math.min(0, self:getScrollAreaHeight() - sh)
	if y > 0 then
		self:setYScroll(0)
	elseif y < minScroll then
		self:setYScroll(minScroll)
	end
end

function HT_BuildGridPanel:setItems(items, selectedId, mode)
	self.items = items or {}
	self.selectedId = selectedId
	self.mode = mode or "entries"
	for _, entry in ipairs(self.items) do
		if self.mode == "groups" then
			entry._gridLabel = getTextOrNull("IGUI_HT_BuildCatalog_Cat_" .. entry.id) or entry.id
		else
			entry._gridLabel = HT_BuildRecipes.getDisplayName(entry)
			entry._gridCap = HT_BuildRecipes.getCapacity(entry)
			entry._gridWater = HT_BuildRecipes.getWaterMax(entry)
		end
	end
	self:setYScroll(0)
	self:clampScroll()
end

function HT_BuildGridPanel:relayoutScroll()
	self:clampScroll()
end

function HT_BuildGridPanel:createChildren()
	ISPanel.createChildren(self)
	self:addScrollBars(false)
end

function HT_BuildGridPanel:indexAt(x, y)
	-- onMouseDown x/y are already in content space when engine scroll is active.
	local sb = self:scrollBarW()
	if sb > 0 and x >= self.width - sb then
		return 0
	end
	local cols = self:columns()
	local col = math.floor((x - 8) / (CELL + CELL_GAP))
	local row = math.floor((y - 8) / (CELL + CELL_GAP))
	if col < 0 or col >= cols or row < 0 then
		return 0
	end
	local idx = row * cols + col + 1
	if idx < 1 or idx > #self.items then
		return 0
	end
	return idx
end

function HT_BuildGridPanel:prerender()
	-- Static bg: must not move with getYScroll (avoids ghost layers).
	self:drawRectStatic(0, 0, self.width, self.height, 1, COL.bg.r, COL.bg.g, COL.bg.b)
end

function HT_BuildGridPanel:render()
	local sb = self:scrollBarW()
	local viewW = math.max(1, self.width - sb)
	local viewH = self.height
	local yScroll = self:getYScroll()

	self:setStencilRect(0, 0, viewW, viewH)

	local cols = self:columns()
	for i, entry in ipairs(self.items) do
		local col = (i - 1) % cols
		local row = math.floor((i - 1) / cols)
		local x = 8 + col * (CELL + CELL_GAP)
		local y = 8 + row * (CELL + CELL_GAP)
		-- Cull against viewport (engine already offsets draw by yScroll).
		local yView = y + yScroll
		if yView + CELL >= 0 and yView <= viewH then
			local selected = entry.id == self.selectedId

			self:drawRect(x, y, CELL, CELL, 1, COL.panelSoft.r, COL.panelSoft.g, COL.panelSoft.b)
			if selected then
				self:drawRectBorder(x, y, CELL, CELL, 1, COL.accent.r, COL.accent.g, COL.accent.b)
				self:drawRectBorder(x + 1, y + 1, CELL - 2, CELL - 2, 0.5, COL.accent.r, COL.accent.g, COL.accent.b)
			else
				self:drawRectBorder(x, y, CELL, CELL, 0.65, COL.border.r, COL.border.g, COL.border.b)
			end

			local labelMaxW = CELL - 10
			local labelY = y + CELL - 18
			local iconBottom = labelY - 4

			if self.mode == "groups" then
				local tex = entry.icon and getTexture(entry.icon) or nil
				if tex then
					drawSpriteInBox(self, tex, x + 10, y + 8, CELL - 20, iconBottom - (y + 8))
				end
				local label = entry._gridLabel or entry.id
				self:drawTextCentre(truncateToWidthCached(label, UIFont.Small, labelMaxW), x + CELL / 2, labelY, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small)
			else
				local tex = getSpriteTex(entry.sprite)
				if tex then
					drawSpriteInBox(self, tex, x + 8, y + 6, CELL - 16, iconBottom - (y + 6))
				end
				if entry.kind == "frame" then
					self:drawRect(x + 4, y + 4, 34, 14, 0.85, COL.frame.r * 0.35, COL.frame.g * 0.35, COL.frame.b * 0.35)
					self:drawText(getText("IGUI_HT_BuildCatalog_Badge_FrameShort"), x + 7, y + 4, COL.frame.r, COL.frame.g, COL.frame.b, 1, UIFont.Small)
				elseif entry.greenhouse then
					self:drawRect(x + 4, y + 4, 52, 14, 0.85, COL.ok.r * 0.35, COL.ok.g * 0.35, COL.ok.b * 0.35)
					self:drawText(getText("IGUI_HT_BuildCatalog_Badge_GreenhouseShort"), x + 7, y + 4, COL.ok.r, COL.ok.g, COL.ok.b, 1, UIFont.Small)
				elseif entry.kind == "style" then
					self:drawRect(x + 4, y + 4, 40, 14, 0.85, COL.style.r * 0.35, COL.style.g * 0.35, COL.style.b * 0.35)
					self:drawText(getText("IGUI_HT_BuildCatalog_Badge_StyleShort"), x + 7, y + 4, COL.style.r, COL.style.g, COL.style.b, 1, UIFont.Small)
				end
				local metaY = labelY - 14
				if entry._gridWater then
					self:drawText(getText("IGUI_HT_BuildCatalog_WaterShort", tostring(entry._gridWater)), x + 5, metaY, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
				elseif entry._gridCap then
					self:drawText(getText("IGUI_HT_BuildCatalog_CapacityShort", tostring(entry._gridCap)), x + 5, metaY, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
				end
				if entry.showHp and entry.hp then
					self:drawTextRight(tostring(entry.hp), x + CELL - 5, metaY, COL.hp.r, COL.hp.g, COL.hp.b, 1, UIFont.Small)
				end
				self:drawTextCentre(
					truncateToWidthCached(entry._gridLabel or HT_BuildRecipes.getDisplayName(entry), UIFont.Small, labelMaxW),
					x + CELL / 2, labelY, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small
				)
			end
		end
	end

	if #self.items == 0 then
		local msg = getText("IGUI_HT_BuildCatalog_Empty")
		if self.mode == "groups" then
			msg = getText("IGUI_HT_BuildCatalog_PickSection")
		elseif self.parentUI and self.parentUI.navLevel == "entries" then
			msg = getText("IGUI_HT_BuildCatalog_EmptyGroup")
		end
		local sy = -yScroll
		self:drawTextCentre(msg, viewW / 2, sy + viewH / 2 - 8, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Medium)
	end

	self:clearStencilRect()
	self:drawRectBorderStatic(0, 0, self.width, self.height, 1, COL.border.r, COL.border.g, COL.border.b)

	self:setScrollHeight(self:contentHeight())
	if self.vscroll then
		self.vscroll:setX(self.width - self.vscroll.width)
		self.vscroll:setHeight(self.height)
	end
end

-- -------------------- Section rail (no ISScrollingListBox / no stencil) --------------------

HT_BuildSectionRail = ISPanel:derive("HT_BuildSectionRail")
local SECTION_H = 52

function HT_BuildSectionRail:new(x, y, w, h, parentUI)
	local o = ISPanel:new(x, y, w, h)
	setmetatable(o, self)
	self.__index = self
	o.parentUI = parentUI
	o.sections = {}
	o.selectedId = nil
	o.backgroundColor = { r = COL.panel.r, g = COL.panel.g, b = COL.panel.b, a = 1 }
	o.borderColor = { r = COL.border.r, g = COL.border.g, b = COL.border.b, a = 1 }
	return o
end

function HT_BuildSectionRail:setSections(sections, selectedId)
	self.sections = sections or {}
	self.selectedId = selectedId
end

function HT_BuildSectionRail:prerender()
end

function HT_BuildSectionRail:render()
	self:drawRect(0, 0, self.width, self.height, 1, COL.panel.r, COL.panel.g, COL.panel.b)
	self:drawRectBorder(0, 0, self.width, self.height, 1, COL.border.r, COL.border.g, COL.border.b)
	for i, section in ipairs(self.sections) do
		local y = (i - 1) * SECTION_H
		if y > self.height then
			break
		end
		local selected = section.id == self.selectedId
		if selected then
			self:drawRect(0, y, self.width, SECTION_H, 0.5, COL.accent.r, COL.accent.g, COL.accent.b)
		end
		local size = 40
		local bx = (self.width - size) / 2
		local by = y + 4
		local tex = section.icon and getTexture(section.icon) or nil
		if tex then
			self:drawTextureScaledAspect(tex, bx, by, size, size, 1, 1, 1, 1)
		end
	end
end

function HT_BuildSectionRail:onMouseDown(x, y)
	local idx = math.floor(y / SECTION_H) + 1
	local section = self.sections[idx]
	if section and self.parentUI then
		self.parentUI:onSectionClick(section)
		return true
	end
	return false
end

function HT_BuildGridPanel:onMouseDown(x, y)
	local idx = self:indexAt(x, y)
	if idx > 0 then
		self.parentUI:onGridClick(self.items[idx], self.mode)
		return true
	end
	return false
end

function HT_BuildGridPanel:onMouseDoubleClick(x, y)
	local idx = self:indexAt(x, y)
	if idx > 0 and self.mode == "entries" then
		self.parentUI:onGridClick(self.items[idx], self.mode)
		self.parentUI:onBuildClicked()
		return true
	end
	return false
end

function HT_BuildGridPanel:onMouseWheel(del)
	if self:contentHeight() <= self:getScrollAreaHeight() then
		return false
	end
	self:setYScroll(self:getYScroll() - (del * 56))
	return true
end

-- -------------------- Window --------------------

function HT_BuildCatalogUI.getCenteredXY(w, h)
	local core = getCore()
	local x = math.max(0, math.floor((core:getScreenWidth() - w) / 2))
	local y = math.max(0, math.floor((core:getScreenHeight() - h) / 2))
	return x, y
end

function HT_BuildCatalogUI.Open(playerNum)
	local playerObj = getSpecificPlayer(playerNum)
	if not playerObj then
		return
	end
	if HT_BuildCatalogUI.instance then
		HT_BuildCatalogUI.instance:close()
	end
	if HT_BuildRecipes then
		HT_BuildRecipes.init()
	end
	local x, y = HT_BuildCatalogUI.getCenteredXY(PANEL_W, PANEL_H)
	local ui = HT_BuildCatalogUI:new(x, y, PANEL_W, PANEL_H, playerNum)
	ui:initialise()
	ui:addToUIManager()
	HT_BuildCatalogUI.instance = ui
	return ui
end

function HT_BuildCatalogUI:new(x, y, width, height, playerNum)
	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.character = getSpecificPlayer(playerNum)
	o.title = getText("IGUI_HT_BuildCatalog_Title") .. " [HT]"
	-- Resizing ISCollapsableWindow with custom-drawn children ghosts panels in B41.
	o.resizable = false
	o.clearStentil = false
	o.background = true
	o.backgroundColor = { r = COL.bg.r, g = COL.bg.g, b = COL.bg.b, a = 1 }
	o.borderColor = { r = COL.border.r, g = COL.border.g, b = COL.border.b, a = 1 }
	local prefs = HT_BuildPrefs and HT_BuildPrefs.get() or {}
	o.sectionId = prefs.lastSection or "Build"
	o.groupId = prefs.lastCategory or nil
	o.navLevel = "groups"
	if o.groupId and o.groupId ~= "" then
		local section = HT_BuildRecipes.getSection(o.sectionId)
		local groupOk = false
		if section and section.groups then
			for _, g in ipairs(section.groups) do
				if g.id == o.groupId then
					groupOk = true
					break
				end
			end
		end
		if groupOk then
			o.navLevel = "entries"
		else
			o.groupId = nil
		end
	end
	o.searchText = ""
	o.availableOnly = prefs.availableOnly == true
	o.selectedEntry = nil
	o.variantIndex = 1
	o.variantHits = {}
	o.helpHits = {}
	o.crumbHits = {}
	return o
end

function HT_BuildCatalogUI:initialise()
	ISCollapsableWindow.initialise(self)
	self:createChildren()
	self:refreshAll()
end

function HT_BuildCatalogUI:createChildren()
	ISCollapsableWindow.createChildren(self)
	local th = self:titleBarHeight()
	local top = th + PAD

	self.backBtn = ISButton:new(PAD + RAIL_W + PAD, top, 70, 24, getText("IGUI_HT_BuildCatalog_Back"), self, HT_BuildCatalogUI.onBackClicked)
	self.backBtn:initialise()
	self.backBtn:instantiate()
	self.backBtn.borderColor = { r = COL.border.r, g = COL.border.g, b = COL.border.b, a = 1 }
	self:addChild(self.backBtn)

	self.searchEntry = ISTextEntryBox:new("", PAD + RAIL_W + PAD + 80, top, 220, 24)
	self.searchEntry:initialise()
	self.searchEntry:instantiate()
	self.searchEntry.onTextChange = function()
		self.searchText = self.searchEntry:getInternalText() or ""
		self:refreshAll()
	end
	self:addChild(self.searchEntry)

	self.availTick = ISTickBox:new(PAD + RAIL_W + PAD + 310, top, 220, 24, "", self, HT_BuildCatalogUI.onAvailToggle)
	self.availTick:initialise()
	self.availTick:instantiate()
	self.availTick:addOption(getText("IGUI_HT_BuildCatalog_AvailableOnly"))
	self.availTick:setSelected(1, self.availableOnly)
	self:addChild(self.availTick)

	local crumbY = top + 28
	self.crumbBar = ISPanel:new(PAD + RAIL_W + PAD, crumbY, self.width - PAD * 3 - RAIL_W - DETAIL_W, 22)
	self.crumbBar:initialise()
	self.crumbBar.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	self.crumbBar.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	self.crumbBar.prerender = function() end
	self.crumbBar.render = function(panel)
		self:renderBreadcrumb(panel)
	end
	self.crumbBar.onMouseDown = function(panel, x, y)
		return self:onCrumbMouseDown(x, y)
	end
	self:addChild(self.crumbBar)

	local bodyY = crumbY + 26
	local bodyH = self.height - bodyY - PAD
	local gridW = self.width - PAD * 3 - RAIL_W - DETAIL_W

	self.sectionList = HT_BuildSectionRail:new(PAD, bodyY, RAIL_W, bodyH, self)
	self.sectionList:initialise()
	self:addChild(self.sectionList)
	self:rebuildSectionList()

	self.grid = HT_BuildGridPanel:new(PAD + RAIL_W + PAD, bodyY, gridW, bodyH, self)
	self.grid:initialise()
	self:addChild(self.grid)

	self.detail = ISPanel:new(PAD + RAIL_W + PAD + gridW + PAD, bodyY, DETAIL_W, bodyH)
	self.detail:initialise()
	self.detail.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	self.detail.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	self.detail.prerender = function() end
	self.detail.render = function(panel)
		self:renderDetails(panel)
	end
	self.detail.onMouseDown = function(panel, x, y)
		return self:onDetailMouseDown(x, y)
	end
	self.detail.onMouseMove = function(panel, dx, dy)
		return self:onDetailMouseMove(panel)
	end
	self.detail.onMouseMoveOutside = function(panel, dx, dy)
		self:setHelpTooltipVisible(panel, false)
	end
	self:addChild(self.detail)

	-- Prevent Java anchor stretch from fighting manual layout on resize.
	for _, panel in ipairs({ self.sectionList, self.grid, self.detail, self.crumbBar }) do
		panel.anchorLeft = true
		panel.anchorRight = false
		panel.anchorTop = true
		panel.anchorBottom = false
		if panel.javaObject then
			panel.javaObject:setAnchorLeft(true)
			panel.javaObject:setAnchorRight(false)
			panel.javaObject:setAnchorTop(true)
			panel.javaObject:setAnchorBottom(false)
		end
	end

	self.buildHit = { x = 0, y = 0, w = 0, h = 0 }
	if self.setResizable then
		self:setResizable(false)
	elseif self.resizeWidget then
		self.resizeWidget:setVisible(false)
		if self.resizeWidget2 then
			self.resizeWidget2:setVisible(false)
		end
	end
	self:layoutChildren()
end

function HT_BuildCatalogUI:rebuildSectionList()
	if not self.sectionList then
		return
	end
	self.sectionList:setSections(HT_BuildRecipes.sections or {}, self.sectionId)
end

function HT_BuildCatalogUI:onSectionClick(item)
	if not item or not item.id then
		return
	end
	self.sectionId = item.id
	self.groupId = nil
	self.navLevel = "groups"
	self.selectedEntry = nil
	self.variantIndex = 1
	if HT_BuildPrefs then
		HT_BuildPrefs.setLastSection(self.sectionId)
		HT_BuildPrefs.setLastCategory("")
	end
	self:rebuildSectionList()
	self:refreshAll()
end

function HT_BuildCatalogUI:onBackClicked()
	if self.navLevel == "entries" then
		self.navLevel = "groups"
		self.groupId = nil
		self.selectedEntry = nil
		self.variantIndex = 1
		if HT_BuildPrefs then
			HT_BuildPrefs.setLastCategory("")
		end
		self:refreshAll()
	end
end

function HT_BuildCatalogUI:onGridClick(entry, mode)
	if mode == "groups" then
		self.groupId = entry.id
		self.navLevel = "entries"
		self.selectedEntry = nil
		self.variantIndex = 1
		if HT_BuildPrefs then
			HT_BuildPrefs.setLastSection(self.sectionId)
			HT_BuildPrefs.setLastCategory(self.groupId)
		end
		self:refreshAll()
		return
	end
	self.selectedEntry = entry
	self.variantIndex = 1
	if self.grid then
		self.grid.selectedId = entry.id
	end
end

function HT_BuildCatalogUI:layoutChildren()
	if not self.grid then
		return
	end
	local w = self:getWidth() or self.width
	local h = self:getHeight() or self.height
	local th = self:titleBarHeight()
	local top = th + PAD
	local crumbY = top + 28
	local bodyY = crumbY + 26
	local bodyH = math.max(80, h - bodyY - PAD)
	local detailW = DETAIL_W
	local minGridW = CELL + 16
	local left = PAD + RAIL_W + PAD
	local rightPad = PAD
	local gap = PAD
	local avail = w - left - rightPad
	if avail - detailW - gap < minGridW then
		detailW = math.max(200, avail - gap - minGridW)
	end
	local gridW = math.max(minGridW, avail - gap - detailW)
	local detailX = left + gridW + gap
	if detailX + detailW > w - rightPad then
		detailX = math.max(left, w - rightPad - detailW)
		gridW = math.max(minGridW, detailX - gap - left)
		detailW = math.max(180, w - rightPad - detailX)
	end

	self.backBtn:setX(PAD + RAIL_W + PAD)
	self.backBtn:setY(top)
	self.searchEntry:setX(PAD + RAIL_W + PAD + 80)
	self.searchEntry:setY(top)
	self.availTick:setX(PAD + RAIL_W + PAD + 310)
	self.availTick:setY(top)

	self.crumbBar:setX(left)
	self.crumbBar:setY(crumbY)
	self.crumbBar:setWidth(gridW)
	self.crumbBar:setHeight(22)

	self.sectionList:setX(PAD)
	self.sectionList:setY(bodyY)
	self.sectionList:setWidth(RAIL_W)
	self.sectionList:setHeight(bodyH)

	self.grid:setX(left)
	self.grid:setY(bodyY)
	self.grid:setWidth(gridW)
	self.grid:setHeight(bodyH)

	self.detail:setX(detailX)
	self.detail:setY(bodyY)
	self.detail:setWidth(detailW)
	self.detail:setHeight(bodyH)

	self.lastW = w
	self.lastH = h
	if self.grid.relayoutScroll then
		self.grid:relayoutScroll()
	end
end

function HT_BuildCatalogUI:setWidth(w)
	ISUIElement.setWidth(self, w)
end

function HT_BuildCatalogUI:setHeight(h)
	ISUIElement.setHeight(self, h)
end

function HT_BuildCatalogUI:prerender()
	ISCollapsableWindow.prerender(self)
	if self.backBtn then
		self.backBtn:setEnable(self.navLevel == "entries")
	end
end

function HT_BuildCatalogUI:render()
	ISCollapsableWindow.render(self)
end

function HT_BuildCatalogUI:onMouseWheel(del)
	if self.grid and (self.grid:isMouseOver() or self:isMouseOver()) then
		local mx = self:getMouseX()
		local my = self:getMouseY()
		local gx = self.grid:getX()
		local gy = self.grid:getY()
		local gw = self.grid:getWidth()
		local gh = self.grid:getHeight()
		if mx >= gx and mx <= gx + gw and my >= gy and my <= gy + gh then
			return self.grid:onMouseWheel(del)
		end
	end
	return false
end

function HT_BuildCatalogUI:onAvailToggle(index, selected)
	self.availableOnly = selected == true
	if HT_BuildPrefs then
		HT_BuildPrefs.setAvailableOnly(self.availableOnly)
	end
	self:refreshAll()
end

function HT_BuildCatalogUI:renderBreadcrumb(panel)
	panel:drawRect(0, 0, panel.width, panel.height, 1, COL.panel.r, COL.panel.g, COL.panel.b)
	self.crumbHits = {}
	local x = 4
	local parts = {}
	table.insert(parts, {
		id = "section",
		label = getTextOrNull("IGUI_HT_BuildCatalog_Section_" .. (self.sectionId or "")) or (self.sectionId or "?"),
	})
	if self.groupId then
		table.insert(parts, {
			id = "group",
			label = getTextOrNull("IGUI_HT_BuildCatalog_Cat_" .. self.groupId) or self.groupId,
		})
	end
	if self.selectedEntry then
		table.insert(parts, {
			id = "entry",
			label = HT_BuildRecipes.getDisplayName(self.selectedEntry),
		})
	end
	for i, part in ipairs(parts) do
		if i > 1 then
			panel:drawText(" › ", x, 3, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
			x = x + getTextManager():MeasureStringX(UIFont.Small, " › ")
		end
		local tw = getTextManager():MeasureStringX(UIFont.Small, part.label)
		local clickable = i < #parts
		local r, g, b = COL.text.r, COL.text.g, COL.text.b
		if clickable then
			r, g, b = COL.accent.r, COL.accent.g, COL.accent.b
			table.insert(self.crumbHits, { x = x, y = 0, w = tw, h = panel.height, id = part.id })
		end
		panel:drawText(truncate(part.label, 28), x, 3, r, g, b, 1, UIFont.Small)
		x = x + tw
	end
end

function HT_BuildCatalogUI:onCrumbMouseDown(x, y)
	for _, hit in ipairs(self.crumbHits or {}) do
		if x >= hit.x and x <= hit.x + hit.w then
			if hit.id == "section" then
				self.groupId = nil
				self.navLevel = "groups"
				self.selectedEntry = nil
				self.variantIndex = 1
				if HT_BuildPrefs then
					HT_BuildPrefs.setLastCategory("")
				end
				self:refreshAll()
			elseif hit.id == "group" then
				self.selectedEntry = nil
				self.variantIndex = 1
				self.navLevel = "entries"
				self:refreshAll()
			end
			return true
		end
	end
	return false
end

function HT_BuildCatalogUI:refreshAll()
	if self.navLevel == "groups" then
		local section = HT_BuildRecipes.getSection(self.sectionId)
		local groups = section and section.groups or {}
		self.grid:setItems(groups, self.groupId, "groups")
		self.selectedEntry = nil
		return
	end

	local entries = HT_BuildRecipes.getEntries(self.sectionId, self.groupId, self.searchText) or {}
	if self.availableOnly and self.character then
		local filtered = {}
		for _, e in ipairs(entries) do
			if select(1, HT_BuildRecipes.evaluate(e, self.character, 1)) then
				table.insert(filtered, e)
			end
		end
		entries = filtered
	end

	local keep = self.selectedEntry and self.selectedEntry.id
	local found = nil
	if keep then
		for _, e in ipairs(entries) do
			if e.id == keep then
				found = e
				break
			end
		end
	end
	if not found then
		found = entries[1]
		self.variantIndex = 1
	end
	self.selectedEntry = found
	self.grid:setItems(entries, found and found.id or nil, "entries")
end

function HT_BuildCatalogUI:renderDetails(panel)
	panel:drawRect(0, 0, panel.width, panel.height, 1, COL.panel.r, COL.panel.g, COL.panel.b)
	panel:drawRectBorder(0, 0, panel.width, panel.height, 1, COL.border.r, COL.border.g, COL.border.b)
	self.variantHits = {}
	self.helpHits = {}
	self.buildHit.w = 0

	local pad = 12
	local btnH = 32
	local contentBottom = panel.height - pad - btnH - 8
	local helpBtnW = 18
	local helpGap = 4
	local function canHelp(fullType)
		if not fullType or not CHC_menu or not CHC_main or not CHC_main.items then
			return false
		end
		if not CHC_main.items[fullType] then
			return false
		end
		return type(CHC_main.recipesByItem[fullType]) == "table"
			or type(CHC_main.recipesForItem[fullType]) == "table"
	end
	local function addHelpHit(fullType, hx, hy)
		if not canHelp(fullType) then
			return false
		end
		panel:drawRect(hx, hy, helpBtnW, 16, 1, COL.bg.r, COL.bg.g, COL.bg.b)
		panel:drawRectBorder(hx, hy, helpBtnW, 16, 0.75, COL.border.r, COL.border.g, COL.border.b)
		panel:drawTextCentre("?", hx + helpBtnW / 2, hy + 1, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		table.insert(self.helpHits, { x = hx, y = hy, w = helpBtnW, h = 16, fullType = fullType })
		return true
	end
	local function drawItemRow(fullType, iconTex, label, ir, ig, ib, yRow)
		local x = pad
		if addHelpHit(fullType, x, yRow) then
			x = x + helpBtnW + helpGap
		end
		if iconTex then
			panel:drawTextureScaledAspect(iconTex, x, yRow, 16, 16, 1, 1, 1, 1)
		end
		local textX = x + 22
		local textMax = panel.width - textX - pad
		panel:drawText(truncateToWidthCached(label, UIFont.Small, textMax), textX, yRow + 1, ir, ig, ib, 1, UIFont.Small)
	end

	if self.navLevel == "groups" then
		self:setHelpTooltipVisible(panel, false)
		panel:drawTextCentre(getText("IGUI_HT_BuildCatalog_PickGroup"), panel.width / 2, panel.height / 2 - 10, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		return
	end

	local recipe = self.selectedEntry
	if not recipe then
		self:setHelpTooltipVisible(panel, false)
		panel:drawTextCentre(getText("IGUI_HT_BuildCatalog_EmptyGroup"), panel.width / 2, panel.height / 2 - 10, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		return
	end

	local active = HT_BuildRecipes.getActive(recipe, self.variantIndex) or recipe
	local y = pad
	local title = HT_BuildRecipes.getDisplayName(recipe)
	if recipe.variants and active and active.roleKey then
		local role = getTextOrNull(active.roleKey)
		if role then
			title = title .. " · " .. role
		end
	end
	panel:drawText(truncate(title, 36), pad, y, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Medium)
	y = y + 22

	if recipe.kind == "frame" then
		panel:drawText(getText("IGUI_HT_BuildCatalog_Badge_Frame"), pad, y, COL.frame.r, COL.frame.g, COL.frame.b, 1, UIFont.Small)
		y = y + 16
	elseif recipe.greenhouse then
		panel:drawText(getText("IGUI_HT_BuildCatalog_Badge_Greenhouse"), pad, y, COL.ok.r, COL.ok.g, COL.ok.b, 1, UIFont.Small)
		y = y + 16
	elseif recipe.kind == "style" then
		panel:drawText(getText("IGUI_HT_BuildCatalog_Badge_Style"), pad, y, COL.style.r, COL.style.g, COL.style.b, 1, UIFont.Small)
		y = y + 16
	end

	-- Roof trim only: cover is default; do not label floors/furniture via solidfloor.
	if recipe.group == "Roofs" then
		local mode = active.roofMode
		if not mode and active.sprite and getSprite then
			local sp = getSprite(active.sprite)
			local props = sp and sp:getProperties()
			if props and ((IsoFlagType and IsoFlagType.solidfloor and props:Is(IsoFlagType.solidfloor)) or props:Is("solidfloor") == true) then
				mode = "cover"
			elseif sp then
				mode = "trim"
			end
		end
		if mode == "trim" then
			panel:drawText(getText("IGUI_HT_BuildCatalog_RoofMode_Trim"), pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
			y = y + 16
		end
	end

	if (active.showHp or recipe.showHp) and (active.hp or recipe.hp) then
		panel:drawText(getText("IGUI_HT_BuildCatalog_HP", tostring(active.hp or recipe.hp)), pad, y, COL.hp.r, COL.hp.g, COL.hp.b, 1, UIFont.Small)
		y = y + 16
	end
	local cap = HT_BuildRecipes.getCapacity(active) or HT_BuildRecipes.getCapacity(recipe)
	if cap then
		panel:drawText(getText("IGUI_HT_BuildCatalog_Capacity", tostring(cap)), pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		y = y + 16
	end
	local waterMax = HT_BuildRecipes.getWaterMax(active) or HT_BuildRecipes.getWaterMax(recipe)
	if waterMax then
		panel:drawText(getText("IGUI_HT_BuildCatalog_Water", tostring(waterMax)), pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		y = y + 16
	end

	local previewH = 120
	if panel.height < 480 then
		previewH = math.max(40, math.min(120, contentBottom - y - 160))
	end
	if y + previewH + 8 < contentBottom then
		panel:drawRect(pad, y, panel.width - pad * 2, previewH, 1, COL.bg.r, COL.bg.g, COL.bg.b)
		panel:drawRectBorder(pad, y, panel.width - pad * 2, previewH, 0.6, COL.border.r, COL.border.g, COL.border.b)
		local tex = getSpriteTex(active.sprite or recipe.sprite)
		if tex then
			drawSpriteInBox(panel, tex, pad + 8, y + 6, panel.width - pad * 2 - 16, previewH - 12)
		end
		y = y + previewH + 8
	end

	if recipe.variants then
		local chipX, chipY = pad, y
		local chipH = 22
		for i, variant in ipairs(recipe.variants) do
			local label = getTextOrNull(variant.roleKey) or variant.role or tostring(i)
			local tw = getTextManager():MeasureStringX(UIFont.Small, label) + 14
			if chipX + tw > panel.width - pad then
				chipX = pad
				chipY = chipY + chipH + 4
			end
			local on = self.variantIndex == i
			if on then
				panel:drawRect(chipX, chipY, tw, chipH, 0.9, COL.accent.r * 0.35, COL.accent.g * 0.35, COL.accent.b * 0.35)
				panel:drawRectBorder(chipX, chipY, tw, chipH, 1, COL.accent.r, COL.accent.g, COL.accent.b)
			else
				panel:drawRect(chipX, chipY, tw, chipH, 0.7, COL.bg.r, COL.bg.g, COL.bg.b)
				panel:drawRectBorder(chipX, chipY, tw, chipH, 0.7, COL.border.r, COL.border.g, COL.border.b)
			end
			panel:drawTextCentre(label, chipX + tw / 2, chipY + 4, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small)
			table.insert(self.variantHits, { x = chipX, y = chipY, w = tw, h = chipH, index = i })
			chipX = chipX + tw + 4
		end
		y = chipY + chipH + 8
	end

	local noteKey = active.noteKey or recipe.noteKey
	if noteKey then
		local note = getTextOrNull(noteKey)
		if note then
			local maxW = panel.width - pad * 2
			local lines = wrapWordsToWidth(note, UIFont.Small, maxW, 4)
			for _, line in ipairs(lines) do
				if y + 14 > contentBottom then
					break
				end
				panel:drawText(line, pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
				y = y + 14
			end
			y = y + 4
		end
	end

	-- Vanilla wood frame: show MultiStage L1/L2/L3 costs and HP so players are not guessing.
	if recipe.id == "v_wall_frame" then
		local upgradeKeys = {
			"IGUI_HT_BuildCatalog_UpgradeHeader",
			"IGUI_HT_BuildCatalog_Upgrade_L1",
			"IGUI_HT_BuildCatalog_Upgrade_L2",
			"IGUI_HT_BuildCatalog_Upgrade_L3",
			"IGUI_HT_BuildCatalog_Upgrade_Total",
			"IGUI_HT_BuildCatalog_Upgrade_PlasterNote",
		}
		for _, key in ipairs(upgradeKeys) do
			if y > contentBottom then
				break
			end
			local line = getTextOrNull(key) or getText(key)
			if line and line ~= "" then
				local maxW = panel.width - pad * 2
				panel:drawText(truncateToWidthCached(line, UIFont.Small, maxW), pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
				y = y + 14
			end
		end
		y = y + 4
	end

	panel:drawText(getText("Tooltip_craft_Needs"), pad, y, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small)
	y = y + 18

	local canBuild = select(1, HT_BuildRecipes.evaluate(recipe, self.character, self.variantIndex))
	if ISBuildMenu and ISBuildMenu.cheat then
		canBuild = true
	end

	if active.needs then
		for _, need in ipairs(active.needs) do
			if y + 18 > contentBottom then
				break
			end
			local have = HT_BuildRecipes.countItem(self.character, need.item)
			local good = have >= need.count or (ISBuildMenu and ISBuildMenu.cheat)
			local ir, ig, ib = good and COL.ok.r or COL.bad.r, good and COL.ok.g or COL.bad.g, good and COL.ok.b or COL.bad.b
			local itemName = getItemNameFromFullType(need.item) or need.item
			drawItemRow(need.item, getItemTex(need.item), itemName .. "  " .. have .. "/" .. need.count, ir, ig, ib, y)
			y = y + 18
		end
	end
	if active.uses and #active.uses > 0 then
		panel:drawText(getText("IGUI_HT_BuildCatalog_UsesHeader"), pad, y, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small)
		y = y + 14
		for _, use in ipairs(active.uses) do
			if y + 18 > contentBottom then
				break
			end
			local have = HT_BuildRecipes.countUses(self.character, use.item)
			local good = have >= use.count or (ISBuildMenu and ISBuildMenu.cheat)
			local ir, ig, ib = good and COL.ok.r or COL.bad.r, good and COL.ok.g or COL.bad.g, good and COL.ok.b or COL.bad.b
			local itemName = getItemNameFromFullType(use.item) or use.item
			drawItemRow(use.item, getItemTex(use.item), itemName .. "  " .. have .. "/" .. use.count, ir, ig, ib, y)
			y = y + 18
		end
	end
	if active.skills then
		for perkId, level in pairs(active.skills) do
			if y + 16 > contentBottom then
				break
			end
			local have = self.character:getPerkLevel(Perks.FromString(perkId))
			local good = have >= level or (ISBuildMenu and ISBuildMenu.cheat)
			local ir, ig, ib = good and COL.ok.r or COL.bad.r, good and COL.ok.g or COL.bad.g, good and COL.ok.b or COL.bad.b
			panel:drawText(getText("IGUI_perks_" .. perkId) .. "  " .. have .. "/" .. level, pad, y, ir, ig, ib, 1, UIFont.Small)
			y = y + 16
		end
	end
	if active.tools and #active.tools > 0 then
		y = y + 4
		panel:drawText(getText("IGUI_HT_BuildCatalog_ToolsHeader"), pad, y, COL.text.r, COL.text.g, COL.text.b, 1, UIFont.Small)
		y = y + 14
		panel:drawText(getText("IGUI_HT_BuildCatalog_ToolsKept"), pad, y, COL.muted.r, COL.muted.g, COL.muted.b, 1, UIFont.Small)
		y = y + 14
		for _, tool in ipairs(active.tools) do
			if y + 18 > contentBottom then
				break
			end
			local good = HT_BuildRecipes.hasTool(self.character, tool) or (ISBuildMenu and ISBuildMenu.cheat)
			local ir, ig, ib = good and COL.ok.r or COL.bad.r, good and COL.ok.g or COL.bad.g, good and COL.ok.b or COL.bad.b
			local toolType = HT_BuildRecipes.getToolFullType and HT_BuildRecipes.getToolFullType(tool) or tool
			drawItemRow(toolType, getItemTex(toolType), HT_BuildRecipes.getToolLabel(tool), ir, ig, ib, y)
			y = y + 18
		end
	end

	local btnY = panel.height - pad - btnH
	local btnW = panel.width - pad * 2
	self.buildHit = { x = pad, y = btnY, w = btnW, h = btnH }
	if canBuild and active.create then
		panel:drawRect(pad, btnY, btnW, btnH, 1, 0.32, 0.52, 0.28)
		panel:drawRectBorder(pad, btnY, btnW, btnH, 1, COL.accent.r, COL.accent.g, COL.accent.b)
		panel:drawTextCentre(getText("IGUI_HT_BuildCatalog_Build"), pad + btnW / 2, btnY + 8, 1, 1, 1, 1, UIFont.Small)
	else
		panel:drawRect(pad, btnY, btnW, btnH, 1, 0.2, 0.2, 0.2)
		panel:drawRectBorder(pad, btnY, btnW, btnH, 0.6, COL.border.r, COL.border.g, COL.border.b)
		panel:drawTextCentre(getText("IGUI_HT_BuildCatalog_Build"), pad + btnW / 2, btnY + 8, 0.55, 0.55, 0.55, 1, UIFont.Small)
	end
end

function HT_BuildCatalogUI:setHelpTooltipVisible(panel, visible)
	if not panel then
		return
	end
	if visible then
		if not panel.helpTooltipUI then
			panel.helpTooltipUI = ISToolTip:new()
			panel.helpTooltipUI:setOwner(panel)
			panel.helpTooltipUI:setVisible(false)
			panel.helpTooltipUI:setAlwaysOnTop(true)
			panel.helpTooltipUI.maxLineWidth = 320
		end
		local tip = panel.helpTooltipUI
		tip.description = getText("IGUI_HT_BuildCatalog_CraftHelper")
		if not tip:getIsVisible() then
			tip:addToUIManager()
			tip:setVisible(true)
		end
		tip:setX(panel:getAbsoluteX() + panel:getMouseX() + 18)
		tip:setY(panel:getAbsoluteY() + panel:getMouseY() + 18)
	elseif panel.helpTooltipUI and panel.helpTooltipUI:getIsVisible() then
		panel.helpTooltipUI:setVisible(false)
		panel.helpTooltipUI:removeFromUIManager()
	end
end

function HT_BuildCatalogUI:onDetailMouseMove(panel)
	local x = panel:getMouseX()
	local y = panel:getMouseY()
	for _, hit in ipairs(self.helpHits or {}) do
		if x >= hit.x and x <= hit.x + hit.w and y >= hit.y and y <= hit.y + hit.h then
			self:setHelpTooltipVisible(panel, true)
			return true
		end
	end
	self:setHelpTooltipVisible(panel, false)
	return false
end

function HT_BuildCatalogUI:openCraftHelperFor(fullType)
	if not fullType or fullType == "" then
		return false
	end
	if not CHC_menu or not CHC_menu.onCraftHelper then
		return false
	end
	local item = nil
	if ISBuildMenu and ISBuildMenu.GetItemInstance then
		item = ISBuildMenu.GetItemInstance(fullType)
	end
	if (not item) and instanceItem then
		item = instanceItem(fullType)
	end
	if not item then
		return false
	end
	CHC_menu.onCraftHelper({ item }, self.playerNum)
	return true
end

function HT_BuildCatalogUI:onDetailMouseDown(x, y)
	for _, hit in ipairs(self.helpHits or {}) do
		if x >= hit.x and x <= hit.x + hit.w and y >= hit.y and y <= hit.y + hit.h then
			self:openCraftHelperFor(hit.fullType)
			return true
		end
	end
	for _, hit in ipairs(self.variantHits or {}) do
		if x >= hit.x and x <= hit.x + hit.w and y >= hit.y and y <= hit.y + hit.h then
			self.variantIndex = hit.index
			return true
		end
	end
	local bh = self.buildHit
	if bh and bh.w > 0 and x >= bh.x and x <= bh.x + bh.w and y >= bh.y and y <= bh.y + bh.h then
		self:onBuildClicked()
		return true
	end
	return false
end

function HT_BuildCatalogUI:onBuildClicked()
	if not self.selectedEntry then
		return
	end
	local ok = select(1, HT_BuildRecipes.evaluate(self.selectedEntry, self.character, self.variantIndex))
	if not ok and not (ISBuildMenu and ISBuildMenu.cheat) then
		return
	end
	local active = HT_BuildRecipes.getActive(self.selectedEntry, self.variantIndex)
	if not active or not active.create then
		return
	end
	-- Keep catalog open; defer setDrag so this mouse click does not place the object.
	HT_BuildRecipes.startBuild(self.selectedEntry, self.playerNum, self.variantIndex)
end

function HT_BuildCatalogUI:close()
	if self.detail then
		self:setHelpTooltipVisible(self.detail, false)
	end
	if HT_BuildPrefs then
		if self.sectionId then
			HT_BuildPrefs.setLastSection(self.sectionId)
		end
		HT_BuildPrefs.setLastCategory(self.groupId or "")
	end
	self:setVisible(false)
	self:removeFromUIManager()
	if HT_BuildCatalogUI.instance == self then
		HT_BuildCatalogUI.instance = nil
	end
end
