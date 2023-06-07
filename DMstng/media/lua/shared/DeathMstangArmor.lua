---
--- Created by cytt0rak
---  WIP

function DeathMstangWindshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

local part = vehicle:getPartById("Windshield")
local parttwo = vehicle:getPartById("WindshieldRear")
        if (vehicle:getPartById("Windshield"):getCondition() < 62) and (vehicle:getPartById("WindshieldRear"):getCondition() > 10) and (vehicle:getPartById("WindshieldRear"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = parttwo:getId(), condition = parttwo:getCondition()-1 })

        end
        vehicle:transmitPartModData(Windshield)
        vehicle:transmitPartModData(WindshieldRear)
    end


end

function DeathMstangEngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

local part = vehicle:getPartById("EngineDoor")
local parttwo = vehicle:getPartById("Windshield")
        if (vehicle:getPartById("EngineDoor"):getCondition() < 62) and (vehicle:getPartById("Windshield"):getCondition() > 10) and (vehicle:getPartById("Windshield"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = parttwo:getId(), condition = parttwo:getCondition()-1 })
        end
        vehicle:transmitPartModData(EngineDoor)
        vehicle:transmitPartModData(Windshield)
    end


end

function DeathMstangGasTank(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("GasTank")
        if (vehicle:getPartById("GasTank"):getCondition() < 70) and (vehicle:getPartById("GasTank"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })

        end
        vehicle:transmitPartModData(GasTank)
    end


end

function DeathMstangWindowFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("WindowFrontLeft")
        local parttwo = vehicle:getPartById("DoorFrontLeft")
        if (vehicle:getPartById("DoorFrontLeft"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 62) and (vehicle:getPartById("DoorFrontLeft"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = parttwo:getId(), condition = parttwo:getCondition()-1 })

        end
        vehicle:transmitPartModData(WindowFrontLeft)
        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function DeathMstangWindowFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("WindowFrontRight")
        local parttwo = vehicle:getPartById("DoorFrontRight")
        if (vehicle:getPartById("DoorFrontRight"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 62) and (vehicle:getPartById("DoorFrontRight"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = parttwo:getId(), condition = parttwo:getCondition()-1 })

        end
        vehicle:transmitPartModData(WindowFrontRight)
        vehicle:transmitPartModData(DoorFrontRight)
    end


end


function DeathMstangWindowRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("WindowRearLeft")
        if (vehicle:getPartById("WindowRearLeft"):getCondition() < 70) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })

        end
        vehicle:transmitPartModData(WindowRearLeft)
    end


end

function DeathMstangWindowRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("WindowRearRight")
        if (vehicle:getPartById("WindowRearRight"):getCondition() < 70) then


            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })

        end
        vehicle:transmitPartModData(WindowRearRight)
    end


end

function DeathMstangMuffler(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("Muffler")
        if (vehicle:getPartById("Muffler"):getCondition() < 5) and (vehicle:getPartById("Muffler"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 10 })

        end
        vehicle:transmitPartModData(Muffler)
    end


end

function DeathMstangTireFrontLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("TireFrontLeft")
        if (vehicle:getPartById("TireFrontLeft"):getCondition() < 20) and (vehicle:getPartById("TireFrontLeft"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 30 })

        end
        vehicle:transmitPartModData(TireFrontLeft)
    end


end

function DeathMstangTireFrontRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("TireFrontRight")
        if (vehicle:getPartById("TireFrontRight"):getCondition() < 20) and (vehicle:getPartById("TireFrontRight"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 30 })

        end
        vehicle:transmitPartModData(TireFrontRight)
    end


end

function DeathMstangTireRearLeft(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("TireRearLeft")
        if (vehicle:getPartById("TireRearLeft"):getCondition() < 20) and (vehicle:getPartById("TireRearLeft"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 30 })

        end
        vehicle:transmitPartModData(TireRearLeft)
    end


end

function DeathMstangTireRearRight(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "DeathMstang" )) then

        local part = vehicle:getPartById("TireRearRight")
        if (vehicle:getPartById("TireRearRight"):getCondition() < 20) and (vehicle:getPartById("TireRearRight"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 30 })

        end
        vehicle:transmitPartModData(TireRearRight)
    end


end

Events.OnPlayerUpdate.Add(DeathMstangWindshield);
Events.OnPlayerUpdate.Add(DeathMstangGasTank);
Events.OnPlayerUpdate.Add(DeathMstangEngineDoor);
Events.OnPlayerUpdate.Add(DeathMstangWindowFrontLeft);
Events.OnPlayerUpdate.Add(DeathMstangWindowFrontRight);
Events.OnPlayerUpdate.Add(DeathMstangWindowRearRight);
Events.OnPlayerUpdate.Add(DeathMstangWindowRearLeft);
Events.OnPlayerUpdate.Add(DeathMstangMuffler);
Events.OnPlayerUpdate.Add(DeathMstangTireFrontLeft);
Events.OnPlayerUpdate.Add(DeathMstangTireFrontRight);
Events.OnPlayerUpdate.Add(DeathMstangTireRearLeft);
Events.OnPlayerUpdate.Add(DeathMstangTireRearRight);