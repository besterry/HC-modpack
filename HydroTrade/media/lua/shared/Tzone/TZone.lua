-- Убираем циклический require
-- require "shared/Tzone/TZone"

-- Кэш зон по регионам для оптимизации
local TZoneCache = {} -- кэш зон
local lastPlayerPos = {x = 0, y = 0} -- последняя позиция игрока
local lastZoneCheck = nil -- последнее состояние зоны
local zoneCheckCooldown = 1000 -- миллисекунды между проверками

local enable = SandboxVars.ToxicZone.Enable or false
-- Переменные тумана
local tzoneOverlay = getTexture("media/ui/ToxicOverlay.png") -- текстура тумана
local tzoneAlpha = 0 -- прозрачность тумана
local tzoneVisible = false -- видимость тумана
local tzoneFadeSpeed = 0.01 -- скорость появления/исчезновения
local lastZoneState = nil -- последнее состояние зоны
local lastZoneCheckTime = 0 -- последнее время проверки зоны
local zoneCheckInterval = 1000 -- интервал проверки зоны
local currentZoneTitle = nil -- текущее название зоны
local NotificationOnEntered = false -- уведомление о входе в зараженную зону
local multiplier = SandboxVars.ToxicZone.FilterDurationMultiplier or 0.1

-- Защитные маски от тумана
ProtectiveMasks = {
    "Hat_GasMask",
    "Hat_DuckMask",
    "Hat_FM53",
    "Hat_M50",
    "Hat_M45_GasMask",
    "Hat_MCU_GasMask",
    "Hat_MSA_Gas_Mask",
    "Hat_MSA_Gas_Mask_AMP",
    "Hat_NBCmask",
    "HazmatSuit",
}

local warningSent1, warningSent2, warningSent3 = false, false, false
-- Функция проверки защитного снаряжения
function protectiveTZoneEquipped(player, PlayerZone)
    local zone = PlayerZone
	if player:isGodMod() then return true end -- Если игрок бог, то возвращаем true
	local inventory = player:getInventory()	-- Получаем инвентарь игрока
	local it = inventory:getItems()			-- Получаем предметы в инвентаре
	if player and inventory then
		for i = 0, it:size()-1 do
			local item = it:get(i) -- Получаем предмет
			if player:isEquippedClothing(item) then
				local iType = item:getType()			-- Получаем тип предмета
				for i = 1, #ProtectiveMasks do
					if ProtectiveMasks[i] == iType then
                        local modData = item:getModData()
                        -- Инициализируем percent если его нет (100 = 100%)
                        if not modData.percent then modData.percent = 1 end --Используем именно 1, а не 100%
                        local percent = modData.percent
						if percent > 0 then
                            if not zone then return true end -- Если игрок не в зоне, то не отнимаем целостность фильтра
                            multiplier = SandboxVars.ToxicZone.FilterDurationMultiplier or 0.1
							modData.percent = percent - 0.00001*multiplier -- Уменьшаем целостность фильтра, используем setModData() для изменения значения в ModData  0.00001 - 21 минута
                            if modData.percent > 0.5 then warningSent1 = false end -- Сбрасываем флаг, если фильтр больше 50% или сменился фильтр/маска
                            if modData.percent < 0.5 and not warningSent1 then
                                player:Say(getText("IGUI_TZoneFilterWarning")) -- Фильтр начинает забиваться...
                                warningSent1 = true
                            end
                            if modData.percent > 0.1 then warningSent2 = false end -- Сбрасываем флаг, если фильтр больше 10%
                            if modData.percent < 0.1 and not warningSent2 then
                                player:Say(getText("IGUI_TZoneFilterCritical")) -- Фильтр почти забит! Нужно менять!
                                warningSent2 = true
                            end
                            if modData.percent > 0 then warningSent3 = false end -- Сбрасываем флаг, если фильтр больше 0%
							if modData.percent < 0 and not warningSent3 then
								modData.percent = 0 -- Если целостность меньше 0, то устанавливаем её в 0
                                player:Say(getText("IGUI_TZoneFilterBroken")) -- Черт, фильтру хана!
                                warningSent3 = true
							end
							return true
						else
                            warningSent1, warningSent2, warningSent3 = false, false, false
							return false 
						end
					end
				end	
			end
		end
	end
	return false
end

-- Функция для получения урона от токсичности
function shouldTakeToxicDamage(player)
    local PlayerZone = isPlayerInTZone(player)

    if protectiveTZoneEquipped(player, PlayerZone) then  -- Проверяет защитный фильтр (отображается в тултипе)
        return false 
    end

    if not PlayerZone then  -- Проверяет находится ли игрок в зоне
        return false 
    end  

    local toxic_Fog = ( 0.15 * ( GameTime.getInstance():getMultiplier() / 1.6) ) 
    local stats = player:getStats()
    local fatigue = stats:getFatigue()
    local isOnline = (isClient() or isServer())
    local sleepOK = isOnline and getServerOptions():getBoolean("SleepAllowed") and getServerOptions():getBoolean("SleepNeeded")

    if fatigue < 1 and (sleepOK or not isOnline) then
        local newFatigue = fatigue + ( 0.001 * toxic_Fog )
        stats:setFatigue(newFatigue)
    end
    
    toxic_Fog = (toxic_Fog * 1.0 / 2) -- Уменьшаем урон в 2 раза
    
    local damage = player:getBodyDamage()
    
    -- Применяем урон
    local headDamage = 0.1 * toxic_Fog
    local torsoDamage = 0.1 * toxic_Fog
    local neckDamage = 0.1 * toxic_Fog
    local generalDamage = 0.015 * toxic_Fog
    
    damage:getBodyPart(BodyPartType.Head):ReduceHealth(headDamage)
    damage:getBodyPart(BodyPartType.Torso_Upper):ReduceHealth(torsoDamage)
    damage:getBodyPart(BodyPartType.Neck):ReduceHealth(neckDamage)
    damage:ReduceGeneralHealth(generalDamage)
    
    -- Проверяем здоровье
    if damage:getBodyPart(BodyPartType.Head):getHealth() < 1 then
        damage:getBodyPart(BodyPartType.Head):setHealth(0)
    end
    if damage:getBodyPart(BodyPartType.Torso_Upper):getHealth() < 1 then
        damage:getBodyPart(BodyPartType.Torso_Upper):setHealth(0)
    end
    if damage:getBodyPart(BodyPartType.Neck):getHealth() < 1 then
        damage:getBodyPart(BodyPartType.Neck):setHealth(0)
    end
    -- Очень редко выводим сообщение о повреждении
    if ZombRand(1, 800) == 1 then
        local messages = {
            getText("IGUI_TZoneDamageCough"), -- *кашляет* Этот воздух...
            getText("IGUI_TZoneDamageDizzy"), -- Голова кружится...
            getText("IGUI_TZoneDamageNausea") -- Тошнит от этих паров...
        }
        player:Say(messages[ZombRand(1, #messages+1)])
    end
end

-- Функция для получения зон из серверной ModData
local function getTZonesFromModData()
    local tzones = ModData.get("TZone")
    -- Имеем таблицу формата {title = {x = x, y = y, x2 = x2, y2 = y2}}
    if not tzones then
        return {}
    end
    -- Фильтруем только активные зоны
    local activeZones = {}
    for title, zone in pairs(tzones) do
        -- print("zone:" .. title .. " => enable:" .. tostring(zone.enable))
        if zone.enable ~= false then -- проверяем что зона не отключена
            activeZones[title] = zone
        end
    end
    return activeZones
end

-- Группировка зон по регионам (каждые 100x100 тайлов)
local function buildZoneCache()
    local tzones = getTZonesFromModData()
    if not tzones then return end -- если нет зон, то выходим
    TZoneCache = {} -- очищаем кэш
    
    for title, zone in pairs(tzones) do
        local startRegionX = math.floor(zone.x / 100)
        local startRegionY = math.floor(zone.y / 100)
        local endRegionX = math.floor(zone.x2 / 100)
        local endRegionY = math.floor(zone.y2 / 100)
        
        -- Добавляем зону во все регионы, которые она пересекает
        for rx = startRegionX, endRegionX do
            for ry = startRegionY, endRegionY do
                local regionKey = rx .. "x" .. ry
                if not TZoneCache[regionKey] then
                    TZoneCache[regionKey] = {}
                end
                TZoneCache[regionKey][title] = zone
            end
        end
    end
end

-- Проверка находится ли игрок в зоне TZone
function isPlayerInTZone(player)
    if not player then return false end
    
    local currentTime = getTimestamp() or 0 -- добавляем fallback
    local playerX = player:getX()
    local playerY = player:getY()
    
    -- Проверяем кэш только если позиция изменилась или прошло время
    if lastPlayerPos.x == playerX and lastPlayerPos.y == playerY and lastZoneCheck then
        -- Проверяем что lastZoneCheck это число (время)
        if type(lastZoneCheck) == "number" and (currentTime - lastZoneCheck) < zoneCheckCooldown then
            return lastZoneCheck
        end
    end
    
    -- Обновляем позицию и время
    lastPlayerPos.x = playerX
    lastPlayerPos.y = playerY
    lastZoneCheck = currentTime
    
    -- Определяем текущий регион игрока
    local currentRegionX = math.floor(playerX / 100)
    local currentRegionY = math.floor(playerY / 100)
    local regionKey = currentRegionX .. "x" .. currentRegionY
    
    -- Проверяем зоны только в текущем регионе
    local regionZones = TZoneCache[regionKey]
    if not regionZones then
        lastZoneCheck = false
        return false
    end
    
    -- Проверяем каждую зону в регионе
    for title, zone in pairs(regionZones) do
        if playerX >= zone.x and playerX <= zone.x2 and 
           playerY >= zone.y and playerY <= zone.y2 then
            lastZoneCheck = title
            return title
        end
    end
    
    lastZoneCheck = false
    return false
end

-- Получить все зоны в текущем регионе игрока
local function getZonesInPlayerRegion(player)
    if not player then return {} end
    
    local playerX = player:getX()
    local playerY = player:getY()
    local currentRegionX = math.floor(playerX / 100)
    local currentRegionY = math.floor(playerY / 100)
    local regionKey = currentRegionX .. "x" .. currentRegionY
    
    return TZoneCache[regionKey] or {}
end

-- Функция отрисовки тумана
local function renderTZoneOverlay()
    if not tzoneVisible or not tzoneOverlay then return end    
    local core = getCore()
    local width = core:getScreenWidth()
    local height = core:getScreenHeight()
    UIManager.DrawTexture(tzoneOverlay, 0, 0, width, height, tzoneAlpha)
end

-- Функция обновления тумана
local function updateTZoneOverlay(player)
    local zone = isPlayerInTZone(player)    
    if zone then
        -- Игрок в зоне - показываем туман
        if not tzoneVisible then
            tzoneVisible = true
        end        
        -- Плавно увеличиваем прозрачность
        if tzoneAlpha < 0.5 then
            tzoneAlpha = tzoneAlpha + tzoneFadeSpeed
        end
    else
        -- Игрок не в зоне - скрываем туман
        if tzoneVisible then
            -- Плавно уменьшаем прозрачность
            if tzoneAlpha > 0 then
                tzoneAlpha = tzoneAlpha - tzoneFadeSpeed
            else
                tzoneVisible = false
                tzoneAlpha = 0
            end
        end
    end
end

-- Используем общую функцию для получения защитных предметов
local function getEquippedProtection(player)
    local protection = {}
    local inventory = player:getInventory()
    if inventory then
        local items = inventory:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if player:isEquippedClothing(item) then
                table.insert(protection, item:getType())
            end
        end
    end
    return protection
end

-- Функция проверки зоны
local function checkZone(player)
    if not player then return end
    
    local currentTime = getTimestamp() or 0 -- добавляем fallback
    local playerX = player:getX()
    local playerY = player:getY()
    
    -- Проверяем только если прошло время или изменилась позиция
    if lastZoneCheckTime and currentTime - lastZoneCheckTime < zoneCheckInterval and 
       lastPlayerPos.x == playerX and lastPlayerPos.y == playerY then
        -- Обновляем туман даже при кэшированной проверке зоны
        updateTZoneOverlay(player)
        return
    end
    
    local zone = isPlayerInTZone(player)
    
    -- Проверяем изменение состояния зоны
    if zone ~= lastZoneState then
        lastZoneState = zone
        currentZoneTitle = zone
        if zone and not NotificationOnEntered and not protectiveTZoneEquipped(player, zone) then -- Если игрок в зоне и уведомление не отправлено
            NotificationOnEntered = true
            local messages = {
                getText("IGUI_TZoneEnteredDangerous"), -- Блять! Здесь что-то не так с воздухом! Нужна защита!
                getText("IGUI_TZoneEnteredCaution"), -- Чувствую химический запах... Опасно без защиты.
                getText("IGUI_TZoneEnteredNoProtection") -- Хм... воздух здесь какой-то странный. Лучше надеть маску.
            }
            player:Say(messages[ZombRand(1, #messages+1)]) -- +1 для корректного выбора
        elseif not zone and NotificationOnEntered then -- Если игрок вышел из зоны
            NotificationOnEntered = false     
            local messages = {
                getText("IGUI_TZoneExited"), -- Наконец-то свежий воздух...
                getText("IGUI_TZoneExitedRelief") -- Дышать стало легче
            }
            player:Say(messages[ZombRand(1, #messages+1)]) -- +1 для корректного выбора
        else
            if not zone then
                NotificationOnEntered = false
            end
        end
    end
    
    -- Обновляем туман
    updateTZoneOverlay(player)    
    lastZoneCheckTime = currentTime
end

-- Инициализация кэша при загрузке (получаем список зон с сервера)
Events.OnReceiveGlobalModData.Add(function(module, packet)
    if module == "TZone" then
        -- print("OnReceiveGlobalModData")
        buildZoneCache()        
    end
end)

local MOD_NAME = "TZone"
local Commands = {}
Commands.onRemoveTZone = function(player, args)
    -- print("onRemoveTZone")
    buildZoneCache()
    
end
Commands.onToggleTZone = function(player, args)
    -- print("onToggleTZone")
    buildZoneCache()    
end

local OnServerCommand = function(module, command, player, args) 
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end
Events.OnServerCommand.Add(OnServerCommand)

-- Инициализация при старте игры
Events.OnGameStart.Add(function()
    -- Ждем немного для загрузки ModData
    local tickHandler
    tickHandler = function()
        if ModData.get("TZone") then
            -- print("OnGameStart")
            buildZoneCache()
            Events.OnTick.Remove(tickHandler)
        end
    end
    Events.OnTick.Add(tickHandler)
end)

-- Добавляем события только на клиенте
if isClient() then    
    Events.OnPreUIDraw.Add(renderTZoneOverlay) -- Отрисовка тумана
    Events.OnPlayerUpdate.Add(checkZone) -- Проверка зоны
    Events.OnPlayerUpdate.Add(shouldTakeToxicDamage) -- Добавляем вызов функции урона
    require "client/Tzone/TZone_craft"
end

-- Экспортируем функции для использования в других файлах
TZone = TZone or {}
TZone.isPlayerInTZone = isPlayerInTZone
TZone.getZonesInPlayerRegion = getZonesInPlayerRegion
TZone.buildZoneCache = buildZoneCache
TZone.shouldTakeToxicDamage = shouldTakeToxicDamage
TZone.protectiveTZoneEquipped = protectiveTZoneEquipped
TZone.ProtectiveMasks = ProtectiveMasks


-- local manager = ScriptManager.instance

-- function TZone_Tweaks()
--     -- Добавляем UseDelta ко всем защитным маскам
--     for _, maskType in ipairs(ProtectiveMasks) do
--         local item = manager:getItem("Base." .. maskType)
--         if item then
--             item:DoParam("UseDelta = " .. duration)
--         end
--     end
-- end
-- Events.OnGameBoot.Add(TZone_Tweaks)