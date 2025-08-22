--- @param iso IsoPlayer
function AddPain(iso, deviation, index)
    local damage = iso:getBodyDamage();
    local parts = damage:getBodyParts();
    local part = parts:get(index) --- @type BodyPart
    local pain = part:getAdditionalPain();
    part:setAdditionalPain(LeftClamp(pain + deviation, 0));
end