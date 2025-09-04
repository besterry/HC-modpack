local function isATMTile(worldobject)
	if not worldobject then return false end
	local sprite = worldobject.getSprite and worldobject:getSprite() or nil
	if not sprite then return false end
	local spriteName = sprite:getName()
	return spriteName ~= nil and (spriteName == "location_business_bank_01_65" or spriteName == "location_business_bank_01_64" or spriteName == "location_business_bank_01_66" or spriteName == "location_business_bank_01_67")
end

local function findATM(worldobjects)
	if not worldobjects then return nil end
	-- 1) ищем среди всех объектов под курсором
	for i = 1, #worldobjects do
		local o = worldobjects[i]
		if isATMTile(o) then
			return o
		end
	end
	-- 2) запасной путь: обходим все объекты клетки
	if clickedSquare then
		local objects = clickedSquare:getObjects()
		if objects then
			for i = 0, objects:size() - 1 do
				local o = objects:get(i)
				if isATMTile(o) then
					return o
				end
			end
		end
	end
	return nil
end

function Shop.ATMContextMenu(playerNum, context, worldobjects)
	if not isClient() then return end

	local atmWo = findATM(worldobjects)
	if not atmWo then return end

	local player = getSpecificPlayer(playerNum)
	context:addOption(getText("IGUI_ATM_Sell"), worldobjects, function()
		local sq = clickedSquare or (atmWo and atmWo:getSquare()) or getMouseSquare()
		if not sq then return end
		sq = luautils.getCorrectSquareForWall(player, sq)
		local adjacent = AdjacentFreeTileFinder.Find(sq, player)
		if not adjacent then return end
		local action = ISWalkToTimedAction:new(player, adjacent)
		action:setOnComplete(function() ATMSellUI:show(player, atmWo) end)
		ISTimedActionQueue.add(action)
	end)
end

Events.OnPreFillWorldObjectContextMenu.Add(Shop.ATMContextMenu)