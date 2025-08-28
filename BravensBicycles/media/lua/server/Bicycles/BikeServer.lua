--***********************************************************
--**                       BitBraven                       **
--***********************************************************

BikeServer = {};
local commands = {}

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

commands.LiftBike = function(player, args)
    local vehicle = getVehicleById(tonumber(args.vehicleId))
    if not vehicle then return end
    -- print("LiftBike - respawning vehicle")
    
    -- Сохраняем все данные велосипеда
    local vehicleData = {}
    vehicleData.scriptName = vehicle:getScriptName()
    vehicleData.skinIndex = vehicle:getSkinIndex()
    vehicleData.rust = vehicle:getRust()
    vehicleData.modData = vehicle:getModData()
    
    -- Сохраняем все установленные запчасти
    local parts = {}
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        if part:getCategory() ~= "nodisplay" then
            local partItem = part:getInventoryItem()
            if partItem then
                parts[i] = {
                    partId = part:getId(),
                    item = partItem,
                    condition = part:getCondition()
                }
            end
        end
    end
    
    -- Получаем позицию через getX, getY, getZ
    local x = vehicle:getX()
    local y = vehicle:getY()
    local z = vehicle:getZ()
    local square = getSquare(x, y, z)
    
    -- Удаляем старый велосипед
    vehicle:permanentlyRemove()
    
    -- Создаем новый велосипед
    local newVehicle = addVehicleDebug(vehicleData.scriptName, nil, nil, square)
    
    -- Восстанавливаем внешний вид
    newVehicle:setSkinIndex(vehicleData.skinIndex)
    newVehicle:updateSkin()
    newVehicle:setRust(vehicleData.rust)
    newVehicle:transmitRust()
    
    -- Восстанавливаем modData, исключая sqlid
    local newModData = newVehicle:getModData()
    for key, value in pairs(vehicleData.modData) do
        if key ~= "sqlId" then
            newModData[key] = value
        end
    end
    newVehicle:transmitModData()
    
    -- Устанавливаем запчасти обратно
    for partIndex, partData in pairs(parts) do
        local part = newVehicle:getPartByIndex(partIndex)
        if part then
            part:setInventoryItem(partData.item)
            part:setCondition(partData.condition)
            newVehicle:transmitPartItem(part)
        end
    end
    
    -- print("Vehicle respawned successfully")
end
local function onClientCommandBikeServer(module, command, player, args)
    if module == "BikeServer" and commands[command] then
        -- print("onClientCommand",module,command)
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(onClientCommandBikeServer)


-- BikeServer.LiftBike = function(vehicle, playerObj)
--     vehicle:setAngles(0, 0, 0)
--     BravensUtils.TirePlayer(playerObj, 0.1)
-- end
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
