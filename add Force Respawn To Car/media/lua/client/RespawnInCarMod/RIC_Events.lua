---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function RIC.ToggleEscapeMenuForSave(key)
    local player = getPlayer()
    if not player or player:isDead() then return end
    local mainMenuKey = getCore():getKey("Main Menu")
    if (key == mainMenuKey) or (mainMenuKey == 0 and key == Keyboard.KEY_ESCAPE) then--or key == getCore():getKey("StartVehicleEngine") then
        local vehicle = player:getVehicle()
        if vehicle and vehicle:isDriver(player) then 
            RIC.SaveVehicle(player,vehicle) 
        end
    end
end
Events.OnKeyPressed.Add(RIC.ToggleEscapeMenuForSave)
-----------------------------------------------------------------
function RIC.OnEnterVehicle() RIC.CarEnter() end
Events.OnEnterVehicle.Add(RIC.OnEnterVehicle)
-----------------------------------------------------------------
function RIC.OnExitVehicle() RIC.CarExit() end
Events.OnExitVehicle.Add(RIC.OnExitVehicle)
-----------------------------------------------------------------
function RIC.OnPlayerDeath() RIC.CarExit(true) end
Events.OnPlayerDeath.Add(RIC.OnPlayerDeath)
-----------------------------------------------------------------
function RIC.OnSwitchVehicleSeat() RIC.SwitchVehicleSeat() end
Events.OnSwitchVehicleSeat.Add(RIC.OnSwitchVehicleSeat)
-----------------------------------------------------------------
function RIC.OnCreatePlayer() RIC.CreatePlayer() end
Events.OnCreatePlayer.Add(RIC.OnCreatePlayer)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return RIC