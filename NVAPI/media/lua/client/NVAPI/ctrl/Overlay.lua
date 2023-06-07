--------------------------------------------------------------------------------
--
-- 													INITIALIZATION SECTION
--
--------------------------------------------------------------------------------
local Overlay = {}


-- object constructor
--------------------------------------------------------------------------------
function Overlay:new()

	local o = {}
  setmetatable(o, self)
  self.__index = self

  o._isEnabled = false
	o._draw      = function() o:draw() end

  return o

end


function Overlay:bind( nvctrl )

	self._nvctrl = nvctrl

end


--------------------------------------------------------------------------------
--
-- 											    	DRAWING SECTION
--
--------------------------------------------------------------------------------


-- final brightness is implemented as a linear func of available ambient light
--------------------------------------------------------------------------------
function calculateFinalBrightness( brightness )

	local amb = getClimateManager():getAmbient()
  return brightness + 0.5 * amb

end


-- called on render event
--------------------------------------------------------------------------------
function Overlay:draw()

	local w   = getPlayerScreenWidth(1)
	local h   = getPlayerScreenHeight(1)

	local nvitem = self._nvctrl:getAttachedItem()
  local blend  = calculateFinalBrightness( nvitem.param:getBrightness() )
	local tex 	 = nvitem.param:getFilterTexture()

	UIManager.DrawTexture( tex, 0, 0, w, h, blend )

end


-- initiate event to draw overlay in the screen
--------------------------------------------------------------------------------
function Overlay:enable()

  Events.OnPreUIDraw.Add( self._draw )
  self._isEnabled = true

end

-- disable event to draw overlay in the screen
--------------------------------------------------------------------------------
function Overlay:disable()

  Events.OnPreUIDraw.Remove( self._draw )
  self._isEnabled = false

end


-- Check if there is an active overlay in the screen
--------------------------------------------------------------------------------
function Overlay:isEnabled()

  return self._isEnabled == true

end

function Overlay:isnotEnabled()

	return not self:isEnabled()

end


return Overlay:new()
