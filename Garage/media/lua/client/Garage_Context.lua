Garage = Garage or {}
PM = PM or {}
PM.DeleteGarage = PM.DeleteGarage or false
PM.ChangeSideGarage = PM.ChangeSideGarage or false

local toolTipcheck = function(option) --Функция для создания тултипа контекстного меню
    local _tooltip = ISToolTip:new()
    _tooltip:initialise()
    _tooltip:setVisible(false)
    option.toolTip = _tooltip

    return _tooltip
end

local function CheckCar(x, y) --Функция для получения авто из зоны по координатам и гос.номеру
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, 0)
    if sq then
        local vehicle = sq:getVehicleContainer()
        if vehicle then
            return vehicle
        else
            return nil
        end
    end
end

local function seekShopTiles(worldobject, spritePrefix) --Функция поиска тайла
    local wo = worldobject
    local found = false
    local sprite = wo:getSprite()
    local spriteName = sprite:getName()
    if spriteName == spritePrefix then --and string.find(spriteName, spritePrefix)
        found = true
    end
    return wo, found, spriteName, sprite
end

local function putCar(worldobjecs, playerNum, vehicle) --NOTE: Сохранение ТС (отправка в гараж)
    sendClientCommand(getPlayer(), "Garage", "getSkinIdx", {vehicle = vehicle:getId()}) --Отправка запроса на сервер для поиска skinIdx  
    local receiveServerCommand
    receiveServerCommand = function(module, command, args) --Получив ответ продолжаем выполнение кода
        if module == "Garage" and command == "getSkinIdx" then
            Events.OnServerCommand.Remove(receiveServerCommand)
            local skinIdx = args.skinIdx
            local vehicleZone = CheckCar(worldobjecs[1]:getModData().spawnX, worldobjecs[1]:getModData().spawnY) --Проверка что игрок не отъехал за зону
            local checkContainersCar = false
            local player = getPlayer()
            --player:StopAllActionQueue() --Остановить выполнение всех действий characters/ILuaGameCharacter
            if vehicle then --Проверка что автомобиль пустой
                for i = 0, vehicle:getPartCount() - 1 do
                    local part = vehicle:getPartByIndex(i)
                    local container = part:getItemContainer() --Получение контейнера детали с содержимым (предметы)
                    if container then
                        if container:getItems():size() ~= 0 then
                            checkContainersCar = false
                            player:Say(getText("IGUI_ContainerIsNotEmpty"))
                            return checkContainersCar
                        end
                    end
                end
                checkContainersCar = true
            end
            if vehicle and checkContainersCar and vehicle==vehicleZone then
                local player = getPlayer()
                vehicle:exit(player)
                triggerEvent("OnExitVehicle", player)
                local vehicleData = Garage.getVehicleData(vehicle, player, skinIdx) --Получаем таблицу с данными автомобиля
                local modDataGarage = worldobjecs[1]:getModData()
                modDataGarage["Garage"] = modDataGarage["Garage"] or {}    --Формирование таблицы гаража
                table.insert(modDataGarage["Garage"], vehicleData)
                worldobjecs[1]:transmitModData()
                sendClientCommand(player, "vehicle", "remove", { vehicle = vehicle:getId() })
                sendClientCommand(player, "Garage", "putCar", { vehicleData, worldobjecs[1]:getX(), worldobjecs[1]:getY(),modDataGarage.GarageOwner })
            else
                getPlayer():Say(getText("IGUI_Car_not_found"))
            end
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end

local function getCar(worldobjecs, playerNum, v, vehicle, spawnX, geoY) -- NOTE: Восстановление ТС (получение из гаража)
    local vehicleZone = CheckCar(spawnX, geoY)
    if not vehicle and not vehicleZone then
        local player = getPlayer()
        local modDataGarage = worldobjecs[1]:getModData()["Garage"]
        local owner = worldobjecs[1]:getModData()["GarageOwner"]
        local car = {}
        local checkCarInGarage = false --Чек на наличие авто в гараже (чтобы второй игрок не смог дублировать авто)
        for i, vehicleData in ipairs(modDataGarage) do
            if vehicleData.oldSqlid == v.oldSqlid and vehicleData.vehicleFullName == v.vehicleFullName then
                car = vehicleData
                table.remove(modDataGarage, i) -- Удаление подтаблицы автомобиля из гаража
                worldobjecs[1]:transmitModData()
                checkCarInGarage = true
                break
            else
                checkCarInGarage = false
            end
        end
        if checkCarInGarage then
            sendClientCommand(player, "Garage", "getCar", { car, spawnX, geoY, owner})
        end
    else
        getPlayer():Say(getText("IGUI_PlaceForCarBusy"))
    end
end

local function removeSpawnSprite(x, y, spriteName,modData)
    if spriteName == "garage_0" then
        PM.DeleteGarage = false
        local action = "delete"
        local player = getPlayer()
        local modData = modData
        sendClientCommand(player,"Garage","GarageLog",{x,y,action,modData})
    end
    local square = getCell():getGridSquare(x, y, 0)
    if square then
        local objects = square:getObjects()
        for i = objects:size() - 1, 0, -1 do
            local object = objects:get(i)
            if object:getSprite() and object:getSprite():getName() == spriteName then
                square:transmitRemoveItemFromSquare(object)
                return
            end
        end
    end
end

local function addSpawnSprite(x, y, spriteName)
    local square = getCell():getGridSquare(x, y, 0) -- Всегда на 0 этаже
    if square then        
        local objects = square:getObjects()-- Проверяем, не содержит ли клетка уже этот спрайт
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if object:getSprite() and object:getSprite():getName() == spriteName then
                return -- Если содержит, ничего не делаем
            end
        end
        local newSprite = IsoObject.new(square, spriteName, spriteName)-- Если в клетке нет нужного спрайта, добавляем его        
        square:AddTileObject(newSprite) -- Синхронизируем объект с сервером
        newSprite:transmitCompleteItemToServer()
    end
end

local spriteName = "street_decoration_01_15"
local function deleteSpawnSprite(worldobject) --Удаление люка при удалении гаража
    local modData = worldobject[1]:getModData()
    local GarageX = modData.spawnX
    local GarageY = modData.spawnY
    removeSpawnSprite(GarageX, GarageY, spriteName)
end


local function change(worldobject) --Смена стороны спавна
    local GarageX = worldobject[1]:getX()
    local GarageY = worldobject[1]:getY()
    if GarageX ~= worldobject[1]:getModData().spawnX or GarageY + 3 ~= worldobject[1]:getModData().spawnY then --Если Х+3
        removeSpawnSprite(GarageX + 3, GarageY, spriteName)
        worldobject[1]:getModData().spawnX = GarageX
        worldobject[1]:getModData().spawnY = GarageY + 3
    else
        removeSpawnSprite(GarageX, GarageY + 3, spriteName)
        worldobject[1]:getModData().spawnX = GarageX + 3
        worldobject[1]:getModData().spawnY = GarageY
    end
    worldobject[1]:transmitModData()
    local modData = worldobject[1]:getModData()
    addSpawnSprite(modData.spawnX, modData.spawnY, spriteName)
end

local function checkCoordSpawn(worldobject)
    local x = worldobject:getModData().spawnX or worldobject:getX() + 3
    local y = worldobject:getModData().spawnY or worldobject:getY()
    if not worldobject:getModData().spawnX or not worldobject:getModData().spawnY then
        addSpawnSprite(x, y, spriteName)
        worldobject:getModData().spawnX = x
        worldobject:getModData().spawnY = y
        worldobject:transmitModData()
    end
    return x, y
end

local function checkSafeHouse()
    local player = getPlayer()
    local square = player:getCurrentSquare()         -- Получаем текущую клетку игрока.
    if not square then return false end
    local safehouse = SafeHouse.getSafeHouse(square) -- Получаем объект убежища для текущей клетки.
    if safehouse and safehouse:isOwner(player) then  -- Проверяем, существует ли убежище и принадлежит ли оно игроку.
        return true
    else
        player:Say(getText("IGUI_Not_in_safehouse_or_not_owner")) --Not in safehouse or not owner
        PM.DeleteGarage = false
        PM.ChangeSideGarage = false
        return false
    end
end

local function chekUserSafeHouse() --Проверка на участника убежища
    if isAdmin() then return true end --Админ имеет доступ к гаражу как член убежища (достать, убрать авто)
    local player = getPlayer()
    local square = player:getCurrentSquare()       -- Получаем текущую клетку игрока.    
    if not square then return false end
    local safehouse = SafeHouse.getSafeHouse(square) -- Получаем объект убежища для текущей клетки.    
    if safehouse then
        if safehouse:isOwner(player) then return true end --Если владелец
        local Users = safehouse:getPlayers() --Список игроков убежища
        local playerUsername = player:getUsername()
        for i = 0, Users:size() - 1 do -- в Java список начинается с 0
            if Users:get(i) == playerUsername then
                return true
            end
        end
        return false
    end
end

local function GarageContextMenu(playerNum, context, worldobjects)
    local wo, found, spriteName, sprite = seekShopTiles(worldobjects[1], "garage_0")
    local checkSH
    if found then checkSH = chekUserSafeHouse() end
    if found and SandboxVars.NPC.Garage and checkSH then
        local geoX = worldobjects[1]:getX() --Координаты гаража (нпс)
        local geoY = worldobjects[1]:getY()
        local spawnCoordX, spawnCoordY = checkCoordSpawn(worldobjects[1])
        -- local spawnX = geoX + 2             --Координата X (смещение +3)
        local player = getPlayer()
        local playerX = player:getX()
        local playerY = player:getY()
        local vehicle = CheckCar(spawnCoordX, spawnCoordY)
        local distace = SandboxVars.NPC.GarageDistance
        if geoX > (playerX - distace) and geoX < (playerX + distace) and geoY > (playerY - distace) and geoY < (playerY + distace) then
            local Garage_text = getText("IGUI_Garage")
            if isAdmin() then Garage_text = getText("IGUI_Admin_Garage") end
            local garageOption = context:addOption(Garage_text, worldobjects, nil) --Гараж

            local subMenu = context:getNew(context)
            context:addSubMenu(garageOption, subMenu)

            if worldobjects[1]:getModData()["Garage"] and #worldobjects[1]:getModData()["Garage"] > 0 then -- Добавляем опции для каждого автомобиля в гараже (считываем все авто в моддате гаража)
                local myGarageOption = subMenu:addOption(getText("IGUI_MyGarage"), worldobjects, nil)    --В гараже
                local myGarageSubMenu = subMenu:getNew(subMenu)
                context:addSubMenu(myGarageOption, myGarageSubMenu)
                for k, v in pairs(worldobjects[1]:getModData()["Garage"]) do
                    if not v.owner then v.owner = "" end
                    myGarageSubMenu:addOption( k .. ". " .. 
                        getText("IGUI_VehicleName" .. getText(v.scriptName)) ..
                        " [H " .. v.oldSqlid .. " KT] " .. v.owner,
                        worldobjects, getCar, playerNum, v, vehicle, spawnCoordX, spawnCoordY)
                end
            else
                local myGarageOption = subMenu:addOption(getText("IGUI_MyGarage_empty"), worldobjects, nil) --Гараж пустой
                local tooltip = toolTipcheck(myGarageOption)
                tooltip:setName(getText('ContextMenu_UseGarage'))
                tooltip.description = getText('Tooltip_Need_Car')
            end

            if vehicle then --Опции для отправки авто в гараж
                local NameCar = getText("IGUI_Put_in_garage") ..
                    getText("IGUI_VehicleName" .. getText(vehicle:getScript():getName())) ..
                    " (H " .. vehicle:getModData().sqlId .. " KT)"
                subMenu:addOption(NameCar, worldobjects, putCar, playerNum, vehicle)
            end
            if PM.ChangeSideGarage then --Кнопка изменения стороны
                if not checkSafeHouse() then return end
                local changeCM = subMenu:addOption(getText("IGUI_ChangeGarageSide"), worldobjects, change, playerNum, vehicle)
                local tooltip = toolTipcheck(changeCM)
                tooltip:setName(getText('ContextMenu_ChangeGarageSideTooltip'))
                tooltip.description = getText('Tooltip_ChangeGarageSideTooltip')
            end
        end
    end
    if found and PM.DeleteGarage then --Удаление гаража
        local geoX = worldobjects[1]:getX() --Координаты гаража (нпс)
        local geoY = worldobjects[1]:getY()
        local player = getPlayer()
        local playerX = player:getX()
        local playerY = player:getY()
        local checkSafeHouse = checkSafeHouse()
        if geoX > playerX - 6 and geoX < playerX + 6 and geoY > playerY - 6 and geoY < playerY + 6 and checkSafeHouse then
            if worldobjects[1]:getModData()["Garage"] and #worldobjects[1]:getModData()["Garage"] > 0 then
                local delete = context:addOption(getText("IGUI_DeleteGarage"), worldobjects, nil)
                local tooltip = toolTipcheck(delete)
                tooltip:setName(getText('ContextMenu_DeleteGarage'))
                local rgb = "<RGB:1,0,0>"
                tooltip.description = rgb .. getText('Tooltip_DeleteGarage')
            else
                local spriteName = "garage_0"
                local x = worldobjects[1]:getX()
                local y = worldobjects[1]:getY()
                local modData = worldobjects[1]:getModData() or {}
                local delete = context:addOption(getText("IGUI_DeleteGarage"), worldobjects, function()
                    removeSpawnSprite(x, y, spriteName,modData)
                    deleteSpawnSprite(worldobjects)
                end)
            end
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(GarageContextMenu)
