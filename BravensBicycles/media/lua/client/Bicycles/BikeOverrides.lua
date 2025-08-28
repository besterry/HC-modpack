--***********************************************************
--**                       BitBraven                       **
--***********************************************************

--ISVehicleMenu
local OnShowRadialMenu = ISVehicleMenu.showRadialMenu
local OnShowRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside
local OnFillPartMenu = ISVehicleMenu.FillPartMenu
local OnFillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
--ISInventoryPaneContextmenu
local OnPlace3DItem = ISInventoryPaneContextMenu.doPlace3DItemOption
local OnDropItem = ISInventoryPaneContextMenu.dropItem

--    /************************ ISVehicleMenu ************************/

-- Don't add sleep, door, hotwire, etc. options to the inside radial menu if the vehicle is a bicycle
ISVehicleMenu.showRadialMenu = function(playerObj)

	OnShowRadialMenu(playerObj)
	
	local isPaused = UIManager.getSpeedControls() and UIManager.getSpeedControls():getCurrentGameSpeed() == 0
	if isPaused then return end

	local vehicle = playerObj:getVehicle()
	if not vehicle then return end

	if not BravensBikeUtils.isBike(vehicle) then return end

	local menu = getPlayerRadialMenu(playerObj:getPlayerNum())
	menu:clear()

	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerObj:getPlayerNum(), nil)
		end
		menu:undisplay()
		return
	end

	menu:setX(getPlayerScreenLeft(playerObj:getPlayerNum()) + getPlayerScreenWidth(playerObj:getPlayerNum()) / 2 - menu:getWidth() / 2)
	menu:setY(getPlayerScreenTop(playerObj:getPlayerNum()) + getPlayerScreenHeight(playerObj:getPlayerNum()) / 2 - menu:getHeight() / 2)

	local texture = Joypad.Texture.AButton
	
	local seat = vehicle:getSeat(playerObj)

	menu:addSlice(getText("IGUI_SwitchSeat"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISVehicleMenu.onShowSeatUI, playerObj, vehicle )

	if vehicle:isDriver(playerObj) and vehicle:hasHorn() then
		menu:addSlice(getText("ContextMenu_VehicleHorn"), getTexture("media/ui/vehicles/vehicle_horn.png"), ISVehicleMenu.onHorn, playerObj)
	end

	menu:addSlice(getText("IGUI_ExitVehicle"), getTexture("media/ui/vehicles/vehicle_exit.png"), ISVehicleMenu.onExit, playerObj)
	menu:addToUIManager()

	if JoypadState.players[playerObj:getPlayerNum()+1] then
		menu:setHideWhenButtonReleased(Joypad.DPadUp)
		setJoypadFocus(playerObj:getPlayerNum(), menu)
		playerObj:setJoypadIgnoreAimUntilCentered(true)
	end
end

-- Don't add door options to the outside radial menu if the vehicle is a bicycle
ISVehicleMenu.showRadialMenuOutside = function(playerObj)
	
	if playerObj:getVehicle() then return end

	OnShowRadialMenuOutside(playerObj)

	local vehicle = playerObj:getNearVehicle()
	if not vehicle then return end

	if not BravensBikeUtils.isBike(vehicle) then return end

	local playerIndex = playerObj:getPlayerNum()
	local menu = getPlayerRadialMenu(playerIndex)

	-- For keyboard, toggle visibility
	if menu:isReallyVisible() then
		if menu.joyfocus then
			setJoypadFocus(playerIndex, nil)
		end
		menu:undisplay()
		return
	end

	menu:clear()

	menu:addSlice(getText("ContextMenu_VehicleMechanics"), getTexture("media/ui/vehicles/vehicle_repair.png"), ISVehicleMenu.onMechanic, playerObj, vehicle)
		
	if vehicle:getScript() and vehicle:getScript():getPassengerCount() > 0 then
		menu:addSlice(getText("IGUI_EnterVehicle"), getTexture("media/ui/vehicles/vehicle_changeseats.png"), ISVehicleMenu.onShowSeatUI, playerObj, vehicle )
	end
	
	ISVehicleMenu.FillPartMenu(playerIndex, nil, menu, vehicle)
	ISVehicleMenu.doTowingMenu(playerObj, vehicle, menu)
end

-- Don't add gas can options to the outside radial menu if the vehicle is a bicycle, but allow locking/unlocking it and picking it up
ISVehicleMenu.FillPartMenu = function(playerIndex, context, slice, vehicle)
	
	local playerObj = getSpecificPlayer(playerIndex)

	if playerObj:DistToProper(vehicle) >= 4 then
		return
	end

	if not BravensBikeUtils.isBike(vehicle) then
		OnFillPartMenu(playerIndex, context, slice, vehicle)
	else

		if slice then
			slice:addSlice(getText("ContextMenu_Pick_Up_Bicycle"), getTexture("media/textures/Item_Bicycle_frame.png"), PickupBike, playerIndex, vehicle)

			local vehicleZ = vehicle:getAngleZ() --Cache vehicle Z axis for performance.

			if (vehicleZ > 80 and vehicleZ < 100 or vehicleZ < -80 and vehicleZ > -100) then
			slice:addSlice(getText("ContextMenu_Lift_Bicycle"), getTexture("media/ui/vehicles/Bicycle_lift.png"), LiftBike, playerIndex, vehicle)
			end
		end

		local doorPart = vehicle:getPartById("DoorFront")
		local door = doorPart:getDoor()

		if not door then return end

		local inventory = playerObj:getInventory()
		local lockItem = inventory:getItemFromType("Base.BicycleLock")

		if door:isLocked() == false then

			if not lockItem then return end

			if slice then
				slice:addSlice(getText("ContextMenu_BicycleLock"), getTexture("media/ui/vehicles/Bicycle_lock.png"), ToggleBikeLock, playerObj, inventory, vehicle, doorPart, true)
			else
				context:addOption(getText("ContextMenu_BicycleLock"), playerObj, ToggleBikeLock, inventory, vehicle, doorPart, true)
			end
		else

			if not inventory:getItemFromType("BicycleLockKey") then return end

			if slice then
				slice:addSlice(getText("ContextMenu_BicycleUnlock"), getTexture("media/ui/vehicles/Bicycle_unlock.png"), ToggleBikeLock, playerObj, inventory, vehicle, doorPart, false)
			else
				context:addOption(getText("ContextMenu_BicycleUnlock"), playerObj, ToggleBikeLock, inventory, vehicle, doorPart, false)
			end

		end
	end
end

-- Add the option to pick up / lift the bicycle when the player right clicks it
ISVehicleMenu.FillMenuOutsideVehicle = function(player, context, vehicle, test)

	if BravensBikeUtils.isBike(vehicle) then

		context:addOption(getText("ContextMenu_Pick_Up_Bicycle"), player, PickupBike, vehicle);

		local vehicleZ = vehicle:getAngleZ() --Cache vehicle Z axis for performance.

		if (vehicleZ > 80 and vehicleZ < 100 or vehicleZ < -80 and vehicleZ > -100) then
			context:addOption(getText("ContextMenu_Lift_Bicycle"), player, LiftBike, vehicle);
		end
	end

	OnFillMenuOutsideVehicle(player, context, vehicle, test)
end

--    /************************ ISInventoryPaneContextMenu ************************/

-- Prevent the player from being able to drop the frames since they don't have a 3D model
-- This would normally already not be possible, but since the frame is a weapon, the game assumes it has a 3D model
ISInventoryPaneContextMenu.doPlace3DItemOption = function(items, playerObj, context)

	local localItems = ISInventoryPane.getActualItems(items)

	if not BravensBikeUtils.isFrame(localItems[1]) then
		OnPlace3DItem(items, playerObj, context)
	end
end

ISInventoryPaneContextMenu.dropItem = function(item, playerObj)

	if not BravensBikeUtils.isFrame(item) then
		OnDropItem(item, playerObj)
	elseif not item:isBroken() then
		PlaceBike(getSpecificPlayer(playerObj), item)
	end
end

--    /************************ Functions ************************/

function PlaceBike(playerObj, bicycle)
	if playerObj:isHandItem(bicycle) then
		ISTimedActionQueue.add(ISUnequipAction:new(playerObj, bicycle, 150))
	end

	local vehicleName = AssignName(bicycle:getFullType(),
	{"Base.BicycleFrameRegular", "Base.BicycleFrameRegularScrap", "Base.BicycleFrameMTB", "Base.BicycleFrameMTBScrap"},
	{"Base.BicycleRegular", "Base.BicycleRegularScrap", "Base.BicycleMTB", "Base.BicycleMTBScrap"})

	ISInventoryPaneContextMenu.transferIfNeeded(playerObj, bicycle)
	local time = 100
	if isAdmin() then time = 10 end
	ISTimedActionQueue.add(ISBikesTimedAction:PlaceAction(playerObj, bicycle, time, vehicleName))
end

-- Save us a couple dozen lines of code by looking up and converting frame to vehicle and vice-versa
function AssignName(nameToLookUp, availableList, resultList)
	local match = ""
	for i=0,#availableList do
		if(nameToLookUp == availableList[i]) then
			match = resultList[i]
		end
	end
	return match
end

function ToggleBikeLock(player, inventory, bicycle, door, lock)
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleAdjacent(player, bicycle));
	ISTimedActionQueue.add(ISBikesTimedAction:LockUnlock(player, inventory, bicycle, door, lock, 100))
end

function PickupBike(player, vehicle) -- Получение рамы велосипеда при поднятии
	local frameName = AssignName(vehicle:getScriptName(),
	{"Base.BicycleRegular", "Base.BicycleRegularScrap", "Base.BicycleMTB", "Base.BicycleMTBScrap"},
	{"Base.BicycleFrameRegular", "Base.BicycleFrameRegularScrap", "Base.BicycleFrameMTB", "Base.BicycleFrameMTBScrap"})

	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleAdjacent(getSpecificPlayer(player), vehicle));
	local time = 700
	if isAdmin() then time = 10 end
	ISTimedActionQueue.add(ISBikesTimedAction:PickUpAction(getSpecificPlayer(player), vehicle, time, frameName));
end

function LiftBike(player, vehicle) -- Действие по поднятию велосипеда в круговом меню
	if vehicle:getCurrentSpeedKmHour() ~= 0 then return end
	local playerObj = getSpecificPlayer(player)
	ISTimedActionQueue.add(ISPathFindAction:pathToVehicleAdjacent(playerObj, vehicle));
	ISTimedActionQueue.add(ISBikesTimedAction:LiftAction(playerObj, vehicle, 50));
end