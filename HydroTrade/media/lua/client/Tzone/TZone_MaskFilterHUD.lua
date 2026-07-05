if isServer() then return end

require "ISUI/ISPanel"

TZoneMaskFilterHUD = TZoneMaskFilterHUD or {}

local HOTBAR_GAP = 4

TZoneMaskFilterSlot = ISPanel:derive("TZoneMaskFilterSlot")

function TZoneMaskFilterSlot:new(playerNum)
	local o = ISPanel:new(0, 0, 50, 50)
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.filterPercent = 0
	o.maskItem = nil
	o.slotWidth = 46
	o.slotHeight = 46
	o.margins = 2
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	return o
end

function TZoneMaskFilterSlot:initialise()
	ISPanel.initialise(self)
	self:setAnchorLeft(false)
	self:setAnchorRight(false)
	self:setAnchorTop(false)
	self:setAnchorBottom(false)
	self.toolTip = ISToolTip:new()
	self.toolTip:initialise()
	self.toolTip:setVisible(false)
	self.toolTip:addToUIManager()
	self.toolTip:setOwner(self)
end

local function getFilterColor(pct)
	if pct < 0.1 then
		return 0.78, 0.18, 0.12
	end
	if pct < 0.5 then
		return 0.82, 0.68, 0.14
	end
	return 0.34, 0.62, 0.18
end

local function getFilterTooltipText(pct)
	local label = getText("Tooltip_clothing_Filter") or "Air filter"
	return label .. " " .. math.floor(pct * 100) .. "%"
end

function TZoneMaskFilterSlot:syncHotbarMetrics(hotbar)
	if not hotbar then return end
	if hotbar.slotWidth then self.slotWidth = hotbar.slotWidth end
	if hotbar.slotHeight then self.slotHeight = hotbar.slotHeight end
	if hotbar.margins then self.margins = hotbar.margins end
	self:setWidth(self.slotWidth + self.margins * 2)
	self:setHeight(self.slotHeight + self.margins * 2)
end

function TZoneMaskFilterSlot:prerender()
	if not self:isVisible() then return end

	local pct = self.filterPercent or 0
	local slotX = self.margins
	local slotY = self.margins
	local w = self.slotWidth
	local h = self.slotHeight

	local borderA = 0.95
	if pct < 0.2 then
		local pulse = 0.65 + 0.35 * math.sin((getTimestamp() or 0) / 400)
		borderA = borderA * pulse
	end

	self:drawRect(slotX, slotY, w, h, 0.75, 0.06, 0.06, 0.06)
	self:drawRectBorderStatic(slotX, slotY, w, h, borderA, 0.38, 0.38, 0.38)

	if self.maskItem then
		local tex = self.maskItem:getTexture()
		if tex then
			local iconW = tex:getWidth()
			local iconH = tex:getHeight()
			local maxIcon = math.min(w - 8, h - 14)
			local scale = math.min(maxIcon / iconW, maxIcon / iconH, 1.0)
			local drawW = iconW * scale
			local drawH = iconH * scale
			local ix = slotX + (w - drawW) / 2
			local iy = slotY + (h - drawH) / 2 - 2
			self:drawTextureScaled(tex, ix, iy, drawW, drawH, 1, 1, 1, 1)
		end
	end

	local barH = 5
	local barX = slotX + 1
	local barY = slotY + h - barH - 1
	local innerW = w - 2
	self:drawRect(barX, barY, innerW, barH, 0.85, 0.12, 0.12, 0.12)
	local fillW = math.max(1, math.floor(innerW * pct))
	local r, g, b = getFilterColor(pct)
	self:drawRect(barX, barY, fillW, barH, 0.95, r, g, b)

	local pctText = math.floor(pct * 100) .. "%"
	local textW = getTextManager():MeasureStringX(UIFont.Small, pctText)
	self:drawText(pctText, slotX + (w - textW) / 2, slotY + 2, 0.95, 0.95, 0.9, 1, UIFont.Small)

	if self.toolTip then
		if self:isMouseOver() then
			self.toolTip.description = getFilterTooltipText(pct)
			self.toolTip:setVisible(true)
			self.toolTip:bringToTop()
		else
			self.toolTip:setVisible(false)
		end
	end
end

function TZoneMaskFilterSlot:shouldShow()
	if self.playerNum > 0 or JoypadState.players[self.playerNum + 1] then
		return false
	end
	local player = getSpecificPlayer(self.playerNum)
	if not player or player:getVehicle() then
		return false
	end
	local hotbar = getPlayerHotbar(self.playerNum)
	if not hotbar or not hotbar:getIsVisible() then
		return false
	end
	if not TZone or not TZone.getEquippedMaskItem then
		return false
	end
	local maskItem, filter = TZone.getEquippedMaskItem(player)
	if not maskItem then
		return false
	end
	self.maskItem = maskItem
	self.filterPercent = filter or 0
	return true
end

function TZoneMaskFilterSlot:setSizeAndPosition()
	local hotbar = getPlayerHotbar(self.playerNum)
	if not hotbar then return end
	self:syncHotbarMetrics(hotbar)
	self:setX(hotbar:getX() - self:getWidth() - HOTBAR_GAP)
	self:setY(hotbar:getY())
end

function TZoneMaskFilterSlot:update()
	ISPanel.update(self)
	if not self:shouldShow() then
		self:setVisible(false)
		if self.toolTip then self.toolTip:setVisible(false) end
		return
	end
	self:setVisible(true)
	self:setSizeAndPosition()
end

function TZoneMaskFilterSlot:onMouseMoveOutside(dx, dy)
	if self.toolTip then
		self.toolTip:setVisible(false)
	end
end

local slots = {}

function TZoneMaskFilterHUD.getSlot(playerNum)
	return slots[playerNum]
end

local function createSlot(playerNum)
	if slots[playerNum] then return end
	local slot = TZoneMaskFilterSlot:new(playerNum)
	slot:initialise()
	slot:addToUIManager()
	slot:setVisible(false)
	slots[playerNum] = slot
end

local function onCreatePlayer(playerIndex)
	createSlot(playerIndex)
end

Events.OnCreatePlayer.Add(onCreatePlayer)

local function onGameStart()
	createSlot(0)
end

Events.OnGameStart.Add(onGameStart)
