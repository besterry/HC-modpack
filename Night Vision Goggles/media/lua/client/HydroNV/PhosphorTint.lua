local Profiles      = require "HydroNV/Profiles"
local PhosphorState = require "HydroNV/PhosphorState"

local PhosphorTint = {
  _whiteTex = nil,
  _coolTex  = nil,
}

function PhosphorTint:_getWhiteTex()
  if self._whiteTex == nil then
    self._whiteTex = getTexture("media/textures/weather/fogwhite.png")
  end
  return self._whiteTex
end

function PhosphorTint:_getCoolTex()
  if self._coolTex == nil then
    self._coolTex = getTexture("media/textures/overlay-noiseless.png")
  end
  return self._coolTex
end

function PhosphorTint._draw()
  if not PhosphorState:isWhite() then
    return
  end

  local w = getPlayerScreenWidth(0)
  local h = getPlayerScreenHeight(0)
  local whiteTex = PhosphorTint:_getWhiteTex()
  local coolTex = PhosphorTint:_getCoolTex()

  if whiteTex ~= nil then
    UIManager.DrawTexture(whiteTex, 0, 0, w, h, 0.20)
  end

  if coolTex ~= nil then
    UIManager.DrawTexture(coolTex, 0, 0, w, h, 0.08)
  end
end

function PhosphorTint:enable(item)
  PhosphorState:setFromItem(item)

  if not PhosphorState:isWhite() then
    return
  end

  Events.OnPreUIDraw.Add(self._draw)
end

function PhosphorTint:disable()
  PhosphorState:clear()
  self._whiteTex = nil
  self._coolTex = nil
  Events.OnPreUIDraw.Remove(self._draw)
end

return PhosphorTint
