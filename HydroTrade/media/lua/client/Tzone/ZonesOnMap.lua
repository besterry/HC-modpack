-- Draw active TZone rectangles on world map for all players

local TZoneMap_Hooked = false
local TZoneMap_Original_prerender = nil

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

local function drawTZonesOnMap(self)
	local zones = getActiveTZones()
	if not zones then return end
	for title, z in pairs(zones) do
		local x1 = z.x
		local y1 = z.y
		local x2 = z.x2
		local y2 = z.y2

		local uiX1 = self.mapAPI:worldToUIX(x1, y1)
		local uiY1 = self.mapAPI:worldToUIY(x1, y1)
		local uiX2 = self.mapAPI:worldToUIX(x2, y2)
		local uiY2 = self.mapAPI:worldToUIY(x2, y2)

		local rx = math.min(uiX1, uiX2)
		local ry = math.min(uiY1, uiY2)
		local rw = math.abs(uiX2 - uiX1)
		local rh = math.abs(uiY2 - uiY1)

		if rw > 0.5 and rh > 0.5 then
			-- Slight amber fill and orange border for toxic zones
			self:drawRect(rx, ry, rw, rh, 0.12, 1.0, 0.65, 0.0)
			self:drawRectBorder(rx, ry, rw, rh, 0.9, 1.0, 0.5, 0.0)
			-- Title label
			if title then
				self:drawText(tostring(title), rx + 2, ry + 2, 1.0, 0.9, 0.7, 1.0, UIFont.Small)
			end
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
	TZoneMap_Hooked = true
end

Events.OnGameStart.Add(function()
	hookWorldMapForTZones()
end)

Events.OnCreatePlayer.Add(function()
	hookWorldMapForTZones()
end)


