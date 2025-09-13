PM = PM or {}
PM.desiredItemsSet = PM.desiredItemsSet or {} --Список собираемых предметов, формируется из Shop.Sell
PM.AutolootDisplayCategory = PM.AutolootDisplayCategory or {} --Категории собираемоего лута (["Ammo"]: boolean = true, ["Junk"]: boolean = false и т.д.)
PM.InventorySelected = PM.InventorySelected or {} --Выбранный инвентарь для автолута
PM.AutolootDurationAction = PM.AutolootDurationAction or {} --Время действия автолута в днях (настройка песочницы SandboxVars.AutoLoot.DurabilityAutoLoot)
PM.TimeActivateAutoLoot = PM.TimeActivateAutoLoot or {} --Когда был куплен автолут
PM.AutoLootMessage = PM.AutoLootMessage or {} --True/false включено ли "оповещение о собираемых предметах над головой игрока"


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

function GetTimeActivateAutoLootForcalculateTime() --Получение времени покупки при заходе игрока
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


local function AutoLoot(zombie) --автолут
    if PM.Autoloot and checkTimeActivate then
        local player = getPlayer()
        -- local zombieInventory = zombie:getInventory()
        local zombieInventory = zombie
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
            -- print("FIND ITEM:",item:getFullType()," Category:",itemDisplayCategory)
            if PM.AutolootDisplayCategory[itemDisplayCategory] or itemDisplayCategory == nil then                
                local itemType = item:getFullType()
                -- print("FIND ITEM:",item:getFullType()," Category:",itemDisplayCategory)
                return PM.desiredItemsSet[itemType] == true
            end
        end

        --Автолут, если есть место
        local lootCount = zombieInventory:getItems():size()
        -- print("========== LOOT SIZE:",lootCount)
        for i = lootCount, 1, -1 do
            local item = zombieInventory:getItems():get(i - 1)
            -- print("+ LOL ITEM:",i," - ",item:getFullType())
            if isDesiredItem(item) then               
                if inv ~= nil then
                    if (inv:getCapacityWeight() + item:getWeight()) <= capacitybag then
                        local itemName = item:getDisplayName()
                        if PM.AutoLootMessage then
                            player:Say("+" .. itemName)
                        end
                        if instanceof(item, "AlarmClockClothing") and item:isAlarmSet() then
                            item:setAlarmSet(false)
                        end
                        inv:AddItem(item)
                    else
                        player:Say(getText("IGUI_Bag_is_full"))
                        break
                    end
                end
            end
        end
    end
end

-- local function requestServerFill(corpse)
--     if not isClient() then return end
--     if not corpse then return end
--     local inv = corpse:getContainer()
--     print("requestServerFill", inv)
-- 	inv:requestServerItemsForContainer() -- ванильный запрос, как при осмотре
-- end
-- --Events.OnZombieDead.Add(onZombieKill)
-- local function AutoLoot_OnZombieDead(zombie)
--     local zombieInventory = zombie:getInventory()
--     local parent = zombieInventory:getParent()
--     if parent and instanceof(parent, "IsoDeadBody") then
--         requestServerFill(parent)
--     end

--     local tries = 20 -- ~1 секунды задержки
--     local function waitAndLoot()
--         if tries <= 1 then
--             Events.OnTick.Remove(waitAndLoot)
--             AutoLoot(zombie)
--             return
--         end
--         tries = tries - 1
--     end
--     Events.OnTick.Add(waitAndLoot)
-- end
-- Events.OnZombieDead.Add(AutoLoot_OnZombieDead)
local function requestVanillaFill(corpse)
	if not corpse then return end
	local inv = corpse:getContainer()
	if not inv or inv:isExplored() then return end
	inv:requestServerItemsForContainer() -- ванильный запрос, как при осмотре
end

local function AutoLoot_OnZombieDead(zombie)
    if not PM.Autoloot or not checkTimeActivate then return end
	if not zombie then return end
	local inv = zombie:getInventory()
	if not inv then return end

    local waitCorpseCount = 0
	local function waitCorpse() -- Ожидание появления тела
		local parent = inv:getParent()
		if parent and instanceof(parent, "IsoDeadBody") then
            waitCorpseCount = waitCorpseCount + 1
            Events.OnTick.Remove(waitCorpse)
			-- триггерим ванильный «осмотр»/запрос спавна
			requestVanillaFill(parent)
			-- ждём, пока контейнер отметится explored/придут предметы
			local waitItemsTries = 30 -- На 60 рработает, на 30 тест
			local function waitItems()
                local container = parent:getContainer()
				if waitItemsTries <= 0 then -- Если нет предметов, то завершаем ожидание
					Events.OnTick.Remove(waitItems)
					AutoLoot(container)
					return
				end
				waitItemsTries = waitItemsTries - 1
                -- local c = container
                -- if c and (c:isExplored() or (c:getItems() and c:getItems():size() > 0)) then
                --     Events.OnTick.Remove(waitItems)
                --     print("AutoLoot(c)",c)
                --     AutoLoot(c)
                -- end
			end
			Events.OnTick.Add(waitItems)
		end
        if waitCorpseCount > 200 then -- На всякий случай, если что-то пошло не так отпишемся, чтоб не повисло
            Events.OnTick.Remove(waitCorpse)
        end
	end
	Events.OnTick.Add(waitCorpse)
end

Events.OnZombieDead.Add(AutoLoot_OnZombieDead)