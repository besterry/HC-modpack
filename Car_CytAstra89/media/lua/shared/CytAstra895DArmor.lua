---
--- Created by cytt0rak
---  WIP

function CytAstra895DWindshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

local part = vehicle:getPartById("Windshield")
        if (vehicle:getPartById("CytAstra895DWindshieldBars"):getCondition() > 1) and (vehicle:getPartById("Windshield"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DWindshieldBars"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DWindshieldBars"):setCondition(vehicle:getPartById("CytAstra895DWindshieldBars"):getCondition()-1)

        end
        vehicle:transmitPartModData(Windshield)
    end


end

function CytAstra895DEngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

local part = vehicle:getPartById("EngineDoor")
        if (vehicle:getPartById("CytAstra895DBullbar"):getCondition() > 1) and (vehicle:getPartById("EngineDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DBullbar"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DBullbar"):setCondition(vehicle:getPartById("CytAstra895DBullbar"):getCondition()-1)

        end
        vehicle:transmitPartModData(EngineDoor)
    end


end

function CytAstra895DGasTank(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("GasTank")
        if (vehicle:getPartById("GasTank"):getCondition() < 70) and (vehicle:getPartById("GasTank"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(GasTank)
    end


end

function CytAstra895DDoorFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("DoorFrontLeft")
        if (vehicle:getPartById("CytAstra895DFrontLeftDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DFrontLeftDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DFrontLeftDoorArmor"):setCondition(vehicle:getPartById("CytAstra895DFrontLeftDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function CytAstra895DDoorFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("DoorFrontRight")
        if (vehicle:getPartById("CytAstra895DFrontRightDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DFrontRightDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DFrontRightDoorArmor"):setCondition(vehicle:getPartById("CytAstra895DFrontRightDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontRight)
    end


end

function CytAstra895DWindowFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("WindowFrontLeft")
        if (vehicle:getPartById("CytAstra895DFrontLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DFrontLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DFrontLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra895DFrontLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
    end


end

function CytAstra895DWindowFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("WindowFrontRight")
        if (vehicle:getPartById("CytAstra895DFrontRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DFrontRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DFrontRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra895DFrontRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontRight)
    end


end


function CytAstra895DWindowRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("WindowRearLeft")
        if (vehicle:getPartById("CytAstra895DRearLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DRearLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DRearLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra895DRearLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearLeft)
    end


end

function CytAstra895DWindowRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("WindowRearRight")
        if (vehicle:getPartById("CytAstra895DRearRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DRearRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DRearRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra895DRearRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearRight)
    end


end

function CytAstra895DWindshieldRear(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("WindshieldRear")
        if (vehicle:getPartById("CytAstra895DTrunkArmor"):getCondition() > 1) and (vehicle:getPartById("WindshieldRear"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DTrunkArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra895DTrunkArmor"):setCondition(vehicle:getPartById("CytAstra895DTrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(WindshieldRear)
    end

end

function CytAstra895DMuffler(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("Muffler")
        if (vehicle:getPartById("Muffler"):getCondition() < 70) and (vehicle:getPartById("Muffler"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(Muffler)
    end


end

function CytAstra895DTrunkDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("TrunkDoor")
        if (vehicle:getPartById("CytAstra895DTrunkArmor"):getCondition() > 1) and (vehicle:getPartById("TrunkDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra895DTrunkArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("CytAstra895DTrunkArmor"):setCondition(vehicle:getPartById("CytAstra895DTrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(TruckBed)
    end


end

function CytAstra895DTireFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("TireFrontLeft")
        if (vehicle:getPartById("TireFrontLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontLeft)
    end


end

function CytAstra895DTireFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("TireFrontRight")
        if (vehicle:getPartById("TireFrontRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontRight)
    end


end

function CytAstra895DTireRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("TireRearLeft")
        if (vehicle:getPartById("TireRearLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearLeft)
    end


end

function CytAstra895DTireRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVHB5DAstra" )) then

        local part = vehicle:getPartById("TireRearRight")
        if (vehicle:getPartById("TireRearRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearRight)
    end


end

Events.OnPlayerUpdate.Add(CytAstra895DWindshield);
Events.OnPlayerUpdate.Add(CytAstra895DWindshieldRear);
Events.OnPlayerUpdate.Add(CytAstra895DEngineDoor);
Events.OnPlayerUpdate.Add(CytAstra895DDoorFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra895DDoorFrontRight);
Events.OnPlayerUpdate.Add(CytAstra895DWindowFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra895DWindowFrontRight);
Events.OnPlayerUpdate.Add(CytAstra895DWindowRearRight);
Events.OnPlayerUpdate.Add(CytAstra895DWindowRearLeft);
Events.OnPlayerUpdate.Add(CytAstra895DTrunkDoor);
Events.OnPlayerUpdate.Add(CytAstra895DTireFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra895DTireFrontRight);
Events.OnPlayerUpdate.Add(CytAstra895DTireRearLeft);
Events.OnPlayerUpdate.Add(CytAstra895DTireRearRight);