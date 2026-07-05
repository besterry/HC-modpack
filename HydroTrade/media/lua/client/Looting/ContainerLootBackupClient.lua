-- КЛИЕНТ: хуки игрока. Читать после shared/ContainerLootBackup.lua

require "Looting/ContainerLootAdminPanel"
require "Looting/ContainerLootDebug"

local MOD_NAME = ContainerLootBackup.MOD_NAME

local function isStaff() -- Админ или модератор
    return isAdmin() or getAccessLevel() == "moderator"
end

local function openDebugPanel(playerObj, obj, container) -- Открыть админ-панель состояния
    ContainerLootAdminPanel.OnOpenPanel(ContainerLootDebug.collectFullDebug(obj, container), obj, container)
end

local function requestRespawnIfNeeded(playerObj, obj, container) -- Запрос спавна если getRespawnReason вернул причину
    if not ContainerLootBackup.getRespawnReason(obj, container) then
        return
    end
    local args = ContainerLootBackup.buildArgs(obj, container)
    if args then
        sendClientCommand(playerObj, MOD_NAME, "requestRespawn", args)
    end
end

local emptyContainerDebounce = {} -- ключ args → ms; refreshBackpacks дергается часто

local function sendMarkEmptied(playerObj, obj, container)
    local args = ContainerLootBackup.buildArgs(obj, container)
    if args then
        sendClientCommand(playerObj, MOD_NAME, "markEmptied", args)
    end
end

local function handleEmptyContainer(playerObj, obj, container, playerEmptied) -- Пустой explored: метка или timer_respawn
    if playerEmptied then
        sendMarkEmptied(playerObj, obj, container)
        return
    end
    if ContainerLootBackup.needsEmptyStamp(obj, container) then
        sendMarkEmptied(playerObj, obj, container)
        return
    end
    requestRespawnIfNeeded(playerObj, obj, container)
end

local function scanWorldContainer(playerObj, container) -- Проверка одного мирового контейнера в loot UI
    if not container or ContainerLootBackup.shouldSkipContainer(container) then
        return
    end
    if container:isInCharacterInventory(playerObj) then
        return
    end
    if not container:isExplored() or container:getItems():size() > 0 then
        return
    end
    local obj = container:getParent()
    if not obj then
        return
    end
    local args = ContainerLootBackup.buildArgs(obj, container)
    if not args then
        return
    end
    local key = args.x .. ":" .. args.y .. ":" .. args.z .. ":" .. args.index .. ":" .. args.containerIndex
    local now = getTimeInMillis()
    if emptyContainerDebounce[key] and now - emptyContainerDebounce[key] < 2000 then
        return
    end
    emptyContainerDebounce[key] = now
    handleEmptyContainer(playerObj, obj, container)
end

local oldCheckExplored = ISInventoryPage.checkExplored
function ISInventoryPage:checkExplored(container, playerObj) -- Хук первого открытия (vanilla: только !isExplored)
    if container:isExplored() then
        return
    end
    oldCheckExplored(self, container, playerObj)
    if isClient() and ContainerLootBackup.isEnabled() then
        local obj = container:getParent()
        if obj and container:getItems():size() == 0 then
            scanWorldContainer(playerObj, container)
        end
    end
end

local oldRefreshBackpacks = ISInventoryPage.refreshBackpacks
function ISInventoryPage:refreshBackpacks() -- Хук loot UI: explored пустые контейнеры (vanilla checkExplored их не трогает)
    oldRefreshBackpacks(self)
    if not isClient() or not ContainerLootBackup.isEnabled() or self.onCharacter then
        return
    end
    local playerObj = getSpecificPlayer(self.player)
    if not playerObj then
        return
    end
    if self.inventory then
        scanWorldContainer(playerObj, self.inventory)
    end
    for _, btn in ipairs(self.backpacks or {}) do
        scanWorldContainer(playerObj, btn.inventory)
    end
end

local oldTransferPerform = ISInventoryTransferAction.perform
function ISInventoryTransferAction:perform() -- Хук переноса: опустошил мировой контейнер
    local src = self.srcContainer
    local srcParent = src and src:getParent()
    local wasWorld = src and not src:isInCharacterInventory(self.character)
    oldTransferPerform(self)
    if not isClient() or not ContainerLootBackup.isEnabled() then
        return
    end
    if wasWorld and srcParent and src:getItems():size() == 0 then
        handleEmptyContainer(self.character, srcParent, src, true)
    end
end

local function formatSpawnTimerLabel(obj, container) -- Часы до спавна для пункта ПКМ-меню
    if ContainerLootBackup.getRespawnReason(obj, container) then
        return "0" .. getText("IGUI_ContainerLootBackup_HoursShort")
    end
    local left = ContainerLootBackup.getHoursUntilRespawn(obj)
    if left ~= nil then
        if left >= 10 then
            return string.format("%.0f%s", left, getText("IGUI_ContainerLootBackup_HoursShort"))
        end
        return string.format("%.1f%s", left, getText("IGUI_ContainerLootBackup_HoursShort"))
    end
    return getText("IGUI_ContainerLootBackup_AdminMenuSpawnNA")
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test) -- ПКМ: админ-меню контейнера
    if test and ISWorldObjectContextMenu.Test then
        return
    end
    if not isStaff() then
        return
    end
    local playerObj = getSpecificPlayer(player)
    local handled = {}
    for _, obj in ipairs(worldobjects) do
        if obj and not handled[obj] then
            handled[obj] = true
            local function addOpts(container)
                if ContainerLootBackup.shouldSkipContainer(container) then
                    return
                end
                local label = getText("IGUI_ContainerLootBackup_AdminMenu")
                    .. " [" .. container:getType() .. "]"
                    .. " (" .. formatSpawnTimerLabel(obj, container) .. ")"
                local subMenu = context:getNew(context)
                local root = context:addOption(label, nil, nil)
                context:addSubMenu(root, subMenu)
                subMenu:addOption(getText("IGUI_ContainerLootBackup_ShowState"), playerObj, openDebugPanel, obj, container)
                subMenu:addOption(getText("IGUI_ContainerLootBackup_ForceRefill"), playerObj, function(p, o, c)
                    local args = ContainerLootBackup.buildArgs(o, c)
                    if args then
                        sendClientCommand(p, MOD_NAME, "forceRefill", args)
                    end
                end, obj, container)
                subMenu:addOption(getText("IGUI_ContainerLootBackup_ResetState"), playerObj, function(p, o, c)
                    local args = ContainerLootBackup.buildArgs(o, c)
                    if args then
                        sendClientCommand(p, MOD_NAME, "resetState", args)
                    end
                end, obj, container)
            end
            if obj:getContainerCount() > 0 then
                for i = 0, obj:getContainerCount() - 1 do
                    addOpts(obj:getContainerByIndex(i))
                end
            elseif obj:getContainer() then
                addOpts(obj:getContainer())
            end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)
