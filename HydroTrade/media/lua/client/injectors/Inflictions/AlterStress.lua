--- @param iso IsoPlayer
function AlterStress(iso, deviation)
    local stats = iso:getStats()
    stats:setStress(
        Clamp(stats:getStress() + deviation / 100, 0, 1)
    )
end