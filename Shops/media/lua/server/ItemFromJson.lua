if not isServer() then return end

-- local Json = require("Json") -- ����������� ������ ��� ������ � JSON
FD = FD or {}
FD.shopItems = FD.shopItems or {}
FD.forSellItems = FD.forSellItems or {}
local shopItems = FD.shopItems
local forSellItems = FD.forSellItems

-- -- �������� ��������� �������� �� json
-- function LoadShopItems()
--     local fileReaderObj = getFileReader("ShopPrice.json", false) -- ������� ���� � ������ JSON-�����
--     if fileReaderObj then 
--         print("SHOP: ShopItems file uploaded successfully")
--     else
--         print("SHOP: The file is empty or does not exist")
--     end

--     local json = ""
--     local line = fileReaderObj:readLine()
--     while line ~= nil do
--         json = json .. line
--         line = fileReaderObj:readLine()
--     end
--     fileReaderObj:close()

--     if json and json ~= "" then
--         shopItems = Json.Decode(json);
--     end

--     -- -- ����� ����������� ������� Shop.Items
--     -- for id, item in pairs(shopItems) do
--     --     print("Item ID:", id)
--     --     print("Tab:", item.tab)
--     --     print("Price:", item.price)
--     -- end
-- end

---@param filename string
---@return table
function LoadJsonItems(filename)
    local fileReaderObj = getFileReader(filename, false) -- ������� ���� � ������ JSON-�����
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

    local resulTable = {}
    if json and json ~= "" then
        resulTable = Json.Decode(json);
    end

    -- -- ����� ����������� ������� Shop.Items
    -- for id, item in pairs(shopItems) do
    --     print("Item ID:", id)
    --     print("Tab:", item.tab)
    --     print("Price:", item.price)
    -- end
    return resulTable
end

function LoadAll()
    shopItems = LoadJsonItems("ShopPrice.json")
    forSellItems = LoadJsonItems("ForSell.json")
end

-- ����� ������� ��� ������ �������
Events.OnServerStarted.Add(LoadAll)

local commands = {}
commands.getData = function(player, args)
    sendServerCommand('shopItems', "onGetData", {shopItems = shopItems, forSellItems = forSellItems})
end


local function shopItems_OnClientCommand(module, command, player, args)
    if module == "shopItems" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(shopItems_OnClientCommand)
