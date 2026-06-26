-- Отрисовка активных зон и панель слоёв карты (как OPT)

local TZoneMap_Hooked = false
local TZoneMap_Original_prerender = nil

-- =============================
-- Константы/стили
-- =============================
local LAYERS_BTN_TEXT = "L" -- Текст на кнопке слоёв
local LAYERS_BTN_BG = { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }
local LAYERS_BTN_BG_HOVER = { r = 0.08, g = 0.08, b = 0.08, a = 1.0 }
local LAYERS_BTN_BORDER = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
local COLOR_TZONE_FILL = { r = 1.0, g = 0.65, b = 0.0, a = 0.12 }
local COLOR_TZONE_BORDER = { r = 1.0, g = 0.5, b = 0.0, a = 0.9 }
local COLOR_PVP_FILL = { r = 1.0, g = 0.0, b = 0.0, a = 0.10 }
local COLOR_PVP_BORDER = { r = 1.0, g = 0.0, b = 0.0, a = 0.9 }
local COLOR_TOWN_FILL = { r = 0.2, g = 0.6, b = 1.0, a = 0.10 }
local COLOR_TOWN_BORDER = { r = 0.2, g = 0.6, b = 1.0, a = 0.9 }
local COLOR_PVE_FILL = { r = 0.0, g = 1.0, b = 0.0, a = 0.10 }
local COLOR_PVE_BORDER = { r = 0.0, g = 0.8, b = 0.0, a = 0.9 }

-- =============================
-- Данные зон
-- =============================
local function getActiveTZones()
	local tz = ModData.get("TZone")
	if not tz then return {} end
	local res = {}
	for title, zone in pairs(tz) do
		if zone and zone.enable ~= false then
			res[title] = zone
		end
	end
	return res
end

local function getForcePvpZones()	
	local md = ModData.get("ForcePvpZoneTable")
	if not md then return {} end
	-- Если таблица пустая то запросим её с сервера (иногда у игроков ModData не инициализируется сразу или некорректна)
	if not md.PvpZoneList or not md["PvpZoneList"] or #md.PvpZoneList == 0 then
		ModData.request("ForcePvpZoneTable")
		md = ModData.get("ForcePvpZoneTable")
	end
	local list = md.PvpZoneList or md["PvpZoneList"] or {}
	return list
end


local function getPveZones()
	local res = {}
	local list = NonPvpZone and NonPvpZone.getAllZones and NonPvpZone.getAllZones()
	if not list then return res end
	for i = 0, list:size()-1 do
		local z = list:get(i)
		if z then
			local x1 = z.getX and z:getX() or 0
			local y1 = z.getY and z:getY() or 0
			local x2 = z.getX2 and z:getX2() or x1
			local y2 = z.getY2 and z:getY2() or y1
			local title = z.getTitle and z:getTitle() or ""
			table.insert(res, {
				x = math.min(x1,x2), y = math.min(y1,y2),
				x2 = math.max(x1,x2), y2 = math.max(y1,y2),
				title = title
			})
		end
	end
	return res
end

local function getTownCloseZones()
	local zonesStr = SandboxVars and SandboxVars.SafeHouseClose and SandboxVars.SafeHouseClose["CloseZone"]
	if not zonesStr or zonesStr == "" then return {} end
	local result = {}
	local chunks = luautils.split(zonesStr, ";")
	for _, chunk in ipairs(chunks) do
		if chunk and chunk ~= "" then
			local parts = luautils.split(chunk, "/")
			if #parts >= 4 then
				local x1 = (tonumber(parts[1]) or 0) * 100
				local x2 = (tonumber(parts[2]) or 0) * 100
				local y1 = (tonumber(parts[3]) or 0) * 100
				local y2 = (tonumber(parts[4]) or 0) * 100
				table.insert(result, { x = x1, y = y1, x2 = x2, y2 = y2, title = "Town" })
			end
		end
	end
	return result
end

-- =============================
-- Рендер зон на карте
-- =============================
local function drawBox(self, x1, y1, x2, y2, fill, border, label)
	if HydroMapZoneDraw and HydroMapZoneDraw.drawWorldZoneQuad then
		HydroMapZoneDraw.drawWorldZoneQuad(self, x1, y1, x2, y2, fill, border, label)
	end
end

local function drawTZonesOnMap(self)

	-- TZone
	if ClientTweaker and ClientTweaker.Options and ClientTweaker.Options.GetBool and ClientTweaker.Options.GetBool("map_show_tzones") then
		local zones = getActiveTZones()
		for title, z in pairs(zones) do
			drawBox(self, z.x, z.y, z.x2, z.y2, COLOR_TZONE_FILL, COLOR_TZONE_BORDER, z.title)
		end
	end

	-- PvP зоны из ModData.ForcePvpZoneTable
	if ClientTweaker and ClientTweaker.Options and ClientTweaker.Options.GetBool and ClientTweaker.Options.GetBool("map_show_pvp_zones") then
		local pvp = getForcePvpZones()
		for _, z in pairs(pvp) do
			local x1 = z.x or z["x"] or 0
			local y1 = z.y or z["y"] or 0
			local x2 = z.x2 or z["x2"] or 0
			local y2 = z.y2 or z["y2"] or 0
			drawBox(self, x1, y1, x2, y2, COLOR_PVP_FILL, COLOR_PVP_BORDER, "") -- z.title убрано (не нужно)
		end
	end

	-- Городские зоны из SandboxVars.SafeHouseClose.CloseZone
	if ClientTweaker and ClientTweaker.Options and ClientTweaker.Options.GetBool and ClientTweaker.Options.GetBool("map_show_town_zones") then
		local towns = getTownCloseZones()
		for _, z in ipairs(towns) do
			drawBox(self, z.x, z.y, z.x2, z.y2, COLOR_TOWN_FILL, COLOR_TOWN_BORDER, "") -- z.title убрано (не нужно)
		end
	end

	-- PvE зоны (NonPvpZone.getAllZones)
	if ClientTweaker and ClientTweaker.Options and ClientTweaker.Options.GetBool and ClientTweaker.Options.GetBool("map_show_pve_zones") then
		local pve = getPveZones()
		for _, z in ipairs(pve) do
			local title = isAdmin() and z.title or ""
			drawBox(self, z.x, z.y, z.x2, z.y2, COLOR_PVE_FILL, COLOR_PVE_BORDER, title)
		end
	end
end

-- =============================
-- Панель слоёв (чекбоксы)
-- =============================
local TZPanel = ISPanel:derive("TZPanel")

function TZPanel:new(x, y, width, height, map)
	local o = {}
	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.anchorTop = false
	o.anchorBottom = true
	o.anchorLeft = true
	o.anchorRight = false
	o.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
	o.borderColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 }
	o.map = map
	return o
end

function TZPanel:createChildren()
	local itemH = getTextManager():getFontHeight(UIFont.Small) + 8
	local tick = ISTickBox:new(10, 10, self.width - 20, itemH, "", self, TZPanel.onOptionChanged)
	tick:initialise()
	tick:instantiate()
	tick.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
	self:addChild(tick)
	self.tick = tick

	-- Опции слоёв
	self:addCheckbox("map_show_tzones", getText("IGUI_ToxicZones"))	
	self:addCheckbox("map_show_town_zones", getText("IGUI_TownZones"))
	self:addCheckbox("map_show_pvp_zones", getText("IGUI_PvpZones"))
	self:addCheckbox("map_show_pve_zones", getText("IGUI_PveZones"))

	self:syncFromOptions()
end

function TZPanel:addCheckbox(key, label)
	local idx = self.tick.options and (#self.tick.options + 1) or 1
	self.tick:addOption(label)
	self.tick.selected[idx] = false
	if not self.optionKeys then self.optionKeys = {} end
	self.optionKeys[idx] = key
	-- resize panel height to fit
	local itemH = getTextManager():getFontHeight(UIFont.Small) + 8
	self:setHeight(20 + (itemH * #self.tick.options) + 10)
end

function TZPanel:syncFromOptions()
	if not (ClientTweaker and ClientTweaker.Options) then return end
	for i, key in ipairs(self.optionKeys) do
		self.tick.selected[i] = ClientTweaker.Options.GetBool(key)
	end
end

function TZPanel.onOptionChanged(parent)
	if not (ClientTweaker and ClientTweaker.Options) then return end
	for i, key in ipairs(parent.optionKeys) do
		local val = parent.tick.selected[i] and "true" or "false"
		ClientTweaker.Options.SetBool(key, val)
	end
	-- Кнопка слоёв не меняет цвет в зависимости от опций
end

function TZPanel:toggle()
	self:setVisible(not self:getIsVisible())
	if self:getIsVisible() then
		self:bringToTop()
		self:syncFromOptions()
	end
end

-- =============================
-- Хуки карты и кнопка слоёв
-- =============================
local function applyLayersButtonStyle(btn)
	if not btn then return end
	btn.backgroundColor = LAYERS_BTN_BG
	btn.backgroundColorMouseOver = LAYERS_BTN_BG_HOVER
	btn.borderColor = LAYERS_BTN_BORDER
end

local function attachOptStyleToBtn(btn)
	if not btn then return end
	local _orig = btn.prerender
	btn.prerender = function(self)
		if _orig then _orig(self) end
		-- внешняя белая рамка (1px)
		self:drawRectBorder(0, 0, self.width, self.height, 1.0, 1.0, 1.0, 1.0)
		-- внутренняя тонкая рамка (для “глубины”)
		self:drawRectBorder(1, 1, self.width - 2, self.height - 2, 0.35, 0.6, 0.6, 0.6)
		-- лёгкая подсветка при наведении
		if self:isMouseOver() then
			self:drawRect(1, 1, self.width - 2, self.height - 2, 0.12, 1.0, 1.0, 1.0)
		end
	end
end

local function hookWorldMapForTZones()
	if TZoneMap_Hooked then return end
	if not ISWorldMap then return end
	TZoneMap_Original_prerender = ISWorldMap.prerender
	ISWorldMap.prerender = function(self)
		if TZoneMap_Original_prerender then TZoneMap_Original_prerender(self) end
		if self and self.mapAPI then
			drawTZonesOnMap(self)
		end
	end

	-- Кнопка слоёв и панель
	local Original_createChildren = ISWorldMap.createChildren
	ISWorldMap.createChildren = function(self)
		if Original_createChildren then Original_createChildren(self) end
		local btnSize = self.texViewIsometric and self.texViewIsometric:getWidth() or 48
		local x = self.buttonPanel.joypadButtons[1] and (self.buttonPanel.joypadButtons[1].x - 20 - btnSize) or 0
		self.tzoneToggleBtn = ISButton:new(x, 0, btnSize, btnSize, LAYERS_BTN_TEXT, self, function(map)
			-- toggle side panel
			if not map.tzPanel then
				local panelW, panelH = 180, 120
				local btnAbsX = map.tzoneToggleBtn:getAbsoluteX()
				local btnAbsY = map.tzoneToggleBtn:getAbsoluteY()
				local mapAbsX = map:getAbsoluteX()
				local mapAbsY = map:getAbsoluteY()
				local px = btnAbsX - mapAbsX
				local py = btnAbsY - mapAbsY - panelH - 6
				if px + panelW > map.width - 6 then px = (map.width - 6) - panelW end
				if px < 6 then px = 6 end
				if py < 6 then py = (btnAbsY - mapAbsY) + map.tzoneToggleBtn:getHeight() + 6 end
				map.tzPanel = TZPanel:new(px, py, panelW, panelH, map)
				map.tzPanel:initialise()
				map:addChild(map.tzPanel)
			end
			map.tzPanel:toggle()
		end)
		self.tzoneToggleBtn:initialise()
		self.tzoneToggleBtn:instantiate()
		self.tzoneToggleBtn.tooltip = getText("IGUI_Layers")
		applyLayersButtonStyle(self.tzoneToggleBtn)
		attachOptStyleToBtn(self.tzoneToggleBtn)
		self.buttonPanel:addChild(self.tzoneToggleBtn)
		if self.buttonPanel.joypadButtons then
			table.insert(self.buttonPanel.joypadButtons, 1, self.tzoneToggleBtn)
		end
	end

	-- Расширяем панель кнопок, чтобы не перекрывалась (как OPT)
	local TZoneWorldMapButtonPanel = { Original = { new = ISWorldMapButtonPanel.new } }
	TZoneWorldMapButtonPanel.new = function(self, x, y, width, height)
		-- Сдвиг влево и увеличение ширины под доп.кнопку
		return TZoneWorldMapButtonPanel.Original.new(self, x-48, y, width+48, height)
	end
	ISWorldMapButtonPanel.new = TZoneWorldMapButtonPanel.new
	TZoneMap_Hooked = true
end

Events.OnGameStart.Add(function()
	hookWorldMapForTZones()
end)

Events.OnCreatePlayer.Add(function()
	hookWorldMapForTZones()
end)


