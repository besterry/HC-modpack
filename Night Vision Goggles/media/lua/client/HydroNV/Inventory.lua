local CONFIG = require "HydroNV/CONFIG"

local Inventory = {}

Inventory.overWornItems = function(player, callback)
  local items = player:getWornItems()
  for i = 0, items:size() - 1 do
    callback(items:get(i):getItem())
  end
end

Inventory.findAllWornNightVisionItems = function(player)
  local list = {}
  Inventory.overWornItems(player, function(item)
    if item:hasTag(CONFIG.ITEM_TAG) then
      table.insert(list, item)
    end
  end)
  return list
end

return Inventory
