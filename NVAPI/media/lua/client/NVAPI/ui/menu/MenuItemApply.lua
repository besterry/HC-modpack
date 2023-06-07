local CONFIG  = require "NVAPI/CONFIG"

local module = {}


-- Perform the recharge operation
--------------------------------------------------------------------------------
module.recharge = function( player, nvitem )

  nvitem.charge:refill()

end


-- Perform the repair operation
--------------------------------------------------------------------------------
module.repair = function( player, nvitem )

  nvitem.recipe.repair:fix( nvitem )

end



-- Perform the change brightness operation
--------------------------------------------------------------------------------
module.brightness = function( nvitem, brightness )

  nvitem.param:setBrightness( brightness )

end



-- Perform the change filter operation
--------------------------------------------------------------------------------

module.filter = function( nvitem, filter )

  nvitem.param:setFilter( filter )

end



return module
