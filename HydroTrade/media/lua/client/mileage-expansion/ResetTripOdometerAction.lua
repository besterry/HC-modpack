ResetTripOdometerAction = ISBaseTimedAction:derive("ResetTripOdometerAction");

function ResetTripOdometerAction:isValid()
	return self.character:getVehicle() == self.vehicle
end

function ResetTripOdometerAction:update()
end

function ResetTripOdometerAction:start()
	self.sound = self.character:playSound("ResetTripOdometer")
end

function ResetTripOdometerAction:stop()
	self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self);
end

function ResetTripOdometerAction:perform()
	self.character:stopOrTriggerSound(self.sound)

    MileageExpansionAPI.resetVehicleTripOdometer(self.character:getVehicle())

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

---@param playerNum number
function ResetTripOdometerAction:new(playerNum)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(playerNum);
    o.vehicle = o.character:getVehicle()
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.maxTime = 200;
	if o.character:isTimedActionInstant() then o.maxTime = 1; end
	return o;
end

return ResetTripOdometerAction
