-- https://colorscheme.ru/html-colors.html
-- local function getRandomColor()
--     local colors = {
--         {0, 128, 255}, -- Голубой
--         {255, 0, 0}, -- Красный
--         {0, 255, 0}, -- Зелёный
--         {255, 255, 0}, -- Жёлтый
--         {255, 0, 255}, -- Пурпурный
--         {0, 255, 255} -- Бирюзовый
--         {255, 165, 0} -- Оранжевый
--         {128, 0, 128} -- Фиолетовый
--         {128, 128, 128} -- Серый
--         {128, 0, 0} -- Тёмно-красный
--         {128, 128, 0} -- Тёмно-жёлтый
--         {0, 128, 0} -- Тёмно-зелёный
--         {0, 0, 128} -- Тёмно-синий
--     }
--     return colors[ZombRand(1, #colors)]
-- end

local currentMessageIndex = 1

local function getTZoneMessage(messages)
    local md = ModData.getOrCreate("TZone")
    if not md then return messages end
    local titles = ""
    local first = true
    for title, data in pairs(md) do
        if data.enable then
            if not first then
                titles = titles .. ", "
            end
            titles = titles .. title
            first = false
        end
    end
    if titles == "" then return messages end
    table.insert(messages, { message = "IGUI_Notify_TZone_Active", color = {255, 0, 0}, params = { title = titles } })
    return messages
end

local function getNextMessage()
    local messages = {}
    
    -- Базовое сообщение всегда добавляется
    table.insert(messages, { message = "IGUI_Vote_For_Server", color = {0, 128, 255} }) -- Голубой
    table.insert(messages, { message = "IGUI_Notify_Garage", color = {255, 165, 0} }) -- Оранжевый
    table.insert(messages, { message = "IGUI_Dont_create_sh_in_town", color = {255, 165, 0} }) -- Оранжевый
    
    -- Условное сообщение добавляется только при выполнении условий
    if SandboxVars.AutoLoot.PriceAutoLoot == 0 and SandboxVars.AutoLoot.Buy then
        table.insert(messages, { message = "IGUI_Sale_AutoLoot", color = {0, 255, 0} })
    end
    
    messages = getTZoneMessage(messages)

    -- Получаем текущее сообщение и переходим к следующему
    local message = messages[currentMessageIndex]
    
    -- Переходим к следующему сообщению или возвращаемся к первому
    currentMessageIndex = currentMessageIndex + 1
    if currentMessageIndex > #messages then
        currentMessageIndex = 1
    end
    
    return message
end

Events.EveryHours.Add(function()
    if not SandboxVars.Notify.Enable then return end
    local hours = getGameTime():getHour()
    if hours % SandboxVars.Notify.Regular == 0 then
        local message = getNextMessage()
        local opts = { color = message.color }
        if message.params then
            opts.params = message.params
        end
        Notify.broadcast(message.message, opts)
    end
end)