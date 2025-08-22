--- @param iso IsoPlayer
function MultiplyLimbDamage(iso, deviation)
    local parts = iso:getBodyDamage():getBodyParts()
    for index = 0, parts:size() - 1 do
        if (index ~= 8) then -- Ignore the head
            local part = parts:get(index) ---@type BodyPart
            local diff = 100 - part:getHealth()
            diff = 100 - (diff + diff * (deviation / 100))
            part:SetHealth(Clamp(diff, 1, 100))
        end
    end
end