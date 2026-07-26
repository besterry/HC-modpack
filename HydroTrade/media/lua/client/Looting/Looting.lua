ISLootTreeCursor = ISBuildingObject:derive("ISLootTreeCursor")

function ISLootTreeCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    local tree = square:getTree()
    if tree then
        local lastLootTime = tree:getModData().TimeLoot or 0
        local respawnTime = tree:getModData().TimeRespawn or 0
        local currentTime = getGameTime():getWorldAgeHours()
        if lastLootTime + respawnTime <= currentTime then
            ISWorldObjectContextMenu.doLootTree(self.character, tree)
        else
            self.character:Say(getText('IGUI_Already_LootTree'))
        end
    end
end

ISWorldObjectContextMenu.doLootTree = function(character, tree)
    local action = ISTreeLootAction:new(character, tree, 200)
    if luautils.walkAdj(character, tree:getSquare(), true) then
        ISTimedActionQueue.add(action)
    end
end

function ISLootTreeCursor:isValid(square)
    return square:HasTree() -- Проверяем, есть ли на этой клетке дерево
end

function ISLootTreeCursor:render(x, y, z, square)
    if not ISLootTreeCursor.floorSprite then
        ISLootTreeCursor.floorSprite = IsoSprite.new()
        ISLootTreeCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    end
    local hc = getCore():getBadHighlitedColor()
    local tree = square:getTree()
    if self:isValid(square) and tree then
        local lastLootTime = tree:getModData().TimeLoot or 0
        local respawnTime = tree:getModData().TimeRespawn or 0
        local currentTime = getGameTime():getWorldAgeHours()
        if lastLootTime + respawnTime <= currentTime then
           hc = getCore():getGoodHighlitedColor() -- Если можно лутать снова, выделяем стандартным цветом (зеленым)
        else
            hc = ColorInfo.new(1, 1, 0, 1) -- Если нельзя лутать, выделяем другим цветом (например, желтым 1, 1, 0, 1)
        end
        tree:setHighlighted(true)
    end
    ISLootTreeCursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end

function ISLootTreeCursor:new(sprite, northSprite, character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = character
    o.player = character:getPlayerNum()
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end
