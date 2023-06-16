--if not isServer() then return end
local json = require("json") -- Подключение модуля для работы с JSON
shopItems = shopItems or {}
-- загрузка элементов магазина из json
function LoadShopItems()
    local fileReaderObj = getFileReader("ShopItems.json", true) -- Укажите путь к вашему JSON-файлу
    if fileReaderObj then 
        print("SHOP: ShopItems file uploaded successfully")
    else
        print("SHOP: The file is empty or does not exist")
    end

    local json = ""
    local line = fileReaderObj:readLine()
    while line ~= nil do
        json = json .. line
        line = fileReaderObj:readLine()
    end
    fileReaderObj:close()

    if json and json ~= "" then
        shopItems = json.decode(json)
    end

    -- добавить их в таблицу Shop.Items
    for _, item in ipairs(shopItems) do
        Shop.Items[item.id] = {
            tab = item.tab,
            price = item.price
        }
    end

    -- Вывод содержимого таблицы Shop.Items
    -- for id, item in pairs(Shop.Items) do
    --     print("Item ID:", id)
    --     print("Tab:", item.tab)
    --     print("Price:", item.price)
    -- end
end

-- Вызов функции при старте сервера
Events.OnServerStarted.Add(LoadShopItems)
