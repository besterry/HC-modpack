if isClient() then return end

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.logger = CarShop.logger or {}

local MOD_NAME = CarShop.MOD_NAME

local Commands = {}

-- ---@type TheLogger
local logger = CarShop.logger

---@param player IsoPlayer
---@param offerInfo offerInfo
function logger:addForSale(player, offerInfo)
	local username = player:getUsername()
	local price = offerInfo.price
	local keyId = offerInfo.vehicleKeyId
	local result = 'Player "'..username..'" add car for sale. keyId: '..keyId..', price: '..price..'$'
    writeLog(MOD_NAME, result);
	-- self:log(result)
end
---@param player IsoPlayer
---@param offerInfo offerInfo
function logger:removeFromSale(player, offerInfo)
	local username = player:getUsername()
	local keyId = offerInfo.vehicleKeyId
	local price = offerInfo.price
	local result = 'Player "'..username..'" remove car from sale. keyId: '..keyId
	writeLog(MOD_NAME, result);
	-- self:log(result)
end
---@param player IsoPlayer
---@param offerInfo offerInfo
function logger:buyCar(player, offerInfo)
	local username = player:getUsername()
	local keyId = offerInfo.vehicleKeyId
	local sellerUsername = offerInfo.username
	local price = offerInfo.price
	local result = 'Player "'..username..'" bought a car from "'..sellerUsername..'" for '..price..'$. Car keyId:'..keyId 
	writeLog(MOD_NAME, result);
	-- self:log(result)
end

function Commands.onAddCarSellTicket(player, offerInfo)
	CarShop.Data.CarShop[offerInfo.vehicleKeyId] = offerInfo
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", offerInfo)
	logger:addForSale(player, offerInfo)
end

function Commands.onRemoveFromSale(player, offerInfo)
	CarShop.Data.CarShop[offerInfo.vehicleKeyId] = {}
	ModData.add(MOD_NAME, CarShop.Data.CarShop)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "UpdateCarShopData", {vehicleKeyId = offerInfo.vehicleKeyId})
	sendServerCommand(MOD_NAME, "StopConstraints", offerInfo)
	logger:removeFromSale(player, offerInfo)
end

function Commands.onBuyCar(player, offerInfo)
	local args = {
		offerInfo.price,
		0,
		offerInfo.username
	}
	BServer.Transfer(player, args)
	Commands.onRemoveFromSale(player, offerInfo)
	logger:buyCar(player, offerInfo)
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

local initLogger = function()
	-- setmetatable(logger ,{__index = TheLogger})
	-- logger = logger:new('CarShop.log', MOD_NAME)
end

Events.OnServerStarted.Add(initLogger);
