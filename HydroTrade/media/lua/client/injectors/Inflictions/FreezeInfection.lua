--- @param iso IsoPlayer
function FreezeInfection(iso)
    local damage = iso:getBodyDamage()
    damage:setInfected(false)
    damage:setInfectionLevel(0)
end