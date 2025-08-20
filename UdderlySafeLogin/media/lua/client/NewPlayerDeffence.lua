-- Система защиты для новичков 
-- NOTE: временно реализована на основе времени выживания
local textManager = getTextManager();
local screenX = 150; --65
local screenY = 5; --13
local protectionTime = SandboxVars.UdderlySafeLogin.Protection or 1
local protectionDeactivated = false

local function newPlayerDeffenceCheck() --Проверка на время защиты
    local player = getPlayer()
    protectionTime = SandboxVars.UdderlySafeLogin.Protection
    if player then
        local hoursSurvived = player:getHoursSurvived()
        if hoursSurvived > protectionTime then
            player:setZombiesDontAttack(false)
            if not protectionDeactivated then
                player:setHaloNote(getText("IGUI_Protection_deactivated"), 236, 131, 190, 50)
                protectionDeactivated = true
            end
        else
            player:setZombiesDontAttack(true)
            if protectionDeactivated then
                player:setHaloNote(getText("IGUI_Protection_will_activated"), 236, 131, 190, 50)
                protectionDeactivated = false
            end
        end
    end
end


local function ShowProtectionTime()
    if isAdmin() then return end
    local player = getPlayer()
    local hoursSurvived = player:getHoursSurvived()
    newPlayerDeffenceCheck()
    protectionTime = SandboxVars.UdderlySafeLogin.Protection
    -- if not player or isAdmin() then return end
    local time = protectionTime - hoursSurvived --Часы 0.125122231, нужны часы и минуты
    local hours = math.floor(time)
    local minutes = math.floor((time - hours) * 60)
    local timeString = hours .. ":" .. minutes

    if time >= 0 then
        textManager:DrawString(UIFont.Large, screenX+1, screenY+1, getText("IGUI_Protection_activated") .. timeString, 0, 0, 0, 1);
        textManager:DrawString(UIFont.Large, screenX, screenY, getText("IGUI_Protection_activated") .. timeString, 1.0, 1.0, 0.0, 1.0);
    end
end

Events.OnGameStart.Add(function()
	Events.OnPostUIDraw.Add(ShowProtectionTime);
end)


-- Спавн лута для нового игрока
-- Если контейнер не лутался 24 часа и пустой, то заполняем его для нового игрока (проверка на часы выживания будет добавлена позже)
-- local function newPlayerLoot()
--     print("START LOOTING")
--     local playerObj = getPlayer()
--     if not playerObj then return end

    -- local hoursSurvived = playerObj:getHoursSurvived()
    -- -- print("hoursSurvived:", hoursSurvived)
    -- if hoursSurvived >= 0.1 then return end -- если игрок выжил больше 0.1 часа, то не заполняем контейнер
    -- print("fill containers")
    -- local playerSquare = playerObj:getCurrentSquare()
    -- if not playerSquare then return end
    
    -- local building = playerSquare:getBuilding()
    -- if building then
    --     building:FillContainers()
    -- end

    -- Ищем контейнеры в радиусе 3 клеток
--     for x = -10, 10 do
--         for y = -10, 10 do
--             local square = getSquare(playerSquare:getX() + x, playerSquare:getY() + y, playerSquare:getZ()) -- квадрат, в котором игрок
--             if square then
--                 local objects = square:getObjects() -- объекты на квадрате
--                 for i = 0, objects:size() - 1 do
--                     local obj = objects:get(i) -- объект
--                     if instanceof(obj, "IsoObject") and obj:getContainerCount() > 0 then -- если объект - контейнер и в контейнере есть предметы
--                         for j = 0, obj:getContainerCount() - 1 do
--                             local container = obj:getContainerByIndex(j)
--                             if container and container:getItems():size() == 0 and 
--                                not instanceof(container:getParent(), "BaseVehicle") and 
--                                not (container:getType() == "inventorymale" or container:getType() == "inventoryfemale") and
--                                container:getSourceGrid() and container:getSourceGrid():getRoom() and 
--                                container:getSourceGrid():getRoom():getRoomDef() and 
--                                container:getSourceGrid():getRoom():getRoomDef():getProceduralSpawnedContainer() then
--                                 -- Проверяем время последнего спавна
--                                 -- print("obj:", obj:getObjectName())
--                                 local md = obj:getModData()
--                                 if not md then md = {} end
--                                 local lastSpawnTime = md["lastSpawnTime"] or 0
--                                 local currentTime = getGameTime():getWorldAgeHours() -- текущее время в часах
                                
--                                 -- Если прошло больше 24 игровых часов
--                                 if currentTime - lastSpawnTime >= 24 then
--                                     print("time to fill container")
--                                     if isClient() then
--                                          -- Заполняем контейнер пока не будет хотя бы 1 предмет
--                                         local attempts = 0
--                                         local maxAttempts = 50 -- Максимум попыток заполнения
                                        
--                                         while container:getItems():size() < 1 and attempts < maxAttempts do
--                                             attempts = attempts + 1
--                                             print("attempts:", attempts)
--                                             local items = container:getItems()
--                                             local tItems = {}
--                                             for i = items:size()-1, 0, -1 do
--                                                 table.insert(tItems, items:get(i))
--                                             end

--                                             for i, v in ipairs(tItems) do
--                                                 ISRemoveItemTool.removeItem(v, playerObj)
--                                             end

--                                             local sq = container:getSourceGrid()
--                                             local cIndex = -1
--                                             for i = 0, container:getParent():getContainerCount()-1 do
--                                                 if container:getParent():getContainerByIndex(i) == container then
--                                                     cIndex = i
--                                                 end
--                                             end
--                                             local args = { x = sq:getX(), y = sq:getY(), z = sq:getZ(), index = container:getParent():getObjectIndex(), containerIndex = cIndex }
--                                             sendClientCommand(playerObj, 'object', 'clearContainerExplore', args)
--                                             container:removeItemsFromProcessItems()
--                                             container:clear()
--                                             container:requestServerItemsForContainer()
--                                             container:setExplored(true)
--                                             sendClientCommand(playerObj, 'object', 'updateOverlaySprite', args)
--                                         end
                                        
--                                         -- Обновляем время последнего спавна
--                                         md["lastSpawnTime"] = currentTime
--                                     else
--                                         -- Заполняем контейнер пока не будет хотя бы 1 предмет
--                                         local attempts = 0
--                                         local maxAttempts = 50 -- Максимум попыток заполнения
                                        
--                                         while container:getItems():size() < 1 and attempts < maxAttempts do
--                                             attempts = attempts + 1
                                            
--                                             container:getSourceGrid():getRoom():getRoomDef():getProceduralSpawnedContainer():clear()
--                                             container:removeItemsFromProcessItems()
--                                             container:clear()
--                                             ItemPicker.fillContainer(container, playerObj)
--                                             if container:getParent() then
--                                                 ItemPicker.updateOverlaySprite(container:getParent())
--                                             end
--                                             container:setExplored(true)
--                                         end
                                        
--                                         -- Обновляем время последнего спавна
--                                         md["lastSpawnTime"] = currentTime
--                                      end
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--         end
--     end
--     Events.OnPlayerUpdate.Remove(newPlayerLoot) -- удаляем событие после заполнения контейнера (сработает только 1 раз при спавне игрока)
-- end

-- Events.OnPlayerUpdate.Add(newPlayerLoot)