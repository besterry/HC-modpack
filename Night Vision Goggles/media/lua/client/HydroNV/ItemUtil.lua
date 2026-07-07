local CONFIG         = require "HydroNV/CONFIG"
local ItemNightVision = require "NVAPI/item/ItemNightVision"

local ItemUtil = {}

ItemUtil.wrap = function(item)
  return ItemNightVision.wrap(item)
end

ItemUtil.isNightVisionItem = function(item)
  return item ~= nil and item:hasTag(CONFIG.ITEM_TAG)
end

ItemUtil.canActivateNv = function(item)
  return ItemUtil.isNightVisionItem(item)
end

ItemUtil.isNvDisplayItem = function(item)
  if item == nil then
    return false
  end
  local Profiles = require "HydroNV/Profiles"
  return ItemUtil.canActivateNv(item) or Profiles.isOffVariant(item)
end

ItemUtil.isBroken = function(item)
  return item:getCondition() == 0
end

ItemUtil.getCharge = function(item)
  local modData = item:getModData()
  local charge = modData[CONFIG.CHARGE_KEY]
  if charge == nil then
    charge = 1
    modData[CONFIG.CHARGE_KEY] = charge
  end
  return charge
end

ItemUtil.isDepleted = function(item)
  return ItemUtil.getCharge(item) == 0
end

ItemUtil.drain = function(item, amount)
  local modData = item:getModData()
  modData[CONFIG.CHARGE_KEY] = math.max(0, ItemUtil.getCharge(item) - amount)
end

return ItemUtil
