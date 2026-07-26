-- SafehouseRegionsUI: player-facing IsoRegions map clipped to safehouse bounds.
-- No free pan/zoom outside the claim. Pure Lua draw (no IsoRegionsRenderer).

require "ISUI/ISCollapsableWindow"

SafehouseRegionsUI = ISCollapsableWindow:derive("SafehouseRegionsUI")
SafehouseRegionsUI.instance = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local MAX_CANVAS = 520
local MIN_TILE = 2
local MAX_TILE = 10
local CHUNK_DIM = 10
-- Margin so N/W wall lines on the claim edge (and S/E walls on adjacent tiles) stay visible.
local VIEW_PAD = 2

local function canViewSafehouse(player, safehouse)
	if not player or not safehouse then
		return false
	end
	if openutils and openutils.HasPermission and openutils.HasPermission(player, "moderator") then
		return true
	end
	if openutils and openutils.IsPlayerMemmberOfSafehouse then
		return openutils.IsPlayerMemmberOfSafehouse(player, safehouse)
	end
	if safehouse:isOwner(player) then
		return true
	end
	return safehouse:playerAllowed(player)
end

local function isInsideBounds(x, y, sh)
	return x >= sh:getX() and x < sh:getX2() and y >= sh:getY() and y < sh:getY2()
end

local function isInsideView(x, y, view)
	return x >= view.x0 and x < view.x1 and y >= view.y0 and y < view.y1
end

function SafehouseRegionsUI.OnOpenPanel(safehouse, player)
	if not canViewSafehouse(player, safehouse) then
		return nil
	end

	if SafehouseRegionsUI.instance then
		SafehouseRegionsUI.instance:close()
	end

	local ui = SafehouseRegionsUI:new(0, 0, 100, 100, safehouse, player)
	ui:initialise()
	ui:instantiate()
	ui:addToUIManager()
	ui:setVisible(true)
	SafehouseRegionsUI.instance = ui
	return ui
end

function SafehouseRegionsUI:initialise()
	ISCollapsableWindow.initialise(self)
end

function SafehouseRegionsUI:createChildren()
	ISCollapsableWindow.createChildren(self)

	local th = self:titleBarHeight()
	local sh = self.safehouse
	local shW = math.max(1, sh:getX2() - sh:getX())
	local shH = math.max(1, sh:getY2() - sh:getY())
	local w = shW + VIEW_PAD * 2
	local h = shH + VIEW_PAD * 2

	local tile = math.floor(math.min(MAX_CANVAS / w, MAX_CANVAS / h))
	if tile < MIN_TILE then tile = MIN_TILE end
	if tile > MAX_TILE then tile = MAX_TILE end
	self.tilePx = tile
	self.view = {
		x0 = sh:getX() - VIEW_PAD,
		y0 = sh:getY() - VIEW_PAD,
		x1 = sh:getX2() + VIEW_PAD,
		y1 = sh:getY2() + VIEW_PAD,
	}
	self.mapW = w
	self.mapH = h
	self.canvasW = w * tile
	self.canvasH = h * tile
	self.canvasY = th
	self.regionMode = 0 -- 0 regions, 1 blueprint
	self.zLevel = math.floor(self.player:getZ())
	if self.zLevel < 0 then self.zLevel = 0 end
	if self.zLevel > 7 then self.zLevel = 7 end
	self.hoverInfo = ""
	self.loadedCells = 0
	self.totalCells = shW * shH
	self.palpha = 1.0
	self.palphaUp = false

	local y = th + self.canvasH + 4
	local btnH = math.max(18, FONT_HGT_SMALL + 4)
	local btnW = math.floor((self.canvasW - 20) / 2)

	self.btnMode = ISButton:new(5, y, btnW, btnH, getText("IGUI_SafehouseRegions_ModeRegions"), self, SafehouseRegionsUI.onButton)
	self.btnMode.internal = "MODE"
	self.btnMode:initialise()
	self.btnMode:instantiate()
	self.btnMode.borderColor = {r = 1, g = 1, b = 1, a = 0.3}
	self:addChild(self.btnMode)

	self.btnZDown = ISButton:new(10 + btnW, y, math.floor(btnW / 2) - 2, btnH, "Z -", self, SafehouseRegionsUI.onButton)
	self.btnZDown.internal = "ZDOWN"
	self.btnZDown:initialise()
	self.btnZDown:instantiate()
	self.btnZDown.borderColor = {r = 1, g = 1, b = 1, a = 0.3}
	self:addChild(self.btnZDown)

	self.btnZUp = ISButton:new(12 + btnW + math.floor(btnW / 2), y, math.floor(btnW / 2) - 2, btnH, "Z +", self, SafehouseRegionsUI.onButton)
	self.btnZUp.internal = "ZUP"
	self.btnZUp:initialise()
	self.btnZUp:instantiate()
	self.btnZUp.borderColor = {r = 1, g = 1, b = 1, a = 0.3}
	self:addChild(self.btnZUp)

	y = y + btnH + 4
	self.infoH = FONT_HGT_SMALL * 3 + 8
	self:setWidth(math.max(self.canvasW, 280))
	self:setHeight(y + self.infoH + self:resizeWidgetHeight())

	local screenW = getCore():getScreenWidth()
	local screenH = getCore():getScreenHeight()
	self:setX((screenW - self:getWidth()) / 2)
	self:setY(math.max(20, (screenH - self:getHeight()) / 2))
end

function SafehouseRegionsUI:onButton(btn)
	if btn.internal == "MODE" then
		self.regionMode = (self.regionMode + 1) % 2
		if self.regionMode == 0 then
			self.btnMode:setTitle(getText("IGUI_SafehouseRegions_ModeRegions"))
		else
			self.btnMode:setTitle(getText("IGUI_SafehouseRegions_ModeBlueprint"))
		end
	elseif btn.internal == "ZDOWN" then
		if self.zLevel > 0 then
			self.zLevel = self.zLevel - 1
		end
	elseif btn.internal == "ZUP" then
		if self.zLevel < 7 then
			self.zLevel = self.zLevel + 1
		end
	end
end

function SafehouseRegionsUI:onMouseWheel(del)
	if del > 0 then
		if self.zLevel < 7 then self.zLevel = self.zLevel + 1 end
	else
		if self.zLevel > 0 then self.zLevel = self.zLevel - 1 end
	end
	return true
end

function SafehouseRegionsUI:worldToUi(wx, wy)
	local ux = (wx - self.view.x0) * self.tilePx
	local uy = self.canvasY + (wy - self.view.y0) * self.tilePx
	return ux, uy
end

function SafehouseRegionsUI:uiToWorld(ux, uy)
	local wx = self.view.x0 + math.floor(ux / self.tilePx)
	local wy = self.view.y0 + math.floor((uy - self.canvasY) / self.tilePx)
	return wx, wy
end

function SafehouseRegionsUI:onMouseMove(dx, dy)
	ISCollapsableWindow.onMouseMove(self, dx, dy)
	local mx = self:getMouseX()
	local my = self:getMouseY()
	if my < self.canvasY or my >= self.canvasY + self.canvasH or mx < 0 or mx >= self.canvasW then
		self.hoverInfo = ""
		return
	end
	local wx, wy = self:uiToWorld(mx, my)
	if not isInsideView(wx, wy, self.view) then
		self.hoverInfo = ""
		return
	end

	local region = IsoRegions.getIsoWorldRegion(wx, wy, self.zLevel)
	local parts = {}
	table.insert(parts, string.format("%d,%d,z%d", wx, wy, self.zLevel))
	if region then
		if region:isEnclosed() then
			table.insert(parts, getText("IGUI_SafehouseRegions_Enclosed"))
		else
			table.insert(parts, getText("IGUI_SafehouseRegions_Hole"))
		end
		if region:isFullyRoofed() then
			table.insert(parts, getText("IGUI_SafehouseRegions_Roofed"))
		else
			table.insert(parts, getText("IGUI_SafehouseRegions_NoRoof"))
		end
	else
		table.insert(parts, getText("IGUI_SafehouseRegions_NoData"))
	end
	self.hoverInfo = table.concat(parts, " | ")
end

function SafehouseRegionsUI:prerender()
	self:stayOnSplitScreen()
	ISCollapsableWindow.prerender(self)
end

function SafehouseRegionsUI:stayOnSplitScreen()
	ISUIElement.stayOnSplitScreen(self, self.playerNum)
end

function SafehouseRegionsUI:render()
	ISCollapsableWindow.render(self)

	if not canViewSafehouse(self.player, self.safehouse) then
		self:close()
		return
	end

	local sh = self.safehouse
	local z = self.zLevel
	local tile = self.tilePx
	local loaded = 0

	self:drawRect(0, self.canvasY, self.canvasW, self.canvasH, 1, 0.05, 0.08, 0.05)

	local view = self.view
	local x0, y0 = view.x0, view.y0
	local x1, y1 = view.x1, view.y1

	for wy = y0, y1 - 1 do
		for wx = x0, x1 - 1 do
			local cx = math.floor(wx / CHUNK_DIM)
			local cy = math.floor(wy / CHUNK_DIM)
			local lx = wx - cx * CHUNK_DIM
			local ly = wy - cy * CHUNK_DIM
			local chunk = IsoRegions.getDataChunk(cx, cy)
			local ux = (wx - x0) * tile
			local uy = self.canvasY + (wy - y0) * tile
			local inClaim = isInsideBounds(wx, wy, sh)

			if chunk then
				local square = chunk:getSquare(lx, ly, z, true)
				chunk:setSelectedFlags(lx, ly, z)
				if square >= 0 then
					if inClaim then
						loaded = loaded + 1
					end
					-- Region fill only inside the claim; pad is for edge walls.
					if inClaim then
						if self.regionMode == 0 then
							local chunkRegion = chunk:getIsoChunkRegion(lx, ly, z)
							if chunkRegion then
								local worldRegion = chunkRegion:getIsoWorldRegion()
								if worldRegion then
									local enclosed = worldRegion:isEnclosed()
									local hasFloor = chunk:selectedHasFlags(IsoRegions.BIT_HAS_FLOOR)
									if enclosed then
										local col = worldRegion:getColor()
										self:drawRect(ux, uy, tile, tile, 0.85, col:getRedFloat(), col:getGreenFloat(), col:getBlueFloat())
									elseif hasFloor or worldRegion:isPlayerRoom() then
										self:drawRect(ux, uy, tile, tile, 0.75, 0.85, 0.15, 0.15)
									end
								end
							end
						else
							if chunk:selectedHasFlags(IsoRegions.BIT_HAS_FLOOR) then
								self:drawRect(ux, uy, tile, tile, 1, 0.392, 0.584, 0.929)
							end
						end
					end

					local wallN = chunk:selectedHasFlags(IsoRegions.BIT_WALL_N) or chunk:selectedHasFlags(IsoRegions.BIT_PATH_WALL_N)
					local wallW = chunk:selectedHasFlags(IsoRegions.BIT_WALL_W) or chunk:selectedHasFlags(IsoRegions.BIT_PATH_WALL_W)
					local thick = math.max(1, math.floor(tile / 3))
					if wallN then
						self:drawRect(ux, uy, tile, thick, 1, 1.0, 1.0, 1.0)
					end
					if wallW then
						self:drawRect(ux, uy, thick, tile, 1, 1.0, 1.0, 1.0)
					end
				end
			end
		end
	end

	self.loadedCells = loaded

	-- claim border inset by VIEW_PAD; outer frame is the padded view
	local bx = VIEW_PAD * tile
	local by = self.canvasY + VIEW_PAD * tile
	local bw = (sh:getX2() - sh:getX()) * tile
	local bh = (sh:getY2() - sh:getY()) * tile
	self:drawRectBorder(bx, by, bw, bh, 1, 0.3, 0.9, 0.3)
	self:drawRectBorder(0, self.canvasY, self.canvasW, self.canvasH, 1, 0.25, 0.25, 0.25)

	-- player marker
	local plrX = self.player:getX()
	local plrY = self.player:getY()
	local plrZ = math.floor(self.player:getZ())
	if plrZ == z and isInsideBounds(plrX, plrY, sh) then
		if self.palphaUp then
			self.palpha = self.palpha + 0.05
			if self.palpha > 1.0 then
				self.palpha = 1.0
				self.palphaUp = false
			end
		else
			self.palpha = self.palpha - 0.05
			if self.palpha < 0.2 then
				self.palpha = 0.2
				self.palphaUp = true
			end
		end
		local px, py = self:worldToUi(plrX, plrY)
		local s = math.max(3, math.floor(tile * 0.7))
		self:drawRect(px + (tile - s) / 2, py + (tile - s) / 2, s, s, self.palpha, 0.1, 0.95, 0.2)
	end

	local infoY = self.canvasY + self.canvasH + 4 + math.max(18, FONT_HGT_SMALL + 4) + 6
	local zTxt = getText("IGUI_SafehouseRegions_ZLevel", tostring(z))
	local loadTxt = getText("IGUI_SafehouseRegions_Loaded", tostring(loaded), tostring(self.totalCells))
	self:drawText(zTxt .. "  " .. loadTxt, 8, infoY, 0.85, 0.85, 0.85, 1, UIFont.Small)
	infoY = infoY + FONT_HGT_SMALL + 2

	if loaded == 0 then
		self:drawText(getText("IGUI_SafehouseRegions_NeedChunks"), 8, infoY, 1.0, 0.55, 0.35, 1, UIFont.Small)
	elseif self.hoverInfo ~= "" then
		self:drawText(self.hoverInfo, 8, infoY, 0.9, 0.9, 0.7, 1, UIFont.Small)
	else
		self:drawText(getText("IGUI_SafehouseRegions_Hint"), 8, infoY, 0.7, 0.7, 0.7, 1, UIFont.Small)
	end
end

function SafehouseRegionsUI:close()
	ISCollapsableWindow.close(self)
	self:removeFromUIManager()
	if SafehouseRegionsUI.instance == self then
		SafehouseRegionsUI.instance = nil
	end
end

function SafehouseRegionsUI:new(x, y, width, height, safehouse, player)
	local o = ISCollapsableWindow:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.safehouse = safehouse
	o.player = player
	o.playerNum = player:getPlayerNum()
	o.borderColor = {r = 0.4, g = 0.4, b = 0.4, a = 1}
	o.backgroundColor = {r = 0, g = 0, b = 0, a = 0.85}
	o.title = getText("IGUI_SafehouseRegions_Title")
	o.resizable = false
	o.drawFrame = true
	o.pin = true
	o.isCollapsed = false
	return o
end
