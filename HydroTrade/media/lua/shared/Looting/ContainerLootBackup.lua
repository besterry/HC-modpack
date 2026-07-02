ContainerLootBackup = ContainerLootBackup or {}

-- =============================================================================
-- Общие правила для клиента и сервера. Порядок чтения:
--   1) isEnabled / isEligible          — какие ящики участвуют
--   2) needsLegacyStamp                — опустошил игрок: штамп TimeEmptied, спавн через N ч
--   3) getRespawnReason                — immediate_spawn / timer_respawn
--   4) client/ContainerLootBackupClient.lua — хуки открытия ития и опустошения
--   5) server/ContainerLootBackupServer.lua — спавн и команды
-- =============================================================================

ContainerLootBackup.MOD_NAME = "ContainerLootBackup"

-- Типы контейнеров, которые мод игнорирует полностью (vehicle + parent BaseVehicle/VehiclePart ниже)
ContainerLootBackup.SKIP_CONTAINER_TYPES = {
    inventorymale = true,
    inventoryfemale = true,
    floor = true,
    vehicle = true,
}

-- Включён ли backup (песочница LootingSystem.ContainerBackupEnable)
function ContainerLootBackup.isEnabled()
    return SandboxVars.LootingSystem and SandboxVars.LootingSystem.ContainerBackupEnable ~= false
end

-- Сколько раз вызывать fillContainer за одну попытку (песочница, default 10)
function ContainerLootBackup.getMaxAttempts()
    if SandboxVars.LootingSystem and SandboxVars.LootingSystem.ContainerBackupAttempts then
        return SandboxVars.LootingSystem.ContainerBackupAttempts
    end
    return 10
end

-- Часы до респавна лута (servertest.ini HoursForLootRespawn)
function ContainerLootBackup.getRespawnHours()
    if getServerOptions then
        return getServerOptions():getInteger("HoursForLootRespawn") or 0
    end
    return 0
end

-- Ванильный порог предметов для респавна (servertest.ini, только для админ-дебага)
function ContainerLootBackup.getMaxItemsForLootRespawn()
    if getServerOptions then
        return getServerOptions():getInteger("MaxItemsForLootRespawn") or 1
    end
    return 1
end

-- true = не мировой лут (инвентарь, пол, транспорт и т.п.)
function ContainerLootBackup.shouldSkipContainer(container)
    if not container or not instanceof(container, "ItemContainer") then
        return true
    end
    if ContainerLootBackup.SKIP_CONTAINER_TYPES[container:getType()] then
        return true
    end
    local parent = container:getParent()
    if not parent then
        return false
    end
    if instanceof(parent, "IsoPlayer")
        or instanceof(parent, "IsoZombie")
        or instanceof(parent, "IsoDeadBody")
        or instanceof(parent, "BaseVehicle")
        or instanceof(parent, "VehiclePart") then
        return true
    end
    return false
end

-- Клетка внутри сейфхауса
function ContainerLootBackup.isSafehouseSquare(sq)
    return sq and SafeHouse and SafeHouse.getSafeHouse(sq) ~= nil
end

-- Клетка контейнера на карте (безопасный доступ с клиента)
function ContainerLootBackup.getContainerSquare(obj, container)
    if container and type(container.getSourceGrid) == "function" then
        local sq = container:getSourceGrid()
        if sq then
            return sq
        end
    end
    if obj and type(obj.getSquare) == "function" then
        return obj:getSquare()
    end
    return nil
end

-- Ванильная мебель с лутом (не построенная игроком IsoThumpable)
function ContainerLootBackup.isWorldLootObject(obj)
    if not obj then
        return false
    end
    return not instanceof(obj, "IsoThumpable") and not instanceof(obj, "IsoCompost")
end

-- Подходит ли ящик для backup. allowForce=true обходит ограничения (админ refill)
-- Вне здания без room: только TownZone/TrailerPark. С room (office в DeepForest): OK
function ContainerLootBackup.isEligible(obj, container, allowForce) -- Подходит ли ящик для backup
    if ContainerLootBackup.shouldSkipContainer(container) then
        return false
    end
    if not obj then
        return false
    end
    if not allowForce and not ContainerLootBackup.isWorldLootObject(obj) then
        return false
    end
    local sq = ContainerLootBackup.getContainerSquare(obj, container)
    if not sq then
        return false
    end
    if not allowForce and ContainerLootBackup.isSafehouseSquare(sq) then
        return false
    end
    if not allowForce then
        local room = sq:getRoom()
        if not room then
            local zone = sq:getZone()
            local zt = zone and zone:getType() or nil
            if zt ~= "TownZone" and zt ~= "TownZones" and zt ~= "TrailerPark" then
                return false
            end
        end
    end
    return true
end

-- Индекс IsoObject на клетке (для сетевых команд клиент→сервер)
function ContainerLootBackup.getObjectIndex(square, obj) -- Индекс IsoObject на клетке
    if not square or not obj then
        return -1
    end
    for i = 0, square:getObjects():size() - 1 do
        if square:getObjects():get(i) == obj then
            return i
        end
    end
    return -1
end

-- Индекс объекта на клетке контейнера (multi-tile: parent может быть не на sourceGrid)
function ContainerLootBackup.getObjectIndexForContainer(square, obj, container)
    local idx = ContainerLootBackup.getObjectIndex(square, obj)
    if idx >= 0 then
        return idx
    end
    if not square or not container then
        return -1
    end
    for i = 0, square:getObjects():size() - 1 do
        local o = square:getObjects():get(i)
        if o == obj then
            return i
        end
        if o:getContainer() == container then
            return i
        end
        for j = 0, o:getContainerCount() - 1 do
            if o:getContainerByIndex(j) == container then
                return i
            end
        end
    end
    return -1
end

local function pickContainerFromObject(obj, containerIndex)
    if not obj then
        return nil
    end
    if containerIndex ~= nil and containerIndex >= 0 then
        return obj:getContainerByIndex(containerIndex)
    end
    return obj:getContainer()
end

-- Координаты объекта для sendClientCommand
function ContainerLootBackup.buildArgs(obj, container) -- Координаты для sendClientCommand
    if not obj or not container then
        return nil
    end
    local sq = ContainerLootBackup.getContainerSquare(obj, container)
    if not sq then
        return nil
    end
    local containerIndex = -1
    for i = 0, obj:getContainerCount() - 1 do
        if obj:getContainerByIndex(i) == container then
            containerIndex = i
            break
        end
    end
    return {
        x = sq:getX(),
        y = sq:getY(),
        z = sq:getZ(),
        index = ContainerLootBackup.getObjectIndexForContainer(sq, obj, container),
        containerIndex = containerIndex,
    }
end

-- Найти obj+container на сервере по args от клиента
function ContainerLootBackup.resolveContainer(args) -- Найти obj+container на сервере по args
    if not args then
        return nil, nil
    end
    local cell = getCell()
    if not cell then
        return nil, nil
    end
    local sq = cell:getGridSquare(args.x, args.y, args.z)
    if not sq then
        return nil, nil
    end
    local obj, container
    if args.index >= 0 and args.index < sq:getObjects():size() then
        obj = sq:getObjects():get(args.index)
        container = pickContainerFromObject(obj, args.containerIndex)
    end
    if not container then
        for i = 0, sq:getObjects():size() - 1 do
            local o = sq:getObjects():get(i)
            local c = pickContainerFromObject(o, args.containerIndex)
            if c then
                obj = o
                container = c
                break
            end
        end
    end
    return obj, container
end

-- Сброс ванильных procedural-счётчиков комнаты (для админ force refill)
function ContainerLootBackup.clearProceduralCounters(container) -- Сброс procedural-счётчиков комнаты (админ force)
    local sq = ContainerLootBackup.getContainerSquare(nil, container)
    if sq and sq:getRoom() and sq:getRoom():getRoomDef() then
        sq:getRoom():getRoomDef():getProceduralSpawnedContainer():clear()
    end
end

-- Legacy-ящик: пустой, explored, залутан, нет TimeEmptied в modData.
-- Не modData-флаг, а проверка на лету. Клиент шлёт markEmptied, спавн не просит.
function ContainerLootBackup.needsLegacyStamp(obj, container)
    if not ContainerLootBackup.isEnabled() then
        return false
    end
    if not ContainerLootBackup.isEligible(obj, container, false) then
        return false
    end
    if not container:isExplored() then
        return false
    end
    if container:getItems():size() > 0 then
        return false
    end

    local md = obj:getModData()
    if not container:isHasBeenLooted() then
        return false
    end
    if md.TimeEmptied then
        return false
    end

    return true
end

-- Нужен ли запрос спавна на сервер. nil = нет, иначе строка-причина:
--   "immediate_spawn" — пустой, hasBeenLooted=false, нет TimeEmptied (первая попытка)
--   "timer_respawn"   — TimeEmptied есть, прошло >= HoursForLootRespawn
-- BackupFailed не блокирует (только для админа в modData)
function ContainerLootBackup.getRespawnReason(obj, container)
    if not ContainerLootBackup.isEnabled() then
        return nil
    end
    if not ContainerLootBackup.isEligible(obj, container, false) then
        return nil
    end
    if not container:isExplored() then
        return nil
    end
    if container:getItems():size() > 0 then
        return nil
    end

    local md = obj:getModData()

    if not md.TimeEmptied then
        if not container:isHasBeenLooted() then
            return "immediate_spawn"
        end
        return nil
    end

    local respawnHours = ContainerLootBackup.getRespawnHours()
    if respawnHours <= 0 then
        return nil
    end

    local elapsed = getGameTime():getWorldAgeHours() - md.TimeEmptied
    if elapsed >= respawnHours then
        return "timer_respawn"
    end

    return nil
end

-- Сколько часов осталось до timer_respawn (для админ-панели)
function ContainerLootBackup.getHoursUntilRespawn(obj)
    local md = obj and obj:getModData() or {}
    local respawnHours = ContainerLootBackup.getRespawnHours()
    if not md.TimeEmptied or respawnHours <= 0 then
        return nil
    end
    local left = respawnHours - (getGameTime():getWorldAgeHours() - md.TimeEmptied)
    if left < 0 then
        return 0
    end
    return left
end

-- Ваниль: public field BuildingDef.lootRespawnHour (час worldAge когда здание получит респавн)
-- Возвращает number или nil если поле недоступно. 0 = ваниль ещё не запланировала респавн.
function ContainerLootBackup.readBuildingLootRespawnHour(buildingDef)
    if not buildingDef then
        return nil
    end
    local ok, hour = pcall(function()
        return buildingDef.lootRespawnHour
    end)
    if ok and type(hour) == "number" then
        return hour
    end
    ok, hour = pcall(function()
        local tbl = buildingDef:getTable()
        return tbl and tbl.lootRespawnHour or nil
    end)
    if ok and type(hour) == "number" then
        return hour
    end
    return nil
end

function ContainerLootBackup.getSeenHoursPreventLootRespawn()
    if getServerOptions then
        return getServerOptions():getInteger("SeenHoursPreventLootRespawn") or 0
    end
    return 0
end

-- Часы до ванильного респавна здания (не per-container). nil = поле недоступно, 0 = срок наступил.
function ContainerLootBackup.getVanillaHoursUntilRespawn(buildingDef)
    local targetHour = ContainerLootBackup.readBuildingLootRespawnHour(buildingDef)
    if targetHour == nil then
        return nil
    end
    if targetHour <= 0 then
        return nil
    end
    local left = targetHour - getGameTime():getWorldAgeHours()
    if left < 0 then
        return 0
    end
    return left
end

-- Форматирование "сколько часов назад" для админ-дебага
function ContainerLootBackup.formatHoursAgo(worldAgeHours, pastHours)
    if not pastHours or pastHours <= 0 then
        return "-"
    end
    local diff = worldAgeHours - pastHours
    if diff < 0 then
        diff = 0
    end
    return string.format("%.1f h ago", diff)
end
