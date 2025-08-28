--***********************************************************
--**                       BitBraven                       **
--***********************************************************

BikeServer = {};

BikeServer.RemoveBikePart = function(part, vehicle) -- более не используется
    part:setInventoryItem(nil);
    vehicle:transmitPartItem(part);
end

local function DeleteBikePartOnCreate(vehicle) -- удаляет все детали с велосипеда при создании (детали игроки создают сами)
    if not vehicle then return end
    for i=0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        if part:getCategory() ~= "nodisplay" then
            part:setInventoryItem(nil);            
            vehicle:transmitPartItem(part);
        end
    end
end

BikeServer.LiftBike = function(vehicle, playerObj)
    vehicle:setAngles(0, 0, 0)
    BravensUtils.TirePlayer(playerObj, 0.1)
end

BikeServer.StartBike = function(vehicle)
    vehicle:setKeysInIgnition(true)
    vehicle:setHotwired(true)
    vehicle:engineDoRunning()
end

-- BikeServer.UpdateBike = function(character, vehicle, frame, inventory)

-- 	if not vehicle then return end
-- 	if not BravensBikeUtils.isBike(vehicle) then return end

-- 	BravensBikeUtils.setPartsToCondition(vehicle, inventory, character)
-- end

local function onClientCommand(module, command, player, args)

    if module ~= "Braven" then return end

    if command == "SpawnBike" then

        local square = getSquare(player:getX(), player:getY(), player:getZ())
        local vehicle = addVehicleDebug(args.bikeName, nil, nil, square);
        DeleteBikePartOnCreate(vehicle)
        local modData = args.frame:getModData()
        if modData.frameColor then
            vehicle:setSkinIndex(modData.frameColor)
            vehicle:updateSkin()
        end
        if modData.rustAmount then
            vehicle:setRust(modData.rustAmount)
            vehicle:transmitRust()
        end
        if modData then
            local vehicleModData = vehicle:getModData()
            -- Копируем все данные из рамы в велосипед
            for key, value in pairs(modData) do
                vehicleModData[key] = value
            end
            vehicle:transmitModData()
        end
        -- vehicle:setHotwired(true)
        if vehicle then
            local params = { vehicleId = vehicle:getId(), frame = args.frame};
            if isServer() then
                sendServerCommand(player, 'Braven', 'BikeSpawned', params);
            else
                triggerEvent('OnServerCommand', 'Braven', 'BikeSpawned', params);
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand);
