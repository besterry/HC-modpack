-- Починка / разбор двигателя: искать разводной ключ и запчасти в сумках

local function hasWrench(player)
    return player:getInventory():containsTypeRecurse("Wrench")
end

local function hasEngineParts(player)
    return player:getInventory():getNumberOfItem("EngineParts", false, true) > 0
end

local function transferAllEngineParts(playerObj)
    local items = playerObj:getInventory():getItemsFromType("EngineParts", true)
    if not items then return end
    for i = 0, items:size() - 1 do
        ISVehiclePartMenu.toPlayerInventory(playerObj, items:get(i))
    end
end

local function getWrenchItem(playerObj)
    local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
    if typeToItem["Base.Wrench"] and typeToItem["Base.Wrench"][1] then
        return typeToItem["Base.Wrench"][1]
    end
    return playerObj:getInventory():getFirstTypeRecurse("Wrench")
end

local _doMenuTooltip = ISVehicleMechanics.doMenuTooltip
function ISVehicleMechanics:doMenuTooltip(part, option, lua, name)
    if lua ~= "takeengineparts" and lua ~= "repairengine" then
        return _doMenuTooltip(self, part, option, lua, name)
    end

    local tooltip = ISToolTip:new()
    tooltip:initialise()
    tooltip:setVisible(false)
    tooltip.description = getText("Tooltip_craft_Needs") .. " : <LINE>"
    option.toolTip = tooltip

    local repairLevel = part:getVehicle():getScript():getEngineRepairLevel()
    local skill = self.chr:getPerkLevel(Perks.Mechanics)

    if lua == "takeengineparts" then
        if part:getCondition() < 10 then
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. " " .. getText("Tooltip_Vehicle_EngineCondition", part:getCondition() .. "/10") .. " <LINE>"
        end
        local rgb = skill < repairLevel and ISVehicleMechanics.bhs or ISVehicleMechanics.ghs
        tooltip.description = tooltip.description .. " " .. rgb .. getText("IGUI_perks_Mechanics") .. " " .. skill .. "/" .. repairLevel .. " <LINE>"
        local wrenchItem = InventoryItemFactory.CreateItem("Base.Wrench")
        if not hasWrench(self.chr) then
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. wrenchItem:getDisplayName() .. " 0/1 <LINE>"
        else
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. wrenchItem:getDisplayName() .. " 1/1 <LINE>"
        end
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. " " .. getText("Tooltip_vehicle_TakeEnginePartsWarning")
        return
    end

    if part:getCondition() >= 100 then
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. " " .. getText("Tooltip_Vehicle_EngineCondition", part:getCondition()) .. " <LINE>"
    end
    local rgb = skill < repairLevel and ISVehicleMechanics.bhs or ISVehicleMechanics.ghs
    tooltip.description = tooltip.description .. " " .. rgb .. getText("IGUI_perks_Mechanics") .. " " .. skill .. "/" .. repairLevel .. " <LINE>"
    local wrenchItem = InventoryItemFactory.CreateItem("Base.Wrench")
    if not hasWrench(self.chr) then
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. wrenchItem:getDisplayName() .. " 0/1 <LINE>"
    else
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. wrenchItem:getDisplayName() .. " 1/1 <LINE>"
    end
    local partsItem = InventoryItemFactory.CreateItem("Base.EngineParts")
    if not hasEngineParts(self.chr) then
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. partsItem:getDisplayName() .. " 0/1 <LINE>"
    else
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. partsItem:getDisplayName() .. " <LINE>"
    end
end

local _doPartContextMenu = ISVehicleMechanics.doPartContextMenu
function ISVehicleMechanics:doPartContextMenu(part, x, y)
    _doPartContextMenu(self, part, x, y)
    if not self.context or part:getId() ~= "Engine" then return end
    if VehicleUtils.RequiredKeyNotFound(part, self.chr) then return end

    local playerObj = getSpecificPlayer(self.playerNum)
    local repairLevel = part:getVehicle():getScript():getEngineRepairLevel()
    local skillOk = self.chr:getPerkLevel(Perks.Mechanics) >= repairLevel
    local wrenchOk = hasWrench(self.chr)
    local partsOk = hasEngineParts(self.chr)
    local cond = part:getCondition()
    local takeName = getText("IGUI_TakeEngineParts")
    local repairName = getText("IGUI_RepairEngine")

    for i = 1, self.context.numOptions do
        local opt = self.context.options[i]
        if not opt then break end
        if opt.name == takeName then
            if cond > 10 and skillOk and wrenchOk then
                opt.notAvailable = false
                opt.target = playerObj
                opt.onSelect = ISVehicleMechanics.onTakeEngineParts
                opt.param1 = part
                opt.param2 = nil
                opt.param3 = nil
            end
            self:doMenuTooltip(part, opt, "takeengineparts")
        elseif opt.name == repairName then
            if cond < 100 and skillOk and wrenchOk and partsOk then
                opt.notAvailable = false
                opt.target = playerObj
                opt.onSelect = ISVehicleMechanics.onRepairEngine
                opt.param1 = part
                opt.param2 = nil
                opt.param3 = nil
            end
            self:doMenuTooltip(part, opt, "repairengine")
        end
    end
end

function ISVehicleMechanics.onRepairEngine(playerObj, part)
    if playerObj:getVehicle() then
        ISVehicleMenu.onExit(playerObj)
    end

    local item = getWrenchItem(playerObj)
    if not item then return end
    ISVehiclePartMenu.toPlayerInventory(playerObj, item)
    transferAllEngineParts(playerObj)

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))

    local engineCover = nil
    local doorPart = part:getVehicle():getPartById("EngineDoor")
    if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() and not doorPart:getDoor():isOpen() then
        engineCover = doorPart
    end

    local time = 300
    if engineCover then
        if engineCover:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(engineCover, playerObj) then
            ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineCover))
        end
        ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
        ISTimedActionQueue.add(ISRepairEngine:new(playerObj, part, item, time))
        ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
    else
        ISTimedActionQueue.add(ISRepairEngine:new(playerObj, part, item, time))
    end
end

function ISVehicleMechanics.onTakeEngineParts(playerObj, part)
    if playerObj:getVehicle() then
        ISVehicleMenu.onExit(playerObj)
    end

    local item = getWrenchItem(playerObj)
    if not item then return end
    ISVehiclePartMenu.toPlayerInventory(playerObj, item)

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))

    local engineCover = nil
    local doorPart = part:getVehicle():getPartById("EngineDoor")
    if doorPart and doorPart:getDoor() and not doorPart:getDoor():isOpen() then
        engineCover = doorPart
    end

    local time = 300
    if engineCover then
        if engineCover:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(part, playerObj) then
            ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineCover))
        end
        ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
        ISTimedActionQueue.add(ISTakeEngineParts:new(playerObj, part, item, time))
        ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
    else
        ISTimedActionQueue.add(ISTakeEngineParts:new(playerObj, part, item, time))
    end
end
