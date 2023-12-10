---
--- Created by cytt0rak
---  WIP

---function ekipmankaydi(player)
---    local vehicle = player.getVehicle and player:getVehicle() or nil
---    if (vehicle and string.find( vehicle:getScriptName(), "XM93Woodland" )) then
---        for i, partId in ipairs(a)
---        ("Windshield", "WindowFrontRight", "WindowFrontLeft", "DoorFrontRight", "DoorFrontLeft", "EngineDoor", "Engine")
---        do
---            c = part:getCondition()
---        end
---    end
---end

---function ekipmankaydi(player, vehicle, args, part)
---    vehicle = player.getVehicle and player:getVehicle() or nil
---    if (vehicle and string.find( vehicle:getScriptName(), "XM93Woodland" )) then
---
---        c = vehicle:getPartById("WindowFrontLeft"):getCondition();
---
---
---    end
---end



function FJ75Windshield(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then



---        if part:getCondition() > 20 then
---            vehicle:getPartById("WindowFrontLeft"):setCondition(c)
    local part = vehicle:getPartById("Windshield")

        if (vehicle:getPartById("FJ75PCArmorWindshield"):getCondition() > 1) and (vehicle:getPartById("Windshield"):getCondition() < 70) and (vehicle:getPartById("FJ75PCArmorWindshield"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCArmorWindshield"):setCondition(vehicle:getPartById("FJ75PCArmorWindshield"):getCondition()-1)

---    vehicle:transmitPartCondition(FJ75PCArmorWindshield)
---    vehicle:getPartById("Windshield"):setCondition(100)
---    vehicle:transmitPartCondition(Windshield)
    end
        vehicle:transmitPartModData(Windshield)
    end


end

function FJ75EngineDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then

---        if part:getCondition() > 20 then
---            vehicle:getPartById("WindowFrontLeft"):setCondition(c)
local part = vehicle:getPartById("EngineDoor")
        if (vehicle:getPartById("FJ75PCBodyArmor"):getCondition() > 1) and (vehicle:getPartById("EngineDoor"):getCondition() < 70) and (vehicle:getPartById("FJ75PCBodyArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCBodyArmor"):setCondition(vehicle:getPartById("FJ75PCBodyArmor"):getCondition()-1)

---    vehicle:transmitPartCondition(FJ75PCBodyArmor)
---    vehicle:getPartById("EngineDoor"):setCondition(100)
---    vehicle:transmitPartCondition(EngineDoor)

        end
        vehicle:transmitPartModData(EngineDoor)
    end


end

function FJ75LeftDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then

---        if part:getCondition() > 20 then
---            vehicle:getPartById("WindowFrontLeft"):setCondition(c)
local part = vehicle:getPartById("DoorFrontLeft")
        if (vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontLeft"):getCondition() < 70) and (vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):setCondition(vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getCondition()-1)

---    vehicle:transmitPartCondition(FJ75PCFrontLeftDoorArmor)
---    vehicle:getPartById("WindowFrontLeft"):setCondition(100)
---    vehicle:getPartById("DoorFrontLeft"):setCondition(100)
---    vehicle:transmitPartCondition(WindowFrontLeft)
---    vehicle:transmitPartCondition(DoorFrontLeft)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function FJ75RightDoor(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then

---        if part:getCondition() > 20 then
---            vehicle:getPartById("WindowFrontRight"):setCondition(c)
local part = vehicle:getPartById("DoorFrontRight")
        if (vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getCondition() > 1) and (vehicle:getPartById("DoorFrontRight"):getCondition() < 70) and (vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCFrontRightDoorArmor"):setCondition(vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getCondition()-1)

---    vehicle:transmitPartCondition(FJ75PCFrontRightDoorArmor)
---    vehicle:getPartById("WindowFrontRight"):setCondition(100)
---    vehicle:getPartById("DoorFrontRight"):setCondition(100)
---    vehicle:transmitPartCondition(WindowFrontRight)
---    vehicle:transmitPartCondition(DoorFrontRight)

        end
        vehicle:transmitPartModData(WindowFrontRight)
        vehicle:transmitPartModData(DoorFrontRight)
    end


end

function FJ75LeftWindow(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then

        ---        if part:getCondition() > 20 then
        ---            vehicle:getPartById("WindowFrontRight"):setCondition(c)
        local part = vehicle:getPartById("WindowFrontLeft")
        if (vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontLeft"):getCondition() < 70) and (vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):setCondition(vehicle:getPartById("FJ75PCFrontLeftDoorArmor"):getCondition()-1)

            ---    vehicle:transmitPartCondition(FJ75PCFrontRightDoorArmor)
            ---    vehicle:getPartById("WindowFrontRight"):setCondition(100)
            ---    vehicle:getPartById("DoorFrontRight"):setCondition(100)
            ---    vehicle:transmitPartCondition(WindowFrontRight)
            ---    vehicle:transmitPartCondition(DoorFrontRight)

        end
        vehicle:transmitPartModData(WindowFrontLeft)
        vehicle:transmitPartModData(DoorFrontLeft)
    end


end

function FJ75RightWindow(player, part, elapsedMinutes)
    local vehicle = player:getVehicle()
    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then

        ---        if part:getCondition() > 20 then
        ---            vehicle:getPartById("WindowFrontRight"):setCondition(c)
        local part = vehicle:getPartById("WindowFrontRight")
        if (vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getCondition() > 1) and (vehicle:getPartById("WindowFrontRight"):getCondition() < 70) and (vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getInventoryItem()) then

            sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = 100 })
            vehicle:getPartById("FJ75PCFrontRightDoorArmor"):setCondition(vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getCondition()-1)

            ---    vehicle:transmitPartCondition(FJ75PCFrontRightDoorArmor)
            ---    vehicle:getPartById("WindowFrontRight"):setCondition(100)
            ---    vehicle:getPartById("DoorFrontRight"):setCondition(100)
            ---    vehicle:transmitPartCondition(WindowFrontRight)
            ---    vehicle:transmitPartCondition(DoorFrontRight)

        end
        vehicle:transmitPartModData(WindowFrontRight)
        vehicle:transmitPartModData(DoorFrontRight)
    end


end

---function FJ75DoorCheck(player, part)
---    local vehicle = player:getVehicle()
---    if (vehicle and string.find( vehicle:getScriptName(), "FJ75PC" )) then
---        if (vehicle:getPartById("FJ75PCFrontRightDoorArmor"):getCondition() < 40) then
---            player:Say("Front right door armor is waning")
---
---        end
---    end
---end

---Events.OnEnterVehicle.Add(ekipmankaydi)
Events.OnPlayerUpdate.Add(FJ75Windshield);
Events.OnPlayerUpdate.Add(FJ75EngineDoor);
Events.OnPlayerUpdate.Add(FJ75LeftDoor);
Events.OnPlayerUpdate.Add(FJ75RightDoor);
Events.OnPlayerUpdate.Add(FJ75LeftWindow);
Events.OnPlayerUpdate.Add(FJ75RightWindow);
---Events.OnPlayerUpdate.Add(FJ75DoorCheck);