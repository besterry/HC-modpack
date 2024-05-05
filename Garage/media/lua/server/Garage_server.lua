local commands = {}
Garage = Garage or {}

commands.GarageLog = function(player, args) --Установка/удаление гаража
    if args then -- NOTE: args[1] = x, args[2] = y, args[3] = action(string), args[4] = modData
        local GlobalModData = ModData.getOrCreate("PersonalGarage") -- Получаем или создаем глобальное хранилище данных для мода "PersonalGarage"   
        GlobalModData.PersonalGarage = GlobalModData.PersonalGarage or {}     
        local Owner = args[4].GarageOwner or "" -- Получаем пользователя, которому принадлежит гараж, из modData
        local msg = player:getUsername() .. " " .. args[3] .. " Garage: [" .. args[1] - 2 .. "," .. args[2] .. ",0] Owner:" .. Owner
        if args[3] and args[3] == "add" then
            GlobalModData.PersonalGarage[Owner] = true  -- Если гараж добавляется, устанавливаем для владельца статус true
        elseif args[3] and args[3] == "delete" and GlobalModData.PersonalGarage[Owner] then
            GlobalModData.PersonalGarage[Owner] = nil -- Если гараж удаляется, удаляем информацию о владельце из хранилища данных
        end
    end
end

commands.getModDataGarage = function(player, args) --Получение modData
    local username = player:getUsername()
    local GlobalModData = ModData.getOrCreate("PersonalGarage")
    local result
    local test = false
    if GlobalModData.PersonalGarage and GlobalModData.PersonalGarage[username] then
        test = GlobalModData.PersonalGarage[username]
    end
    if test then
        result = true
    else
        result = false
    end
    sendServerCommand(player, "Garage", "onGetModData", {result}) --Args = x, y
end

commands.putCar = function(player, args) --Добавление авто в гараж
    if args then
        local car = args[1]
        local msg = player:getUsername() ..
            " PUT car " .. car.scriptName ..
            " in   Garage: [" .. args[2] - 2 .. "," .. args[3] .. ",0 ->" ..
            " Owner:".. tostring(args[4]) .. "] " ..
            " (oldsqlid:" ..  car.oldSqlid .. ")" ..
            " startDay:" .. string.format("%.2f",car.startDay) ..
            ", skinIndx:" .. car.skinIdx ..
            ", rust:" .. car.rust ..
            ", engineQuality:" .. car.engineFeature[1] .. ", EngineLoudness:" .. car.engineFeature[2] .. ", EnginePower:" .. car.engineFeature[3] ..
            ", HSV:" .. math.floor(car.HSV[1] * 100) .. "/" .. math.floor(car.HSV[2] * 100) .. "/" .. math.floor(car.HSV[3] * 100) ..
            ", keyid:" .. car.keyid ..
            ", vehicleFullName:" .. car.vehicleFullName ..
            ", dir:" .. tostring(car.dir) ..
            ", isKeysInIgnition:" .. tostring(car.isKeysInIgnition) .. ", isHotwired:" .. tostring(car.isHotwired);
        writeLog("Garage-server", msg)
    end
end

commands.getCar = function(player, args) --Получение автомобиля из гаража
    if args then
        local car = args[1]
        local spawnX = args[2]
        local geoY = args[3]
        local cell = getCell()
        local x, y = tonumber(spawnX + 1), tonumber(geoY)
        local sq = cell:getGridSquare(x, y, 0)
        local newVehicle = addVehicleDebug(car.scriptName, car.dir, car.skinIdx, sq)
        Garage.setVehicleData(newVehicle, car, sq, player)
        local newSqlID = newVehicle:getSqlId()
        local msg = player:getUsername() .. " GET car " .. car.scriptName ..
            " from Garage: [" .. args[2] - 2 .. "," .. args[3] .. ",0 ->" .. 
            " Owner:".. args[4] .. "] "..     
            " (oldsqlid:" ..  car.oldSqlid .. 
            ", newsqlid:" .. newSqlID .. ")" ..       
            " startDay:" .. string.format("%.2f", car.startDay) ..
            ", currentDay:" .. string.format("%.2f",getWorld():getWorldAgeDays())  
        writeLog("Garage-server", msg)
    end
end

local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "Garage" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)
