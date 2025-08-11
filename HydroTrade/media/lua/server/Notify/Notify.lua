
Notify = {}

local function _sendToAll(args)
    local players = getOnlinePlayers()
    for i=0, players:size()-1 do
        sendServerCommand(players:get(i), "Notify", "chat", args)
    end
end

function Notify.broadcast(msg, opts)
    opts = opts or {}
    _sendToAll({ msg=tostring(msg), color=opts.color, channel=opts.channel })
end

function Notify.toPlayer(player, msg, opts)
    opts = opts or {}
    sendServerCommand(player, "Notify", "chat", { msg=tostring(msg), color=opts.color, channel=opts.channel })
end

-- клиентский запрос → сервер рассылает
Events.OnClientCommand.Add(function(module, command, player, args)
    if module == 'Notify' and command == 'request' then
        args = args or {}
        local msg, opts = tostring(args.msg or ""), (args.opts or {})
        if args.to == "self" then
            Notify.toPlayer(player, msg, opts)
        else
            Notify.broadcast(msg, opts)
        end
    end
end)
