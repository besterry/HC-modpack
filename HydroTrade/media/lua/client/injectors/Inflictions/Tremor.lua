local function JamHeld(iso, chance)
    local item = iso:getPrimaryHandItem() ---@type InventoryItem
    if item ~= nil and item:IsWeapon() then
        if chance > ZombRand(100)+1 then
            if item:getAmmoType() and iso:IsAiming() then
                item:setJammed(true)
            end
        end
    end
end

--- @param iso IsoPlayer
function Tremor(iso, chance)
    if chance > ZombRand(100)+1 then
        iso:dropHandItems()
    else
        JamHeld(iso, chance)
    end
end