-- Клиентская часть системы телеметрии игроков
-- Функции сбора информации об игроке

if isServer() then return end

local Commands = {}
local MOD_NAME = "PlayerHealth"
local PlayerHealthClient = {}

-- Безопасный вызов функции
local function safeCall(fn, default)
    local ok, res = pcall(fn)
    if ok then return res end
    return default
end

-- Безопасный вызов метода объекта с проверкой наличия
local function callMethod(obj, methodName, default, ...)
    if not obj then return default end
    local m = obj[methodName]
    if type(m) ~= "function" then return default end
    local ok, res = pcall(m, obj, ...)
    if ok and res ~= nil then return res end
    return default
end

-- Проверка токсичной зоны
local function isInToxicZoneSafe(player)
    if type(isPlayerInTZone) == "function" then
        return safeCall(function() return isPlayerInTZone(player) end, false) and true or false
    end
    return false
end

-- Сбор информации о травмах
local function collectInjuries()
    local p = getPlayer()
    if not p then return {} end
    
    local bd = callMethod(p, "getBodyDamage", nil)
    if not bd then return {} end
    
    local arr = {}
    local parts = callMethod(bd, "getBodyParts", nil)
    if not parts then return arr end
    local count = callMethod(parts, "size", 0)
    for i = 0, count - 1 do
        local b = callMethod(parts, "get", nil, i)
        if b then
            local flags = {}
            if callMethod(b, "HasInjury", false) then table.insert(flags, "inj") end
            if callMethod(b, "bleeding", false) then table.insert(flags, "bleed") end
            if callMethod(b, "bitten", false) or callMethod(b, "isBitten", false) then table.insert(flags, "bite") end
            if callMethod(b, "scratched", false) or callMethod(b, "isScratched", false) then table.insert(flags, "scr") end
            if callMethod(b, "deepWounded", false) or callMethod(b, "isDeepWounded", false) then table.insert(flags, "deep") end
            if callMethod(b, "isBurnt", false) then table.insert(flags, "burn") end
            if callMethod(b, "haveGlass", false) then table.insert(flags, "glass") end
            if callMethod(b, "haveBullet", false) then table.insert(flags, "bullet") end
            if callMethod(b, "stitched", false) or callMethod(b, "isStitched", false) then table.insert(flags, "stitch") end
            if callMethod(b, "isSplint", false) or callMethod(b, "haveSplint", false) then table.insert(flags, "splint") end
            if callMethod(b, "isFracture", false) or callMethod(b, "fracture", false) then table.insert(flags, "fx") end
            local woundInf = callMethod(b, "getWoundInfectionLevel", 0)
            if (type(woundInf) == "number" and woundInf > 0) then table.insert(flags, "winf") end
            if callMethod(b, "bandaged", false) then
                if callMethod(b, "isBandageDirty", false) then table.insert(flags, "bandageDirty")
                else table.insert(flags, "bandage") end
            end
            if #flags > 0 then
                local partType = callMethod(b, "getType", nil)
                local name = tostring(partType or "Unknown")
                table.insert(arr, name .. ":" .. table.concat(flags, ","))
            end
        end
    end
    return arr
end

-- Сбор расширенных данных о здоровье игрока
function PlayerHealthClient.getHealthData()
    local p = getPlayer()
    if not p then return nil end
    
    local bd = callMethod(p, "getBodyDamage", nil)
    if not bd then return nil end
    
    return {
        -- Основное здоровье
        health = callMethod(bd, "getOverallBodyHealth", 0),
        poison = callMethod(bd, "getPoisonLevel", 0),
        foodSick = callMethod(bd, "getFoodSicknessLevel", 0),
        
        -- Простуда и температура
        coldStr = callMethod(bd, "getColdStrength", 0),
        hasCold = callMethod(bd, "isHasACold", false) and 1 or 0,
        catchACold = callMethod(bd, "getCatchACold", 0),
        coldDamageStage = callMethod(bd, "getColdDamageStage", 0),
        coldProgressionRate = callMethod(bd, "getColdProgressionRate", 0),
        coldReduction = callMethod(bd, "getColdReduction", 0),
        
        -- Температура тела
        tempBD = callMethod(bd, "getTemperature", 0),
        temp = callMethod(p, "getTemperature", 0),
        
        -- Влажность и огонь
        wet = callMethod(bd, "getWetness", 0),
        onFire = callMethod(p, "isOnFire", false) and 1 or 0,
        
        -- Инфекция (только доступные методы)
        infectionLevel = callMethod(bd, "getInfectionLevel", 0),
        fakeInfectionLevel = callMethod(bd, "getFakeInfectionLevel", 0),
        isInfected = callMethod(bd, "isInfected", false) and 1 or 0,
        isFakeInfected = callMethod(bd, "isFakeInfected", false) and 1 or 0,
        infectionGrowthRate = callMethod(bd, "getInfectionGrowthRate", 0),
        infectionTime = callMethod(bd, "getInfectionTime", 0),
        infectionMortalityDuration = callMethod(bd, "getInfectionMortalityDuration", 0),
        apparentInfectionLevel = callMethod(bd, "getApparentInfectionLevel", 0),
        
        -- Боль и стресс
        painReduction = callMethod(bd, "getPainReduction", 0),
        painReductionFromMeds = callMethod(bd, "getPainReductionFromMeds", 0),
        continualPainIncrease = callMethod(bd, "getContinualPainIncrease", 0),
        remotePainLevel = callMethod(bd, "getRemotePainLevel", 0),
        
        -- Начальная боль от разных типов повреждений
        initialBitePain = callMethod(bd, "getInitialBitePain", 0),
        initialScratchPain = callMethod(bd, "getInitialScratchPain", 0),
        initialThumpPain = callMethod(bd, "getInitialThumpPain", 0),
        initialWoundPain = callMethod(bd, "getInitialWoundPain", 0),
        
        -- Счетчики повреждений
        numPartsBitten = callMethod(bd, "getNumPartsBitten", 0),
        numPartsBleeding = callMethod(bd, "getNumPartsBleeding", 0),
        numPartsScratched = callMethod(bd, "getNumPartsScratched", 0),
        
        -- Здоровье от еды
        healthFromFood = callMethod(bd, "getHealthFromFood", 0),
        healthFromFoodTimer = callMethod(bd, "getHealthFromFoodTimer", 0),
        standardHealthFromFoodTime = callMethod(bd, "getStandardHealthFromFoodTime", 0),
        
        -- Добавки к здоровью
        standardHealthAddition = callMethod(bd, "getStandardHealthAddition", 0),
        reducedHealthAddition = callMethod(bd, "getReducedHealthAddition", 0),
        severelyReducedHealthAddition = callMethod(bd, "getSeverlyReducedHealthAddition", 0),
        sleepingHealthAddition = callMethod(bd, "getSleepingHealthAddition", 0),
        
        -- Снижение здоровья от плохого настроения
        healthReductionFromSevereBadMoodles = callMethod(bd, "getHealthReductionFromSevereBadMoodles", 0),
        
        -- Паника и скука
        panicIncreaseValue = callMethod(bd, "getPanicIncreaseValue", 0),
        panicIncreaseValueFrame = callMethod(bd, "getPanicIncreaseValueFrame", 0),
        panicReductionValue = callMethod(bd, "getPanicReductionValue", 0),
        boredomLevel = callMethod(bd, "getBoredomLevel", 0),
        boredomDecreaseFromReading = callMethod(bd, "getBoredomDecreaseFromReading", 0),
        unhappinessLevel = callMethod(bd, "getUnhappynessLevel", 0),
        
        -- Алкоголь
        drunkIncreaseValue = callMethod(bd, "getDrunkIncreaseValue", 0),
        drunkReductionValue = callMethod(bd, "getDrunkReductionValue", 0),
        
        -- Чихание и кашель
        sneezeCoughActive = callMethod(bd, "getSneezeCoughActive", 0),
        sneezeCoughTime = callMethod(bd, "getSneezeCoughTime", 0),
        sneezeCoughDelay = callMethod(bd, "getSneezeCoughDelay", 0),
        timeToSneezeOrCough = callMethod(bd, "getTimeToSneezeOrCough", 0),
        
        -- Таймеры чихания для разных стадий простуды
        mildColdSneezeTimerMin = callMethod(bd, "getMildColdSneezeTimerMin", 0),
        mildColdSneezeTimerMax = callMethod(bd, "getMildColdSneezeTimerMax", 0),
        coldSneezeTimerMin = callMethod(bd, "getColdSneezeTimerMin", 0),
        coldSneezeTimerMax = callMethod(bd, "getColdSneezeTimerMax", 0),
        nastyColdSneezeTimerMin = callMethod(bd, "getNastyColdSneezeTimerMin", 0),
        nastyColdSneezeTimerMax = callMethod(bd, "getNastyColdSneezeTimerMax", 0),
        
        -- Видимость зомби
        currentNumZombiesVisible = callMethod(bd, "getCurrentNumZombiesVisible", 0),
        oldNumZombiesVisible = callMethod(bd, "getOldNumZombiesVisible", 0),
        
        -- Счетчик модификаторов урона
        damageModCount = callMethod(bd, "getDamageModCount", 0),
        
        -- Смерть от ожогов
        burntToDeath = callMethod(bd, "isBurntToDeath", false) and 1 or 0,
        
        -- Доп. служебные
        healthRaw = callMethod(bd, "getHealth", 0),
        temperatureChangeTick = callMethod(bd, "getTemperatureChangeTick", 0),
        
        -- Травмы
        injuries = collectInjuries()
    }
end

-- Сбор данных о статах игрока
function PlayerHealthClient.getStatsData()
    local p = getPlayer()
    if not p then return nil end
    
    local st = callMethod(p, "getStats", nil)
    if not st then return nil end
    
    return {
        hunger = callMethod(st, "getHunger", 0),
        thirst = callMethod(st, "getThirst", 0),
        fatigue = callMethod(st, "getFatigue", 0),
        endurance = callMethod(st, "getEndurance", 0),
        pain = callMethod(st, "getPain", 0),
        stress = callMethod(st, "getStress", 0)
    }
end

-- Сбор позиционных данных
function PlayerHealthClient.getPositionData()
    local p = getPlayer()
    if not p then return nil end
    
    local x = callMethod(p, "getX", 0)
    local y = callMethod(p, "getY", 0)
    local z = callMethod(p, "getZ", 0)
    local building = callMethod(p, "getBuilding", nil)
    
    return {
        x = math.floor(x or 0),
        y = math.floor(y or 0),
        z = z,
        inside = building ~= nil,
        toxic = isInToxicZoneSafe(p)
    }
end

-- Сбор базовой информации об игроке
function PlayerHealthClient.getPlayerInfo()
    local p = getPlayer()
    if not p then return nil end
    
    return {
        username = callMethod(p, "getUsername", ""),
        steamId = callMethod(p, "getSteamID", ""),
        playerNum = callMethod(p, "getPlayerNum", 0)
    }
end

-- Сбор полной информации об игроке
Commands.getFullPlayerData = function()
    local p = getPlayer()
    if not p then return nil end
    
    local healthData = PlayerHealthClient.getHealthData()
    local statsData = PlayerHealthClient.getStatsData()
    local positionData = PlayerHealthClient.getPositionData()
    local playerInfo = PlayerHealthClient.getPlayerInfo()
    
    if not healthData or not statsData or not positionData or not playerInfo then return nil end
    
    local args = {
        player = playerInfo,
        health = healthData,
        stats = statsData,
        position = positionData
    }
    sendClientCommand(getPlayer(), MOD_NAME, "onGetFullPlayerData", args)
end

local OnServerCommand = function(module, command, player, args) 
    if module == MOD_NAME and Commands[command] then
        Commands[command](player, args)
    end
end
Events.OnServerCommand.Add(OnServerCommand)