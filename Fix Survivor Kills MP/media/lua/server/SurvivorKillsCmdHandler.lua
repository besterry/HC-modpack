--****************************************************************************************
--**                                  CHRISTIAN LEMOS                                   **
--**     Handles commands sent by clients to update survivor kills for the killer       **
--****************************************************************************************

if isClient() then return end

local function serverUpdateSurvivorKills(module, command, player, args)
    if module ~= "FixSurvivorKills" then return end

    if command == "ServerUpdateSurvivorKills" then
        local killer = getPlayerByOnlineID(args.killerOnlineID)
        sendServerCommand(killer, "FixSurvivorKills", "ClientUpdateSurvivorKills", {})
    end
end

Events.OnClientCommand.Add(serverUpdateSurvivorKills)