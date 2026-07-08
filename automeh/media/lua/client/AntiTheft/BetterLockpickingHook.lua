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

local function isAntiTheftBlocked(character, vehicle)
    local levelProtection = hasAntiTheftProtection(vehicle)
    if not levelProtection then return false end

    local mechanicSkill = character:getPerkLevel(Perks.Mechanics) or 0
    local lockpickingSkill = character:getPerkLevel(Perks.Lockpicking) or 0
    local skills = (mechanicSkill + lockpickingSkill) * 2
    local baseProtection = 80 * (1 + levelProtection * 0.1)
    local chance = math.max(50, baseProtection - skills)
    if ZombRand(100) < chance then
        activateAlarm(vehicle)
        return true
    end
    return false
end

-- Перехват попытки взлома зажигания
local function hookHotwireAttempt()    
    if not HotwireWindow or not HotwireWindow.wireConnected then return end
    if not HotwireWindow.originalWireConnected then HotwireWindow.originalWireConnected = HotwireWindow.wireConnected end
    HotwireWindow.wireConnected = function(self, first, second)
        local vehicle = self.character:getVehicle()
        if vehicle and isAntiTheftBlocked(self.character, vehicle) then
            self:close()
            return
        end
        if HotwireWindow.originalWireConnected then HotwireWindow.originalWireConnected(self, first, second) end
    end
end

local VEHICLE_DOOR_MODE = 0

local function hookVehicleDoorLockpick()
    if BobbyPinWindow and not BobbyPinWindow._antiTheftDoUnlockHooked then
        BobbyPinWindow._antiTheftDoUnlockHooked = true
        local originalDoUnlock = BobbyPinWindow.doUnlock
        BobbyPinWindow.doUnlock = function(self)
            if self.mode == VEHICLE_DOOR_MODE and self.lockpick_object then
                local vehicle = self.lockpick_object:getVehicle()
                if vehicle and isAntiTheftBlocked(self.character, vehicle) then
                    self.breakTimer = 1
                    self.isFailEnd = true
                    self.character:getEmitter():playSound("lockpick_force_fail")
                    return
                end
            end
            originalDoUnlock(self)
        end
    end

    if CrowbarWindow and not CrowbarWindow._antiTheftDoUnlockHooked then
        CrowbarWindow._antiTheftDoUnlockHooked = true
        local originalDoUnlock = CrowbarWindow.doUnlock
        CrowbarWindow.doUnlock = function(self)
            if self.mode == VEHICLE_DOOR_MODE and self.lockpick_object then
                local vehicle = self.lockpick_object:getVehicle()
                if vehicle and isAntiTheftBlocked(self.character, vehicle) then
                    self:resetProgress()
                    self.character:getEmitter():playSound("lockpick_force_fail")
                    return
                end
            end
            originalDoUnlock(self)
        end
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
    local ready = true
    if HotwireWindow and HotwireWindow.wireConnected then
        hookHotwireAttempt()
    else
        ready = false
    end
    if BobbyPinWindow and CrowbarWindow then
        hookVehicleDoorLockpick()
    else
        ready = false
    end
    hookWindowSmashing()
    if ready then
        Events.OnPlayerUpdate.Remove(initAntiTheftHook)
    end
end
Events.OnPlayerUpdate.Add(initAntiTheftHook)
