if not isServer() then return end

-- local Json = require("Json") -- ˜˜˜˜˜˜˜˜˜˜˜ ˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ ˜ JSON
FD = FD or {}
FD.shopItems = FD.shopItems or {}
FD.forSellItems = FD.forSellItems or {}
local shopItems = FD.shopItems
local forSellItems = FD.forSellItems

---@param filename string
---@return table
local function LoadJsonItems(filename)
    local fileReaderObj = getFileReader(filename, false) -- ˜˜˜˜˜˜˜ ˜˜˜˜ ˜ ˜˜˜˜˜˜ JSON-˜˜˜˜˜
    if fileReaderObj then 
        print("SHOP: " .. filename .. " file uploaded successfully")
    else
        print("SHOP: " .. filename .. " file is empty or does not exist")
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
    return resulTable
end

local function SaveJsonItems(theTable,filename)
    local fileWriterObj = getFileWriter(filename, true, false);
    local json = Json.Encode(theTable);
    fileWriterObj:write(json);
    fileWriterObj:close();
end

local function LoadAll()
    shopItems = LoadJsonItems("ShopPrice.json")
    forSellItems = LoadJsonItems("ForSell.json")
end

local function SaveAll()
    SaveJsonItems(shopItems,"ShopPrice.json")
    SaveJsonItems(forSellItems,"ForSell.json")
end

-- ˜˜˜˜˜ ˜˜˜˜˜˜˜ ˜˜˜ ˜˜˜˜˜˜ ˜˜˜˜˜˜˜
Events.OnServerStarted.Add(LoadAll)

local commands = {}
commands.getData = function(player, args)
    sendServerCommand('shopItems', "onGetData", {shopItems = shopItems, forSellItems = forSellItems})
end
commands.PushShopItems = function(player, args)
    shopItems = args[1]
    forSellItems = args[2]
    SaveAll()
end
commands.ReloadShopItems = function(player, args)
    LoadAll()
    print("Reload item")
end


local function shopItems_OnClientCommand(module, command, player, args)
    if module == "shopItems" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(shopItems_OnClientCommand)
