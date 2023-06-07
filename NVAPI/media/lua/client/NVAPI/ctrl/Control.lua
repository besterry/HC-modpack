local CONFIG				  = require "NVAPI/CONFIG"
local EventManager	  = require "NVAPI/ctrl/EventManager"
local Overlay 			  = require "NVAPI/ctrl/Overlay"
local ItemControlled  = require "NVAPI/item/ItemControlled"
local Sound 				  = require "NVAPI/item/ItemSound"
local ItemState       = require "NVAPI/item/ItemState"
local PlayerUtils 	  = require "NVAPI/Player"


local Control = {}


-- create a new control object
--------------------------------------------------------------------------------
function Control:new()

	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.event = EventManager:new()
	o._item = nil
	Overlay:bind( o )

	return o

end


-- start the controller
--------------------------------------------------------------------------------
function Control:start()

	self.player = getPlayer()
	--ItemState.clear( self:getEquippedItems() )

end


function Control:clear()

	if self:isAttached() then
		self._item:_switchOff()
	end

end


--------------------------------------------------------------------------------
--
-- 														ATTACHMENT SECTION
--
--------------------------------------------------------------------------------


-- This function is called while toggling
-- This function scans the equipped items, find a suitable candidate and
-- and attach it to the control
--------------------------------------------------------------------------------
function Control:_attach()

	-- check if an item is already attached
	---------------------------------------
	if self:isAttached() then
		return
	end

	-- look for the best nv candidate in the equipped item list
	-----------------------------------------------------------
	local equippedItems = self:getEquippedItems()
	local bindTo        = equippedItems[1]

	for i = 2, #equippedItems do

		local candidate     = equippedItems[i]
		local notBroken     = candidate:isnotBroken()
		local hasMoreCharge = candidate.charge:get() > bindTo.charge:get()

		if notBroken and hasMoreCharge then
			bindTo = candidate
		end

	end

	if bindTo then
		self._item = ItemControlled:new( self, bindTo:getBoundItem() )
	end

end


-- dettach an item
--------------------------------------------------------------------------------
function Control:_dettach()

--	ItemState.unhack( self.player, self._item:getBoundItem() )
	self._item = nil

end


-- get the attached item object (can be nil)
--------------------------------------------------------------------------------
function Control:getAttachedItem()

	return self._item

end


-- check if the controller is currently attached to an item object
--------------------------------------------------------------------------------
function Control:isAttached()

	return self:getAttachedItem() ~= nil

end

function Control:isnotAttached()

	return not self:isAttached()

end


-- check if the controller is currently attached to a specific item
--------------------------------------------------------------------------------
function Control:isAttachedTo( item )

	if self:isnotAttached() then
		return false
	end

	local isnotGameItem = item.getBoundItem ~= nil

	if isnotGameItem then
		item = item:getBoundItem()
	end

	return self._item:isBoundTo( item )

end

function Control:isnotAttachedTo( item )

	return not self:isAttachedTo( item )

end



--------------------------------------------------------------------------------
--
-- 	  									    	EQUIP SECTION
--
--------------------------------------------------------------------------------

-- get a list of all equipped NV items
--------------------------------------------------------------------------------
function Control:getEquippedItems()

	return PlayerUtils.findAllWornNightVisionItems()

end


-- check if at least one NV item is equipped
--------------------------------------------------------------------------------
function Control:isEquipped()

	return self:getEquippedItems()[1] ~= nil

end


function Control:isnotEquipped()

	return not self:isEquipped()

end


-- Equip an available nv item
-- (THIS FUNCTION IS NOT YET IMPLEMENTED)
--------------------------------------------------------------------------------
function Control:equip( performAction )

	if performAction == nil then
		performAction = true
	end

end

-- unequip currently bound nv item
-- (THIS FUNCTION IS NOT PROPERLY IMPLEMENTED)
--------------------------------------------------------------------------------
function Control:unequip( performAction )

	if performAction == nil then
		performAction = true
	end

	self:_turnOff()

end


--------------------------------------------------------------------------------
--
-- 	  								  	ACTIVATION SECTION
--
--------------------------------------------------------------------------------


function Control:isTurnedOn()

	return self._item and self._item:isTurnedOn()

end


function Control:isTurnedOff()

	return not self:isTurnedOn()

end


function Control:toggle()

	self:_attach()
	if self:isnotAttached() then
		return
	end

	self.event:triggerOnToggle()

	if self:isTurnedOn() then
		self:_turnOff()
	else
		self:_turnOn()
	end

end


-- this is a private function and should not be called directly
-- Use toggle instead
--------------------------------------------------------------------------------
function Control:_turnOn()

	self.event:triggerBeforeTurnOn()
	self._item:_switchOn()
	self.event:triggerAfterTurnOn()

end

-- this is a private function and should not be called directly
-- use 'toggle' instead
--------------------------------------------------------------------------------
function Control:_turnOff()

	self.event:triggerBeforeTurnOff()
	self._item:_switchOff()
	self.event:triggerAfterTurnOff()

end


return Control
