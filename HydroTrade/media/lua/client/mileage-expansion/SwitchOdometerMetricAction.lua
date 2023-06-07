SwitchOdometerMetricAction = ISBaseTimedAction:derive("SwitchOdometerMetricAction");

function SwitchOdometerMetricAction:isValid()
	return self.character:getVehicle() == self.vehicle
end

function SwitchOdometerMetricAction:update()
end

function SwitchOdometerMetricAction:start()
	self.sound = self.character:playSound("ResetTripOdometer")
end

function SwitchOdometerMetricAction:stop()
	self.character:stopOrTriggerSound(self.sound)
    ISBaseTimedAction.stop(self);
end

function SwitchOdometerMetricAction:perform()
	self.character:stopOrTriggerSound(self.sound)

	MileageExpansionAPI.setUseMetricOdometer(self.vehicle, self.newState)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

---@param playerNum number
---@param newState boolean
function SwitchOdometerMetricAction:new(playerNum, newState)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getSpecificPlayer(playerNum);
    o.vehicle = o.character:getVehicle()
	o.newState = newState;
	o.stopOnWalk = false;
	o.stopOnRun = false;
	o.maxTime = 25;
	if o.character:isTimedActionInstant() then o.maxTime = 1; end
	return o;
end

return SwitchOdometerMetricAction
