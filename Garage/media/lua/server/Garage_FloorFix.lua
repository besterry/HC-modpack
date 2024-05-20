local original_ISWoodenFloor_isValid = ISWoodenFloor.isValid
function ISWoodenFloor:isValid(square) --Проверка наличия плитки garage_0 при постройке пола (что бы не удалялся гараж)
    if not original_ISWoodenFloor_isValid(self, square) then -- Сначала выполняем оригинальные проверки
        return false
    end
    for i=0,square:getObjects():size()-1 do -- Добавляем новую проверку на наличие garage_0
        local object = square:getObjects():get(i)
        if object:getSprite() and object:getSprite():getName() == "garage_0" then
            return false -- если гараж есть, то нельзя строить пол
        end
    end
    return true
end