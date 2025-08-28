-- Хук для BetterLockpicking - защита от взлома
local AntiTheftHook = {}

local function getOwnersAndConfidants(vehicle)
    if not vehicle then return false end
    local owner = vehicle:getModData().register
    local confidants = vehicle:getModData().confidants or {}
    if owner then
        return owner, confidants
    end
end

-- Проверка наличия противоугонки и уровня защиты
local function hasAntiTheftProtection(vehicle)
    if not vehicle then return false end    
    local antiTheft = vehicle:getModData().antiTheft
    if antiTheft and antiTheft.level then
        return antiTheft.level --Возвращаем уровень защиты 1-4
    end
    return false
end

-- Проверка активности сигнализации
local function checkActiveAlarm(vehicle)
    if not vehicle then return false end    
    local antiTheft = vehicle:getModData().antiTheft
    if antiTheft and antiTheft.alarmEnabled then
        return true
    else
        return false
    end
end

-- Активация сигнализации
local function activateAlarm(vehicle)
    if not vehicle then return end  
    if checkActiveAlarm(vehicle) then
        vehicle:setAlarmed(true)
        vehicle:triggerAlarm()
    end
    -- sendClientCommand("AntiTheft", "onTheftAttempt", {vehicleId = vehicle:getId()})
end

-- Перехват попытки взлома зажигания
local function hookHotwireAttempt()    
    if not HotwireWindow or not HotwireWindow.wireConnected then return end -- Проверяем существование HotwireWindow
    if not HotwireWindow.originalWireConnected then  HotwireWindow.originalWireConnected = HotwireWindow.wireConnected end -- Сохраняем оригинальную функцию
    HotwireWindow.wireConnected = function(self, first, second) -- Переопределяем функцию
        local vehicle = self.character:getVehicle() -- Получаем автомобиль
        local levelProtection = hasAntiTheftProtection(vehicle) -- Получаем уровень защиты
        if levelProtection then -- Проверяем защиту противоугонки
            local mechanicSkill = self.character:getPerkLevel(Perks.Mechanics) or 0
            local lockpickingSkill = self.character:getPerkLevel(Perks.Lockpicking) or 0
            local skills = (mechanicSkill + lockpickingSkill) *2--Максимум 40
            local baseProtection = 80 * (1 + levelProtection * 0.1) -- Базовая защита авто
            local chance = math.max(50, baseProtection - skills)  -- Рассчитываем шанс взлома
            local zombrand = ZombRand(100)
            -- print("DEBUG: chance: " .. chance .. " > zombrand: " .. zombrand)
            if zombrand < chance then -- Если взлом не удался, активируем сигнализацию
                activateAlarm(vehicle)
                self:close() -- Закрываем окно взлома
                return
            end
        end
        -- print("Successfully hotwired")
        if HotwireWindow.originalWireConnected then HotwireWindow.originalWireConnected(self, first, second) end -- Если защиты нет - обычный взлом
    end
end

-- Перехват разбития стекла через перехват действий
-- context:addOption(getText("ContextMenu_Vehicle_Smashwindow", getText("IGUI_VehiclePart" .. part:getId())), playerObj, ISVehiclePartMenu.onSmashWindow, part)
local function hookWindowSmashing()
    if ISSmashVehicleWindow then -- Проверяем существование ISSmashVehicleWindow
        local originalPerform = ISSmashVehicleWindow.perform -- Сохраняем оригинальную функцию
        ISSmashVehicleWindow.perform = function(self) -- Переопределяем функцию
            local vehicle = self.vehicle
            local character = self.character
            if hasAntiTheftProtection(vehicle) then -- Проверяем защиту противоугонки
                activateAlarm(vehicle)
                -- character:Say("ALARM! Anti-theft system activated!")
            end
            if originalPerform then -- Если защиты нет - обычное разбитие
                originalPerform(self)
            end
        end
    end
end

-- Усложнение процесса взлома (не работает)
local function enhanceHotwireDifficulty()
    if not BetLock or not BetLock.Wires then return end    
    -- Увеличиваем количество попыток для успешного взлома
    local originalAddWires = BetLock.Wires.addWires
    if originalAddWires then
        BetLock.Wires.addWires = function(parent)
            -- Добавляем дополнительные провода для усложнения
            originalAddWires(parent)
            local level = hasAntiTheftProtection(parent.vehicle)
            -- Увеличиваем сложность
            if parent.vehicle and level then
                -- Добавляем дополнительные провода для усложнения
                for i = 1, level do
                    -- print("DEBUG: Adding extra wire for level " .. level)
                    -- Добавляем лишние провода для усложнения
                    local extraWire = ISLabel:new(10 + i * 30, 200, 20, "EXTRA", 1, 1, 1, 1, UIFont.Small, true)
                    parent:addChild(extraWire)
                end
            end
        end
    end
end

-- Инициализация хука
local function initAntiTheftHook()
    if HotwireWindow and HotwireWindow.wireConnected then
        hookHotwireAttempt()
        hookWindowSmashing()
        -- enhanceHotwireDifficulty()
        Events.OnPlayerUpdate.Remove(initAntiTheftHook)
    end
end
Events.OnPlayerUpdate.Add(initAntiTheftHook)
