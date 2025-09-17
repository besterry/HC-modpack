if not isClient() then return end

PSClient = PSClient or {}

-- find shop object at coords on client
local function getShopObject(coords)
    local square = getCell():getGridSquare(coords.x, coords.y, coords.z)
    if not square then return nil end
    for i=0, square:getSpecialObjects():size()-1 do
        local o = square:getSpecialObjects():get(i)
        local sprite = o:getSprite() and o:getSprite():getName() or ""
        if sprite and PlayerShop and PlayerShop.spritePrefix and string.find(sprite, PlayerShop.spritePrefix) then
            return o
        end
    end
    return nil
end

function PSClient.ToggleBusy(args)
    PlayerShop.status[args[1]] = args[2]
end

function PSClient.SyncStatusData(args)
    PlayerShop.status = args[1]
end

local function PS_OnServerCommand(module, command, args)
    if module== "PS" and PSClient[command] then
        PSClient[command](args)
    end
end

local function SyncPlayerShopStatusData()
	sendClientCommand("PS", "SyncStatusData", {})
    Events.OnTick.Remove(SyncPlayerShopStatusData)
end

Events.OnTick.Add(SyncPlayerShopStatusData)
Events.OnServerCommand.Add(PS_OnServerCommand)


-- Ордеры скупки: храним в shop:getModData().buyOrders = { [key] = {type, price, specialCoin, qty, from = 'owner'|'shop', owner = 'name', limit = N } }
local function ensureBuyOrdersTable(shop)
    local md = shop:getModData()
    if not md.buyOrders then md.buyOrders = {} end
    return md.buyOrders
end

-- key формируем: type|price|special
local function makeOrderKey(typeFull, price, special)
    return typeFull.."|"..tostring(price).."|"..tostring(special)
end

-- Создать/обновить ордер
function PSClient.SetBuyOrder(player,args)
    -- args: coords, order = {type, price, specialCoin, qty, from, limit}
    local coords = args.coords
    local order = args.order
    local shop = getShopObject(coords)
    if not shop then return end
    local owner = shop:getModData().owner or player:getUsername()
    local orders = ensureBuyOrdersTable(shop)
    order.owner = owner
    local key = makeOrderKey(order.type, order.price, order.specialCoin)
    orders[key] = order
    shop:transmitModData()
end

-- Удалить ордер
function PSClient.RemoveBuyOrder(player,args)
    local coords = args.coords
    local key = args.key
    local shop = getShopObject(coords)
    if not shop then return end
    local orders = ensureBuyOrdersTable(shop)
    orders[key] = nil
    shop:transmitModData()
end

-- Продать предмет в ордер: проверка и выплата
function PSClient.SellToBuyOrder(player,args)
    -- args: coords, itemType, quantity
    local coords = args.coords
    local itemType = args.itemType
    local quantity = args.quantity or 1
    local shop = getShopObject(coords)
    if not shop then return end
    local md = shop:getModData()
    local orders = ensureBuyOrdersTable(shop)
    -- по нескольким ордерам: ищем самый дорогой подходящий
    local bestKey, bestOrder
    for key,ord in pairs(orders) do
        local parts = {}
        for p in string.gmatch(key, "[^|]+") do table.insert(parts, p) end
        local t = parts[1]
        if t == itemType and ord.qty and ord.qty > 0 then
            if not bestOrder or ord.price > bestOrder.price or (ord.specialCoin and not bestOrder.specialCoin) then
                bestKey, bestOrder = key, ord
            end
        end
    end
    if not bestOrder then return end
    local canSell = math.min(quantity, bestOrder.qty)
    if canSell <= 0 then return end
    -- проверим вместимость контейнера магазина
    local cont = shop:getContainer()
    local scriptItem = ScriptManager.instance:getItem(itemType)
    if scriptItem then
        local temp = InventoryItemFactory.CreateItem(itemType)
        if temp then
            local need = temp:getActualWeight() * canSell
            if cont:getCapacity() < (cont:getCapacityWeight() + need) then
                return
            end
        end
    end

    -- оплата: сначала из кассы, затем из дохода, если разрешено
    local md = shop:getModData()
    md.cash = md.cash or {coin=0,specialCoin=0} -- Касса магазина
    local needCoin = bestOrder.specialCoin and 0 or (bestOrder.price*canSell) -- Нужно монет
    local needSpec = bestOrder.specialCoin and (bestOrder.price*canSell) or 0 -- Нужно специальных монет

    local fromCashCoin = math.min(md.cash.coin or 0, needCoin) -- Из кассы монет
    local fromCashSpec = math.min(md.cash.specialCoin or 0, needSpec) -- Из специальных монет
    local remCoin = needCoin - fromCashCoin -- Остаток монет
    local remSpec = needSpec - fromCashSpec -- Остаток специальных монет

    local function sumIncome(currencySpecial) -- Сумма дохода
        local s = 0
        for _,v in pairs(md.income or {}) do
            if currencySpecial then s = s + (v.t and v.t.tls or 0) else s = s + (v.t and v.t.tl or 0) end -- Если специальные монеты, то складываем специальные монеты, иначе складываем монеты
        end
        return s -- Возвращаем сумму дохода нужной валюты
    end

    local function takeFromIncome(amount, currencySpecial) -- Взять из дохода нужной валюты
        if amount <= 0 then return 0 end -- Если нужно взять 0, то возвращаем 0
        local left = amount -- Остаток нужной валюты
        local income = md.income or {} -- Доход
        for i=#income,1,-1 do -- Цикл по доходу
            local v = income[i] -- Доход
            local val = currencySpecial and (v.t and v.t.tls or 0) or (v.t and v.t.tl or 0) -- Если специальные монеты, то складываем специальные монеты, иначе складываем монеты
            if val > 0 then
                local take = math.min(val, left) -- Взять из дохода нужной валюты
                if currencySpecial then v.t.tls = val - take else v.t.tl = val - take end -- Если специальные монеты, то вычитаем из специальных монет, иначе вычитаем из монет
                left = left - take -- Остаток нужной валюты
                -- if (v.t.tl <= 0) and (v.t.tls <= 0) then table.remove(income, i) end -- Если монет и специальных монет не осталось, то удаляем доход
                if left <= 0 then break end -- Если остаток нужной валюты 0, то выходим из цикла
            end
        end
        md.income = income -- Доход
        return amount - left -- Возвращаем остаток нужной валюты
    end

    local fromIncomeCoin, fromIncomeSpec = 0, 0 -- Из дохода монет и специальных монет
    if (remCoin > 0 or remSpec > 0) and md.useIncome then -- Если нужно взять из дохода монет или специальных монет и разрешено использовать доход
        if remCoin > 0 then
            local avail = sumIncome(false) -- Сумма дохода монет
            local got = takeFromIncome(math.min(remCoin, avail), false) -- Из дохода монет, если есть
            fromIncomeCoin = got -- Из дохода монет
            remCoin = remCoin - got -- Остаток монет
        end
        if remSpec > 0 then
            local availS = sumIncome(true) -- Сумма дохода специальных монет
            local gotS = takeFromIncome(math.min(remSpec, availS), true) -- Из дохода специальных монет
            fromIncomeSpec = gotS -- Из дохода специальных монет
            remSpec = remSpec - gotS -- Остаток специальных монет
        end
    end

    if remCoin > 0 or remSpec > 0 then -- Если нужно взять из дохода монет или специальных монет и нет дохода, то выходим
        return
    end

    -- списать из кассы только то, что оплачено из кассы
    md.cash.coin = (md.cash.coin or 0) - fromCashCoin -- Из кассы монет
    md.cash.specialCoin = (md.cash.specialCoin or 0) - fromCashSpec -- Из кассы специальных монет
    -- выплатить продавцу (серверная операция)
    local totalPayCoin = fromCashCoin + fromIncomeCoin -- Сумма к выплате монет
    local totalPaySpec = fromCashSpec + fromIncomeSpec -- Сумма к выплате специальных монет
    if totalPayCoin > 0 or totalPaySpec > 0 then
        sendClientCommand("BS", "Deposit", { totalPayCoin, totalPaySpec })
    end
    if totalPayCoin > 0 or totalPaySpec > 0 then player:playSound("CashRegister") end
    -- положить купленные предметы в контейнер магазина
    for i=1,canSell do
        local it = InventoryItemFactory.CreateItem(itemType)
        if it then
            cont:AddItem(it)
            if cont.addItemOnServer then cont:addItemOnServer(it) end
        end
    end
    bestOrder.qty = bestOrder.qty - canSell -- Уменьшаем количество предметов в ордере
    if bestOrder.limit then
        bestOrder.limit = math.max(0, bestOrder.limit - canSell) -- Уменьшаем лимит предметов в ордере
    end
    if bestOrder.qty <= 0 or (bestOrder.limit and bestOrder.limit <= 0) then -- Если количество предметов в ордере 0 или лимит предметов в ордере 0, то удаляем ордер
        orders[bestKey] = nil -- Удаляем ордер
    end
    shop:transmitModData()
    return { coin = totalPayCoin, special = totalPaySpec }
end