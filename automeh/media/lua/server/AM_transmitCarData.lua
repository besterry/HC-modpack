local commands = {}
commands.SetPart = function(player, args) --Ремонт автомобиля
    local vehicle = getVehicleById(args.vehicleId)
    if vehicle then
        local part = vehicle:getPartByIndex(args.partId)
        local item
        if args.condition then    
            part:setCondition(args.condition)
        end
        if args.repaired then
            part:getInventoryItem():setHaveBeenRepaired(args.repaired)
        end
        vehicle:transmitPartCondition(part)
        --Log:
        if part:getItemType() then item = part:getItemType():get(0) else item = "No" end
        local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
        local msg = player:getUsername() .." [" .. coord .."]" .. " repair car, sqlid:" .. vehicle:getModData().sqlId .. ", part:" .. args.partId .. ", Item:".. item .. ", condition:" .. part:getCondition() .. " -> " .. args.condition .. " Price:"..args.coast
        writeLog("Automeh",msg)
    end
end

commands.getCarPP = function (player,args) --Получение списка транспорта на штрафстоянке игрока
    local Username = player:getUsername()
    local globalModData = ModData.get("ParkingPenalty")
    local modDataUser = globalModData[Username]
    sendServerCommand(player,"AutoMeh","onCarPP",{modDataUser=modDataUser})
end

commands.deleteCar = function (player,args) --Удаление авто из админки
    local globalModData = ModData.get("ParkingPenalty")
    local modDataUser = globalModData[args.vehicleData.modData.register]
    if modDataUser then
        for i, vehicleData in ipairs(modDataUser) do
            if vehicleData.oldSqlid == args.vehicleData.oldSqlid and vehicleData.vehicleFullName == args.vehicleData.vehicleFullName then
                table.remove(modDataUser, i)  -- Удаление подтаблицы авто из modDataUser
                break
            end
        end
    end
    local coords = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = "DELETE Penalty Parking: " .. player:getUsername() .. " " ..
    "[" .. coords .. "]" ..
    " Register:" .. args.vehicleData.modData.register .. "," ..
    " vehicle: " .. args.vehicleData.scriptName .. "," ..
    " GameDay:" .. string.format("%.2f",args.vehicleData.startDay) .. "," ..
    " Oldsqlid:" .. args.vehicleData.oldSqlid .. "," ..
    " skinIndx:" .. args.vehicleData.skinIdx .. "," ..
    " rust:" .. args.vehicleData.rust .. "," ..
    " engineQuality:" .. args.vehicleData.engineFeature[1] .. "," ..
    " HSV:" .. math.floor(args.vehicleData.HSV[1] * 100) .. "/" .. math.floor(args.vehicleData.HSV[2] * 100)  .. "/" .. math.floor(args.vehicleData.HSV[3] * 100)
    writeLog("Automeh", msg)
    sendServerCommand(player,"AutoMeh","onGetAllCarPenaltyParking",{globalModData=globalModData})
end

commands.getAllCarPenaltyParking = function (player,args) --Получение полного списка транспорта на штрафстоянке
    local globalModData = ModData.get("ParkingPenalty")
    sendServerCommand(player,"AutoMeh","onGetAllCarPenaltyParking",{globalModData=globalModData})
end

local setVehicleData = function (vehicle,data,sq,player) --Восстановление ТС (получение)
    if not vehicle or not data then
        return
    end
    vehicle:setAngles(unpack(data.angles)) --Установк углов
    vehicle:setColorHSV(unpack(data.HSV)) --Установка цвета
    vehicle:transmitColorHSV()
    vehicle:setEngineFeature(unpack(data.engineFeature)) --Установка качество двигателя
    vehicle:transmitEngine()
    vehicle:setRust(data.rust) --Установка уровня ржавчины
    vehicle:transmitRust()
    local bFront, bRight, bRear, bLeft = unpack(data.blood) --установка загрязнения
    vehicle:setBloodIntensity("Front", bFront)
    vehicle:setBloodIntensity("Right", bRight)
    vehicle:setBloodIntensity("Rear", bRear)
    vehicle:setBloodIntensity("Left", bLeft)
    vehicle:transmitBlood()
    vehicle:setKeyId(data.keyid)
    --Моддата: частичное восстановление--
    vehicle:getModData().register = data.modData.register
    vehicle:getModData().sqlId = vehicle:getSqlId()
    if data.modData.playerLog then vehicle:getModData().playerLog = data.modData.playerLog end
    if data.modData.Confidant then vehicle:getModData().Confidant = data.modData.Confidant end
    vehicle:transmitModData()
    --Моддата--
    if data.isKeysInIgnition then
        vehicle:setKeysInIgnition(data.isKeysInIgnition)
        local key = vehicle:createVehicleKey()
        vehicle:putKeyInIgnition(key)
    else 
        vehicle:setKeysInIgnition(data.isKeysInIgnition)
    end
    if not data.isKeysInIgnition and data.isHotwired then
        vehicle:setHotwired(data.isHotwired)
    end
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local partData = data.partData[part:getId()]
        if partData then
            if partData.partModData then --Запись моддаты детали, если она есть
                for k, v in pairs(partData.partModData) do
                    part:setModData(k, v)
                end
            end            
            if partData.installItem then ---Сохраняем предмет установленный
                local partItem = InventoryItemFactory.CreateItem(partData.installItem)
                part:setInventoryItem(partItem)
                vehicle:transmitPartItem(part)
            end
            if partData.containerAmount then --Сохраняем вместимость (бензобак)
                part:setContainerContentAmount(partData.containerAmount)
            end
            if partData.delta then --Сохраняем использование предмета (аккумулятор) ОК
                local partItem = part:getInventoryItem()
                if partItem and partItem:IsDrainable() then
                    partItem:setUsedDelta(partData.delta)
                    vehicle:transmitPartUsedDelta(part)
                end
            end
            if partData.haveBeenRepaired then -- Число починок предмета
                local partItem = part:getInventoryItem()
                partItem:setHaveBeenRepaired(partData.haveBeenRepaired)
                vehicle:transmitPartItem(part)
            end
            if partData.isLocked ~= nil then --Сохранение закрыты ли двери
                local door = part:getDoor()
                if door then
                    door:setLocked(partData.isLocked)
                    vehicle:transmitPartDoor(part)
                end
            end
            if partData.isLockBroken ~= nil then --Сломан ли замок
                local door = part:getDoor()
                if door then
                    door:setLockBroken(partData.isLockBroken)
                    vehicle:transmitPartDoor(part)
                end
            end
			local container = part:getItemContainer()--Очистка контейнеров
			if container then
				if container:getItems():size() ~= 0 then
					container:removeAllItems()
				end
			end
            if partData.condition then --Сохраняем состояние
                part:setCondition(partData.condition)
                vehicle:transmitPartCondition(part)
            end
        end
    end    
    local coords = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = "RESTORE PenaltyParking: " .. player:getUsername() .. " " ..
    "[" .. coords .. "]" ..
    " vehicle: " .. data.scriptName .. "," ..
    " Days store:" .. string.format("%.2f",(getWorld():getWorldAgeDays() - data.startDay)) .. "," ..
    " Price:" .. math.floor((getWorld():getWorldAgeDays() - data.startDay)*SandboxVars.NPC.ParkingPenaltyPricePerDay) .. "," ..
    " Oldsqlid:" .. data.oldSqlid .. "," ..
    " NewSqlid:" .. vehicle:getSqlId() .. "," ..
    " skinIndx:" .. data.skinIdx .. "," ..
    " rust:" .. data.rust .. "," ..
    " engineQuality:" .. data.engineFeature[1] .. "," ..
    " HSV:" .. math.floor(data.HSV[1] * 100) .. "/" .. math.floor(data.HSV[2] * 100)  .. "/" .. math.floor(data.HSV[3] * 100)
    writeLog("Automeh", msg)
end

commands.GetCar = function (player,args) --Спавн авто
    local Username = player:getUsername() --Получение владельца авто
    local globalModData = ModData.get("ParkingPenalty") --Получение глобальной моддаты парковки
    local modDataUser = globalModData[Username] --Получение моддаты парковки владельца
    local car = {}
    if modDataUser then --Поиск в глобальной моддате нужного авто и удаление
        for i, vehicleData in ipairs(modDataUser) do
            if vehicleData.oldSqlid == args.oldSqlid and vehicleData.vehicleFullName == args.vehicleFullName then
                car = vehicleData
                table.remove(modDataUser, i)  -- Удаление подтаблицы из modDataUser
                break
            end
        end
    end
    local cell = getCell()
    local coordinates = string.split(SandboxVars.NPC.ParkingPenaltyCoordinateSpawn, ",")
    local x,y = tonumber(coordinates[1]), tonumber(coordinates[2])
    local sq = cell:getGridSquare(x, y, 0)
    local newVehicle = addVehicleDebug(car.scriptName, car.dir, car.skinIdx, sq)
    setVehicleData(newVehicle,car,sq,player)
end

local getVehicleData = function (vehicle,player) --Сохранение ТС (отправка на парковку)
    local result = {
        startDay = getWorld():getWorldAgeDays(), --День постановки на парковку
        modData = vehicle:getModData(), --Моддата авто
        oldSqlid = vehicle:getSqlId(), --SqlId
        keyid = vehicle:getKeyId(), --id ключа
        vehicleFullName = vehicle:getScript():getFullName(), --Полное имя
        scriptName = vehicle:getScript():getName(), --Display Name
        dir = vehicle:getDir(), --угол направления ТС
        skinIdx = vehicle:getSkinIndex(), --Номер скина
        coords = { vehicle:getX(), vehicle:getY(), vehicle:getZ() }, --Координаты
        angles = { vehicle:getAngleX(), vehicle:getAngleY(), vehicle:getAngleZ() }, --Угол поворота
        rust = vehicle:getRust(), --Ржавчина
        blood = { -- NOTE: по часовой стрелке спереди.
            vehicle:getBloodIntensity("Front"),
            vehicle:getBloodIntensity("Right"),
            vehicle:getBloodIntensity("Rear"),
            vehicle:getBloodIntensity("Left")
        },
        HSV = { --Цвет
            vehicle:getColorHue(),
            vehicle:getColorSaturation(),
            vehicle:getColorValue(),
        },
        isKeysInIgnition = vehicle:isKeysInIgnition(), --Есть ли ключи в замке зажигания
        isHotwired = vehicle:isHotwired(), --Взломано ли авто
        engineFeature = { --Характеристики движка
            vehicle:getEngineQuality(),
            vehicle:getEngineLoudness(),
            vehicle:getEnginePower(),
        }
    }
    local partData = {}
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i) --Деталь
        local partItem = part:getInventoryItem() --Предмет детали
        local partId = part:getId() -- ID детали
        local partCondition = part:getCondition() --состояние детали

        partData[partId] = {} --Формирование таблицы информации детали
        local partModData = part:getModData() --Чтение моддаты детали моддату детали
        local modDataCount = 0
        for k, v in pairs(partModData) do
            modDataCount = modDataCount + 1
        end
        if modDataCount > 0 then
            partData[partId].modData = partModData --Запись моддаты детали, если она есть ОК
        end
        if partItem then
            partData[partId].condition = partItem:getCondition() --Сохраняем состояние ОК
            partData[partId].installItem = partItem:getFullType() --Сохраняем предмет установленный ОК
            local haveBeenRepaired = partItem:getHaveBeenRepaired() -- Число починок предмета ОК
            if haveBeenRepaired and haveBeenRepaired > 1 then
                partData[partId].haveBeenRepaired = haveBeenRepaired
            end
            if part:isContainer() and not part:getItemContainer() then
                partData[partId].containerAmount = part:getContainerContentAmount() --Сохраняем вместимость (бензобак) ОК
            end
            if partItem:IsDrainable() then
                partData[partId].delta = partItem:getUsedDelta() --Сохраняем использование предмета (аккумулятор) ОК
            end
            local door = part:getDoor()
            if door then
                partData[partId].isLocked = door:isLocked() --Сохранение закрыты ли двери ОК
                partData[partId].isLockBroken = door:isLockBroken() --Сломан ли замок ОК
            end
        elseif not partItem and not part:isInventoryItemUninstalled() then
            partData[partId].condition = partCondition --Запись состояния, если нет предмета ОК
        end
    end
    local coords = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = "ADD Penalty Parking: " .. player:getUsername() .. " " ..
    "[" .. coords .. "]" ..
    " vehicle: " .. result.scriptName .. "," ..
    " GameDay:" .. string.format("%.2f",result.startDay) .. "," ..
    " Oldsqlid:" .. result.oldSqlid .. "," ..
    " NewSqlid:" .. vehicle:getSqlId() .. "," ..
    " skinIndx:" .. result.skinIdx .. "," ..
    " rust:" .. result.rust .. "," ..
    " engineQuality:" .. result.engineFeature[1] .. "," ..
    " HSV:" .. math.floor(result.HSV[1] * 100) .. "/" .. math.floor(result.HSV[2] * 100)  .. "/" .. math.floor(result.HSV[3] * 100)
    writeLog("Automeh", msg)
    result['partData'] = partData
    return result
end

commands.saveCar = function(player, args)
    local vehicle = getVehicleById(args.vehicle) --получение ТС на стороне сервера
    local register = vehicle:getModData().register --Ник игрока
    local vehicleData = getVehicleData(vehicle,player) --Получение таблицы для сохранения ТС
    local oldSqlid = vehicle:getModData().sqlId --Получение номера ТС (sqlid)
    local globalModData = ModData.get("ParkingPenalty")
    globalModData[register] = globalModData[register] or {} --Формирование таблицы пользователя (владельца ТС)
    table.insert(globalModData[register],vehicleData) --NOTE: при удалении тачек перебирать эту таблицу (globalModData[register]) перебирать с конца
    triggerEvent("OnClientCommand", 'vehicle', "remove", player, {vehicle = vehicle:getId()}) --Удаление авто из мира
end

local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "AutoMeh" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)