local CONFIG = require "HydroNV/CONFIG"

local Debug = {
  sessionOverride = nil,
}

function Debug:isDaylightChecksEnabled()
  if not CONFIG.BLOCK_DAYLIGHT_NV then
    return false
  end

  if self.sessionOverride ~= nil then
    return not self.sessionOverride
  end

  return true
end

function Debug:toggleSessionTest()
  if not CONFIG.BLOCK_DAYLIGHT_NV then
    self:notify("HydroNV: дневная блокировка отключена (CONFIG)")
    return
  end

  if self.sessionOverride == nil then
    self.sessionOverride = true
  else
    self.sessionOverride = not self.sessionOverride
  end

  if self.sessionOverride then
    self:notify("HydroNV: тест днём ВКЛ")
  else
    self:notify("HydroNV: тест днём ВЫКЛ")
  end
end

function Debug:notify(text)
  local player = getPlayer()
  if player == nil then
    return
  end

  if HaloTextHelper and HaloTextHelper.addTextWithArrow then
    HaloTextHelper.addTextWithArrow(player, text, true, HaloTextHelper.getColorGreen())
  else
    player:Say(text)
  end
end

function Debug:notifyStartupState()
end

return Debug
