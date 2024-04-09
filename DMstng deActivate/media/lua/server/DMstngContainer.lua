require "Vehicle/Vehicles"

function Vehicles.ContainerAccess.DMstngContainer(vehicle, part, chr)
    if chr:getVehicle() == vehicle then
        return true
    end
end

