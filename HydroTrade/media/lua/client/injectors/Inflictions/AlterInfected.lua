--- @param iso IsoPlayer
function AlterInfected(iso, isInfected)
    iso:getBodyDamage():setInfected(isInfected)
    iso:getBodyDamage():setIsFakeInfected(isInfected)
end