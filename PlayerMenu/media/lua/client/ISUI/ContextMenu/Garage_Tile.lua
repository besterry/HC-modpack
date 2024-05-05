PM = PM or {} -- Глобальный контейнер PlayerMenu
PM.EditGarage = PM.EditGarage or false

-- require "BuildingObjects/ISBuildingObject"
-- ISGarage = ISBuildingObject:derive("ISGarage");

-- -- Функция для создания гаража.
-- function ISGarage:create(x, y, z, north, sprite)
--     local cell = getWorld():getCell();
--     self.sq = cell:getGridSquare(x, y, z);
--     self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
--     self.javaObject:setName("Garage");
--     self.sq:AddSpecialObject(self.javaObject);
--     self.javaObject:transmitCompleteItemToServer();
--     PM.EditGarage = false
-- end

-- -- Функция возвращает новый объект гаража.
-- function ISGarage:new(name, character, sprite, northSprite)
--     local o = {};
--     setmetatable(o, self);
--     self.__index = self;
--     o:init();
--     o:setSprite(sprite);
--     o.character = character;
--     o:setNorthSprite(northSprite);
--     -- Остальные свойства объекта, например:
--     -- o.noNeedHammer = true;
--     -- o.blockAllTheSquare = true;
--     -- o.canBeAlwaysPlaced = true;
--     o.name = name;
--     return o;
-- end
local function addGarageSprite(x, y)
    local square = getCell():getGridSquare(x, y, 0) -- Здесь 0 предполагается как Z-координата, корректируйте по необходимости
    local spriteName = "garage_0"
    if square then
        -- Проверяем, не содержит ли клетка уже этот спрайт
        local objects = square:getObjects()
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if object:getSprite() and object:getSprite():getName() == spriteName then
                -- Если содержит, ничего не делаем
                return
            end
        end

        -- Если в клетке нет нужного спрайта, добавляем его
        local newSprite = IsoObject.new(square, spriteName, spriteName)
        square:AddTileObject(newSprite)
        -- Синхронизируем объект с сервером
        newSprite:transmitCompleteItemToServer()
        PM.EditGarage = false        
        newSprite:getModData()["GarageOwner"] = getPlayer():getUsername()
        newSprite:transmitModData()

        sendClientCommand(getPlayer(), "Garage", "GarageLog", {x, y, "add", newSprite:getModData()})
    end
end

local function hasGarageSpriteInSafehouse(player, spriteName) --Проверка есть ли тайл гаража в убежище
    local safehouse = SafeHouse.getSafeHouse(player:getCurrentSquare())
    if not safehouse then
        return false
    end
    -- Перебираем все клетки убежища
    local sx, sy = safehouse:getX(), safehouse:getY()
    local ex, ey = safehouse:getX2(), safehouse:getY2()

    for x = sx, ex do
        for y = sy, ey do
            local square = getCell():getGridSquare(x, y, 0)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    if object:getTextureName() and string.find(string.lower(object:getTextureName()), string.lower(spriteName)) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function checkSafeHouse(player, x, y, z) --Проверка существует ли убежище и принадлежит ли оно игроку
    --getCell().getGridSquare(x, y, z)
    local cell = getWorld():getCell()
    local square = cell:getGridSquare(x, y, z)
    --local square = worldobjects[1]:getCurrentSquare() -- Получаем текущую клетку игрока.
    if not square then return false end
    local safehouse = SafeHouse.getSafeHouse(square) -- Получаем объект убежища для текущей клетки.
    if safehouse and safehouse:isOwner(player) then  -- Проверяем, существует ли убежище и принадлежит ли оно игроку.
        return true
    else
        player:Say(getText("IGUI_Not_in_safehouse_or_not_owner"))
        PM.EditGarage = false
        return false
    end
end

local function setGarage(worldobjects, playerNum, sprites) --Создание гаража
    local player = getSpecificPlayer(playerNum)
    local x = worldobjects[1]:getX()
    local y = worldobjects[1]:getY()
    local z = worldobjects[1]:getZ()
    if not checkSafeHouse(player, x, y, z) then return end

    if hasGarageSpriteInSafehouse(player, "garage_0") then -- Вызов функции проверки на наличие спрайта в убежище
        player:Say(getText("IGUI_GarageAlreadyExists"))
        PM.EditGarage = false
        return
    end

    -- local north = false     -- Булево значение: true, если гараж должен быть направлен на север.
    -- local sprite = sprites; -- Название спрайта гаража.
    -- getData(x,y)
    addGarageSprite(x,y)
    -- local garage = ISGarage:new("Garage", player, sprite, sprite);
    -- garage:create(x, y, z, north, sprite);
end

local function GarageSetTileContextMenu(playerNum, context, worldobjects, test)
    local sprites = "garage_0"
    if PM.EditGarage and SandboxVars.NPC.Garage then
        context:addOption(getText("IGUI_set_Garage"), worldobjects, setGarage, playerNum, sprites);
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(GarageSetTileContextMenu)
