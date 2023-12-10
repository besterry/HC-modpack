---
--- Created by cytt0rak
---  WIP

function CytAstra89Windshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

local part = vehicle:getPartById("Windshield")
        if (vehicle:getPartById("CytAstra89WindshieldBars"):getCondition() > 1) and (vehicle:getPartById("Windshield"):getCondition() < 70) and (vehicle:getPartById("CytAstra89WindshieldBars"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89WindshieldBars"):setCondition(vehicle:getPartById("CytAstra89WindshieldBars"):getCondition()-1)

        end
        vehicle:transmitPartModData(Windshield)
    end


end

function CytAstra89EngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

local part = vehicle:getPartById("EngineDoor")
        if (vehicle:getPartById("CytAstra89Bullbar"):getCondition() > 1) and (vehicle:getPartById("EngineDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra89Bullbar"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89Bullbar"):setCondition(vehicle:getPartById("CytAstra89Bullbar"):getCondition()-1)

        end
        vehicle:transmitPartModData(EngineDoor)
    end


end

function CytAstra89GasTank(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("GasTank")
        if (vehicle:getPartById("GasTank"):getCondition() < 70) and (vehicle:getPartById("GasTank"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(GasTank)
    end


end

function CytAstra89DoorFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("DoorFrontLeft")
        if (vehicle:getPartById("CytAstra89FrontLeftDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89FrontLeftDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89FrontLeftDoorArmor"):setCondition(vehicle:getPartById("CytAstra89FrontLeftDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function CytAstra89DoorFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("DoorFrontRight")
        if (vehicle:getPartById("CytAstra89FrontRightDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89FrontRightDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89FrontRightDoorArmor"):setCondition(vehicle:getPartById("CytAstra89FrontRightDoorArmor"):getCondition()-1)

        end

        vehicle:transmitPartModData(DoorFrontRight)
    end


end

function CytAstra89WindowFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("WindowFrontLeft")
        if (vehicle:getPartById("CytAstra89FrontLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89FrontLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89FrontLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra89FrontLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
    end


end

function CytAstra89WindowFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("WindowFrontRight")
        if (vehicle:getPartById("CytAstra89FrontRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89FrontRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89FrontRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra89FrontRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontRight)
    end


end


function CytAstra89WindowRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("WindowRearLeft")
        if (vehicle:getPartById("CytAstra89RearLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearLeft"):getCondition() < 70) and (vehicle:getPartById("CytAstra89RearLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89RearLeftWindowArmor"):setCondition(vehicle:getPartById("CytAstra89RearLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearLeft)
    end


end

function CytAstra89WindowRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("WindowRearRight")
        if (vehicle:getPartById("CytAstra89RearRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearRight"):getCondition() < 70) and (vehicle:getPartById("CytAstra89RearRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89RearRightWindowArmor"):setCondition(vehicle:getPartById("CytAstra89RearRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearRight)
    end


end

function CytAstra89WindshieldRear(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("WindshieldRear")
        if (vehicle:getPartById("CytAstra89TrunkArmor"):getCondition() > 1) and (vehicle:getPartById("WindshieldRear"):getCondition() < 70) and (vehicle:getPartById("CytAstra89TrunkArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytAstra89TrunkArmor"):setCondition(vehicle:getPartById("CytAstra89TrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(WindshieldRear)
    end

end

function CytAstra89Muffler(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("Muffler")
        if (vehicle:getPartById("Muffler"):getCondition() < 70) and (vehicle:getPartById("Muffler"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(Muffler)
    end


end

function CytAstra89TrunkDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("TrunkDoor")
        if (vehicle:getPartById("CytAstra89TrunkArmor"):getCondition() > 1) and (vehicle:getPartById("TrunkDoor"):getCondition() < 70) and (vehicle:getPartById("CytAstra89TrunkArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("CytAstra89TrunkArmor"):setCondition(vehicle:getPartById("CytAstra89TrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(TruckBed)
    end


end

function CytAstra89TireFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("TireFrontLeft")
        if (vehicle:getPartById("TireFrontLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontLeft)
    end


end

function CytAstra89TireFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("TireFrontRight")
        if (vehicle:getPartById("TireFrontRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireFrontRight)
    end


end

function CytAstra89TireRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("TireRearLeft")
        if (vehicle:getPartById("TireRearLeft"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearLeft)
    end


end

function CytAstra89TireRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytVAstraHB" )) then

        local part = vehicle:getPartById("TireRearRight")
        if (vehicle:getPartById("TireRearRight"):getCondition() < 20) and (vehicle:getPartById("CytAstra89Tire"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 29 })

        end
        vehicle:transmitPartModData(TireRearRight)
    end


end

Events.OnPlayerUpdate.Add(CytAstra89Windshield);
Events.OnPlayerUpdate.Add(CytAstra89WindshieldRear);
Events.OnPlayerUpdate.Add(CytAstra89EngineDoor);
Events.OnPlayerUpdate.Add(CytAstra89DoorFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89DoorFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89WindowFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89WindowFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89WindowRearRight);
Events.OnPlayerUpdate.Add(CytAstra89WindowRearLeft);
Events.OnPlayerUpdate.Add(CytAstra89TrunkDoor);
Events.OnPlayerUpdate.Add(CytAstra89TireFrontLeft);
Events.OnPlayerUpdate.Add(CytAstra89TireFrontRight);
Events.OnPlayerUpdate.Add(CytAstra89TireRearLeft);
Events.OnPlayerUpdate.Add(CytAstra89TireRearRight);