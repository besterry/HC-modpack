function Recipe.GetItemTypes.PinkSlip(scriptItems) -- Проверка тега PinkSlip
    scriptItems:addAll(getScriptManager():getItemsTag("PinkSlip"))
end 
    
function Recipe.OnCanPerform.CW_ClaimVehicle(recipe, playerObj, item) -- Проверяем, стоит ли игрок на земле и не находится ли он в здании
    if playerObj:isOutside() and playerObj:getZ() == 0 then
        return true
    end    
    return false
end

function Recipe.OnCreate.CW_ClaimVehicle(items, result, player) -- Получение автомобиля
    local pinkslip = items:get(0)

    if not player:isOutside() or player:getZ() > 0 then
    -- Это не должно происходить, но если это происходит, то даем игроку обратной pinkslip.
        player:Say("This wont work unless im standing on the ground outside...")
        player:getInventory():AddItem(pinkslip)
    else 
		local modData = pinkslip:getModData()
		local requestedVehicle = { type = modData.VehicleID }
		--Состояние автомобиля
		if (type(modData.Condition) == "number") then
			requestedVehicle.condition = modData.Condition
		end
		--Уровень топлива бензобака
		if (type(modData.GasTank) == "number") then
			requestedVehicle.gastank = modData.GasTank 
		end	
		--Уровень топлива цистерны
		if (type(modData.FuelTank) == "number") then
			requestedVehicle.fueltank = modData.FuelTank
		end
		--Есть ли ключ
		if modData.HasKey then
			requestedVehicle.makekey = true
		end  
		--Есть ли улучшение
		if modData.Upgraded then
			requestedVehicle.upgrade = true
		end 
        --Уровень ржавчины
        if modData.Rust then
            requestedVehicle.rust = modData.Rust
        end
        --Цвет автомобиля
        if modData.HSV then
            requestedVehicle.HSV = modData.HSV
        end

        requestedVehicle.dir = player:getDir(); -- Угол автомобиля
        requestedVehicle.clear = true -- Очистка инвентаря
        requestedVehicle.battery = 1 --Батарея
        
        
        sendClientCommand(player, "CW", "spawnVehicle",  requestedVehicle ) 
    end

end