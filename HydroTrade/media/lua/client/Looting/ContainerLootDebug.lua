ContainerLootDebug = ContainerLootDebug or {}

local function tryMethod(obj, methodName, ...)
    if not obj then
        return nil
    end
    local fn = obj[methodName]
    if type(fn) ~= "function" then
        return nil
    end
    local ok, result = pcall(fn, obj, ...)
    if ok then
        return result
    end
    return nil
end

local function tableHasEntries(t)
    if type(t) ~= "table" then
        return false
    end
    for _ in pairs(t) do
        return true
    end
    return false
end

local function safeClassName(obj)
    local cls = tryMethod(obj, "getClass")
    return tryMethod(cls, "getSimpleName") or "unknown"
end

local function formatValue(value)
    if value == nil then
        return "nil"
    end
    local t = type(value)
    if t == "boolean" then
        return value and "true" or "false"
    end
    if t == "number" or t == "string" then
        return tostring(value)
    end
    if t == "userdata" and instanceof(value, "IsoGridSquare") then
        return string.format("IsoGridSquare(%d,%d,%d)", value:getX(), value:getY(), value:getZ())
    end
    return tostring(value)
end

local function addRow(rows, section, key, value, raw)
    table.insert(rows, { section = section, key = key, value = formatValue(value), raw = raw })
end

local function flattenModData(rows, section, prefix, data)
    for k, v in pairs(data) do
        local path = prefix == "" and tostring(k) or (prefix .. "." .. tostring(k))
        if type(v) == "table" then
            flattenModData(rows, section, path, v)
        else
            addRow(rows, section, path, v, v)
        end
    end
end

function ContainerLootDebug.collectFullDebug(obj, container)
    local rows = {}
    local sq = ContainerLootBackup.getContainerSquare(obj, container)
    local room = sq and tryMethod(sq, "getRoom")
    local roomDef = room and tryMethod(room, "getRoomDef")
    local zone = sq and tryMethod(sq, "getZone")
    local building = sq and tryMethod(sq, "getBuilding")
    local buildingDef = building and tryMethod(building, "getDef")
    local md = obj and obj:getModData() or {}
    local worldAge = getGameTime():getWorldAgeHours()
    local reason = ContainerLootBackup.getRespawnReason(obj, container)
    local legacyStamp = ContainerLootBackup.needsEmptyStamp(obj, container)

    addRow(rows, "Meta", "worldAgeHours", worldAge)
    addRow(rows, "Meta", "backupEnabled", ContainerLootBackup.isEnabled())
    addRow(rows, "Meta", "HoursForLootRespawn", ContainerLootBackup.getRespawnHours())
    addRow(rows, "Meta", "MaxItemsForLootRespawn", ContainerLootBackup.getMaxItemsForLootRespawn())
    addRow(rows, "Meta", "needsEmptyStamp", legacyStamp)
    addRow(rows, "Meta", "respawnReason", reason or "none")
    addRow(rows, "Meta", "hoursUntilRespawn", ContainerLootBackup.getHoursUntilRespawn(obj))
    addRow(rows, "Meta", "vanillaLootRespawnHour", ContainerLootBackup.readBuildingLootRespawnHour(buildingDef))
    addRow(rows, "Meta", "vanillaHoursUntilRespawn", ContainerLootBackup.getVanillaHoursUntilRespawn(buildingDef))
    addRow(rows, "Meta", "SeenHoursPreventLootRespawn", ContainerLootBackup.getSeenHoursPreventLootRespawn())
    addRow(rows, "Meta", "eligible", ContainerLootBackup.isEligible(obj, container, false))

    if container then
        addRow(rows, "ItemContainer", "type", tryMethod(container, "getType"))
        addRow(rows, "ItemContainer", "isExplored", tryMethod(container, "isExplored"))
        addRow(rows, "ItemContainer", "isHasBeenLooted", tryMethod(container, "isHasBeenLooted"))
        addRow(rows, "ItemContainer", "items:size", container:getItems() and container:getItems():size(), container:getItems() and container:getItems():size())
        addRow(rows, "ItemContainer", "capacity", tryMethod(container, "getCapacity"))
        addRow(rows, "ItemContainer", "parentClass", safeClassName(obj))
        addRow(rows, "ItemContainer", "sourceGrid", tryMethod(container, "getSourceGrid"))

        local items = container:getItems()
        if items and items:size() > 0 then
            for i = 0, items:size() - 1 do
                local item = items:get(i)
                if item then
                    addRow(rows, "Items", "[" .. i .. "]", tryMethod(item, "getFullType") or tryMethod(item, "getType"))
                end
            end
        else
            addRow(rows, "Items", "list", "(empty)")
        end
    end

    if obj then
        addRow(rows, "IsoObject", "class", safeClassName(obj))
        addRow(rows, "IsoObject", "sprite", obj:getSprite() and tryMethod(obj:getSprite(), "getName"))
        addRow(rows, "IsoObject", "isIsoThumpable", instanceof(obj, "IsoThumpable"))
        addRow(rows, "IsoObject", "objectIndex", sq and ContainerLootBackup.getObjectIndex(sq, obj))
        if md and tableHasEntries(md) then
            flattenModData(rows, "Object.modData", "", md)
        else
            addRow(rows, "Object.modData", "(empty)", "true")
        end
    end

    if sq then
        addRow(rows, "IsoGridSquare", "coords", string.format("%d,%d,%d", sq:getX(), sq:getY(), sq:getZ()))
        addRow(rows, "IsoGridSquare", "isOverlayDone", tryMethod(sq, "isOverlayDone"))
        addRow(rows, "IsoGridSquare", "inSafehouse", ContainerLootBackup.isSafehouseSquare(sq))
    end

    if room then
        addRow(rows, "IsoRoom", "name", tryMethod(room, "getName"))
    end

    if roomDef then
        addRow(rows, "RoomDef", "name", tryMethod(roomDef, "getName"))
        addRow(rows, "RoomDef", "bExplored", tryMethod(roomDef, "isExplored"))
    end

    if zone then
        addRow(rows, "Zone", "type", tryMethod(zone, "getType"))
        addRow(rows, "Zone", "name", tryMethod(zone, "getName"))
    end

    if buildingDef then
        addRow(rows, "BuildingDef", "lootRespawnHour", ContainerLootBackup.readBuildingLootRespawnHour(buildingDef))
        addRow(rows, "BuildingDef", "hasBeenVisited", tryMethod(buildingDef, "isHasBeenVisited"))
    end

    addRow(rows, "ModData", "TimeEmptied", md.TimeEmptied, md.TimeEmptied)
    addRow(rows, "ModData", "TimeEmptied_ago", ContainerLootBackup.formatHoursAgo(worldAge, md.TimeEmptied))
    addRow(rows, "ModData", "PlayerLooter", md.PlayerLooter)
    addRow(rows, "ModData", "RespawnDelayHours", md.RespawnDelayHours)
    addRow(rows, "ModData", "RespawnCount", md.RespawnCount or 0)
    addRow(rows, "ModData", "LastRespawnAttempt", md.LastRespawnAttempt)
    addRow(rows, "ModData", "BackupFailed", md.BackupFailed == true, md.BackupFailed == true)

    local items = container and container:getItems()
    return {
        containerType = container and tryMethod(container, "getType") or "?",
        itemCount = items and items:size() or 0,
        isExplored = container and tryMethod(container, "isExplored"),
        hasBeenLooted = container and tryMethod(container, "isHasBeenLooted"),
        backupFailed = md.BackupFailed == true,
        eligible = ContainerLootBackup.isEligible(obj, container, false),
        ineligibleReason = reason or "none",
        respawnReason = reason,
        needsEmptyStamp = legacyStamp,
        hoursUntilRespawn = ContainerLootBackup.getHoursUntilRespawn(obj),
        vanillaHoursUntilRespawn = ContainerLootBackup.getVanillaHoursUntilRespawn(buildingDef),
        vanillaLootRespawnHour = ContainerLootBackup.readBuildingLootRespawnHour(buildingDef),
        debugRows = rows,
    }
end
