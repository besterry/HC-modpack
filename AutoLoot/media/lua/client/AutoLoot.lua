PM = PM or {}
PM.desiredItemsSet = PM.desiredItemsSet or {}
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {}
PM.InventorySelected = PM.InventorySelected or {}
PM.AutolootDurationAction = PM.AutolootDurationAction or {}
PM.TimeActivateAutoLoot = PM.TimeActivateAutoLoot or {} --Когда был куплен автолут
PM.AutoLootMessage = PM.AutoLootMessage or {}

local function reloadSell() --Обновление списка предметов кажды игровой час
    PM.desiredItemsSet = {}
    for fulltype, item in pairs(Shop.Sell) do
        PM.desiredItemsSet[fulltype] = true
    end
end
Events.EveryTenMinutes.Add(reloadSell)

local checkTimeActivate = false
local function calculateTime() --Рассчет оставшегося времени активации
    sendClientCommand(getPlayer(), 'BalanceAndSH', 'getServerTime', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'BalanceAndSH' then return; end
        if command == 'onGetServerTime1' then
            if type(PM.TimeActivateAutoLoot) ~= "table" then
                --print("PM.AutolootDurationAction:",PM.AutolootDurationAction," + PM.TimeActivateAutoLoot:",PM.TimeActivateAutoLoot)
                local subscriptionDuration = PM.AutolootDurationAction * 24 * 60 * 60  -- дней подписки в секундах   
                local remainingTime = PM.TimeActivateAutoLoot + subscriptionDuration - string.format("%.3f", args.time)-- Оставшееся время в секундах
                if remainingTime <=0 then checkTimeActivate=false else checkTimeActivate=true end
            end
            Events.OnServerCommand.Remove(receiveServerCommand)
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end
Events.EveryTenMinutes.Add(calculateTime)

-- function GetTimeActivateAutoLootForcalculateTime() --Получение времени покупки
--     print("GETPLAYER:",getPlayer())
--     sendClientCommand(getPlayer(), 'BalanceAndSH', 'getDataAutoLoot', nil)
--     local receiveServerCommand
--     receiveServerCommand = function(module, command, args)
--         if module ~= 'BalanceAndSH' then return; end
--         if command == 'onGetDataAutoLoot' then
--             if args['UserData'].autoloot ~= nil and args['UserData'].autoloot>0 then
--                 PM.TimeActivateAutoLoot = args['UserData'].autoloot
--                 print("PM.TimeActivateAutoLoot on DB:",PM.TimeActivateAutoLoot)
--             end          
--             calculateTime()
--             reloadSell()
--             Events.OnServerCommand.Remove(receiveServerCommand)
--         end
--     end
--     Events.OnServerCommand.Add(receiveServerCommand)
-- end
-- Events.OnGameStart.Add(GetTimeActivateAutoLootForcalculateTime)

function GetTimeActivateAutoLootForcalculateTime() --Получение времени покупки
    local player = getPlayer()
    if not player then return end
    --print("GETPLAYER:",player)
    sendClientCommand(player, 'BalanceAndSH', 'getDataAutoLoot', nil)    
    local function receiveServerCommand(module, command, args)
        if module ~= 'BalanceAndSH' then return; end
        if command ~='onGetDataAutoLoot' then return; end
        if args['UserData'].autoloot and args['UserData'].autoloot ~= nil and args['UserData'].autoloot>0 then
            PM.TimeActivateAutoLoot = args['UserData'].autoloot
            --print("PM.TimeActivateAutoLoot on DB:",PM.TimeActivateAutoLoot)
        else
            PM.TimeActivateAutoLoot = 0 --Test FIX
        end          
        calculateTime()
        reloadSell()
        Events.OnServerCommand.Remove(receiveServerCommand)
    end
    Events.OnServerCommand.Add(receiveServerCommand)
    Events.OnTick.Remove(GetTimeActivateAutoLootForcalculateTime)
end
Events.OnTick.Add(GetTimeActivateAutoLootForcalculateTime)
-- GetTimeActivateAutoLootForcalculateTime()


local function AutoLoot(zombie) --автолут
    if PM.Autoloot and checkTimeActivate then
        --print("AUTOLOOTING START")
        local player = getPlayer()
        local zombieInventory = zombie:getInventory()
        local inv
        --Если не задана сумка в UI        
        if type(PM.InventorySelected) == "table" then
            PM.InventorySelected = player
        end
        --Если сумка не одета переключение на основной инвентарь
        if PM.InventorySelected:getInventory() == player:getInventory() then
        elseif not PM.InventorySelected:isEquipped() then
            player:Say(getText("IGUI_Bag_UnEquipped"))
            PM.InventorySelected = player
        end
        inv=PM.InventorySelected:getInventory()
        --Проверка есть ли перк организованного, рассчет вместимости
        local capacitybag
        if inv ~= nil then
            local character = inv:getCharacter()
            local charactertrait = character:getCharacterTraits()
            if charactertrait:contains("Organized") and PM.InventorySelected ~= player then
                capacitybag = inv:getCapacity()*1.27
            else 
                capacitybag = inv:getCapacity()
            end
        end

        --Проверка категории предмета с выбранными в опциях
        local function isDesiredItem(item)
            local itemDisplayCategory = item:getDisplayCategory()
            --print("FIND ITEM:",item:getFullType()," Category:",itemDisplayCategory)
            if PM.AutolootDisplayCategory[itemDisplayCategory] then
                local itemType = item:getFullType()
                return PM.desiredItemsSet[itemType] == true
            end
        end

        --Автолут, если есть место
        local lootCount = zombieInventory:getItems():size()
        --print("LOOT SIZE:",lootCount)
        for i = lootCount, 1, -1 do
            local item = zombieInventory:getItems():get(i - 1)
            --print("LOL ITEM:",i," - ",item:getFullType())
            if isDesiredItem(item) then
               
                if inv ~= nil then
                    if (inv:getCapacityWeight() + item:getWeight()) <= capacitybag then
                        local itemName = item:getDisplayName()
                        if PM.AutoLootMessage then
                            player:Say("+" .. itemName)
                        end
                        inv:AddItem(item)
                    else
                        player:Say(getText("IGUI_Bag_is_full"))
                        break
                    end
                end
            end
        end
    --zombie:DoDeath()
    end
end
--Events.OnZombieDead.Add(onZombieKill)
local old_event_trigger = Events.OnZombieDead.Add--переопределение функции OnZombieDead
Events.OnZombieDead.Add = function (fn_handler)
    local custom_handler = function (zombie)
        fn_handler(zombie)
        AutoLoot(zombie)
    end
    old_event_trigger(custom_handler)
end