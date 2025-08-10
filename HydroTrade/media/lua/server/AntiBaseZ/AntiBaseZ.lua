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

local function spawnHordeToPlayer(player)
    local px, py = player:getX(), player:getY()
    local pz = player:getZ()
    local count = ZombRand(15, 30)
    local radius = 20
    for i=1,3 do
        local ang = ZombRandFloat(0.0, 360.0)
        local sx = px + math.cos(math.rad(ang))*radius
        local sy = py + math.sin(math.rad(ang))*radius
        createHordeFromTo(sx, sy, px, py, math.floor(count/3))
    end
    pulseNoiseAtPlayer(player, 3, 2, 1, 140, 70)
    -- addSound(player, player:getX(), player:getY(), player:getZ(), 140, 70)
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "ZombieSiege" or command ~= "spawnHorde" then return end
    if not player or player:isDead() then return end
    spawnHordeToPlayer(player)
end)
