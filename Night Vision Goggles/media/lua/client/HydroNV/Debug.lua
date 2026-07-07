local CONFIG = require "HydroNV/CONFIG"

local Debug = {
  sessionOverride = nil,
}

function Debug:isDaylightChecksEnabled()
  if CONFIG.ALLOW_DAYTIME_TEST then
    return false
  end

  if self.sessionOverride ~= nil then
    return not self.sessionOverride
  end

  return true
end

function Debug:toggleSessionTest()
  if CONFIG.ALLOW_DAYTIME_TEST then
    self:notify("HydroNV: тест днём уже включён в CONFIG")
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
  if not CONFIG.ALLOW_DAYTIME_TEST then
    return
  end

  self:notify("HydroNV: тест днём активен (CONFIG)")
end

return Debug
