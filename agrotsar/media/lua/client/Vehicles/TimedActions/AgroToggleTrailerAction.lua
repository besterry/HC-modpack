require('TimedActions/ISBaseTimedAction')
require('AgroUtils')

AgroToggleTrailerAction = ISBaseTimedAction:derive("AgroToggleTrailerAction")

function AgroToggleTrailerAction:isValid()
    return self.character:getVehicle() == self.vehicle and self.vehicle:getVehicleTowing() == self.trailer
end

function AgroToggleTrailerAction:update()
end

function AgroToggleTrailerAction:start()
end

function AgroToggleTrailerAction:perform()
    AgroUtils.toggleTrailerActivated(self.trailer)
    ISBaseTimedAction.perform(self)
end

function AgroToggleTrailerAction:stop()
    ISBaseTimedAction.stop(self)
end

function AgroToggleTrailerAction:new(character, vehicle, trailer)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = vehicle
    o.trailer = trailer
    o.maxTime = 50
    return o
end