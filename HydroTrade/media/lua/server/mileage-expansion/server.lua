--- Backup original function
local _Vehicles_Create_Engine = Vehicles.Create.Engine

---Override Vehicles.Create.Engine
--- Set default odometer value at vehicle creation
---@param vehicle BaseVehicle
---@param part VehiclePart
function Vehicles.Create.Engine(vehicle, part)
    _Vehicles_Create_Engine(vehicle, part) -- call original function
    
    if part and MileageExpansionAPI.getVehicleOdometerValue(vehicle) == 0 then
        local unit = getSandboxOptions():getOptionByName('MileageExpansion.Default_Unit'):getValue() or 1
        local min = getSandboxOptions():getOptionByName('MileageExpansion.Minimum_Starting_Odometer'):getValue() or 100000
        local max = getSandboxOptions():getOptionByName('MileageExpansion.Maximum_Starting_Odometer'):getValue() or 300000
        
        --- Set initial odometer value based on initial engine condition
        local odometer = ZombRandFloat(min, max) * (1.1 - (part:getCondition() / 100))
        MileageExpansionAPI.setVehicleOdometerValue(vehicle, odometer, ZombRandFloat(0, odometer / 2), true)
        MileageExpansionAPI.setUseMetricOdometer(vehicle, unit == 2)
    end
end
