local CONFIG = require "NVAPI/CONFIG"

module = {}


--------------------------------------------------------------------------------
--
-- Hack item's state to make it behave like flashlight in belt
--
--------------------------------------------------------------------------------
module.hack = function( player, item )

  local slot      = "MeatCleaver Belt Right"
	local slotIndex = 3
	local slotDef   = "SmallBeltRight"


	item:setLightStrength( CONFIG.PARAM_VISCONE_INTENSITY )
	item:setLightDistance( CONFIG.PARAM_VISCONE_RANGE )
	item:setTorchCone( true )
	item:setCanBeActivated( true )

	player:setAttachedItem( slot, item )
	item:setAttachedSlot( slotIndex )
	item:setAttachedSlotType( slotDef )
	item:setAttachedToModel( slot )
	item:setActivated( true )

end



--------------------------------------------------------------------------------
--
-- Unhack item's state to make sure there wont be any odd behavor
--
--------------------------------------------------------------------------------
module.unhack = function( player, item )

	item:setLightDistance( 0 )
	item:setTorchCone( false )
	item:setLightStrength(-1)
	item:setCanBeActivated( false )

	player:removeAttachedItem( item )
	item:setAttachedSlot(-1)
	item:setAttachedSlotType(nil)
	item:setAttachedToModel(nil)

end

--------------------------------------------------------------------------------
--
-- Clear item state
--
--------------------------------------------------------------------------------
module.clear = function( nvitems )

  for _, nvitem in ipairs( nvitems ) do
    module.unhack( getPlayer(), nvitem:getBoundItem() )
  end

end


return module
