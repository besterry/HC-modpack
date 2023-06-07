local ItemNightVision = require "NVAPI/item/ItemNightVision"
local ItemState   		= require "NVAPI/item/ItemState"
local Overlay 				= require "NVAPI/ctrl/Overlay"
local CONFIG 					= require "NVAPI/CONFIG"


local ItemControlled = ItemNightVision:derive()


function ItemControlled:new( ctrl, gameitem )

	local o = {}
	setmetatable(o, self)
	self.__index = self

	self.init( o, gameitem )

	ItemState.unhack( getPlayer(), gameitem )

	o._ctrl = ctrl
	o._itemUsageOnTick = function() o:_processItemUsageOnTick() end

	return o

end



--------------------------------------------------------------------------------
--
--                         ACTIVATION OPERATIONS
--
--------------------------------------------------------------------------------


-- this function is used by the nvctrl while toggling
--------------------------------------------------------------------------------
function ItemControlled:_switchOn()

	-- do not turn on if there is no battery
  ---------------------------------------
	if self.charge:isDepleted() then
		self.sound:playToggleFail()
		return
	end

	-- do not turn on if it's broken
	--------------------------------
	if self:isBroken() then
		self.sound:playBroken()
		return
	end


	--Overlay:bind( self )
	Overlay:enable()
	self.sound:playTurnOn()
  ItemState.hack( getPlayer(), self:getBoundItem() )

	self:_startMonitorItemUsage()

end


-- this function is used by the nvctrl while toggling
--------------------------------------------------------------------------------
function ItemControlled:_switchOff( playSound )

	if playSound == nil then
		playSound = true
	end

	if self:isTurnedOn() and playSound then
		self.sound:playTurnOff()
	end

	Overlay:disable()
  ItemState.unhack( getPlayer(), self:getBoundItem() )
	self._ctrl:_dettach()

	self:_stopMonitorItemUsage()

end



function ItemControlled:isTurnedOn()

	return Overlay:isEnabled()

end




--------------------------------------------------------------------------------
--
--                           BINDING OPERATIONS
--
--------------------------------------------------------------------------------

function ItemControlled:unbind()

	--ItemState.validate( self )
	ItemState.unhack( getPlayer(), self:getBoundItem() )
  self._bound = nil

end




--------------------------------------------------------------------------------
--
--                           EVENT MONITORING
--
--------------------------------------------------------------------------------

-- this function is called during the monitor item usage event as soon as
-- it detects that the item is depleted
--------------------------------------------------------------------------------
function ItemControlled:_shutdown()

	self.sound:playDepleted()
	self:_switchOff( false )

end


-- this function is called during the monitor item usage event as soon as
-- it detects that the item has fallend in ground
--------------------------------------------------------------------------------
function ItemControlled:_break()

	self.sound:playBreak()
	self.condition:shatter()
	self:_switchOff( false )

end


function ItemControlled:_processItemUsageOnTick()

	if self:hasFallen() then
		self:_break()
		return
	end

  self.charge:drain( CONFIG.CHARGE_DRAIN_RATE )

	if self.charge:isDepleted() then
    self:_shutdown()
	end

end


function ItemControlled:_startMonitorItemUsage()

	Events.EveryOneMinute.Add( self._itemUsageOnTick )

end


function ItemControlled:_stopMonitorItemUsage()

	Events.EveryOneMinute.Remove( self._itemUsageOnTick )

end




return ItemControlled
