-- Перехватываем функцию ISVehicleMechanics.onCheatRemoveAux
local originalOnCheatRemoveAux = ISVehicleMechanics.onCheatRemoveAux
function ISVehicleMechanics.onCheatRemoveAux(dummy, button, playerObj, vehicle)
    if button.internal == "NO" then return end
    
    if playerObj:getAccessLevel() ~= "Admin" then
        return
    end
    
    if isClient() then
        sendClientCommand(playerObj, "vehicle", "remove", { vehicle = vehicle:getId() })
    else
        vehicle:permanentlyRemove()
    end
end