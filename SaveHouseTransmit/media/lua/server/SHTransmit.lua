if isClient() then return end

--Преобразорвание таблицы в строку
local function tableToString(t)
    local result = ""
    for k, v in pairs(t) do
        if type(k) == "table" then
            result = result .. tableToString(k)
        elseif type(v) == "table" then
            result = result .. tableToString(v)
        else
            result = result .. tostring(k) .. "=" .. tostring(v) .. " " .. "\n"
        end
    end
    return result
end

 --Сохраняем в текстовый файл данные убежища для дальнейшей обработки
local function SaveSHListData(SHData)
    local fileWriterObj = getFileWriter("SafeHousesData/" .. SHData.Owner .. ".txt", true, false);
    fileWriterObj:write(tableToString(SHData));
    fileWriterObj:close();
end

local timeToRemoveSHOption = getServerOptions():getOptionByName("SafeHouseRemovalTime"):getValue() --Получаем значение настройки SafeHouseRemovalTime
local timeInMillis = timeToRemoveSHOption * 3600000 --Переводим в мс

local function checkSafehouses() --Получаем список всех убежищ и проверяем какие из них истекли
    local currentTime = getTimeInMillis()
    local safehouses = SafeHouse.getSafehouseList()
    local count = safehouses:size()
    for i = count - 1, 0, -1 do
        local SHData = {}
        local safehouse = safehouses:get(i)
        local lastVisitedTimestamp = safehouse:getLastVisited()   
        if (lastVisitedTimestamp+timeInMillis) <= currentTime then --Проверяем вышло ли время
            SHData.Name = safehouse:getTitle()
            SHData.Owner = safehouse:getOwner()
            SHData.X = safehouse:getX()
            SHData.X2 = safehouse:getX2()
            SHData.Y = safehouse:getY()
            SHData.Y2 = safehouse:getY2()
            SHData.Members = safehouse:getPlayers()
            SHData.lastVisited = os.date("%Y-%m-%d %H:%M:%S", lastVisitedTimestamp / 1000)
            SHData.CurrentTime = os.date("%Y-%m-%d %H:%M:%S", currentTime / 1000)
            SHData.Delete = true
            SaveSHListData(SHData)
            safehouse:removeSafeHouse(getPlayerFromUsername(safehouse:getOwner())) --Удаления убежища у которого истекло время после пометки их к удалению
        else --Если время не истекло - фиксируем обновленные значения
            SHData.Name = safehouse:getTitle()
            SHData.Owner = safehouse:getOwner()
            SHData.X = safehouse:getX()
            SHData.X2 = safehouse:getX2()
            SHData.Y = safehouse:getY()
            SHData.Y2 = safehouse:getY2()
            SHData.Members = safehouse:getPlayers()
            SHData.lastVisited = os.date("%d-%m-%Y %H:%M:%S", lastVisitedTimestamp / 1000)
            SHData.CurrentTime = os.date("%d-%m-%Y %H:%M:%S", currentTime / 1000)
            SHData.Delete = false
            SaveSHListData(SHData)
        end
    end
end
--Events.EveryTenMinutes.Add(checkSafehouses)
Events.EveryDays.Add(checkSafehouses) -- Проверять каждый игровой день