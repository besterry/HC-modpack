-- Territory Protection by координатам
local protectedZones = {
    -- Пример зоны: {x1, y1, x2, y2, name}
    {8550, 7000 , 8770, 7140, "Trade Zone"},
}

local function isInProtectedZone(square)
    if not square then return false end
    
    local x = square:getX()
    local y = square:getY()
    
    for _, zone in ipairs(protectedZones) do
        if x >= zone[1] and x <= zone[3] and y >= zone[2] and y <= zone[4] then
            return true, zone[5]
        end
    end
    return false
end

local function createHook()
    if ISDestroyCursor then
        Events.EveryOneMinute.Remove(createHook)
        local oldIsValid = ISDestroyCursor.isValid
        ISDestroyCursor.isValid = function(self, square)
            local retVal = oldIsValid(self, square)
            if isAdmin() then
                return retVal
            end
            if retVal then
                local inZone, zoneName = isInProtectedZone(square)
                if inZone then
                    local player = getPlayer()
                    player:setHaloNote(getText('IGUI_TradeZone_Protected'))
                    return false
                end
            end
            return retVal
        end
    end
end

Events.EveryOneMinute.Add(createHook)
