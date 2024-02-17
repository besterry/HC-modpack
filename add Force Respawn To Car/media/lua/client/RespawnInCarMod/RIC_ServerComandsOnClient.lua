-------------------------------------------------------------------------
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
-------------------------------------------------------------------------
-- SERVER COMMANDS
-------------------------------------------------------------------------
function RIC.OnServerCommand(module, command, args)
    if module ~= "RespawnINcar" then return end
    local player = getPlayer()
    RIC[command](player,args,command)
end
Events.OnServerCommand.Add(RIC.OnServerCommand)
-------------------------------------------------------------------------
return RIC