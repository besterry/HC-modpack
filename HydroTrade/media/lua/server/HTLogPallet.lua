Recipe = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}
Recipe.OnTest = Recipe.OnTest or {}

--Pallets

function Recipe.OnCreate.HTCreatePallet(items, result, player) --Создание паллет
	local pallet = player:getInventory():AddItem("Base.HTpalletLogs");
	pallet:setDelta(0.02);
	player:getInventory():Remove("Log")
end

function Recipe.OnTest.HTCheckPutPalletLogs(item) --Проверка что дельта не = 1 или число бревен не больше 50
	if item:getType() == "HTpalletLogs" then
		if item:getUsedDelta() >= 1 or math.floor(item:getUsedDelta() / 0.02 + 0.1) >= 50 then return false; end
	end
	return true;
end

function Recipe.OnCreate.HTAddLogToPallet(items, result, player) --Положить на палету
	for i = 0, items:size() - 1 do
		if items:get(i):getType() == "HTpalletLogs" then
			local newWeight = items:get(i):getWeight() + 0.3
			local name = string.gsub(items:get(i):getName(), " %[.*%]", "")
			name = string.gsub(name, "%s*%[.*", "")
			local oldDelta = items:get(i):getDelta()
			local newUseDelta = oldDelta + items:get(i):getUseDelta()
			items:get(i):setCustomWeight(true)
			print("OldDelta: ", oldDelta, " + ", items:get(i):getUseDelta()," = ", newUseDelta)
			local count = math.floor((newUseDelta / 0.02) + 0.001)
			items:get(i):setName(name .. " [" .. count .. "/50]")
			items:get(i):setDelta(newUseDelta)
			if newWeight < 1.3 then newWeight = 1+(count*0.3) end
			items:get(i):setWeight(newWeight)
			items:get(i):setActualWeight(newWeight)
			player:getInventory():Remove("Log")
			return
		end
	end
end

function Recipe.OnCreate.HTGetLogWithPallet(items, result, player)  --взять с палеты
	for i = 0, items:size() - 1 do
		if items:get(i):getType() == "HTpalletLogs" then
			local newWeight = items:get(i):getWeight() - 0.3
			local oldDelta = items:get(i):getDelta() -- 0.03999999910593033
			local newUseDelta = oldDelta - items:get(i):getUseDelta() -- 0.03999999910593033 - 0.019999999552965164
			local name = string.gsub(items:get(i):getName(), "%s*%[.*", "")
			name = string.gsub(name, "%s+$", "") -- удаляет пробелы в конце строки
			items:get(i):setCustomWeight(true)
			print("OldDelta: ", oldDelta, " - ", items:get(i):getUseDelta()," = ",newUseDelta)
			if newUseDelta <= 0 then newUseDelta = 0.02 end
			local count = math.floor((newUseDelta / 0.02) + 0.001)
			items:get(i):setName(name .. " [" .. count .. "/50]")
			if newWeight < 1.3 then newWeight = 1+(count*0.3) end
			items:get(i):setWeight(newWeight)
			items:get(i):setActualWeight(newWeight)
			return
		end
	end
end