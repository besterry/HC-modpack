TZone = TZone or {}

function TZoneCheckGasMask(gasfilter) -- Функция проверки наличия поврежденной маски
    if not TZone.ProtectiveMasks or #TZone.ProtectiveMasks == 0 then
        return false
    end
    local maskTypes = {}
    for _, maskType in ipairs(TZone.ProtectiveMasks) do
        maskTypes[maskType] = true
    end
    local player = getPlayer()
    for i=0, player:getInventory():getItems():size()-1 do
        local item = player:getInventory():getItems():get(i)
            local itemType = item:getType()            
            if maskTypes[itemType] then -- Проверяем, является ли предмет маской 
                local modData = item:getModData()
                if modData and modData.percent and modData.percent < 1 then
                    return true -- Маска повреждена
                end
            end
        end
    end
    return false -- Маска не повреждена или отсутствует
end 

function TZoneGasMask(gasfilter) -- Функция смены фильтра
    if not TZone.ProtectiveMasks or #TZone.ProtectiveMasks == 0 then
        return
    end    
    local maskTypes = {}
    for _, maskType in ipairs(TZone.ProtectiveMasks) do
        maskTypes[maskType] = true
    end
    local player = getPlayer()
    for i=0, player:getInventory():getItems():size()-1 do
        local item = player:getInventory():getItems():get(i)
        if item:getType() then
            local itemType = item:getType()
            if maskTypes[itemType] then
                local modData = item:getModData()
                if modData then
                    modData.percent = 1 -- Восстанавливаем фильтр до 100%
                end
            end
        end
    end
end