require "TimedActions/ISBaseTimedAction"
PSClient = PSClient or {}
local Nfunction = require "Nfunction"
PlayerShopBuyAction = ISBaseTimedAction:derive("PlayerShopBuyAction")

function PlayerShopBuyAction:isValid()
    -- при скупке валидность не зависит от баланса игрока
    local ticket = self.ticket
    if (ticket.coin or 0) == 0 and (ticket.specialCoin or 0) == 0 then
        return true
    end
    local username = self.character:getUsername()
    local coin,specialCoin = Balance.getUserBalance(username)
    return coin >= (ticket.coin or 0) and specialCoin >= (ticket.specialCoin or 0)
end

function PlayerShopBuyAction:waitToStart()
    return self.character:shouldBeTurning()
end

function PlayerShopBuyAction:update()
    if not self.shopUI:getIsVisible() then 
        self:forceStop()
    end
end

function PlayerShopBuyAction:start()
end

function PlayerShopBuyAction:stop()
    ISBaseTimedAction.stop(self)
end

function PlayerShopBuyAction:perform()
    local cartItems = self.shopUI.cartItems.items
    local playerInv = self.character:getInventory()
    local total = 0
    local totalSpecial = 0
    local itemsSold = {}
    local soldUnits = 0 -- сколько единиц продали в магазин (скупка)
    local sellTotalCoin, sellTotalSpec = 0, 0
    -- 1) Сначала обработаем все ордера на скупку агрегировано по ключу
    local orderBatches = {}
    for _,v in pairs(cartItems) do
        local it = v.item
        if it.orderKey then
            local key = it.orderKey
            local units = it.units or 1
            if not orderBatches[key] then
                orderBatches[key] = { key = key, type = it.type, units = units, onlyFull = it.onlyFull and true or false }
            else
                orderBatches[key].units = orderBatches[key].units + units
            end
        end
    end
    -- helper: найти подходящий предмет (учитывая onlyFull)
    local function findEligible(inv, typeFull, onlyFull)
        if not inv then return nil end
        local list = inv:getAllTypeRecurse(typeFull)
        if not list then return nil end
        for i=0,list:size()-1 do
            local it = list:get(i)
            if not onlyFull then return it end
            local maxC = it and it:getConditionMax() or 0
            if maxC > 0 and it:getCondition() == maxC then return it end
        end
        return nil
    end

    for _,batch in pairs(orderBatches) do
        local units = batch.units or 0
        if units > 0 then
            local sample = findEligible(playerInv, batch.type, batch.onlyFull)
            if sample then
                local cont = self.shop:getContainer()
                local unitWeight = sample:getActualWeight()
                local maxByWeight = math.floor(math.max(0, (cont:getCapacity() - cont:getCapacityWeight())) / math.max(0.0001, unitWeight))
                local allowed = math.min(units, maxByWeight)
                if allowed <= 0 then
                    self.character:setHaloNote(getText("IGUI_ContainerFull"), 255,255,255,300)
                    return -- выходим из всей функции если контейнер заполнен
                else
                    local removed = 0
                    while removed < allowed do
                        local it = findEligible(playerInv, batch.type, batch.onlyFull)
                        if not it then break end
                        playerInv:Remove(it)
                        -- переносим этот же экземпляр в контейнер магазина
                        cont:AddItem(it)
                        if cont.addItemOnServer then cont:addItemOnServer(it) end
                        if SandboxVars.Shops.PurchaseLog then Nfunction.buildLogShop(batch.type) end
                        removed = removed + 1
                    end
                    if removed > 0 then
                        soldUnits = soldUnits + removed
                        local shopSquare = self.shop:getSquare()
                        local coords = {x = shopSquare:getX(), y = shopSquare:getY(), z = shopSquare:getZ()}
                        local paid = PSClient.SellToBuyOrder(self.character, {coords = coords, orderKey = batch.key, itemType = batch.type, quantity = removed})
                        if paid then
                            sellTotalCoin = sellTotalCoin + (paid.coin or 0)
                            sellTotalSpec = sellTotalSpec + (paid.special or 0)
                        end
                    end
                end
            end
        end
    end

    -- 2) Затем обработаем обычные покупки из магазина
    for _,v in pairs(cartItems) do
        local item = v.item
        if not item.orderKey then
            local invItem = item.invItem
            shopContainer = self.shop:getContainer()
            if shopContainer:contains(invItem) then
                shopContainer:Remove(invItem)
                shopContainer:removeItemOnServer(invItem)
                playerInv:addItem(invItem)
                if SandboxVars.Shops.PurchaseLog then Nfunction.buildLogShop(invItem:getFullType()) end
                if item.specialCoin then
                    totalSpecial = totalSpecial + item.price
                else
                    total = total + item.price
                end
                local modData = invItem:getModData()
                modData.specialCoin = nil
                modData.price = nil
                table.insert(itemsSold, {type = invItem:getFullType(), name = invItem:getName(), price = item.price, specialCoin = item.specialCoin})
            end
        end
    end
    local shopSquare = self.shop:getSquare()
    local coords = {
        x = shopSquare:getX(),
        y = shopSquare:getY(),
        z = shopSquare:getZ(),
    }
    if SandboxVars.Shops.PurchaseLog then
        if soldUnits > 0 then
            Nfunction.logShop(coords, "Sell (" .. self.shop:getModData().owner .. ") [price: " .. sellTotalCoin .. "c/" .. sellTotalSpec .. "s]")
        else
            Nfunction.logShop(coords, "Purchase (" .. self.shop:getModData().owner .. ") [price: " .. total .. "c/" .. totalSpecial .. "s]")
        end
    end
    self.character:playSound("CashRegister")
    local income = self.shop:getModData().income
    local data = { b = self.character:getUsername(), t = {tl = total, tls = totalSpecial}, items = itemsSold }
    if total > 0 or totalSpecial > 0 then
        -- обычная покупка: списываем со счета игрока и пишем доход магазина
        sendClientCommand("BS", "Withdraw", {total,totalSpecial})
        table.insert(income,data)
    end
    self.shop:transmitModData()
    self.shopUI:activateFirstTab()
    ISBaseTimedAction.perform(self)
end

function PlayerShopBuyAction:new(character,shopUI,ticket)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.shopUI = shopUI
    o.ticket = ticket
    o.shop = shopUI.shop
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = 100
    return o
end 