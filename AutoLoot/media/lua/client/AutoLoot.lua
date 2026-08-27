PM = PM or {}
PM.desiredItemsSet = PM.desiredItemsSet or {} --Список собираемых предметов, формируется из Shop.Sell
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {} --Категории собираемоего лута
PM.AutolootCustomItems = PM.AutolootCustomItems or {} -- Свои предметы (вне скупки), до AUTOLOOT_CUSTOM_MAX
PM.InventorySelected = PM.InventorySelected or {} --Выбранный инвентарь для автолута
PM.AutolootDurationAction = PM.AutolootDurationAction or {} --Время действия автолута в днях
PM.TimeActivateAutoLoot = PM.TimeActivateAutoLoot or {} --Когда был куплен автолут
PM.AutoLootMessage = PM.AutoLootMessage or {} --Оповещение о собираемых предметах


local function GetSellItems(callback)
    sendClientCommand(getPlayer(), 'shopItems', 'getData', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'shopItems' then return; end
        if command == 'onGetData' then
            if callback then callback(args['forSellItems']) end
            Events.OnServerCommand.Remove(receiveServerCommand)            
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end

local function reloadSell() --Обновление списка предметов кажды игровой час
    PM.desiredItemsSet = {}
    GetSellItems(function(forSellItems)
        for fulltype, item in pairs(forSellItems) do
            PM.desiredItemsSet[fulltype] = true
        end
    end)
end
Events.EveryHours.Add(reloadSell)

local checkTimeActivate = false

function AutoLoot_SetSubscriptionActive(active, serverTime)
    if serverTime ~= nil then
        local t = tonumber(serverTime) or serverTime
        PM.TimeActivateAutoLoot = t
        PM.AutoLootLastServerTime = t
        PM.AutoLootLastServerTimeLocal = os.time()
    end
    checkTimeActivate = active and true or false
end

local function calculateTime() --Рассчет оставшегося времени активации
    sendClientCommand(getPlayer(), 'BalanceAndSH', 'getServerTime', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'BalanceAndSH' then return end
        if command ~= 'onGetServerTime1' then return end
        Events.OnServerCommand.Remove(receiveServerCommand)
        -- не трогаем подписку, пока идёт покупка (этот же ответ обработает Purchase)
        if PM.AutoLootPurchasePending then return end
        local activate = tonumber(PM.TimeActivateAutoLoot)
        local durationDays = tonumber(PM.AutolootDurationAction) or 0
        local serverTime = tonumber(args.time) or 0
        PM.AutoLootLastServerTime = serverTime
        PM.AutoLootLastServerTimeLocal = os.time()
        if activate and activate > 0 then
            local remaining = activate + durationDays * 24 * 60 * 60 - serverTime
            checkTimeActivate = remaining > 0
        else
            checkTimeActivate = false
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end
Events.EveryTenMinutes.Add(calculateTime)

function GetTimeActivateAutoLootForcalculateTime() --Получение времени покупки при заходе игрока
    local player = getPlayer()
    if not player then return end
    sendClientCommand(player, 'BalanceAndSH', 'getDataAutoLoot', nil)
    local function receiveServerCommand(module, command, args)
        if module ~= 'BalanceAndSH' then return end
        if command ~= 'onGetDataAutoLoot' then return end
        -- во время покупки не затираем только что выставленное время
        if PM.AutoLootPurchasePending then
            Events.OnServerCommand.Remove(receiveServerCommand)
            return
        end
        local autoloot = args['UserData'] and args['UserData'].autoloot
        autoloot = tonumber(autoloot) or 0
        if autoloot > 0 then
            PM.TimeActivateAutoLoot = autoloot
        else
            PM.TimeActivateAutoLoot = 0
        end
        calculateTime()
        reloadSell()
        Events.OnServerCommand.Remove(receiveServerCommand)
    end
    Events.OnServerCommand.Add(receiveServerCommand)
    Events.OnTick.Remove(GetTimeActivateAutoLootForcalculateTime)
end
Events.OnTick.Add(GetTimeActivateAutoLootForcalculateTime)


-- Тики: ~3 после трупа (Hydrocraft OnZombieDead), ~60 на ответ fill (~1–2 с)
local AUTOLOOT_HC_DELAY_TICKS = 3
local AUTOLOOT_FILL_TIMEOUT_TICKS = 60
local AUTOLOOT_CORPSE_WAIT_TICKS = 300

local function isWalletContainer(item)
    if not item then return false end
    if item.getBodyLocation and item:getBodyLocation() == "Wallet" then
        return true
    end
    if item.canBeEquipped and item:canBeEquipped() == "Wallet" then
        return true
    end
    local itemType = item.getType and item:getType()
    if itemType and string.find(itemType, "Wallet", 1, true) == 1 then
        return true
    end
    return false
end

local function isDesiredItem(item)
    if not item then return false end
    -- Кошельки не забираем (внутри свои ограничения)
    if isWalletContainer(item) then
        return false
    end
    local fullType = item:getFullType()
    -- Свои предметы: вне скупки и без фильтра категорий
    if PM.AutolootCustomItems and PM.AutolootCustomItems[fullType] then
        return true
    end
    local itemDisplayCategory = item:getDisplayCategory()
    if not (PM.AutolootDisplayCategory[itemDisplayCategory] or itemDisplayCategory == nil) then
        return false
    end
    return PM.desiredItemsSet[fullType] == true
end

local function disableAutoLootOverflow(player)
    if not PM.Autoloot then return end
    PM.Autoloot = false
    if AutoLoot_SaveConfig then
        AutoLoot_SaveConfig()
    end
    local msg = getText("IGUI_AutoLoot_DisabledFull")
    if player.setHaloNote then
        player:setHaloNote(msg, 255, 160, 80, 400)
    end
    player:Say(msg)
    if UI_AutoLoot and UI_AutoLoot.instance and UI_AutoLoot.instance.refreshPowerVisual then
        UI_AutoLoot.instance:refreshPowerVisual()
    end
end

-- Перенос как ISInventoryTransferAction: серверное удаление с трупа + локальный AddItem
local function transferLootItem(player, srcContainer, destInv, item)
    if instanceof(item, "AlarmClockClothing") and item:isAlarmSet() then
        item:setAlarmSet(false)
    end
    if isClient() then
        srcContainer:removeItemOnServer(item)
    end
    srcContainer:DoRemoveItem(item)
    srcContainer:setHasBeenLooted(true)
    srcContainer:setDrawDirty(true)
    destInv:AddItem(item)
    destInv:setDrawDirty(true)
    if PM.AutoLootMessage then
        player:Say("+" .. item:getDisplayName())
    end
end

local function AutoLoot(srcContainer)
    if not PM.Autoloot or not checkTimeActivate then return end
    if not srcContainer or not instanceof(srcContainer, "ItemContainer") then return end

    local player = getPlayer()
    if not player then return end

    if type(PM.InventorySelected) == "table" then
        PM.InventorySelected = player
    end
    -- Бумажник / снятая сумка → основной инвентарь
    if PM.InventorySelected ~= player then
        local badBag = false
        if not PM.InventorySelected:isEquipped() then
            badBag = true
            player:Say(getText("IGUI_Bag_UnEquipped"))
        elseif (PM.InventorySelected.getBodyLocation and PM.InventorySelected:getBodyLocation() == "Wallet")
            or (PM.InventorySelected.canBeEquipped and PM.InventorySelected:canBeEquipped() == "Wallet") then
            badBag = true
        end
        if badBag then
            PM.InventorySelected = player
        end
    end

    local inv = PM.InventorySelected:getInventory()
    if not inv then return end

    local items = srcContainer:getItems()
    if not items then return end
    for i = items:size() - 1, 0, -1 do
        if not PM.Autoloot then return end
        local item = items:get(i)
        if isDesiredItem(item) then
            if inv:hasRoomFor(player, item) then
                transferLootItem(player, srcContainer, inv, item)
            else
                disableAutoLootOverflow(player)
                return
            end
        end
    end
end

local function requestVanillaFill(corpse)
    if not corpse then return end
    local inv = corpse:getContainer()
    if not inv or inv:isExplored() then return end
    if isClient() then
        inv:requestServerItemsForContainer()
    elseif ItemPicker and ItemPicker.fillContainer then
        ItemPicker.fillContainer(inv, getPlayer())
    end
end

-- Проход 1: HC/уже лежащий лут. Проход 2: после ванильного fill (тихий «осмотр»).
local function runAutoLootPasses(corpse)
    local container = corpse:getContainer()
    if not container then return end

    local delay = AUTOLOOT_HC_DELAY_TICKS
    local function afterHcDelay()
        delay = delay - 1
        if delay > 0 then return end
        Events.OnTick.Remove(afterHcDelay)

        container = corpse:getContainer()
        if container then
            AutoLoot(container)
        end

        requestVanillaFill(corpse)

        local waitFill = AUTOLOOT_FILL_TIMEOUT_TICKS
        local function waitFillTick()
            local c = corpse:getContainer()
            if not c then
                Events.OnTick.Remove(waitFillTick)
                return
            end
            if c:isExplored() or waitFill <= 0 then
                Events.OnTick.Remove(waitFillTick)
                AutoLoot(c)
                return
            end
            waitFill = waitFill - 1
        end
        Events.OnTick.Add(waitFillTick)
    end
    Events.OnTick.Add(afterHcDelay)
end

local function AutoLoot_OnZombieDead(zombie)
    if not PM.Autoloot or not checkTimeActivate then return end
    if not zombie then return end
    local inv = zombie:getInventory()
    if not inv then return end

    local ticks = 0
    local function waitCorpse()
        ticks = ticks + 1
        local parent = inv:getParent()
        if parent and instanceof(parent, "IsoDeadBody") then
            Events.OnTick.Remove(waitCorpse)
            runAutoLootPasses(parent)
            return
        end
        if ticks >= AUTOLOOT_CORPSE_WAIT_TICKS then
            Events.OnTick.Remove(waitCorpse)
        end
    end
    Events.OnTick.Add(waitCorpse)
end

Events.OnZombieDead.Add(AutoLoot_OnZombieDead)