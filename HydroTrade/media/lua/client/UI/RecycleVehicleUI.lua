require "ISUI/ISModalDialog"
require "luautils"

if not RecycleVehicle then RecycleVehicle = {} end
if not RecycleVehicle.UI then RecycleVehicle.UI = {} end

-- ------------------------------------------------------
-- Copy of the same functions from ISBlacksmithMenu
-- for compatibility reasons
-- ------------------------------------------------------

local function comparatorDrainableUsesInt(item1, item2)
    return item1:getDrainableUsesInt() - item2:getDrainableUsesInt()
end

local function predicateDrainableUsesInt(item, count)
    return item:getDrainableUsesInt() >= count
end

local function getBlowTorchWithMostUses(container)
    return container:getBestTypeEvalRecurse("Base.BlowTorch", comparatorDrainableUsesInt)
end

local function getFirstBlowTorchWithUses(container, uses)
    return container:getFirstTypeEvalArgRecurse("Base.BlowTorch", predicateDrainableUsesInt, uses)
end

-- ------------------------------------------------------
-- The mod's functions
-- ------------------------------------------------------

local function onRecycleVehicleAux(player, button, vehicle, propaneNeeded)
    if button.internal == "NO" then return end
	
	--если у игрока в инвентаре нет пропановой горелки, то завершить разбор
	if not player:getInventory():containsTypeRecurse("BlowTorch") then 
	player:Say(getText("IGUI_VRR_Not_BlowTorch"))
	player:playEmote("shrug") 		-- показывает анимацию "не знаю" распуская руки перед собой на уровне живота
	return 
	end
	
	--если вместимость горелки меньше чем нужно, прекращаем разбор
	local blowTorch = getBlowTorchWithMostUses(player:getInventory())
    if blowTorch then
		local blowTorchUsesLeft = blowTorch:getDrainableUsesInt()
		if blowTorchUsesLeft < propaneNeeded then 
		player:Say(getText("IGUI_VRR_Not_BlowTorchLow"))
		player:playEmote("shrug") 		-- показывает анимацию "не знаю" распуская руки перед собой на уровне живота
		return 
		end
	end

    if luautils.walkAdj(player, vehicle:getSquare()) then
        local blowTorch = getFirstBlowTorchWithUses(player:getInventory(), propaneNeeded)
        ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), blowTorch, true);
        local mask = player:getInventory():getFirstTypeRecurse("WeldingMask")
        if mask then
            ISInventoryPaneContextMenu.wearItem(mask, player:getPlayerNum())
        end
        ISTimedActionQueue.add(RecycleVehicleAction:new(player, vehicle, propaneNeeded))
    end
end

local function onRecycleVehicle(player, vehicle, propaneNeeded)
    local message = getText("IGUI_VehicleRecycling_ConfirmDialog_Vehicle")
    if vehicle:getScript():getName():find("Trailer") then
        message = getText("IGUI_VehicleRecycling_ConfirmDialog_Trailer")
    end

    local playerNum = player:getPlayerNum()
    local modal = ISModalDialog:new(0, 0, 350, 150, message, true, player, onRecycleVehicleAux, playerNum, vehicle, propaneNeeded)
    modal:initialise();
    modal:addToUIManager();
end

function RecycleVehicle.UI.addOptionToMenuOutsideVehicle(player, context, vehicle)
    --if RecycleVehicle.Utils.isBurnt(vehicle) and not RecycleVehicleOptions.overrideBurnt then return end
    --if RecycleVehicle.Utils.isSmashed(vehicle) and not RecycleVehicleOptions.overrideSmashed then return end
    if not RecycleVehicle.Utils.isBurnt(vehicle) and not RecycleVehicle.Utils.isSmashed(vehicle) then
        if not player:getInventory():containsTypeRecurse("BlowTorch") then return end

        local hasPassengers
        for i = 0, vehicle:getMaxPassengers() - 1 do
            if vehicle:getCharacter(i) then
                hasPassengers = true
                break
            end
        end
        if hasPassengers then
            local option = context:addOption(getText("ContextMenu_VehicleRecycling_RemoveVehicle"), nil, nil)
            local toolTip = ISToolTip:new()
            toolTip:initialise()
            toolTip:setVisible(false)
            option.toolTip = toolTip
            toolTip.description = getText("Tooltip_VehicleRecycling_Passengers")
            option.notAvailable = true
            return
        end
    end

    local propaneNeeded = 0
    for i = 1, vehicle:getPartCount() do
        local part = vehicle:getPartByIndex(i - 1)
        local partId = part:getId()

        if not (part:getItemType() and not part:getItemType():isEmpty() and not part:getInventoryItem()) then
            if not (partId:find("Wind") or partId:find("Headlight") or partId:find("TruckBed")
                    or partId:find("GloveBox") or partId:find("Engine") or partId:find("Heater")
                    or partId:find("PassengerCompartment") or partId == "TrunkDoorWreck") then
                propaneNeeded = propaneNeeded + 0.65
            end
        end
    end

	-- добавлена опция по просьбе из коментариев
	-- если не стоит настройка на старой версии пропана, то используем требование пропана / 10
	if SandboxVars.VehicleRecycling.OldVersionNeededPropane then
		propaneNeeded = math.ceil(propaneNeeded) + RecycleVehicle.Utils.getBaseArea(vehicle)
		-- TODO: temporary fix for cases when more than one propane torch (>100 units) needed
		if propaneNeeded > 100 then
			propaneNeeded = 100
		end
	else
		propaneNeeded = (math.ceil(propaneNeeded) + RecycleVehicle.Utils.getBaseArea(vehicle)) / 10
		-- TODO: temporary fix for cases when more than one propane torch (>100 units) needed
		if propaneNeeded > 10 then
			propaneNeeded = 10
		end
	end
	
    local optionText = getText("ContextMenu_VehicleRecycling_RemoveVehicle")
    if vehicle:getScript():getName():find("Trailer") then
        optionText = getText("ContextMenu_VehicleRecycling_RemoveTrailer")
    end

    local option
    -- Override the vanilla implementation for burnt or smashed vehicles
    --if RecycleVehicleOptions.overrideBurnt and RecycleVehicle.Utils.isBurnt(vehicle) then
    if RecycleVehicle.Utils.isBurnt(vehicle) then
        option = context:getOptionFromName(getText("ContextMenu_RemoveBurntVehicle"))
    end
    --if RecycleVehicleOptions.overrideSmashed and RecycleVehicle.Utils.isSmashed(vehicle) then
    if RecycleVehicle.Utils.isSmashed(vehicle) then
        option = context:getOptionFromName(getText("ContextMenu_RemoveBurntVehicle"))
    end

    if option then
        option.name = optionText
        option.target = player
        option.onSelect = onRecycleVehicle
        option.param1 = vehicle
        option.param2 = propaneNeeded
    else
        option = context:addOption(optionText, player, onRecycleVehicle, vehicle, propaneNeeded)
    end

    local toolTip = ISToolTip:new()
    toolTip:initialise()
    toolTip:setVisible(false)
    toolTip:setName(optionText)
    option.toolTip = toolTip

    local text = getText("Tooltip_VehicleRecycling") .. " <LINE> "
    local notAvailable = false
	
	-- FIX Valhalla Aegis отмена разбора авто.
	local vehicleName = vehicle:getScript():getFullName()
	local smashedCarClaimed
	if SandboxVars.VehicleRecycling.RecyclingClaimedSmashedCar then
		smashedCarClaimed = vehicleName:find("Smashed")
	end
	-- если в названии машины есть Burnt
	local burntCarClaimed
	if SandboxVars.VehicleRecycling.RecyclingClaimedBurntCar then
		burntCarClaimed = vehicleName:find("Burnt")
	end
	
	-- Если отключена настройка на разбор заприваченных авто
	-- и есть мод Аегис
	if SandboxVars.VehicleRecycling.RecyclingClaimedVehicle == false then
		if Valhalla and Valhalla.VehicleClaims then	
			local vehicleData = Valhalla:getVehicleModData(vehicle);
			if vehicleData['owner'] and vehicleData['owner'] ~= "" and not smashedCarClaimed and not burntCarClaimed then	
				text = text .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_VehicleRecycling_VehicleIsClamedThe15karatFix") .. " <LINE> "
				notAvailable = true
			end	
		end	
	end


    if player:getInventory():containsTypeRecurse("WeldingMask") then
        text = text .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.WeldingMask")
    else
        text = text .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.WeldingMask")
        notAvailable = true
    end

    local blowTorch = getBlowTorchWithMostUses(player:getInventory())
    if blowTorch then
        local blowTorchUsesLeft = blowTorch:getDrainableUsesInt()
        if blowTorchUsesLeft >= propaneNeeded then
            text = text .. " <LINE> <RGB:1,1,1> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUsesLeft .. "/" .. propaneNeeded
        else
            text = text .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " " .. getText("ContextMenu_Uses") .. " " .. blowTorchUsesLeft .. "/" .. propaneNeeded
            notAvailable = true
        end
    else
        text = text .. " <LINE> <RGB:1,0,0> " .. getItemNameFromFullType("Base.BlowTorch") .. " 0/" .. propaneNeeded
        notAvailable = true
    end

	------------------------------------
	--FIX Список исключений
	
	--функция помощник
	local function hasValue (tab, val)
		for index, value in ipairs(tab) do
			if value == val then
				return index+1
			end
		end

		return false
	end

	--Полное имя машины с кодом
	local vehicleName = vehicle:getScript():getFullName()
	-- поиск исключений из списка в песочнице игры
	local vehicleException = luautils.split(SandboxVars.VehicleRecycling["ExceptionListRate"], ";")
	
	-- если в названии машины есть Smashed
	local smashedCar
	if SandboxVars.VehicleRecycling.RecyclingSmashedCar then
		smashedCar = vehicleName:find("Smashed")
	end
	
	-- если в названии машины есть Burnt
	local burntCar
	if SandboxVars.VehicleRecycling.RecyclingBurntCar then
		burntCar = vehicleName:find("Burnt")
	end


    if SandboxVars.VehicleRecycling.UninstallParts and not hasValue(vehicleException, vehicleName) and not smashedCar and not burntCar then
        local partsToRemove = {}
		
        for i = 1, vehicle:getPartCount() do
            local part = vehicle:getPartByIndex(i - 1)
            local partId = part:getId()
			local category = part:getCategory() or "Other";
            -- Looking for all windows, doors (including engine and trunk doors), seats
            if (partId:find("^Wind") or partId:find("Door") or partId:find("Seat")) and category ~= "nodisplay" then
                if part:getItemType() and not part:getItemType():isEmpty() and part:getInventoryItem() then
                    table.insert(partsToRemove, partId)
                end
            end
        end

        if #partsToRemove > 0 then
            text = text .. " <LINE> <LINE> <RGB:1,1,1> " .. getText("Tooltip_VehicleRecycling_Uninstall")
            for _, part in ipairs(partsToRemove) do
                text = text .. " <LINE> <RGB:1,0,0> " .. getText("IGUI_VehiclePart" .. part)
            end
            notAvailable = true
        end
    end

    toolTip.description = text
    option.notAvailable = notAvailable
end

-- Wrap the original function
if not RecycleVehicle.UI.defaultMenuOutsideVehicle then
    RecycleVehicle.UI.defaultMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
end

-- Override the original function
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    RecycleVehicle.UI.defaultMenuOutsideVehicle(player, context, vehicle, test)
    RecycleVehicle.UI.addOptionToMenuOutsideVehicle(getSpecificPlayer(player), context, vehicle)
end