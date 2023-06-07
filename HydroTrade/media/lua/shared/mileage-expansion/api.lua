MileageExpansionAPI = {}

---Get vehicle odometer value
---@param vehicle BaseVehicle the vehicle to get the odometer value
---@return number
function MileageExpansionAPI.getVehicleOdometerValue(vehicle)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local engine = vehicle:getPartById("Engine")
        if engine then
            local engineData = engine:getModData()
            return engineData.odometer or 0
        end
    end
    return 0
end

---Get vehicle trip odometer value
---@param vehicle BaseVehicle the vehicle to get the trip odometer value
---@return number
function MileageExpansionAPI.getTripOdometerValue(vehicle)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local engine = vehicle:getPartById("Engine")
        if engine then
            local engineData = engine:getModData()
            return engineData.trip_odometer or 0
        end
    end
    return 0
end

--- Get use metric odometer is enabled
---@param vehicle BaseVehicle the vehicle to get the odometer value
function MileageExpansionAPI.getUseMetricOdometer(vehicle)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local modData = vehicle:getModData()
        return modData.useMetricOdometer or false
    end
end

--- Get trip odometer is enabled
---@param vehicle BaseVehicle the vehicle to get the trip odometer is enabled
function MileageExpansionAPI.getTripOdometerEnabled(vehicle)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local modData = vehicle:getModData()
        return modData.showTripOdometer or false
    end
end

--- Set use metric odometer
---@param vehicle BaseVehicle the vehicle to set the odometer value
---@param enabled boolean set the odometer to use true (metric) or false (imperial)
function MileageExpansionAPI.setUseMetricOdometer(vehicle, enabled)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local modData = vehicle:getModData()
        modData.useMetricOdometer = enabled == true

        if isClient() then
            sendClientCommand("MileageExpansion", "setUseMetricOdometer", { enabled = enabled })
            return
        end

        vehicle:transmitModData()
    end
end

--- Set trip odometer enabled
---@param vehicle BaseVehicle the vehicle to set the trip odometer enabled
---@param enabled boolean set the trip odometer to use true (enabled) or false (disabled)
function MileageExpansionAPI.setTripOdometerEnabled(vehicle, enabled)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle    
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local modData = vehicle:getModData()
        modData.showTripOdometer = enabled == true

        if isClient() then
            -- print("MileageExpansion: Transmit " .. vehicle:getScriptName() .. " trip odometer enabled set to " .. tostring(enabled))
            sendClientCommand("MileageExpansion", "setTripOdometerEnabled", { enabled = enabled })
            return
        end

        vehicle:transmitModData()
    end
end

---Set vehicle odometer value
---@param vehicle BaseVehicle the vehicle to set the odometer value
---@param newOdometer number set the odometer value
---@param newtripOdometer number|nil set the trip odometer value
---@param transmitNow boolean|nil transmit data to server now
function MileageExpansionAPI.setVehicleOdometerValue(vehicle, newOdometer, newtripOdometer, transmitNow)    
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local engine = vehicle:getPartById("Engine")
        if engine then
            local engineData = engine:getModData()

            local oldOdometer = engineData.odometer or 0
            local oldTempOdometer = engineData.trip_odometer

            --- Set odometer value
            engineData.odometer = math.max(0, newOdometer)

            --- Set trip odometer value if not nil
            if newtripOdometer ~= nil then
                engineData.trip_odometer = math.max(0, newtripOdometer)
            end

            --- Transmit data to server
            -- print(math.floor(oldOdometer) .. " === " .. math.floor(engineData.odometer))
            if isClient() and (transmitNow or math.floor(oldOdometer) ~= math.floor(engineData.odometer)) then
                -- print("MileageExpansion: Transmit " .. vehicle:getScriptName() .. " odometer set to " .. engineData.odometer .. " km" .. (engineData.trip_odometer and " and trip odometer set to " .. engineData.trip_odometer .. " km" or ""))
                sendClientCommand("MileageExpansion", "setVehicleOdometerValue", { odometer = engineData.odometer, tripOdometer = engineData.trip_odometer })

            elseif isServer() and (engineData.odometer ~= oldOdometer or engineData.trip_odometer ~= oldTempOdometer) then
                -- print("MileageExpansion: Transmit " .. vehicle:getScriptName() .. " odometer set to " .. engineData.odometer .. " km" .. (engineData.trip_odometer and " and trip odometer set to " .. engineData.trip_odometer .. " km" or ""))
                vehicle:transmitPartModData(engine)
            end
        end
    end
end

---Reset vehicle trip odometer value
---@param vehicle BaseVehicle the vehicle to reset the trip odometer value
function MileageExpansionAPI.resetVehicleTripOdometer(vehicle)
    vehicle = type(vehicle) == "number" and getVehicleById(vehicle) or vehicle
    if vehicle and instanceof(vehicle, "BaseVehicle") then
        local engine = vehicle:getPartById("Engine")
        if engine then
            local engineData = engine:getModData()

            --- Reset trip odometer value
            engineData.trip_odometer = 0

            --- Transmit data to server
            if isClient() then
                -- print("MileageExpansion: " .. vehicle:getScriptName() .. " trip odometer resetted")
                sendClientCommand("MileageExpansion", "resetVehicleTripOdometer", {})
                return
            end

            -- print("MileageExpansion: " .. vehicle:getScriptName() .. " trip odometer resetted")
            vehicle:transmitPartModData(engine)
        end
    end
end

--- Receive command from client
if isServer() then
    Events.OnClientCommand.Add(function (module, command, player, args)
        if module ~= "MileageExpansion" then return end

        local vehicle = player:getVehicle() or args.vehicle

        if command == "setUseMetricOdometer" then
            MileageExpansionAPI.setUseMetricOdometer(vehicle, args.enabled)
        end

        if command == "setTripOdometerEnabled" then
            MileageExpansionAPI.setTripOdometerEnabled(vehicle, args.enabled)
        end

        if command == "setVehicleOdometerValue" then
            MileageExpansionAPI.setVehicleOdometerValue(vehicle, args.odometer, args.tripOdometer)
        end

        if command == "resetVehicleTripOdometer" then
            MileageExpansionAPI.resetVehicleTripOdometer(vehicle)
        end
    end)
end

return MileageExpansionAPI
