ShopProximity = ShopProximity or {}

ShopProximity.INTERACT_RADIUS = 2.0
ShopProximity.HINT_RADIUS = 1.35
ShopProximity.HINT_SHOW_MS = 600
ShopProximity.SCAN_INTERVAL_MS = 500
ShopProximity.HINT_REFRESH_MS = 500
ShopProximity.OPEN_COOLDOWN_MS = 600
ShopProximity.FACING_CONE_DEG = 70

local HIGHLIGHT_R = 0.48
local HIGHLIGHT_G = 0.9
local HIGHLIGHT_B = 0.48
local HIGHLIGHT_A = 0.62

local function isShopObject(worldobject, spritePrefix)
	if not worldobject or not spritePrefix then return false end
	local sprite = worldobject:getSprite()
	if not sprite then return false end
	local spriteName = sprite:getName()
	return spriteName ~= nil and string.find(spriteName, spritePrefix) ~= nil
end

local function getAngleOffset2D(angle1, angle2)
	return 180 - math.abs(math.abs(angle1 - angle2) - 180)
end

local function getPlayerFacingAngleDeg(player)
	local angle = math.deg(player:getForwardDirection():getDirection() + math.pi / 2)
	if angle < 0 then
		angle = math.abs(360 + angle)
	end
	return angle
end

local function getAngleToWorldDeg(px, py, wx, wy)
	local angle = math.atan2(px - wx, -(py - wy))
	if angle < 0 then
		angle = math.abs(angle)
	else
		angle = 2 * math.pi - angle
	end
	return math.deg(angle)
end

function ShopProximity.getShopWorldPos(shop)
	local sq = shop:getSquare()
	if not sq then return nil end
	return sq:getX() + 0.5, sq:getY() + 0.5
end

function ShopProximity.getShopAngleOffset(player, shop)
	local wx, wy = ShopProximity.getShopWorldPos(shop)
	if not wx then return 360 end
	local facing = getPlayerFacingAngleDeg(player)
	local toShop = getAngleToWorldDeg(player:getX(), player:getY(), wx, wy)
	toShop = math.abs(toShop - 360)
	return getAngleOffset2D(facing, toShop)
end

function ShopProximity.isShopInFacingCone(player, shop, maxAngle)
	local offset = ShopProximity.getShopAngleOffset(player, shop)
	return offset <= (maxAngle or ShopProximity.FACING_CONE_DEG)
end

local function matchesObject(worldobject, filter, spriteName)
	if not worldobject or not filter then return false end
	if type(filter) == "function" then
		return filter(worldobject)
	end
	if type(filter) == "string" then
		if spriteName == nil then
			local sprite = worldobject:getSprite()
			spriteName = sprite and sprite:getName() or nil
		end
		return spriteName ~= nil and string.find(spriteName, filter) ~= nil
	end
	return false
end

local function getObjectFilter(opts)
	if not opts then return nil end
	return opts.isObject or opts.spritePrefix
end

function ShopProximity.canScanPlayer(player)
	if not isClient() then return false end
	if not player or not player:isLocalPlayer() then return false end
	if player:isDead() or player:getVehicle() then return false end
	if ISContextMenu and ISContextMenu.instance and ISContextMenu.instance.visibleCheck then return false end
	if ISUIHandler and ISUIHandler.allUIVisible and not ISUIHandler.allUIVisible then return false end
	return true
end

function ShopProximity.findAllNearby(player, filter, maxRadius)
	local result = {}
	if not player or not filter then return result end
	local cell = player:getCell()
	if not cell then return result end

	maxRadius = maxRadius or ShopProximity.INTERACT_RADIUS
	local px = player:getX()
	local py = player:getY()
	local pz = player:getZ()
	local radius = math.ceil(maxRadius)
	local maxDistSq = maxRadius * maxRadius

	for dx = -radius, radius do
		for dy = -radius, radius do
			local sq = cell:getGridSquare(math.floor(px) + dx, math.floor(py) + dy, pz)
			if sq then
				local sx = sq:getX() + 0.5
				local sy = sq:getY() + 0.5
				local ddx = px - sx
				local ddy = py - sy
				if ddx * ddx + ddy * ddy <= maxDistSq then
					local objects = sq:getObjects()
					for i = 0, objects:size() - 1 do
						local wo = objects:get(i)
						if matchesObject(wo, filter) then
							table.insert(result, wo)
						end
					end
				end
			end
		end
	end
	return result
end

function ShopProximity.pickBestShop(player, shops)
	if not shops or #shops == 0 then return nil end
	if #shops == 1 then return shops[1] end

	local inCone = {}
	for i = 1, #shops do
		if ShopProximity.isShopInFacingCone(player, shops[i]) then
			table.insert(inCone, shops[i])
		end
	end

	local pool = #inCone > 0 and inCone or shops
	local best = pool[1]
	local bestAngle = ShopProximity.getShopAngleOffset(player, best)
	local bestDistSq = ShopProximity.getShopDistanceSq(player, best)

	for i = 2, #pool do
		local shop = pool[i]
		local angle = ShopProximity.getShopAngleOffset(player, shop)
		local distSq = ShopProximity.getShopDistanceSq(player, shop)
		if #inCone > 0 then
			if angle < bestAngle or (angle == bestAngle and distSq < bestDistSq) then
				best = shop
				bestAngle = angle
				bestDistSq = distSq
			end
		elseif distSq < bestDistSq then
			best = shop
			bestAngle = angle
			bestDistSq = distSq
		end
	end
	return best
end

function ShopProximity.findNearby(player, filter, maxRadius)
	local shops = ShopProximity.findAllNearby(player, filter, maxRadius)
	return ShopProximity.pickBestShop(player, shops)
end

function ShopProximity.getShopDistanceSq(player, shop)
	local wx, wy = ShopProximity.getShopWorldPos(shop)
	if not wx then return nil end
	local ddx = player:getX() - wx
	local ddy = player:getY() - wy
	return ddx * ddx + ddy * ddy
end

function ShopProximity.clearShopHighlight()
	local wo = ShopProximity._highlightedShop
	if wo then
		wo:setHighlighted(false)
		ShopProximity._highlightedShop = nil
	end
end

function ShopProximity.setShopHighlight(shop)
	if ShopProximity._highlightedShop ~= shop then
		ShopProximity.clearShopHighlight()
		ShopProximity._highlightedShop = shop
	end
	if not shop then return end

	shop:setHighlighted(true)
	shop:setHighlightColor(HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A)
end

function ShopProximity.newState()
	return {
		hintActive = false,
		hintLastAt = 0,
		openLastAt = 0,
	}
end

function ShopProximity.clearHint(player, state)
	if not player or not state or not state.hintActive then return end
	player:setHaloNote("", 255, 255, 255, 1)
	state.hintActive = false
	state.hintLastAt = 0
end

function ShopProximity.isPriorityNoteActive()
	return getTimestampMs() < (ShopProximity._priorityNoteUntil or 0)
end

function ShopProximity.showPriorityNote(player, text, r, g, b, durationMs)
	if not player or not text then return end
	durationMs = durationMs or 2500
	r = r or 255
	g = g or 100
	b = b or 100
	local now = getTimestampMs()
	if ShopProximity._priorityNoteText == text and now < (ShopProximity._priorityNoteUntil or 0) then
		return
	end
	ShopProximity._priorityNoteUntil = now + durationMs
	ShopProximity._priorityNoteText = text
	ShopProximity._priorityNoteColor = { r, g, b }
	player:setHaloNote(text, r, g, b, durationMs)
end

function ShopProximity.clearPriorityNote(player)
	ShopProximity._priorityNoteUntil = 0
	ShopProximity._priorityNoteText = nil
	ShopProximity._priorityNoteColor = nil
	if player then
		player:setHaloNote("", 255, 255, 255, 1)
	end
end

function ShopProximity.clearAllActive(player)
	for _, handler in ipairs(ShopProximity._handlers) do
		ShopProximity.clearHint(player, handler.state)
	end
	ShopProximity.clearShopHighlight()
	ShopProximity._cachedBestHandler = nil
	ShopProximity._cachedBestShop = nil
end

function ShopProximity.defaultCanUse(player, uiInstance)
	if not ShopProximity.canScanPlayer(player) then return false end
	if uiInstance and uiInstance:getIsVisible() then return false end
	return true
end

function ShopProximity.applyHaloHint(player, state, opts, shop)
	if not player or not state or not opts or not shop then return end
	local text, r, g, b, ms
	if opts.getHaloNote then
		text, r, g, b, ms = opts.getHaloNote(player, shop)
	else
		text = opts.getHintText(player, shop)
		r, g, b, ms = 255, 220, 120, ShopProximity.HINT_SHOW_MS
	end
	player:setHaloNote(text, r, g, b, ms)
	state.hintActive = true
end

function ShopProximity.updateHint(player, state, opts)
	if not player or not player:isLocalPlayer() or not state or not opts then return end

	local filter = getObjectFilter(opts)
	if not filter then return end

	local shops = ShopProximity.findAllNearby(player, filter, opts.hintRadius or ShopProximity.HINT_RADIUS)
	local shop = ShopProximity.pickBestShop(player, shops)
	local canShow = opts.canUse(player) and shop ~= nil
	if opts.canShowHint and not opts.canShowHint(player, shop) then
		canShow = false
	end

	if not canShow then
		ShopProximity.clearHint(player, state)
		return
	end

	local now = getTimestampMs()
	if now - state.hintLastAt < ShopProximity.HINT_REFRESH_MS then return end
	state.hintLastAt = now

	ShopProximity.applyHaloHint(player, state, opts, shop)
end

function ShopProximity.tryOpen(player, state, opts)
	if not player or not state or not opts then return end
	if not opts.canUse(player) then return end

	local filter = getObjectFilter(opts)
	if not filter then return end

	local shops = ShopProximity.findAllNearby(player, filter, opts.interactRadius or ShopProximity.INTERACT_RADIUS)
	local shop = ShopProximity.pickBestShop(player, shops)
	if not shop then return end
	if opts.canOpen and not opts.canOpen(player, shop) then return end

	local now = getTimestampMs()
	if now - state.openLastAt < ShopProximity.OPEN_COOLDOWN_MS then return end
	state.openLastAt = now
	opts.open(player, shop)
end

function ShopProximity.onInteractKey(key, state, opts)
	if key ~= getCore():getKey("Interact") then return end
	local player = getPlayer()
	if not player then return end
	ShopProximity.tryOpen(player, state, opts)
end

function ShopProximity.addShopIcon(option)
	if option and Currency and Currency.CoinsTexture and Currency.CoinsTexture.Coin then
		option.iconTexture = Currency.CoinsTexture.Coin.texture
	end
end

ShopProximity._handlers = ShopProximity._handlers or {}

function ShopProximity.register(handler)
	if not handler or not handler.state or not handler.opts then return end
	table.insert(ShopProximity._handlers, handler)
end

local function collectCandidates(player, baseRadius)
	local candidates = {}
	if not player or not ShopProximity.canScanPlayer(player) then return candidates end

	local cell = player:getCell()
	if not cell then return candidates end

	local px = player:getX()
	local py = player:getY()
	local pz = player:getZ()
	local base = baseRadius or ShopProximity.INTERACT_RADIUS

	local activeHandlers = {}
	local scanRadius = base
	for _, handler in ipairs(ShopProximity._handlers) do
		local opts = handler.opts
		if opts.canUse(player) then
			local filter = getObjectFilter(opts)
			if filter then
				local handlerRadius = opts.hintRadius or opts.interactRadius or base
				if handlerRadius > scanRadius then
					scanRadius = handlerRadius
				end
				activeHandlers[#activeHandlers + 1] = {
					handler = handler,
					filter = filter,
					radiusSq = handlerRadius * handlerRadius,
					opts = opts,
				}
			end
		end
	end
	if #activeHandlers == 0 then return candidates end

	local radius = math.ceil(scanRadius)
	local maxDistSq = scanRadius * scanRadius

	for dx = -radius, radius do
		for dy = -radius, radius do
			local sq = cell:getGridSquare(math.floor(px) + dx, math.floor(py) + dy, pz)
			if sq then
				local sx = sq:getX() + 0.5
				local sy = sq:getY() + 0.5
				local ddx = px - sx
				local ddy = py - sy
				local distSq = ddx * ddx + ddy * ddy
				if distSq <= maxDistSq then
					local objects = sq:getObjects()
					for i = 0, objects:size() - 1 do
						local wo = objects:get(i)
						local sprite = wo:getSprite()
						local spriteName = sprite and sprite:getName() or nil
						for h = 1, #activeHandlers do
							local entry = activeHandlers[h]
							if distSq <= entry.radiusSq and matchesObject(wo, entry.filter, spriteName) then
								if not entry.opts.canOpen or entry.opts.canOpen(player, wo) then
									candidates[#candidates + 1] = { handler = entry.handler, shop = wo }
								end
							end
						end
					end
				end
			end
		end
	end
	return candidates
end

local function pickBestCandidate(player, candidates)
	if #candidates == 0 then return nil, nil end
	if #candidates == 1 then return candidates[1].handler, candidates[1].shop end

	local inCone = {}
	for i = 1, #candidates do
		if ShopProximity.isShopInFacingCone(player, candidates[i].shop) then
			inCone[#inCone + 1] = candidates[i]
		end
	end

	local pool = #inCone > 0 and inCone or candidates
	local best = pool[1]
	local bestAngle = ShopProximity.getShopAngleOffset(player, best.shop)
	local bestDistSq = ShopProximity.getShopDistanceSq(player, best.shop)

	for i = 2, #pool do
		local c = pool[i]
		local angle = ShopProximity.getShopAngleOffset(player, c.shop)
		local distSq = ShopProximity.getShopDistanceSq(player, c.shop)
		if #inCone > 0 then
			if angle < bestAngle or (angle == bestAngle and distSq < bestDistSq) then
				best = c
				bestAngle = angle
				bestDistSq = distSq
			end
		elseif distSq < bestDistSq then
			best = c
			bestAngle = angle
			bestDistSq = distSq
		end
	end
	return best.handler, best.shop
end

local function findBestHandler(player, interactRadius)
	return pickBestCandidate(player, collectCandidates(player, interactRadius))
end

local function shouldRescan(player)
	local now = getTimestampMs()
	if now - (ShopProximity._lastScanAt or 0) >= ShopProximity.SCAN_INTERVAL_MS then
		return true
	end
	local px = math.floor(player:getX())
	local py = math.floor(player:getY())
	local pz = player:getZ()
	if px ~= ShopProximity._lastScanPx or py ~= ShopProximity._lastScanPy or pz ~= ShopProximity._lastScanPz then
		return true
	end
	return false
end

local function refreshScanCache(player, interactRadius)
	ShopProximity._cachedBestHandler, ShopProximity._cachedBestShop = findBestHandler(player, interactRadius)
	ShopProximity._lastScanAt = getTimestampMs()
	ShopProximity._lastScanPx = math.floor(player:getX())
	ShopProximity._lastScanPy = math.floor(player:getY())
	ShopProximity._lastScanPz = player:getZ()
end

function ShopProximity.updateAllHints(player)
	if not player or not player:isLocalPlayer() then return end

	if not ShopProximity.canScanPlayer(player) then
		if ShopProximity._scanningActive then
			ShopProximity.clearAllActive(player)
			ShopProximity._scanningActive = false
		end
		return
	end
	ShopProximity._scanningActive = true

	if shouldRescan(player) then
		refreshScanCache(player, ShopProximity.HINT_RADIUS)
	end

	local bestHandler = ShopProximity._cachedBestHandler
	local bestShop = ShopProximity._cachedBestShop
	local canShow = bestHandler ~= nil and bestShop ~= nil
	if canShow and bestHandler.opts.canShowHint and not bestHandler.opts.canShowHint(player, bestShop) then
		canShow = false
	end

	if not canShow then
		ShopProximity.clearAllActive(player)
		return
	end

	for _, handler in ipairs(ShopProximity._handlers) do
		if handler ~= bestHandler then
			ShopProximity.clearHint(player, handler.state)
		end
	end

	ShopProximity.setShopHighlight(bestShop)

	local state = bestHandler.state
	local opts = bestHandler.opts
	local now = getTimestampMs()

	if ShopProximity.isPriorityNoteActive() then
		local color = ShopProximity._priorityNoteColor
		local remaining = (ShopProximity._priorityNoteUntil or 0) - now
		if color and remaining > 0 then
			player:setHaloNote(ShopProximity._priorityNoteText, color[1], color[2], color[3], remaining)
		end
		return
	end

	if state.hintActive and now - state.hintLastAt < ShopProximity.HINT_REFRESH_MS then
		return
	end
	state.hintLastAt = now

	ShopProximity.applyHaloHint(player, state, opts, bestShop)
end

function ShopProximity.onGlobalInteractKey(key)
	if key ~= getCore():getKey("Interact") then return end
	local player = getPlayer()
	if not player or not ShopProximity.canScanPlayer(player) then return end

	local bestHandler, bestShop = findBestHandler(player, ShopProximity.INTERACT_RADIUS)
	if not bestHandler or not bestShop then return end

	local state = bestHandler.state
	local opts = bestHandler.opts
	local now = getTimestampMs()
	if now - state.openLastAt < ShopProximity.OPEN_COOLDOWN_MS then return end
	state.openLastAt = now
	opts.open(player, bestShop)
end

function ShopProximity.initGlobalEvents()
	if ShopProximity._eventsHooked then return end
	ShopProximity._eventsHooked = true
	Events.OnPlayerUpdate.Add(ShopProximity.updateAllHints)
	Events.OnKeyPressed.Add(ShopProximity.onGlobalInteractKey)
end
