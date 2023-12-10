---
--- Created by cytt0rak
---  WIP

function CytAstra89STWindshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

local part = vehicle:getPartById("Windshield")
        if (vehicle:getPartById("CytAstra89STWindshieldBars"):getCondition() > 1) and (vehicle:getPartById("Windshield"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STWindshieldBars"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STWindshieldBars"):setCondition(vehicle:getPartById("CytAstra89STWindshieldBars"):getCondition()-1)

        end
        vehicle:transmitPartModData(Windshield)
    end


end

function CytAstra89STEngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

local part = vehicle:getPartById("EngineDoor")
        if (vehicle:getPartById("CytAstra89STBullbar"):getCondition() > 1) and (vehicle:getPartById("EngineDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STBullbar"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STBullbar"):setCondition(vehicle:getPartById("CytAstra89STBullbar"):getCondition()-1)

        end
        vehicle:transmitPartModData(EngineDoor)
    end


end

function CytAstra89STGasTank(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("GasTank")
        if (vehicle:getPartById("GasTank"):getCondition() < 70) and (vehicle:getPartById("GasTank"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(GasTank)
    end


end

function CytAstra89STDoorFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("DoorFrontLeft")
        if (vehicle:getPartById("CytAstra89STFrontLeftDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STFrontLeftDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STFrontLeftDoorArmor"):setCondition(vehicle:getPartById("CytAstra89STFrontLeftDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function CytAstra89STDoorFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("DoorFrontRight")
        if (vehicle:getPartById("CytAstra89STFrontRightDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STFrontRightDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STFrontRightDoorArmor"):setCondition(vehicle:getPartById("CytAstra89STFrontRightDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontRight)
    end


end

function CytAstra89STWindowFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("WindowFrontLeft")
        if (vehicle:getPartById("CytAstra89STFrontLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STFrontLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STFrontLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra89STFrontLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
    end


end

function CytAstra89STWindowFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("WindowFrontRight")
        if (vehicle:getPartById("CytAstra89STFrontRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STFrontRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STFrontRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra89STFrontRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontRight)
    end


end


function CytAstra89STWindowRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("WindowRearLeft")
        if (vehicle:getPartById("CytAstra89STRearLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STRearLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STRearLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra89STRearLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearLeft)
    end


end

function CytAstra89STWindowRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("WindowRearRight")
        if (vehicle:getPartById("CytAstra89STRearRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STRearRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STRearRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra89STRearRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearRight)
    end


end

function CytAstra89STWindshieldRear(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("WindshieldRear")
        if (vehicle:getPartById("CytAstra89STTrunkArmor"):getCondition() > 1) and (vehicle:getPartById("WindshieldRear"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STTrunkArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89STTrunkArmor"):setCondition(vehicle:getPartById("CytAstra89STTrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(WindshieldRear)
    end

end

function CytAstra89STMuffler(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("Muffler")
        if (vehicle:getPartById("Muffler"):getCondition() < 70) and (vehicle:getPartById("Muffler"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(Muffler)
    end


end

function CytAstra89STTrunkDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("TrunkDoor")
        if (vehicle:getPartById("CytAstra89STTrunkArmor"):getCondition() > 1) and (vehicle:getPartById("TrunkDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra89STTrunkArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("CytAstra89STTrunkArmor"):setCondition(vehicle:getPartById("CytAstra89STTrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(TruckBed)
    end


end

function CytAstra89STTireFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("TireFrontLeft")
        if (vehicle:getPartById("TireFrontLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontLeft)
    end


end

function CytAstra89STTireFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("TireFrontRight")
        if (vehicle:getPartById("TireFrontRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontRight)
    end


end

function CytAstra89STTireRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("TireRearLeft")
        if (vehicle:getPartById("TireRearLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearLeft)
    end


end

function CytAstra89STTireRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVST5DAstra" )) then

        local part = vehicle:getPartById("TireRearRight")
        if (vehicle:getPartById("TireRearRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearRight)
    end


end

Events.OnPlayerUpdate.Add(CytAstra89STWindshield);
Events.OnPlayerUpdate.Add(CytAstra89STWindshieldRear);
Events.OnPlayerUpdate.Add(CytAstra89STEngineDoor);
Events.OnPlayerUpdate.Add(CytAstra89STDoorFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89STDoorFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89STWindowFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89STWindowFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89STWindowRearRight);
Events.OnPlayerUpdate.Add(CytAstra89STWindowRearLeft);
Events.OnPlayerUpdate.Add(CytAstra89STTrunkDoor);
Events.OnPlayerUpdate.Add(CytAstra89STTireFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89STTireFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89STTireRearLeft);
Events.OnPlayerUpdate.Add(CytAstra89STTireRearRight);