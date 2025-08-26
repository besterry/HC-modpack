local Nfunction = {}

 function Nfunction.trimString(str,limit) -- обрезает строку до limit символов
    local len = string.len(str)
    if len > limit then
        str = string.sub(str,1,limit-3) .. "..."
    end
    return str
end

function Nfunction.drainablePrice(item,price) -- возвращает цену для жидкостей
    if instanceof(item, "DrainableComboItem") then
        price = math.floor(price*item:getUsedDelta())
        if price<=0 then
            price = 1
        end  
    end
    return price
end

local shopItems = {} -- массив для предметов при продаже или покупке
function Nfunction.logShop(coords,action) -- логирует продажу (перенос на сервер)
    local username = getPlayer():getUsername()
    if not action then
        action = "Purchase"
    end
    -- Передаем данные на сервер вместо формирования лога
    local args = {
        username = username,
        coords = coords,
        action = action,
        items = shopItems
    }
    shopItems = {} -- очищаем массив
    sendClientCommand("LS", "ProcessShopTransaction", args)    
end

function Nfunction.buildLogShop(type,quantity) -- строит логирование продаж
    if not shopItems[type] then
        local count = 1
        if quantity then count = quantity end
        shopItems[type] = count
    else
        shopItems[type] = shopItems[type] + 1
    end
end

return Nfunction