if not isServer() then return end
-------------------------------------------------------------------------------
local function itemGPS_OnClientCommand(module, command, player,arguments)
	if module ~= "GPScommands" then return end
	if command == "GPSchargeBattery" then
		local vehicle = getVehicleById(arguments[1])
		local delta = arguments[2]
		VehicleUtils.chargeBattery(vehicle,delta);
	end
end
Events.OnClientCommand.Add(itemGPS_OnClientCommand)
-----------------------------------------------------------------
