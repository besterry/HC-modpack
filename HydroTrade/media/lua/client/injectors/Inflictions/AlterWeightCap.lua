--- @param iso IsoPlayer
local function ApplySavedDelta(iso, mult)
    local delta = iso:getModData().weightDeltaSave or 0
    local weightDelta = iso:getMaxWeightDelta()
    local multDelta = delta * mult
    iso:setMaxWeightDelta(weightDelta + multDelta)
end

--- @param iso IsoPlayer
function AlterWeightCap(iso, deviation)
    --- Return to the initial carrying weight.
    ApplySavedDelta(iso, -1)

    --- PZ recalculates max carry weight each time player relogs.
    --- This modData entry is required to preserve this value.
    local data = iso:getModData()
    local deltaSave = data.weightDeltaSave or 0
    data.weightDeltaSave = deltaSave + deviation / 100
    ApplySavedDelta(iso, 1)
end

local function OnCreatePlayer(_, player)
    ApplySavedDelta(player, 1)
end

Events.OnCreatePlayer.Add(OnCreatePlayer)