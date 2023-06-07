
local onClientCommand = function(module, command, player, args)
    if isServer() then 
        if module == "AutoGate" then
            if command == "install" then
                AutoGate.Utils.InstallGate(args)
                sendServerCommand(module, command, args)
            end
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)