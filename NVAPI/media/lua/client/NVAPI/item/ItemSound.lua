local module = {}

function module:new()

	local o = {}
  setmetatable(o, self)
  self.__index = self

  return o

end

function module:playRecharged()

  getPlayer():getEmitter():playSound("nv-recharged")

end

function module:playTurnOn()

  getPlayer():getEmitter():playSound("nv-turnon")

end

function module:playTurnOff()

  getPlayer():getEmitter():playSound("nv-turnoff")

end

function module:playToggleFail()

  getPlayer():getEmitter():playSound("nv-toggle-fail")

end

function module:playLowBattery()

  getPlayer():getEmitter():playSound("nv-low-battery")

end

function module:playDepleted()

  getPlayer():getEmitter():playSound("nv-depleted")

end

function module:playBroken()

  getPlayer():getEmitter():playSound("nv-broken")

end

function module:playBreak()

  getPlayer():getEmitter():playSound("nv-break")

end

function module:playRepairFail()

  getPlayer():getEmitter():playSound("nv-repair-fail")

end

return module:new()
