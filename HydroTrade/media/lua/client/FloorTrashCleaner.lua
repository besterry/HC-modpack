-- Очистка мусора на полу вне убежищ (клиент MP, очередь с бюджетом на тик).
-- Sandbox: FloorTrashCleaner.Enabled, FloorTrashCleaner.MaxAgeGameDays

if not isClient() then return end

FloorTrashCleaner = FloorTrashCleaner or {}

-- Производительность (внутренние константы)
FloorTrashCleaner.VISIBLE_RADIUS = 35
FloorTrashCleaner.OTHER_PLAYER_RADIUS = 35
FloorTrashCleaner.MAX_SQUARES_PER_TICK = 4
FloorTrashCleaner.MAX_REMOVES_PER_TICK = 8
FloorTrashCleaner.MAX_REMOVES_PER_SQUARE = 50

-- ============================================================================

local pendingQueue = {}
local pendingKeys = {}
local deferredSquares = {}
local deferredKeys = {}

local tickCounter = 0
local cachedWorldAgeDays = 0
local cachedMaxAgeGameDays = 24
local cachedMe = nil
local cachedOtherPlayers = nil

local function isModuleEnabled()
    return SandboxVars.FloorTrashCleaner and SandboxVars.FloorTrashCleaner.Enabled
end

local function getMaxAgeGameDays()
    if SandboxVars.FloorTrashCleaner then
        return SandboxVars.FloorTrashCleaner.MaxAgeGameDays or 24
    end
    return 24
end

local function squareKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function chebyshevDist(ax, ay, az, bx, by, bz)
    if math.abs(az - bz) > 1 then
        return 9999
    end
    return math.max(math.abs(ax - bx), math.abs(ay - by))
end

local function refreshPlayerCache()
    cachedMe = getPlayer()
    cachedOtherPlayers = {}
    local players = getOnlinePlayers()
    if players and cachedMe then
        for i = 0, players:size() - 1 do
            local p = players:get(i)
            if p and p ~= cachedMe then
                cachedOtherPlayers[#cachedOtherPlayers + 1] = p
            end
        end
    end
    cachedWorldAgeDays = getWorld():getWorldAgeDays()
    cachedMaxAgeGameDays = getMaxAgeGameDays()
end

local function enqueueSquare(x, y, z)
    local key = squareKey(x, y, z)
    if pendingKeys[key] or deferredKeys[key] then return end
    pendingKeys[key] = true
    pendingQueue[#pendingQueue + 1] = { x = x, y = y, z = z }
end

local function deferSquareCoords(x, y, z)
    local key = squareKey(x, y, z)
    if deferredKeys[key] then return end
    deferredKeys[key] = true
    pendingKeys[key] = nil
    deferredSquares[#deferredSquares + 1] = { x = x, y = y, z = z }
end

local function clearDeferred(key)
    deferredKeys[key] = nil
end

local function isPlayerNearCoords(x, y, z, player, radius)
    if not player then return false end
    return chebyshevDist(x, y, z, player:getX(), player:getY(), player:getZ()) <= radius
end

local function isBlockedByPlayers(x, y, z)
    if isPlayerNearCoords(x, y, z, cachedMe, FloorTrashCleaner.VISIBLE_RADIUS) then
        return true
    end
    for i = 1, #cachedOtherPlayers do
        if isPlayerNearCoords(x, y, z, cachedOtherPlayers[i], FloorTrashCleaner.OTHER_PLAYER_RADIUS) then
            return true
        end
    end
    return false
end

local function isTrashItem(item)
    if not item then return false end
    local md = item:getModData()
    if not md or not md["Owner"] or not md["TimeUsed"] then
        return false
    end
    return (cachedWorldAgeDays - md["TimeUsed"]) >= cachedMaxAgeGameDays
end

local function removeWorldObject(square, wo)
    local item = wo:getItem()
    square:transmitRemoveItemFromSquare(wo)
    wo:removeFromWorld()
    wo:removeFromSquare()
    wo:setSquare(nil)
    if item then
        item:setWorldItem(nil)
    end
end

local function processSquare(entry, removeBudget)
    local square = getCell():getGridSquare(entry.x, entry.y, entry.z)
    if not square then
        clearDeferred(squareKey(entry.x, entry.y, entry.z))
        return 0
    end

    if SafeHouse.getSafeHouse(square) then
        return 0
    end

    if isBlockedByPlayers(entry.x, entry.y, entry.z) then
        deferSquareCoords(entry.x, entry.y, entry.z)
        return 0
    end

    clearDeferred(squareKey(entry.x, entry.y, entry.z))

    local wos = square:getWorldObjects()
    if not wos or wos:isEmpty() then
        return 0
    end

    local removed = 0
    local needRequeue = false

    for i = wos:size() - 1, 0, -1 do
        if removed >= FloorTrashCleaner.MAX_REMOVES_PER_SQUARE then
            needRequeue = true
            break
        end
        if removeBudget - removed <= 0 then
            needRequeue = true
            break
        end
        local wo = wos:get(i)
        if wo and instanceof(wo, "IsoWorldInventoryObject") then
            local item = wo:getItem()
            if item and isTrashItem(item) then
                removeWorldObject(square, wo)
                removed = removed + 1
            end
        end
    end

    if needRequeue then
        enqueueSquare(entry.x, entry.y, entry.z)
    end

    return removed
end

local function promoteDeferred()
    for i = #deferredSquares, 1, -1 do
        local e = deferredSquares[i]
        if not isBlockedByPlayers(e.x, e.y, e.z) then
            table.remove(deferredSquares, i)
            clearDeferred(squareKey(e.x, e.y, e.z))
            enqueueSquare(e.x, e.y, e.z)
        end
    end
end

local function onLoadGridsquare(square)
    if not isModuleEnabled() or not square then return end

    local wos = square:getWorldObjects()
    if not wos or wos:isEmpty() then return end

    enqueueSquare(square:getX(), square:getY(), square:getZ())
end

local function onTick()
    if not isModuleEnabled() then return end
    if #pendingQueue == 0 and #deferredSquares == 0 then return end

    tickCounter = tickCounter + 1
    if tickCounter % 30 == 1 then
        refreshPlayerCache()
        promoteDeferred()
    end

    if #pendingQueue == 0 then return end

    local squaresLeft = FloorTrashCleaner.MAX_SQUARES_PER_TICK
    local removeBudget = FloorTrashCleaner.MAX_REMOVES_PER_TICK

    while squaresLeft > 0 and #pendingQueue > 0 and removeBudget > 0 do
        local entry = table.remove(pendingQueue, 1)
        pendingKeys[squareKey(entry.x, entry.y, entry.z)] = nil

        local removed = processSquare(entry, removeBudget)
        removeBudget = removeBudget - removed
        squaresLeft = squaresLeft - 1
    end
end

local function retryDeferred()
    if not isModuleEnabled() then return end
    refreshPlayerCache()
    promoteDeferred()
end

Events.LoadGridsquare.Add(onLoadGridsquare)
Events.OnTick.Add(onTick)
Events.EveryTenMinutes.Add(retryDeferred)
