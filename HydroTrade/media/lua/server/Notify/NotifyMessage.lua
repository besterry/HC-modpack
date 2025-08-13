Events.EveryHours.Add(function()
    local hours = getGameTime():getHour() -- Текущий игровой час 00-23
    -- print(hours)
    if hours % 8 == 0 then -- Каждые 8 часов (0, 8, 16)
        Notify.broadcast("IGUI_Vote_For_Server", { color={0, 128, 255} }) --Голосование за сервер , Голубой цвет
    end
end)