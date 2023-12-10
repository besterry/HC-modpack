---
--- Created by cytt0rak
---  WIP

function CytMercEvoWindshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

local part = vehicle:getPartById("Windshield")
        if (vehicle:getPartById("CytMercEvoWindshieldBars"):getCondition() > 1) and (vehicle:getPartById("Windshield"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoWindshieldBars"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoWindshieldBars"):setCondition(vehicle:getPartById("CytMercEvoWindshieldBars"):getCondition()-1)

        end
        vehicle:transmitPartModData(Windshield)
    end


end

function CytMercEvoEngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

local part = vehicle:getPartById("EngineDoor")
        if (vehicle:getPartById("CytMercEvoBullbar"):getCondition() > 1) and (vehicle:getPartById("EngineDoor"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoBullbar"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoBullbar"):setCondition(vehicle:getPartById("CytMercEvoBullbar"):getCondition()-1)

        end
        vehicle:transmitPartModData(EngineDoor)
    end


end

function CytMercEvoWindowFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("WindowFrontLeft")
        if (vehicle:getPartById("CytMercEvoFrontLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoFrontLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoFrontLeftWindowArmor"):setCondition(vehicle:getPartById("CytMercEvoFrontLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
    end


end

function CytMercEvoWindowFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("WindowFrontRight")
        if (vehicle:getPartById("CytMercEvoFrontRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoFrontRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoFrontRightWindowArmor"):setCondition(vehicle:getPartById("CytMercEvoFrontRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowFrontRight)
    end


end


function CytMercEvoWindowRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("WindowRearLeft")
        if (vehicle:getPartById("CytMercEvoRearLeftWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearLeft"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoRearLeftWindowArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoRearLeftWindowArmor"):setCondition(vehicle:getPartById("CytMercEvoRearLeftWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearLeft)
    end


end

function CytMercEvoWindowRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("WindowRearRight")
        if (vehicle:getPartById("CytMercEvoRearRightWindowArmor"):getCondition() > 1) and (vehicle:getPartById("WindowRearRight"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoRearRightWindowArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoRearRightWindowArmor"):setCondition(vehicle:getPartById("CytMercEvoRearRightWindowArmor"):getCondition()-1)

        end
        vehicle:transmitPartModData(WindowRearRight)
    end


end

function CytMercEvoWindshieldRear(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("WindshieldRear")
        if (vehicle:getPartById("CytMercEvoTrunkArmor"):getCondition() > 1) and (vehicle:getPartById("WindshieldRear"):getCondition() < 70) and (vehicle:getPartById("CytMercEvoTrunkArmor"):getInventoryItem()) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })
            vehicle:getPartById("CytMercEvoTrunkArmor"):setCondition(vehicle:getPartById("CytMercEvoTrunkArmor"):getCondition()-1)
        end
        vehicle:transmitPartModData(WindshieldRear)
    end

end

function CytMercEvoMuffler(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "CytMercEvo" )) then

        local part = vehicle:getPartById("Muffler")
        if (vehicle:getPartById("Muffler"):getCondition() < 70) and (vehicle:getPartById("Muffler"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 70 })

        end
        vehicle:transmitPartModData(Muffler)
    end


end

Events.OnPlayerUpdate.Add(CytMercEvoWindshield);
Events.OnPlayerUpdate.Add(CytMercEvoWindshieldRear);
Events.OnPlayerUpdate.Add(CytMercEvoEngineDoor);
Events.OnPlayerUpdate.Add(CytMercEvoWindowFrontLeft);
Events.OnPlayerUpdate.Add(CytMercEvoWindowFrontRight);
Events.OnPlayerUpdate.Add(CytMercEvoWindowRearRight);
Events.OnPlayerUpdate.Add(CytMercEvoWindowRearLeft);