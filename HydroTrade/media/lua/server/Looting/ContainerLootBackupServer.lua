-- СЕРВЕР: спавн лута и modData. Читать после client/ContainerLootBackupClient.lua

if isClient() then
    return
end

local MOD_NAME = ContainerLootBackup.MOD_NAME

local function syncContainer(obj, container) -- Синхронизировать содержимое контейнера клиентам после спавна
    if isServer() then
        sendItemsInContainer(obj, container)
    end
end

local function markEmptied(obj, player) -- Запись в modData времени опустошения и кто опустошил
    local md = obj:getModData()
    md.TimeEmptied = getGameTime():getWorldAgeHours()
    md.PlayerLooter = player and player:getUsername() or "unknown"
    md.BackupFailed = false
    obj:transmitModData()
end

function ContainerLootBackup.tryRespawn(obj, container, player, reason, force) -- fillContainer до N попыток; force=админ
    if not ContainerLootBackup.isEnabled() then
        return false
    end
    if not obj or not container then
        return false
    end
    if not ContainerLootBackup.isEligible(obj, container, force == true) then
        return false
    end
    local md = obj:getModData()
    if container:getItems():size() > 0 and not force then
        return false
    end
    if not force then
        local checkReason = ContainerLootBackup.getRespawnReason(obj, container)
        if not checkReason then
            return false
        end
        reason = checkReason
    else
        md.BackupFailed = false
        ContainerLootBackup.clearProceduralCounters(container)
    end
    local maxAttempts = ContainerLootBackup.getMaxAttempts()
    local hadItems = false
    for i = 1, maxAttempts do
        ItemPicker.fillContainer(container, player)
        if container:getItems():size() > 0 then
            hadItems = true
            break
        end
        if force and i == 1 then
            ContainerLootBackup.clearProceduralCounters(container)
        end
    end
    local now = getGameTime():getWorldAgeHours()
    md.LastRespawnAttempt = now
    if hadItems then
        md.RespawnCount = (md.RespawnCount or 0) + 1
        md.BackupFailed = false
        md.TimeEmptied = nil
        obj:transmitModData()
        syncContainer(obj, container)
        return true
    end
    md.BackupFailed = true -- только для админа, не блокирует следующие попытки
    obj:transmitModData()
    return false
end

local function onFillContainer(roomType, containerType, container) -- Ваниль fillContainer дал пусто → broken_spawn
    if not ContainerLootBackup.isEnabled() then
        return
    end
    if ContainerLootBackup.shouldSkipContainer(container) then
        return
    end
    if container:getItems():size() > 0 then
        return
    end
    local obj = container:getParent()
    if not obj then
        return
    end
    if not container:isHasBeenLooted() then
        ContainerLootBackup.tryRespawn(obj, container, nil, "broken_spawn", false)
    end
end
Events.OnFillContainer.Add(onFillContainer)

local Commands = {}

Commands.markEmptied = function(player, args) -- Опустошение или legacy-штамп; не перезаписывает TimeEmptied
    local obj, container = ContainerLootBackup.resolveContainer(args)
    if not obj or not container then
        return
    end
    if container:getItems():size() > 0 then
        return
    end
    if not container:isHasBeenLooted() then
        return
    end
    local md = obj:getModData()
    if md.TimeEmptied then
        return
    end
    markEmptied(obj, player)
end

Commands.requestRespawn = function(player, args) -- Клиент: broken_spawn или timer_respawn
    local obj, container = ContainerLootBackup.resolveContainer(args)
    if not obj or not container then
        return
    end
    local reason = ContainerLootBackup.getRespawnReason(obj, container)
    if not reason then
        return
    end
    ContainerLootBackup.tryRespawn(obj, container, player, reason, false)
end

Commands.forceRefill = function(player, args) -- Админ: принудительный спавн
    if player:getAccessLevel() ~= "Admin" and player:getAccessLevel() ~= "moderator" then
        return
    end
    local obj, container = ContainerLootBackup.resolveContainer(args)
    if not obj or not container then
        return
    end
    ContainerLootBackup.tryRespawn(obj, container, player, "admin_force", true)
end

Commands.resetState = function(player, args) -- Админ: сброс modData backup
    if player:getAccessLevel() ~= "Admin" and player:getAccessLevel() ~= "moderator" then
        return
    end
    local obj, container = ContainerLootBackup.resolveContainer(args)
    if not obj then
        return
    end
    local md = obj:getModData()
    md.TimeEmptied = nil
    md.PlayerLooter = nil
    md.RespawnCount = 0
    md.LastRespawnAttempt = nil
    md.BackupFailed = false
    obj:transmitModData()
end

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= MOD_NAME then
        return
    end
    if Commands[command] then
        Commands[command](player, args)
    end
end)
