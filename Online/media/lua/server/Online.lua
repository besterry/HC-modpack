local function SavePlayersCount(players,playersListString)
    local fileWriterObj = getFileWriter("Online/players_online.txt", true, false);
    fileWriterObj:write(tostring(players));
    fileWriterObj:close();
    local fileWriterObj2 = getFileWriter("Online/players.txt", true, false);
    fileWriterObj2:write(tostring(playersListString));
    fileWriterObj2:close();
end

---@return getOnlinePlayers ArrayList
---@type getOnlinePlayers userdata
local function PlayersOnline()
    local players = getOnlinePlayers():size()  
    local maxPlayersOption = getServerOptions():getOptionByName("MaxPlayers"):getValue()
    local result = players .. "/" .. maxPlayersOption
    --Получение списка имен и формирование строки
    local onlinePlayers = getOnlinePlayers()
    local playersCount = onlinePlayers:size()
    local playerNames = {}
    for i = 0, playersCount - 1 do
        local player = onlinePlayers:get(i)
        local playerName = player:getUsername()
        table.insert(playerNames, playerName)
    end
    local playersListString = table.concat(playerNames, "\n")
    SavePlayersCount(result,playersListString)
end

---@diagnostic disable-next-line: param-type-mismatch
Events.EveryTenMinutes.Add(PlayersOnline)