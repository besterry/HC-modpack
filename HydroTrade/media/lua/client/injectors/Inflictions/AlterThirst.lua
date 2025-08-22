--- @param iso IsoPlayer
function AlterThirst(iso, deviation)
    local stats = iso:getStats()
    stats:setThirst(
        Clamp(stats:getThirst() + deviation / 100, 0, 1)
    )
end