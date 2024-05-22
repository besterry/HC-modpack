Recipe = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}
Recipe.OnTest = Recipe.OnTest or {}

--Pallets

function Recipe.OnCreate.HTCreatePallet(items, result, player) --Создание паллет
	local pallet = player:getInventory():AddItem("Base.HTpalletLogs");
	pallet:setDelta(0.02);
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
			local name = string.gsub(result:getName(), "%[.*%]", "")
			name = string.gsub(name, "%s*%[.*", "")
			local newUseDelta = items:get(i):getDelta() + items:get(i):getUseDelta()
			result:setCustomWeight(true)
			result:setName(name .. " [" .. math.floor(newUseDelta / 0.02 + 0.1) .. "/50]")
			result:setDelta(newUseDelta)
			result:setWeight(newWeight)
			result:setActualWeight(newWeight)
			return
		end
	end
end

function Recipe.OnCreate.HTGetLogWithPallet(items, result, player)  --взять с палеты
	for i = 0, items:size() - 1 do
		if items:get(i):getType() == "HTpalletLogs" then
			local newWeight = items:get(i):getWeight() - 0.3
			local newUseDelta = items:get(i):getDelta() - items:get(i):getUseDelta()
			local name = string.gsub(result:getName(), "%s*%[.*", "")
			name = string.gsub(name, "%s+$", "") -- удаляет пробелы в конце строки
			items:get(i):setCustomWeight(true)
			items:get(i):setName(name .. " [" .. math.floor(newUseDelta / 0.02 + 0.1) .. "/50]")
			items:get(i):setWeight(newWeight)
			items:get(i):setActualWeight(newWeight)
			return
		end
	end
end