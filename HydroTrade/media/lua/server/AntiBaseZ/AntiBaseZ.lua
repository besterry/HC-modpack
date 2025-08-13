local function pulseNoiseAtPlayer(player, pulses, periodMins, initialDelayMins, radius, volume)
    pulses           = pulses or 3
    periodMins       = periodMins or 2
    initialDelayMins = initialDelayMins or 1
    radius           = radius or 140
    volume           = volume or 70
    local left = pulses
    local tick = initialDelayMins
    local function loop()
        if not player or player:isDead() then
            Events.EveryOneMinute.Remove(loop); return
        end
        tick = tick - 1
        if tick <= 0 then
            addSound(player, player:getX(), player:getY(), player:getZ(), radius, volume)
            left = left - 1
            tick = periodMins
            if left <= 0 then
                Events.EveryOneMinute.Remove(loop)
            end
        end
    end
    Events.EveryOneMinute.Add(loop)
end

local function spawnHordeToPlayer(player,args)    
    local playerHours = player:getHoursSurvived() -- время выживания игрока, скалируем число зомби
    local count = ZombRand(15, 30)
    local radius = 40 -- Радиус спавна, стандартный радиус 40м, но ведем расчет от убежища

    local x,x2,y,y2 = args[1],args[2],args[3],args[4] -- x,x2,y,y2 - координаты убежища (квадрат), необходимо спавнить строго за пределами убежища, не ближе 10м, игрок всегда в убежище
    --Получаем центр убежища
    local px = (x + x2) / 2
    local py = (y + y2) / 2
    --Расчет расстояния от центра до краёв убежища 
    local dist = math.max(math.abs(px - x), math.abs(py - y))
    -- local dist = math.sqrt((px - x)^2 + (py - y)^2) -- среднее расстояние от центра убежища до края, для корректировки радиуса спавна
    radius = radius + dist    
    
    --Скалируем число зомби в зависимости от времени выживания игрока, есть игроки у которых 1500 часов выживания, поэтому скалирование не слишком большое должно быть
    if playerHours > 24 then
        count = count + math.floor(playerHours/100)  -- На 100 часов +1 зомби
        if count > 100 then
            local max = ZombRand(0,15) -- Добавляем случайное число зомби
            count = 100 + max
        end
    end

    local wave = ZombRand(1,4) -- 1-3 волны
    for i=1,wave do
        local ang = ZombRandFloat(0.0, 360.0)
        local sx = px + math.cos(math.rad(ang))*radius
        local sy = py + math.sin(math.rad(ang))*radius
        local zombiePerWave = math.floor(count/wave)
        createHordeFromTo(sx, sy, px, py, zombiePerWave) -- (float spawnX, float spawnY, float targetX, float targetY, int count) sx, sy - координаты спавна, px, py - координаты цели, math.floor(count/wave) - количество зомби
    end
    pulseNoiseAtPlayer(player, 3, 2, 1, 140, 70) -- 3 импульса, 2 минуты между импульсами, 1 минута задержки, 140м радиус, 70 громкость
    -- addSound(player, player:getX(), player:getY(), player:getZ(), 140, 70)
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "ZombieSiege" or command ~= "spawnHorde" then return end
    if not player or player:isDead() then return end
    spawnHordeToPlayer(player,args)
end)
