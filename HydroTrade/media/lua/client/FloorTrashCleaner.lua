-- Очистка мусора на полу вне убежищ (клиент MP, очередь с бюджетом).
-- Sandbox: FloorTrashCleaner.Enabled, FloorTrashCleaner.MaxAgeGameDays
-- Ванильную очистку (HoursForWorldItemRemoval) отключить: она не учитывает убежища.

if not isClient() then return end

FloorTrashCleaner = FloorTrashCleaner or {}

FloorTrashCleaner.VISIBLE_RADIUS = 35
FloorTrashCleaner.OTHER_PLAYER_RADIUS = 35
FloorTrashCleaner.TICK_INTERVAL = 4
FloorTrashCleaner.MAX_SQUARES_PER_TICK = 2
FloorTrashCleaner.MAX_REMOVES_PER_TICK = 4
FloorTrashCleaner.MAX_REMOVES_PER_SQUARE = 50
FloorTrashCleaner.MAX_PENDING_QUEUE = 256

local pendingQueue = {}
local pendingKeys = {}
local deferredSquares = {}
local deferredKeys = {}
local skipKeys = {}

local tickCounter = 0
local processCounter = 0
local tickRegistered = false

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

local function isSquareInSafehouse(square)
    if not square then return false end
    return SafeHouse.getSafeHouse(square) ~= nil
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

local function ensureTick()
    if not tickRegistered then
        Events.OnTick.Add(onTick)
        tickRegistered = true
    end
end

local onTick

local function maybeRemoveTick()
    if tickRegistered and #pendingQueue == 0 and #deferredSquares == 0 then
        Events.OnTick.Remove(onTick)
        tickRegistered = false
        tickCounter = 0
    end
end

local function enqueueSquare(x, y, z)
    local key = squareKey(x, y, z)
    if pendingKeys[key] or deferredKeys[key] or skipKeys[key] then return end
    if #pendingQueue >= FloorTrashCleaner.MAX_PENDING_QUEUE then return end
    pendingKeys[key] = true
    pendingQueue[#pendingQueue + 1] = { x = x, y = y, z = z }
    ensureTick()
end

local function deferSquareCoords(x, y, z)
    local key = squareKey(x, y, z)
    if deferredKeys[key] then return end
    deferredKeys[key] = true
    pendingKeys[key] = nil
    skipKeys[key] = nil
    deferredSquares[#deferredSquares + 1] = { x = x, y = y, z = z }
    ensureTick()
end

local function markSquareDone(key)
    deferredKeys[key] = nil
    pendingKeys[key] = nil
    skipKeys[key] = true
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

-- Рюкзаки, сумки и любые контейнеры на полу не трогаем
local function isProtectedItem(item)
    if not item then return true end
    if item:isFavorite() then return true end
    if instanceof(item, "InventoryContainer") then return true end
    return false
end

local function isTrashItem(item)
    if not item or isProtectedItem(item) then return false end
    local md = item:getModData()
    if not md or not md["Owner"] or not md["TimeUsed"] then
        return false
    end
    return (cachedWorldAgeDays - md["TimeUsed"]) >= cachedMaxAgeGameDays
end

local function squareHasTrashCandidate(wos)
    if not wos or wos:isEmpty() then return false end
    for i = 0, wos:size() - 1 do
        local wo = wos:get(i)
        if wo then
            local item = wo:getItem()
            if item and isTrashItem(item) then
                return true
            end
        end
    end
    return false
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

local function processSquare(cell, entry, removeBudget)
    local key = squareKey(entry.x, entry.y, entry.z)

    if isBlockedByPlayers(entry.x, entry.y, entry.z) then
        deferSquareCoords(entry.x, entry.y, entry.z)
        return 0
    end

    local square = cell:getGridSquare(entry.x, entry.y, entry.z)
    if not square then
        clearDeferred(key)
        markSquareDone(key)
        return 0
    end

    if isSquareInSafehouse(square) then
        markSquareDone(key)
        return 0
    end

    clearDeferred(key)

    local wos = square:getWorldObjects()
    if not wos or wos:isEmpty() then
        markSquareDone(key)
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
        if wo then
            local item = wo:getItem()
            if item and isTrashItem(item) then
                if isSquareInSafehouse(square) then
                    markSquareDone(key)
                    return removed
                end
                removeWorldObject(square, wo)
                removed = removed + 1
            end
        end
    end

    if needRequeue then
        skipKeys[key] = nil
        enqueueSquare(entry.x, entry.y, entry.z)
    else
        markSquareDone(key)
    end

    return removed
end

local function promoteDeferred(limit)
    local promoted = 0
    for i = #deferredSquares, 1, -1 do
        if promoted >= limit then break end
        local e = deferredSquares[i]
        if not isBlockedByPlayers(e.x, e.y, e.z) then
            table.remove(deferredSquares, i)
            clearDeferred(squareKey(e.x, e.y, e.z))
            skipKeys[squareKey(e.x, e.y, e.z)] = nil
            enqueueSquare(e.x, e.y, e.z)
            promoted = promoted + 1
        end
    end
end

local function onLoadGridsquare(square)
    if not isModuleEnabled() or not square then return end

    if isSquareInSafehouse(square) then return end

    local x, y, z = square:getX(), square:getY(), square:getZ()
    local key = squareKey(x, y, z)
    if skipKeys[key] or pendingKeys[key] or deferredKeys[key] then return end

    local me = getPlayer()
    if me and isPlayerNearCoords(x, y, z, me, FloorTrashCleaner.VISIBLE_RADIUS) then
        deferSquareCoords(x, y, z)
        return
    end

    local wos = square:getWorldObjects()
    if not squareHasTrashCandidate(wos) then
        skipKeys[key] = true
        return
    end

    enqueueSquare(x, y, z)
end

onTick = function()
    if not isModuleEnabled() then
        maybeRemoveTick()
        return
    end
    if #pendingQueue == 0 and #deferredSquares == 0 then
        maybeRemoveTick()
        return
    end

    tickCounter = tickCounter + 1
    if tickCounter % FloorTrashCleaner.TICK_INTERVAL ~= 0 then
        return
    end

    processCounter = processCounter + 1
    if processCounter % 15 == 1 or not cachedMe then
        refreshPlayerCache()
        promoteDeferred(8)
    end

    if #pendingQueue == 0 then
        maybeRemoveTick()
        return
    end

    local cell = getCell()
    if not cell then return end

    local squaresLeft = FloorTrashCleaner.MAX_SQUARES_PER_TICK
    local removeBudget = FloorTrashCleaner.MAX_REMOVES_PER_TICK

    while squaresLeft > 0 and #pendingQueue > 0 and removeBudget > 0 do
        local entry = table.remove(pendingQueue, 1)
        pendingKeys[squareKey(entry.x, entry.y, entry.z)] = nil

        local removed = processSquare(cell, entry, removeBudget)
        removeBudget = removeBudget - removed
        squaresLeft = squaresLeft - 1
    end

    maybeRemoveTick()
end

local function retryDeferred()
    if not isModuleEnabled() then return end
    skipKeys = {}
    refreshPlayerCache()
    promoteDeferred(9999)
end

Events.LoadGridsquare.Add(onLoadGridsquare)
Events.EveryTenMinutes.Add(retryDeferred)
