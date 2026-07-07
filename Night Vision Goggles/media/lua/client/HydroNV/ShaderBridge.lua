local Profiles = require "HydroNV/Profiles"

local ShaderBridge = {
  PHOSPHOR_WHITE = 0.77,
  _activeItemId  = nil,
}

function ShaderBridge:_playerIndex(player)
  if player == nil then
    return 0
  end
  return player:getPlayerNum()
end

function ShaderBridge:_setFloat(channel, value)
  channel:setExterior(value)
  channel:setInterior(value)
  channel:setTargetExterior(value)
  channel:setTargetInterior(value)
end

function ShaderBridge:_resetChannels(idx)
  local searchMode = getSearchMode()
  self:_setFloat(searchMode:getDarkness(idx), 0)
  self:_setFloat(searchMode:getDesat(idx), 0)
  self:_setFloat(searchMode:getBlur(idx), 0)
end

function ShaderBridge:apply(player, item)
  if player == nil or item == nil then
    self:clear(player)
    return
  end

  local itemId = item:getID()
  local profile = Profiles.get(item)
  local searchMode = getSearchMode()
  local idx = self:_playerIndex(player)

  searchMode:setOverride(idx, true)

  local phosphor = profile.phosphor == "white" and self.PHOSPHOR_WHITE or 0.0
  local grain = Profiles.getShaderGrain(item)

  self:_setFloat(searchMode:getDarkness(idx), phosphor)
  self:_setFloat(searchMode:getDesat(idx), grain)
  self._activeItemId = itemId
end

function ShaderBridge:clear(player)
  if player == nil then
    return
  end

  local idx = self:_playerIndex(player)
  local searchMode = getSearchMode()

  self:_resetChannels(idx)
  searchMode:setOverride(idx, false)
  self._activeItemId = nil
end

return ShaderBridge
