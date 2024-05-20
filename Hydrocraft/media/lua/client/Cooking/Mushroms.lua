-- local mushrooms = {
--     "MushroomGeneric1", "MushroomGeneric2", "MushroomGeneric3", "MushroomGeneric4", 
--     "MushroomGeneric5", "MushroomGeneric6", "MushroomGeneric7", "HCPortobello", 
--     "HCShiitake", "HCBlewitshroom", "HCLobstershroom", "HCWitchshatshroom", 
--     "HCYellowmorelshroom", "HCChantrelle"
-- }

-- local itemCounts = {}

-- function HCCanBunchofshrooms(items)
    
--     local mushroomCounter = 0
--     local id = items:getID()
--     -- Если предмет уже зарегистрирован, увеличить его количество
--     itemCounts[id] = true
--     for _ in pairs(itemCounts) do
--         mushroomCounter = mushroomCounter + 1
--     end
--     -- Временный код для отображения количества каждого предмета
--     print("Items:",mushroomCounter)
-- end

-- function Recipe.OnTest.HCBunchofshrooms(item)    
--     local mushroomCount = 0
--     for i=1, #mushrooms do
--         mushroomCount = mushroomCount + player:getInventory():getItemCount(mushrooms[i])
--     end
    
--     return mushroomCount >= 4
-- end

-- function UseMushrooms(items, result, player)
    
-- end
