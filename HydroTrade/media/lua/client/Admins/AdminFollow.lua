-- -- Admin follow: ISWalkToTimedAction без god/invis, плавный setX/setY с god/invis/ghost.
-- -- AdminFollow.debug = true для логов

-- AdminFollow = AdminFollow or {}

-- AdminFollow.debug = false
-- AdminFollow.active = false
-- AdminFollow.target = nil
-- AdminFollow.followDist = 2
-- AdminFollow.offsetX = 0
-- AdminFollow.offsetY = 0
-- AdminFollow.tick = 0
-- AdminFollow.updateEvery = 10
-- AdminFollow.lastTargetX = nil
-- AdminFollow.lastTargetY = nil
-- AdminFollow.lastTargetZ = nil
-- AdminFollow.lastMeX = nil
-- AdminFollow.lastMeY = nil

-- local MOVE_KEYS = { "Forward", "Backward", "Left", "Right" }
-- local MIN_FOLLOW_DIST = 2
-- local CHEAT_WALK_SPEED = 0.07
-- local CHEAT_RUN_SPEED = 0.14

-- local function needsCheatMove(me)
--     return me:isGodMod() or me:isInvisible() or me:isGhostMode()
-- end

-- local function isTextInputActive()
--     if ISChat and ISChat.instance and ISChat.instance.textEntry then
--         if ISChat.instance.textEntry.isFocused and ISChat.instance.textEntry:isFocused() then
--             return true
--         end
--     end
--     return false
-- end

-- local function dbg(msg)
--     if not AdminFollow.debug then return end
--     print("[AdminFollow] " .. tostring(msg))
-- end

-- local function findClickedPlayer(me, sq)
--     if not sq then return nil end
--     for x = sq:getX() - 1, sq:getX() + 1 do
--         for y = sq:getY() - 1, sq:getY() + 1 do
--             local sq2 = getCell():getGridSquare(x, y, sq:getZ())
--             if sq2 then
--                 for i = 0, sq2:getMovingObjects():size() - 1 do
--                     local o = sq2:getMovingObjects():get(i)
--                     if instanceof(o, "IsoPlayer") and o ~= me then
--                         return o
--                     end
--                 end
--             end
--         end
--     end
--     return nil
-- end

-- local function getFollowSquare(me, target)
--     local tz = target:getZ()
--     local ix = math.floor(target:getX() + AdminFollow.offsetX + 0.5)
--     local iy = math.floor(target:getY() + AdminFollow.offsetY + 0.5)
--     local cell = getCell()
--     local sq = cell:getGridSquare(ix, iy, tz)
--     local targetSq = target:getCurrentSquare()

--     if sq and targetSq and sq ~= targetSq then
--         return sq
--     end

--     if targetSq and AdjacentFreeTileFinder then
--         local anchor = sq or targetSq
--         local found = AdjacentFreeTileFinder.Find(anchor, me)
--         if found then return found end
--     end

--     if targetSq then
--         local dx = me:getX() - target:getX()
--         local dy = me:getY() - target:getY()
--         local len = math.sqrt(dx * dx + dy * dy)
--         if len < 0.01 then dx, dy, len = 1, 0, 1 end
--         local bx = math.floor(target:getX() + (dx / len) * AdminFollow.followDist + 0.5)
--         local by = math.floor(target:getY() + (dy / len) * AdminFollow.followDist + 0.5)
--         local backSq = cell:getGridSquare(bx, by, tz)
--         if backSq then return backSq end
--     end

--     return sq or targetSq
-- end

-- local function isSquareWalkable(sq)
--     if not sq then return false end
--     if sq:isSolid() then return false end
--     if sq.isSolidTrans and sq:isSolidTrans() then return false end
--     return true
-- end

-- local function getNextStepSquare(me, destSq)
--     if not destSq then return nil end
--     local mySq = me:getCurrentSquare()
--     if not mySq then return nil end

--     if mySq == destSq then return nil end

--     if AdjacentFreeTileFinder and AdjacentFreeTileFinder.isTileOrAdjacent(mySq, destSq) then
--         if isSquareWalkable(destSq) then
--             return destSq
--         end
--     end

--     local cell = getCell()
--     local cx, cy, cz = mySq:getX(), mySq:getY(), mySq:getZ()
--     local dx = destSq:getX() - cx
--     local dy = destSq:getY() - cy

--     local sx = cx + (dx > 0 and 1 or (dx < 0 and -1 or 0))
--     local sy = cy + (dy > 0 and 1 or (dy < 0 and -1 or 0))

--     local candidates = {
--         cell:getGridSquare(sx, sy, cz),
--         cell:getGridSquare(sx, cy, cz),
--         cell:getGridSquare(cx, sy, cz),
--     }

--     for i = 1, #candidates do
--         if isSquareWalkable(candidates[i]) then
--             return candidates[i]
--         end
--     end

--     if AdjacentFreeTileFinder then
--         return AdjacentFreeTileFinder.Find(destSq, me)
--     end

--     return nil
-- end

-- local function hasWalkQueued(me)
--     local aq = ISTimedActionQueue.getTimedActionQueue(me)
--     if not aq or not aq.queue then return false end
--     for i = 1, #aq.queue do
--         local entry = aq.queue[i]
--         if entry and (entry.Type == "ISWalkToTimedAction" or entry.Type == "ISPathFindAction") then
--             return true
--         end
--     end
--     return false
-- end

-- local function tryPathToFloor(me, destSq)
--     if not destSq or me:getZ() == destSq:getZ() then return false end
--     local pf = me:getPathFindBehavior2()
--     if not pf then return false end
--     pf:pathToLocation(destSq:getX(), destSq:getY(), destSq:getZ())
--     dbg(string.format("pathToLocation floor %d -> %d", me:getZ(), destSq:getZ()))
--     return true
-- end

-- local function queueWalkStep(me, destSq)
--     if not destSq then
--         dbg("queueWalkStep: no dest")
--         return false
--     end

--     if hasWalkQueued(me) then
--         return false
--     end

--     if me:getZ() ~= destSq:getZ() then
--         return tryPathToFloor(me, destSq)
--     end

--     local nextSq = getNextStepSquare(me, destSq)
--     if not nextSq then
--         dbg("queueWalkStep: no next square")
--         return false
--     end

--     local mySq = me:getCurrentSquare()
--     if mySq and mySq == nextSq then
--         return false
--     end

--     if luautils and luautils.walkAdj then
--         if luautils.walkAdj(me, nextSq, false) then
--             dbg(string.format("walkAdj step -> (%d,%d,%d) me=(%.1f,%.1f)", nextSq:getX(), nextSq:getY(), nextSq:getZ(), me:getX(), me:getY()))
--             return true
--         end
--     end

--     ISTimedActionQueue.add(ISWalkToTimedAction:new(me, nextSq))
--     dbg(string.format("ISWalkToTimedAction -> (%d,%d,%d) me=(%.1f,%.1f)", nextSq:getX(), nextSq:getY(), nextSq:getZ(), me:getX(), me:getY()))
--     return true
-- end

-- local function cheatMoveToward(me, destSq, running)
--     if not destSq then return false end

--     if me:getZ() ~= destSq:getZ() then
--         local pf = me:getPathFindBehavior2()
--         if pf then
--             pf:pathToLocation(destSq:getX(), destSq:getY(), destSq:getZ())
--         end
--         dbg(string.format("cheat path floor %d -> %d", me:getZ(), destSq:getZ()))
--         return true
--     end

--     local tx = destSq:getX() + 0.5
--     local ty = destSq:getY() + 0.5
--     local cx, cy = me:getX(), me:getY()
--     local dx, dy = tx - cx, ty - cy
--     local dist = math.sqrt(dx * dx + dy * dy)
--     if dist < 0.08 then return false end

--     local speed = running and CHEAT_RUN_SPEED or CHEAT_WALK_SPEED
--     local step = math.min(speed, dist)
--     me:setX(cx + dx / dist * step)
--     me:setY(cy + dy / dist * step)
--     me:setRunning(running)
--     return true
-- end

-- local function moveTowardDest(me, destSq, running)
--     if needsCheatMove(me) then
--         if cheatMoveToward(me, destSq, running) then
--             dbg(string.format("cheat move -> (%d,%d) me=(%.1f,%.1f)", destSq:getX(), destSq:getY(), me:getX(), me:getY()))
--             return true
--         end
--         return false
--     end
--     return queueWalkStep(me, destSq)
-- end

-- local function syncSpeed(me, target, distError)
--     if not target:isPlayerMoving() then
--         me:setRunning(false)
--         return
--     end

--     if target:isSprinting() or target:IsRunning() then
--         me:setRunning(true)
--     else
--         me:setRunning(false)
--     end

--     if distError > AdminFollow.followDist + 3 then
--         me:setRunning(true)
--     end
-- end

-- local function shouldStep(me, target)
--     if target:getZ() ~= me:getZ() then
--         return true
--     end

--     local dist = IsoUtils.DistanceTo(me:getX(), me:getY(), target:getX(), target:getY())
--     if math.abs(dist - AdminFollow.followDist) > 1.5 then
--         return true
--     end

--     local destSq = getFollowSquare(me, target)
--     if destSq then
--         local dx = me:getX() - (destSq:getX() + 0.5)
--         local dy = me:getY() - (destSq:getY() + 0.5)
--         if (dx * dx + dy * dy) > 0.6 then
--             return true
--         end
--     end

--     if target:isPlayerMoving() then
--         local moved = IsoUtils.DistanceTo(
--             target:getX(), target:getY(),
--             AdminFollow.lastTargetX or target:getX(),
--             AdminFollow.lastTargetY or target:getY()
--         )
--         if moved > 1.0 then
--             return true
--         end
--     end

--     return false
-- end

-- local function onKeyKeepPressed(key)
--     if not AdminFollow.active then return end
--     if not isAdmin() then return end
--     if isTextInputActive() then return end

--     for i = 1, #MOVE_KEYS do
--         if key == getCore():getKey(MOVE_KEYS[i]) then
--             AdminFollow.stop(getSpecificPlayer(0), "WASD")
--             return
--         end
--     end
-- end

-- local function onPlayerUpdate(player)
--     if not AdminFollow.active then return end
--     if player ~= getSpecificPlayer(0) then return end
--     if not isAdmin() then
--         AdminFollow.stop(player, "not admin")
--         return
--     end

--     local me = player
--     local target = AdminFollow.target
--     if not target or target:isDead() or target:isAsleep() then
--         AdminFollow.stop(me, "target invalid")
--         return
--     end

--     if target:getVehicle() or me:getVehicle() then
--         AdminFollow.stop(me, "vehicle")
--         return
--     end

--     local mx, my = me:getX(), me:getY()
--     if AdminFollow.lastMeX and AdminFollow.lastMeY then
--         local movedMe = IsoUtils.DistanceTo(mx, my, AdminFollow.lastMeX, AdminFollow.lastMeY)
--         if movedMe > 0.1 and AdminFollow.debug then
--             dbg(string.format("moved %.2f -> (%.1f,%.1f)", movedMe, mx, my))
--         end
--     end
--     AdminFollow.lastMeX = mx
--     AdminFollow.lastMeY = my

--     local cheat = needsCheatMove(me)

--     if not cheat then
--         local actionQueue = ISTimedActionQueue.getTimedActionQueue(me)
--         if actionQueue and actionQueue.queue and actionQueue.queue[1] then
--             local entry = actionQueue.queue[1]
--             if entry and entry.Type ~= "ISWalkToTimedAction" and entry.Type ~= "ISPathFindAction" then
--                 return
--             end
--         end
--     end

--     AdminFollow.tick = AdminFollow.tick + 1
--     local interval = cheat and 2 or AdminFollow.updateEvery
--     if AdminFollow.tick % interval ~= 0 then
--         return
--     end

--     local dist = IsoUtils.DistanceTo(me:getX(), me:getY(), target:getX(), target:getY())
--     local distError = math.abs(dist - AdminFollow.followDist)
--     syncSpeed(me, target, distError)

--     if shouldStep(me, target) then
--         local destSq = getFollowSquare(me, target)
--         local running = me:IsRunning()
--         if moveTowardDest(me, destSq, running) then
--             AdminFollow.lastTargetX = target:getX()
--             AdminFollow.lastTargetY = target:getY()
--             AdminFollow.lastTargetZ = target:getZ()
--         end
--     end
-- end

-- function AdminFollow.stop(me, reason)
--     if AdminFollow.active then
--         dbg("stop: " .. tostring(reason or "manual"))
--     end
--     AdminFollow.active = false
--     AdminFollow.target = nil
--     AdminFollow.tick = 0
--     AdminFollow.lastTargetX = nil
--     AdminFollow.lastTargetY = nil
--     AdminFollow.lastTargetZ = nil
--     AdminFollow.lastMeX = nil
--     AdminFollow.lastMeY = nil

--     Events.OnPlayerUpdate.Remove(onPlayerUpdate)
--     Events.OnKeyKeepPressed.Remove(onKeyKeepPressed)

--     if me then
--         me:setRunning(false)
--         local pf = me:getPathFindBehavior2()
--         if pf and pf.cancel then pf:cancel() end
--     end
-- end

-- function AdminFollow.start(me, target)
--     if not isAdmin() then dbg("start blocked: not admin"); return end
--     if not me or not target or me == target then return end
--     if target:isDead() or target:isAsleep() then return end

--     local dx = me:getX() - target:getX()
--     local dy = me:getY() - target:getY()
--     local dist = math.sqrt(dx * dx + dy * dy)
--     if dist < MIN_FOLLOW_DIST then dist = MIN_FOLLOW_DIST end

--     AdminFollow.active = true
--     AdminFollow.target = target
--     AdminFollow.followDist = dist
--     AdminFollow.offsetX = dx / dist * dist
--     AdminFollow.offsetY = dy / dist * dist
--     AdminFollow.tick = 0
--     AdminFollow.lastTargetX = target:getX()
--     AdminFollow.lastTargetY = target:getY()
--     AdminFollow.lastTargetZ = target:getZ()
--     AdminFollow.lastMeX = nil
--     AdminFollow.lastMeY = nil

--     ISTimedActionQueue.clear(me)

--     local destSq = getFollowSquare(me, target)
--     local mode = needsCheatMove(me) and "cheat" or "walk"
--     dbg(string.format("Follow %s dist=%.1f mode=%s", target:getUsername() or "?", dist, mode))

--     Events.OnPlayerUpdate.Remove(onPlayerUpdate)
--     Events.OnPlayerUpdate.Add(onPlayerUpdate)
--     Events.OnKeyKeepPressed.Remove(onKeyKeepPressed)
--     Events.OnKeyKeepPressed.Add(onKeyKeepPressed)

--     moveTowardDest(me, destSq, false)
-- end

-- function AdminFollow.toggle(me, target)
--     if AdminFollow.active and AdminFollow.target == target then
--         AdminFollow.stop(me)
--     else
--         if AdminFollow.active then
--             AdminFollow.stop(me)
--         end
--         AdminFollow.start(me, target)
--     end
-- end

-- local function onFillContextMenu(playerNum, context, worldobjects)
--     if not isAdmin() then return end

--     local me = getSpecificPlayer(playerNum)
--     if not me then return end

--     local sq = nil
--     for _, v in ipairs(worldobjects) do
--         sq = v:getSquare()
--         if sq then break end
--     end
--     if not sq then return end

--     local clickedPlayer = findClickedPlayer(me, sq)
--     if not clickedPlayer then return end

--     local name = clickedPlayer:getUsername() or "?"
--     local label = (AdminFollow.active and AdminFollow.target == clickedPlayer) and ("Stop follow: " .. name) or ("Follow: " .. name)

--     context:addOption(label, nil, function()
--         local player = getSpecificPlayer(playerNum)
--         if player then
--             AdminFollow.toggle(player, clickedPlayer)
--         end
--     end)
-- end

-- Events.OnFillWorldObjectContextMenu.Add(onFillContextMenu)
