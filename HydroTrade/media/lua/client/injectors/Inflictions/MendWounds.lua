--- @param iso IsoPlayer
function MendWounds(iso, deviation)
    local parts = iso:getBodyDamage():getBodyParts()
    for index = 0, parts:size() - 1 do
        local part = parts:get(index) ---@type BodyPart

        if (part:isDeepWounded()) then
            local deepTime = part:getDeepWoundTime() - deviation;
            part:setDeepWoundTime(LeftClamp(deepTime, 0));

            -- For some reason, 0 progress does not remove said wound on it's own.
            if (part:getDeepWoundTime() <= 0) then
                part:setDeepWounded(false);
            end
        end

        if (part:bleeding()) then
            local bleedTime = part:getBleedingTime() - deviation;
            part:setBleedingTime(LeftClamp(bleedTime, 0))
        end
    end
end