local Condition = {}


function Condition:new( oitem )

  local o = {}
  setmetatable(o, self)
  self.__index  = self
  o._oitem = oitem

  return o

end


function Condition:getBoundItem()

  return self._oitem:getBoundItem()

end


function Condition:setWorn()

  self:getBoundItem():setCondition( 0, false )

end


function Condition:shatter()

  self:getBoundItem():setCondition( 0, false )

end


function Condition:damage( percent )


end


function Condition:get()

  return self:getBoundItem():getCondition()

end


function Condition:isWorn()

  return self:get() == 0

end


function Condition:isnotWorn()

  return not self:isWorn()

end


function Condition:isBroken()

  return self:isWorn()

end


function Condition:isnotBroken()

  return not self:isBroken()

end



return Condition
