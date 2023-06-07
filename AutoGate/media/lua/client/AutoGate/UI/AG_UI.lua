if AutoGate == nil then AutoGate = {} end
if AutoGate.UI == nil then AutoGate.UI = {} end

function AutoGate.UI.contextMenuOptions(_player, context, worldObjects)
    
    print(tostring(isClient()))
    print(tostring(isServer()))
    local player = getSpecificPlayer(_player)
    local door = nil
    for _,v in ipairs(worldObjects) do
        local name = tostring(v:getName())
        if (instanceof(v, "IsoThumpable")) and ((name == "Double Door") or (name == "Double Metal Pole Gate") or (name == "Double Metal Wire Gate")) then   
            door = v
            break
        end
    end

    if door then
        local fqcs = AutoGate.Utils.GetFrequency(door)
        if fqcs then
            local wasPaired = door:getModData()["AutoGate_gateFrequency_PAIRED"]
            local battery = AutoGate.UI.getBattery(door)
            if wasPaired == nil then
                local emptyCtrl = AutoGate.UI.findController(player, nil)
                local pair = context:addOption("Pair Controller", player, AutoGate.UI.pairController, emptyCtrl, door)
                if (not emptyCtrl) or (not battery) then
                    AutoGate.ToolTip.toolTipPair(pair, emptyCtrl, battery)
                    pair.notAvailable = true
                end 
            else
                local pairedCtrl = AutoGate.UI.findController(player, wasPaired)
                local open = context:addOption("Use Controller", player, AutoGate.UI.toggleAutoGate, door, battery)  
                if pairedCtrl then
                    local emptyCtrl = AutoGate.UI.findController(player, nil)
                    if emptyCtrl then
                        local copy = context:addOption("Make a copy", player, AutoGate.UI.makeCopy, emptyCtrl, pairedCtrl)
                    end
                else
                    AutoGate.ToolTip.toolTipOpen(open)
                    open.notAvailable = true
                end 
            end
        else
            local install = context:addOption("Install Components", player, AutoGate.UI.installGateMotor, door:getSquare(), door:getOppositeSquare(), door)
            AutoGate.UI.checkCanInstall(player, install)
        end
    end       
end

function AutoGate.UI.checkCanInstall(player, install)
    local metalWelding = player:getPerkLevel(Perks.MetalWelding)
    local mechanics = player:getPerkLevel(Perks.Mechanics)
    local electricity = player:getPerkLevel(Perks.Electricity)
    local componets = player:getInventory():containsType("GateComponents")
    local bt = player:getInventory():containsType("BlowTorch")
    local wm = player:getInventory():containsType("WeldingMask")
    if (not componets) or (metalWelding < 2) or (mechanics < 2) or (electricity < 1) or (not bt) or (not wm) then
        install.notAvailable = true
        AutoGate.ToolTip.toolTipInstall(install, componets, bt, wm, metalWelding, mechanics, electricity)
    end
end

local onServerCommand = function(module, command, args)
    if module == "AutoGate" then
        if command == "install" then
            AutoGate.Utils.InstallGate(args)
        end
    end
end

function AutoGate.UI.getBattery(door)
    local gateContainer = AutoGate.Utils.GetGateFromSquare(AutoGate.Utils.GetGateCorner(door, nil)):getItemContainer()
    if gateContainer then
        local gateItems = gateContainer:getItems()
        for i=0, gateItems:size()-1, 1 do
            local item = gateItems:get(i)
            local iType = item:getType()
            if iType == "CarBattery1" or iType == "CarBattery2" or iType == "CarBattery3" then
                if item:getDelta() >= 0.05 then
                    return item
                end
            end
        end
    end
    return false
end

function AutoGate.UI.findController(player, doorCode)
    local ctrls = player:getInventory():getItemsFromType("GateController")
    for i=0, ctrls:size()-1, 1 do
        local ctrl = ctrls:get(i)
        local code = ctrl:getModData()["AutoGate_gateFrequency_PAIRED"]
        if (not doorCode) and (not code) then
            return ctrl
        elseif doorCode and code then
            if code == doorCode then
                return ctrl
            end
        end
	end
    return nil
end

function AutoGate.UI.pairController(player, gateCtrl, door)
    AutoGate.Utils.pairGateCtrl(gateCtrl, door)
    player:Say("Controller paired, should make more copies!")
end

function AutoGate.UI.makeCopy(player, gateCtrl, pairedCtrl)
    AutoGate.Utils.makeCopy(gateCtrl, pairedCtrl)
    player:Say("Success!")
end

-- function AutoGate.UI.lockGate(gate)
--     for i, sq in ipairs(gate) do
--         sq:setIsLocked(true)
--     end
-- end

function AutoGate.UI.toggleAutoGate(player, obj, battery)
    --local ObjProp = tonumber(obj:getSquare():getProperties():Val("DoubleDoor"))
    --if obj:IsOpen() then
        --obj:ToggleDoor(player)
        --local gate = AutoGate.Utils.GetFullGate(obj,ObjProp)
        --AutoGate.UI.lockGate(gate)
    --else
        --obj:setIsLocked(false)
        --obj:ToggleDoor(player)
    --end
    if AutoGate.UI.checkDistance(player, obj) then
        obj:ToggleDoor(player)
        battery:setDelta(battery:getDelta() - 0.01)
    end
end

function AutoGate.UI.installGateMotor(player, sq1, sq2, obj)
    local sq = sq1
    if sq2:DistTo(player:getSquare()) < sq1:DistTo(player:getSquare()) then
        sq = sq2
    end

    ISTimedActionQueue.add(ISWalkToTimedAction:new(player, sq))
    ISTimedActionQueue.add(AutoGateAction:new(player, obj))
end

function AutoGate.UI.openFromInv(player, fqc)
    local square = getCell():getGridSquare(fqc[1],fqc[2],fqc[3])
    if square then
        local gate = AutoGate.Utils.GetGateFromSquare(square)
        if gate then
            if gate:getModData()["AutoGate_gateFrequency_PAIRED"] == fqc[4] then
                local battery = AutoGate.UI.getBattery(gate)
                if battery then
                    AutoGate.UI.toggleAutoGate(player, gate, battery)
                end
            end
        end
    end
end

function AutoGate.UI.checkDistance(player, obj)
    if obj:getSquare():DistTo(player:getSquare()) < 35 then
        return true
    end
    return false
end

function AutoGate.UI.contextInvObjMenuOptions(_player, context, invObjects)
    local player = getSpecificPlayer(_player)
    local itens = invObjects[1]["items"]
    if itens then
        for _,v in ipairs(itens) do
            if v:getType() == "GateController" then
                local fqc = AutoGate.Utils.GetFrequency(v)
                local useCtrl = context:addOption("Use", player, AutoGate.UI.openFromInv, fqc)
                if not fqc then
                    useCtrl.notAvailable = true
                    AutoGate.ToolTip.toolTipUse(useCtrl)
                else
                    local emptyCtrl = AutoGate.UI.findController(player, nil)
                    local copy = context:addOption("Make a copy", player, AutoGate.UI.makeCopy, emptyCtrl, v)
                    if not emptyCtrl then
                        copy.notAvailable = true
                        AutoGate.ToolTip.toolTipCopy(copy)
                    end
                end  
                break
            end
        end
    end
end

local origDoContextualDblClick = ISInventoryPane.doContextualDblClick

function ISInventoryPane:doContextualDblClick(item)
    if item:getType() == "GateController" then
        local fqc = AutoGate.Utils.GetFrequency(item)
        if fqc then
            local player = getPlayer()
            AutoGate.UI.openFromInv(player, fqc)
        end
    end
    return origDoContextualDblClick(self, item)
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnFillWorldObjectContextMenu.Add(AutoGate.UI.contextMenuOptions)
Events.OnFillInventoryObjectContextMenu.Add(AutoGate.UI.contextInvObjMenuOptions)
