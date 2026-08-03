--***********************************************************
--**                ALEKSANDR OPEKUNOV | ZUU               **
--***********************************************************

local T15KKillboard = {}
local pairs = pairs

T15KKillboard.RankData = nil
T15KKillboard.ZombieRankClientTable = nil
T15KKillboard.PendingRewards = {}
T15KKillboard.RankingModal = {}

T15KKillboard.MODE_MONTHLY = "monthly"
T15KKillboard.MODE_ALLTIME = "allTime"

T15KKillboard.tableSize = function(t)
    local c = 0
    for _ in pairs(t) do
        c = c + 1
    end
    return c
end

T15KKillboard.timeDiffInString = function(time)
    local diff = getTimestamp() - time
    local string = getText("IGUI_T15KKillboard_Updated") .. " "
    if diff < 60 * 60 then
        return string .. getText("IGUI_T15KKillboard_Less_Hour")
    elseif diff >= 60 * 60 and diff < 60 * 60 * 24 then
        diff = math.floor(diff / (60 * 60))
        return string .. diff .. " " .. getText("IGUI_T15KKillboard_Hours")
    else
        diff = math.floor(diff / (60 * 60 * 24))
        return string .. diff .. " " .. getText("IGUI_T15KKillboard_Days")
    end
end

T15KKillboard.getSandboxVar = function(name)
    local value = SandboxVars.T15KKillboardTable[name]
    if value ~= nil then
        return value
    end
    return nil
end

T15KKillboard.isSinglePlayer = function()
    return not isClient() and not isServer()
end

T15KKillboard.getMonthKey = function(ts)
    ts = ts or getTimestamp()
    if os and os.date then
        return os.date("%Y-%m", ts)
    end
    return tostring(math.floor(ts / (60 * 60 * 24 * 30)))
end

-- unix ts конца месяца (00:00 1-го числа следующего), по переданному "сейчас"
T15KKillboard.getMonthEndTs = function(ts)
    ts = ts or getTimestamp()
    if not (os and os.date and os.time) then
        return nil
    end
    local y = tonumber(os.date("%Y", ts))
    local m = tonumber(os.date("%m", ts))
    if not y or not m then
        return nil
    end
    m = m + 1
    if m > 12 then
        m = 1
        y = y + 1
    end
    return os.time({ year = y, month = m, day = 1, hour = 0, min = 0, sec = 0 })
end

-- remaining по серверным serverNow/monthEndTs + локальному дрейфу с момента пакета
T15KKillboard.getSecondsToMonthEndFromRankData = function(rankData)
    if not rankData or not rankData.monthEndTs or not rankData.serverNow then
        return nil
    end
    local recv = rankData._clientRecvTs or getTimestamp()
    local elapsed = getTimestamp() - recv
    if elapsed < 0 then
        elapsed = 0
    end
    local serverGuess = rankData.serverNow + elapsed
    return math.max(0, rankData.monthEndTs - serverGuess)
end

T15KKillboard.formatRemaining = function(left)
    if left == nil then
        return getText("IGUI_T15KKillboard_Left_Days", "--")
    end
    if left < 60 * 60 then
        local mins = math.max(1, math.floor(left / 60))
        return getText("IGUI_T15KKillboard_Left_Minutes", tostring(mins))
    elseif left < 60 * 60 * 24 then
        return getText("IGUI_T15KKillboard_Left_Hours", tostring(math.floor(left / (60 * 60))))
    else
        return getText("IGUI_T15KKillboard_Left_Days", tostring(math.floor(left / (60 * 60 * 24))))
    end
end

T15KKillboard.getMonthRemainingText = function(rankData)
    local left = T15KKillboard.getSecondsToMonthEndFromRankData(rankData)
    return T15KKillboard.formatRemaining(left)
end

T15KKillboard.copyRewardConfig = function(src)
    local out = {}
    for i = 1, 3 do
        local conf = src and src[i]
        out[i] = {
            item = (conf and conf.item) or "",
            count = (conf and conf.count) or 1,
        }
    end
    return out
end

T15KKillboard.DEFAULT_REWARDS = {
    { item = "PM.Balance", count = 500 },
    { item = "PinkSlip.70barracuda", count = 1 },
    { item = "Base.HazmatSuit", count = 1 },
}

T15KKillboard.getRewardConfig = function()
    local cfg = {
        { item = T15KKillboard.getSandboxVar("Reward1Item") or "", count = T15KKillboard.getSandboxVar("Reward1Count") or 1 },
        { item = T15KKillboard.getSandboxVar("Reward2Item") or "", count = T15KKillboard.getSandboxVar("Reward2Count") or 1 },
        { item = T15KKillboard.getSandboxVar("Reward3Item") or "", count = T15KKillboard.getSandboxVar("Reward3Count") or 1 },
    }
    if not T15KKillboard.hasAnyReward(cfg) then
        return T15KKillboard.copyRewardConfig(T15KKillboard.DEFAULT_REWARDS)
    end
    return cfg
end

-- награды, подготовленные на следующий месяц
T15KKillboard.getNextRewardConfig = function()
    return {
        { item = T15KKillboard.getSandboxVar("NextReward1Item") or "", count = T15KKillboard.getSandboxVar("NextReward1Count") or 1 },
        { item = T15KKillboard.getSandboxVar("NextReward2Item") or "", count = T15KKillboard.getSandboxVar("NextReward2Count") or 1 },
        { item = T15KKillboard.getSandboxVar("NextReward3Item") or "", count = T15KKillboard.getSandboxVar("NextReward3Count") or 1 },
    }
end

T15KKillboard.hasAnyReward = function(cfg)
    if not cfg then
        return false
    end
    for i = 1, 3 do
        if cfg[i] and cfg[i].item and cfg[i].item ~= "" then
            return true
        end
    end
    return false
end

-- применить next → current в SandboxVars runtime (после фиксации выдачи)
T15KKillboard.applyNextRewardsToSandbox = function()
    local nextCfg = T15KKillboard.getNextRewardConfig()
    if not T15KKillboard.hasAnyReward(nextCfg) then
        return false
    end
    if not SandboxVars or not SandboxVars.T15KKillboardTable then
        return false
    end
    local t = SandboxVars.T15KKillboardTable
    t.Reward1Item = nextCfg[1].item or ""
    t.Reward1Count = nextCfg[1].count or 1
    t.Reward2Item = nextCfg[2].item or ""
    t.Reward2Count = nextCfg[2].count or 1
    t.Reward3Item = nextCfg[3].item or ""
    t.Reward3Count = nextCfg[3].count or 1
    -- next очищаем, чтобы случайно не применить дважды
    t.NextReward1Item = ""
    t.NextReward2Item = ""
    t.NextReward3Item = ""
    return true
end

T15KKillboard.REWARD_PM_BALANCE = "PM.Balance"

T15KKillboard.isPMBalanceReward = function(fullType)
    return fullType == T15KKillboard.REWARD_PM_BALANCE or fullType == "PlayerMenu.Balance"
end

T15KKillboard.formatRewardCountSuffix = function(count)
    count = count or 1
    if count > 1 then
        return " x" .. tostring(count)
    end
    return ""
end

T15KKillboard.getItemDisplayName = function(fullType)
    if not fullType or fullType == "" then
        return ""
    end
    if T15KKillboard.isPMBalanceReward(fullType) then
        return getText("IGUI_T15KKillboard_Reward_Balance")
    end
    if Translator and Translator.getItemNameFromFullType then
        local ok, name = pcall(function()
            return Translator.getItemNameFromFullType(fullType)
        end)
        if ok and name and name ~= "" and name ~= fullType then
            return name
        end
    end
    if getScriptManager then
        local scriptItem = getScriptManager():getItem(fullType)
        if scriptItem then
            if scriptItem.getDisplayName then
                local name = scriptItem:getDisplayName()
                if name and name ~= "" then
                    return name
                end
            end
        end
    end
    return fullType
end

T15KKillboard.formatRewardLine = function(fullType, count)
    if T15KKillboard.isPMBalanceReward(fullType) then
        return getText("IGUI_T15KKillboard_Reward_Balance_Amount", tostring(count or 0))
    end
    return T15KKillboard.getItemDisplayName(fullType) .. T15KKillboard.formatRewardCountSuffix(count)
end

T15KKillboard.createInvItem = function(fullType)
    if not fullType or fullType == "" or T15KKillboard.isPMBalanceReward(fullType) then
        return nil
    end
    if InventoryItemFactory and InventoryItemFactory.CreateItem then
        return InventoryItemFactory.CreateItem(fullType)
    end
    if instanceItem then
        return instanceItem(fullType)
    end
    return nil
end

T15KKillboard.getVehicleIdFromItem = function(fullType)
    if not fullType or fullType == "" or T15KKillboard.isPMBalanceReward(fullType) then
        return nil
    end
    local invItem = T15KKillboard.createInvItem(fullType)
    if invItem and invItem.getModData then
        local md = invItem:getModData()
        if md and md.VehicleID and md.VehicleID ~= "" then
            return md.VehicleID
        end
    end
    return nil
end

T15KKillboard.getItemTexture = function(fullType)
    if T15KKillboard.isPMBalanceReward(fullType) then
        if getTexture then
            return getTexture("media/textures/pm_money.png")
        end
        return nil
    end
    local invItem = T15KKillboard.createInvItem(fullType)
    if invItem and invItem.getTex then
        local tex = invItem:getTex()
        if tex then
            return tex
        end
    end
    if getScriptManager then
        local scriptItem = getScriptManager():getItem(fullType)
        if scriptItem then
            if scriptItem.getNormalTexture then
                return scriptItem:getNormalTexture()
            end
            if scriptItem.getIcon then
                local icon = scriptItem:getIcon()
                if icon and getTexture then
                    return getTexture("Item_" .. icon)
                end
            end
        end
    end
    return nil
end

function getT15KKillboardInstance()
    return T15KKillboard
end
