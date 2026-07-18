-- Починка / разбор двигателя: искать разводной ключ и запчасти в сумках
-- Подменю выбора числа запчастей при починке

local function hasWrench(player)
    return player:getInventory():containsTypeRecurse("Wrench")
end

local function getEnginePartsCount(player)
    return player:getInventory():getNumberOfItem("EngineParts", false, true)
end

local function hasEngineParts(player)
    return getEnginePartsCount(player) > 0
end

local function transferEngineParts(playerObj, maxCount)
    local items = playerObj:getInventory():getItemsFromType("EngineParts", true)
    if not items then return end
    local moved = 0
    for i = 0, items:size() - 1 do
        if maxCount and moved >= maxCount then break end
        ISVehiclePartMenu.toPlayerInventory(playerObj, items:get(i))
        moved = moved + 1
    end
end

local function getWrenchItem(playerObj)
    local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
    if typeToItem["Base.Wrench"] and typeToItem["Base.Wrench"][1] then
        return typeToItem["Base.Wrench"][1]
    end
    return playerObj:getInventory():getFirstTypeRecurse("Wrench")
end

local function getCondPerPart(player, part)
    local skillLevel = player:getPerkLevel(Perks.Mechanics) - part:getVehicle():getScript():getEngineRepairLevel()
    local condPerPart = 1 + (skillLevel / 2)
    if condPerPart > 5 then condPerPart = 5 end
    return condPerPart
end

local function getPartsNeededForFull(player, part)
    local missing = 100 - part:getCondition()
    if missing <= 0 then return 0 end
    return math.ceil(missing / getCondPerPart(player, part))
end

local function addRepairCountOptions(subMenu, playerObj, part, available)
    local need = getPartsNeededForFull(playerObj, part)
    local maxParts = math.min(available, need)
    if maxParts < 1 then return end

    local function addCountOption(count, label)
        local opt = subMenu:addOption(label, playerObj, ISVehicleMechanics.onRepairEngine, part, count)
        local tip = ISToolTip:new()
        tip:initialise()
        tip:setVisible(false)
        local gain = math.min(100 - part:getCondition(), math.floor(count * getCondPerPart(playerObj, part)))
        tip.description = getText("IGUI_RepairEngine_PartsTip", tostring(count), tostring(gain))
        opt.toolTip = tip
    end

    local shownAll = false
    local MAX_LIST = 12
    if maxParts <= MAX_LIST then
        for i = 1, maxParts do
            if i == available then
                addCountOption(i, getText("IGUI_RepairEngine_All", tostring(i)))
                shownAll = true
            else
                addCountOption(i, getText("IGUI_RepairEngine_Parts", tostring(i)))
            end
        end
    else
        for i = 1, 5 do
            addCountOption(i, getText("IGUI_RepairEngine_Parts", tostring(i)))
        end
        for _, n in ipairs({10, 15, 20, 25, 30, 40, 50, 60, 80}) do
            if n < maxParts then
                addCountOption(n, getText("IGUI_RepairEngine_Parts", tostring(n)))
            end
        end
        if maxParts == available then
            addCountOption(maxParts, getText("IGUI_RepairEngine_All", tostring(maxParts)))
            shownAll = true
        else
            addCountOption(maxParts, getText("IGUI_RepairEngine_PartsToFull", tostring(maxParts)))
        end
    end

    if not shownAll then
        addCountOption(available, getText("IGUI_RepairEngine_All", tostring(available)))
    end
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
    local partsCount = getEnginePartsCount(self.chr)
    if partsCount <= 0 then
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.bhs .. partsItem:getDisplayName() .. " 0/1 <LINE>"
    else
        tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. partsItem:getDisplayName() .. " x" .. partsCount .. " <LINE>"
        local need = getPartsNeededForFull(self.chr, part)
        if need > 0 then
            tooltip.description = tooltip.description .. " " .. ISVehicleMechanics.ghs .. getText("IGUI_RepairEngine_NeedForFull", tostring(need)) .. " <LINE>"
        end
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
                opt.target = nil
                opt.onSelect = nil
                opt.param1 = nil
                opt.param2 = nil
                opt.param3 = nil
                local subMenu = ISContextMenu:getNew(self.context)
                self.context:addSubMenu(opt, subMenu)
                addRepairCountOptions(subMenu, playerObj, part, getEnginePartsCount(self.chr))
            end
            self:doMenuTooltip(part, opt, "repairengine")
        end
    end
end

function ISVehicleMechanics.onRepairEngine(playerObj, part, numberOfParts)
    if playerObj:getVehicle() then
        ISVehicleMenu.onExit(playerObj)
    end

    local item = getWrenchItem(playerObj)
    if not item then return end
    ISVehiclePartMenu.toPlayerInventory(playerObj, item)

    local have = getEnginePartsCount(playerObj)
    if not numberOfParts or numberOfParts < 1 then
        numberOfParts = have
    elseif numberOfParts > have then
        numberOfParts = have
    end
    if numberOfParts < 1 then return end

    transferEngineParts(playerObj, numberOfParts)

    ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))

    local engineCover = nil
    local doorPart = part:getVehicle():getPartById("EngineDoor")
    if doorPart and doorPart:getDoor() and doorPart:getInventoryItem() and not doorPart:getDoor():isOpen() then
        engineCover = doorPart
    end

    local time = math.min(300, 80 + numberOfParts * 30)
    if engineCover then
        if engineCover:getDoor():isLocked() and VehicleUtils.RequiredKeyNotFound(engineCover, playerObj) then
            ISTimedActionQueue.add(ISUnlockVehicleDoor:new(playerObj, engineCover))
        end
        ISTimedActionQueue.add(ISOpenVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
        ISTimedActionQueue.add(ISRepairEngine:new(playerObj, part, item, time, numberOfParts))
        ISTimedActionQueue.add(ISCloseVehicleDoor:new(playerObj, part:getVehicle(), engineCover))
    else
        ISTimedActionQueue.add(ISRepairEngine:new(playerObj, part, item, time, numberOfParts))
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

local _ISRepairEngine_new = ISRepairEngine.new
function ISRepairEngine:new(character, part, item, time, numberOfParts)
    local o = _ISRepairEngine_new(self, character, part, item, time)
    o.numberOfParts = numberOfParts
    return o
end

function ISRepairEngine:perform()
    ISBaseTimedAction.perform(self)
    self.item:setJobDelta(0)
    local skill = self.character:getPerkLevel(Perks.Mechanics) - self.vehicle:getScript():getEngineRepairLevel()
    local have = self.character:getInventory():getNumberOfItem("EngineParts", false, true)
    local numberOfParts = self.numberOfParts or have
    if numberOfParts > have then
        numberOfParts = have
    end
    if numberOfParts < 1 then
        numberOfParts = 0
    end
    local args = { vehicle = self.vehicle:getId(), condition = self.part:getCondition(), skillLevel = skill, numberOfParts = numberOfParts }
    args.giveXP = self.character:getMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2") == nil
    sendClientCommand(self.character, 'vehicle', 'repairEngine', args)
    self.character:addMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2", self.part, getGameTime():getCalender():getTimeInMillis())
end
