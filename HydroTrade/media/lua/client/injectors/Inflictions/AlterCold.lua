--- @param iso IsoPlayer
function AlterCold(iso, deviation)
    local damage = iso:getBodyDamage()
    damage:setCatchACold(
        Clamp(damage:getCatchACold() + deviation, 0, 100)
    )
end