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
        getTextWithPrefix = function()
            local size = (ISChat and ISChat.instance and ISChat.instance.chatFont) or "medium"
            return string.format("<SIZE:%s>%s", tostring(size), message)
        end,
        isServerAlert = function() return opts.serverAlert end,
        isShowAuthor = function() return opts.showAuthor end,
        getAuthor = function() return tostring(author or "SERVER") end,
        setShouldAttractZombies = function() return false end,
        setOverHeadSpeech = function() return false end,
    }

    ISChat.addLineInChat(msg, 0)
end

-- System chat tab support
local SystemChat = { 
    title = getText("UI_chat_system_tab") or "System", 
    id = 0 
}

local function getSystemTab()
    if not ISChat or not ISChat.instance or not ISChat.instance.tabs then return nil end
    for _, tab in ipairs(ISChat.instance.tabs) do
        if tab and tab.tabTitle == SystemChat.title then
            return tab
        end
    end
    return nil
end

local function __HydroTrade_InitSystemTabFix()
    local tab = getSystemTab()
    if not tab then return end
    if not tab.chatStreams or #tab.chatStreams == 0 then
        tab.streamID = 1
        local generalStream = (ISChat.allChatStreams and ISChat.allChatStreams[6]) or { name="general", command="/all ", tabID=1 }
        tab.chatStreams = { generalStream }
        tab.lastChatCommand = generalStream.command
    end
    if Events and Events.OnTick and Events.OnTick.Remove then
        Events.OnTick.Remove(__HydroTrade_InitSystemTabFix)
    end
end

local function ensureSystemTab()
    if not ISChat or not ISChat.instance then return end
    if not getSystemTab() then
        triggerEvent("OnTabAdded", SystemChat.title, SystemChat.id)
        if Events and Events.OnTick and Events.OnTick.Add then
            Events.OnTick.Add(__HydroTrade_InitSystemTabFix)
        end
    end
end


local historyRequested = false
local function initializeNotifyClient()
    local player = getPlayer()
    if not player then return end
    ensureSystemTab()
    if not historyRequested then
        sendClientCommand("Notify", "history", {})
        historyRequested = true
    end
    Events.OnTick.Remove(initializeNotifyClient)
end
Events.OnTick.Add(initializeNotifyClient)

local function addLineToSystemChat(message, color, author, opts)
    if not ISChat or not ISChat.instance then
        return addLineToChat(message, color, author, opts)
    end
    ensureSystemTab()

    local systemTab = getSystemTab()
    if not systemTab then
        return addLineToChat(message, color, author, opts)
    end

    -- Blink tab if not active
    if ISChat and ISChat.instance and ISChat.instance.panel and systemTab.tabTitle then
        local activeTitle = ISChat.instance.chatText and ISChat.instance.chatText.tabTitle
        if activeTitle ~= systemTab.tabTitle then
            local alreadyExist = false
            for i,blinkedTab in ipairs(ISChat.instance.panel.blinkTabs) do
                if blinkedTab == systemTab.tabTitle then
                    alreadyExist = true
                    break
                end
            end
            if not alreadyExist then
                table.insert(ISChat.instance.panel.blinkTabs, systemTab.tabTitle)
            end
        end
    end

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
        getTextWithPrefix = function()
            local size = (ISChat and ISChat.instance and ISChat.instance.chatFont) or "medium"
            return string.format("<SIZE:%s>%s", tostring(size), message)
        end,
        isServerAlert = function() return opts.serverAlert end,
        isShowAuthor = function() return opts.showAuthor end,
        getAuthor = function() return tostring(author or "SERVER") end,
        setShouldAttractZombies = function() return false end,
        setOverHeadSpeech = function() return false end,
    }

    local chatText = systemTab
    local line = msg:getTextWithPrefix()
    if msg:isServerAlert() then
        ISChat.instance.servermsg = ""
        if msg:isShowAuthor() then
            ISChat.instance.servermsg = msg:getAuthor() .. ": "
        end
        ISChat.instance.servermsg = ISChat.instance.servermsg .. msg:getText()
        ISChat.instance.servermsgTimer = 5000
    end

    local vscroll = chatText.vscroll
    local scrolledToBottom = (chatText:getScrollHeight() <= chatText:getHeight()) or (vscroll and vscroll.pos == 1)
    if #chatText.chatTextLines > ISChat.maxLine then
        local newLines = {}
        for i,v in ipairs(chatText.chatTextLines) do
            if i ~= 1 then
                table.insert(newLines, v)
            end
        end
        table.insert(newLines, line .. " <LINE> ")
        chatText.chatTextLines = newLines
    else
        table.insert(chatText.chatTextLines, line .. " <LINE> ")
    end
    chatText.text = ""
    local newText = ""
    for i,v in ipairs(chatText.chatTextLines) do
        if i == #chatText.chatTextLines then
            v = string.gsub(v, " <LINE> $", "")
        end
        newText = newText .. v
    end
    chatText.text = newText
    table.insert(chatText.chatMessages, msg)
    chatText:paginate()
    if scrolledToBottom then
        chatText:setYScroll(-10000)
    end
end

Events.OnServerCommand.Add(function(module, command, args)
    if module == "Notify" and command == "chat" then
        args = args or {}
        local text = args.msg or ""
        
        -- Получаем базовый локализованный текст
        text = getText(text)
        
        -- Добавляем параметры, если они есть
        if args.params then
            for key, value in pairs(args.params) do
                if value and value ~= "" then
                    text = text .. " " .. tostring(value)
                end
            end
        end
        
        addLineToSystemChat(tostring(text or ""), args.color, args.author, { showTime=false })
    end
end)

function NotifySend(msg, opts, to)
    sendClientCommand("Notify", "request", { msg=tostring(msg), opts=opts or {}, to=to })
end