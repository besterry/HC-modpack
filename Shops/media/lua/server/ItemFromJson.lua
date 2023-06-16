if not isServer() then return end

-- local Json = require("Json") -- Подключение модуля для работы с JSON
FD = FD or {}
FD.shopItems = FD.shopItems or {}
local shopItems = FD.shopItems

-- загрузка элементов магазина из json
function LoadShopItems()
    local fileReaderObj = getFileReader("ShopPrice.json", false) -- Укажите путь к вашему JSON-файлу
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
        shopItems = Json.Decode(json);
    end

    -- -- Вывод содержимого таблицы Shop.Items
    -- for id, item in pairs(shopItems) do
    --     print("Item ID:", id)
    --     print("Tab:", item.tab)
    --     print("Price:", item.price)
    -- end
end

-- Вызов функции при старте сервера
Events.OnServerStarted.Add(LoadShopItems)

local commands = {}
commands.getData = function(player, args)
    sendServerCommand('shopItems', "onGetData", shopItems)
end


local function shopItems_OnClientCommand(module, command, player, args)
    if module == "shopItems" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(shopItems_OnClientCommand)
