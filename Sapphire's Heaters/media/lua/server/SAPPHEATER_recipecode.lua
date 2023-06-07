-- При создании предмета в окне результатов панели создания.
function Recipe.OnCreate.HeaterBatteryRemoval(items, result, player)
	for i=0, items:size()-1 do
		local item = items:get(i)
		-- мы нашли аккумулятор, мы меняем его использованный delta в соответствии с аккумулятором
		if item:getType() == SmallHeaterObject.itemType then
			result:setUsedDelta(item:getUsedDelta());
			-- затем мы опустошаем факел, использовав дельту (его энергию)
			item:setUsedDelta(0);
		end
	end
end

function Recipe.OnTest.HeaterBatteryInsert(sourceItem, result)
	if sourceItem:getType() == SmallHeaterObject.itemType then
		return sourceItem:getUsedDelta() == 0; -- Only allow the battery inserting if the flashlight has no battery left in it.
	end
	return true -- the battery
end


function Recipe.OnCreate.OutdoorHeaterBatteryRemoval(items, result, player)
	for i=0, items:size()-1 do
		local item = items:get(i)
		-- мы нашли аккумулятор, мы меняем его использованный delta в соответствии с аккумулятором
		if item:getType() == OutdoorHeaterObject.itemType then
			result:setUsedDelta(item:getUsedDelta());
			-- затем мы опустошаем факел, использовав дельту (его энергию)
			item:setUsedDelta(0);
		end
	end
end

function Recipe.OnTest.OutdoorHeaterBatteryInsert(sourceItem, result)
	if sourceItem:getType() == OutdoorHeaterObject.itemType then
		return sourceItem:getUsedDelta() == 0; --Разрешайте вставлять батарейку только в том случае, если в фонарике не осталось батарейки.
	end
	return true -- батарея
end

