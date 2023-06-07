--**************************************************
--**                    BUHORL                    **
--**************************************************

--if isServer() then return end

require "GlobalItems/CGlobalItemSystem"
require "GlobalItems/CGlobalItem"

------------------------------
--- First the GlobalObject ---
------------------------------

CSnowOnDrainableObject = CGlobalItem:derive("CSnowOnDrainableObject")

function CSnowOnDrainableObject:new(luaSystem, globalObject)
	local o = CGlobalItem.new(self, luaSystem, globalObject)
	return o
end

function CSnowOnDrainableObject:getObject()
	return self:getIsoObject()
end

-----------------------------------------------
--- Then the System for parent GlobalObject ---
-----------------------------------------------

CSnowOnDrainableSystem = CGlobalItemSystem:derive("CSnowOnDrainableSystem")

function CSnowOnDrainableSystem:new()
	local o = CGlobalItemSystem.new(self, "itemsnowsystem")
	return o
end

function CSnowOnDrainableSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        if (instanceof(isoObject:getItem(), "InventoryItem")) then
            return isoObject:getItem():shouldUpdateInWorld()
        end
    end
    if (instanceof(isoObject, "InventoryItem")) then
        return isoObject:shouldUpdateInWorld()
    end
end

function CSnowOnDrainableSystem:newLuaObject(globalObject)
	return CSnowOnDrainableObject:new(self, globalObject)
end

CGlobalItemSystem.RegisterSystemClass(CSnowOnDrainableSystem)

function isValidSODObject( worldItem )
	if isClient() then 
		--params: sendCommand(playerObj, command, args)
		--call for multiplayer
		CSnowOnDrainableSystem.instance:sendCommand(getPlayer(), "addIsoObject", {worldItem:getX(),worldItem:getY(),worldItem:getZ()})
	else 
		--for Singleplayer
		return SSnowOnDrainableSystem:isValidNormalObject(worldItem)
	end
	return
end


