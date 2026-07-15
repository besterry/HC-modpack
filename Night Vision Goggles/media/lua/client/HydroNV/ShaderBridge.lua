local Profiles = require "HydroNV/Profiles"

local ShaderBridge = {
  PHOSPHOR_WHITE = 0.77,
  _activeItemId  = nil,
  _overrideOn    = false,
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

function ShaderBridge:_isForagingActive(player)
  if player == nil then
    return false
  end

  if ISSearchManager and ISSearchManager.getManager then
    local manager = ISSearchManager.getManager(player)
    if manager ~= nil and manager.isSearchMode then
      return true
    end
  end

  return false
end

function ShaderBridge:apply(player, item)
  if player == nil or item == nil then
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
  self._overrideOn = true
end

function ShaderBridge:isOverrideOn()
  return self._overrideOn == true
end

function ShaderBridge:clear(player)
  if player == nil or not self._overrideOn then
    return
  end

  local idx = self:_playerIndex(player)
  local searchMode = getSearchMode()

  -- Снимаем только каналы ПНВ (phosphor/grain)
  self:_setFloat(searchMode:getDarkness(idx), 0)
  self:_setFloat(searchMode:getDesat(idx), 0)

  -- При активном собирательстве blur/override не трогаем
  if not self:_isForagingActive(player) then
    self:_setFloat(searchMode:getBlur(idx), 0)
    searchMode:setOverride(idx, false)
  end

  self._activeItemId = nil
  self._overrideOn = false
end

return ShaderBridge
