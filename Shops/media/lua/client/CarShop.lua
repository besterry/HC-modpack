-- local base_ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
local base_ISVehicleMenu_showRadialMenu = ISVehicleMenu.showRadialMenu

CarShop = CarShop or {};
CarShop.Data = CarShop.Data or {};
CarShop.ServerCommands = CarShop.ServerCommands or {}
CarShop.updateTime = 0
local CarUtils = CarShop.CarUtils

local TICKET_NAME = CarShop.TICKET_NAME
local MOD_NAME = CarShop.MOD_NAME

local carShopEventHandler = {}

function ISVehicleMenu.onSendCommandAddCarSellTicket(playerObj, offerInfo)
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
            -- print("Sending command ISVehicleMenu.onAddCarClamp")
			playerObj:getInventory():RemoveOneOf(TICKET_NAME);
            playerObj:Say("Adding car for sale...") -- TODO: Переписать текст
            offerInfo.price = priceValue
            sendClientCommand(playerObj, MOD_NAME, 'onAddCarSellTicket', offerInfo)
        end
    end
end

function ISVehicleMenu.onSendCommandRemoveCarSellTicket(playerObj, offerInfo)
	playerObj:getInventory():AddItems(TICKET_NAME, 1);
    -- print("Sending command ISVehicleMenu.onRemoveCarClamp")
    playerObj:Say("Rmove from sell...")
    sendClientCommand(playerObj, MOD_NAME, 'onRemoveFromSale', offerInfo)
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
		local userIsCarOwner = carInfo:isCarOwner()
		print('vehicleIsOnSale: ', vehicleIsOnSale)
		print('userIsCarOwner: ', userIsCarOwner)
		if playerHasCarTicket and not vehicleIsOnSale then
        	menu:addSlice("Offer For Sale", getTexture("media/textures/ShopUI_Cart_Add.png"), ISVehicleMenu.onSendCommandAddCarSellTicket, playerObj, offerInfo)
		end
		if vehicleIsOnSale and userIsCarOwner then
			menu:addSlice("Remove Sell Ticket", getTexture("media/textures/ShopUI_Cart_Remove.png"), ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo)
		end

		if vehicleIsOnSale and (ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= "None") then
			menu:addSlice("CHEAT: Clean Car Sell Ticket ModData", getTexture("media/ui/BugIcon.png"), ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, offerInfo)
		end

		-- if vehicleHasInstalledTicket and usedKey then
        --     print('vehicleHasInstalledTicket and usedKey: ', vehicleHasInstalledTicket, usedKey, vehicleHasInstalledTicket and usedKey)
		-- 	menu:addSlice("Remove Sell Ticket", getTexture("media/textures/item_RemoveCarClamp.png"), ISVehicleMenu.onSendCommandRemoveCarSellTicket, playerObj, vehicleInfo)
		-- end

		-- if vehicleHasInstalledTicket and not usedKey then
		-- 	menu:addSlice("No key for this Sell Ticket", getTexture("media/textures/item_NoKeyCarClamp.png"), ISVehicleMenu.onSendCommandNoKeySellTicket, playerObj, vehicleInfo)
		-- end
	end
	
	-- menu:setX(getPlayerScreenLeft(playerIndex) + getPlayerScreenWidth(playerIndex) / 2 - menu:getWidth() / 2)
	-- menu:setY(getPlayerScreenTop(playerIndex) + getPlayerScreenHeight(playerIndex) / 2 - menu:getHeight() / 2)
	menu:addToUIManager()
	-- if JoypadState.players[playerObj:getPlayerNum()+1] then
	-- 	menu:setHideWhenButtonReleased(Joypad.DPadUp)
	-- 	setJoypadFocus(playerObj:getPlayerNum(), menu)
	-- 	playerObj:setJoypadIgnoreAimUntilCentered(true)
	-- end
end


function CarShop.ServerCommands.UpdateCarShopData(offerInfo)
	print('UpdateCarShopData', bcUtils.dump(offerInfo))
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

local function processCarSellTicketConstraints(vehicle, shouldPrintOutput)
    local constants = CarShop.constants
	updateTime = getTimestampMs()

	if CarShop.Data.CarShop == nil then return false end
	if CarShop.Data.CarShop == {} then return false end
	if type(CarShop.Data.CarShop) ~= "table" then return false end

	if CarShop.Data.CarShop[tostring(GetCarShopIdByVehicle(vehicle))] then
		if shouldPrintOutput then print("Lock vehicle engine.") end
		vehicle:setMass(constants.vehicleLockMass)
		return true
	else
		local vehicleTowing = vehicle:getVehicleTowing()
		if vehicleTowing and CarShop.Data.CarShop[tostring(GetCarShopIdByVehicle(vehicleTowing))] then
			if shouldPrintOutput then print("Lock vehicle engine.") end
			vehicle:setMass(constants.vehicleLockMass)
			return true
		else
			if shouldPrintOutput then print("Unlock vehicle engine.") end
			vehicle:setMass(vehicle:getInitialMass())
			vehicle:updateTotalMass()
		end
		return false
	end
end

-- local function onPlayerUpdate(playerObj)
-- 	if CarShop.updateTime + 150 < getTimestampMs() then
-- 		print(true)
-- 		-- local vehicle = playerObj:getVehicle()
-- 		local carUtils = CarUtils:initByPlayerObj(playerObj)
-- 		if carUtils then
-- 			if carUtils.vehicle then
-- 				carUtils:processConstraints()
-- 				-- processCarSellTicketConstraints(vehicle, false)
-- 			end
-- 		end
		
-- 	else
-- 		print(false)
-- 	end	
-- end
local lastCarUtils = nil
local function onEnterVehicle(playerObj)
	-- Events.OnPlayerUpdate.Add(onPlayerUpdate)
	-- local vehicle = character:getVehicle()
	local carUtils = CarUtils:initByPlayerObj(playerObj)
	if carUtils then
		lastCarUtils = carUtils
		carUtils:processConstraints()
	end
	-- processCarSellTicketConstraints(vehicle, true)
end

-- local function onExitVehicle(playerObj)
-- 	local carUtils = CarUtils:initByPlayerObj(playerObj)
-- 	carUtils:stopConstraints()
-- end
local function onExitVehicle(character)
	if lastCarUtils then
		lastCarUtils:stopConstraints()
		lastCarUtils = nil
	end
	-- Events.OnPlayerUpdate.Remove(onPlayerUpdate)
end
Events.OnEnterVehicle.Add(onEnterVehicle)
Events.OnExitVehicle.Add(onExitVehicle)

