if isClient() then return end

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};

local MOD_NAME = CarShop.MOD_NAME

local CarShopCommands = {}
local Commands = {}

function Commands.onAddCarSellTicket(player, offerInfo)
	local vehicle = getVehicleById(offerInfo.vehicleId)
	CarShop.Data.CarShop[offerInfo.vehicleId] = offerInfo
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", offerInfo)
	Commands.shutOff(vehicle)
end

function Commands.onRemoveFromSale(player, offerInfo)
	-- local vehicle = getVehicleById(offerInfo.vehicleId)
	CarShop.Data.CarShop[offerInfo.vehicleId] = {}
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", {vehicleId = offerInfo.vehicleId})
	sendServerCommand(MOD_NAME, "StopConstraints", offerInfo)
	
end

function Commands.stopEngine(vehicle)
	-- if vehicle and vehicle:isEngineRunning() then
	-- 	vehicle:shutOff()
	-- end
end

function Commands.onBuyCar(player, offerInfo)
	local args = {
		offerInfo.price,
		0,
		offerInfo.username
	}
	BServer.Transfer(player, args)
	Commands.onRemoveFromSale(player, offerInfo)
	sendServerCommand(MOD_NAME, "StopConstraints", offerInfo)
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