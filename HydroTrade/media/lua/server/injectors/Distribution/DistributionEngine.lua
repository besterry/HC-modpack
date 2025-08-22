local function CheckRules(value, rule)
    if not rule then
        return true
    end
    if type(rule) == "string" then
        return value == rule
    elseif type(rule) == "table" then
        for _, r in ipairs(rule) do
            if value == r then
                return true
            end
        end
    end
    return false
end

--- @param roomType string
--- @param containerType string
--- @param container ItemContainer
local function SpawnProcedure(roomType, containerType, container)
    local maxItems = SpawnConfig.maxItems or math.huge
    local items = SpawnConfig.items or {}
    local rolls = SpawnConfig.rolls or 0

    local spawnedCount = 0
    for roll = 1, rolls do
        for _, entry in ipairs(items) do
            if spawnedCount >= maxItems then break end
            if CheckRules(roomType, entry.RoomType) and CheckRules(containerType, entry.ContainerType) then
                local chancePercent = entry.Chance * 100
                local chanceRandom = ZombRand(100)
                if chanceRandom < chancePercent then
                    container:AddItem(entry.Name)
                    spawnedCount = spawnedCount + 1
                end
            end
        end
    end
end

-- Events.OnFillContainer.Add(SpawnProcedure)