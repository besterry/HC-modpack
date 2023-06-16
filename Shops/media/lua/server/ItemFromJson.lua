--if not isServer() then return end
local json = require("json") -- ����������� ������ ��� ������ � JSON
shopItems = shopItems or {}
-- �������� ��������� �������� �� json
function LoadShopItems()
    local fileReaderObj = getFileReader("ShopItems.json", true) -- ������� ���� � ������ JSON-�����
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

    -- �������� �� � ������� Shop.Items
    for _, item in ipairs(shopItems) do
        Shop.Items[item.id] = {
            tab = item.tab,
            price = item.price
        }
    end

    -- ����� ����������� ������� Shop.Items
    -- for id, item in pairs(Shop.Items) do
    --     print("Item ID:", id)
    --     print("Tab:", item.tab)
    --     print("Price:", item.price)
    -- end
end

-- ����� ������� ��� ������ �������
Events.OnServerStarted.Add(LoadShopItems)
