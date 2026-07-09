-- Очистка мусора на полу вне убежищ (клиент MP).
-- LoadGridsquare: только постановка клетки в очередь (без перебора предметов).
-- OnTick: обработка по бюджету. В транспорте очередь не растёт и не чистится.
-- Sandbox: FloorTrashCleaner.Enabled, MaxAgeGameDays, ContainerAgeMultiplier

if not isClient() then return end

FloorTrashCleaner = FloorTrashCleaner or {}

FloorTrashCleaner.VISIBLE_RADIUS = 35
FloorTrashCleaner.OTHER_PLAYER_RADIUS = 35

FloorTrashCleaner.SQUARES_PER_TICK = 3
FloorTrashCleaner.MAX_REMOVES_PER_TICK = 8
FloorTrashCleaner.MAX_REMOVES_PER_SQUARE = 40
FloorTrashCleaner.TICK_INTERVAL = 4
FloorTrashCleaner.MAX_QUEUE = 512
FloorTrashCleaner.RESCAN_RADIUS = 40

-- OnExitVehicle: догоняет клетки, пропущенные при проезде на транспорте.

-- true: не ставить в очередь и не чистить, пока игрок в машине/транспорте
FloorTrashCleaner.SKIP_WHILE_IN_VEHICLE = true

FloorTrashCleaner.DEBUG = true
FloorTrashCleaner.DEBUG_LOG_LIMIT = 80

local pendingQueue = {}
local pendingKeys = {}

local cachedWorldAgeDays = 0
local cachedWorldAgeHours = 0
local cachedMaxAgeGameDays = 24
local cachedContainerAgeMultiplier = 10
local cachedMe = nil
local cachedOtherPlayers = nil

local tickCounter = 0
local debugLogBudget = 0

local function debugLog(msg, bypassBudget)
    if not FloorTrashCleaner.DEBUG then return end
    if not bypassBudget and debugLogBudget <= 0 then return end
    if not bypassBudget then
        debugLogBudget = debugLogBudget - 1
    end
    print("[FloorTrashCleaner] " .. msg)
end

local function resetDebugBudget()
    if FloorTrashCleaner.DEBUG then
        debugLogBudget = FloorTrashCleaner.DEBUG_LOG_LIMIT
    end
end

local function isModuleEnabled()
    return SandboxVars.FloorTrashCleaner and SandboxVars.FloorTrashCleaner.Enabled
end

local function getContainerAgeMultiplier()
    if SandboxVars.FloorTrashCleaner then
        return SandboxVars.FloorTrashCleaner.ContainerAgeMultiplier or 10
    end
    return 10
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

local function isPlayerInVehicle()
    if not FloorTrashCleaner.SKIP_WHILE_IN_VEHICLE then return false end
    local me = cachedMe or getPlayer()
    if not me then return false end
    return me:getVehicle() ~= nil
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
    cachedWorldAgeHours = getGameTime():getWorldAgeHours()
    cachedMaxAgeGameDays = getMaxAgeGameDays()
    cachedContainerAgeMultiplier = getContainerAgeMultiplier()
end

local function isPlayerNearCoords(x, y, z, player, radius)
    if not player then return false end
    return chebyshevDist(x, y, z, player:getX(), player:getY(), player:getZ()) <= radius
end

local function getSquareSkipReason(x, y, z)
    if isPlayerNearCoords(x, y, z, cachedMe, FloorTrashCleaner.VISIBLE_RADIUS) then
        return string.format("player_near(self<=%d)", FloorTrashCleaner.VISIBLE_RADIUS)
    end
    for i = 1, #cachedOtherPlayers do
        if isPlayerNearCoords(x, y, z, cachedOtherPlayers[i], FloorTrashCleaner.OTHER_PLAYER_RADIUS) then
            return string.format("player_near(other<=%d)", FloorTrashCleaner.OTHER_PLAYER_RADIUS)
        end
    end
    return nil
end

local function enqueueSquare(x, y, z)
    local key = squareKey(x, y, z)
    if pendingKeys[key] then return end
    if #pendingQueue >= FloorTrashCleaner.MAX_QUEUE then return end
    pendingKeys[key] = true
    pendingQueue[#pendingQueue + 1] = { x = x, y = y, z = z }
end

local function getWorldObjectDropTime(wo)
    if not wo then return nil end
    local dropTime = wo.dropTime
    if (dropTime == nil or dropTime <= 0) and wo.getDropTime then
        dropTime = wo:getDropTime()
    end
    if dropTime and dropTime > 0 then
        return dropTime
    end
    return nil
end

local function getItemAgeDays(item, wo)
    local md = item:getModData()
    if md and md["TimeUsed"] then
        return cachedWorldAgeDays - md["TimeUsed"], "moddata"
    end
    local dropTime = getWorldObjectDropTime(wo)
    if dropTime then
        local hours = cachedWorldAgeHours - dropTime
        if hours < 0 then hours = 0 end
        return hours / 24, "dropTime"
    end
    return nil, nil
end

local function getContainerMaxAgeGameDays()
    return cachedMaxAgeGameDays * cachedContainerAgeMultiplier
end

local function getItemSkipReason(item, wo)
    if not item then return "no_item" end
    if item:isFavorite() then return "favorite" end

    local ageDays, ageSource = getItemAgeDays(item, wo)
    if not ageDays then
        return "no_age"
    end

    if instanceof(item, "InventoryContainer") then
        local maxAge = getContainerMaxAgeGameDays()
        if ageDays < maxAge then
            return string.format("container_too_young(%.2f/%.0f, %s)", ageDays, maxAge, ageSource or "?")
        end
        return nil
    end

    if ageDays < cachedMaxAgeGameDays then
        return string.format("too_young(%.2f/%.0f, %s)", ageDays, cachedMaxAgeGameDays, ageSource or "?")
    end
    return nil
end

local function logItemAt(x, y, z, item, wo, action, extra)
    if not item then return end
    local md = item:getModData() or {}
    local owner = md["Owner"] or "-"
    local ageDays, ageSource = getItemAgeDays(item, wo)
    debugLog(string.format(
        "%s %s @%d,%d,%d owner=%s age=%.2f(%s)%s",
        action,
        item:getFullType(),
        x, y, z,
        owner,
        ageDays or -1,
        ageSource or "?",
        extra or ""
    ))
end

local function removeWorldObject(square, wo)
    local item = wo:getItem()
    if item and instanceof(item, "InventoryContainer") then
        local inv = item:getInventory()
        if inv and not inv:isEmpty() then
            inv:removeAllItems()
        end
    end
    square:transmitRemoveItemFromSquare(wo)
    wo:removeFromWorld()
    wo:removeFromSquare()
    wo:setSquare(nil)
    if item then
        item:setWorldItem(nil)
    end
end

local function processFloorSquare(square, tag, removeBudget)
    if not square then return 0 end

    if isSquareInSafehouse(square) then
        return 0
    end

    local x, y, z = square:getX(), square:getY(), square:getZ()
    local squareReason = getSquareSkipReason(x, y, z)
    if squareReason then
        if FloorTrashCleaner.DEBUG then
            debugLog(string.format("SKIP square @%d,%d,%d reason=%s", x, y, z, squareReason))
        end
        return 0
    end

    local wos = square:getWorldObjects()
    if not wos or wos:isEmpty() then return 0 end

    local removed = 0
    local needRequeue = false

    for i = wos:size() - 1, 0, -1 do
        if removed >= FloorTrashCleaner.MAX_REMOVES_PER_SQUARE then
            needRequeue = true
            break
        end
        if removed >= removeBudget then
            needRequeue = true
            break
        end
        local wo = wos:get(i)
        if wo then
            local item = wo:getItem()
            if item then
                local reason = getItemSkipReason(item, wo)
                if reason then
                    if FloorTrashCleaner.DEBUG then
                        logItemAt(x, y, z, item, wo, "SKIP", " reason=" .. reason)
                    end
                else
                    if FloorTrashCleaner.DEBUG then
                        local extra = instanceof(item, "InventoryContainer") and " (container)" or ""
                        logItemAt(x, y, z, item, wo, "REMOVE", extra)
                    end
                    removeWorldObject(square, wo)
                    removed = removed + 1
                end
            end
        end
    end

    if needRequeue then
        enqueueSquare(x, y, z)
    end

    if FloorTrashCleaner.DEBUG and removed > 0 then
        debugLog(string.format("DONE %s @%d,%d,%d removed=%d", tag or "tick", x, y, z, removed), true)
    end

    return removed
end

local function drainQueue(maxSquares, maxRemoves)
    if #pendingQueue == 0 then return 0 end

    local cell = getCell()
    if not cell then return 0 end

    local totalRemoved = 0
    local squaresLeft = maxSquares
    local removesLeft = maxRemoves

    while squaresLeft > 0 and removesLeft > 0 and #pendingQueue > 0 do
        local entry = table.remove(pendingQueue, 1)
        pendingKeys[squareKey(entry.x, entry.y, entry.z)] = nil

        local square = cell:getGridSquare(entry.x, entry.y, entry.z)
        if square then
            local n = processFloorSquare(square, "tick", removesLeft)
            removesLeft = removesLeft - n
            totalRemoved = totalRemoved + n
        end
        squaresLeft = squaresLeft - 1
    end

    return totalRemoved
end

local function scheduleRescanAroundPlayer(radius)
    local me = cachedMe
    if not me then return end

    local cell = getCell()
    if not cell then return end

    local px, py, pz = me:getX(), me:getY(), me:getZ()

    for dx = -radius, radius do
        for dy = -radius, radius do
            local square = cell:getGridSquare(px + dx, py + dy, pz)
            if square and not isSquareInSafehouse(square) then
                enqueueSquare(square:getX(), square:getY(), square:getZ())
            end
        end
    end
end

local function onLoadGridsquare(square)
    if not isModuleEnabled() or not square then return end
    if isSquareInSafehouse(square) then return end

    if not cachedMe then
        refreshPlayerCache()
    end

    if isPlayerInVehicle() then
        return
    end

    enqueueSquare(square:getX(), square:getY(), square:getZ())
end

local function onTick()
    if not isModuleEnabled() then return end
    if #pendingQueue == 0 then return end

    tickCounter = tickCounter + 1
    if tickCounter % FloorTrashCleaner.TICK_INTERVAL ~= 0 then
        return
    end

    if not cachedMe then
        refreshPlayerCache()
    end

    if isPlayerInVehicle() then
        return
    end

    if tickCounter % 60 == 0 then
        refreshPlayerCache()
    end

    drainQueue(FloorTrashCleaner.SQUARES_PER_TICK, FloorTrashCleaner.MAX_REMOVES_PER_TICK)
end

local function onGameStart()
    refreshPlayerCache()
    if FloorTrashCleaner.DEBUG then
        debugLog(string.format(
            "START enabled=%s maxAge=%d containerMaxAge=%d skipInVehicle=%s",
            tostring(isModuleEnabled()),
            getMaxAgeGameDays(),
            getMaxAgeGameDays() * getContainerAgeMultiplier(),
            tostring(FloorTrashCleaner.SKIP_WHILE_IN_VEHICLE)
        ), true)
    end
end

FloorTrashCleaner.RunDebugScan = function()
    if not isModuleEnabled() then return end
    refreshPlayerCache()
    resetDebugBudget()
    scheduleRescanAroundPlayer(45)
    debugLog("SCAN queued=" .. #pendingQueue, true)
end

local function onExitVehicle(player)
    if not isModuleEnabled() then return end
    if not player or player ~= getPlayer() then return end
    refreshPlayerCache()
    scheduleRescanAroundPlayer(FloorTrashCleaner.RESCAN_RADIUS)
end

Events.LoadGridsquare.Add(onLoadGridsquare)
Events.OnTick.Add(onTick)
Events.OnGameStart.Add(onGameStart)
Events.OnExitVehicle.Add(onExitVehicle)
