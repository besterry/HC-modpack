-- if not isServer() then return end


-- -- Получаем текущее состояние
-- local Power = getSandboxOptions():getOptionByName("ElecShutModifier"):getValue() > -1
-- local Water = getSandboxOptions():getOptionByName("WaterShutModifier"):getValue() > -1


-- -- Функция для переключения состояния
-- local function toggle(optionName, turnOn)
--     local options = SandboxOptions.new()
--     options:copyValuesFrom(getSandboxOptions())
--     options:getOptionByName(optionName):setValue(turnOn and 2147483647 or -1)
--     getSandboxOptions():copyValuesFrom(options)
--     getSandboxOptions():toLua()
-- end


-- -- Интервалы
-- -- local intervalEnableWater = SandboxVars.DinamicEvents.Water_on
-- -- local intervalDisableWater = SandboxVars.DinamicEvents.Water_off
-- -- local intervalEnablePower = SandboxVars.DinamicEvents.Power_on
-- -- local intervalDisablePower = SandboxVars.DinamicEvents.Power_off


-- local function checkState()
--     print("GameTime:", getGameTime():getWorldAgeHours()) --3877.83447265625
-- end

-- Events.EveryTenMinutes.Add(checkState)
-- -- Использование:  
-- -- toggle("ElecShutModifier", false) -- выключить электричество
-- -- toggle("WaterShutModifier", true)  -- включить воду

-- Только сервер
if not isServer() then return end

-- ================== КОНФИГ ==================
local CFG = {
    -- Сколько недель минимум между событиями (гарантированная редкость)
    minWeeksBetween = 2, --3
    -- Доп. шанс запланировать событие на этой неделе (после проверки редкости)
    weeklyChance    = 0.35,    -- 35% (можешь снизить до 0.2–0.25)
    -- Вероятность затронуть сразу и воду, и электричество
    pickBothChance  = 0.10,
    -- Режимы: "restore_on" (временно включить), "blackout" (временно отключить)
    modePower = "restore_on",
    modeWater = "restore_on",
    -- Диапазоны длительностей (часы внутриигровые)
    durPowerHours = {min=12, max=36},
    durWaterHours = {min=12, max=48},
    -- Защитный зазор до конца недели (часы)
    startGuardHours = 6,
    -- Цвет уведомления
    notifyColor = {255,215,0},
    testForceNow = false, 
}

-- ================== КОНСТ / ХЭЛПЕРЫ ==================
local MDKEY = "WPDynamicPlan"
local WEEK_H = 24*7

local OPT = {
    power = "ElecShutModifier",
    water = "WaterShutModifier",
}

local function md() return ModData.getOrCreate(MDKEY) end
local function worldH() return GameTime:getInstance():getWorldAgeHours() end
local function weekIndex() return math.floor(worldH() / WEEK_H) end

local function isOn(which)
    local opt = getSandboxOptions():getOptionByName(OPT[which])
    return opt and (opt:getValue() > -1) or false
end

local function setState(which, turnOn)
    local options = SandboxOptions.new()
    options:copyValuesFrom(getSandboxOptions())
    local v = turnOn and 2147483647 or -1
    local opt = options:getOptionByName(OPT[which])
    if opt then opt:setValue(v) end
    getSandboxOptions():copyValuesFrom(options)
    getSandboxOptions():toLua()
end

local function notify(msg)
    if Notify and Notify.broadcast then
        Notify.broadcast(msg, { color = CFG.notifyColor })
    end
end

local function randInt(minI, maxI) -- [min,max], с ванильным RNG
    return ZombRand(minI, maxI + 1)
end

-- ================== ПЛАНИРОВАНИЕ НЕДЕЛИ ==================
local function makeEmptyPlan(w)
    return { week=w, start=nil, power=nil, water=nil }
end

local function planThisWeekAllowed(w)
    local d = md()
    local last = d.lastEventWeek or -9999
    if w - last < CFG.minWeeksBetween then return false end
    return (ZombRand(1000000)/1000000.0) < CFG.weeklyChance
end

local function buildWeekPlan(w)
    local plan = makeEmptyPlan(w)
    if not planThisWeekAllowed(w) then return plan end

    local both = (ZombRand(1000000)/1000000.0) < CFG.pickBothChance
    local wantPower, wantWater
    if both then
        wantPower, wantWater = true, true
    else
        wantPower = (ZombRand(2) == 0)
        wantWater = not wantPower
    end

    local maxDur = 0
    if wantPower then
        local durP = randInt(CFG.durPowerHours.min, CFG.durPowerHours.max)
        plan.power = { dur=durP, mode=CFG.modePower, active=false, prevOn=nil }
        maxDur = math.max(maxDur, durP)
    end
    if wantWater then
        local durW = randInt(CFG.durWaterHours.min, CFG.durWaterHours.max)
        plan.water = { dur=durW, mode=CFG.modeWater, active=false, prevOn=nil }
        maxDur = math.max(maxDur, durW)
    end

    if maxDur > 0 then
        local latestStart = math.max(0, WEEK_H - maxDur - CFG.startGuardHours)
        plan.start = randInt(0, latestStart)
        -- фиксируем неделю с событием (для minWeeksBetween)
        local d = md(); d.lastEventWeek = w; ModData.transmit(MDKEY)
    end
    return plan
end

local function ensurePlan()
    local d = md()
    local w = weekIndex()
    if not d.plan or d.plan.week ~= w then
        d.plan = buildWeekPlan(w)
        ModData.transmit(MDKEY)
    end
    -- print("[WPDynamic] plan:", tostring(md().plan and md().plan.start), "week", weekIndex())
    return d.plan
end

-- ================== РАНТАЙМ ==================
local function inWindow(nowInWeek, startH, durH)
    return startH and durH and nowInWeek >= startH and nowInWeek < (startH + durH)
end

local function enterWindow(which, slot)
    -- Запоминаем прежнее состояние
    slot.prevOn = isOn(which)
    -- Применяем режим (только если реально меняется)
    if slot.mode == "restore_on" then
        if not slot.prevOn then
            setState(which, true)
            notify(which=="power" and "IGUI_WPDynamic_Power_On"
                                 or  "IGUI_WPDynamic_Water_On")
        end
    else -- blackout
        if slot.prevOn then
            setState(which, false)
            notify(which=="power" and "IGUI_WPDynamic_Power_Off"
                                 or  "IGUI_WPDynamic_Water_Off")
        end
    end
    slot.active = true
    ModData.transmit(MDKEY)
end

local function exitWindow(which, slot)
    if slot.prevOn ~= nil then
        local target = slot.prevOn
        if isOn(which) ~= target then
            setState(which, target)
            if slot.mode == "restore_on" then
                notify(which=="power" and "IGUI_WPDynamic_Power_Off1"
                                     or  "IGUI_WPDynamic_Water_Off1")
            else
                notify(which=="power" and "IGUI_WPDynamic_Power_On1"
                                     or  "IGUI_WPDynamic_Water_On1")
            end
        end
    end
    slot.active, slot.prevOn = false, nil
    ModData.transmit(MDKEY)
end

local function forcePlanNowIfTest()
    if not CFG.testForceNow then return end
    local d = md()
    local w = weekIndex()
    local nowInWeek = worldH() - w * WEEK_H

    d.plan = {
        week  = w,
        start = nowInWeek + 0.01,  -- начнётся практически сразу (на следующем тике)
        power = { dur = randInt(1,2), mode = CFG.modePower, active=false, prevOn=nil },
        water = { dur = randInt(1,2), mode = CFG.modeWater, active=false, prevOn=nil },
    }
    d.lastEventWeek = w
    ModData.transmit(MDKEY)
end


local function tick()
    local plan = ensurePlan()
    local wH = worldH()
    local nowInWeek = wH - plan.week * WEEK_H

    -- POWER
    if plan.power then
        local shouldActive = inWindow(nowInWeek, plan.start, plan.power.dur)
        if shouldActive and (not plan.power.active) then
            enterWindow("power", plan.power)
        elseif (not shouldActive) and plan.power.active then
            exitWindow("power", plan.power)
        end
    end

    -- WATER
    if plan.water then
        local shouldActive = inWindow(nowInWeek, plan.start, plan.water.dur)
        if shouldActive and (not plan.water.active) then
            enterWindow("water", plan.water)
        elseif (not shouldActive) and plan.water.active then
            exitWindow("water", plan.water)
        end
    end
end

Events.OnServerStarted.Add(function() 
    -- print("[WPDynamic] server file loaded")
    ensurePlan()
    -- forcePlanNowIfTest()
 end)
Events.EveryTenMinutes.Add(tick)
