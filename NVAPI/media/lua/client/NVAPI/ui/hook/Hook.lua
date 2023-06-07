local nvctrl          = require "NVAPI/ctrl/instance"
local ItemNightVision = require "NVAPI/item/ItemNightVision"


local HOOK = {
  unequipPerform      = ISUnequipAction.perform,
  equipPerform        = ISWearClothing.perform,
  reloadIcons         = ISHotbar.reloadIcons,
  extraUnequipPerform = ISClothingExtraAction.perform
}

ISClothingExtraAction.perform = function(self )

  if nvctrl:isAttached() then
    local isReplacing = nvctrl:getAttachedItem():getBoundItem():getBodyLocation() == self.item:getBodyLocation()
    if isReplacing then
      nvctrl:unequip( false )
    end
  end

  HOOK.extraUnequipPerform( self )

end

-- When wearing an item, we must check if the nvg is bound
-- If so, then we have to make sure that the bodylocation replacement is
-- properly handled bu unequipping the wore item
--------------------------------------------------------------------------------
ISWearClothing.perform = function( self )

  if nvctrl:isAttached() then
    local isReplacing = nvctrl:getAttachedItem():getBoundItem():getBodyLocation() == self.item:getBodyLocation()
    if isReplacing then
      nvctrl:unequip( false )
    end

  end

  HOOK.equipPerform( self )

end


-- When unwearing (unequipping) an item, we must first check if them unwearing
-- item is a nvg capable.
-- If so, then we must check if the unwearing item is bound to the controller
-- If so, then we must handle the unequip properly
--------------------------------------------------------------------------------
ISUnequipAction.perform = function(self)

  local nvitem = ItemNightVision.wrap( self.item )

  if nvitem:isNightVision() then

    if nvctrl:isAttachedTo( nvitem ) then
      nvctrl:unequip( false )
    end

  end

  HOOK.unequipPerform( self )

end



ISHotbar.reloadIcons = function( self )

	self.attachedItems = {};
	for i=0, self.chr:getInventory():getItems():size()-1 do
		local item = self.chr:getInventory():getItems():get(i);
		if item:getAttachedSlot() > -1 then

      -- dont let it process nv item in hotbar.
      -- this avoids so much glitches
      --if nvctrl.item == nil or ( nvctrl.item ~= nil and item ~= nvctrl.item:getBoundItem() ) then
      if nvctrl:isnotAttachedTo( item ) then
			  self.attachedItems[item:getAttachedSlot()] = item;
      end

		end
	end
end
