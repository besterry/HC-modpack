-- local MOD_NAME = "TZone"
-- TZone = TZone or {}
-- TZone.Data = TZone.Data or {}
-- TZone.Data.TZone = TZone.Data.TZone or {}
-- local chanceToActivateZone = 10

-- local function initTZoneEvents()
--     if not TZone.Data.Events then
--         TZone.Data.Events = {
--             lastCheck = 0, -- время последней проверки
--             checkInterval = 10, -- проверка каждые 10 минут
--             zoneChangeChance = 0.3, -- 30% шанс изменения зоны
--             minActiveZones = 1, -- минимальное количество активных зон
--             maxActiveZones = 3 -- максимальное количество активных зон
--         }
--         ModData.add(MOD_NAME, TZone.Data)
--     end
-- end

-- local function checkAndUpdateZones() -- проверка каждый игровой день
--     local activeZones = 0 -- количество активных зон
--     local zonesCount = 0 -- общее количество зон
--     for key, value in pairs(TZone.Data.TZone) do
--         if value.enable then
--             activeZones = activeZones + 1            
--         end
--         zonesCount = zonesCount + 1
--     end    
--     if zonesCount > 0 and not activeZones then
--         if ZombRand(1, 100) < chanceToActivateZone then
--             sendClientCommand("TZone", "toggleTZone", {TZone.Data.TZone[ZombRand(1, zonesCount)].title}) -- включаем случайную зону
--             Notify.broadcast("ZoneActivated", { color={0, 255, 0} })
--         end
--     end
-- end


-- local function initGlobalModData() -- Инициализация при загрузке сервера
--     TZone.Data.TZone = ModData.getOrCreate(MOD_NAME)
--     initTZoneEvents()
--     ModData.transmit(MOD_NAME)
-- end

-- -- Регистрируем события
-- Events.OnInitGlobalModData.Add(initGlobalModData)
-- Events.EveryDays.Add(checkAndUpdateZones)
