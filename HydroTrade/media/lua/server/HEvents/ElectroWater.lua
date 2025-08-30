-- -- if not isServer() then return end


-- -- -- Получаем текущее состояние
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

-- Интервалы
-- local intervalEnableWater = SandboxVars.DinamicEvents.Water_on
-- local intervalDisableWater = SandboxVars.DinamicEvents.Water_off
-- local intervalEnablePower = SandboxVars.DinamicEvents.Power_on
-- local intervalDisablePower = SandboxVars.DinamicEvents.Power_off

-- local function checkState()
--     print("GameTime:", getGameTime():getWorldAgeHours()) --3877.83447265625
-- end

-- Events.EveryTenMinutes.Add(checkState)
-- Использование:  
-- toggle("ElecShutModifier", false) -- выключить электричество
-- toggle("WaterShutModifier", true)  -- включить воду

-- Только сервер
if not isServer() then return end

-- ================== КОНФИГ ==================
local CFG = {
    -- Сколько недель минимум между событиями (гарантированная редкость)
    minWeeksBetween = 0, --3
    -- Доп. шанс запланировать событие на этой неделе (после проверки редкости)
    weeklyChance    = 0.35,    -- 35% (можешь снизить до 0.2–0.25)
    -- Вероятность затронуть сразу и воду, и электричество
    pickBothChance  = 0.25, -- 10%
    -- Режимы: "restore_on" (временно включить), "blackout" (временно отключить)
    modePower = "restore_on",
    modeWater = "restore_on",
    -- Диапазоны длительностей (часы внутриигровые)
    durPowerHours = {min=12, max=64},
    durWaterHours = {min=12, max=64},
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

local function md() return ModData.getOrCreate(MDKEY) end -- получаем или создаём ModData
local function worldH() return GameTime:getInstance():getWorldAgeHours() end -- получаем текущее время существования мира в часах
local function weekIndex() return math.floor(worldH() / WEEK_H) end -- получаем текущую игровую неделю 

local function isOn(which) -- проверяем, включено ли электричество или вода
    local opt = getSandboxOptions():getOptionByName(OPT[which]) -- получаем значение опции
    return opt and (opt:getValue() > -1) or false -- возвращаем true или false в зависимости от значения опции
end

-- local function setState(which, turnOn) -- включаем или выключаем электричество или воду
--     print("[WPDynamic DEBUG] setState - which:", OPT[which], "turnOn:", turnOn)
--     local options = SandboxOptions.new() -- создаем новые опции
--     options:copyValuesFrom(getSandboxOptions()) -- копируем значения из текущих опций
--     options:getOptionByName(OPT[which]):setValue(turnOn and 2147483647 or -1) -- устанавливаем значение опции
--     getSandboxOptions():copyValuesFrom(options) -- копируем значения из новых опций в текущие опции
--     getSandboxOptions():toLua() -- сохраняем опции в файл
-- end
local function setState(which, turnOn)
    local optionName = OPT[which]
    local options = SandboxOptions.new()
    options:copyValuesFrom(getSandboxOptions())

    local opt = options:getOptionByName(optionName)
    if not opt then return end

    local value = turnOn and 2147483647 or -1
    opt:setValue(value)
    -- применяем на сервере
    getSandboxOptions():copyValuesFrom(options)
    getSandboxOptions():toLua()

    -- МГНОВЕННЫЙ свет
    if which == "power" then
        if isServer() then getWorld():setHydroPowerOn(turnOn) end
    end

    -- шлём клиентам, чтобы обновили свой SandboxVars без релога
    if isServer() then
        sendServerCommand("WPDynamic", "ResyncSandbox", { which = which, value = value, power = (which=="power" and turnOn) or nil })
    end
end

local function notify(msg) -- уведомляем игроков
    writeLog("WPDynamic", msg)
    if Notify and Notify.broadcast then
        Notify.broadcast(msg, { color = CFG.notifyColor })
    end
end

local function randInt(minI, maxI) -- [min,max], с ванильным RNG (рандом)
    return ZombRand(minI, maxI + 1)
end

-- ================== ПЛАНИРОВАНИЕ НЕДЕЛИ ==================
local function makeEmptyPlan(w)
    return { week=w, power=nil, water=nil }
end

local function planThisWeekAllowed(w) -- проверяем, можно ли запланировать событие на этой неделе
    local d = md() -- получаем ModData
    local last = d.lastEventWeek or -9999 -- получаем последнюю неделю когда было событие
    if w - last < CFG.minWeeksBetween then return false end -- если прошло меньше недель, чем минимальное количество недель между событиями, то нельзя запланировать событие
    return (ZombRand(1000000)/1000000.0) < CFG.weeklyChance -- возвращаем true или false в зависимости от вероятности
end

local function buildWeekPlan(w) -- создаем план на неделю
    local plan = makeEmptyPlan(w) -- создаем пустой план для текущей недели
    if not planThisWeekAllowed(w) then return plan end -- если нельзя запланировать событие на этой неделе, то возвращаем пустой план для текущей недели

    local both = (ZombRand(1000000)/1000000.0) < CFG.pickBothChance -- случайно выбираем, будет ли включено и электричество и вода (одновременно)
    local wantPower, wantWater -- будет ли событие на воде и на электричестве
    if both then -- если оба события
        wantPower, wantWater = true, true
    else
        wantPower = (ZombRand(2) == 0) -- случайно выбираем, будет ли событие на воде или электричестве
        wantWater = not wantPower
    end

    if wantPower then -- если включено электричество
        local durP = randInt(CFG.durPowerHours.min, CFG.durPowerHours.max) -- случайно выбираем длительность события на электричестве
        local latestStartP = math.max(0, WEEK_H - durP - CFG.startGuardHours) -- случайно выбираем время начала события на электричестве
        plan.power = { 
            dur=durP, 
            mode=CFG.modePower, 
            active=false, 
            prevOn=nil,
            start=randInt(0, latestStartP)  -- Отдельное время для электричества
        }
    end
    
    if wantWater then -- если включено вода
        local durW = randInt(CFG.durWaterHours.min, CFG.durWaterHours.max) -- случайно выбираем длительность события на воде
        local latestStartW = math.max(0, WEEK_H - durW - CFG.startGuardHours) -- случайно выбираем время начала события на воде
        plan.water = { 
            dur=durW, 
            mode=CFG.modeWater, 
            active=false, 
            prevOn=nil,
            start=randInt(0, latestStartW)  -- Отдельное время для воды
        }
    end

    if wantPower or wantWater then
        local d = md(); d.lastEventWeek = w; ModData.transmit(MDKEY) -- сохраняем последнюю неделю когда было событие
    end
    return plan
end

local function ensurePlan() -- проверяем, есть ли план на неделю
    local d = md() -- получаем ModData
    local w = weekIndex() -- получаем текущую неделю
    -- print("[WPDynamic DEBUG] ensurePlan - current week:", w, "plan week:", d.plan and d.plan.week or "nil")
    if not d.plan or d.plan.week ~= w then -- если нет плана или план не на этой неделе
        -- print("[WPDynamic DEBUG] creating new plan for week:", w)
        d.plan = buildWeekPlan(w) -- строим план на неделю
        ModData.transmit(MDKEY)
    end
    -- print("[WPDynamic] plan:", tostring(md().plan and md().plan.start), "week", weekIndex())
    return d.plan
end

-- ================== РАНТАЙМ ==================
local function inWindow(nowInWeek, startH, durH) -- проверяем, находится ли в окне
    return startH and durH and nowInWeek >= startH and nowInWeek < (startH + durH)
end

local function enterWindow(which, slot) -- ВКЛЮЧЕНИЕ ЭЛЕКТРОСЕТИ/ВОДЫ
    -- print("[WPDynamic DEBUG] enterWindow - which:", which, "slot:", tostring(slot))
    slot.prevOn = isOn(which) -- Текущее состояние настройки
    -- print("[WPDynamic DEBUG] enterWindow - prevOn:", slot.prevOn)
    if slot.mode == "restore_on" then -- Всегда restore_on
        if not slot.prevOn then
            setState(which, true)
            notify(which=="power" and "IGUI_WPDynamic_Power_On"
                                 or  "IGUI_WPDynamic_Water_On")
        end
    else -- если режим blackout (отключение)
        if slot.prevOn then
            setState(which, false)
            notify(which=="power" and "IGUI_WPDynamic_Power_Off"
                                 or  "IGUI_WPDynamic_Water_Off")
        end
    end
    slot.active = true --Активность всегда true
    ModData.transmit(MDKEY)
end

local function exitWindow(which, slot) -- ВЫКЛЮЧЕНИЕ ЭЛЕКТРОСЕТИ/ВОДЫ
    -- print("[WPDynamic DEBUG] exitWindow")
    if slot.mode == "restore_on" then -- Всегда restore_on
        -- print("[WPDynamic DEBUG] exitWindow - which:", which, "slot:", tostring(slot))
        setState(which, false) -- Отключаем всегда
        notify(which=="power" and "IGUI_WPDynamic_Power_Off1"
                             or  "IGUI_WPDynamic_Water_Off1")
    else
        -- Если это был blackout - восстанавливаем предыдущее состояние
        if slot.prevOn ~= nil then
            local target = slot.prevOn
            if isOn(which) ~= target then
                setState(which, target)
                notify(which=="power" and "IGUI_WPDynamic_Power_On1"
                                     or  "IGUI_WPDynamic_Water_On1")
            end
        end
    end
    
    slot.active, slot.prevOn = false, nil
    ModData.transmit(MDKEY)
end

local function forcePlanNowIfTest() -- принудительно запускаем план на текущую неделю
    if not CFG.testForceNow then return end
    local d = md()
    local w = weekIndex()
    local nowInWeek = worldH() - w * WEEK_H

    d.plan = {
        week = w,
        power = { 
            dur = 2, 
            mode = CFG.modePower, -- Всегда restore_on
            active=false, 
            prevOn=nil,
            start = nowInWeek + 0.01  -- Добавляем start для power
        },
        water = { 
            dur = 3, --randInt(2,3)
            mode = CFG.modeWater,  -- Всегда restore_on
            active=false, 
            prevOn=nil,
            start = nowInWeek + 0.01  -- Добавляем start для water
        },
    }
    d.lastEventWeek = w
    ModData.transmit(MDKEY)
end


local function tick() -- тик (каждые 10 минут)
    -- print("[WPDynamic DEBUG] tick() called")
    local plan = ensurePlan() -- получаем план на неделю
    local wH = worldH() -- получаем текущее время существования мира в часах
    local nowInWeek = wH - plan.week * WEEK_H -- получаем текущее время в неделе
    -- print("[WPDynamic DEBUG] tick - nowInWeek:", nowInWeek, "plan.power.active:", plan.power and plan.power.active, "plan.water.active:", plan.water and plan.water.active)

    -- сохраняем текущее время в неделе
    local d = md()
    d.currentHourInWeek = nowInWeek
    ModData.transmit(MDKEY)

    -- ОТЛАДКА: общая информация
    -- print("[WPDynamic DEBUG] worldH:", wH, "week:", plan.week, "nowInWeek:", nowInWeek)

    -- POWER - используем plan.power.start
    if plan.power then
        local shouldActive = inWindow(nowInWeek, plan.power.start, plan.power.dur) -- Проверяем, находится ли в окне
        -- print("[WPDynamic DEBUG] POWER - start:", plan.power.start, "dur:", plan.power.dur, "active:", plan.power.active, "shouldActive:", shouldActive)
        
        if shouldActive and (not plan.power.active) then -- Если событие на электричестве и не активно
            -- print("[WPDynamic DEBUG] POWER - entering window")
            enterWindow("power", plan.power)
        elseif (not shouldActive) and plan.power.active then -- Если событие на электричестве и активно
            -- print("[WPDynamic DEBUG] POWER - exiting window")
            exitWindow("power", plan.power)
        end
    end

    -- WATER - используем plan.water.start
    if plan.water then
        local shouldActive = inWindow(nowInWeek, plan.water.start, plan.water.dur)
        -- print("[WPDynamic DEBUG] WATER - start:", plan.water.start, "dur:", plan.water.dur, "active:", plan.water.active, "shouldActive:", shouldActive)
        
        if shouldActive and (not plan.water.active) then
            -- print("[WPDynamic DEBUG] WATER - entering window")
            enterWindow("water", plan.water)
        elseif (not shouldActive) and plan.water.active then
            -- print("[WPDynamic DEBUG] WATER - exiting window")
            exitWindow("water", plan.water)
        end
    end
end

Events.OnServerStarted.Add(function() 
    print("[WPDynamic] loaded")
    ensurePlan() -- получаем план на неделю
    -- forcePlanNowIfTest()
 end)
Events.EveryTenMinutes.Add(tick)