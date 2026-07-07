local CONFIG   = require "HydroNV/CONFIG"
local ItemUtil = require "HydroNV/ItemUtil"
local Profiles = require "HydroNV/Profiles"

local Inventory = {}

Inventory.overWornItems = function(player, callback)
  if player == nil or callback == nil then
    return
  end

  local items = player:getWornItems()
  if items == nil then
    return
  end

  for i = 0, items:size() - 1 do
    local worn = items:get(i)
    if worn ~= nil then
      local item = worn:getItem()
      if item ~= nil then
        callback(item)
      end
    end
  end
end

Inventory.findAllWornNightVisionItems = function(player)
  local list = {}
  Inventory.overWornItems(player, function(item)
    if ItemUtil.canActivateNv(item) then
      table.insert(list, item)
    end
  end)
  return list
end

Inventory.findWornNvDisplayItem = function(player)
  local found = nil
  Inventory.overWornItems(player, function(item)
    if Profiles.isNvBodySlot(item:getBodyLocation()) and ItemUtil.isNvDisplayItem(item) then
      found = item
    end
  end)
  return found
end

return Inventory
