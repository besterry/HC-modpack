--***********************************************************
--**                       BitBraven                       **
--***********************************************************

BravensBikeUtils = {}

-- Выдаем игроку все детали, установленные на велосипеде.
BravensBikeUtils.addPartsWithCondition = function(vehicle, inventory, character)
	for i=0, vehicle:getPartCount() - 1 do -- Проходим по всем частям велосипеда
		local part = vehicle:getPartByIndex(i) -- Получаем часть велосипеда
		if part:getCategory() ~= "nodisplay" then -- Если часть не является "nodisplay"
			local partItem = part:getInventoryItem() -- Получаем деталь из части		
			if partItem then -- Если деталь существует
				inventory:AddItem(partItem) -- Добавляем деталь в инвентарь
			end
		end
	end
end

BravensBikeUtils.LiftBike = function(vehicle, character)
    print("LiftBike shared")
    
    -- Сначала отключаем физику
    vehicle:setPhysicsActive(false)
    
    -- Устанавливаем углы
    vehicle:setAngles(0, 0, 0)
    
    -- Включаем физику обратно
    vehicle:setPhysicsActive(true)
    
    -- Принудительно обновляем
    vehicle:update()
    
    BravensUtils.TirePlayer(character, 0.1)	
end
-- Устанавливаем все детали в инвентаре игрока на велосипеде. Иначе, удаляем их с велосипеда.
-- Убрано. Установка деталей вручную игроками
-- BravensBikeUtils.setPartsToCondition = function(vehicle, inventory, character)
-- 	if not BravensBikeUtils.isBike(vehicle) then return end -- Применяем только к велосипедам
-- 	for i=0, vehicle:getPartCount() - 1 do -- Проходим по всем частям велосипеда
-- 		local part = vehicle:getPartByIndex(i) -- Получаем часть велосипеда
-- 		if part:getCategory() ~= "nodisplay" then -- Если часть не является "nodisplay"
-- 			local partItem = part:getInventoryItem() -- Получаем деталь из части
-- 			-- print("partItem: " , partItem)
-- 			if(partItem) then -- Если деталь существует
-- 				local invPartItem = inventory:getItemFromType(partItem:getFullType()) -- Получаем деталь из инвентаря
-- 				if(invPartItem) then -- Если деталь существует в инвентаре
-- 					if isClient() then -- Если клиент
-- 						sendClientCommand(character, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = invPartItem:getCondition() }) -- Отправляем команду на клиент
-- 					else
-- 						part:setCondition(invPartItem:getCondition()) -- Устанавливаем состояние детали на велосипеде
-- 					end
-- 					inventory:Remove(invPartItem) -- Удаляем деталь из инвентаря
-- 				else
-- 					-- Либо удаляем деталь
-- 					BikeServer.RemoveBikePart(part, vehicle)
-- 				end
-- 			end
-- 		end
-- 	end
-- end

BravensBikeUtils.isFrame = function(item)

	local itemIsFrame = false
	local itemFullType = item:getFullType()

	if (itemFullType == "Base.BicycleFrameRegular" or itemFullType == "Base.BicycleFrameRegularScrap" or itemFullType == "Base.BicycleFrameMTB" or itemFullType == "Base.BicycleFrameMTBScrap") then
		itemIsFrame = true 
	end

	return itemIsFrame
end

BravensBikeUtils.isBike = function(vehicle)
	local vehicleIsBicycle = false
	local vehicleName
	if not BravensUtils.isNumber(vehicle) then
		vehicleName = vehicle:getScriptName()
	else
		vehicleName = getVehicleById(vehicle):getScriptName()
	end
	if not vehicleName then return vehicleIsBicycle end
	if (vehicleName == "Base.BicycleRegular" or vehicleName == "Base.BicycleRegularScrap" or vehicleName == "Base.BicycleMTB" or vehicleName == "Base.BicycleMTBScrap") then
		vehicleIsBicycle = true 
	end
	return vehicleIsBicycle
end

BravensBikeUtils.GetBike = function(vehicle)
	local vehicleName = nil
	if not BravensUtils.isNumber(vehicle) then
		vehicleName = vehicle:getScriptName()
	else
		vehicleName = getVehicleById(vehicle):getScriptName()
	end
	return vehicleName
end