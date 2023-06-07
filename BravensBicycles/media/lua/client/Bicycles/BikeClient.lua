local function onServerCommand(module, command, args)

    if module ~= "Braven" then return; end

    if command == "BikeSpawned" then

        local function awaitBike()

            local playerObj =  getPlayer()
            local vehicle = getVehicleById(args.vehicleId);

            if vehicle then
                BikeServer.UpdateBike(playerObj, vehicle, args.frame, playerObj:getInventory())
                BravensUtils.TryPlaySoundClip(vehicle, "BikeHandle")
                Events.OnTick.Remove(awaitBike);
            end
        end

        Events.OnTick.Add(awaitBike);
    end
end

BikeClient = {}

BikeClient.SpawnBike = function(bikeName, frame)
    sendClientCommand("Braven", "SpawnBike", {bikeName = bikeName, frame = frame});
end

Events.OnServerCommand.Add(onServerCommand);
