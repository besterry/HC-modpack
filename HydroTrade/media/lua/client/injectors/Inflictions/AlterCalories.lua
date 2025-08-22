--- @param iso IsoPlayer
function AlterCalories(iso, deviation)
    local nutrition = iso:getNutrition()
    nutrition:setCalories(
        Clamp(nutrition:getCalories() + deviation, -2200, 3700)
    )
end