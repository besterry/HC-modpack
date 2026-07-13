--Author: FD

RemoverItemAndBuildsTool = ISPanelJoypad:derive("RemoverItemAndBuildsTool");
RemoverItemAndBuildsTool.storedTemplate = nil
RemoverItemAndBuildsTool.MAX_APPLY_CELLS = 5000
RemoverItemAndBuildsTool.APPLY_BATCH_SIZE = 80
RemoverItemAndBuildsTool.applyQueue = nil
RemoverItemAndBuildsTool.applyQueueIndex = 1
RemoverItemAndBuildsTool.applyInProgress = false
RemoverItemAndBuildsTool.placeItem = nil

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function RemoverItemAndBuildsTool.snapEndToTemplate(startPos, endX, endY, template)
    if not template or not startPos then return endX, endY end
    local tw = template.width
    local th = template.height
    local dx = endX - startPos.x
    local dy = endY - startPos.y
    local signX = dx >= 0 and 1 or -1
    local signY = dy >= 0 and 1 or -1
    local absW = math.abs(dx) + 1
    local absH = math.abs(dy) + 1
    local snapW = math.max(tw, math.floor(absW / tw) * tw)
    local snapH = math.max(th, math.floor(absH / th) * th)
    return startPos.x + signX * (snapW - 1), startPos.y + signY * (snapH - 1)
end

function RemoverItemAndBuildsTool.getSelectionBounds(startPos, endX, endY)
    if not startPos or not endX or not endY then return nil end
    local x1 = math.min(startPos.x, endX)
    local x2 = math.max(startPos.x, endX)
    local y1 = math.min(startPos.y, endY)
    local y2 = math.max(startPos.y, endY)
    return x1, x2, y1, y2, x2 - x1 + 1, y2 - y1 + 1
end

function RemoverItemAndBuildsTool:getSelectionEnd()
    if self.selectEnd and self.startPos then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        xx = math.floor(xx)
        yy = math.floor(yy)
        if self.itemType:isSelected(11) and RemoverItemAndBuildsTool.storedTemplate then
            xx, yy = RemoverItemAndBuildsTool.snapEndToTemplate(self.startPos, xx, yy, RemoverItemAndBuildsTool.storedTemplate)
        end
        return xx, yy
    elseif self.endPos then
        return self.endPos.x, self.endPos.y
    end
    return nil, nil
end

function RemoverItemAndBuildsTool:highlightSelection(cell)
    local endX, endY = self:getSelectionEnd()
    if not self.startPos or not endX or not endY then return end
    local x1, x2, y1, y2 = RemoverItemAndBuildsTool.getSelectionBounds(self.startPos, endX, endY)
    for x = x1, x2 do
        for y = y1, y2 do
            local sq = cell:getGridSquare(x, y, self.zPos)
            if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end
        end
    end
end

function RemoverItemAndBuildsTool:drawSelectionSizeLabel()
    local endX, endY = self:getSelectionEnd()
    if not self.startPos or not endX or not endY then return end
    local x1, x2, y1, y2, selW, selH = RemoverItemAndBuildsTool.getSelectionBounds(self.startPos, endX, endY)
    local template = RemoverItemAndBuildsTool.storedTemplate
    local label = getText("IGUI_SelectionSize", selW, selH)
    if self.itemType:isSelected(11) and template then
        local repX = math.floor(selW / template.width)
        local repY = math.floor(selH / template.height)
        label = label .. "  " .. getText("IGUI_TemplateRepeats", repX, repY)
    end
    local playerNum = self.player:getPlayerNum()
    local sx = isoToScreenX(playerNum, x2 + 0.5, y1, self.zPos)
    local sy = isoToScreenY(playerNum, x2 + 0.5, y1, self.zPos)
    getTextManager():DrawString(UIFont.Small, sx + 8, sy - 16, label, 1, 1, 0.4, 1)
end

function RemoverItemAndBuildsTool:initialise()
    ISPanelJoypad.initialise(self);

    local fontHgt = FONT_HGT_SMALL
    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Select area") + 12
    local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "Remove") + 12
    local buttonWid3 = getTextManager():MeasureStringX(UIFont.Small, "Close") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid2, buttonWid3), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10

    self.select = ISButton:new((self:getWidth() / 6) - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("IGUI_SelectArea"), self, RemoverItemAndBuildsTool.onClick);
    self.select.internal = "SELECT";
    self.select:initialise();
    self.select:instantiate();
    self.select.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.select);

    self.remove = ISButton:new((self:getWidth() / 2) - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("IGUI_RemoveTools"), self, RemoverItemAndBuildsTool.onClick);
    self.remove.internal = "REMOVE";
    self.remove:initialise();
    self.remove:instantiate();
    self.remove.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.remove);

    self.close = ISButton:new((self:getWidth() / 6)*5 - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("IGUI_CloseTools"), self, RemoverItemAndBuildsTool.onClick);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);

    self.itemType = ISRadioButtons:new(self:getWidth()/2 - 150, 45, 150, 20, self)
    self.itemType.choicesColor = {r=1, g=1, b=1, a=1}
    self.itemType:initialise()
    self.itemType.autoWidth = true;
    self:addChild(self.itemType)
    self.itemType:addOption(getText("IGUI_Delete_AllItems"));
    self.itemType:addOption(getText("IGUI_RemoveBuilds"))
    self.itemType:addOption(getText("IGUI_RemoveAll"))
    self.itemType:addOption(getText("IGUI_ChangeToRoad"))
    self.itemType:addOption(getText("IGUI_ChangeToGrass"))
    self.itemType:addOption(getText("IGUI_AddRandomGrass"))
    self.itemType:addOption(getText("IGUI_AddRandomTrees"))
    self.itemType:addOption(getText("IGUI_RemoveFloors"))
    self.itemType:addOption(getText("IGUI_SetSelectedFloors"))
    self.itemType:addOption(getText("IGUI_CaptureTemplate"))
    self.itemType:addOption(getText("IGUI_ApplyTemplate"))
    -- self.itemType:addOption(getText("IGUI_ClearSnow"))
    self.itemType:setSelected(1)

    self.spriteNameEntry = ISTextEntryBox:new("", self:getWidth()/2 , 200, 150, fontHgt + 6)
    self.spriteNameEntry:initialise()
    self.spriteNameEntry:instantiate()
    self.spriteNameEntry.borderColor = {r=1, g=1, b=1, a=0.3}
    self:addChild(self.spriteNameEntry)
end

function RemoverItemAndBuildsTool:destroy()
    if RemoverItemAndBuildsTool.applyUIInstance == self then
        RemoverItemAndBuildsTool.applyUIInstance = nil
    end
    self:setVisible(false);
    self:removeFromUIManager();
end

local function removeAllButFloor(square)
	if not square then return nil end
	for i=square:getObjects():size(),2,-1 do
		local isoObject = square:getObjects():get(i-1)
		square:transmitRemoveItemFromSquare(isoObject)
	end
	for i=square:getStaticMovingObjects():size(),1,-1 do
		local isoObject = square:getStaticMovingObjects():get(i-1)
		isoObject:removeFromWorld()
		isoObject:removeFromSquare()
	end
end

local function clearSquareForTemplate(square)
    if not square then return end
    for i = square:getObjects():size() - 1, 0, -1 do
        local obj = square:getObjects():get(i)
        if obj and not obj:isFloor() then
            if isClient() and sledgeDestroy then
                sledgeDestroy(obj)
            else
                square:transmitRemoveItemFromSquare(obj)
                square:RemoveTileObject(obj)
            end
        end
    end
end

local function getPlaceItem()
    if not RemoverItemAndBuildsTool.placeItem then
        RemoverItemAndBuildsTool.placeItem = InventoryItemFactory.CreateItem("Base.Plank")
    end
    return RemoverItemAndBuildsTool.placeItem
end

local function isFloorSprite(spriteName)
    if not spriteName then return false end
    local sprite = getSprite(spriteName)
    if not sprite or not sprite:getProperties() then return false end
    return sprite:getProperties():Is(IsoFlagType.solidfloor)
end

local function placeTileOnSquare(square, spriteName)
    if not square or not spriteName then return end
    if isFloorSprite(spriteName) then
        local floor = square:getFloor()
        if floor then
            local current = floor:getSprite()
            if current and current:getName() == spriteName then return end
            floor:setSprite(getSprite(spriteName))
            floor:transmitUpdatedSprite()
        end
        return
    end
    local objs = square:getObjects()
    for i = 0, objs:size() - 1 do
        local spr = objs:get(i):getSprite()
        if spr and spr:getName() == spriteName then
            return
        end
    end
    local props = ISMoveableSpriteProps.new(IsoObject.new(square, spriteName):getSprite())
    props.rawWeight = 10
    props:placeMoveableInternal(square, getPlaceItem(), spriteName)
end

local function applySquareData(square, cellData)
    if not square or not cellData then return end
    clearSquareForTemplate(square)
    if cellData.floor then
        local floor = square:getFloor()
        if floor then
            floor:setSprite(getSprite(cellData.floor))
            if cellData.floorOverlay and floor.setOverlaySprite then
                floor:setOverlaySprite(cellData.floorOverlay, 1, 1, 1, 1)
            end
            floor:transmitUpdatedSprite()
        end
    end
    for _, spriteName in ipairs(cellData.objects or {}) do
        if spriteName ~= cellData.floor and spriteName ~= cellData.floorOverlay then
            placeTileOnSquare(square, spriteName)
        end
    end
end

local function addTreeToSquare(sprite, square)
    --square:AddTileObject(IsoObject.new(square, treeName));
    local objs = square:getObjects()

    local tileAlreadyOnSquare = false
    for i=0, objs:size() - 1 do
        if objs:get(i):getSprite() ~= nil and objs:get(i):getSprite():getName() == sprite then
            tileAlreadyOnSquare = true
        end
    end
    if not tileAlreadyOnSquare then
        local props = ISMoveableSpriteProps.new(IsoObject.new(square, sprite):getSprite())
        props.rawWeight = 10
        props:placeMoveableInternal(square, InventoryItemFactory.CreateItem("Base.Plank"), sprite)
    end
    
    -- local tree = IsoTree.new(treeName)    
    -- if tree then
    --     -- Установка позиции дерева
    --     tree:setSquare(square)
    --     -- Добавление дерева на клетку
    --     square:AddSpecialObject(tree)
        
    --     -- Передача мод данных для объекта
    --     tree:transmitModData()
    -- else
    --     print("Error: Could not create IsoTree with name:", treeName)
    -- end

    -- local tree = IsoTree.new(cell, square, sprite)
    -- tree:setName("Tree")
    -- tree:setType(IsoObjectType.tree)
    -- square:AddTileObject(tree)
    
    -- if tree:getProperties():Is("IsTree") then
    --     local isoTree = IsoTree.new(tree)
    --     square:transmitAddObjectToSquare(isoTree)
    --     square:AddTileObject(isoTree)
    --     if tree:getContainer() then
    --         isoTree:setContainer(tree:getContainer())
    --     end
    --     tree:removeFromSquare()
    -- end
end

function RemoverItemAndBuildsTool:onClick(button)
    if button.internal == "SELECT" then
        self.selectEnd = false
        self.startPos = nil
        self.endPos = nil
        self.zPos = self.player:getZ()
        self.selectStart = true
    end
    if button.internal == "REMOVE" then
        if self.startPos ~= nil and self.endPos ~= nil then
            local cell = getCell()
            local x1 = math.min(self.startPos.x, self.endPos.x)
            local x2 = math.max(self.startPos.x, self.endPos.x)
            local y1 = math.min(self.startPos.y, self.endPos.y)
            local y2 = math.max(self.startPos.y, self.endPos.y)
            local z = self.zPos

            if self.itemType:isSelected(10) then
                RemoverItemAndBuildsTool.storedTemplate = self:captureTemplate(x1, y1, x2, y2, z)
                if RemoverItemAndBuildsTool.storedTemplate and self.player then
                    local t = RemoverItemAndBuildsTool.storedTemplate
                    self.player:Say(getText("IGUI_TemplateCapturedMsg", t.width, t.height))
                end
                self.startPos = nil
                self.endPos = nil
                self.selectStart = false
                self.selectEnd = false
                self.itemType:setSelected(11)
                return
            elseif self.itemType:isSelected(11) then
                if RemoverItemAndBuildsTool.applyInProgress then
                    if self.player then
                        self.player:Say(getText("IGUI_TemplateApplyInProgress"))
                    end
                    return
                end
                if RemoverItemAndBuildsTool.storedTemplate then
                    local template = RemoverItemAndBuildsTool.storedTemplate
                    local snapEndX, snapEndY = RemoverItemAndBuildsTool.snapEndToTemplate(self.startPos, self.endPos.x, self.endPos.y, template)
                    x2 = math.max(self.startPos.x, snapEndX)
                    x1 = math.min(self.startPos.x, snapEndX)
                    y2 = math.max(self.startPos.y, snapEndY)
                    y1 = math.min(self.startPos.y, snapEndY)
                    self:startApplyTemplate(template, x1, y1, x2, y2, z)
                elseif self.player then
                    self.player:Say(getText("IGUI_TemplateNone"))
                end
                return
            end

            local itemBuffer = {}
    
            for x = x1, x2 do
                for y = y1, y2 do
                    for z = 0, 5 do
                        local sq = cell:getGridSquare(x, y, z)
                        if sq and sq:getObjects() then
                            if self.itemType:isSelected(1) then
                                for i = 0, sq:getObjects():size() - 1 do
                                    local object = sq:getObjects():get(i)
                                    if object and instanceof(object, "IsoWorldInventoryObject") then
                                        local item = object
                                        table.insert(itemBuffer, { it = item, square = sq })
                                    elseif object and (instanceof(object, "IsoThumpable") or instanceof(object, "IsoObject"))  then
                                        local itemConteiner = object:getContainer()
                                        if itemConteiner then
                                            itemConteiner:removeAllItems()
                                        end
                                    end
                                end
                            elseif self.itemType:isSelected(2) then
                                for i = 0, sq:getObjects():size() - 1 do
                                    local building = sq:getObjects():get(i)
                                    if building then
                                        local isIsoThumpable = instanceof(building , "IsoThumpable")
                                        local isIsoObject = instanceof(building, "IsoObject")
                                        local isFloor = building:isFloor()
                                        if isIsoThumpable or (isIsoObject and isFloor) then
                                                if isIsoThumpable then --Удаление построек
                                                    --building:destroy()  --Разобрать (падают доски и гвозди)
                                                    building:getSquare():transmitRemoveItemFromSquare(building)
                                                    building:getSquare():RemoveTileObject(building)
                                                elseif z>0 then --удаление потолков (z=0 - земля)
                                                    --building:removeFromSquare() --Работает только на стороне клиента
                                                    --building:removeFromWorld() --не работает на клиенте(возможно только на стороне сервера)
                                                    building:getSquare():transmitRemoveItemFromSquare(building)
                                                    building:getSquare():RemoveTileObject(building)
                                                end
                                        end
                                    end
                                end
                            elseif self.itemType:isSelected(3) then --Удаление всего (кроме пола на 0 этаже)
                                for i = sq:getObjects():size() - 1, 0 , -1 do
                                    local building = sq:getObjects():get(i)
                                    if building then
                                        if building:isFloor() and z==0 then
                                            --print("This floor:", building:isFloor())
                                        else
                                            building:getSquare():transmitRemoveItemFromSquare(building)
                                            building:getSquare():RemoveTileObject(building)
                                        end
                                    end
                                end
                            elseif self.itemType:isSelected(4) then --Если замена на дорогу
                                for i = sq:getObjects():size() - 1, 0 , -1 do
                                    local building = sq:getObjects():get(i)
                                    --print("Floor: ",building:isFloor())
                                    if building:isFloor() and z==0 then
                                        --print("ROAD")
                                        removeAllButFloor(building:getSquare())
                                        building:getSquare():getFloor():setSprite(getSprite("blends_street_01_86"))
                                        building:transmitUpdatedSprite()
                                        --building:transmitUpdatedSpriteToServer()
                                        --building:setSprite(getSprite("blends_street_01_86"))
                                    end

                                end
                            elseif self.itemType:isSelected(5) then --Если замена на дорогу
                                for i = sq:getObjects():size() - 1, 0 , -1 do
                                    local building = sq:getObjects():get(i)
                                    --print("Floor: ",building:isFloor())
                                    if building:isFloor() and z==0 then
                                        --print("ROAD")
                                        removeAllButFloor(building:getSquare())
                                        building:getSquare():getFloor():setSprite(getSprite("blends_natural_01_22"))
                                        building:transmitUpdatedSprite()
                                        --building:transmitUpdatedSpriteToServer()
                                        --building:setSprite(getSprite("blends_street_01_86"))
                                    end
                                end
                            elseif self.itemType:isSelected(6) then --Заполнение травой
                                local tileSet = {"e_newgrass_1_45", "e_newgrass_1_0", "e_newgrass_1_4", "e_newgrass_1_5", "e_newgrass_1_6", "e_newgrass_1_7", "e_newgrass_1_8",  "e_newgrass_1_15", "e_newgrass_1_39", "e_newgrass_1_45", "d_generic_1_80",
                                                 "d_generic_1_81", "d_generic_1_49", "d_plants_1_34",
                                                 "d_plants_1_38"}
                                local hasOnlyBlendsOrEmpty = true
                                for i = 0, sq:getObjects():size() - 1 do
                                    local object = sq:getObjects():get(i)
                                    if object and instanceof(object, "IsoObject") then
                                        if string.find(object:getTextureName(), "^blends_natural_01") ~= 1 then
                                            hasOnlyBlendsOrEmpty = false
                                            break
                                        end
                                    end
                                end
                                
                                if hasOnlyBlendsOrEmpty then -- Если клетка подходит, случайным образом размещаем на ней тайл
                                    local chanse = ZombRand(1,10)
                                    if chanse >= 5 then -- % заполения тайлами 5 - 50%
                                        local tileName = tileSet[ZombRand(1, #tileSet + 1)] -- Выбираем случайный тайл из списка                                    
                                        self:addTileToSquare(tileName, sq) -- Функция для добавления тайла на клетку
                                    end
                                end
                            elseif self.itemType:isSelected(7) then --Заполнение деревьями
                                local tileSet = {"e_canadianhemlock_1_0","e_canadianhemlock_1_1", "e_canadianhemlock_1_2", "e_canadianhemlock_1_3",
                                                "e_americanholly_1_0", "e_americanholly_1_1", "e_americanholly_1_2", "e_americanholly_1_3",
                                                "e_virginiapine_1_0", "e_virginiapine_1_1", "e_virginiapine_1_2", "e_virginiapine_1_3",}
                                local hasOnlyBlendsOrEmpty = true
                                for i = 0, sq:getObjects():size() - 1 do
                                    local object = sq:getObjects():get(i)
                                    if object and instanceof(object, "IsoObject") then
                                        if string.find(object:getTextureName(), "^blends_natural_01") ~= 1 then
                                            hasOnlyBlendsOrEmpty = false
                                            break
                                        end
                                    end
                                end
                                if hasOnlyBlendsOrEmpty then -- Если клетка подходит, случайным образом размещаем на ней тайл
                                    local chanse = ZombRand(1,10)
                                    if chanse >= 7 then -- % заполения тайлами 5 - 50%
                                        local tileName = tileSet[ZombRand(1, #tileSet + 1)] -- Выбираем случайный тайл из списка  
                                        addTreeToSquare(tileName, sq)
                                        --self:addTileToSquare(tileName, sq) -- Функция для добавления тайла на клетку
                                    end
                                end
                            elseif self.itemType:isSelected(8) then --Удаление полов
                                for i = sq:getObjects():size() - 1, 0 , -1 do
                                    local building = sq:getObjects():get(i)
                                    if building:isFloor() and z==0 then
                                        building:getSquare():RemoveTileObject(building)
                                    end
                                end
                            -- elseif self.itemType:isSelected(8) then --Если очистка от снего
                            --     for i = sq:getObjects():size() - 1, 0 , -1 do
                            --         local Cell = sq:getCell()
                            --         --print("Floor: ", sq:getCell():gridSquareIsSnow(x,y,z))
                            --         if Cell:gridSquareIsSnow(x,y,z) then    
                            --             print("Snow clear!")                                    
                            --             Cell:setSnowTarget(i)
                            --         else
                            --             print("This no snow")
                            --         end
                            --     end
                            elseif self.itemType:isSelected(9) then --Установка полов 0 этажа
                                local spriteName = self.spriteNameEntry:getText()
                                if spriteName == "" then
                                    spriteName = "blends_natural_01_22"
                                end
                                for i = sq:getObjects():size() - 1, 0 , -1 do
                                    local building = sq:getObjects():get(i)
                                    if building:isFloor() and z==0 then
                                        building:getSquare():getFloor():setSprite(getSprite(spriteName))
                                        building:transmitUpdatedSprite()
                                    end
                                end
                            end
                        end
                    end
                end
            end
    
            for i, itemData in ipairs(itemBuffer) do
                local sq = itemData.square
                local item = itemData.it
                if self.itemType:isSelected(1) then
                    sq:transmitRemoveItemFromSquare(item)
                    item:removeFromWorld()
                    item:removeFromSquare()
                    item:setSquare(nil)
                end
            end
        end
    end
    if button.internal == "CLOSE" then
        self:destroy();
        return;
    end
end

function RemoverItemAndBuildsTool:captureSquareData(square)
    if not square then return nil end
    local data = { floor = nil, floorOverlay = nil, objects = {} }
    local seen = {}
    local function addObject(spriteName)
        if not spriteName or seen[spriteName] then return end
        seen[spriteName] = true
        table.insert(data.objects, spriteName)
    end
    for i = 0, square:getObjects():size() - 1 do
        local obj = square:getObjects():get(i)
        if obj and obj:getSprite() then
            local spriteName = obj:getSprite():getName()
            if spriteName then
                if obj:isFloor() then
                    data.floor = spriteName
                    seen[spriteName] = true
                    if obj:getOverlaySprite() and obj:getOverlaySprite():getName() then
                        data.floorOverlay = obj:getOverlaySprite():getName()
                        seen[data.floorOverlay] = true
                    end
                else
                    addObject(spriteName)
                end
            end
        end
        if obj and not obj:isFloor() and obj:getOverlaySprite() and obj:getOverlaySprite():getName() then
            addObject(obj:getOverlaySprite():getName())
        end
    end
    return data
end

function RemoverItemAndBuildsTool:captureTemplate(x1, y1, x2, y2, z)
    local template = {
        width = x2 - x1 + 1,
        height = y2 - y1 + 1,
        z = z,
        cells = {},
    }
    local cell = getCell()
    for x = x1, x2 do
        local relX = x - x1 + 1
        template.cells[relX] = {}
        for y = y1, y2 do
            local relY = y - y1 + 1
            local sq = cell:getGridSquare(x, y, z)
            template.cells[relX][relY] = self:captureSquareData(sq)
        end
    end
    return template
end

function RemoverItemAndBuildsTool:startApplyTemplate(template, x1, y1, x2, y2, z)
    if not template or not template.cells then return end
    local totalCells = (x2 - x1 + 1) * (y2 - y1 + 1)
    if totalCells > RemoverItemAndBuildsTool.MAX_APPLY_CELLS then
        if self.player then
            self.player:Say(getText("IGUI_TemplateApplyTooLarge", totalCells, RemoverItemAndBuildsTool.MAX_APPLY_CELLS))
        end
        return
    end
    RemoverItemAndBuildsTool.applyQueue = {}
    for tx = x1, x2 do
        for ty = y1, y2 do
            local relX = ((tx - x1) % template.width) + 1
            local relY = ((ty - y1) % template.height) + 1
            local cellData = template.cells[relX] and template.cells[relX][relY]
            if cellData then
                table.insert(RemoverItemAndBuildsTool.applyQueue, { tx = tx, ty = ty, z = z, cellData = cellData })
            end
        end
    end
    RemoverItemAndBuildsTool.applyQueueIndex = 1
    RemoverItemAndBuildsTool.applyInProgress = true
    RemoverItemAndBuildsTool.applyPlayer = self.player
    RemoverItemAndBuildsTool.applyUIInstance = self
    if self.remove then
        self.remove:setEnable(false)
    end
    if self.player then
        self.player:Say(getText("IGUI_TemplateApplyStarted", totalCells))
    end
    Events.OnTick.Add(RemoverItemAndBuildsTool.onApplyTemplateTick)
end

function RemoverItemAndBuildsTool.onApplyTemplateTick()
    local queue = RemoverItemAndBuildsTool.applyQueue
    if not queue or not RemoverItemAndBuildsTool.applyInProgress then
        Events.OnTick.Remove(RemoverItemAndBuildsTool.onApplyTemplateTick)
        return
    end
    local cell = getCell()
    local batchEnd = math.min(RemoverItemAndBuildsTool.applyQueueIndex + RemoverItemAndBuildsTool.APPLY_BATCH_SIZE - 1, #queue)
    for i = RemoverItemAndBuildsTool.applyQueueIndex, batchEnd do
        local job = queue[i]
        local sq = cell:getGridSquare(job.tx, job.ty, job.z)
        if sq then
            applySquareData(sq, job.cellData)
        end
    end
    RemoverItemAndBuildsTool.applyQueueIndex = batchEnd + 1
    if RemoverItemAndBuildsTool.applyQueueIndex > #queue then
        RemoverItemAndBuildsTool.applyQueue = nil
        RemoverItemAndBuildsTool.applyInProgress = false
        Events.OnTick.Remove(RemoverItemAndBuildsTool.onApplyTemplateTick)
        local player = RemoverItemAndBuildsTool.applyPlayer
        if player then
            player:Say(getText("IGUI_TemplateApplyDone"))
        end
        RemoverItemAndBuildsTool.applyPlayer = nil
        local ui = RemoverItemAndBuildsTool.applyUIInstance
        if ui and ui.remove then
            ui.remove:setEnable(true)
        end
        RemoverItemAndBuildsTool.applyUIInstance = nil
    end
end

function RemoverItemAndBuildsTool:applyTemplate(template, x1, y1, x2, y2, z)
    self:startApplyTemplate(template, x1, y1, x2, y2, z)
end

function RemoverItemAndBuildsTool:addTileToSquare(tileName, square)
    -- Создаем новый IsoObject с использованием спрайта, имя которого указано в tileName
    local object = IsoObject.new(square:getCell(), square, tileName)

    -- Добавляем объект на клетку
    square:AddTileObject(object)
    object:transmitCompleteItemToServer()
    -- square:RecalcProperties()
    -- square:InvalidateIsoObjects()
    -- Обновляем данные о клетке, если это необходимо
    -- square:RecalcAllWithNeighbours()
    -- square:RecalcProperties() -- если нужно пересчитать свойства клетки
end

function RemoverItemAndBuildsTool:titleBarHeight()
    return 16
end

function RemoverItemAndBuildsTool:prerender()
    self.backgroundColor.a = 0.8

    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);

    local th = self:titleBarHeight()
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);

    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    self:drawTextCentre(getText("IGUI_Remover_Tools"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);

    local template = RemoverItemAndBuildsTool.storedTemplate
    if template then
        self:drawTextCentre(getText("IGUI_TemplateCaptured") .. ": " .. template.width .. "x" .. template.height, self:getWidth() / 2, 36, 0.4, 1, 0.4, 1, UIFont.Small)
    else
        self:drawTextCentre(getText("IGUI_TemplateNone"), self:getWidth() / 2, 36, 0.7, 0.7, 0.7, 1, UIFont.Small)
    end

    local endX, endY = self:getSelectionEnd()
    if self.startPos and endX and endY then
        local _, _, _, _, selW, selH = RemoverItemAndBuildsTool.getSelectionBounds(self.startPos, endX, endY)
        local selText = getText("IGUI_SelectionSize", selW, selH)
        local r, g, b = 1, 1, 1
        if self.itemType:isSelected(11) and template then
            local repX = math.floor(selW / template.width)
            local repY = math.floor(selH / template.height)
            selText = selText .. "  " .. getText("IGUI_TemplateRepeats", repX, repY)
            r, g, b = 0.4, 1, 0.4
        end
        self:drawTextCentre(selText, self:getWidth() / 2, 52, r, g, b, 1, UIFont.Small)
    elseif self.itemType:isSelected(11) and template then
        self:drawTextCentre(getText("IGUI_TemplateApplyHint", template.width, template.height) .. "  " .. getText("IGUI_TemplateApplyLimit", RemoverItemAndBuildsTool.MAX_APPLY_CELLS), self:getWidth() / 2, 52, 0.8, 0.8, 0.4, 1, UIFont.Small)
    end
    if RemoverItemAndBuildsTool.applyInProgress then
        self:drawTextCentre(getText("IGUI_TemplateApplyInProgress"), self:getWidth() / 2, 68, 1, 0.8, 0.2, 1, UIFont.Small)
    end
end

function RemoverItemAndBuildsTool:render()
    local cell = getCell()
    if self.selectStart then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        local sq = cell:getGridSquare(math.floor(xx), math.floor(yy), self.zPos)
        if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end
    else
        self:highlightSelection(cell)
        self:drawSelectionSizeLabel()
    end
end

function RemoverItemAndBuildsTool:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function RemoverItemAndBuildsTool:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function RemoverItemAndBuildsTool:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function RemoverItemAndBuildsTool:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end

function RemoverItemAndBuildsTool:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function RemoverItemAndBuildsTool:onMouseDownOutside(x, y)
    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
    xx = math.floor(xx)
    yy = math.floor(yy)
    if self.selectStart then
        self.startPos = { x = xx, y = yy }
        self.selectStart = false
        self.selectEnd = true
    elseif self.selectEnd then
        if self.itemType:isSelected(11) and RemoverItemAndBuildsTool.storedTemplate then
            xx, yy = RemoverItemAndBuildsTool.snapEndToTemplate(self.startPos, xx, yy, RemoverItemAndBuildsTool.storedTemplate)
        end
        self.endPos = { x = xx, y = yy }
        self.selectEnd = false
    end
end

function RemoverItemAndBuildsTool:new(x, y, width, height, player)
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self

    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end
    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end
    o.name = nil;
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o.player = player;
    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
    o.numLines = 1
    o.maxLines = 1
    o.multipleLine = false

    o.selectStart = false
    o.selectEnd = false
    o.startPos = nil
    o.endPos = nil
    o.zPos = 0
    o.spriteNameEntry = nil

    return o;
end

--************************************************************************--
--************************************************************************--

function RemoverItemAndBuildsTool.removeItem(item, player)
    if item:getWorldItem() ~= nil then
        item:getWorldItem():getSquare():transmitRemoveItemFromSquare(item:getWorldItem());
        item:getWorldItem():removeFromWorld()
        item:getWorldItem():removeFromSquare()
        item:getWorldItem():setSquare(nil)
        getPlayerLoot(player):refreshBackpacks()
        return
    end

    if item:isEquipped() then
        local playerObj = item:getContainer():getParent()

        item:getContainer():setDrawDirty(true);
        item:setJobDelta(0.0);
        playerObj:removeWornItem(item)

        local hotbar = getPlayerHotbar(playerObj:getPlayerNum())
        local fromHotbar = false;
        if hotbar then
            fromHotbar = hotbar:isItemAttached(item);
        end

        if fromHotbar then
            hotbar.chr:setAttachedItem(item:getAttachedToModel(), item);
            playerObj:resetEquippedHandsModels()
        end

        if item == playerObj:getPrimaryHandItem() then
            if (item:isTwoHandWeapon() or item:isRequiresEquippedBothHands()) and item == playerObj:getSecondaryHandItem() then
                playerObj:setSecondaryHandItem(nil);
            end
            playerObj:setPrimaryHandItem(nil);
        end
        if item == playerObj:getSecondaryHandItem() then
            if (item:isTwoHandWeapon() or item:isRequiresEquippedBothHands()) and item == playerObj:getPrimaryHandItem() then
                playerObj:setPrimaryHandItem(nil);
            end
            playerObj:setSecondaryHandItem(nil);
        end
    end

    if isClient() and not instanceof(item:getOutermostContainer():getParent(), "IsoPlayer") and item:getContainer():getType()~="floor" then
        item:getContainer():removeItemOnServer(item);
    end

    item:getContainer():DoRemoveItem(item);
end

function RemoverItemAndBuildsTool.removeItems(items, player)
    for i, item in ipairs(items) do
        RemoverItemAndBuildsTool.removeItem(item, player)
    end
end

--************************************************************************--
--Блок удаления предмета в инветаре (дубль)
-- local function RemoveItemContextOptions(player, context, items)
--     if not (isDebugEnabled() or (isClient() and (isAdmin() or getAccessLevel() ~= ""))) then return true; end

--     local container = nil
--     local resItems = {}
--     for i,v in ipairs(items) do
--         if not instanceof(v, "InventoryItem") then
--             for _, it in ipairs(v.items) do
--                 resItems[it] = true
--             end
--             container = v.items[1]:getContainer()
--         else
--             resItems[v] = true
--             container = v:getContainer()
--         end
--     end

--     local listItems = {}
--     for v, _ in pairs(resItems) do
--         table.insert(listItems, v)
--     end

--     local removeOption = context:addDebugOption("Delete:")
--     local subMenuRemove = ISContextMenu:getNew(context)
--     context:addSubMenu(removeOption, subMenuRemove)

--     subMenuRemove:addOption("1 item", listItems[1], RemoverItemAndBuildsTool.removeItem, player)
--     subMenuRemove:addOption("selected", listItems, RemoverItemAndBuildsTool.removeItems, player)
-- end
-- Events.OnFillInventoryObjectContextMenu.Add(RemoveItemContextOptions)

