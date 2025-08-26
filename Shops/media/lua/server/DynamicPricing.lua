if not isServer() then return end

FD = FD or {}
FD.forSellItems = FD.forSellItems or {}
FD.shopItems = FD.shopItems or {}
DynamicPricing = DynamicPricing or {}

DynamicPricing.CONFIG = {
    DEFAULT_DECAY_RATE = 0.1,        -- Скорость снижения цены при частых продажах
    DEFAULT_MIN_MULTIPLIER = 0.3,    -- Минимальный множитель цены
    DEFAULT_MAX_MULTIPLIER = 1.2,    -- Максимальный множитель цены
    DEMAND_THRESHOLD = 10,           -- Порог продаж для начала снижения цены
    HOURLY_DECREASE = SandboxVars.Shops.HourlyDecrease,            -- На сколько снижать число продаж каждый час
}

function DynamicPricing.getCurrentGameHour() -- Функция для получения текущего игрового времени в часах
    local gameTime = getGameTime()
    if gameTime then  return gameTime:getWorldAgeHours() end
    return 0
end

function DynamicPricing.calculateDemandThreshold(defaultPrice) -- Вычисление индивидуального порога спроса на основе цены
    local baseThreshold = DynamicPricing.CONFIG.DEMAND_THRESHOLD -- Базовый порог спроса = 10
    local priceFactor = math.pow(1000 / (defaultPrice + 100), 1.2) -- Фактор цены = 1000 / (цена + 100)^1.2
    local threshold = math.floor(baseThreshold * priceFactor) -- Порог спроса = базовый порог * фактор цены
    threshold = math.max(3, math.min(100, threshold)) -- Ограничиваем порог диапазоном от 3 до 100 (по умолчанию)
    return threshold 
end

function DynamicPricing.initializeItem(itemName, itemData) -- Инициализация динамических полей для товара
    if not itemData or itemData.blacklisted then return end    
    if not itemData.defaultPrice then itemData.defaultPrice = itemData.price or 1 end    
    if not itemData.sellCount then itemData.sellCount = 0 end    
    if not itemData.lastSold then itemData.lastSold = 0 end
    if not itemData.priceMultiplier then itemData.priceMultiplier = 1.0 end
    if not itemData.demandLevel then itemData.demandLevel = 1.0 end
    if not itemData.minPrice then itemData.minPrice = math.max(1, math.floor(itemData.defaultPrice * DynamicPricing.CONFIG.DEFAULT_MIN_MULTIPLIER)) end
    if not itemData.maxPrice then itemData.maxPrice = math.floor(itemData.defaultPrice * DynamicPricing.CONFIG.DEFAULT_MAX_MULTIPLIER) end
    if not itemData.decayRate then itemData.decayRate = DynamicPricing.CONFIG.DEFAULT_DECAY_RATE end
    itemData.demandThreshold = DynamicPricing.calculateDemandThreshold(itemData.defaultPrice)
    DynamicPricing.updateItemPrice(itemName, itemData) -- Пересчитываем текущую цену
end

function DynamicPricing.onItemSold(itemName, quantity) -- Обновление цены товара при продаже
    if not SandboxVars.Shops.DinamicPrice then return end
    local itemData = FD.forSellItems[itemName]
    if not itemData then return end    
    if itemData.blacklisted then return end    
    DynamicPricing.initializeItem(itemName, itemData) -- Инициализируем если нужно    
    itemData.sellCount = itemData.sellCount + quantity -- Обновляем число продаж
    itemData.lastSold = DynamicPricing.getCurrentGameHour() -- Обновляем время последней продажи
    local demandFactor = itemData.sellCount / itemData.demandThreshold -- Используем индивидуальный порог товара    
    if demandFactor <= 1.0 then
        itemData.demandLevel = 1.0  -- Нормальный спрос до порога
    else
        itemData.demandLevel = math.max(DynamicPricing.CONFIG.DEFAULT_MIN_MULTIPLIER, 1.0 - (demandFactor - 1.0) * itemData.decayRate) -- Плавное снижение
    end
    local oldPrice = itemData.price
    DynamicPricing.updateItemPrice(itemName, itemData) -- Обновляем цену
    local msg = string.format(
        "DynamicPricing: %s sold x%d, demand: %.2f, price: %d->%d", 
        itemName, quantity, itemData.demandLevel, 
        oldPrice, itemData.price
    )
    writeLog("DynamicPricing", msg)
end

function DynamicPricing.updateItemPrice(itemName, itemData) -- Обновление цены товара
    if not itemData or itemData.blacklisted then return end
    local newPrice = math.floor(itemData.defaultPrice * itemData.demandLevel * itemData.priceMultiplier)
    newPrice = math.max(itemData.minPrice, math.min(itemData.maxPrice, newPrice)) -- Ограничиваем цену диапазоном
    itemData.price = newPrice -- Обновляем цену
    return newPrice
end

function DynamicPricing.recoverPrices() -- Восстановление цен каждый игровой час
    if not SandboxVars.Shops.DinamicPrice then return end
    local recoveredCount = 0
    for itemName, itemData in pairs(FD.forSellItems) do
        if not itemData.blacklisted and itemData.price and itemData.defaultPrice then
            local oldDemand = itemData.demandLevel -- Сохраняем текущий уровень спроса
            local oldSellCount = itemData.sellCount -- Сохраняем текущее число продаж
            if itemData.sellCount > 0 then
                local newSellCount = math.max(0, itemData.sellCount - DynamicPricing.CONFIG.HOURLY_DECREASE) -- Снижаем счетчик продаж на HOURLY_DECREASE каждый час
                if newSellCount ~= itemData.sellCount then
                    itemData.sellCount = newSellCount
                 end
            end
            local demandFactor = itemData.sellCount / itemData.demandThreshold -- Используем индивидуальный порог товара
            if demandFactor <= 1.0 then
                itemData.demandLevel = math.min(DynamicPricing.CONFIG.DEFAULT_MAX_MULTIPLIER, 1.0 + (1.0 - demandFactor) * 0.2) -- Плавное увеличение
            else
                itemData.demandLevel = math.max(DynamicPricing.CONFIG.DEFAULT_MIN_MULTIPLIER, 1.0 - (demandFactor - 1.0) * itemData.decayRate) -- Плавное снижение
            end
            local oldPrice = itemData.price
            DynamicPricing.updateItemPrice(itemName, itemData) -- Обновляем цену
            if oldDemand ~= itemData.demandLevel or oldSellCount ~= itemData.sellCount then
                local msg = string.format(
                    "DynamicPricing: %s recovered, demand: %.2f->%.2f, sellCount: %d->%d, price: %d->%d", 
                    itemName, oldDemand, itemData.demandLevel, oldSellCount, itemData.sellCount, oldPrice, itemData.price
                )
                writeLog("DynamicPricing", msg)
                recoveredCount = recoveredCount + 1
            end
        end
    end
    if recoveredCount > 0 then
        DynamicPricing.saveData() -- Сохраняем изменения
    end
end

function DynamicPricing.resetItemStats(itemName) -- Сброс статистики для товара
    if not SandboxVars.Shops.DinamicPrice then return end
    local itemData = FD.forSellItems[itemName]
    if not itemData then return false end
    itemData.sellCount = 0
    itemData.lastSold = 0
    itemData.demandLevel = 1.0
    itemData.priceMultiplier = 1.0    
    DynamicPricing.updateItemPrice(itemName, itemData)    
    local msg = "DynamicPricing: Reset stats for " .. itemName
    writeLog("DynamicPricing", msg)    
    DynamicPricing.saveData() -- Сохраняем изменения    
    return true
end

function DynamicPricing.resetAllStats() -- Сброс статистики для всех товаров
    if not SandboxVars.Shops.DinamicPrice then return end
    local resetCount = 0    
    for itemName, itemData in pairs(FD.forSellItems) do
        if not itemData.blacklisted and itemData.price then
            if DynamicPricing.resetItemStats(itemName) then
                resetCount = resetCount + 1
            end
        end
    end    
    local msg = "DynamicPricing: Reset stats for " .. resetCount .. " items"
    writeLog("DynamicPricing", msg)
    return resetCount
end

function DynamicPricing.initialize() -- Инициализация системы
    if not SandboxVars.Shops.DinamicPrice then return end
    for itemName, itemData in pairs(FD.forSellItems) do
        DynamicPricing.initializeItem(itemName, itemData)
    end    
    Events.EveryHours.Add(DynamicPricing.recoverPrices)    
end
