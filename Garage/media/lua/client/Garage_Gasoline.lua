local original_ISTakeGasolineFromVehicle_isValid = ISTakeGasolineFromVehicle.isValid

function ISTakeGasolineFromVehicle:isValid()
    return not self.vehicle:isRemovedFromWorld()
end