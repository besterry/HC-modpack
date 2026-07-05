require "TimedActions/ISInventoryTransferAction"

local function applyPlayerShopTransferPatch()
    Events.OnTick.Remove(applyPlayerShopTransferPatch)
	local oldIsValid = ISInventoryTransferAction.isValid

	function ISInventoryTransferAction:isValid()        
		local valid = oldIsValid(self)
		if self.srcContainer then
			local parent = self.srcContainer:getParent()
			if parent and parent:getModData().owner then
				local isOwner = self.character:getUsername() == parent:getModData().owner
				if isAdmin() then isOwner = true end
				return valid and isOwner
			end
		end

		if self.destContainer then
			local parent = self.destContainer:getParent()
			if parent and parent:getModData().owner then
				local item = self.item
				if item and item:getModData() then
					local modData = item:getModData()
					if not modData.price or modData.price <= 0 then
						if self.character and ShopProximity and ShopProximity.showPriorityNote then
							ShopProximity.showPriorityNote(self.character, getText("IGUI_ItemNoPrice"), 255, 100, 100, 2500)
						end
						if isAdmin() then
							return valid
						end
						return false
					end
				end
			end
		end
		return valid
	end
end

Events.OnTick.Add(applyPlayerShopTransferPatch)
