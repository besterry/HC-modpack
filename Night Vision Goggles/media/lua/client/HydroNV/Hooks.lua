local Control   = require "HydroNV/Control"
local CONFIG    = require "HydroNV/CONFIG"
local Inventory = require "HydroNV/Inventory"
local ItemUtil  = require "HydroNV/ItemUtil"

local Hooks = {
  unequipPerform      = nil,
  equipPerform        = nil,
  extraUnequipPerform = nil,
}

local function shouldTurnOffForBodyLocation(bodyLocation)
  if not Control:isOn() then
    return false
  end

  local activeItem = Control:getActiveItem()
  return activeItem ~= nil and activeItem:getBodyLocation() == bodyLocation
end

local function unequipItemSync(player, item)
  if player == nil or item == nil or not item:isEquipped() then
    return
  end

  local action = ISUnequipAction:new(player, item, 1)
  if action:isValid() then
    action:perform()
  end
end

local function unequipOtherNightVision(player, keepItem)
  if player == nil or keepItem == nil then
    return
  end

  local removeList = {}
  Inventory.overWornItems(player, function(item)
    if item ~= keepItem and item:hasTag(CONFIG.ITEM_TAG) then
      table.insert(removeList, item)
    end
  end)

  for i = 1, #removeList do
    unequipItemSync(player, removeList[i])
  end
end

function Hooks.install()
  if Hooks.unequipPerform ~= nil then
    return
  end

  Hooks.unequipPerform      = ISUnequipAction.perform
  Hooks.equipPerform        = ISWearClothing.perform
  Hooks.extraUnequipPerform = ISClothingExtraAction.perform

  ISClothingExtraAction.perform = function(self)
    if shouldTurnOffForBodyLocation(self.item:getBodyLocation()) then
      Control:turnOff(false)
    end
    Hooks.extraUnequipPerform(self)
    if self.character ~= nil and self.item ~= nil then
      local keep = self.character:getWornItem(self.item:getBodyLocation())
      if keep ~= nil and keep:hasTag(CONFIG.ITEM_TAG) then
        unequipOtherNightVision(self.character, keep)
      end
    end
    Control:syncActiveItem()
  end

  ISWearClothing.perform = function(self)
    if shouldTurnOffForBodyLocation(self.item:getBodyLocation()) then
      Control:turnOff(false)
    end
    Hooks.equipPerform(self)
    if self.character ~= nil and self.item ~= nil and self.item:isEquipped() and self.item:hasTag(CONFIG.ITEM_TAG) then
      unequipOtherNightVision(self.character, self.item)
    end
    Control:syncActiveItem()
  end

  ISUnequipAction.perform = function(self)
    if ItemUtil.isNightVisionItem(self.item) and Control:isActiveItem(self.item) then
      Control:turnOff(false)
    end
    Hooks.unequipPerform(self)
    Control:syncActiveItem()
  end
end

return Hooks
