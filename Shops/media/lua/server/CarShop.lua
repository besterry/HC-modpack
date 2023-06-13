if isClient() then return end

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
local CarUtils = CarShop.CarUtils

local TICKET_NAME = CarShop.TICKET_NAME
local MOD_NAME = CarShop.MOD_NAME

local CarShopCommands = {}
local Commands = {}

function Commands.onAddCarSellTicket(player, offerInfo)
	print("Adding car clamp")
	local vehicle = getVehicleById(offerInfo.vehicleId)
	CarShop.Data.CarShop[offerInfo.vehicleId] = offerInfo
	sendServerCommand(MOD_NAME, "UpdateCarShopData", offerInfo)
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	vehicle:shutOff()
end

function Commands.onRemoveFromSale(player, offerInfo)
	print("Removing car clamp")
	local vehicle = getVehicleById(offerInfo.vehicleId)
	CarShop.Data.CarShop[offerInfo.vehicleId] = {}
	sendServerCommand(MOD_NAME, "UpdateCarShopData", {vehicleId = offerInfo.vehicleId})
	ModData.transmit(MOD_NAME)
	vehicle:shutOff()
end

CarShopCommands.OnClientCommand = function(module, command, player, args)
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(CarShopCommands.OnClientCommand)

local function initGlobalModData(isNewGame)
    CarShop.Data.CarShop = ModData.getOrCreate(MOD_NAME);
	ModData.transmit(MOD_NAME)
end

Events.OnInitGlobalModData.Add(initGlobalModData);

-- local function processCarShopConstraints(vehicle)
-- 	if CarShop.Data.CarShop == nil then return false end
-- 	if CarShop.Data.CarShop == {} then return false end
-- 	if type(CarShop.Data.CarShop) ~= "table" then return false end

-- 	if CarShop.Data.CarShop[tostring(GetCarShopIdByVehicle(vehicle))] then
-- 		print("Lock vehicle engine.")
-- 		vehicle:setMass(CarShop.constants.vehicleLockMass)
-- 		return true
-- 	else
-- 		local vehicleTowing = vehicle:getVehicleTowing()
-- 		if vehicleTowing and CarShop.Data.CarShop[tostring(GetCarShopIdByVehicle(vehicleTowing))] then
-- 			print("Lock vehicle engine.")
-- 			vehicle:setMass(CarShop.constants.vehicleLockMass)
-- 			return true
-- 		else
-- 			print("Unlock vehicle engine.")
-- 			vehicle:setMass(vehicle:getInitialMass())
-- 			vehicle:updateTotalMass()
-- 		end
-- 		return false
-- 	end
-- end

-- function onEnterVehicle(character)
-- 	local carUtils = CarUtils:initByPlayerObj(character)
-- 	if carUtils then
-- 		carUtils:processConstraints()
-- 	end
-- 	-- local vehicle = character:getVehicle()	
-- 	-- processCarShopConstraints(vehicle)
-- end
-- local function onExitVehicle(character)
-- 	local carUtils = CarUtils:initByPlayerObj(character)
-- 	carUtils:stopConstraints()
-- end
-- Events.OnEnterVehicle.Add(onEnterVehicle)
-- -- Events.OnExitVehicle.Add(onExitVehicle)