local ItemCharge = {}


function ItemCharge:new( item )

	local o = {}
  setmetatable(o, self)
  self.__index  = self

  o._item = item

  return o

end


-- get available charge as a numeric float ( range: 0~1 )
--------------------------------------------------------------------------------
function ItemCharge:get()

	local item   = self._item:getBoundItem()
	local charge = item:getModData().NVAPI_CHARGE
	if charge == nil then
		charge = 1
		item:getModData().NVAPI_CHARGE = charge
	end

	return charge

end


-- get available charge in percentage format
--------------------------------------------------------------------------------
function ItemCharge:getPercent()

	local charge  = self:get()
	local percent = string.format("%.0f", charge * 100 ) .. "%"

	return percent

end


-- check if there is no charge left
--------------------------------------------------------------------------------
function ItemCharge:isDepleted()

	return self:get() == 0

end


function ItemCharge:isnotDepleted()

  return not self:isDepleted()

end

-- check if it is fully charged
--------------------------------------------------------------------------------
function ItemCharge:isFull()

	return self:get() == 1

end


-- add a specific amount of charge
--------------------------------------------------------------------------------
function ItemCharge:add( amount )

  local item = self._item:getBoundItem()

	local newcharge = math.min( 1, self:get() + amount )
	item:getModData().NVAPI_CHARGE = newcharge

  if self:isFull() then
    self._item.sound:playRecharged()
  end

end


-- drain a specific amount of charge
--------------------------------------------------------------------------------
function ItemCharge:drain( amount )

	local item      = self._item:getBoundItem()
	local newcharge = math.max( 0, self:get() - amount )

	item:getModData().NVAPI_CHARGE = newcharge

end



function ItemCharge:refillFromBattery( battery )

	-- calculate charge exchange between nv item and battery
	--------------------------------------------------------
	local availableCharge = battery:getUsedDelta()
	local needCharge      = 1 - self:get()
	local consumedCharge  = math.min( needCharge, availableCharge )

	-- consume battery and dispose of it if empty
	--------------------------------------------
	battery:setUsedDelta( availableCharge - consumedCharge )
	if battery:getUsedDelta() == 0 then
		battery:getContainer():Remove( battery )
	end

	-- add battery's charge into nvitem
	--------------------------------------
	self:add( consumedCharge )

end


-- refill charge by inspecting any battery in the inventory item
----------------------------------------------------------------
function ItemCharge:refill()

	if self:isFull() then
		return
	end

	local player = getPlayer()

	while true do

    local battery = player:getInventory():getFirstTypeRecurse("Battery")

    -- check if there is a battery
    ------------------------------
    if battery == nil then
      return
    end

		self:refillFromBattery( battery )
    if self:isFull() then
      return
    end

  end

end



return ItemCharge
