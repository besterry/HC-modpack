--- @param iso IsoPlayer
function Painkill(iso, deviation)
    local stats = iso:getStats()
    stats:setPain(
        Clamp(stats:getPain() - deviation, 0, 100)
    )
end