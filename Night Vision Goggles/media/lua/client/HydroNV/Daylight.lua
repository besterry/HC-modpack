local CONFIG = require "HydroNV/CONFIG"
local Debug  = require "HydroNV/Debug"

local Daylight = {}

Daylight.getStrength = function()
  local climate = getClimateManager()
  if climate == nil then
    return 0
  end
  return climate:getDayLightStrength()
end

Daylight.isTooBrightToTurnOn = function()
  if not CONFIG.BLOCK_DAYLIGHT_NV then
    return false
  end
  return Daylight.getStrength() >= CONFIG.DAYLIGHT_BLOCK_ON
end

Daylight.isTooBrightToKeepOn = function()
  if not CONFIG.BLOCK_DAYLIGHT_NV then
    return false
  end
  return Daylight.getStrength() >= CONFIG.DAYLIGHT_AUTO_OFF
end

return Daylight
