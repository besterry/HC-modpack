local CONFIG          = require "NVAPI/CONFIG"
local InventoryUtils  = require "NVAPI/lib/player/Inventory"
local ItemNightVision = require "NVAPI/item/ItemNightVision"


local module = {}


module.findAllWornNightVisionItems = function()

  local list = {}

  InventoryUtils.overWornItems( getPlayer(), function(item)

    local nvitem = ItemNightVision.wrap( item )
    if nvitem:isNightVision() then
      table.insert( list, nvitem )
    end

  end)

  return list

end


return module
