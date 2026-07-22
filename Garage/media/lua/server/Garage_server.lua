local commands = {}
Garage = Garage or {}

commands.GarageLog = function(player, args)                         --Установка/удаление гаража
    if args then                                                    -- NOTE: args[1] = x, args[2] = y, args[3] = action(string), args[4] = modData, args[5] = garageCount
        local GlobalModData = ModData.getOrCreate("PersonalGarage") -- Получаем или создаем глобальное хранилище данных для мода "PersonalGarage"
        GlobalModData.PersonalGarage = GlobalModData.PersonalGarage or {}
        local Owner = args[4].GarageOwner or ""                     -- Получаем пользователя, которому принадлежит гараж, из modData
        local msg = player:getUsername() ..
        " " .. args[3] .. " Garage: [" .. args[1] - 2 .. "," .. args[2] .. ",0] Owner:" .. Owner
        if args[3] and args[3] == "add" then
            GlobalModData.PersonalGarage[Owner] = true -- Если гараж добавляется, устанавливаем для владельца статус true
        elseif args[3] and args[3] == "delete" and GlobalModData.PersonalGarage[Owner] then
            -- print("delete garage")
            if args[5] and args[5] <= 1 then -- Если гаражей нет, то удаляем информацию о владельце из хранилища данных
                -- print("delete garage2")
                GlobalModData.PersonalGarage[Owner] = nil  -- Если гараж удаляется, удаляем информацию о владельце из хранилища данных
            end
        end
        writeLog("Garage-server", msg)
    end
end

commands.getSkinIdx = function(player, args) --Получение данных о машине с сервера
    local vehicle = nil
    vehicle = getVehicleById(args.vehicle)
    local skinIdx = nil
    skinIdx = vehicle:getSkinIndex()
    sendServerCommand(player, "Garage", "getSkinIdx", { skinIdx = skinIdx })
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
    sendServerCommand(player, "Garage", "onGetModData", { result }) --Args = x, y
end

commands.putCar = function(player, args) --Добавление авто в гараж (на стороне сервера логирование, постановка через моддату тайла)
    if args then
        local car = args[1]
        local msg = player:getUsername() ..
            " PUT car " .. car.scriptName ..
            " in   Garage: [" .. args[2] - 2 .. "," .. args[3] .. ",0 ->" ..
            " Owner:" .. tostring(args[4]) .. "] " ..
            " (oldsqlid:" .. car.oldSqlid .. ")" ..
            " startDay:" .. string.format("%.2f", car.startDay) ..
            ", skinIndx:" .. car.skinIdx ..
            ", rust:" .. car.rust ..
            ", engineQuality:" ..
            car.engineFeature[1] ..
            ", EngineLoudness:" .. car.engineFeature[2] .. ", EnginePower:" .. car.engineFeature[3] ..
            ", HSV:" ..
            math.floor(car.HSV[1] * 100) .. "/" .. math.floor(car.HSV[2] * 100) .. "/" .. math.floor(car.HSV[3] * 100) ..
            ", keyid:" .. car.keyid ..
            ", vehicleFullName:" .. car.vehicleFullName ..
            ", dir:" .. tostring(car.dir) ..
            ", isKeysInIgnition:" .. tostring(car.isKeysInIgnition) .. ", isHotwired:" .. tostring(car.isHotwired);
        writeLog("Garage-server", msg)
    end
end

local function findGarageTileObject(x, y)
    local cell = getCell()
    local sq = cell and cell:getGridSquare(tonumber(x), tonumber(y), 0)
    if not sq then
        return nil
    end
    local objects = sq:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if object and object:getSprite() and object:getSprite():getName() == "garage_0" then
            return object
        end
    end
    return nil
end

local function claimCarFromGarage(garageObj, oldSqlid, vehicleFullName)
    if not garageObj then
        return nil
    end
    local md = garageObj:getModData()
    local list = md and md["Garage"]
    if not list then
        return nil
    end
    for i, vehicleData in ipairs(list) do
        if vehicleData.oldSqlid == oldSqlid and vehicleData.vehicleFullName == vehicleFullName then
            local car = vehicleData
            table.remove(list, i)
            garageObj:transmitModData()
            return car
        end
    end
    return nil
end

commands.getCar = function(player, args) --Выдача авто: атомарный claim на сервере (анти-дюп при 2+ игроках)
    if not args or not player then
        return
    end

    local oldSqlid = args.oldSqlid
    local vehicleFullName = args.vehicleFullName
    local spawnX = args.spawnX
    local spawnY = args.spawnY
    local garageX = args.garageX
    local garageY = args.garageY
    local username = player:getUsername()

    if oldSqlid == nil or not vehicleFullName or spawnX == nil or spawnY == nil or garageX == nil or garageY == nil then
        writeLog("Garage-server", username .. " GET car REJECTED bad args")
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "bad_args" })
        return
    end

    local cell = getCell()
    local x, y = tonumber(spawnX + 1), tonumber(spawnY)
    local sq = cell and cell:getGridSquare(x, y, 0)
    if not sq then
        writeLog("Garage-server", username .. " GET car REJECTED no square oldsqlid:" .. tostring(oldSqlid))
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "no_square" })
        return
    end
    if sq:getVehicleContainer() then
        writeLog("Garage-server", username .. " GET car REJECTED spot busy oldsqlid:" .. tostring(oldSqlid))
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "busy" })
        return
    end

    local garageObj = findGarageTileObject(garageX, garageY)
    if not garageObj then
        writeLog("Garage-server", username .. " GET car REJECTED no garage tile [" .. tostring(garageX) .. "," .. tostring(garageY) .. "]")
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "no_garage" })
        return
    end

    local owner = garageObj:getModData().GarageOwner or "unknown"
    local car = claimCarFromGarage(garageObj, oldSqlid, vehicleFullName)
    if not car then
        -- Уже забрали другой игрок / запись отсутствует
        writeLog("Garage-server", username .. " GET car REJECTED not in garage (oldsqlid:" .. tostring(oldSqlid) .. " " .. tostring(vehicleFullName) .. ")")
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "missing" })
        return
    end

    local newVehicle = addVehicleDebug(car.vehicleFullName, car.dir, car.skinIdx, sq)
    if not newVehicle then
        -- Откат: вернуть авто в гараж
        local md = garageObj:getModData()
        md["Garage"] = md["Garage"] or {}
        table.insert(md["Garage"], car)
        garageObj:transmitModData()
        writeLog("Garage-server", username .. " GET car REJECTED spawn failed, restored oldsqlid:" .. tostring(oldSqlid))
        sendServerCommand(player, "Garage", "getCarResult", { ok = false, reason = "spawn_fail" })
        return
    end

    local oldKeyID = newVehicle:getKeyId()
    newVehicle:removeKeyFromIgnition()
    Garage.setVehicleData(newVehicle, car, sq, player)
    sendServerCommand(player, "Garage", "findKeyCarEvent", { keyId = oldKeyID, x = newVehicle:getX(), y = newVehicle:getY() })
    sendServerCommand(player, "Garage", "getCarResult", { ok = true })

    local newSqlID = newVehicle:getSqlId()
    local msg = username .. " GET car " .. tostring(car.scriptName) ..
        " from Garage: [" .. tostring(garageX) .. "," .. tostring(garageY) .. ",0 ->" ..
        " Owner:" .. tostring(owner) .. "] " ..
        " (oldsqlid:" .. tostring(car.oldSqlid) ..
        ", newsqlid:" .. tostring(newSqlID) .. ")" ..
        " startDay:" .. string.format("%.2f", car.startDay or 0) ..
        ", currentDay:" .. string.format("%.2f", getWorld():getWorldAgeDays()) ..
        " (" .. string.format("%.2f", (getWorld():getWorldAgeDays() - (car.startDay or 0))) .. " game days)"
    writeLog("Garage-server", msg)
end

local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "Garage" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)
