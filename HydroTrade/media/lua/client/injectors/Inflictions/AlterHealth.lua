--- @param iso IsoPlayer
function AlterHealth(iso, deviation)
    local damage = iso:getBodyDamage()
    if (deviation >= 0) then
        if ((damage:getOverallBodyHealth() + deviation) < 100) then
            damage:AddGeneralHealth(deviation)
        end
    else
        damage:ReduceGeneralHealth(math.abs(deviation))
    end
end