--**************************************************
--**                    BUHORL                    **
--**************************************************

if isClient() then return end

require "ISBaseObject"

SGlobalItem = ISBaseObject:derive("SGlobalItem")

function SGlobalItem:noise(message)
	self.luaSystem:noise(message)
end

function SGlobalItem:initNew()
	error "override this method"
end

function SGlobalItem:stateFromIsoObject(isoObject)
	-- This is called for IsoObjects that did not have a Lua object when loaded.
	-- This can happen when the gos_NAME.bin file was deleted.
	-- This is where you would init the fields of this Lua object from
	-- isoObject:getModData().
	error "override this method"
end

function SGlobalItem:stateToIsoObject(isoObject)
	-- This is called for IsoObjects that already have a Lua object.
	-- This is where you would synchronize the state of the IsoObject
	-- with this Lua object's current state.
	error "override this method"
end

function SGlobalItem:getIsoObject()
	return self.luaSystem:getIsoObjectAt(self.x, self.y, self.z)
end

function SGlobalItem:getSquare()
	return getCell():getGridSquare(self.x, self.y, self.z)
end

function SGlobalItem:removeIsoObject()
	local square = self:getSquare()
	local isoObject = self:getIsoObject()
	if square and isoObject then
		square:transmitRemoveItemFromSquare(isoObject)
	end
end

function SGlobalItem:aboutToRemoveFromSystem()
end

function SGlobalItem:OnIsoObjectChangedItself(isoObject)
	-- A Java object changed it's state. Sync the global object.
	-- For example, after a generator runs out of fuel and shuts itself off.
end

function SGlobalItem:new(luaSystem, globalObject)
	-- NOTE: The table for this object is the *same* one the GlobalObject.class
	-- object created in Java.  Doing it this way means we don't have to worry
	-- about syncing this Lua object's fields with the GlobalObject in Java.
	-- Derived classes should not initialize any fields here that are saved,
	-- because they are already loaded from disk when this method is called.
	-- Override initNew() to initialize a brand-new SGlobalItem.
	local o = globalObject:getModData()
	setmetatable(o, self)
	self.__index = self
	o.luaSystem = self.item
	o.globalObject = globalObject
	o.x = globalObject:getX()
	o.y = globalObject:getY()
	o.z = globalObject:getZ()
	return o
end

