local SafeHouse_HordeInterval = SandboxVars.SafeHouse.HordeInterval
local SafeHouse_HordeIntervalPause = SandboxVars.SafeHouse.HordeIntervalPause

Events.EveryTenMinutes.Add(function()
    local player = getPlayer()
    if not player then return end
    local md = player:getModData()

    -- Инициализация данных (если нет записи предыдущей)
    if not md.ZombieSiegelastCheckX then
        md.ZombieSiegelastCheckX = player:getX()
        md.ZombieSiegelastCheckY = player:getY()
        md.ZombieSiegestationaryTime = 0
        md.lastHordeTime = 0
        player:transmitModData()
    end

    -- Защита от отсутствующих полей
    if not md.lastHordeTime then
        md.lastHordeTime = 0
        player:transmitModData()
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
        player:transmitModData()
    end

    -- Проверка на 1 игровой день (24*60 минут = 1440 минут)
    if md.ZombieSiegestationaryTime >= SafeHouse_HordeInterval and md.lastHordeTime == 0 then
        sendClientCommand("ZombieSiege", "spawnHorde", {}) -- Спавн орды 
        md.lastHordeTime = 1 -- Просто флаг что пауза активна
        md.ZombieSiegestationaryTime = 0 -- сброс после орды        
        player:transmitModData()
        player:Say(getText("IGUI_ZombieSiege_Horde_Start")) -- для атмосферы (Вы слышите приближающийся гул...)
    else 
        if md.lastHordeTime > 0 then
            md.lastHordeTime = md.lastHordeTime + 10
            if md.lastHordeTime >= SafeHouse_HordeIntervalPause then
                md.lastHordeTime = 0 -- Сброс таймера паузы
                md.ZombieSiegestationaryTime = 0 -- Сброс таймера осады
                player:transmitModData()
            end
        end
    end
end)
