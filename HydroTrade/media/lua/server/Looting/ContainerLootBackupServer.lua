-- СЕРВЕР: спавн лута и modData. Читать после client/ContainerLootBackupClient.lua

if isClient() then
    return
end

local MOD_NAME = ContainerLootBackup.MOD_NAME
local fillingFromBackup = false -- guard: fillContainer триггерит OnFillContainer → без этого stack overflow

local function syncContainer(obj, container) -- Синхронизировать содержимое контейнера клиентам после спавна
    if isServer() then
        sendItemsInContainer(obj, container)
    end
end

local function rollRespawnDelayHours() -- HoursForLootRespawn + случайные 0..24 ч
    local base = ContainerLootBackup.getRespawnHours()
    if base <= 0 then
        return 0
    end
    return base + ZombRand(0, 24)
end

local function stampEmptyRecord(obj, player) -- TimeEmptied + PlayerLooter + RespawnDelayHours
    local md = obj:getModData()
    md.TimeEmptied = getGameTime():getWorldAgeHours()
    md.PlayerLooter = player and player:getUsername() or "unknown"
    md.RespawnDelayHours = rollRespawnDelayHours()
    obj:transmitModData()
end

local function markEmptied(obj, player) -- Игрок опустошил: штамп и сброс BackupFailed
    local md = obj:getModData()
    if md.TimeEmptied then
        return
    end
    stampEmptyRecord(obj, player)
    md.BackupFailed = false
    obj:transmitModData()
end

local function recordFailedRespawn(obj, container, player) -- Провал N попыток: штамп если нет, иначе сдвиг таймера
    local md = obj:getModData()
    local now = getGameTime():getWorldAgeHours()
    if not md.TimeEmptied then
        stampEmptyRecord(obj, player)
    else
        md.TimeEmptied = now
        md.RespawnDelayHours = rollRespawnDelayHours()
        if player then
            md.PlayerLooter = player:getUsername()
        end
    end
    md.LastRespawnAttempt = now
    md.BackupFailed = true
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
    fillingFromBackup = true
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
    fillingFromBackup = false
    if hadItems then
        md.RespawnCount = (md.RespawnCount or 0) + 1
        md.BackupFailed = false
        md.TimeEmptied = nil
        md.RespawnDelayHours = nil
        md.LastRespawnAttempt = getGameTime():getWorldAgeHours()
        obj:transmitModData()
        ItemPicker.updateOverlaySprite(obj)
        syncContainer(obj, container)
        return true
    end
    recordFailedRespawn(obj, container, player) -- BackupFailed для админа; таймер N ч для следующей попытки
    return false
end

local Commands = {}

Commands.markEmptied = function(player, args) -- Пустой ящик: штамп TimeEmptied, ждём N ч
    local obj, container = ContainerLootBackup.resolveContainer(args)
    if not obj or not container then
        return
    end
    if container:getItems():size() > 0 then
        return
    end
    markEmptied(obj, player)
end

Commands.requestRespawn = function(player, args) -- Клиент: timer_respawn
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
    md.RespawnDelayHours = nil
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
