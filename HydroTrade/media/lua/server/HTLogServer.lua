local commands = {}

-- installPart / uninstallPart logging moved to Vehicles/VehicleCommands.lua (logs after roll with Result)

commands.setContainerContentAmount = function (player, args) -- args = { vehicle = self.vehicle:getId(), part = self.part:getId(), amount = self.tankTarget }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    if not part then
        return
    end
    local msg = "Player: " .. player:getUsername() .. " [" .. math.floor(player:getX()) .. "," ..  math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId ..
    " Part: " .. part:getId() .. " -> GASOLINE -> " .. math.floor(args.amount) .. "/" .. part:getContainerCapacity()
    writeLog("vehicle-FuelChange", msg)
end

--sendClientCommand(playerObj, "vehicle", "repairPart", { vehicle = part:getVehicle():getId(), part = part:getId() })
commands.repairPart = function(player, args) -- args = { vehicle = self.vehicle:getId(), part = self.part:getId() }
    local vehicle = getVehicleById(args.vehicle)
    local part = vehicle:getPartById(args.part)
    if not part then
        return
    end
    local msg = '"' .. player:getUsername() .. '"'.. " -> REPAIR PART TO 100%" .. " [" .. math.floor(player:getX()) .. "," ..  math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId .. " Part: " .. part:getId() 
    writeLog("admin", msg)
end

-- sendClientCommand(playerObj, "vehicle", "repair", { vehicle = vehicle:getId() }) -- перенесена в VehicleCommandsOv.lua
-- commands.repair = function(player, args) -- args = { vehicle = self.vehicle:getId() }
--     local vehicle = getVehicleById(args.vehicle)
--     if not vehicle then
--         return
--     end    
--     local msg = '"' .. player:getUsername() .. '"' .. " -> REPAIR VEHICLE TO 100%" .. " [" .. math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0]" ..
--     " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
--     " SqlId: " .. (vehicle:getModData().sqlId or "N/A")    
--     writeLog("admin", msg)
-- end

commands.setNewEngineQuality = function(player, args) -- args = { vehicle = self.vehicle:getId(), carQuality = self.carQuality }
    local vehicle = getVehicleById(args.vehicle)
    if not vehicle then
        return
    end
    local msg = '"' .. player:getUsername() .. '"' .. " -> SET NEW ENGINE QUALITY TO " .. args.carQuality .. " [" .. math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0]" ..
    " vehicle: " .. vehicle:getScriptName() .. "[" .. math.floor(vehicle:getX()) .. "," .. math.floor(vehicle:getY()) .. ",0]" ..
    " SqlId: " .. vehicle:getModData().sqlId
    writeLog("admin", msg)
    vehicle:setEngineFeature(args.carQuality, vehicle:getEngineLoudness(), vehicle:getEnginePower()) -- (качество, громкость, мощность)
    vehicle:transmitEngine()
end


local function BalanceAndSH_OnClientCommand(module, command, player, args)
    if module == "vehicle" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(BalanceAndSH_OnClientCommand)


Events.OnClientCommand.Add(function(module, command, player, args) -- Изменение веса игрока
    if module == "player" and command == "setWeight" then
        local msg = "Player: " .. player:getUsername() .. " [" .. math.floor(player:getX()) .. "," .. math.floor(player:getY()) .. ",0] change weight: " .. args.weight .. " for OnlineID -> " .. args.id
        writeLog("admin", msg)
    end
end)