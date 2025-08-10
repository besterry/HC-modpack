ISLootPlantCursor = ISBuildingObject:derive("ISLootPlantCursor")
local bushSprites = {} -- Список кустов и растений

for i = 0, 63 do -- Генерируем автоматически все спрайты от d_plants_1_0 до d_plants_1_63 для быстрого поиска
    table.insert(bushSprites, "d_plants_1_" .. i)
end

local bushSpriteSet = {} -- Быстрая проверка через хеш-таблицу
for _, sprite in ipairs(bushSprites) do
    bushSpriteSet[sprite] = true
end

local function isBush(spriteName)
    return bushSpriteSet[spriteName] ~= nil
end

local function getBushObject(square)
	if not square then return nil end
	for i=1,square:getObjects():size() do
		local o = square:getObjects():get(i-1)
		if bushSpriteSet[o:getSprite():getName()] then
			return o
		end
	end
	return nil
end

function ISLootPlantCursor:create(x, y, z, north, sprite) -- Лутание куста
	local square = getWorld():getCell():getGridSquare(x, y, z) -- Получаем квадрат
    local bush = getBushObject(square)
    local lastLootTime = bush:getModData().TimeLoot or 0
    local respawnTime = bush:getModData().TimeRespawn or 0
    local currentTime = getGameTime():getWorldAgeHours()
    if lastLootTime + respawnTime <= currentTime then
        ISWorldObjectContextMenu.doLootBush(self.character, square, "bush")
    else
        self.character:Say(getText('IGUI_Already_LootBush'))
    end
	-- if self.removeType == "bush" then 
	-- 	ISWorldObjectContextMenu.doLootBush(self.character, square, "bush")
	-- elseif self.removeType == "grass" then
	-- 	ISWorldObjectContextMenu.doLootBush(self.character, square, "grass")
	-- elseif self.removeType == "wallVine" then
	-- 	ISWorldObjectContextMenu.doLootBush(self.character, square, "wallVine")
	-- end
end

ISWorldObjectContextMenu.doLootBush = function(playerObj, square, wallVine) -- Заставляем персонажа идти к кусту и лутать его
    local action = ISBushLootAction:new(playerObj, square, 100)
    if wallVine then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, square))
    else
        if not luautils.walkAdj(playerObj, square, true) then return end
    end
    ISTimedActionQueue.add(action)
end

function ISLootPlantCursor:isValid(square) -- Проверки перед лутанием
	return self:getRemovableObject(square) ~= nil
end

function ISLootPlantCursor:render(x, y, z, square) -- Выделение куста для лутания
	if not ISLootPlantCursor.floorSprite then
		ISLootPlantCursor.floorSprite = IsoSprite.new()
		ISLootPlantCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end
	local hc = getCore():getBadHighlitedColor()
    local bush = getBushObject(square)
    if bush then
        local lastLootTime = bush:getModData().TimeLoot or 0
        local respawnTime = bush:getModData().TimeRespawn or 0
        local currentTime = getGameTime():getWorldAgeHours()
        if lastLootTime + respawnTime <= currentTime then
            hc = getCore():getGoodHighlitedColor()
        else
            hc = ColorInfo.new(1, 1, 0, 1)
        end
    end
	if self:isValid(square) then
		-- hc = getCore():getGoodHighlitedColor()
		self:getRemovableObject(square):setHighlighted(true)
		self:getRemovableObject(square):setHighlightColor(0.0, 1.0, 0.0, 1.0)
	end
	ISLootPlantCursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end

function ISLootPlantCursor:getRemovableObject(square) -- Проверка на куст для лутания (для выделения)
	for i=1,square:getObjects():size() do
		local o = square:getObjects():get(i-1)
        if isBush(o:getSprite():getName()) then
            return o
        end
		if self.removeType == "bush" then
			if o:getSprite() and o:getSprite():getProperties() and o:getSprite():getProperties():Is(IsoFlagType.canBeCut) then
				return o
			end
		elseif self.removeType == "grass" then
			if o:getSprite() and o:getSprite():getProperties() and o:getSprite():getProperties():Is(IsoFlagType.canBeRemoved) then
				return o
			end
		elseif self.removeType == "wallVine" then
			local attached = o:getAttachedAnimSprite()
			if attached then
				for n=1,attached:size() do
					local sprite = attached:get(n-1)
					if sprite and sprite:getParentSprite() and sprite:getParentSprite():getName() and
						luautils.stringStarts(sprite:getParentSprite():getName(), "f_wallvines_") then
						return o
					end
				end
			end
		end
	end
	return nil
end


function ISLootPlantCursor:new(character, removeType)
	local o = ISBuildingObject.new(self)
	o:init()
	o.character = character
	o.player = character:getPlayerNum()
	o.noNeedHammer = true
	o.skipBuildAction = true
	o.isYButtonResetCursor = true
	o.removeType = removeType
	return o
end