-- Проверка на пересечение двух прямоугольников
local function isOverlap(x1, y1, x2, y2, wx1, wy1, wx2, wy2)
    return not (x2 < wx1 or x1 > wx2 or y2 < wy1 or y1 > wy2)
end

-- Преобразование координат в чанки
local function toChunks(x1, y1, x2, y2)
    local chunkX1 = math.floor(x1 / 10)
    local chunkY1 = math.floor(y1 / 10)
    local chunkX2 = math.floor(x2 / 10)
    local chunkY2 = math.floor(y2 / 10)

    return chunkX1, chunkY1, chunkX2, chunkY2
end

-- Функция для расширения зоны вайпа для исключения полного перекрытия с убежищем (+ клетки вокруг убежища, опционально)
local function expandWipeZone(wx1, wy1, wx2, wy2, shx1, shy1, shx2, shy2)
    local expanded = SandboxVars.WipedZone.AreaProtection
    -- Расширяем зону вайпа на один чанк вокруг убежища
    local expandedWipeZone = {
        wx1 = wx1 - expanded, wy1 = wy1 - expanded,
        wx2 = wx2 + expanded, wy2 = wy2 + expanded
    }
    
    -- Корректируем зону вайпа, чтобы избежать полного перекрытия с убежищем
    return expandedWipeZone.wx1, expandedWipeZone.wy1, expandedWipeZone.wx2, expandedWipeZone.wy2
end

-- Функция для разделения зоны вайпа при пересечении с убежищем
local function splitWipeZone(wx1, wy1, wx2, wy2, shx1, shy1, shx2, shy2)
    local resultZones = {}

    -- Расширяем зону вайпа
    if SandboxVars.WipedZone.AreaProtection > 0 then
        wx1, wy1, wx2, wy2 = expandWipeZone(wx1, wy1, wx2, wy2, shx1, shy1, shx2, shy2)
    end

    -- Верхняя зона
    if shy1 > wy1 then
        table.insert(resultZones, string.format("%d %d %d %d", wx1, wx2, wy1, shy1 - 1))
    end

    -- Нижняя зона
    if shy2 < wy2 then
        table.insert(resultZones, string.format("%d %d %d %d", wx1, wx2, shy2 + 1, wy2))
    end

    -- Левая зона
    if shx1 > wx1 then
        table.insert(resultZones, string.format("%d %d %d %d", wx1, shx1 - 1, math.max(wy1, shy1), math.min(wy2, shy2)))
    end

    -- Правая зона
    if shx2 < wx2 then
        table.insert(resultZones, string.format("%d %d %d %d", shx2 + 1, wx2, math.max(wy1, shy1), math.min(wy2, shy2)))
    end

    return resultZones
end

-- Функция обработки зон вайпа с учетом убежищ
local function processWipeZones(zones, safehouses)
    local resultZones = {}

    for _, zone in ipairs(zones) do
        local wx1, wx2, wy1, wy2 = zone:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        wx1, wx2, wy1, wy2 = tonumber(wx1), tonumber(wx2), tonumber(wy1), tonumber(wy2)

        local tempZones = {string.format("%d %d %d %d", wx1, wx2, wy1, wy2)}

        for i = 0, safehouses:size() - 1 do
            local safehouse = safehouses:get(i)
            local shx1, shy1 = safehouse:getX(), safehouse:getY()
            local shx2, shy2 = safehouse:getX2(), safehouse:getY2()

            -- Преобразование координат убежища в чанки
            shx1, shy1, shx2, shy2 = toChunks(shx1, shy1, shx2, shy2)

            local newZones = {}
            for _, z in ipairs(tempZones) do
                local zwx1, zwx2, zwy1, zwy2 = z:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
                zwx1, zwx2, zwy1, zwy2 = tonumber(zwx1), tonumber(zwx2), tonumber(zwy1), tonumber(zwy2)

                if isOverlap(zwx1, zwy1, zwx2, zwy2, shx1, shy1, shx2, shy2) then
                    local splitZones = splitWipeZone(zwx1, zwy1, zwx2, zwy2, shx1, shy1, shx2, shy2)
                    for _, newZone in ipairs(splitZones) do
                        table.insert(newZones, newZone)
                    end
                else
                    table.insert(newZones, z)
                end
            end
            tempZones = newZones
        end

        -- Удаляем зоны, которые полностью перекрывают чанк убежища
        local filteredZones = {}
        for _, z in ipairs(tempZones) do
            local zwx1, zwx2, zwy1, zwy2 = z:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            zwx1, zwx2, zwy1, zwy2 = tonumber(zwx1), tonumber(zwx2), tonumber(zwy1), tonumber(zwy2)

            local keepZone = true
            for i = 0, safehouses:size() - 1 do
                local safehouse = safehouses:get(i)
                local shx1, shy1 = safehouse:getX(), safehouse:getY()
                local shx2, shy2 = safehouse:getX2(), safehouse:getY2()

                -- Преобразование координат убежища в чанки
                shx1, shy1, shx2, shy2 = toChunks(shx1, shy1, shx2, shy2)

                -- Проверяем, полностью ли зона вайпа пересекает все чанки убежища
                if isOverlap(zwx1, zwy1, zwx2, zwy2, shx1, shy1, shx2, shy2) then
                    keepZone = false
                    break
                end
            end

            if keepZone then
                table.insert(filteredZones, z)
            end
        end

        for _, z in ipairs(filteredZones) do
            table.insert(resultZones, z)
        end
    end

    return resultZones
end

local function SaveWipeList(wipeList)
    local fileWriterObj = getFileWriter("WipedZone/WipedZone.txt", true, false);
    fileWriterObj:write(tostring(wipeList));
    fileWriterObj:close();
end

-- Основная функция для получения зон вайпа с учетом убежищ
local function getWipeZonesExcludingSafehouses()
    --print("Check wipe zones")
    local safehouses = SafeHouse.getSafehouseList()
    local wipeZones = SandboxVars.WipedZone.WipeZoneList
    local zones = {}

    -- Разделяем строки зон вайпа на координаты
    for zone in string.gmatch(wipeZones, "[^;]+") do
        local wx1, wx2, wy1, wy2 = zone:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        wx1, wx2, wy1, wy2 = tonumber(wx1), tonumber(wx2), tonumber(wy1), tonumber(wy2)
        table.insert(zones, string.format("%d %d %d %d", wx1, wx2, wy1, wy2))
    end

    local resultZones = processWipeZones(zones, safehouses)

    -- Конкатенация оставшихся зон в строку и вывод результата
    local resultString = table.concat(resultZones, "\n")
    resultString = resultString .. "\n"
    SaveWipeList(resultString)
end

Events.EveryDays.Add(getWipeZonesExcludingSafehouses)