--***********************************************************
--**                ALEKSANDR OPEKUNOV | ZUU               **
--***********************************************************

if isClient() then
    return
end

if not getT15KKillboardInstance then
    require('shared/T15KillboardUtils')
end

local T15KKillboard = getT15KKillboardInstance()

local pairs = pairs
local table = table

-- sort and clear killboard
local function prepareAndClearKillboard(dirtyTable, isSurvival)
    local maxPlayers = T15KKillboard.getSandboxVar("PlayersPerPage")
    local preparedTable = {}
    local slicedTable = {}
    local argPos = 1
    if isSurvival then
        argPos = 2
    end
    local counter = 0

    -- sorting
    for username, data in pairs(dirtyTable) do
        if #preparedTable > 0 then

            for i = 1, #preparedTable do
                if data[argPos] <= preparedTable[#preparedTable - i + 1][2] then
                    table.insert(preparedTable, #preparedTable - i + 2, { username, data[1], data[2], data[3] })
                    break
                end
                if i == #preparedTable then
                    table.insert(preparedTable, 1, { username, data[1], data[2], data[3] })
                end
            end
        else
            preparedTable[1] = { username, data[1], data[2], data[3] }
        end
        counter = counter + 1
    end

    -- slice table
    for i = 1, #preparedTable do
        if i > maxPlayers then
            preparedTable[i] = nil
        else
            slicedTable[preparedTable[i][1]] = { preparedTable[i][2], preparedTable[i][3], preparedTable[i][4] }
        end
    end

    -- slice table for save in modData
    -- prepared table for client UI
    return { ["slicedTable"] = slicedTable, ["preparedTable"] = preparedTable }
end

-- send prepared table for client and clear it
local function serverUpdateT15KRankTable()
    local dirtyKillboard = getGameTime():getModData().T15KKillboard -- getTable

    if dirtyKillboard ~= {} and dirtyKillboard ~= nil then
        local prepared = prepareAndClearKillboard(dirtyKillboard, nil)
        getGameTime():getModData().T15KKillboard = prepared.slicedTable -- save sliced table
        local ZombieRankClientTable = prepared.preparedTable

        if T15KKillboard.isSinglePlayer() then
            -- check is singleplayer
            triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "true", ZombieRankClientTable);
        else
            sendServerCommand("T15K_Rank_From_Server", "true", ZombieRankClientTable);
        end
    end
end

-- Add client data to modData
-- args[1] - player name
-- args[2] - zombie kills
-- args[3] - player kills
-- args[4] - timestamp
local function OnClientCommandT15KRank(module, command, player, args)
    if module ~= "T15KKillboardModule" then
        return
    end

    if command == "playerRemove" then
        local rankTable = getGameTime():getModData().T15KKillboard
        if rankTable == nil then
            return
        end

        getGameTime():getModData().T15KKillboard[args[1]] = nil
        serverUpdateT15KRankTable()
    elseif command == "clearKillboard" then
        getGameTime():getModData().T15KKillboard = {}
        serverUpdateT15KRankTable()
    else
        local rankTable = getGameTime():getModData().T15KKillboard
        if rankTable == nil then
            getGameTime():getModData().T15KKillboard = {}
        end

        getGameTime():getModData().T15KKillboard[args[1]] = { args[2], args[3], getTimestamp() }
    end
end

-- add client listener
Events.OnClientCommand.Add(OnClientCommandT15KRank)

-- send data to players
local serverUpdateTickRate = T15KKillboard.getSandboxVar("ServerTickRate")

if serverUpdateTickRate == 1 or T15KKillboard.isSinglePlayer() then
    Events.EveryTenMinutes.Add(serverUpdateT15KRankTable)
elseif serverUpdateTickRate == 2 then
    Events.EveryHours.Add(serverUpdateT15KRankTable)
else
    Events.EveryDays.Add(serverUpdateT15KRankTable)
end
