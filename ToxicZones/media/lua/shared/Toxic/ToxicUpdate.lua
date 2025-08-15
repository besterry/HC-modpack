ToxicUpdate = {}

ToxicUpdate.createRegionsModData = function(table) -- Создание таблицы регионов
	local regions = {}
	
	for i, w in pairs(table) do
		local zone = i
		local startingX = math.floor(table[zone].startX / 100); -- Начало X
		local endX = math.floor(table[zone].endX / 100); -- Конец X
		local startingY = math.floor(table[zone].startY / 100); -- Начало Y
		local endY = math.floor(table[zone].endY / 100); -- Конец Y
		
		if startingX > endX then
			local x2 = endX; -- Временная переменная для хранения значения endX
			endX = startingX; -- Устанавливаем значение endX в значение startingX
			startingX = x2; -- Устанавливаем значение startingX в значение x2
		end
		if startingY > endY then
			local y2 = endY; -- Временная переменная для хранения значения endY
			endY = startingY; -- Устанавливаем значение endY в значение startingY
			startingY = y2; -- Устанавливаем значение startingY в значение y2
		end
		-- test corners
		local regionTag = tostring(startingX) .. "x" .. tostring(startingY); -- Создаем тег региона
		regions[regionTag] = regions[regionTag] or {} -- Создаем таблицу для тега региона
		if not regions[regionTag][zone] then -- Если таблица для тега региона не существует, то создаем её
			regions[regionTag][zone] = table[zone] -- Устанавливаем значение таблицы для тега региона в значение таблицы для зоны
		end	

		regionTag = tostring(endX) .. "x" .. tostring(startingY); -- Создаем тег региона
		regions[regionTag] = regions[regionTag] or {} -- Создаем таблицу для тега региона
		if not regions[regionTag][zone] then -- Если таблица для тега региона не существует, то создаем её
			regions[regionTag][zone] = table[zone] -- Устанавливаем значение таблицы для тега региона в значение таблицы для зоны
		end

		regionTag = tostring(startingX) .. "x" .. tostring(endY); -- Создаем тег региона
		regions[regionTag] = regions[regionTag] or {} -- Создаем таблицу для тега региона
		if not regions[regionTag][zone] then -- Если таблица для тега региона не существует, то создаем её
			regions[regionTag][zone] = table[zone] -- Устанавливаем значение таблицы для тега региона в значение таблицы для зоны
		end	

		regionTag = tostring(endX) .. "x" .. tostring(endY); -- Создаем тег региона
		regions[regionTag] = regions[regionTag] or {} -- Создаем таблицу для тега региона
		if not regions[regionTag][zone] then -- Если таблица для тега региона не существует, то создаем её
			regions[regionTag][zone] = table[zone] -- Устанавливаем значение таблицы для тега региона в значение таблицы для зоны
		end			
		
		--try testing each fake square (попытка проверить каждый квадрат)
		for xN=startingX, endX do -- Цикл для каждого X
			for yN=startingY, endY do -- Цикл для каждого Y
				local regionTag = tostring(xN) .. "x" .. tostring(yN); -- Создаем тег региона
				regions[regionTag] = regions[regionTag] or {} -- Создаем таблицу для тега региона
				
				if not regions[regionTag][zone] then -- Если таблица для тега региона не существует, то создаем её
					regions[regionTag][zone] = table[zone] -- Устанавливаем значение таблицы для тега региона в значение таблицы для зоны
				end			
			end
		end
	end
	return regions -- Возвращаем таблицу регионов
end

Events.OnInitGlobalModData.Add(function(bool) -- Событие при инициализации глобальных данных
	if isClient() then -- Если клиент
		ModData.request("ToxicZone") -- Запрашиваем таблицу токсичных зон
		ModData.request("ToxicZoneRegions") -- Запрашиваем таблицу регионов
	else
		ModData.getOrCreate("ToxicZone") -- Создаем таблицу токсичных зон
		ModData.getOrCreate("ToxicZoneRegions") -- Создаем таблицу регионов
	end
end)

Events.OnReceiveGlobalModData.Add(function(key, table) -- Событие при получении глобальных данных
	if key == "ToxicZone" then -- Если ключ равен "ToxicZone"
		ModData.remove("ToxicZone") -- Удаляем таблицу токсичных зон
		ModData.getOrCreate("ToxicZone") -- Создаем таблицу токсичных зон
		ModData.add("ToxicZone", table) -- Добавляем таблицу токсичных зон

		-- создаем список по кускам и перезапускаем список квадратов
		ModData.remove("ToxicZoneSquares") -- Удаляем таблицу квадратов
		local regionsTable = ToxicUpdate.createRegionsModData(table) -- Создаем таблицу регионов
		ModData.getOrCreate("ToxicZoneRegions") -- Создаем таблицу регионов
		ModData.add("ToxicZoneRegions", regionsTable) -- Добавляем таблицу регионов

		if isServer() then -- Если сервер
			ModData.transmit("ToxicZone") -- Передаем таблицу токсичных зон
			ModData.transmit("ToxicZoneRegions") -- Передаем таблицу регионов
		end
	end
end)