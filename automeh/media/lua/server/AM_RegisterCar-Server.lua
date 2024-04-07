local commands = {}
commands.SetRegister = function(player, args) --Регистрация ТС
    local args = args or {}
    local vehicle = getVehicleById(args.vehicleId)
    local username = player:getUsername()
    if not vehicle:getModData().register then
        vehicle:getModData().register=username
        vehicle:transmitModData()
        args.result = true
        args.username = username
        local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
        local msg = username .. " [" .. coord .. "]"  .. " register car:" .. vehicle:getSqlId()
        writeLog("Automeh",msg)
    else
        args.result = false
    end
    sendServerCommand("RegisterCar", "onSetRegister", args)
end

commands.DelRegister = function(player, args) --Удаление регистрации ТС
    local vehicle = getVehicleById(args.vehicleId)
    local args = args or {}
    local username = player:getUsername()
    if vehicle:getModData().register then
        vehicle:getModData().register=nil
        if vehicle:getModData().Confidant then
            vehicle:getModData().Confidant = nil
        end
        vehicle:transmitModData()
        args.result = true
        local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
        local msg = username .. " [" .. coord .. "]"  .. " Unregister car:" .. vehicle:getSqlId()
        writeLog("Automeh",msg)
    else
        args.result = false
    end
    sendServerCommand("RegisterCar", "onDelRegister", args)
end

commands.AddConfidant = function(player, args) --Добавление игрока в доверенные
    local vehicle = getVehicleById(args.vehicleId)--Получаем авто
    local maxEntries = 5 --максимум доверенностей
    local curentEntries
    if vehicle:getModData().Confidant then
        curentEntries = #vehicle:getModData().Confidant --получаем число доверенностей
    else
        curentEntries = 0
    end
    local args = args or {}
    if vehicle:getModData().register and curentEntries<maxEntries then      --Проверка что у авто есть регистрация и количество доверенностей меньше установленного числа  
        vehicle:getModData().Confidant = vehicle:getModData().Confidant or {} --Чек на наличие таблицы
        table.insert(vehicle:getModData().Confidant, args.user) --Добавление юзера
        vehicle:transmitModData() --Запись в бд
        args.result = true
        local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
        local msg = player:getUsername() .. " [" .. coord .. "]"  .. " car:" .. vehicle:getSqlId() .. ", add user Confidant:" .. args.user
        writeLog("Automeh",msg)
    else
        args.result = false
    end
    sendServerCommand("RegisterCar", "onAddConfidant", args)
end

commands.DelConfidant = function(player, args) --Удаление игрока из доверенных
    local vehicle = getVehicleById(args.vehicleId)--Получаем авто
    local args = args or {}
    local playerIndex
    if vehicle:getModData().register then --Проверка наличия регистрации          
        for i, playerName in ipairs(vehicle:getModData().Confidant) do --Получение индекса игрока по нику
            if playerName == args.user then
                playerIndex = i
                break
            end
        end
        if playerIndex then --Найден ли индекс
            table.remove(vehicle:getModData().Confidant, playerIndex) --Удаление по найденому индексу
            vehicle:transmitModData() --Запись в бд
            args.result = true --Успешное удаление
            args.playerIndex = playerIndex --Формирование индекса для передачи клиенту
            local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
            local msg = player:getUsername() .. " [" .. coord .. "]"  .. " car:" .. vehicle:getSqlId() .. ", delete user Confidant:" .. args.user
            writeLog("Automeh",msg)
        else
            args.result = false --Если нет индекса
        end
    else
        args.result = false --Если нет регистрации
    end
    sendServerCommand("RegisterCar", "onDelConfidant", args)
end

local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "RegisterCar" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)