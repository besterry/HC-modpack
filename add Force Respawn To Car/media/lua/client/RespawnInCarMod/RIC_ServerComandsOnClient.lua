-------------------------------------------------------------------------
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
-------------------------------------------------------------------------
-- SERVER COMMANDS
-------------------------------------------------------------------------
function RIC.OnServerCommand(module, command, args)
    if module ~= "RespawnINcar" then return end
    local handler = RIC[command]
    if type(handler) ~= "function" then
        print("[RIC] unknown server command: " .. tostring(command))
        return
    end
    local player = getPlayer()
    handler(player, args, command)
end
Events.OnServerCommand.Add(RIC.OnServerCommand)
-------------------------------------------------------------------------
return RIC