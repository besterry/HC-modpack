-- Не снимать противогаз при разборе авто (VehicleRecycling грузится после HydroTrade).

RecycleVehicleMaskFix = RecycleVehicleMaskFix or {}

local function hasEquippedProtectiveMask(player)
    if not player then return false end

    if protectiveMaskEquipped then
        return protectiveMaskEquipped(player)
    end

    local types = ProtectiveMasks
    if not types then return false end

    local items = player:getInventory():getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if player:isEquippedClothing(item) then
            local iType = item:getType()
            for j = 1, #types do
                if types[j] == iType then
                    local percent = item:getModData().percent
                    if percent == nil or percent > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function RecycleVehicleMaskFix.shouldKeepProtectiveMaskOn(player)
    if not player then return false end
    if isInToxicZone and isInToxicZone(player) then
        return true
    end
    return hasEquippedProtectiveMask(player)
end

function RecycleVehicleMaskFix.installWearItemHook()
    if RecycleVehicleMaskFix.hookInstalled then return end
    if not ISInventoryPaneContextMenu or not ISInventoryPaneContextMenu.wearItem then return end

    local originalWearItem = ISInventoryPaneContextMenu.wearItem
    ISInventoryPaneContextMenu.wearItem = function(item, playerNum)
        if item and item:getType() == "WeldingMask" then
            local player = getSpecificPlayer(playerNum)
            if RecycleVehicleMaskFix.shouldKeepProtectiveMaskOn(player) then
                return
            end
        end
        return originalWearItem(item, playerNum)
    end

    RecycleVehicleMaskFix.hookInstalled = true
end

RecycleVehicleMaskFix.installWearItemHook()
Events.OnGameStart.Add(RecycleVehicleMaskFix.installWearItemHook)
