if isClient() then return end
local Rmove = function(module, command, player, args)
    if module == 'vehicle' and command == "rmove" then
        triggerEvent("OnClientCommand", module, "remove", player, args)
    end
end
Events.OnClientCommand.Add(Rmove)
