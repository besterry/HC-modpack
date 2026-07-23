--[[
    Tracks active combat injectors for HUD moodles.
    remaining / total use the same "duration units" as TickInflictions (~1s at 60 UPS).
]]

HT_InjectorStatus = HT_InjectorStatus or {}

-- Moodle level floor (last N seconds always lvl1). Shake is separate and shorter.
local CRITICAL_SECONDS = 40
local SHAKE_SECONDS = 5

local SHORT_LABELS = {
    adrenaline = "ADR",
    ahf1 = "AHF1",
    btg2a2 = "2A2",
    btg3 = "BTG3",
    etg = "eTG",
    meldonin = "MELD",
    morphine = "MOR",
    mule = "MULE",
    norepinephrine = "L1",
    obdolbos = "OBD",
    obdolbos2 = "OBD2",
    p22 = "P22",
    perfotoran = "PERF",
    pnb = "PNB",
    propital = "PROP",
    sj1 = "SJ1",
    sj6 = "SJ6",
    sj9 = "SJ9",
    sj12 = "SJ12",
    trimadol = "TRIM",
    xtg = "xTG",
    zagustin = "ZAG",
}

-- Side-effect funcs: never used as "useful buff window"
local SKIP_FUNCS = {
    AlterHunger = true,
    AlterThirst = true,
    Tremor = true,
    AddPain = true,
    AlterCold = true,
    MultiplyLimbDamage = true,
}

local function funcName(func)
    if type(func) == "string" then
        return func
    end
    if type(func) ~= "function" then
        return nil
    end
    for key, value in pairs(_G) do
        if value == func and type(value) == "function" then
            return key
        end
    end
    return nil
end

--- Useful buff window from InjectorSettings table.
function HT_InjectorStatus.CalcUsefulDuration(settings)
    if not settings then
        return 60
    end

    local maxEnd = 0
    local weightCapEnd = 0

    for _, inf in pairs(settings) do
        if type(inf) == "table" and inf.func then
            local name = funcName(inf.func)
            local delay = tonumber(inf.delay) or 0
            local duration = tonumber(inf.duration) or 0
            local args = inf.args or {}

            if name == "AlterSkill" then
                local skillDur = tonumber(args[2]) or 0
                local receive = args[3]
                if receive and skillDur > 0 then
                    maxEnd = math.max(maxEnd, delay + skillDur)
                end
            elseif name == "AlterWeightCap" then
                local delta = tonumber(args[1]) or 0
                if delta < 0 then
                    -- revert tick = end of carry buff
                    weightCapEnd = math.max(weightCapEnd, delay)
                elseif delta > 0 then
                    maxEnd = math.max(maxEnd, delay + duration)
                end
            elseif name and not SKIP_FUNCS[name] then
                local amount = tonumber(args[1])
                local include = true
                if name == "AlterHealth" or name == "AlterLimbHealth" or name == "AlterCalories" or name == "AlterEndurance" then
                    include = amount ~= nil and amount > 0
                elseif name == "AlterStress" then
                    -- negative stress change = relief
                    include = amount ~= nil and amount < 0
                end
                if include then
                    maxEnd = math.max(maxEnd, delay + duration)
                end
            end
        end
    end

    maxEnd = math.max(maxEnd, weightCapEnd)
    if maxEnd < 1 then
        maxEnd = 60
    end
    return maxEnd
end

function HT_InjectorStatus.Register(player, injectorId, settings, overrideTotal)
    if not player or not injectorId then
        return
    end
    local modData = player:getModData()
    local active = modData.activeInjectors
    if not active then
        active = {}
        modData.activeInjectors = active
    end

    local total = overrideTotal or HT_InjectorStatus.CalcUsefulDuration(settings)
    if total < 1 then
        total = 60
    end

    active[injectorId] = {
        id = injectorId,
        short = SHORT_LABELS[injectorId] or string.upper(tostring(injectorId)):sub(1, 5),
        total = total,
        remaining = total,
        icon = "Item_" .. injectorId,
        fullType = "injectorItems.injector_" .. injectorId,
        tooltipKey = "Tooltip_" .. injectorId,
    }
end

function HT_InjectorStatus.GetActive(player)
    if not player then
        return {}
    end
    local active = player:getModData().activeInjectors
    if not active then
        return {}
    end
    local list = {}
    for id, entry in pairs(active) do
        if entry and (entry.remaining or 0) > 0 then
            list[#list + 1] = entry
        else
            active[id] = nil
        end
    end
    table.sort(list, function(a, b)
        return (a.remaining or 0) > (b.remaining or 0)
    end)
    return list
end

function HT_InjectorStatus.CountActive(player)
    return #HT_InjectorStatus.GetActive(player)
end

--- Moodle level 1..4 from remaining time (relative % + critical floor).
function HT_InjectorStatus.GetLevel(entry)
    if not entry then
        return 0
    end
    local remaining = entry.remaining or 0
    if remaining <= 0 then
        return 0
    end
    if remaining <= CRITICAL_SECONDS then
        return 1
    end
    local total = entry.total or remaining
    if total < 1 then
        total = remaining
    end
    local ratio = remaining / total
    if ratio > 0.75 then
        return 4
    end
    if ratio > 0.50 then
        return 3
    end
    if ratio > 0.25 then
        return 2
    end
    return 1
end

function HT_InjectorStatus.ShouldShake(entry)
    return entry and (entry.remaining or 0) > 0 and (entry.remaining or 0) <= SHAKE_SECONDS
end

function HT_InjectorStatus.GetShortLabel(entry)
    if not entry then
        return "?"
    end
    if entry.short and entry.short ~= "" then
        return entry.short
    end
    local id = entry.id
    return SHORT_LABELS[id] or string.upper(tostring(id or "?")):sub(1, 5)
end

function HT_InjectorStatus.FormatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    if m > 0 then
        return string.format("%d:%02d", m, s)
    end
    return string.format("0:%02d", s)
end

--- Decrement all active injector timers once per ~second (60 OnPlayerUpdate).
function HT_InjectorStatus.Tick(player)
    if not player then
        return
    end
    local active = player:getModData().activeInjectors
    if not active then
        return
    end
    for id, entry in pairs(active) do
        if entry then
            entry.remaining = (entry.remaining or 0) - 1
            if entry.remaining <= 0 then
                active[id] = nil
            end
        end
    end
end
