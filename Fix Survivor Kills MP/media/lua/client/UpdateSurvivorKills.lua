--*********************************************************************************
--**                                  CHRISTIAN LEMOS                            **
--**     Checks if the player was killed by another and alerts the server.       **
--*********************************************************************************

local function clientUpdateSurvivorKills(module, command, args)
    if module ~= "FixSurvivorKills" then return end

    if command == "ClientUpdateSurvivorKills" then
        local thisPlayer = getPlayer();
        thisPlayer:setSurvivorKills(thisPlayer:getSurvivorKills() + 1);
    end
end

local function updateSurvivorKills(player)
    if not player:isLocalPlayer() then return end
    
    local killer = player:getAttackedBy()
    
    if killer:isZombie() then return end
    
    -- print("updateSurvivorKills: " .. player:getUsername() .. " was KILLED by " .. killer:getUsername())
    sendClientCommand(getPlayer(), "FixSurvivorKills", "ServerUpdateSurvivorKills", {killerOnlineID = killer:getOnlineID()})
end

Events.OnServerCommand.Add(clientUpdateSurvivorKills)
Events.OnPlayerDeath.Add(updateSurvivorKills)