local CONFIG      = require "HydroNV/CONFIG"
local Daylight    = require "HydroNV/Daylight"
local Inventory   = require "HydroNV/Inventory"
local ItemUtil    = require "HydroNV/ItemUtil"
local Profiles    = require "HydroNV/Profiles"
local VisionBoost  = require "HydroNV/VisionBoost"
local ShaderBridge = require "HydroNV/ShaderBridge"
local Sound        = require "NVAPI/item/ItemSound"

local Control = {
  _activeItem = nil,
}

function Control:isOn()
  local player = getPlayer()
  return player ~= nil and player:isWearingNightVisionGoggles()
end

function Control:getActiveItem()
  return self._activeItem
end

function Control:isActiveItem(item)
  return self._activeItem ~= nil and self._activeItem == item
end

function Control:_itemStillEquipped()
  if self._activeItem == nil then
    return false
  end

  local found = false
  Inventory.overWornItems(getPlayer(), function(item)
    if item == self._activeItem then
      found = true
    end
  end)

  return found
end

function Control:_pickBestItem(items)
  if #items == 0 then
    return nil
  end

  local best = items[1]
  for i = 2, #items do
    local candidate = items[i]
    local bestBroken = ItemUtil.isBroken(best)
    local candidateBroken = ItemUtil.isBroken(candidate)
    local bestCharge = ItemUtil.getCharge(best)
    local candidateCharge = ItemUtil.getCharge(candidate)

    if not candidateBroken and (bestBroken or candidateCharge > bestCharge) then
      best = candidate
    end
  end

  return best
end

function Control:_startDrain()
  if self._drainTick ~= nil then
    return
  end

  self._drainTick = function()
    self:_onDrainTick()
  end

  Events.EveryOneMinute.Add(self._drainTick)
end

function Control:_stopDrain()
  if self._drainTick == nil then
    return
  end

  Events.EveryOneMinute.Remove(self._drainTick)
  self._drainTick = nil
end

function Control:_onDrainTick()
  if not self:isOn() then
    self:_stopDrain()
    return
  end

  if Daylight.isTooBrightToKeepOn() then
    Sound:playToggleFail()
    self:turnOff(false)
    return
  end

  if not self:_itemStillEquipped() then
    self:turnOff(false)
    return
  end

  if ItemUtil.isBroken(self._activeItem) then
    Sound:playBroken()
    self:turnOff(false)
    return
  end

  ItemUtil.drain(self._activeItem, Profiles.getDrainRate(self._activeItem))

  if ItemUtil.isDepleted(self._activeItem) then
    Sound:playDepleted()
    self:turnOff(false)
  end
end

function Control:syncActiveItem()
  local player = getPlayer()
  if player == nil then
    if self:isOn() or self._activeItem ~= nil then
      self:turnOff(false)
    end
    return
  end

  -- ПНВ выключен: SearchMode не трогаем (иначе сбивается собирательство)
  if not self:isOn() then
    if self._activeItem ~= nil then
      self._activeItem = nil
      VisionBoost:restore()
      self:_stopDrain()
    end
    return
  end

  local worn = Inventory.findAllWornNightVisionItems(player)
  if #worn == 0 or not self:_itemStillEquipped() then
    self:turnOff(false)
    return
  end

  local best = self:_pickBestItem(worn)
  if best ~= self._activeItem then
    self._activeItem = best
    VisionBoost:apply(best)
  end

  ShaderBridge:apply(player, self._activeItem)
end

function Control:turnOn(item)
  local player = getPlayer()
  if player == nil or item == nil then
    return false
  end

  if ItemUtil.isDepleted(item) then
    Sound:playToggleFail()
    return false
  end

  if ItemUtil.isBroken(item) then
    Sound:playBroken()
    return false
  end

  if not ItemUtil.canActivateNv(item) then
    Sound:playToggleFail()
    return false
  end

  if Daylight.isTooBrightToTurnOn() then
    Sound:playToggleFail()
    return false
  end

  if self:isOn() and self._activeItem == item then
    ShaderBridge:apply(player, item)
    return true
  end

  self._activeItem = item
  player:setWearingNightVisionGoggles(true)
  VisionBoost:apply(item)
  ShaderBridge:apply(player, item)
  Sound:playTurnOn()
  self:_startDrain()
  return true
end

function Control:turnOff(playSound)
  if playSound == nil then
    playSound = true
  end

  local player = getPlayer()
  local wasOn = self:isOn()

  if player == nil then
    self._activeItem = nil
    self:_stopDrain()
    return
  end

  if wasOn and playSound then
    Sound:playTurnOff()
  end

  player:setWearingNightVisionGoggles(false)

  -- Сбрасываем только свой эффект ПНВ, и только если он был включён
  if wasOn then
    ShaderBridge:clear(player)
    VisionBoost:restore()
  end

  self._activeItem = nil
  self:_stopDrain()
end

function Control:toggle()
  if self:isOn() then
    self:turnOff()
    return
  end

  local player = getPlayer()
  if player == nil then
    return
  end

  local item = self:_pickBestItem(Inventory.findAllWornNightVisionItems(player))
  if item == nil then
    return
  end

  self:turnOn(item)
end

function Control:clear()
  self:turnOff(false)
end

return Control
