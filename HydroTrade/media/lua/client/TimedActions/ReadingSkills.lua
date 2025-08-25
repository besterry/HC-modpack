require "TimedActions/ISReadABook"

-- Сохраняем оригинальные функции
local original_ISReadABook_update = ISReadABook.update
local original_ISReadABook_new = ISReadABook.new

-- Хук для функции update
function ISReadABook:update()
    -- Вызываем оригинальную функцию
    original_ISReadABook_update(self)

    -- Добавляем нашу логику XP
    if self.pageTimer and self.pageTimer >= 200 then
        self.pageTimer = 0
        self:addReadingXP()
    end
end

-- Хук для функции new
function ISReadABook:new(character, item, time)
    -- Вызываем оригинальную функцию
    local o = original_ISReadABook_new(self, character, item, time)
    
    -- Применяем бонус от навыка чтения
    if o and o.maxTime then
        local readingLevel = character:getPerkLevel(Perks.Reading)
        if readingLevel > 0 then
            local readingBonus = math.max(0.5, 1.0 - (0.05 * readingLevel))
            o.maxTime = o.maxTime * readingBonus
        end
    end
    
    return o
end

-- Функция начисления XP за чтение
function ISReadABook:addReadingXP()
    local character = self.character
    local item = self.item
    
    -- Проверяем, не читали ли уже эту книгу полностью
    -- if character:getAlreadyReadPages(item:getFullType()) >= item:getNumberOfPages() then
    --     print("already read")
    --     return
    -- end
    
    -- Базовый XP за страницу
    local baseXP = SandboxVars.Reading.SkillsEXP or 4 -- 4 = 54 опыта за 220 страниц
    -- 5 = 75.75 опыта за 220 страниц (100% + 15% + 20% - 20% = 105% = 75.75)
    
    -- print("Type: " .. item:getType())
    -- Журналы дают 50% XP
    if item:getType() == "Magazine" or item:getType() == "Newspaper" then -- MetalworkMag1
        baseXP = baseXP * 0.5
    end
    
    -- Применяем множители за условия
    local multiplier = 1.0
    
    -- Хорошие условия: +20% XP
    if self:hasGoodConditions() then
        multiplier = multiplier * 1.2
    end
    
    -- Плохие условия: -20% XP
    if self:hasBadConditions() then
        multiplier = multiplier * 0.8
    end

    if character:HasTrait("FastReader") or character:HasTrait("BookWorm") then
        multiplier = multiplier * 1.15
        -- print("BookWorm bonus applied: +15% XP")
    end
    
    -- Штраф за перк "Не любит читать книги" (-25% XP)
    if character:HasTrait("SlowReader") or character:HasTrait("Illiterate") then
        multiplier = multiplier * 0.75
        -- print("Illiterate penalty applied: -25% XP")
    end
    
    -- Начисляем XP
    local finalXP = math.floor(baseXP * multiplier)
    -- print("Final XP: +" .. finalXP)
    character:getXp():AddXP(Perks.Reading, finalXP)
end

-- Проверка хороших условий
function ISReadABook:hasGoodConditions()
    local character = self.character
    local cell = character:getCurrentSquare()
    
    -- Хорошее освещение
    local hasGoodLight = cell:getLightLevel(character:getPlayerNum()) > 0.3
    
    -- Сидячая позиция
    local isSitting = character:isSitOnGround()
    
    -- Сытость
    local hunger = character:getStats():getHunger()
    local hasGoodHunger = hunger < 0.3
    
    -- Низкий стресс
    local stress = character:getStats():getStress()
    local hasLowStress = stress < 0.3
    
    return hasGoodLight and isSitting and hasGoodHunger and hasLowStress
end

-- Проверка плохих условий
function ISReadABook:hasBadConditions()
    local character = self.character
    
    -- Сонливость
    local fatigue = character:getStats():getFatigue()
    local isSleepy = fatigue > 0.7
    
    -- Голод
    local hunger = character:getStats():getHunger()
    local isHungry = hunger > 0.7
    
    -- Высокий стресс
    local stress = character:getStats():getStress()
    local isStressed = stress > 0.7
    
    return isSleepy or isHungry or isStressed
end

-- Система XP для навыка
function addSkillBooks()
    SkillBook["Reading"] = {}
    SkillBook["Reading"].perk = Perks.Reading
    SkillBook["Reading"].maxMultiplier1 = 3
    SkillBook["Reading"].maxMultiplier2 = 5
    SkillBook["Reading"].maxMultiplier3 = 8
    SkillBook["Reading"].maxMultiplier4 = 12
    SkillBook["Reading"].maxMultiplier5 = 16
end

Events.OnGameStart.Add(addSkillBooks)