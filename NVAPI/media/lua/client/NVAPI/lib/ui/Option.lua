local ToolTip = require "NVAPI/lib/ui/ToolTip"



local Option = {}


function Option:new( label, action )

	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.label   = label
  o.action  = action
  o.checks  = {}

	return o

end

--
-- add an action to validated upon
--
function Option:check( action, message )

  table.insert( self.checks, {action,message} )

end


function Option:renderTo( context, item )

  local label  = self.label
  local player = getPlayer()
  local action = self.action

  local option = context:addOption( label, player, action, item )

  for _, entry in ipairs( self.checks ) do

    local action  = entry[1]
    local message = entry[2]

    if action() then
      option.notAvailable = true
      option.onSelect     = nil
      option.toolTip      = ToolTip:new( message )._instance
    end

  end

end


return Option
