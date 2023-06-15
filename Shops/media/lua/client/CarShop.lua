-- TODO:
-- Сделать функцию торга. 

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.ServerCommands = CarShop.ServerCommands or {}
CarShop.updateTime = 0
---@alias carTradeZone number[]
---@type carTradeZone[]
CarShop.zones = {}

---@type CarUtils
local CarUtils = CarShop.CarUtils

---@type string
local TICKET_NAME = CarShop.TICKET_NAME
---@type string
local MOD_NAME = CarShop.MOD_NAME

local carShopEventHandler = {}

if SandboxVars.Shops.CarTradeZone then
	---@type carTradeZone[]
	local result = {}
	local zonesStrArr = luautils.split(SandboxVars.Shops.CarTradeZone, ';')
	for _, zoneStr in ipairs(zonesStrArr) do
        local zoneValuesStr = luautils.split(zoneStr, " ")
		---@type carTradeZone
		local zoneValuesNum = {}
		for _, coordStr in ipairs(zoneValuesStr) do
			table.insert(zoneValuesNum, tonumber(coordStr))
		end
        table.insert(result, zoneValuesNum)
    end
	CarShop.zones = result
end

---@param x number
---@param y number
CarShop.isTradeZoneCoords = function(x, y)
	local result = false
	for _, zone in ipairs(CarShop.zones) do
		result = (x >= zone[1] and x < zone[2] and y >= zone[3] and y < zone[4]) or result
	end
	-- return result
	return true
end

---@param playerObj IsoPlayer
---@param _offerInfo offerInfo
function ISVehicleMenu.onSendCommandAddCarSellTicket(playerObj, _offerInfo)
	local offerInfo = copyTable(_offerInfo)
	local hasAccount = BClientGetAccount(playerObj)
	if not hasAccount then
		playerObj:Say(getText('IGUI_Balance_AccountNeeded2'));
		return
	end

	local x = playerObj:getX()
	local y = playerObj:getY()
	if not CarShop.isTradeZoneCoords(x, y) then
		playerObj:Say(getText('IGUI_CarShop_Not_TradeZone'));
		return
	end
    local playerId = playerObj:getPlayerNum()
	local title = getText('IGUI_CarShop_Set_Price')
    local modal = ISTextBox:new(
		0, 0, 280, 180, title, '', 
		nil, ISVehicleMenu.onPriceEntered, playerId, playerObj, offerInfo);
    modal:initialise();
    modal:setOnlyNumbers(true)
    modal:addToUIManager();
end

---@param playerObj IsoPlayer
---@param _offerInfo offerInfo
function ISVehicleMenu.onPriceEntered(target, button, playerObj, _offerInfo)
	local offerInfo = copyTable(_offerInfo)
    if button.internal == "OK" then
        local priceValue = tonumber(button.parent.entry:getText())
		local length = button.parent.entry:getInternalText():len()
        if length == 0 or priceValue <= 0 then
            playerObj:Say(getText('IGUI_CarShop_Is_Too_Low_Price'));
            return
        else
			playerObj:getInventory():RemoveOneOf(TICKET_NAME);
            playerObj:Say(getText('IGUI_CarShop_Adding_Car_For_Sale'))
            offerInfo.price = priceValue
			offerInfo.vehicle = nil
            sendClientCommand(playerObj, MOD_NAME, 'onAddCarSellTicket', offerInfo)
			ISTimedActionQueue.add(ISExitVehicle:new(playerObj))
        end
    end
end

---@param playerObj IsoPlayer
---@param _offerInfo offerInfo
function ISVehicleMenu.onSendCommandRemoveCarSellTicket(playerObj, _offerInfo)
	local offerInfo = copyTable(_offerInfo)
	playerObj:getInventory():AddItems(TICKET_NAME, 1);
    playerObj:Say(getText('IGUI_CarShop_Remove_Car_For_Sale'))
	offerInfo.vehicle = nil
    sendClientCommand(playerObj, MOD_NAME, 'onRemoveFromSale', offerInfo)
end

---@param playerObj IsoPlayer
---@param _carInfo CarUtils
function ISVehicleMenu.buyCar(playerObj, _carInfo)
	local offerInfo = copyTable(_carInfo:getOfferInfo())
	local account = BClientGetAccount(playerObj)
	local price = offerInfo.price
	if not account then
		playerObj:Say(getText('IGUI_Balance_AccountNeeded2'))
		return
	end
	if account.coin < price then
		playerObj:Say(getText('IGUI_CarShop_Need_Money'))
		return
	end
	offerInfo.vehicle = nil
	sendClientCommand(playerObj, MOD_NAME, 'onBuyCar', offerInfo)
end

local base_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu
---@param playerObj IsoPlayer
function ISVehicleMenu.showRadialMenu(playerObj)
    base_ISVehicleMenu_showRadialMenu(playerObj)

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
		local vehicleKeyId = vehicle:getKeyId()
        local offerInfo = {
            username = username,
			vehicleKeyId = vehicleKeyId,
			vehicle = vehicle
        }
		local carInfo = CarUtils:init(offerInfo)
		local playerHasCarTicket = playerObj:getInventory():contains(TICKET_NAME)
		local vehicleIsOnSale = carInfo:isCarOnSale()
		local playerIsCarOwner = carInfo:isCarOwner()

		if playerHasCarTicket and not vehicleIsOnSale then
        	menu:addSlice(
				getText('IGUI_CarShop_Offer_For_Sale'), 
				getTexture('media/textures/ShopUI_Cart_Add.png'), 
				ISVehicleMenu.onSendCommandAddCarSellTicket, playerObj, offerInfo
			)
		end
		if vehicleIsOnSale and playerIsCarOwner then
			local price = carInfo:getPrice()
			menu:addSlice(
				getText('IGUI_CarShop_Remove_Car_For_Sale_W_Price')..price..'$', 
				getTexture('media/textures/ShopUI_Cart_Remove.png'), 
				ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo
			)
		end
		if vehicleIsOnSale and not playerIsCarOwner then
			local price = carInfo:getPrice()
			menu:addSlice(
				getText('IGUI_CarShop_Buy_Car_For')..price..'$', 
				getTexture('media/textures/ShopUI_Cart.png'), 
				ISVehicleMenu.buyCar, playerObj, carInfo
			)
		end

		if vehicleIsOnSale and (ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= 'None') then
			menu:addSlice(
				'CHEAT: remove from sale', 
				getTexture('media/ui/BugIcon.png'), 
				ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo
			)
		end
	end
	menu:addToUIManager()
end

---@param offerInfo offerInfo
function CarShop.ServerCommands.UpdateCarShopData(offerInfo)
    CarShop.Data.CarShop[offerInfo.vehicleKeyId] = offerInfo;
end

---@param offerInfo offerInfo
function CarShop.ServerCommands.StopConstraints(offerInfo)
	local carUtils = CarUtils:init(offerInfo)
	carUtils:stopConstraints()
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

---@param module string
---@param command string
---@param args any[] | any
carShopEventHandler.receiveServerCommand = function(module, command, args)
    if module ~= MOD_NAME then return; end
    if CarShop.ServerCommands[command] then
        CarShop.ServerCommands[command](args);
    end
end

Events.OnServerCommand.Add(carShopEventHandler.receiveServerCommand);

carShopEventHandler.initGlobalModData = function (isNewGame)
    -- clear only if its a client, if it's single-player we dont need to clear
    if isClient() and ModData.exists(MOD_NAME) then
        -- clear the current copy for a client cause it might be outdated
        ModData.remove(MOD_NAME);
    end

	ModData.request(MOD_NAME)
    CarShop.Data.CarShop = ModData.getOrCreate(MOD_NAME);
	
	CarShop.updateTime = getTimestampMs()
end

Events.OnInitGlobalModData.Add(carShopEventHandler.initGlobalModData);

---@param playerObj IsoPlayer
carShopEventHandler.onEnterVehicle = function(playerObj)
	local carUtils = CarUtils:initByPlayerObj(playerObj)
	if carUtils then
		carUtils:processConstraints()
	end
end

-- NOTE: Переопределяем метод выхода из авто, чтобы заглушить двигатель. Потому что через события машина перестаёт работать
-- Двигательно нужно глушить чтобы нельзя было уехать из трейдзоны
local base_ISExitVehicle_perform = ISExitVehicle.perform;
function ISExitVehicle:perform()
	-- shutOff(self.character)
	local carUtils = CarUtils:initByPlayerObj(self.character)
	if carUtils and carUtils:isCarOnSale() then
		carUtils:stopEngine()
		carUtils:stopHeater()
		carUtils:stopHeadlights()
		carUtils:stopConstraints()
	end
	return base_ISExitVehicle_perform(self);
end

-- NOTE: Переопределяем метод смены седения, чтобы глушить двигатель.
local base_ISSwitchVehicleSeat_perform = ISSwitchVehicleSeat.perform
function ISSwitchVehicleSeat:perform()
	-- shutOff(self.character)
	local carUtils = CarUtils:initByPlayerObj(self.character)
	if carUtils and carUtils:isCarOnSale() then
		carUtils:stopEngine()
		carUtils:stopHeater()
		carUtils:stopHeadlights()
	end
	-- carUtils:stopConstraints()
	return base_ISSwitchVehicleSeat_perform(self);
end

-- NOTE: Переопределяем метод, чтоб нельзя было забрать ключи когда машина выставлена на продажу
local base_ISVehicleDashboard_onClickKeys = ISVehicleDashboard.onClickKeys
function ISVehicleDashboard:onClickKeys()
	local o = base_ISVehicleDashboard_onClickKeys(self)
	if not CarShop.isAllowGetKey and not self.vehicle:isHotwired() then
		self.vehicle:setKeysInIgnition(true);
	end
	return o
end

Events.OnEnterVehicle.Add(carShopEventHandler.onEnterVehicle)
