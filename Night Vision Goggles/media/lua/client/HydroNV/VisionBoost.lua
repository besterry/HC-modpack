local Profiles = require "HydroNV/Profiles"

local VisionBoost = {
  _savedViewDist        = nil,
  _savedViewDistMax     = nil,
  _removedShortSighted  = false,
  _activeProfile        = nil,
}

function VisionBoost:_refreshDistance()
  if self._activeProfile == nil then
    return
  end

  getClimateManager():setViewDistance(self._activeProfile.viewDist)
  GameTime:getInstance():setViewDistMax(self._activeProfile.viewDistMax)
end

function VisionBoost:apply(item)
  local player = getPlayer()
  if player == nil then
    return
  end

  local profile = Profiles.get(item)
  local climate = getClimateManager()
  local gameTime = GameTime:getInstance()

  if self._savedViewDist == nil then
    self._savedViewDist = climate:getViewDistance()
  end

  if self._savedViewDistMax == nil then
    self._savedViewDistMax = gameTime:getViewDistMax()
  end

  self._activeProfile = profile
  self:_refreshDistance()

  if profile.coneBoost and player:HasTrait("ShortSighted") then
    player:getTraits():remove("ShortSighted")
    self._removedShortSighted = true
  end
end

function VisionBoost:restore()
  local player = getPlayer()
  if player == nil then
    return
  end

  if self._savedViewDist ~= nil then
    getClimateManager():setViewDistance(self._savedViewDist)
    self._savedViewDist = nil
  end

  if self._savedViewDistMax ~= nil then
    GameTime:getInstance():setViewDistMax(self._savedViewDistMax)
    self._savedViewDistMax = nil
  end

  if self._removedShortSighted then
    player:getTraits():add("ShortSighted")
    self._removedShortSighted = false
  end

  self._activeProfile = nil
end

function VisionBoost:tick()
  if self._activeProfile ~= nil then
    self:_refreshDistance()
  end
end

return VisionBoost
