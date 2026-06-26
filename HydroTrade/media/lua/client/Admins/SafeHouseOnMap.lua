-- Draw Safehouses on the world map for Admins only

local Hooked = false
local Original_prerender = nil

local function drawSafehousesOnMap(self)
	local player = getPlayer()
	if not player then return end
	if player:getAccessLevel() ~= "Admin" then return end

	local list = SafeHouse.getSafehouseList()
	if not list then return end

	for i = 0, list:size() - 1 do
		local sh = list:get(i)
		if sh then
			local x = sh:getX()
			local y = sh:getY()
			local w = sh:getW()
			local h = sh:getH()
			local owner = sh:getOwner() or "?"
			if HydroMapZoneDraw and HydroMapZoneDraw.drawWorldZoneQuad then
				HydroMapZoneDraw.drawWorldZoneQuad(self, x, y, x + w, y + h,
					{ r = 0.80, g = 0.20, b = 1.00, a = 0.10 },
					{ r = 0.85, g = 0.30, b = 1.00, a = 0.90 },
					owner)
			end
		end
	end
end

local function hookWorldMap()
	if Hooked then return end
	if not ISWorldMap then return end
	Original_prerender = ISWorldMap.prerender
	ISWorldMap.prerender = function(self)
		if Original_prerender then Original_prerender(self) end
		if self and self.mapAPI then
			drawSafehousesOnMap(self)
		end
	end
	Hooked = true
end

Events.OnGameStart.Add(function()
	hookWorldMap()
end)

Events.OnCreatePlayer.Add(function()
	hookWorldMap()
end)


