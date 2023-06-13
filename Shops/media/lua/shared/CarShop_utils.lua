CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.ServerCommands = CarShop.ServerCommands or {}
CarShop.TICKET_NAME = 'CarSellTicket'
CarShop.MOD_NAME = 'CarShop'
CarShop.isAllowGetKey = true

CarShop.constants = { 
	vehicleLockMass = 9000000 
}

local CarUtils = {}
CarUtils.__index = CarUtils
CarShop.CarUtils = CarUtils

function CarUtils:init(offerInfo)
	local o = {}
	setmetatable(o, CarUtils)
	o.username = offerInfo.username
	o.vehicleId = offerInfo.vehicleId
	o.vehicleIdStr = tostring(offerInfo.vehicleId)
	o.vehicle = getVehicleById(offerInfo.vehicleId)
	return o
end

function CarUtils:initByPlayerObj(playerObj)
	local vehicle = playerObj:getVehicle()
	if not vehicle then
		return
	end
	return self:init({
		username = playerObj:getUsername(),
		vehicleId = vehicle:getId()
	})
end

function CarUtils:initByVehicle(vehicleObj)
	local playerObj = vehicleObj:getDriver()
	local username = ''
	if playerObj then
		username = playerObj:getUsername()
	end
	return self:init({
		username = username,
		vehicleId = vehicleObj:getId()
	})
end

-- HACK: не всегда корректно работает
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

-- FIXME: по неизвестно причине не работает
function CarUtils:stopEngine()
	local vehicle = self.vehicle
	local playerObj = vehicle:getDriver()
	if vehicle and playerObj and vehicle:isDriver(playerObj) and vehicle:isEngineRunning() then
		if isClient() then
			sendClientCommand(self.character, 'vehicle', 'shutOff', {})
		else
			vehicle:shutOff()
		end
	end
end

function CarUtils:isCarOwner()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleIdStr] then
		return CarShop.Data.CarShop[self.vehicleIdStr].username == self.username
	end
	return false
end

function CarUtils:isCarOnSale()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleIdStr] then
		return CarShop.Data.CarShop[self.vehicleIdStr].price ~= nil
	end
	return false
end

function CarUtils:getPrice()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleIdStr] then
		return CarShop.Data.CarShop[self.vehicleIdStr].price
	end
	return nil
end

function CarUtils:getOfferInfo()
	if CarShop.Data.CarShop and CarShop.Data.CarShop[self.vehicleIdStr] then
		return CarShop.Data.CarShop[self.vehicleIdStr]
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
	self.vehicle:setMass(self.vehicle:getInitialMass())
	self.vehicle:updateTotalMass()
	CarShop.isAllowGetKey = true
end