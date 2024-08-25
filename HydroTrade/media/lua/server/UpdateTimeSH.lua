local function UpdateTime(owner) --Обновление времени владения убежища по владельцу (сброс времени посещения до текущего)
    local currentTime = getTimeInMillis()
    for i=0,SafeHouse.getSafehouseList():size()-1 do
        local sh = SafeHouse.getSafehouseList():get(i);
        if sh:getOwner() == owner then
        sh:setLastVisited(currentTime)
        sh:syncSafehouse()
        end
    end
end

local function IsDateValid(expirationDate)
    if expirationDate == nil or expirationDate == "" then return true end -- Если даты нет, то продлеваем бесконечно
    local day, month, year = expirationDate:match("^(%d%d)%.(%d%d)%.(%d%d%d%d)$")
    if day and month and year then
        local currentDay = os.time{
            year = tonumber(os.date("%Y")),
            month = tonumber(os.date("%m")),
            day = tonumber(os.date("%d"))
        }
        local targetDay = os.time{
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day)
        }
        return targetDay >= currentDay -- Проверка, истекла ли дата
    end
    return false -- Неверный формат даты, ничего не продлеваем
end

local function PlayerListForUpdate()
    local playerList = SandboxVars.SafeHouseClose.OwnerListForUpdate -- Список владельцев убежищ в формате string = "admin,player1=25.08.2024,player2"
    if playerList == nil or playerList == "" then return end
    for entry in string.gmatch(playerList, '([^,]+)') do
        local owner, expirationDate = entry:match("([^=]+)=?(.*)")
        if IsDateValid(expirationDate) then
            UpdateTime(owner)
        end
    end
end

Events.EveryDays.Add(PlayerListForUpdate)