local CONFIG   = require "HydroNV/CONFIG"
local Profiles = require "HydroNV/Profiles"

local GrainOverlay = {
  _grainAmount       = 0,
  _grainExtra        = 0,
  _grainCoarseOffset = 0,
  _texturePath       = nil,
  _extraTexturePath  = nil,
  _texture           = nil,
  _extraTexture      = nil,
}

function GrainOverlay:_resolveTexture(path, cacheKey)
  if path == nil then
    return nil
  end

  if cacheKey == "extra" then
    if self._extraTexture ~= nil and self._extraTexturePath == path then
      return self._extraTexture
    end
    self._extraTexturePath = path
    self._extraTexture = getTexture(path)
    return self._extraTexture
  end

  if self._texture ~= nil and self._texturePath == path then
    return self._texture
  end

  self._texturePath = path
  self._texture = getTexture(path)
  return self._texture
end

function GrainOverlay:_drawLayer(tex, x, y, w, h, alpha)
  if tex ~= nil and alpha > 0 then
    UIManager.DrawTexture(tex, x, y, w, h, alpha)
  end
end

function GrainOverlay._draw()
  local self = GrainOverlay
  if self._grainAmount <= 0 or self._texturePath == nil then
    return
  end

  local tex = self:_resolveTexture(self._texturePath, "main")
  if tex == nil then
    return
  end

  local w = getPlayerScreenWidth(0)
  local h = getPlayerScreenHeight(0)

  self:_drawLayer(tex, 0, 0, w, h, self._grainAmount)

  if self._grainCoarseOffset > 0 then
    self:_drawLayer(tex, w * 0.11, h * 0.06, w, h, self._grainCoarseOffset)
  end

  if self._grainExtra > 0 and self._extraTexturePath ~= nil then
    local extraTex = self:_resolveTexture(self._extraTexturePath, "extra")
    self:_drawLayer(extraTex, 0, 0, w, h, self._grainExtra)
  end
end

function GrainOverlay:enable(item)
  local profile = Profiles.get(item)
  local scale = CONFIG.GRAIN_OVERLAY_SCALE or 1.0

  self._grainAmount = (profile.grain or 0.26) * scale
  self._grainExtra = (profile.grainExtra or 0) * scale
  self._grainCoarseOffset = (profile.grainCoarseOffset or 0) * scale
  self._texturePath = Profiles.getGrainTexture(item)
  self._extraTexturePath = Profiles.getGrainTextureByKey(profile.grainExtraTex)
  self._texture = nil
  self._extraTexture = nil

  Events.OnPreUIDraw.Add(self._draw)
end

function GrainOverlay:disable()
  self._grainAmount = 0
  self._grainExtra = 0
  self._grainCoarseOffset = 0
  self._texturePath = nil
  self._extraTexturePath = nil
  self._texture = nil
  self._extraTexture = nil
  Events.OnPreUIDraw.Remove(self._draw)
end

return GrainOverlay
