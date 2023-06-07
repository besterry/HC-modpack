local EventManager = {}

function EventManager:new()

	local o = {}
  setmetatable(o, self)
  self.__index = self

	o._events = {
		beforeTurnOn  = {},
		afterTurnOn   = {},
		beforeTurnOff = {},
		afterTurnOff  = {},
		beforeEquip		= {},
		afterEquip		= {},
		beforeUnequip = {},
		afterUnequip	= {},
		onToggle 		  = {}
	}

  return o

end


local function getEventInfo( evlist, callback )

	for _, evinfo in ipairs( evlist ) do
		local evcall = evinfo[1]
		if callback == evcall then
			return evinfo
		end
	end

	return nil

end


local function register( evlist, callback, args )

	local evinfo = getEventInfo( evlist, callback )
	if evinfo then return end

	evinfo = { callback, args }
	table.insert( evlist, evinfo )

end


EventManager.addBeforeTurnOn = function( self, callback, args )
	register( self._events.beforeTurnOn, callback, args )
end

EventManager.addAfterTurnOn = function( self, callback, args )
	register( self._events.afterTurnOn, callback, args )
end

EventManager.addBeforeTurnOff = function( self, callback, args )
	register( self._events.beforeTurnOff, callback, args )
end

EventManager.addAfterTurnOff = function( self, callback, args )
	register( self._events.afterTurnOff, callback, args )
end

EventManager.addBeforeEquip = function( self, callback, args )
	register( self._events.beforeEquip, callback, args )
end

EventManager.addAfterEquip = function( self, callback, args )
	register( self._events.afterEquip, callback, args )
end

EventManager.addBeforeUnequip = function( self, callback, args )
	register( self._events.beforeUnequip, callback, args )
end

EventManager.addAfterUnequip = function( self, callback, args )
	register( self._events.afterUnequip, callback, args )
end

EventManager.addOnToggle = function( self, callback, args )
	register( self._events.onToggle, callback, args )
end


local function trigger( evlist )

	for _, evinfo in ipairs( evlist ) do
		evcall = evinfo[1]
		evargs = evinfo[2]

		evcall( evargs )
	end

end


EventManager.triggerBeforeTurnOn = function( self )
	trigger( self._events.beforeTurnOn )
end

EventManager.triggerAfterTurnOn = function( self )
	trigger( self._events.afterTurnOn )
end

EventManager.triggerBeforeTurnOff = function( self )
	trigger( self._events.beforeTurnOff )
end

EventManager.triggerAfterTurnOff = function( self )
	trigger( self._events.afterTurnOff )
end

EventManager.triggerBeforeEquip = function( self )
	trigger( self._events.beforeEquip )
end

EventManager.triggerAfterEquip = function( self )
	trigger( self._events.afterEquip )
end

EventManager.triggerBeforeUnequip = function( self )
	trigger( self._events.beforeUnequip )
end

EventManager.triggerAfterUnequip = function( self )
	trigger( self._events.afterUnequip )
end

EventManager.triggerOnToggle = function( self )
	trigger( self._events.onToggle )
end



return EventManager
