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

LuaEventManager.AddEvent("onCarSaleChange") -- Добавляем новый тип события. Будем его вызывать когда изменится количество продаваемых авто
local function onLoad()
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
end
Events.OnLoad.Add(onLoad)

---@param x number
---@param y number
CarShop.isTradeZoneCoords = function(x, y)
	local result = false
	for _, zone in ipairs(CarShop.zones) do
		result = (x >= zone[1] and x < zone[2] and y >= zone[3] and y < zone[4]) or result
	end
	return result
end

local function countCarsOnSale()
	local result = 0
	local resultList = {}
	local username = getPlayer():getUsername()
	for k, v in pairs(CarShop.Data.CarShop) do
		if v and v.username and v.username == username then -- NOTE: Я где-то накосячил и записи могут дублироваться. Часть типа строка часть типа интеджер. 
			-- result = result + 1							-- Проблема нетипизируемого луа. В общем мне лень сейчас искать где косяк, это ни на что не влияет кроме этого подсчёта
															-- Так что придётся его немного усложнить
			resultList[tostring(v.vehicleKeyId)] = true     -- Делаем уникальный список id транспорта по имени игрока
		end
	end
	for _, _ in pairs(resultList) do -- Ну а теперь просто считаем элементы в этой таблице
		result = result + 1
	end
	return result
end

local function checkIsCarSellAllowed()
	return countCarsOnSale() < SandboxVars.Shops.CarSellsByPlayer
end

---@param playerObj IsoPlayer
---@param _offerInfo offerInfo
function ISVehicleMenu.onSendCommandAddCarSellTicket(playerObj, _offerInfo)
	if not checkIsCarSellAllowed() then
		playerObj:Say(getText('IGUI_CarShop_Is_Maximum'));
		return
	end
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
	--print("========REMOVE SELL CAR========")
	--print("vehicleKeyId", offerInfo.vehicleKeyId)
	CarShop.Data.CarShop[offerInfo.vehicleKeyId] = nil
	--print("After remove:",CarShop.Data.CarShop[offerInfo.vehicleKeyId])
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

local function isModDataTableEmpty(modDataTable)
    if modDataTable == nil then
		--print("Table empty")
        return true
	end

	local count = 0
    for _ in pairs(modDataTable) do
        count = count + 1
        if count > 0 then
			--print("Table not empty")
            return false
        end
    end
        
	return true
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
		local carname = vehicle:getScript():getName()
		local carId = vehicle:getModData().sqlId
		local X = vehicle:getX()
		local Y = vehicle:getY()
        local offerInfo = {
            username = username,
			vehicleKeyId = vehicleKeyId,
			vehicle = vehicle,
			carname = carname,
			carid = carId,
			x = X,
			y = Y
        }
		local carInfo = CarUtils:init(offerInfo)
		local playerHasCarTicket = playerObj:getInventory():contains(TICKET_NAME)
		local vehicleIsOnSale = carInfo:isCarOnSale()
		local globalModDataTable = ModData.get(MOD_NAME)[vehicleKeyId]
		local isEmptyTable = isModDataTableEmpty(globalModDataTable)
		local playerIsCarOwner = carInfo:isCarOwner()

		if vehicleIsOnSale and globalModDataTable and BravensBikeUtils.isBike(vehicle) then
			menu:clear()
		end

		if playerHasCarTicket and (not vehicleIsOnSale or not globalModDataTable or isEmptyTable) then
        	menu:addSlice(
				getText('IGUI_CarShop_Offer_For_Sale'), 
				getTexture('media/textures/ShopUI_Cart_Add.png'), 
				ISVehicleMenu.onSendCommandAddCarSellTicket, playerObj, offerInfo
			)
		end
		if vehicleIsOnSale and globalModDataTable and playerIsCarOwner then
			local price = carInfo:getPrice()
			menu:addSlice(
				getText('IGUI_CarShop_Remove_Car_For_Sale_W_Price')..price..'$', 
				getTexture('media/textures/ShopUI_Cart_Remove.png'), 
				ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo
			)
		end
		if vehicleIsOnSale and globalModDataTable and not playerIsCarOwner then
			local price = carInfo:getPrice()
			menu:addSlice(
				getText('IGUI_CarShop_Buy_Car_For')..price..'$', 
				getTexture('media/textures/ShopUI_Cart.png'), 
				ISVehicleMenu.buyCar, playerObj, carInfo
			)
		end

		if vehicleIsOnSale and globalModDataTable and not playerIsCarOwner then
			local ownerUsername = carInfo:getOwner()
			menu:addSlice(
				getText('IGUI_CarShop_Seller') .. ownerUsername, 
				getTexture('media/textures/Item_DriversLicense.png'), 
				nil
			)
		end

		if vehicleIsOnSale and globalModDataTable and (ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= 'None') then
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
	local carsOnSaleNum = countCarsOnSale()
	triggerEvent('onCarSaleChange', carsOnSaleNum)
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
		carUtils:startConstraints()
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
		carUtils:putKeyInIgnition()
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
		carUtils:putKeyInIgnition()
	end
	return base_ISSwitchVehicleSeat_perform(self);
end

---@param vehicle BaseVehicle
local setKeysInIgnition_helper = function(vehicle) -- 20 тиков подряд проверяем что ключ в замке и вставляем его если это не так. Вызывается ниже
	local delayedFn = function() 
		if not CarShop.isAllowGetKey and not vehicle:isHotwired() and not vehicle:isKeysInIgnition() then
			vehicle:setKeysInIgnition(true);
		end
	end
	for i = 1, 20, 1 do
		BravensUtils.DelayFunction(delayedFn, i)
	end
end

-- NOTE: Переопределяем метод, чтоб нельзя было забрать ключи когда машина выставлена на продажу
local base_ISVehicleDashboard_onClickKeys = ISVehicleDashboard.onClickKeys
function ISVehicleDashboard:onClickKeys()
	local o = base_ISVehicleDashboard_onClickKeys(self)
	local vehicle = self.vehicle
	if not CarShop.isAllowGetKey and not vehicle:isHotwired() then
		vehicle:setKeysInIgnition(true);
		setKeysInIgnition_helper(vehicle)
	end	
	return o
end

local userPanelHooks = function()
	-- NOTE: делаем хук для панели юзера.
	function ISUserPanelUI:renderCarOnSale(carsOnSaleNum)
		local resultStr = getText('IGUI_CarShop_Vehicles_On_Sale') .. carsOnSaleNum .. '/' .. SandboxVars.Shops.CarSellsByPlayer
		self.sellingCarsCount:setName(resultStr)
	end

	local base_ISUserPanelUI_create = ISUserPanelUI.create
	function ISUserPanelUI:create()
		base_ISUserPanelUI_create(self)
		local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
		local btnWid = 160 --Ширина кнопок
		local btnHgt = math.max(30, FONT_HGT_SMALL + 8) --Высота кнопок
		
		-- self:removeChild(self.showServerInfo) -- Удаляем галочку "информация о сервере"
		-- self:removeChild(self.showConnectionInfo) -- Удаляем галочку "информация о соединении"
		
		local y = 60
		
		if not self.sellingCarsCount then
			self.sellingCarsCount = ISLabel:new(15 + btnWid + 30, y, btnHgt, '',1,1,1,1,UIFont.Small, true); -- Вставляем текст с количеством тачек на прродаже
			self:addChild(self.sellingCarsCount);
		end
		self:renderCarOnSale(countCarsOnSale()) -- Отрисовываем количество машин в продаже
		
		y = y + btnHgt;
		self.showPingInfo:setY(y) -- Передвигаем чекбокс повыше

		self.onCarSaleChange_handler = function(carsOnSaleNum)
			self:renderCarOnSale(carsOnSaleNum) -- обновляем счётчик по событию
		end
		Events.onCarSaleChange.Add(self.onCarSaleChange_handler) -- Подписываемся на событие чтоб можно было обновлять счётчик во время того как окно открыто
	end

	local base_ISUserPanelUI_close = ISUserPanelUI.close
	function ISUserPanelUI:close()
		Events.onCarSaleChange.Remove(self.onCarSaleChange_handler) -- Незабываем отписаться от события
		base_ISUserPanelUI_close(self)
	end
end
userPanelHooks()

Events.OnCreateUI.Add(userPanelHooks) -- NOTE: меняем интерфейс в этом событии потому что иначе ГитроТрейд по неизвестно причине загружается раньше и всё портит. Код будет работать и в случие использования ванильных функций (напр. отключения гидротрейда)
Events.OnEnterVehicle.Add(carShopEventHandler.onEnterVehicle)
