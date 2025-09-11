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

			-- Convert world coords to UI coords
			local uiX1 = self.mapAPI:worldToUIX(x, y)
			local uiY1 = self.mapAPI:worldToUIY(x, y)
			local uiX2 = self.mapAPI:worldToUIX(x + w, y + h)
			local uiY2 = self.mapAPI:worldToUIY(x + w, y + h)

			local rx = math.min(uiX1, uiX2)
			local ry = math.min(uiY1, uiY2)
			local rw = math.abs(uiX2 - uiX1)
			local rh = math.abs(uiY2 - uiY1)

			if rw > 0.5 and rh > 0.5 then
				self:drawRect(rx, ry, rw, rh, 0.10, 0.80, 0.20, 1.00) -- фиолетовая заливка
				self:drawRectBorder(rx, ry, rw, rh, 0.90, 0.85, 0.30, 1.00) -- фиолетовая рамка
				-- Owner label
				local owner = sh:getOwner() or "?"
				self:drawText(owner, rx + 2, ry + 2, 1.0, 1.0, 1.0, 1.0, UIFont.Small)
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


