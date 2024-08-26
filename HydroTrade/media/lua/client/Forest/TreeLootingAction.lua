require "TimedActions/ISBaseTimedAction"
ISTreeLootAction = ISBaseTimedAction:derive("ISTreeLootAction")

function ISTreeLootAction:isValid()
    return self.character ~= nil and self.tree ~= nil
end

function ISTreeLootAction:perform()
    --LootingTreeAfterAnimation(self.character, self.tree) --Функция для выполнения лутания после окончания анимации.
    LootingTree(self.obj,self.character) -- Не забудьте определить эту функцию
    ISBaseTimedAction.perform(self) -- Завершаем действие
end

function ISTreeLootAction:waitToStart() -- Ожидание начала действия
	self.character:faceLocation(self.tree:getX(), self.tree:getY())
	return self.character:shouldBeTurning()
end

function ISTreeLootAction:update() -- Обновление состояния во время действия
	self.character:faceLocation(self.tree:getX(), self.tree:getY())
    self.character:setMetabolicTarget(Metabolics.LightWork);
end


function ISTreeLootAction:start() -- Запуск действия
    self:setActionAnim("Loot");
    self.character:SetVariable("LootPosition", "Mid")
    -- self:setOverrideHandModels("Broom", nil);
    self.character:getEmitter():playSound("SowSeeds")
    self.character:reportEvent("EventLootItem");
    -- self.character:reportEvent("EventLootingTree");
end

function ISTreeLootAction:stop()
    ISBaseTimedAction.stop(self);
end

function ISTreeLootAction:new(character, obj, time)
    local o = {}
    -- o = ISBaseTimedAction:new(o, character)
    setmetatable(o, self)
    self.__index = self
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.tree = obj:getSquare()
    o.obj = obj
    o.character = character
    o.maxTime = time
    o.caloriesModifier = 5;
    -- if character:isTimedActionInstant() then
    --     o.maxTime = 1;
    -- end
    return o
end