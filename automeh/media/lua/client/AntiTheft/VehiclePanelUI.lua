
-- Хук для добавления кнопки сигнализации на панель автомобиля
local VehiclePanelHook = {}

-- Проверка наличия противоугонки
local function hasAntiTheftProtection(vehicle)
    if not vehicle then return false end    
    local antiTheft = vehicle:getModData().antiTheft
    return antiTheft and antiTheft.installed
end

-- Проверка является ли игрок владельцем
local function isOwner(vehicle, player)
    if not vehicle or not player then return false end    
    local antiTheft = vehicle:getModData().antiTheft
    local owner = vehicle:getModData().register    
    return owner and owner == player:getUsername()
end

-- Функция включения/выключения сигнализации
local function toggleAlarm(vehicle, player)
    if not hasAntiTheftProtection(vehicle) or not isOwner(vehicle, player) then
        return
    end    
    local antiTheft = vehicle:getModData().antiTheft
    if not antiTheft then return end
    local currentState = antiTheft.alarmEnabled or false
    -- Переключаем состояние
    antiTheft.alarmEnabled = not currentState
    local args = {}
    args.vehicleId = vehicle:getId()
    args.alarmEnabled = antiTheft.alarmEnabled
    sendClientCommand("AntiTheft", "toggleAlarm", args)
end


Events.OnServerCommand.Add(function(module, command, args)
    if module == "AntiTheft" then
        if command == "onToggleAlarm" then
            local vehicle = getVehicleById(args.vehicleId)
            if vehicle then
                vehicle:getModData().antiTheft.alarmEnabled = args.alarmEnabled
                -- print("DEBUG: toggleAlarm on server", args.alarmEnabled)
            end
        end
    end
end)

-- Функция обновления иконки (теперь для кнопки)
local function updateAlarmIcon(dashboard)
    if not dashboard.alarmButton or not dashboard.vehicle then return end
    
    local antiTheft = dashboard.vehicle:getModData().antiTheft
    if antiTheft and antiTheft.alarmEnabled then
        -- Сигнализация включена - показываем иконку вкл
        dashboard.alarmButton:setImage(dashboard.alarmActivateIcon)
    else
        -- Сигнализация выключена - показываем иконку выкл
        dashboard.alarmButton:setImage(dashboard.alarmDeactivateIcon)
    end
end

-- Основная функция добавления иконки
local function addAlarmIconToDashboard()
    local player = getPlayer()
    if not player then return end
    
    local vehicle = player:getVehicle()
    if not vehicle then return end
    
    -- Ищем панель автомобиля
    local playerData = getPlayerData(player:getPlayerNum())
    if not playerData or not playerData.vehicleDashboard then return end
    
    local dashboard = playerData.vehicleDashboard
    
    -- Проверяем наличие противоугонки и владельца
    local hasProtection = hasAntiTheftProtection(vehicle)
    local isOwnerPlayer = isOwner(vehicle, player)
    
    -- Если иконка уже существует
    if dashboard.alarmButton then
        -- Проверяем, нужно ли её скрыть
        if not hasProtection or not isOwnerPlayer then
            dashboard.alarmButton:setVisible(false)
            return
        else
            -- Показываем иконку и обновляем состояние
            dashboard.alarmButton:setVisible(true)
            updateAlarmIcon(dashboard)
            return
        end
    end
    
    -- Создаем иконку только если есть противоугонка и игрок владелец
    if not hasProtection or not isOwnerPlayer then return end
    
    -- Загружаем текстуры
    local alarmActivateIcon = getTexture("media/textures/AlarmActivate.png")
    local alarmDeactivateIcon = getTexture("media/textures/AlarmDeactivate.png")
    
    dashboard.alarmButton = ISButton:new(65, 20, 25, 25, "", dashboard, function()
        if dashboard.vehicle and hasAntiTheftProtection(dashboard.vehicle) and isOwner(dashboard.vehicle, player) then
            toggleAlarm(dashboard.vehicle, player)
        end
    end)
    
    dashboard.alarmButton:initialise()
    dashboard.alarmButton:instantiate()
    
    -- Настраиваем кнопку как в CarInfo
    dashboard.alarmButton:setImage(alarmActivateIcon)
    dashboard.alarmButton:setDisplayBackground(false)
    dashboard.alarmButton.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    
    dashboard:addChild(dashboard.alarmButton)
    
    -- Сохраняем ссылки на иконки для переключения
    dashboard.alarmActivateIcon = alarmActivateIcon
    dashboard.alarmDeactivateIcon = alarmDeactivateIcon
    
    -- Обновляем иконку
    updateAlarmIcon(dashboard)
end

-- Используем Events.OnTick для добавления иконки
local function onTick()
    addAlarmIconToDashboard()
end

-- Запускаем проверку каждые 10 тиков (чтобы не нагружать игру)
local tickCounter = 0
Events.OnTick.Add(function()
    tickCounter = tickCounter + 1
    if tickCounter >= 100 then
        onTick()
        tickCounter = 0
    end
end)