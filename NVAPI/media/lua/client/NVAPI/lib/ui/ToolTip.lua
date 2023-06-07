local ToolTip = {}

function ToolTip:new( message )

	local o = {}
	setmetatable(o, self)
	self.__index = self

  local instance = ISToolTip:new()
  o._instance = instance
  instance:initialise()
  instance:setVisible(true)
  instance:setName("Operation not allowed")
  instance.description = message

	return o

end

return ToolTip
