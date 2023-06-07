--- In this file we add a new context menu option to the vehicle mechanics menu.
--- To do this we override the ISVehicleMechanics.doPartContextMenu function.
--- We also add a new function to handle the context menu option.
--- The context menu option is only available to admins or if the cheat mode is enabled.
--- The context menu option will set the odometer value to the value entered by the user.
--- The context menu option will only be available if the vehicle has an engine part.

local _ISVehicleMechanics_doPartContextMenu = ISVehicleMechanics.doPartContextMenu
function ISVehicleMechanics:doPartContextMenu(part, x,y)
    _ISVehicleMechanics_doPartContextMenu(self, part, x, y)

    local player = getSpecificPlayer(self.playerNum)
    if ISVehicleMechanics.cheat or player:getAccessLevel() ~= "None" then
        self.context:addOption("CHEAT: Set Odometer in KM", player, ISVehicleMechanics.onCheatSetOdometer, self.vehicle)
    end
end

---@param button ISButton
---@param playerObj IsoPlayer
---@param vehicle BaseVehicle
function ISVehicleMechanics.onCheatSetOdometerAux(target, button, playerObj, vehicle)
	if button.internal ~= "OK" then return end
	local text = button.parent.entry:getText()
	local odometer = tonumber(text)
	if not odometer then return end
	odometer = math.max(odometer, 0)
	odometer = math.min(odometer, 999999)
    MileageExpansionAPI.setVehicleOdometerValue(vehicle, odometer, nil, true)
end

---@param playerObj IsoPlayer
---@param vehicle BaseVehicle
function ISVehicleMechanics.onCheatSetOdometer(playerObj, vehicle)
	local modal = ISTextBox:new(0, 0, 280, 180, "Odometer (KM):", tostring(MileageExpansionAPI.getVehicleOdometerValue(vehicle)),
		nil, ISVehicleMechanics.onCheatSetOdometerAux, playerObj:getPlayerNum(), playerObj, vehicle)
	modal:initialise()
	modal:addToUIManager()
end
