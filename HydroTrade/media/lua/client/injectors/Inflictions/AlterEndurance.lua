--- @param iso IsoPlayer
function AlterEndurance(iso, deviation)
    local stats = iso:getStats()
    stats:setEndurance(
        Clamp(stats:getEndurance() + deviation / 100, 0, 1)
    )
end