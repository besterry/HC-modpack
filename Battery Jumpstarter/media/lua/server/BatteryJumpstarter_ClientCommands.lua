local Commands = {}

function Commands.increaseUsedDelta(vehicleId)
	local vehicle = getVehicleById(vehicleId)
	local part = vehicle:getPartById('Battery')
	part:getInventoryItem():setUsedDelta(0.15)
	vehicle:transmitPartUsedDelta(part)
end

local function OnClientCommand(module, command, player, args)
    if module == 'BatteryJumpstarter' then
        Commands[command](args[1])
    end
end

Events.OnClientCommand.Add(OnClientCommand)