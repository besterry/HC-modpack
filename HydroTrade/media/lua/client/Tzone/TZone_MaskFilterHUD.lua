if isServer() then return end

require "ISUI/ISPanel"

local BAR_WIDTH = 7
local BAR_GAP = 2

TZoneMaskFilterBar = ISPanel:derive("TZoneMaskFilterBar")

function TZoneMaskFilterBar:new(playerNum)
	local o = ISPanel:new(0, 0, BAR_WIDTH, 10)
	setmetatable(o, self)
	self.__index = self
	o.playerNum = playerNum
	o.filterPercent = 0
	o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
	return o
end

function TZoneMaskFilterBar:initialise()
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

function TZoneMaskFilterBar:prerender()
	if not self:isVisible() then return end
	local pct = self.filterPercent or 0
	local w, h = self.width, self.height
	self:drawRect(0, 0, w, h, 0.88, 0.07, 0.07, 0.07)
	self:drawRectBorder(0, 0, w, h, 0.95, 0.38, 0.38, 0.38)
	local fillH = math.max(1, math.floor((h - 2) * pct))
	local r, g, b = getFilterColor(pct)
	self:drawRect(1, h - 1 - fillH, w - 2, fillH, 0.95, r, g, b)
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

function TZoneMaskFilterBar:update()
	ISPanel.update(self)
	local hotbar = getPlayerHotbar(self.playerNum)
	if not hotbar or not hotbar:getIsVisible() then
		self:setVisible(false)
		if self.toolTip then self.toolTip:setVisible(false) end
		return
	end
	local player = getSpecificPlayer(self.playerNum)
	if not player or player:getVehicle() then
		self:setVisible(false)
		if self.toolTip then self.toolTip:setVisible(false) end
		return
	end
	if not TZone or not TZone.getEquippedMaskFilter then
		self:setVisible(false)
		if self.toolTip then self.toolTip:setVisible(false) end
		return
	end
	local filter = TZone.getEquippedMaskFilter(player)
	if filter == nil then
		self:setVisible(false)
		if self.toolTip then self.toolTip:setVisible(false) end
		return
	end
	self.filterPercent = filter
	self:setVisible(true)
	self:setWidth(BAR_WIDTH)
	self:setHeight(hotbar:getHeight())
	self:setX(hotbar:getAbsoluteX() - BAR_WIDTH - BAR_GAP)
	self:setY(hotbar:getAbsoluteY())
end

function TZoneMaskFilterBar:onMouseMoveOutside(dx, dy)
	if self.toolTip then
		self.toolTip:setVisible(false)
	end
end

local bars = {}

local function createBar(playerNum)
	if bars[playerNum] then return end
	local bar = TZoneMaskFilterBar:new(playerNum)
	bar:initialise()
	bar:addToUIManager()
	bar:setVisible(false)
	bars[playerNum] = bar
end

local function onCreatePlayer(playerIndex)
	createBar(playerIndex)
end

Events.OnCreatePlayer.Add(onCreatePlayer)

local function onGameStart()
	createBar(0)
end

Events.OnGameStart.Add(onGameStart)
