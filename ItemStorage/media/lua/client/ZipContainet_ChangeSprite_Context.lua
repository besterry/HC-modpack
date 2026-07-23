ZipContainer = ZipContainer or {}

local HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A = 1.0, 0.85, 0.2, 1.0
local highlightedZip = nil

local function clearZipHighlight()
    if highlightedZip then
        highlightedZip:setHighlighted(false)
        highlightedZip = nil
    end
end

local function setZipHighlight(obj, enable)
    if not enable then
        if highlightedZip == obj then
            clearZipHighlight()
        end
        return
    end
    if highlightedZip and highlightedZip ~= obj then
        highlightedZip:setHighlighted(false)
    end
    highlightedZip = obj
    if obj then
        obj:setHighlighted(true)
        obj:setHighlightColor(HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A)
    end
end

function ZipContainer.onHighlightZip(option, menu, isMouseOver)
    setZipHighlight(option.zipHighlightObj, isMouseOver)
end

local function attachZipHighlight(option, obj)
    if not option or not obj then return end
    option.zipHighlightObj = obj
    option.onHighlight = ZipContainer.onHighlightZip
end

local function isZipTileSprite(spriteName)
    if not spriteName then return false end
    if not string.find(spriteName, ZipContainer.spritePrefix, 1, true) then return false end
    return spriteName ~= "ZipContainer_01_3" and spriteName ~= "ZipContainer_01_4"
end

local function seekZipTilesOnSquare(worldobject)
    local found = {}
    if not worldobject then return found end
    local square = worldobject:getSquare()
    if not square then return found end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local obj = objects:get(i)
        local sprite = obj and obj:getSprite()
        local spriteName = sprite and sprite:getName()
        if isZipTileSprite(spriteName) then
            table.insert(found, obj)
        end
    end
    return found
end

local function getSpriteKeyByName(spriteName)
    if not spriteName or not ZipContainer.sprites then return nil end
    for key, sprites in pairs(ZipContainer.sprites) do
        if sprites[1] == spriteName then
            return key
        end
    end
    return nil
end

local function getZipLabel(obj, index, total)
    local sprite = obj:getSprite()
    local spriteName = sprite and sprite:getName()
    local key = getSpriteKeyByName(spriteName)
    local signName = key and getText("ContextMenu_" .. key) or (spriteName or "?")
    if total > 1 then
        return getText("ContextMenu_ZipBoxLabeled", tostring(index), signName)
    end
    return signName
end

function ZipContainer.ChangeSprite(worldobjects, playerNum, sprites, zip)
    clearZipHighlight()
    local coords = {x = zip:getX(), y = zip:getY(), z = zip:getZ()}
    local sprite = sprites[1]
    local currentSprite = zip:getSprite():getName()
    if sprite then
        if isClient() then
            sendClientCommand("PS", "ChangeSprite", {sprite, coords, currentSprite})
        end
    end
end

local function addSignOptions(context, parentMenu, worldobjects, playerNum, wo)
    local noSignSprites = ZipContainer.sprites.NoSign
    if noSignSprites then
        local opt = parentMenu:addOption(getText("ContextMenu_NoSign"), worldobjects, ZipContainer.ChangeSprite, playerNum, noSignSprites, wo)
        attachZipHighlight(opt, wo)
    end

    local categories = ZipContainer.spriteCategories
    if not categories then return end
    for _, category in ipairs(categories) do
        local catOption = parentMenu:addOption(getText("ContextMenu_ZipCat_" .. category.id), worldobjects, nil)
        attachZipHighlight(catOption, wo)
        local subCat = context:getNew(context)
        context:addSubMenu(catOption, subCat)
        for _, key in ipairs(category.keys) do
            local sprites = ZipContainer.sprites[key]
            if sprites then
                local opt = subCat:addOption(getText("ContextMenu_" .. key), worldobjects, ZipContainer.ChangeSprite, playerNum, sprites, wo)
                attachZipHighlight(opt, wo)
            end
        end
    end
end

function ZipContainer.ZipContainerContextMenu(playerNum, context, worldobjects)
    local zipObjects = seekZipTilesOnSquare(worldobjects and worldobjects[1])
    if #zipObjects == 0 then return end

    clearZipHighlight()

    local ZipBox = context:addOption(UIText.ChangeSign, worldobjects, nil)
    local subSign = context:getNew(context)
    context:addSubMenu(ZipBox, subSign)

    if #zipObjects == 1 then
        attachZipHighlight(ZipBox, zipObjects[1])
        addSignOptions(context, subSign, worldobjects, playerNum, zipObjects[1])
        return
    end

    for i, wo in ipairs(zipObjects) do
        local boxOption = subSign:addOption(getZipLabel(wo, i, #zipObjects), worldobjects, nil)
        attachZipHighlight(boxOption, wo)
        local subBox = context:getNew(context)
        context:addSubMenu(boxOption, subBox)
        addSignOptions(context, subBox, worldobjects, playerNum, wo)
    end
end

Events.OnPreFillWorldObjectContextMenu.Add(ZipContainer.ZipContainerContextMenu)
