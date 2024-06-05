local original_ISWoodenFloor_isValid = ISWoodenFloor.isValid
function ISWoodenFloor:isValid(square) --Проверка наличия плитки garage_0 при постройке пола (что бы не удалялся гараж)
    if not original_ISWoodenFloor_isValid(self, square) then -- Сначала выполняем оригинальные проверки
        return false
    end
    for i=0,square:getObjects():size()-1 do -- Добавляем новую проверку на наличие тайла garage_0
        local object = square:getObjects():get(i)
        if object:getSprite() and object:getSprite():getName() == "garage_0" then
            return false -- если гараж есть, то нельзя строить пол
        end
    end
    return true
end

local original_ISNaturalFloor_isValid = ISNaturalFloor.isValid
function ISNaturalFloor:isValid(square) --Проверка при рассыпании земли, песка, гравия
    if not original_ISNaturalFloor_isValid(self, square) then
        return false
    end
    for i=0,square:getObjects():size()-1 do
        local object = square:getObjects():get(i)
        if object:getSprite() and object:getSprite():getName() == "garage_0" then
            return false
        end
    end
    return true
end

local original_farmingPlot_isValid = farmingPlot.isValid
function farmingPlot:isValid(square) --Проверка при копании грядки
    if not original_farmingPlot_isValid(self, square) then
        return false
    end
    for i=0,square:getObjects():size()-1 do
        local object = square:getObjects():get(i)
        if object:getSprite() and object:getSprite():getName() == "garage_0" then
            return false
        end
    end
    return true
end

local original_ISShovelGroundCursor_isValid = ISShovelGroundCursor.isValid
function ISShovelGroundCursor:isValid(square) --Проверка при набирании грунта в мешок
    if not original_ISShovelGroundCursor_isValid(self, square) then
        return false
    end
    for i=0,square:getObjects():size()-1 do
        local object = square:getObjects():get(i)
        if object:getSprite() and object:getSprite():getName() == "garage_0" then
            return false
        end
    end
    return true
    
end