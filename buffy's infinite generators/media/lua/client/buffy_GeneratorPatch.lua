
-- ** 
-- ** Simple Infinite Generators
-- ** Mod Author: github.com/buffyuwu
-- ** If you are using this work, please don't remove credit. Doing so fragments the modding community and makes it harder for newbies to learn.
-- ** 

local function ReplaceExistingObject(object, fuel, condition)
	local cell = getWorld():getCell()
	local square = object:getSquare()

	local item = InventoryItemFactory.CreateItem("Base.Generator")
	if item == nil then
		return
	end
	item:setCondition(condition)
	item:getModData().fuel = fuel
	item:getModData()['_isFuelInfinite'] = true; --if you want to display the infinite status somewhere, check for this
	square:transmitRemoveItemFromSquare(object)
	local javaObject = IsoGenerator.new(item, cell, square)
	javaObject:transmitCompleteItemToClients()
end
Events.OnFillWorldObjectContextMenu.Add(function(player, context, worldObjects, test)
	
	for _,obj in ipairs(worldObjects) do --filter for what we find when we right click
		if not isAdmin() then return; end
		local function _toggleInfiniteFuel()
			ReplaceExistingObject(obj, 99999999, 99999999)
			getPlayer():addLineChatElement(getText("IGUI_Generator_Now_Has_Infinite_Fuel_and_Condition"), 1, 0, 0);
		end
		local objTextureName = obj:getTextureName() or ""
        if not objTextureName then return end
        if luautils.stringStarts(objTextureName, "appliances_misc_01_0") then
            context:addOption(getText("IGUI_Admin_Set_Infinite_Fuel"), obj, _toggleInfiniteFuel)
            return
        end
    end
  
  end)
