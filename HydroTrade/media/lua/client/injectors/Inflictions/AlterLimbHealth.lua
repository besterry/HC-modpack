--- @param iso IsoPlayer
function AlterLimbHealth(iso, deviation)
    local parts = iso:getBodyDamage():getBodyParts()
    for index = 0, parts:size() - 1 do
        local part = parts:get(index) ---@type BodyPart
        part:AddHealth(Clamp(deviation, 0, 100))
    end
end