Notify = {}
Notify.lastMessage = {} -- храним 10 последних сообщений, удаляя старые

local function _sendToAll(args)
    local players = getOnlinePlayers()
    for i=0, players:size()-1 do
        sendServerCommand(players:get(i), "Notify", "chat", args)
    end
end

local function _sendHistoryTo(player)
    for i=1, #Notify.lastMessage do
        local m = Notify.lastMessage[i]
        if m then
            sendServerCommand(player, "Notify", "chat", { msg=tostring(m.msg or ""), color=m.color, channel=m.channel, params=m.params })
        end
    end
end

function Notify.broadcast(msg, opts)
    opts = opts or {}
    _sendToAll({ msg=tostring(msg), color=opts.color, channel=opts.channel, params=opts.params })
    if #Notify.lastMessage >= 10 then
        table.remove(Notify.lastMessage, 1)
    end
    table.insert(Notify.lastMessage, { msg=tostring(msg), color=opts.color, channel=opts.channel, params=opts.params })
end

function Notify.toPlayer(player, msg, opts)
    opts = opts or {}
    sendServerCommand(player, "Notify", "chat", { msg=tostring(msg), color=opts.color, channel=opts.channel, params=opts.params })
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
    elseif module == 'Notify' and command == 'history' then
        _sendHistoryTo(player)
    end
end)