AutoMeh = AutoMeh or {}

function AutoMeh.CheckZoneRegistration()
    local xcar1, xcar2, ycar1, ycar2
    local result = {}
    local sandboxCoord = "1/2/3/4" --Если не смогли получить
    if SandboxVars.NPC.AutomehRegistrationZone then
        sandboxCoord = SandboxVars.NPC.AutomehRegistrationZone
    end
    for match in (sandboxCoord.."/"):gmatch("(.-)".."/") do
        table.insert(result, match)
    end
    xcar1, xcar2, ycar1, ycar2 = tonumber(result[1]), tonumber(result[2]), tonumber(result[3]), tonumber(result[4])
    return xcar1, xcar2, ycar1, ycar2
end

function AutoMeh.CheckZone(zone)
    local xcar1, xcar2, ycar1, ycar2
    local result = {}
    local sandboxCoord = "1/2/3/4" --Если не смогли получить

    -- print("zone:",zone)
    if zone=="register" and SandboxVars.NPC.AutomehRegistrationZone then
        sandboxCoord = SandboxVars.NPC.AutomehRegistrationZone
        -- print("1:",sandboxCoord)
    elseif zone=="repair" and SandboxVars.NPC.AutomehRepairZone then
        sandboxCoord = SandboxVars.NPC.AutomehRepairZone
        -- print("2:",sandboxCoord)
    elseif zone=="blackmarketauto" and SandboxVars.NPC.BlackmarketAutoZone then
        sandboxCoord = SandboxVars.NPC.BlackmarketAutoZone
    end
    for match in (sandboxCoord.."/"):gmatch("(.-)".."/") do
        table.insert(result, match)
    end
    xcar1, xcar2, ycar1, ycar2 = tonumber(result[1]), tonumber(result[2]), tonumber(result[3]), tonumber(result[4])
    -- print(xcar1,",", xcar2,",", ycar1,",", ycar2)
    return xcar1, xcar2, ycar1, ycar2
end

function AutoMeh.CheckCarZone(x1,x2,y1,y2,govsing) --Функция для получения авто из зоны по координатам и гос.номеру
    local cell = getCell()
    local breakFlag = false
    if not govsing then govsing = 0 end
    local Findvehicle
    -- print(x1,",",x2,",",y1,",",y2)
    for x = x1, x2 do
        for y = y1, y2 do
            local sq = cell:getGridSquare(x, y, 0) --Получеаем Square 1 этажа для поиска авто
            if sq then
                local vehicle = sq:getVehicleContainer()
                if vehicle and vehicle:getModData().sqlId and vehicle:getModData().sqlId  == govsing then
                    Findvehicle = vehicle
                    -- print(Findvehicle)
                    breakFlag = true -- Устанавливаем флаг для прерывания внешнего цикла
                    break --Перерываем внтуренний цикл for (y1,y2)
                end
            end
        end
        if breakFlag then
            break -- Прерываем внешний цикл for (x1,x2)
        end
    end
    return Findvehicle
end

function AutoMeh.Pricing(part,condition,renew) --Рассчет цены починки детали
    local priceString = SandboxVars.NPC.Price
    local priceTable = {}
    -- Разбиваем строку на пары "деталь=цена"
    for pair in priceString:gmatch("([^;]+)") do
        local detail, price = pair:match("([^=]+)=([^=]+)")
        priceTable[detail] = tonumber(price)
    end
    local partid = part:getId()
    local repaircondition = condition-part:getCondition()
    local repairCount
    if partid ~= "Engine" and partid ~= "Heater" then
        repairCount = part:getInventoryItem():getHaveBeenRepaired()+1
    else
        repairCount = 2
    end
    local repairCost = priceTable[partid] or SandboxVars.NPC.DefaultPrice -- or 100, если цена не найдена
    if renew then 
        return (repairCost*100)*(SandboxVars.NPC.MaxRepairPart*SandboxVars.NPC.AutomehcoefPrice)
    else    
        return (repairCost*repaircondition)*(repairCount*SandboxVars.NPC.AutomehcoefPrice)
    end
end

function AutoMeh.CheckDistance(geoX,geoY) --Проверка дистанци от игрока до принимаемых координат
    local player = getPlayer()
    local dist = math.sqrt((geoX - player:getX())^2 + (geoY - player:getY())^2)
    if dist > SandboxVars.NPC.MaxDistanceUse then
        return true
    else
        return false
    end
end

function AutoMeh.BalancePlayer() --Получение баланса игрока
    local username = getPlayer():getUsername()
    local account = ModData.get("CoinBalance")[username]
    return account.coin
end

function AutoMeh.CheckZoneSpawnCar()--Проверка есть ли в зоне спавна ТС автомобили
    local coordinates = string.split(SandboxVars.NPC.ParkingPenaltyCoordinateSpawn, ",")
    local x,y = tonumber(coordinates[1]), tonumber(coordinates[2])
    for newX = x-2, x+2 do
        for newY = y-2, y+2 do
            local vehicle = getCell():getGridSquare(newX, newY, 0):getVehicleContainer()
            if vehicle then return true end
        end
    end
    return false
end