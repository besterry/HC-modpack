-- local base_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
require('bcUtils')
local base_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.ServerCommands = CarShop.ServerCommands or {}
CarShop.updateTime = 0
local CarUtils = CarShop.CarUtils

local TICKET_NAME = CarShop.TICKET_NAME
local MOD_NAME = CarShop.MOD_NAME

local carShopEventHandler = {}

-- NOTE: Переопределяем метод, чтоб нельзя было забрать ключи когда машина выставлена на продажу
local base_ISVehicleDashboard_onClickKeys = ISVehicleDashboard.onClickKeys
---@diagnostic disable-next-line: duplicate-set-field
function ISVehicleDashboard:onClickKeys()
	local o = base_ISVehicleDashboard_onClickKeys(self)
	if not CarShop.isAllowGetKey then
		self.vehicle:setKeysInIgnition(true);
	end
	return o
end

function ISVehicleMenu.onSendCommandAddCarSellTicket(playerObj, offerInfo)
	local hasAccount = BClientGetAccount(playerObj)
	if not hasAccount then
		playerObj:Say('I have no account');
		return
	end
    local playerId = playerObj:getPlayerNum()
    local modal = ISTextBox:new(0, 0, 280, 180, 'Set price for the car', '0', nil, ISVehicleMenu.onPriceEntered, playerId, playerObj, offerInfo);
    modal:initialise();
    modal:setOnlyNumbers(true)
    modal:addToUIManager();
end

function ISVehicleMenu.onPriceEntered(target, button, playerObj, offerInfo)
    if button.internal == "OK" then
        local priceValue = tonumber(button.parent.entry:getText())
		local length = button.parent.entry:getInternalText():len()
        if length == 0 or priceValue <= 0 then
            playerObj:Say('Is too low');
            return
        else
			playerObj:getInventory():RemoveOneOf(TICKET_NAME);
            playerObj:Say("Adding car for sale...") -- TODO: Переписать текст
            offerInfo.price = priceValue
            sendClientCommand(playerObj, MOD_NAME, 'onAddCarSellTicket', offerInfo)
        end
    end
end

function ISVehicleMenu.onSendCommandRemoveCarSellTicket(playerObj, offerInfo)
	playerObj:getInventory():AddItems(TICKET_NAME, 1);
    playerObj:Say("Rmove from sell...")
    sendClientCommand(playerObj, MOD_NAME, 'onRemoveFromSale', offerInfo)
end

function ISVehicleMenu.buyCar(playerObj, carInfo)
	local account = BClientGetAccount(playerObj)
	local price = carInfo:getPrice()
	if not account then
		playerObj:Say("I have no account")
		return
	end
	if account.coin < price then
		playerObj:Say("I don't have enough money")
		return
	end
	local offerInfo = carInfo:getOfferInfo()
	sendClientCommand(playerObj, MOD_NAME, 'onBuyCar', offerInfo)
	print('account', account)
	print(bcUtils.dump(account))
	-- playerObj:getInventory():AddItems(TICKET_NAME, 1);
    -- playerObj:Say("Rmove from sell...")
    -- sendClientCommand(playerObj, MOD_NAME, 'onRemoveFromSale', offerInfo)
end

---@diagnostic disable-next-line: duplicate-set-field
function ISVehicleMenu.showRadialMenu(playerObj)
    base_ISVehicleMenu_showRadialMenu(playerObj)
    -- if playerObj:getVehicle() then return end

	local playerIndex = playerObj:getPlayerNum()
    local username = tostring(playerObj:getUsername())
	local menu = getPlayerRadialMenu(playerIndex)

	-- For keyboard, toggle visibility
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerIndex, nil)
		end
		menu:undisplay()
		return
	end

	local vehicle = ISVehicleMenu.getVehicleToInteractWith(playerObj)

	if vehicle then
		local vehicleId = vehicle:getId()
        local offerInfo = {
            username = username,
            vehicleId = vehicleId
        }
		local carInfo = CarUtils:init(offerInfo)
		local playerHasCarTicket = playerObj:getInventory():contains(TICKET_NAME)
		local vehicleIsOnSale = carInfo:isCarOnSale()
		local playerIsCarOwner = carInfo:isCarOwner()

		print('vehicleId: ', vehicleId)
		print('vehicleIsOnSale: ', vehicleIsOnSale)
		print('playerIsCarOwner: ', playerIsCarOwner)
		if playerHasCarTicket and not vehicleIsOnSale then
        	menu:addSlice('Offer For Sale', getTexture('media/textures/ShopUI_Cart_Add.png'), ISVehicleMenu.onSendCommandAddCarSellTicket, playerObj, offerInfo)
		end
		if vehicleIsOnSale and playerIsCarOwner then
			menu:addSlice('Remove Sell Ticket', getTexture('media/textures/ShopUI_Cart_Remove.png'), ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo)
		end
		if vehicleIsOnSale and not playerIsCarOwner then
			local price = carInfo:getPrice()
			menu:addSlice('Buy a car for: '..price..'$', getTexture('media/textures/ShopUI_Cart.png'), ISVehicleMenu.buyCar, playerObj, carInfo)
		end

		print('CHEAT:', vehicleIsOnSale, ISVehicleMechanics.cheat, playerObj:getAccessLevel() ~= 'None', playerObj:getAccessLevel())
		if vehicleIsOnSale and (ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= 'None') then
			menu:addSlice('CHEAT: Clean Car Sell Ticket ModData', getTexture('media/ui/BugIcon.png'), ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo)
		end
	end
	menu:addToUIManager()
end


function CarShop.ServerCommands.UpdateCarShopData(offerInfo)
	-- print('UpdateCarShopData', bcUtils.dump(offerInfo))
    CarShop.Data.CarShop[offerInfo.vehicleId] = offerInfo;
end

carShopEventHandler.OnReceiveGlobalModData = function(tableName, data)
	if CarShop.Data[tableName] and type(data) == "table" then
        if #data > 0 then
            -- if the received data is an array table
            for _, value in ipairs(data) do
                table.insert(CarShop.Data[tableName], value);
            end
        else
            -- if the received data is a key/value table
            for key, value in pairs(data) do
				if key ~= nil then
                	CarShop.Data[tableName][tostring(key)] = value;
				end
            end
        end
    end
end

Events.OnReceiveGlobalModData.Add(carShopEventHandler.OnReceiveGlobalModData);

local function receiveServerCommand(module, command, args)
    if module ~= MOD_NAME then return; end
    if CarShop.ServerCommands[command] then
        CarShop.ServerCommands[command](args);
    end
end

Events.OnServerCommand.Add(receiveServerCommand);

local function initGlobalModData(isNewGame)
    -- clear only if its a client, if it's single-player we dont need to clear
    if isClient() and ModData.exists(MOD_NAME) then
        -- clear the current copy for a client cause it might be outdated
        ModData.remove(MOD_NAME);
    end

	ModData.request(MOD_NAME)
    CarShop.Data.CarShop = ModData.getOrCreate(MOD_NAME);
	
	CarShop.updateTime = getTimestampMs()
end

Events.OnInitGlobalModData.Add(initGlobalModData);


-- local function onPlayerUpdate(playerObj)
-- 	local carUtils = CarUtils:initByPlayerObj(playerObj)
-- 	if carUtils then
-- 		if carUtils.vehicle and carUtils:isCarOnSale() then
-- 			carUtils:processConstraints()
-- 		else
-- 			carUtils:stopConstraints()
-- 			Events.OnPlayerUpdate.Remove(onPlayerUpdate)
-- 		end
-- 	end
-- end
local lastCarUtils = nil
local function onEnterVehicle(playerObj)
	-- Events.OnPlayerUpdate.Add(onPlayerUpdate)
	local carUtils = CarUtils:initByPlayerObj(playerObj)
	if carUtils and carUtils:isCarOnSale() then
		lastCarUtils = carUtils
		carUtils:processConstraints()
	end
end

local function onExitVehicle(character)
	if lastCarUtils and lastCarUtils:isCarOnSale() then
		lastCarUtils:stopConstraints()
		lastCarUtils = nil
	end
	-- Events.OnPlayerUpdate.Remove(onPlayerUpdate)
end
Events.OnEnterVehicle.Add(onEnterVehicle)
Events.OnExitVehicle.Add(onExitVehicle)

