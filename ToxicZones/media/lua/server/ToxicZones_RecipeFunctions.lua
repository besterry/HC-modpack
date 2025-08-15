function InsertMaskFilter(items, result,  player) -- Добавление фильтра в маску
	for i=0, items:size()-1 do
		if items:get(i):getType() == "GasMaskFilter" then
       			local filter = items:get(i);
			local percent = filter:getUsedDelta()
			result:getModData().percent = percent

			local customTooltip = {filter = {label = "Tooltip_clothing_Filter", value = "percent", bar = true}, }
			result:getModData().customTooltip = customTooltip
		end
	end
end

function RemoveMaskFilter(items, result,  player) -- Удаление фильтра из маски
	for i=0, items:size()-1 do
		if items:get(i):getCategory() == "Clothing" then
			local mask = items:get(i);
			local percent = 1;
			if mask:getModData().percent then
				percent = mask:getModData().percent
			end
			local filter = player:getInventory():AddItem("GasMaskFilter")
			filter:setUsedDelta(percent)
		end
	end
end