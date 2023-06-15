CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.ServerCommands = CarShop.ServerCommands or {}
CarShop.TICKET_NAME = 'CarSellTicket'
CarShop.MOD_NAME = 'CarShop'
CarShop.isAllowGetKey = true

CarShop.constants = { 
	vehicleLockMass = 9000000 
}

---@class CarUtils
---@field username string
---@field vehicleKeyId integer
---@field vehicleKeyIdStr string
---@field vehicle BaseVehicle
---@field price number
local CarUtils = {}
CarUtils.__index = CarUtils
CarShop.CarUtils = CarUtils

---@class offerInfo
---@field username string
---@field vehicleKeyId integer
---@field vehicle BaseVehicle | nil
---@field price number | nil

---@param offerInfo offerInfo
---@return CarUtils
function CarUtils:init(offerInfo)
	local o = {}
	setmetatable(o, CarUtils)
	o.username = offerInfo.username
	o.vehicleKeyId = offerInfo.vehicleKeyId
	o.vehicleKeyIdStr = tostring(offerInfo.vehicleKeyId)
	o.vehicle = offerInfo.vehicle
	return o
end

---@param playerObj IsoPlayer
---@return CarUtils | nil
function CarUtils:initByPlayerObj(playerObj)
	local vehicle = playerObj:getVehicle()
	if not vehicle then
		return nil
	end
	return self:init({
		username = playerObj:getUsername(),
		vehicleKeyId = vehicle:getKeyId(),
		vehicle = vehicle
	})
end

---@param vehicleObj BaseVehicle
---@return CarUtils
function CarUtils:initByVehicle(vehicleObj)
	local playerObj = vehicleObj:getDriver()
	local username = ''
	if playerObj then
		username = playerObj:getUsername()
	end
	return self:init({
		username = username,
		vehicleKeyId = vehicleObj:getKeyId(),
		vehicle = vehicleObj
	})
end

---@param keyId integer
---@return BaseVehicle | nil
function CarUtils:getVehicleByKeyId(keyId)
	local vihiclesList = getCell():getVehicles()
	local result = nil
	for i = 0, vihiclesList:size() - 1 do
		local vehicle = vihiclesList:get(i)
		if vehicle:getKeyId() == keyId then
			result = vehicle
		end
	end
	return result
end

-- HACK: работает но вызывает не все сайд эффекты
---@param playerObj IsoPlayer
---@return void
function CarUtils:exit(playerObj)
	local vehicle = self.vehicle
	local seat = vehicle:getSeat(playerObj)
	if not seat then
		return
	end
	vehicle:exit(playerObj)
	vehicle:setCharacterPosition(playerObj, seat, "outside")
	playerObj:PlayAnim("Idle")
	vehicle:updateHasExtendOffsetForExitEnd(playerObj)
	getPlayerVehicleDashboard(playerObj:getPlayerNum()):setVehicle(nil)
end

function CarUtils:stopEngine()
	local vehicle = self.vehicle
	local playerObj = vehicle:getDriver()
	if vehicle and playerObj and vehicle:isDriver(playerObj) and vehicle:isEngineRunning() then
		if isClient() then
			sendClientCommand(playerObj, 'vehicle', 'shutOff', {})
		else
			vehicle:shutOff()
		end
	end
end

function CarUtils:stopHeater()
	local vehicle = self.vehicle
	local playerObj = vehicle:getDriver()
	local state = false
	local temp = 0
	if vehicle and playerObj and vehicle:isDriver(playerObj) then 
		if isClient() then
			sendClientCommand(playerObj, 'vehicle', 'toggleHeater', { on = state, temp = temp })
		else
			local part = vehicle:getPartById("Heater");
			if part then
				part:getModData().active = state;
				part:getModData().temperature = temp;
				vehicle:transmitPartModData(part);
			end
		end
	end
end

function CarUtils:stopHeadlights()
	local vehicle = self.vehicle
	local playerObj = vehicle:getDriver()
	local state = false
	local mode = 0
	if vehicle and playerObj and vehicle:isDriver(playerObj) then 
		if isClient() then
			sendClientCommand(playerObj, 'vehicle', 'setHeadlightsOn', { on = state })
			sendClientCommand(playerObj, 'vehicle', 'setLightbarSirenMode', {mode=mode})
			sendClientCommand(playerObj, 'vehicle', 'setLightbarLightsMode', {mode=mode})
		else
			vehicle:setHeadlightsOn(state);
			vehicle:setLightbarLightsMode(mode);
			vehicle:setLightbarSirenMode(mode)
		end
	end
end

function CarUtils:isCarOwner()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleKeyIdStr] then
		return CarShop.Data.CarShop[self.vehicleKeyIdStr].username == self.username
	end
	return false
end

function CarUtils:isCarOnSale()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleKeyIdStr] then
		return CarShop.Data.CarShop[self.vehicleKeyIdStr].price ~= nil
	end
	return false
end

---@return integer | nil
function CarUtils:getPrice()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleKeyIdStr] then
		return CarShop.Data.CarShop[self.vehicleKeyIdStr].price
	end
	return nil
end

---@return offerInfo | nil
function CarUtils:getOfferInfo()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleKeyIdStr] then
		local result = CarShop.Data.CarShop[self.vehicleKeyIdStr]
		local vehicle = self.vehicle
		if not vehicle then 
			vehicle = self:getVehicleByKeyId(self.vehicleKeyId)
		end
		result.vehicle = vehicle
		return result
	end
	return nil
end

function CarUtils:processConstraints()
	local constants = CarShop.constants
	if self:isCarOnSale() then
		self.vehicle:setMass(constants.vehicleLockMass)
		CarShop.isAllowGetKey = false
		return true
	else
		local vehicleTowing = self.vehicle:getVehicleTowing()
		if vehicleTowing then
			local vehicleTowingUtils = CarUtils:initByVehicle(vehicleTowing)
			if vehicleTowing and vehicleTowingUtils:isCarOnSale() then
				self.vehicle:setMass(constants.vehicleLockMass)
				return true	
			end
		end
		self:stopConstraints()
		return false
	end
end

function CarUtils:stopConstraints()
	local vehicle = self.vehicle
	if not vehicle then
		vehicle = self:getVehicleByKeyId(self.vehicleKeyId)
	end
	vehicle:setMass(vehicle:getInitialMass())
	vehicle:updateTotalMass()

	-- self.vehicle:updatePhysics()
	vehicle:updatePhysicsNetwork()
	CarShop.isAllowGetKey = true
end
