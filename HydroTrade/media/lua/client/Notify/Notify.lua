--[[
    NOTE: 
    Отправка всем с клиента
    NotifySend("[Notify] ...", { color={255,215,0} })

    Всем (сервер):
    NotifySend("[Notify] ...", { color={255,215,0} })

    Только себе (клиент):
    NotifySend("[Notify] ...", { color={255,215,0} }, "self")

    Конкретному игроку (сервер):
    NotifySend("[Notify] ...", { color={255,215,0} }, "self")
]]--

local function rgbTag(c)
    if type(c) == "table" then
        return string.format("<RGB:%d,%d,%d>", c[1] or c.r or 255, c[2] or c.g or 255, c[3] or c.b or 255)
    elseif type(c) == "string" then
        -- если присылаешь строку типа "Gold" – можно маппить в RGB по таблице, но проще передавать {r,g,b}
        return "<RGB:255,255,255>"
    end
    return "<RGB:255,255,255>"
end

local function addLineToChat(message, color, author, opts)
    if not ISChat or not ISChat.instance or not ISChat.instance.chatText then return end

    color = rgbTag(color)
    opts = opts or { showTime=false, serverAlert=false, showAuthor=false }

    if opts.showTime then
        local date = Calendar.getInstance():getTime()
        local fmt = SimpleDateFormat.new("H:mm")
        if date and fmt then
            message = string.format("%s[%s]  %s", color, tostring(fmt:format(date) or "N/A"), message)
        end
    else
        message = color .. message
    end

    local msg = {
        getText = function() return message end,
        getTextWithPrefix = function() return message end,
        isServerAlert = function() return opts.serverAlert end,
        isShowAuthor = function() return opts.showAuthor end,
        getAuthor = function() return tostring(author or "SERVER") end,
        setShouldAttractZombies = function() return false end,
        setOverHeadSpeech = function() return false end,
    }

    ISChat.addLineInChat(msg, 0)
end

Events.OnServerCommand.Add(function(module, command, args)
    if module == "Notify" and command == "chat" then
        args = args or {}
        addLineToChat(tostring(args.msg or ""), args.color, args.author, { showTime=false })
    end
end)

function NotifySend(msg, opts, to)
    sendClientCommand("Notify", "request", { msg=tostring(msg), opts=opts or {}, to=to })
end