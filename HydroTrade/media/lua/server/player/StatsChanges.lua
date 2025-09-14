if isClient() then return end

local Commands = {}

Commands.setForUsername = function(sender, args)
    local username = tostring(args.username or "")
    if username == "" then return end

    local hours = args.hours
    local kills = args.kills
    local mode = args.mode
    local target = nil

    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local findPlayer = players:get(i)
        if findPlayer:getUsername() == username then
            target = findPlayer
            break
        end
    end
    if not target then
        writeLog("StatRestore", string.format("%s tried change stats for offline %s", sender:getUsername(), username))
        return
    end
    if hours ~= nil then
        sendServerCommand(target, "StatRestore", "setHoursSurvived", args)
        -- target:setHoursSurvived(val)
    end

    if kills ~= nil then
        sendServerCommand(target, "StatRestore", "setZombieKills", args)
        -- target:setZombieKills(val)
    end

    writeLog("StatRestore", string.format("%s applied (%s) to %s: hours=%s, kills=%s",
        sender:getUsername(), mode, username, tostring(hours), tostring(kills)))
end

local function OnClientCommand(module, command, player, args)
    if module ~= "StatRestore" then return end
    if Commands[command] then
        Commands[command](player, args or {})
    end
end

Events.OnClientCommand.Add(OnClientCommand)