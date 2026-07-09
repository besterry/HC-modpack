HydroHUDVehicle = HydroHUDVehicle or {}

local VEHICLE_SLOT_GAP = 6
local VEHICLE_DASHBOARD_GAP = 8

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

function HydroHUDVehicle.getDashboard(playerNum)
  local dashboard = getPlayerVehicleDashboard(playerNum)
  if dashboard and dashboard.vehicle ~= nil and dashboard:isVisible() then
    return dashboard
  end
  return nil
end

function HydroHUDVehicle.isVehicleGearHudMode(playerNum, character)
  local vehicle = character and character:getVehicle()
  if not vehicle then
    return false
  end
  if HydroHUDVehicle.isBicycle(vehicle) then
    return false
  end
  return HydroHUDVehicle.getDashboard(playerNum) ~= nil
end

function HydroHUDVehicle.shouldHideInVehicle(playerNum, character)
  return HydroHUDVehicle.isVehicleGearHudMode(playerNum, character)
end

function HydroHUDVehicle.syncStandardSlotMetrics(playerNum, slot)
  if not slot or not slot.syncHotbarMetrics then
    return
  end
  local hotbar = getPlayerHotbar(playerNum)
  if hotbar then
    slot:syncHotbarMetrics(hotbar)
  end
end

function HydroHUDVehicle.layoutGearHudSlots(playerNum)
  local dashboard = HydroHUDVehicle.getDashboard(playerNum)
  if not dashboard then
    return
  end

  local nvSlot = HydroNVChargeHUD and HydroNVChargeHUD.getSlot and HydroNVChargeHUD.getSlot(playerNum)
  local maskSlot = TZoneMaskFilterHUD and TZoneMaskFilterHUD.getSlot and TZoneMaskFilterHUD.getSlot(playerNum)

  local slots = {}
  if nvSlot and nvSlot:isVisible() then
    table.insert(slots, nvSlot)
  end
  if maskSlot and maskSlot:isVisible() then
    table.insert(slots, maskSlot)
  end
  if #slots == 0 then
    return
  end

  local totalW = 0
  for i, slot in ipairs(slots) do
    if i > 1 then
      totalW = totalW + VEHICLE_SLOT_GAP
    end
    totalW = totalW + slot:getWidth()
  end

  local startX = dashboard:getX() - totalW - VEHICLE_DASHBOARD_GAP
  local bottomY = dashboard:getY() + dashboard:getHeight()
  local x = startX
  for _, slot in ipairs(slots) do
    slot:setX(x)
    slot:setY(bottomY - slot:getHeight())
    x = x + slot:getWidth() + VEHICLE_SLOT_GAP
  end
end

function HydroHUDVehicle.layoutConsumableHotbar(playerNum, hotbar)
  local dashboard = HydroHUDVehicle.getDashboard(playerNum)
  if not dashboard or not hotbar then
    return false
  end

  local x = dashboard:getX() + dashboard:getWidth() + VEHICLE_DASHBOARD_GAP
  local y = dashboard:getY() + dashboard:getHeight() + VEHICLE_DASHBOARD_GAP

  local screenLeft = getPlayerScreenLeft(playerNum)
  local screenTop = getPlayerScreenTop(playerNum)
  local screenRight = screenLeft + getPlayerScreenWidth(playerNum)
  local screenBottom = screenTop + getPlayerScreenHeight(playerNum)

  if x + hotbar:getWidth() > screenRight - 4 then
    x = screenRight - hotbar:getWidth() - 4
  end
  if y + hotbar:getHeight() > screenBottom - 4 then
    y = screenBottom - hotbar:getHeight() - 4
  end

  hotbar:setX(x)
  hotbar:setY(y)
  return true
end

return HydroHUDVehicle
