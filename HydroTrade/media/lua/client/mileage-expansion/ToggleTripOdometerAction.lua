ToggleTripOdometerAction = ISBaseTimedAction:derive("ToggleTripOdometerAction");

function ToggleTripOdometerAction:isValid()
	return self.character:getVehicle() == self.vehicle
end

function ToggleTripOdometerAction:update()
end

function ToggleTripOdometerAction:start()
	self.sound = self.character:playSound("ResetTripOdometer")
end

function ToggleTripOdometerAction:stop()
	self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self);
end

function ToggleTripOdometerAction:perform()
	self.character:stopOrTriggerSound(self.sound)

	MileageExpansionAPI.setTripOdometerEnabled(self.vehicle, not MileageExpansionAPI.getTripOdometerEnabled(self.vehicle))

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

---@param playerNum number
function ToggleTripOdometerAction:new(playerNum)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(playerNum);
    o.vehicle = o.character:getVehicle()
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.maxTime = 50;
	if o.character:isTimedActionInstant() then o.maxTime = 1; end
	return o;
end

return ToggleTripOdometerAction
