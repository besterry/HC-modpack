if not isServer() then return end
local function readfile()
    print("Read:")
    local files = getDirFiles("users/")
    if files then
        for _, fileName in ipairs(files) do
            print(fileName)
        end
    else
        print("Error: Unable to retrieve files in directory " .. relativePath)
    end
end

local commands = {}
commands.getPlayers = function(player, args)
    print("Command")
    --readfile()
    --sendServerCommand('AutoLoot', 'onGetPlayers', {})
end

local function autoloot_OnClientCommand(module, command, player, args)
    if module == "AdminAutoLoot" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(autoloot_OnClientCommand)