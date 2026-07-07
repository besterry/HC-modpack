local ItemNightVision = require "NVAPI/item/ItemNightVision"
local ItemControlled  = require "NVAPI/item/ItemControlled"
local ItemState       = require "NVAPI/item/ItemState"
local Overlay         = require "NVAPI/ctrl/Overlay"
local CONFIG          = require "HydroNV/CONFIG"

local NVAPIPatch = {}

function NVAPIPatch.apply()
  function ItemNightVision:isNightVision()
    return self._bound:hasTag(CONFIG.ITEM_TAG)
  end

  function ItemControlled:_switchOn()
  end

  function ItemControlled:_switchOff()
  end

  function ItemControlled:isTurnedOn()
    return false
  end

  ItemState.hack = function()
  end

  ItemState.unhack = function()
  end

  function Overlay:enable()
  end

  function Overlay:disable()
  end

  function Overlay:isEnabled()
    return false
  end
end

return NVAPIPatch
