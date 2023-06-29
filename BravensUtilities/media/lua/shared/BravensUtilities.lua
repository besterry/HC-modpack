--***********************************************************
--**                       BitBraven                       **
--***********************************************************

BravensUtils = {}

--- Attempt to play a sound from an entity.
---@param obj IsoGameCharacter | DeviceData | BaseVehicle
---@param soundName string
BravensUtils.TryPlaySoundClip = function(obj, soundName)

	if obj:getEmitter():isPlaying(soundName) then return end
    obj:getEmitter():playSoundImpl(soundName, IsoObject.new())
end

--- Attempt to stop playing a sound from an entity.
---@param obj IsoGameCharacter | DeviceData | BaseVehicle
---@param soundName string
BravensUtils.TryStopSoundClip = function(obj, soundName)

	if not obj:getEmitter():isPlaying(soundName) then return end
	obj:getEmitter():stopSoundByName(soundName)
end

--- Cause physical exertion on a Player
---@param playerObj IsoPlayer
---@param amount number
BravensUtils.TirePlayer = function(playerObj, amount)

	local stats = playerObj:getStats()
	if not stats then return end

	if stats:getEndurance() < 0.21 then return end --We don't want to *kill* someone out of exhaustion do we?
	stats:setEndurance(stats:getEndurance() - amount)
end

--- Delays a function by a specified amount in milliseconds
--- <br> Credits for this function: Konijima
---@param func function
---@param delay number
BravensUtils.DelayFunction = function(func, delay)

    delay = delay or 1;
    local ticks = 0;
    local canceled = false;

    local function onTick()

        if not canceled and ticks < delay then
            ticks = ticks + 1;
            return;
        end

        Events.OnTick.Remove(onTick);
        if not canceled then func(); end
    end

    Events.OnTick.Add(onTick);

    return function()
        canceled = true;
    end
end

--- Calculates the distance between two entities
BravensUtils.DistanceBetween = function(firstObj, secondObj)

    local distance = {}

    distance.X = firstObj:getX() - secondObj:getX()
    distance.Y = firstObj:getY() - secondObj:getY()
    distance.Z = firstObj:getZ() - secondObj:getZ()

    return distance
end

--- Checks if a given variable is a number
BravensUtils.isNumber = function(num)

    if tonumber(num) ~= nil then
        return true
    end

    return false
end