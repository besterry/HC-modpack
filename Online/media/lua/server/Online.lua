function SavePlayersCount(players)
    local fileWriterObj = getFileWriter("Online/players_online.txt", true, false);
    fileWriterObj:write(tostring(players));
    fileWriterObj:close();
end

---@return getOnlinePlayers ArrayList
---@type getOnlinePlayers userdata
local function PlayersOnline()
    local players = getOnlinePlayers():size()  
    local maxPlayersOption = getServerOptions():getOptionByName("MaxPlayers"):getValue()
    local result = players .. "/" .. maxPlayersOption
    SavePlayersCount(result)
end

Events.EveryTenMinutes.Add(PlayersOnline)