--***********************************************************
--**                ALEKSANDR OPEKUNOV | ZUU               **
--***********************************************************

local T15KKillboard = {}
local pairs = pairs

T15KKillboard.ZombieRankClientTable = nil
T15KKillboard.RankingModal = {}

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
    local value = SandboxVars.T15KKillboardTable[name];

    if value ~= nil
    then
        --print(">>>>> getSandboxVar -- " .. name .. " = " .. value)
        return value
    else
        --print(">>>>> getSandboxVar -- " .. name .. " = NIL ")
    end

    return nil;
end

T15KKillboard.isSinglePlayer = function()
    return not isClient() and not isServer()
end

function getT15KKillboardInstance()
    return T15KKillboard
end
