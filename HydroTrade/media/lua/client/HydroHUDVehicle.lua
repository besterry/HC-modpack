HydroHUDVehicle = HydroHUDVehicle or {}

function HydroHUDVehicle.isBicycle(vehicle)
  if not vehicle then
    return false
  end
  if BravensBikeUtils and BravensBikeUtils.isBike then
    return BravensBikeUtils.isBike(vehicle)
  end
  local scriptName = vehicle:getScriptName()
  return scriptName ~= nil and string.find(scriptName, "Bicycle", 1, true) ~= nil
end

function HydroHUDVehicle.shouldHideInVehicle(playerNum, character)
  local vehicle = character and character:getVehicle()
  if not vehicle then
    return false
  end
  if HydroHUDVehicle.isBicycle(vehicle) then
    return false
  end
  local dashboard = getPlayerVehicleDashboard(playerNum)
  if dashboard and dashboard.vehicle ~= nil and dashboard:isVisible() then
    return true
  end
  return false
end

return HydroHUDVehicle
