ZipContainer = ZipContainer or {}

-- local function seekZipTiles(worldobjects, spritePrefix)
--     local foundObjects = {} -- Создаем пустой массив для хранения найденных объектов
--     local found = false
--     for _, wo in ipairs(worldobjects) do -- Перебираем все объекты мира
--         local sprite = wo:getSprite()        
--         if sprite then
--             local spriteName = sprite:getName()
--             if spriteName and string.find(spriteName, spritePrefix) then
--                 table.insert(foundObjects, wo) -- Если спрайт подходит, добавляем объект в массив
--                 found = true
--             end
--         end
--     end
--     return foundObjects, found -- Возвращаем массив всех найденных объектов и флаг найденных объектов
-- end
local function seekZipTiles(worldobject,spritePrefix)
    local wo = worldobject
    local found = false
    if not wo then return wo,found end
    local sprite = wo:getSprite()
    local spriteName = sprite:getName()
    if spriteName then
        if(string.find(spriteName,spritePrefix)) then
            found = true
        end
    end
    return wo, found
end

function ZipContainer.ChangeSprite(worldobjects, playerNum, sprites,zip)
    local sprite = zip:getSprite():getName()
    local spriteNum = string.gsub(sprite,ZipContainer.spritePrefix,"")
    local coords = {x=zip:getX(),y=zip:getY(),z=zip:getZ()}
    local sprite = sprites[1]
    local currentSprite = zip:getSprite():getName()
    if sprite then
        if isClient() then
            sendClientCommand("PS",'ChangeSprite', {sprite,coords,currentSprite})
        end
    end
end

-- function ZipContainer.ZipContainerContextMenu(playerNum, context, worldobjects)
--     local foundObjects, found = seekZipTiles(worldobjects, ZipContainer.spritePrefix)
--     if found then
--         local ZipBox = context:addOption(UIText.ChangeSign, worldobjects, nil);
--         for index, value in ipairs(foundObjects) do
--             local subSelect = context:getNew(context);
--             context:addSubMenu(ZipBox, subSelect);
--             subSelect:addOption(value:getSprite():getName(), value, nil)
--             local subSign = context:getNew(context);
--             context:addSubMenu(subSelect, subSign);
--             for k,v in pairs(ZipContainer.sprites) do                
--                 subSign:addOption(k, worldobjects, ZipContainer.ChangeSprite, playerNum,v,value);
--             end
--         end
--     end
-- end


function ZipContainer.ZipContainerContextMenu(playerNum, context, worldobjects)
    local wo, found = seekZipTiles(worldobjects[1],ZipContainer.spritePrefix)
    if found then
        local ZipBox = context:addOption(UIText.ChangeSign,worldobjects,nil);
        local subSign = context:getNew(context);
        context:addSubMenu(ZipBox, subSign);
        for k,v in pairs(ZipContainer.sprites) do
            subSign:addOption(getText("ContextMenu_".. k) , worldobjects, ZipContainer.ChangeSprite, playerNum,v,wo);
        end
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(ZipContainer.ZipContainerContextMenu)