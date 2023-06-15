if isClient() then return end

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};

local MOD_NAME = CarShop.MOD_NAME

local Commands = {}

function Commands.onAddCarSellTicket(player, offerInfo)
	CarShop.Data.CarShop[offerInfo.vehicleKeyId] = offerInfo
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", offerInfo)
end

function Commands.onRemoveFromSale(player, offerInfo)
	CarShop.Data.CarShop[offerInfo.vehicleKeyId] = {}
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", {vehicleKeyId = offerInfo.vehicleKeyId})
	sendServerCommand(MOD_NAME, "StopConstraints", offerInfo)
end

function Commands.onBuyCar(player, offerInfo)
	local args = {
		offerInfo.price,
		0,
		offerInfo.username
	}
	BServer.Transfer(player, args)
	Commands.onRemoveFromSale(player, offerInfo)
end

local OnClientCommand = function(module, command, player, args)
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)

local function initGlobalModData(isNewGame)
    CarShop.Data.CarShop = ModData.getOrCreate(MOD_NAME);
	ModData.transmit(MOD_NAME)
end

Events.OnInitGlobalModData.Add(initGlobalModData);