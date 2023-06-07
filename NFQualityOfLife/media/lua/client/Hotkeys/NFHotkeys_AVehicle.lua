NFHotkeys = NFHotkeys or {}

local SORT_VARS = {
    pos = Vector3f.new()
}

local function distanceToPassengerPosition(seat)
    local outside = SORT_VARS.vehicle:getPassengerPosition(seat, "outside")
    local worldPos = SORT_VARS.vehicle:getWorldPos(outside:getOffset(), SORT_VARS.pos)
    return SORT_VARS.character:DistTo(worldPos:x(), worldPos:y())
end

local function getClosestSeat(character, vehicle, seats)
    if #seats == 0 then
        return nil
    end
    -- Sort by distance from the player to the 'outside' position.
    SORT_VARS.character = character
    SORT_VARS.vehicle = vehicle
    table.sort(seats, function(a, b)
        local distA = distanceToPassengerPosition(a)
        local distB = distanceToPassengerPosition(b)
        return distA < distB - 1
    end)
    return seats[1]
end

-- TODO: seat may not have a door
local function isSeatValid(character, vehicle, seat)
    -- 0 is a driver's seat
    if seat ~= 0 and not vehicle:canSwitchSeat(seat, 0) then
        return false
    end

    return not vehicle:isEnterBlocked(character, seat)
            and not vehicle:isSeatOccupied(seat)
            and vehicle:isSeatInstalled(seat)
end

local function isDoorValid(character, vehicle, seat)
    local door
    local doorPart = vehicle:getPassengerDoor(seat)
    if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
        door = doorPart:getDoor()
    else
        doorPart = vehicle:getPassengerDoor2(seat)
        if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() then
            door = doorPart:getDoor()
        end
    end

    if door then
        if door:isLocked() then
            if not vehicle:isKeyIsOnDoor() and not character:getInventory():haveThisKeyId(vehicle:getKeyId()) then
                return false
            end
        end
    else
        return false
    end
    return true
end

-- check for playerObj:isBlockMovement()
function NFHotkeys.enterVehicle()
    local character = getSpecificPlayer(0)

    if character:getVehicle() then return end

    local vehicle = ISVehicleMenu.getVehicleToInteractWith(character)
    if not vehicle or not vehicle:getModData().hasEntered then return end

    local seats = {}
    -- or getPassengerCount
    for seat = 0, vehicle:getMaxPassengers() - 1 do
        if isDoorValid(character, vehicle, seat) and isSeatValid(character, vehicle, seat) then
            table.insert(seats, seat)
        end
    end

    if #seats ~= 0 then
        local seat = getClosestSeat(character, vehicle, seats)
        ISVehicleMenu.processShiftEnter(character, vehicle, seat)
    end
end

-- *********************

local function onEnterVehicle(character)
    if instanceof(character, 'IsoPlayer') and character:isLocalPlayer() and character:getPlayerNum() == 0
            and not character:getVehicle():getModData().hasEntered then
        character:getVehicle():getModData().hasEntered = true
    end
end

Events.OnEnterVehicle.Add(onEnterVehicle)