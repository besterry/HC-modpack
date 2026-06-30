TutorialQuestNavigation = TutorialQuestNavigation or {}

local arrowMarker = nil
local arrowExpireMs = 0
local tickRegistered = false

local function nowMs()
	if getTimestampMs then
		return getTimestampMs()
	end
	return 0
end

local function clearArrow()
	if arrowMarker then
		arrowMarker:remove()
		arrowMarker = nil
	end
	arrowExpireMs = 0
end

function TutorialQuestNavigation.clear()
	clearArrow()
end

local function objectHasAtmSprite(obj)
	if not obj then return false end
	local sprite = obj.getSprite and obj:getSprite() or nil
	if sprite and TutorialQuestsData.isAtmSprite(sprite:getName()) then
		return true
	end
	return false
end

local function squareHasAtm(square)
	if not square then return false end
	local objects = square:getObjects()
	if objects then
		for i = 0, objects:size() - 1 do
			if objectHasAtmSprite(objects:get(i)) then
				return true, square:getX(), square:getY(), square:getZ()
			end
		end
	end
	local special = square.getSpecialObjects and square:getSpecialObjects() or nil
	if special then
		for i = 0, special:size() - 1 do
			if objectHasAtmSprite(special:get(i)) then
				return true, square:getX(), square:getY(), square:getZ()
			end
		end
	end
	return false
end

function TutorialQuestNavigation.searchAtm(player, maxRadius)
	if not player then return nil end
	local px = math.floor(player:getX())
	local py = math.floor(player:getY())
	local pz = player:getZ()
	local cell = getCell()
	if not cell then return nil end

	maxRadius = maxRadius or TutorialQuestsData.ATM_SEARCH_RADIUS
	local bestDist = maxRadius + 1
	local best = nil

	for dx = -maxRadius, maxRadius do
		for dy = -maxRadius, maxRadius do
			if math.abs(dx) + math.abs(dy) <= maxRadius then
				local sq = cell:getGridSquare(px + dx, py + dy, pz)
				local found, ax, ay, az = squareHasAtm(sq)
				if found then
					local dist = math.abs(dx) + math.abs(dy)
					if dist < bestDist then
						bestDist = dist
						best = { x = ax, y = ay, z = az }
					end
				end
			end
		end
	end
	return best
end

local function aimTarget(player, target)
	local tx = target.x + 0.5
	local ty = target.y + 0.5
	local tz = target.z or 0
	local px = player:getX()
	local py = player:getY()
	local dx = tx - px
	local dy = ty - py
	local dist = math.sqrt(dx * dx + dy * dy)
	if dist < 1.5 then
		if dist < 0.01 then
			tx = px + 3
			ty = py
		else
			tx = px + (dx / dist) * 3
			ty = py + (dy / dist) * 3
		end
	end
	return tx, ty, tz
end

local function ensureTick()
	if tickRegistered then return end
	tickRegistered = true
	Events.OnTick.Add(function()
		TutorialQuestNavigation.tick()
	end)
end

function TutorialQuestNavigation.showArrow(player, target, durationMs)
	if not player or not target then return end
	ensureTick()

	local markers = getWorldMarkers()
	if not markers then return end

	clearArrow()

	local tx, ty, tz = aimTarget(player, target)
	arrowMarker = markers:addDirectionArrow(player, tx, ty, tz, nil, 1.0, 0.85, 0.25, 1.0)
	arrowExpireMs = nowMs() + (durationMs or TutorialQuestsData.ARROW_DURATION_MS)
end

function TutorialQuestNavigation.tick()
	if arrowExpireMs <= 0 then return end
	if nowMs() >= arrowExpireMs then
		clearArrow()
	end
end
