local lastX, lastY = 0, 0

---@type BaseVehicle | nil last vehicle the player was driving.
local lastVehicle = nil

local function onTick()
    for i = 1, getNumActivePlayers() do
        local player = getSpecificPlayer(i - 1)

        --- Check if player is alive
        if player and not player:isDead() then
            local vehicle = player:getVehicle()

            --- Check if player is driving the vehicle
            if vehicle and vehicle:getDriver() == player then
                if vehicle ~= lastVehicle then
                    lastVehicle = vehicle
                    lastX = vehicle:getX()
                    lastY = vehicle:getY()
                end
                
                --- Get engine part
                local engine = vehicle:getPartById("Engine")
                if engine then
                    local traveled = 0
                    local oldOdometer = MileageExpansionAPI.getVehicleOdometerValue(vehicle)
                    local oldTripOdometer = MileageExpansionAPI.getTripOdometerValue(vehicle)

                    --- Calculate traveled distance since last tick if engine is running and vehicle is moving
                    if vehicle:isEngineRunning() and vehicle:getCurrentSpeedKmHour() ~= 0 then
                        local traveledX = vehicle:getX() - lastX
                        local traveledY = vehicle:getY() - lastY

                        --- calculate distance in km (1 meter = 1 tile)
                        traveled = math.sqrt(traveledX * traveledX + traveledY * traveledY) / (getSandboxOptions():getOptionByName('MileageExpansion.Meter_Per_Kilometer'):getValue() or 1000)

                        if traveled > 0 then
                            lastX = vehicle:getX()
                            lastY = vehicle:getY()
                        end
                    end

                    --- Set odometer value and transmit data to client if value changed
                    if traveled and traveled > 0 then
                        -- print("VehicleOdometer: " .. vehicle:getScriptName() .. " traveled " .. oldOdometer + traveled .. " km")
                        MileageExpansionAPI.setVehicleOdometerValue(vehicle, oldOdometer + traveled, oldTripOdometer + traveled)
                    end
                end
            
            --- Reset lastVehicle, lastX and lastY if player is not driving a vehicle
            else
                -- lastVehicle = nil
                lastX = 0
                lastY = 0
            end
        end
    end
end
Events.OnTick.Add(onTick)

--- Set initial odometer value when player enters a vehicle
---@param player IsoPlayer
local function onEnterVehicle(player)
    local vehicle = player:getVehicle()
    if not vehicle or vehicle:getDriver() ~= player then return end

    local engine = vehicle:getPartById("Engine")
    if engine then
        if MileageExpansionAPI.getVehicleOdometerValue(vehicle) == 0 then
            local unit = getSandboxOptions():getOptionByName('MileageExpansion.Default_Unit'):getValue() or 1
            local min = getSandboxOptions():getOptionByName('MileageExpansion.Minimum_Starting_Odometer'):getValue() or 100000
            local max = getSandboxOptions():getOptionByName('MileageExpansion.Maximum_Starting_Odometer'):getValue() or 300000
            
            --- Set initial odometer value based on initial engine condition
            local odometer = ZombRandFloat(min, max) * (1.1 - (engine:getCondition() / 100))
            MileageExpansionAPI.setVehicleOdometerValue(vehicle, odometer, ZombRandFloat(0, odometer / 2), true)
            MileageExpansionAPI.setUseMetricOdometer(vehicle, unit == 2)
        end
    end
end
Events.OnEnterVehicle.Add(onEnterVehicle)
Events.OnSwitchVehicleSeat.Add(onEnterVehicle)

--- Transmit odometer on exiting vehicle
---@param player IsoPlayer
local function onExitVehicle(player)
    if lastVehicle and instanceof(lastVehicle, "BaseVehicle") and lastVehicle:getDriver() ~= player then
        MileageExpansionAPI.setVehicleOdometerValue(lastVehicle, MileageExpansionAPI.getVehicleOdometerValue(lastVehicle), MileageExpansionAPI.getTripOdometerValue(lastVehicle), true)
        lastVehicle = nil
    end
end
Events.OnExitVehicle.Add(onExitVehicle)
Events.OnSwitchVehicleSeat.Add(onExitVehicle)
