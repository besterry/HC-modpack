-- Убираем циклический require
-- require "shared/Tzone/TZone"
local MOD_NAME = "TZone"
-- Кэш зон по регионам для оптимизации
local TZoneCache = {} -- кэш зон
local lastPlayerPos = {x = 0, y = 0} -- последняя позиция игрока
local lastZoneCheck = nil -- последнее состояние зоны
local zoneCheckCooldown = 1000 -- миллисекунды между проверками

local enable = SandboxVars.ToxicZone.Enable or false
-- Переменные тумана
local tzoneTintTex = nil
local tzoneFogTex = nil
local maskLensTintTex = nil
local maskRimTex = nil
local tzoneOverlay = nil
local tzoneAlpha = 0
local vignetteAlpha = 0
local maskTintAlpha = 0
local maskRimAlpha = 0
local tzoneVisible = false
local tzoneFadeSpeed = 0.005 -- ~2 сек до полной густоты тумана
local maskRimFadeSpeed = 0.03
local TOXIC_TINT_NAKED = 0.65
local TOXIC_TINT_MASKED = 0.14
local TOXIC_VIGNETTE_NAKED = 0.52
local TOXIC_VIGNETTE_MASKED = 0.08
local MASK_LENS_TINT = 0.08
local MASK_LENS_TINT_ZONE = 0.12
local MASK_RIM_ALPHA = 0.22
local MASK_RIM_ALPHA_ZONE = 0.88
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
	if player:isGodMod() then return true end -- Если godmod то защита включена
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

local function hasProtectiveMask(player)
	if not player then return false end
	local inventory = player:getInventory()
	if not inventory then return false end
	local it = inventory:getItems()
	for i = 0, it:size() - 1 do
		local item = it:get(i)
		if player:isEquippedClothing(item) then
			local iType = item:getType()
			for j = 1, #ProtectiveMasks do
				if ProtectiveMasks[j] == iType then
					local percent = item:getModData().percent or 1
					if percent > 0 then return true end
				end
			end
		end
	end
	return false
end

local function getMaskFilterPercent(player)
	if not player then return 1 end
	local lowest = 1
	local found = false
	local inventory = player:getInventory()
	if not inventory then return 1 end
	local it = inventory:getItems()
	for i = 0, it:size() - 1 do
		local item = it:get(i)
		if player:isEquippedClothing(item) then
			local iType = item:getType()
			for j = 1, #ProtectiveMasks do
				if ProtectiveMasks[j] == iType then
					found = true
					local percent = item:getModData().percent or 1
					if percent < lowest then lowest = percent end
				end
			end
		end
	end
	if not found then return 1 end
	return lowest
end

-- Функция для получения урона от токсичности
function shouldTakeToxicDamage(player)
    local PlayerZone = isPlayerInTZone(player)

    if protectiveTZoneEquipped(player, PlayerZone) then  -- Если фильтр на игроке, то не наносим урон
        return false 
    end

    if not PlayerZone then  -- Если игрок не в зоне, то не наносим урон
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
local function getTZonesFromModData() -- Получение списка зон из ModData на клиенте
    if isServer() then return end
    local tzones = ModData.get("TZone")
    -- Имеем таблицу формата {title = {x = x, y = y, x2 = x2, y2 = y2}}
    if not tzones then
        print("TZONE: getTZonesFromModData No TZones in ModData")
        return {}
    end
    -- Фильтруем только активные зоны
    local zoneCount = 0
    local activeZones = {}
    for title, zone in pairs(tzones) do
        -- print("zone:" .. title .. " => enable:" .. tostring(zone.enable))
        zoneCount = zoneCount + 1
        if zone.enable ~= false then -- проверяем что зона не отключена
            activeZones[title] = zone
        end
    end
    print("TZONE: getTZonesFromModData completed with " .. zoneCount .. " zones")
    return activeZones
end

-- Группировка зон по регионам (каждые 100x100 тайлов)
local function buildZoneCache(tzones) 
    if isServer() then return end -- Только на клиенте для формирования кэша зон
    if not tzones then tzones = getTZonesFromModData() end
    if not tzones then return end -- если нет зон, то выходим
    TZoneCache = {} -- очищаем кэш
    local zoneCount = 0
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
                zoneCount = zoneCount + 1
            end
        end
    end
    print("TZONE: buildZoneCache completed with " .. zoneCount .. " zones")
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

local function fadeAlpha(current, target, speed)
	if current < target then
		return math.min(current + speed, target)
	end
	if current > target then
		return math.max(current - speed, target)
	end
	return current
end

local function loadTZoneTextures()
	if tzoneTintTex then return end
	tzoneTintTex = getTexture("media/ui/ToxicFogTint.png")
	tzoneFogTex = getTexture("media/ui/ToxicFogVignette.png")
	maskLensTintTex = getTexture("media/ui/GasMaskLensTint.png")
	maskRimTex = getTexture("media/ui/GasMaskRim.png")
	tzoneOverlay = getTexture("media/ui/ToxicOverlay.png")
end

local function drawOverlay(tex, alpha)
	if not tex or alpha <= 0 then return end
	local core = getCore()
	UIManager.DrawTexture(tex, 0, 0, core:getScreenWidth(), core:getScreenHeight(), alpha)
end

local function updateMaskEquippedOverlay(player)
	if not player then return end
	local targetRim = 0
	local targetLens = 0
	if hasProtectiveMask(player) then
		targetRim = MASK_RIM_ALPHA
		targetLens = MASK_LENS_TINT
		if isPlayerInTZone(player) then
			targetRim = MASK_RIM_ALPHA_ZONE
			local leak = 1 - getMaskFilterPercent(player)
			targetLens = MASK_LENS_TINT + MASK_LENS_TINT_ZONE + leak * 0.10
		end
	end
	maskRimAlpha = fadeAlpha(maskRimAlpha, targetRim, maskRimFadeSpeed)
	maskTintAlpha = fadeAlpha(maskTintAlpha, targetLens, maskRimFadeSpeed)
end

-- Отрисовка тумана и эффектов противогаза
local function renderTZoneOverlay()
	loadTZoneTextures()
	if tzoneVisible then
		local tintTex = tzoneTintTex or tzoneOverlay
		drawOverlay(tintTex, tzoneAlpha)
		if tzoneFogTex and vignetteAlpha > 0 then
			drawOverlay(tzoneFogTex, vignetteAlpha)
		end
	end
	if maskLensTintTex and maskTintAlpha > 0 then
		drawOverlay(maskLensTintTex, maskTintAlpha)
	end
	if maskRimTex and maskRimAlpha > 0 then
		drawOverlay(maskRimTex, maskRimAlpha)
	end
end

-- Функция обновления тумана
local function updateTZoneOverlay(player)
	local zone = isPlayerInTZone(player)
	if zone then
		if not tzoneVisible then
			tzoneVisible = true
		end
		local hasMask = hasProtectiveMask(player)
		local targetTint = TOXIC_TINT_NAKED
		local targetVignette = TOXIC_VIGNETTE_NAKED
		if hasMask then
			local filterPercent = getMaskFilterPercent(player)
			local leak = 1 - filterPercent
			targetTint = TOXIC_TINT_MASKED + leak * (TOXIC_TINT_NAKED - TOXIC_TINT_MASKED)
			targetVignette = TOXIC_VIGNETTE_MASKED + leak * (TOXIC_VIGNETTE_NAKED - TOXIC_VIGNETTE_MASKED)
		end
		tzoneAlpha = fadeAlpha(tzoneAlpha, targetTint, tzoneFadeSpeed)
		vignetteAlpha = fadeAlpha(vignetteAlpha, targetVignette, tzoneFadeSpeed)
	else
		if tzoneVisible then
			tzoneAlpha = fadeAlpha(tzoneAlpha, 0, tzoneFadeSpeed)
			vignetteAlpha = fadeAlpha(vignetteAlpha, 0, tzoneFadeSpeed)
			if tzoneAlpha <= 0 and vignetteAlpha <= 0 then
				tzoneVisible = false
				tzoneAlpha = 0
				vignetteAlpha = 0
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
        updateTZoneOverlay(player)
        updateMaskEquippedOverlay(player)
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
    
    updateTZoneOverlay(player)
    updateMaskEquippedOverlay(player)
    lastZoneCheckTime = currentTime
end

-- Инициализация кэша при загрузке (получаем список зон с сервера)
Events.OnReceiveGlobalModData.Add(function(module, packet)
    if module == "TZone" then
        -- print("OnReceiveGlobalModData")
        buildZoneCache(nil)        
    end
end)

local MOD_NAME = "TZone"
local Commands = {}
Commands.onRemoveTZone = function(player, args)
    -- print("onRemoveTZone")
    buildZoneCache(nil)
end

Commands.onToggleTZone = function(player, args)
    -- print("onToggleTZone")
    buildZoneCache(nil)    
end

Commands.onEditTZone = function(player, args)
    buildZoneCache(nil)
end

local OnServerCommand = function(module, command, player, args) 
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end
Events.OnServerCommand.Add(OnServerCommand)

-- Инициализация при обновлении игрока
-- local function initializeTZoneOnPlayerUpdate(player)
--     if not player then return end    
--     if ModData.get("TZone") then
--         print("TZONE: initializeTZoneOnPlayerUpdate")
--         buildZoneCache(nil)
--         -- Проверяем что кэш действительно заполнен
--         local cacheNotEmpty = false
--         for k, v in pairs(TZoneCache) do -- проверяем кэш заполнен ли
--             print("TZONE: cache success filled: " , k)
--             cacheNotEmpty = true
--             break -- выходим после первого элемента
--         end        
--         -- Удаляем событие только если кэш заполнен
--         if cacheNotEmpty then
--             print("TZONE: success remove initializeTZoneOnPlayerUpdate")
--             Events.OnPlayerUpdate.Remove(initializeTZoneOnPlayerUpdate)
--         end
--     end
-- end
-- Events.OnPlayerUpdate.Add(initializeTZoneOnPlayerUpdate)

if isClient() then   
    local Commands = {}
    Commands.onTZones = function(args)
        if isServer() then return end
        -- print("TZONE: onTZones")
        buildZoneCache(args.zones) -- Обновляем кэш зон
        ModData.add(MOD_NAME, args.zones) -- Добавляем зоны в ModData (у некоторых игроков ModData не инициализируется сразу или некорректно)
    end

    local OnServerCommand = function(module, command, player, args) 
        if module == MOD_NAME and Commands[command] then
            Commands[command](player, args)
        end
    end
    Events.OnServerCommand.Add(OnServerCommand)

    local commandsReady = false -- Задержка 1 тик для отправки запроса зон с сервера (на 1м тике не отправится запрос)
    local function initializeTZoneClient()    
        local player = getPlayer()
        if not player then return end
        if commandsReady then
            -- print("TZONE: getTZones")
            sendClientCommand(player, MOD_NAME, "getTZones", {}) -- Запрос зон с сервера
            Events.OnTick.Remove(initializeTZoneClient)
        else 
            commandsReady = true
        end
    end
    Events.OnTick.Add(initializeTZoneClient)

    Events.OnGameStart.Add(loadTZoneTextures)
    -- Добавляем события только на клиенте 
    Events.OnPreUIDraw.Add(renderTZoneOverlay) -- Отрисовка тумана
    Events.OnPlayerUpdate.Add(checkZone) -- Проверка зоны
    Events.OnPlayerUpdate.Add(shouldTakeToxicDamage) -- Добавляем вызов функции урона
end

-- Экспортируем функции для использования в других файлах
TZone = TZone or {}
TZone.isPlayerInTZone = isPlayerInTZone
TZone.getZonesInPlayerRegion = getZonesInPlayerRegion
TZone.buildZoneCache = buildZoneCache
TZone.shouldTakeToxicDamage = shouldTakeToxicDamage
TZone.protectiveTZoneEquipped = protectiveTZoneEquipped
TZone.ProtectiveMasks = ProtectiveMasks