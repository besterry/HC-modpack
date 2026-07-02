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

local function handleEmptyContainer(playerObj, obj, container) -- Пустой explored: legacy-штамп или requestRespawn
    if ContainerLootBackup.needsLegacyStamp(obj, container) then
        local args = ContainerLootBackup.buildArgs(obj, container)
        if args then
            sendClientCommand(playerObj, MOD_NAME, "markEmptied", args)
        end
        return
    end
    requestRespawnIfNeeded(playerObj, obj, container)
end

local oldCheckExplored = ISInventoryPage.checkExplored
function ISInventoryPage:checkExplored(container, playerObj) -- Хук открытия контейнера
    if container:isExplored() then
        if isClient() and ContainerLootBackup.isEnabled() then
            local obj = container:getParent()
            if obj and container:getItems():size() == 0 then
                handleEmptyContainer(playerObj, obj, container)
            end
        end
        return
    end
    oldCheckExplored(self, container, playerObj)
end

local oldTransferPerform = ISInventoryTransferAction.perform
function ISInventoryTransferAction:perform() -- Хук переноса: опустошил мировой контейнер → markEmptied
    local src = self.srcContainer
    local srcParent = src and src:getParent()
    local wasWorld = src and not src:isInCharacterInventory(self.character)
    oldTransferPerform(self)
    if not isClient() or not ContainerLootBackup.isEnabled() then
        return
    end
    if wasWorld and srcParent and src:getItems():size() == 0 and src:isHasBeenLooted() then
        local args = ContainerLootBackup.buildArgs(srcParent, src)
        if args then
            sendClientCommand(self.character, MOD_NAME, "markEmptied", args)
        end
    end
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
                local label = getText("IGUI_ContainerLootBackup_AdminMenu") .. " [" .. container:getType() .. "]"
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
