-- https://colorscheme.ru/html-colors.html
-- local function getRandomColor()
--     local colors = {
--         {0, 128, 255}, -- Голубой
--         {255, 0, 0}, -- Красный
--         {0, 255, 0}, -- Зелёный
--         {255, 255, 0}, -- Жёлтый
--         {255, 0, 255}, -- Пурпурный
--         {0, 255, 255} -- Бирюзовый
--     }
--     return colors[ZombRand(1, #colors)]
-- end

local currentMessageIndex = 1

local function getNextMessage()
    local messages = {}
    
    -- Базовое сообщение всегда добавляется
    table.insert(messages, { message = "IGUI_Vote_For_Server", color = {0, 128, 255} })
    
    -- Условное сообщение добавляется только при выполнении условий
    if SandboxVars.AutoLoot.PriceAutoLoot == 0 and SandboxVars.AutoLoot.Buy then
        table.insert(messages, { message = "IGUI_Sale_AutoLoot", color = {0, 255, 0} })
    end
    
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
        Notify.broadcast(message.message, { color=message.color })
    end
end)