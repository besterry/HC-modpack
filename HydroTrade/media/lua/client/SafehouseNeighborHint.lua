-- Подсказка и подсветка границы чужого убежища при подходе (без карты)

SafehouseNeighborHint = SafehouseNeighborHint or {}

local PROXIMITY = 3
local BORDER_SEGMENT = 3
local HALO_MS = 1200
local HALO_R, HALO_G, HALO_B = 255, 180, 80
local TICK_INTERVAL = 3

local BORDER_COLOR = ColorInfo.new(1.0, 0.45, 0.1, 1.0)

local lastHighlighted = {}
local tickCounter = 0
local haloActive = false
local haloSafehouseKey = nil

local function getSafehouseKey(sh)
    return tostring(sh:getX()) .. "," .. tostring(sh:getY()) .. "," .. tostring(sh:getW()) .. "," .. tostring(sh:getH())
end

local function clearHighlights()
    for i = 1, #lastHighlighted do
        local obj = lastHighlighted[i]
        if obj then
            obj:setHighlighted(false)
        end
    end
    lastHighlighted = {}
end

local function chebyshevDistToRect(px, py, x1, y1, x2, y2)
    local dx = 0
    if px < x1 then
        dx = x1 - px
    elseif px > x2 then
        dx = px - x2
    end
    local dy = 0
    if py < y1 then
        dy = y1 - py
    elseif py > y2 then
        dy = py - y2
    end
    return math.max(dx, dy)
end

local function getSafehouseTitle(sh)
    local title = sh:getTitle()
    if title and title ~= "" then
        return title
    end
    return getText("IGUI_SafehouseNeighbor_Untitled")
end

local function highlightTile(cell, x, y)
    local sq = cell:getGridSquare(x, y, 0)
    if not sq then return end
    local obj = sq:getFloor()
    if not obj then return end
    obj:setHighlighted(true)
    obj:setHighlightColor(BORDER_COLOR)
    lastHighlighted[#lastHighlighted + 1] = obj
end

local function getClosestBorderPoint(px, py, x1, y1, x2, y2)
    local bx = px
    if px < x1 then
        bx = x1
    elseif px > x2 then
        bx = x2
    end
    local by = py
    if py < y1 then
        by = y1
    elseif py > y2 then
        by = y2
    end
    return bx, by
end

local function highlightBorderNearPlayer(sh, px, py, cell)
    local x1 = sh:getX()
    local y1 = sh:getY()
    local x2 = x1 + sh:getW() - 1
    local y2 = y1 + sh:getH() - 1
    local bx, by = getClosestBorderPoint(px, py, x1, y1, x2, y2)
    local half = math.floor(BORDER_SEGMENT / 2)

    if by == y1 or by == y2 then
        local y = by
        for x = bx - half, bx + half do
            if x >= x1 and x <= x2 then
                highlightTile(cell, x, y)
            end
        end
    end

    if bx == x1 or bx == x2 then
        local x = bx
        for y = by - half, by + half do
            if y >= y1 and y <= y2 then
                highlightTile(cell, x, y)
            end
        end
    end
end

local function isSafehouseResident(player, sh)
    if not player or not sh then return false end
    local username = player:getUsername()
    if not username then return false end
    if sh:getOwner() == username then return true end
    local members = sh:getPlayers()
    if members then
        for i = 0, members:size() - 1 do
            if members:get(i) == username then return true end
        end
    end
    if HydroSafehouseGuests and HydroSafehouseGuests.isGuest then
        return HydroSafehouseGuests.isGuest(username, sh)
    end
    return false
end

local function findNearestForeignSafehouse(player)
    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    local list = SafeHouse.getSafehouseList()
    if not list then return nil end

    local best = nil
    local bestDist = PROXIMITY + 1

    for i = 0, list:size() - 1 do
        local sh = list:get(i)
        if sh and not isSafehouseResident(player, sh) then
            local x1 = sh:getX()
            local y1 = sh:getY()
            local x2 = x1 + sh:getW() - 1
            local y2 = y1 + sh:getH() - 1
            local dist = chebyshevDistToRect(px, py, x1, y1, x2, y2)
            if dist <= PROXIMITY and dist < bestDist then
                bestDist = dist
                best = sh
            end
        end
    end

    return best
end

local function clearHalo(player)
    if not haloActive then return end
    player:setHaloNote("", 255, 255, 255, 1)
    haloActive = false
    haloSafehouseKey = nil
end

local function showHaloOnce(player, sh)
    local key = getSafehouseKey(sh)
    if haloActive and haloSafehouseKey == key then return end
    local text = getText("IGUI_SafehouseNeighbor_Halo", getSafehouseTitle(sh))
    player:setHaloNote(text, HALO_R, HALO_G, HALO_B, HALO_MS)
    haloActive = true
    haloSafehouseKey = key
end

local function update(player)
    if not player or not player:isLocalPlayer() then return end
    if isAdmin() then
        return
    end

    clearHighlights()

    local sh = findNearestForeignSafehouse(player)
    if not sh then
        clearHalo(player)
        return
    end

    local px = math.floor(player:getX())
    local py = math.floor(player:getY())
    highlightBorderNearPlayer(sh, px, py, getCell())
    showHaloOnce(player, sh)
end

local function onRenderTick()
    tickCounter = tickCounter + 1
    if tickCounter % TICK_INTERVAL ~= 0 then return end
    local player = getPlayer()
    if player then
        update(player)
    end
end

Events.OnRenderTick.Add(onRenderTick)
