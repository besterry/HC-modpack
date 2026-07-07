if not isClient() then return end

CI_KeyRing = CI_KeyRing or {}

local MAX_HISTORY_ENTRIES = 10
local MODDATA_KEY = "CI_vehicleHistory"

local function getDateString()
    return os.date("%H:%M  %d.%m.%y", (getTimeInMillis() + 10800000) / 1000)
end

local function getVehicleSqlId(vehicle)
    local modData = vehicle:getModData()
    if modData and modData.sqlId then
        return modData.sqlId
    end
    return vehicle:getSqlId()
end

local function getVehicleModelName(vehicle)
    local script = vehicle:getScript()
    if not script then return "Unknown" end
    return script:getName()
end

function CI_KeyRing.findKeyRing(player)
    if not player then return nil end

    local equippedRing = nil
    local anyRing = nil

    local function scan(container)
        if not container then return end
        local items = container:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if item:getType() == "KeyRing" then
                if item:isEquipped() then
                    equippedRing = item
                elseif not anyRing then
                    anyRing = item
                end
            end
            if item:IsInventoryContainer() and item:getInventory() then
                scan(item:getInventory())
            end
        end
    end

    scan(player:getInventory())
    return equippedRing or anyRing
end

function CI_KeyRing.getHistory(keyRing)
    if not keyRing then return {} end
    local history = keyRing:getModData()[MODDATA_KEY]
    if type(history) ~= "table" then return {} end
    return history
end

local function syncKeyRing(keyRing)
    if isClient() and keyRing.transmitCompleteItemToServer then
        keyRing:transmitCompleteItemToServer()
    end
end

function CI_KeyRing.stamp(player, vehicle, action)
    -- if isAdmin() then return end
    if not player or not vehicle then return end

    local keyRing = CI_KeyRing.findKeyRing(player)
    if not keyRing then return end

    local sqlId = getVehicleSqlId(vehicle)
    if not sqlId then return end
    sqlId = tonumber(sqlId) or sqlId

    local model = getVehicleModelName(vehicle)
    local dateStr = getDateString()
    local history = CI_KeyRing.getHistory(keyRing)
    local entryIndex = nil

    for i, entry in ipairs(history) do
        local entrySqlId = tonumber(entry.sqlId) or entry.sqlId
        if entrySqlId == sqlId then
            entryIndex = i
            break
        end
    end

    if entryIndex then
        local entry = history[entryIndex]
        entry.model = model
        entry.date = dateStr
        entry.active = action == "enter"
        table.remove(history, entryIndex)
        table.insert(history, 1, entry)
    else
        table.insert(history, 1, {
            sqlId = sqlId,
            model = model,
            date = dateStr,
            active = action == "enter",
        })
    end

    while #history > MAX_HISTORY_ENTRIES do
        table.remove(history)
    end

    keyRing:getModData()[MODDATA_KEY] = history
    syncKeyRing(keyRing)
end

local function getVehicleByIdSafe(vehicleId)
    if vehicleId == nil then return nil end
    local ok, vehicle = pcall(getVehicleById, vehicleId)
    if ok then return vehicle end
    return nil
end

local function onEnterVehicle(player)
    local vehicle = player:getVehicle()
    if not vehicle then return end
    CI_KeyRing.stamp(player, vehicle, "enter")
end

local function onExitVehicle(player)
    if not player then return end

    local vehicleId = CI_KeyRing.lastVehicleId
    if not vehicleId then return end

    local vehicle = player:getVehicle()
    if vehicle and vehicle:getId() == vehicleId then
        CI_KeyRing.stamp(player, vehicle, "exit")
        return
    end

    vehicle = getVehicleByIdSafe(vehicleId)
    if vehicle then
        CI_KeyRing.stamp(player, vehicle, "exit")
    end
end

CI_KeyRing.lastVehicleId = nil

local function onEnterVehicleTrackId(player)
    local vehicle = player:getVehicle()
    if vehicle then
        CI_KeyRing.lastVehicleId = vehicle:getId()
    end
    onEnterVehicle(player)
end

local function onExitVehicleTrackId(player)
    onExitVehicle(player)
    CI_KeyRing.lastVehicleId = nil
end

Events.OnEnterVehicle.Add(onEnterVehicleTrackId)
Events.OnExitVehicle.Add(onExitVehicleTrackId)

local function onFillInventoryObjectContextMenu(playerIndex, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items or #items ~= 1 then return end

    local item = items[1]
    if not item or item:getType() ~= "KeyRing" then return end

    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    context:addOption(getText("IGUI_CI_KeyRingHistory"), player, CI_KeyRing.openHistoryUI, item)
end

Events.OnFillInventoryObjectContextMenu.Add(onFillInventoryObjectContextMenu)
