Garage = Garage or {}

Garage.setVehicleData = function (vehicle,data,sq,player) --Восстановление ТС (получение)
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
    vehicle:transmitBlood() --Установка загрязнения
    vehicle:setKeyId(data.keyid) --Установка старого id ключей, что бы ключи подходили
    --Моддата: частичное восстановление--
    vehicle:getModData().register = data.modData.register
    vehicle:getModData().sqlId = vehicle:getSqlId()
    if data.modData.playerLog then vehicle:getModData().playerLog = data.modData.playerLog end
    if data.modData.Confidant then vehicle:getModData().Confidant = data.modData.Confidant end
    vehicle:transmitModData()
    --Моддата--
    if data.isKeysInIgnition then --Если ключ установлен в замок зажигания
        vehicle:setKeysInIgnition(data.isKeysInIgnition)
        local key = vehicle:createVehicleKey()
        vehicle:putKeyInIgnition(key)
    else 
        -- vehicle:setKeysInIgnition(false)
        vehicle:removeKeyFromIgnition()
    end
    if not data.isKeysInIgnition and data.isHotwired then
        vehicle:setHotwired(data.isHotwired)
    end
    for i = 0, vehicle:getPartCount() - 1 do
        local part = vehicle:getPartByIndex(i)
        local partData = data.partData[part:getId()]
        if partData then
            if partData.condition and partData.installItem then
                if partData.partModData then --Запись моддаты детали, если она есть
                    for k, v in pairs(partData.partModData) do
                        part:setModData(k, v)
                    end
                end
                if partData.installItem then ---Сохраняем предмет установленный
                    local partItem = InventoryItemFactory.CreateItem(partData.installItem)
                    partItem:setMaxCapacity(partData.containerCapacity)
                    part:setInventoryItem(partItem)
                    vehicle:transmitPartItem(part)
                end
                if partData.containerAmount then --Восстановление кол-ва бензина
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
                if partData.condition then --Сохраняем состояние
                    part:setCondition(partData.condition)
                    vehicle:transmitPartCondition(part)
                end
            elseif partData.condition then --Если у детали нет предмета (мигалки и т.п.)
                part:setCondition(partData.condition)
                
                -- if partData.containerCapacity then
                --     print("Part:", part:getId(), "Capacity:", partData.containerCapacity)
                --     part:setContainerCapacity(partData.containerCapacity) 
                -- end
                vehicle:transmitPartCondition(part)
            else --Если деталь была демонтирована
                part:setInventoryItem(nil)
                vehicle:transmitPartItem(part)
            end
        end
        local container = part:getItemContainer()--Очистка контейнеров
        if container then
            if container:getItems():size() ~= 0 then
                container:removeAllItems()
            end
        end
    end
end

Garage.onGetSkinIdx = function(player, args)
    local ServerSkinIdx = args[1]
end
Events.OnServerCommand.Add(Garage.onGetSkinIdx)

Garage.getVehicleData = function (vehicle,player,index) --Сохранение ТС (отправка на парковку)
    local result = {
        owner = player:getUsername(),
        startDay = getWorld():getWorldAgeDays(), --День постановки на парковку
        modData = vehicle:getModData(), --Моддата авто
        oldSqlid = vehicle:getModData().sqlId, --SqlId (на клиенте = внутренний ID)
        keyid = vehicle:getKeyId(), --id ключа
        vehicleFullName = vehicle:getScript():getFullName(), --Полное имя
        scriptName = vehicle:getScript():getName(), --Display Name
        dir = vehicle:getDir(), --угол направления ТС
        skinIdx = index, --Номер скина
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

        partData[partId] = {} --Формирование таблицы информации о детали
        local partModData = part:getModData() --Чтение моддаты детали
        local modDataCount = 0
        for k, v in pairs(partModData) do --считаем кол-во записей в моддате детали
            modDataCount = modDataCount + 1
        end
        if modDataCount > 0 then --Запись моддаты детали, если она есть
            partData[partId].modData = partModData 
        end
        if partItem then
            partData[partId].containerCapacity = partItem:getMaxCapacity() --Сохраняем максимальную вместимость
            partData[partId].condition = partItem:getCondition() --Сохраняем состояние ОК
            partData[partId].installItem = partItem:getFullType() --Сохраняем предмет установленный ОК
            local haveBeenRepaired = partItem:getHaveBeenRepaired() -- Число починок предмета ОК
            if haveBeenRepaired and haveBeenRepaired > 1 then
                partData[partId].haveBeenRepaired = haveBeenRepaired
            end
            if part:isContainer() and not part:getItemContainer() then
                partData[partId].containerAmount = part:getContainerContentAmount() --Сохраняем количество бензина (бензобак) ОК
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
    result['partData'] = partData
    return result
end
