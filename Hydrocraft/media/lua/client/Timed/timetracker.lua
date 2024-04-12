
-- Checks given square for at least 1 item with a timetracker definition
-- Проверяет указанный квадрат как минимум на 1 элемент с определением таймера.
local function checkForLife(player, square)
	local items = square:getWorldObjects()
	for i=0, items:size()-1 do
		if(items:get(i) and items:get(i):getItem()) then
			local item = items:get(i):getItem()
			local type = item:getType()
			-- Send cmd and exit loop as soon as we find any items with time tracker defs on this square
			-- Отправьте cmd и выйдите из цикла, как только мы найдем на этом квадрате какие-либо элементы с определениями трекера времени.
			if ItemTimeTrackerMod[ type ] ~= nil then
				local args = { x = square:getX(), y = square:getY(), z = square:getZ() }
				sendClientCommand(player, 'Timetracker', 'updateLife', args)
				return
			end
		end
	end
end

function ItemCheck()

	--disables the check if the game is running faster than speed 1 
	--отключает проверку, работает ли игра быстрее скорости 1

	--reports of FPS drops, any interaction with an item will drop the speed anyway.
	-- сообщения о падении FPS, любое взаимодействие с предметом все равно будет снижать скорость. 
	if UIManager.getSpeedControls():getCurrentGameSpeed() > 1 then
		return
	end

	local player = getPlayer()
	local px = math.floor( player:getX() + 0.5 )--round to nearest int [округлить до ближайшего целого числа]
	local py = math.floor( player:getY() + 0.5 )
	local pz = player:getZ()
	local radius = 2
	local cell = player:getCell()
	for x = px-radius, px + radius do
		for y = py-radius, py + radius do
			local sq = cell:getGridSquare(x, y, pz)
			if(sq ~= nil) then
				checkForLife(player, sq)
			end
		end
	end
end

Events.EveryOneMinute.Add(ItemCheck)
