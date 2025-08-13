local SafeHouse_HordeInterval = SandboxVars.SafeHouse.HordeInterval
local SafeHouse_HordeIntervalPause = SandboxVars.SafeHouse.HordeIntervalPause
local SafeHouse_Horde = SandboxVars.SafeHouse.Horde

local function isPlayerExcluded(playerName)
    if not SafeHouse_HordeExclude or SafeHouse_HordeExclude == "" then return false end
    
    -- Приводим имя игрока к нижнему регистру
    local playerNameLower = string.lower(playerName)
    
    -- Разбиваем строку по запятым
    for excludedName in string.gmatch(SafeHouse_HordeExclude, "([^,]+)") do
        -- Убираем пробелы и приводим к нижнему регистру
        excludedName = string.lower(string.gsub(excludedName, "^%s*(.-)%s*$", "%1"))
        if excludedName == playerNameLower then
            return true
        end
    end
    return false
end

local function checkSafeHouse(player)
    local square = player:getCurrentSquare()         -- Получаем текущую клетку игрока.
    if not square then return false end
    local safehouse = SafeHouse.getSafeHouse(square) -- Получаем объект убежища для текущей клетки
    if safehouse then  -- Проверяем, существует ли убежище
        --Вычисляем координаты убежища
        local x = safehouse:getX()
        local x2 =safehouse:getX2()
        local y = safehouse:getY()
        local y2 = safehouse:getY2()
        return x,x2,y,y2
    else
        return false
    end
end

Events.EveryTenMinutes.Add(function()
    if isAdmin() then return end

    -- Обновляем переменные
    SafeHouse_HordeInterval = SandboxVars.SafeHouse.HordeInterval
    SafeHouse_HordeIntervalPause = SandboxVars.SafeHouse.HordeIntervalPause
    SafeHouse_Horde = SandboxVars.SafeHouse.Horde or false
    SafeHouse_HordeExclude = SandboxVars.SafeHouse.HordeExclude or ""

    if SafeHouse_Horde == false then return end

    local player = getPlayer()
    if not player then return end
    local playerName = player:getUsername()
    
    local x,x2,y,y2 = checkSafeHouse(player)
    if not x then return end

    if isPlayerExcluded(playerName) then return end
    local md = player:getModData()

    -- Инициализация данных (если нет записи предыдущей)
    if not md.ZombieSiegelastCheckX then
        md.ZombieSiegelastCheckX = player:getX()
        md.ZombieSiegelastCheckY = player:getY()
        md.ZombieSiegestationaryTime = 0
        md.lastHordeTime = 0
    end

    -- Защита от отсутствующих полей
    if not md.lastHordeTime then
        md.lastHordeTime = 0
    end
    
    -- Считаем дистанцию
    local dist = math.sqrt((player:getX() - md.ZombieSiegelastCheckX)^2 + (player:getY() - md.ZombieSiegelastCheckY)^2)


    if dist < 100 then
        -- игрок не отходил далеко — увеличиваем таймер
        md.ZombieSiegestationaryTime = (md.ZombieSiegestationaryTime or 0) + 10
    else
        -- игрок сменил позицию — сбрасываем
        md.ZombieSiegestationaryTime = 0
        md.ZombieSiegelastCheckX = player:getX()
        md.ZombieSiegelastCheckY = player:getY()
    end

    -- Проверка на 1 игровой день (24*60 минут = 1440 минут)
    if md.ZombieSiegestationaryTime >= SafeHouse_HordeInterval and md.lastHordeTime == 0 then
        local args = {x,x2,y,y2}
        sendClientCommand("ZombieSiege", "spawnHorde", args) -- Спавн орды
        md.lastHordeTime = 1 -- Просто флаг что пауза активна
        md.ZombieSiegestationaryTime = 0 -- сброс после орды        
        player:Say(getText("IGUI_ZombieSiege_Horde_Start")) -- для атмосферы (Вы слышите приближающийся гул...)
    else 
        if md.lastHordeTime > 0 then
            md.lastHordeTime = md.lastHordeTime + 10
            md.ZombieSiegestationaryTime = 0 -- Сброс таймера осады
            
            if md.lastHordeTime >= SafeHouse_HordeIntervalPause then
                md.lastHordeTime = 0 -- Сброс таймера паузы        
            end            
        end
    end
    -- player:transmitModData()
end)
