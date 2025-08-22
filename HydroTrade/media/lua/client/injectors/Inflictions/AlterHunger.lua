--- @param iso IsoPlayer
function AlterHunger(iso, deviation)
    local stats = iso:getStats()
    stats:setHunger(
        Clamp(stats:getHunger() + deviation / 100, 0, 1)
    )
end