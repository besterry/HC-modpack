local commands = {}

--Установка противоугона
commands.InstallAntiTheft = function(player, args)
    -- print("InstallAntiTheft")
    local vehicleId = args.vehicleId
    local vehicle = getVehicleById(args.vehicleId)
    local username = player:getUsername()
    
    if not vehicle or not vehicle:getModData().register then
        args.result = false
        args.message = "Only registered cars"
        args.vehicleId = vehicleId
        sendServerCommand("AntiTheft", "onInstallAntiTheft", args)
        return
    end
    
    if vehicle:getModData().register ~= username then
        args.result = false
        args.message = "Only the owner can install"
        sendServerCommand("AntiTheft", "onInstallAntiTheft", args)
        return
    end
    local installDate = getGameTime():getWorldAgeHours()
    -- Устанавливаем противоугонку
    vehicle:getModData().antiTheft = {
        installed = true,
        installer = username,
        installDate = installDate,
        level = 1
    }
    
    vehicle:transmitModData()
    args.result = true -- не используется на клиенте
    args.message = "AntiTheft successfully installed" -- не используется на клиенте
    args.installer = username
    args.installDate = installDate
    args.level = 1
    args.vehicleId = vehicleId
    
    -- Логирование
    local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = username .. " [" .. coord .. "] install anti-theft on car:" .. vehicle:getSqlId()
    writeLog("Automeh", msg)
    
    -- print("sendServerCommand onInstallAntiTheft")
    sendServerCommand("AntiTheft", "onInstallAntiTheft", args)
end

commands.toggleAlarm = function(player, args)
    -- print("ToggleAlarm")
    local vehicleId = args.vehicleId
    local vehicle = getVehicleById(vehicleId)
    
    if not vehicle or not vehicle:getModData().antiTheft then
        args.result = false
        args.message = "AntiTheft not installed"
        sendServerCommand("AntiTheft", "onToggleAlarm", args)
        return
    end
    if vehicle:getModData().antiTheft then
        vehicle:getModData().antiTheft.alarmEnabled = args.alarmEnabled
        vehicle:transmitModData()
        vehicle:setAlarmed(args.alarmEnabled)
        local responseArgs = {}
        responseArgs.result = true
        responseArgs.vehicleId = vehicleId
        responseArgs.alarmEnabled = vehicle:getModData().antiTheft.alarmEnabled
        sendServerCommand("AntiTheft", "onToggleAlarm", responseArgs)
    end
end

--Снятие противоугона
commands.RemoveAntiTheft = function(player, args)
    -- print("RemoveAntiTheft")
    local vehicleId = args.vehicleId
    local vehicle = getVehicleById(vehicleId)
    local username = player:getUsername()
    
    if not vehicle or not vehicle:getModData().antiTheft then
        args.result = false
        args.message = "AntiTheft not installed"
        args.vehicleId = vehicleId
        sendServerCommand("AntiTheft", "onRemoveAntiTheft", args)
        return
    end
    
    if vehicle:getModData().register ~= username then
        args.result = false
        args.message = "Only the owner can remove"
        sendServerCommand("AntiTheft", "onRemoveAntiTheft", args)
        return
    end
    
    -- Снимаем противоугонку
    vehicle:getModData().antiTheft = nil
    vehicle:transmitModData()
    args.result = true
    args.message = "AntiTheft successfully removed"
    args.vehicleId = vehicleId
    
    -- Логирование
    local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = username .. " [" .. coord .. "] remove anti-theft from car:" .. vehicle:getSqlId()
    writeLog("Automeh", msg)
    
    -- print("sendServerCommand onRemoveAntiTheft")
    sendServerCommand("AntiTheft", "onRemoveAntiTheft", args)
end

-- Перехват попыток взлома (вызов с клиента BetterLockpicking)
local function onHotwireAttempt(player, vehicle)
    if not vehicle:getModData().antiTheft or not vehicle:getModData().antiTheft.installed then
        return
    end
    
    -- Включаем сигнализацию
    vehicle:setAlarmed(true)
    
    -- Блокируем двигатель
    vehicle:setHotwired(false)
    
    -- Логирование попытки взлома
    local coord = math.floor(player:getX()) .. ',' .. math.floor(player:getY()) .. ',0'
    local msg = player:getUsername() .. " [" .. coord .. "] attempted hotwire on protected car:" .. vehicle:getSqlId()
    writeLog("Automeh", msg)
    
    -- Уведомляем владельца
    local owner = getPlayerByUsername(vehicle:getModData().register)
    if owner then
        sendServerCommand(owner, "AntiTheft", "onTheftAttempt", {
            vehicleId = vehicle:getId(),
            thief = player:getUsername(),
            coord = coord
        })
    end
end

-- Обработчик команд
local function onClientCommand(module, command, player, args)
    if module == "AntiTheft" and commands[command] then
        -- print("onClientCommand",module,command)
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(onClientCommand)

-- Перехват событий взлома (если BetterLockpicking активен)
if BetterLockpicking then
    local oldHotwire = ISVehicleMenu.onHotwire
    function ISVehicleMenu.onHotwire(playerObj)
        local vehicle = playerObj:getVehicle()
        if vehicle and vehicle:getModData().antiTheft and vehicle:getModData().antiTheft.installed then
            onHotwireAttempt(playerObj, vehicle)
            return
        end
        if oldHotwire then
            oldHotwire(playerObj)
        end
    end
end