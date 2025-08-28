-- Добавляем настройку количества записей в начале файла
local MAX_PLAYER_LOG_ENTRIES = 10 -- Можно изменить на любое число
local commands = {} --Команды приходящие на сервер

local function getServerTimestamp()
    local time = getTimeInMillis()
    local time = os.date("%H:%M  %d.%m.%y", (time+10800000)/1000)
    return time
end

commands.writeSeat = function(player, args)
    local vehicle = getVehicleById(args.vehicleId)
    if not vehicle then return end
    
    local modData = vehicle:getModData()['playerLog'] or {}
    local playerIndex
    
    -- Поиск существующей записи игрока
    for i, entry in ipairs(modData) do 
        if entry.name == args.name then 
            playerIndex = i 
            break 
        end 
    end
    
    if playerIndex then
        -- Обновление существующей записи
        if args.action == "enter" then
            modData[playerIndex].timeEnter = getServerTimestamp()
            modData[playerIndex].timeExit = "In car or relogin"
            modData[playerIndex].status = "active"
            modData[playerIndex].enterX = args.enterX
            modData[playerIndex].enterY = args.enterY
            modData[playerIndex].distance = nil
        elseif args.action == "exit" then
            modData[playerIndex].timeExit = getServerTimestamp()
            modData[playerIndex].status = "exited"
            modData[playerIndex].exitX = args.exitX
            modData[playerIndex].exitY = args.exitY
            
            -- Расчет времени в пути и расстояния
            if modData[playerIndex].timeEnter and modData[playerIndex].enterX and modData[playerIndex].enterY then
                -- Расчет расстояния
                local distance = 0
                if modData[playerIndex].exitX and modData[playerIndex].exitY then
                    local dx = modData[playerIndex].exitX - modData[playerIndex].enterX
                    local dy = modData[playerIndex].exitY - modData[playerIndex].enterY
                    distance = math.sqrt(dx * dx + dy * dy)
                    if distance >= 2 then
                        modData[playerIndex].distance = math.floor(distance)
                    end
                end
            end
        end
        
        -- Перемещение в начало списка
        table.insert(modData, 1, table.remove(modData, playerIndex))
    else
        -- Создание новой записи
        local currentUser = { 
            name = args.name, 
            timeEnter = getServerTimestamp(), 
            timeExit = "In car or relogin",
            status = "active",
            enterX = args.enterX,
            enterY = args.enterY
        }
        table.insert(modData, 1, currentUser)
    end
    
    -- Используем настраиваемое количество записей
    while #modData > MAX_PLAYER_LOG_ENTRIES do 
        table.remove(modData, #modData) 
    end
    
    vehicle:getModData()['playerLog'] = modData
    args.modData = modData
    vehicle:transmitModData()
    sendServerCommand('CItransmitModData', "onSeatCar", args)
end

local function CISeat_OnClientCommand(module, command, player, args)
    if module == "CISeat" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(CISeat_OnClientCommand)