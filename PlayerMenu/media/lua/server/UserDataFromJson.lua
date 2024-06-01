if not isServer() then return end
-- FD = FD or {}
-- FD.UserData = FD.UserData or {}
local UserData --= FD.UserData

local function checkUserdata() --проверка на существование полей
    if not UserData.balance then UserData.balance = 0 end   
    if not UserData.bonus then  UserData.bonus = 0 end
    if not UserData.safehouse then  UserData.safehouse = 625 end    
    if not UserData.ShopCount then  UserData.ShopCount = 0 end        
    if not UserData.MaxShopCount then  UserData.MaxShopCount = 5 end       
end

local function SaveJsonItems(theTable,filename) --Сохранение в файл
    --local filename = "users/" .. nickname .. ".json"
    local fileWriterObj = getFileWriter(filename, true, false);
    local json = Json.Encode(theTable);
    fileWriterObj:write(json);
    fileWriterObj:close();
end

---@param filename string
---@return table
local function LoadJsonItems(filename) --чтение с файла json
    local fileReaderObj = getFileReader(filename, false)
    if fileReaderObj then         
        --print("UserData: " .. filename .. " file uploaded successfully")
    else
        local defaultData = { --Создание файла пользователя, если он не найден
            balance = 0,
            bonus = 0,
            safehouse = 625, 
            ShopCount = 0,
            MaxShopCount = 5,
            autoloot = 0
        }
        local msg = "New user create account:" .. filename
        writeLog("BalanceAndSafeHouse", msg)
        SaveJsonItems(defaultData, filename)
        return defaultData
    end

    local json = ""
    local line = fileReaderObj:readLine()
    while line ~= nil do
        --print(line)
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

function CheckBalance(userData,args,key,value) --Проверка баланса на пополнение   
    if args["balance"] then
        if args["delta"] <= userData.balance then
            userData.balance = userData.balance - args["delta"]
        end   
    end
    if args["bonus"] then
        if args["delta"] <= userData.bonus then
            userData.bonus = userData.bonus - args["delta"]   
        end
    end
end

local commands = {} --Команды приходящие на сервер

commands.getData = function(player, args) --Считывание UserData из jsob и отправка
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"    
    UserData = LoadJsonItems(filename)
    checkUserdata()
    if UserData then
        sendServerCommand('BalanceAndSH', 'onGetData', {UserData = UserData})
    end
end

commands.getDataAutoLoot = function(player, args) --Считывание UserData из jsob и отправка
    --print("test")
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"    
    UserData = LoadJsonItems(filename)
    checkUserdata()
    if UserData then
        sendServerCommand(player, 'BalanceAndSH', 'onGetDataAutoLoot', {UserData = UserData})
    end
end

commands.getDataALUI = function(player, args) --Считывание UserData из jsob и отправка
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"    
    UserData = LoadJsonItems(filename)
    checkUserdata()
    if UserData then
        sendServerCommand(player, 'BalanceAndSH', 'onGetDataALUI', {UserData = UserData})
    end
end

commands.saveData = function(player, args) 
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"
    UserData = LoadJsonItems(filename)
    local safehouse = args['userData'][1]
    local balanceOld = args['userData'][2]
    local balanceNew = args['userData'][3]
    checkUserdata()

    if balanceOld == UserData.balance and safehouse > UserData.safehouse then
        UserData.balance = balanceNew
        UserData.safehouse = safehouse
        SaveJsonItems(UserData, filename)
    elseif balanceOld < UserData.balance and safehouse > UserData.safehouse then 
        UserData.balance = UserData.balance - (balanceOld - balanceNew)
        UserData.safehouse = safehouse
        SaveJsonItems(UserData, filename)
    end
    
    local msg = nickname .. ", delta: " .. (balanceNew - balanceOld) .. ", oldBalance:" ..  balanceOld .. ", newBalance:" .. balanceNew .. ", oldSafehouseSize:" .. UserData.safehouse .. ", newSafehouseSize:" .. safehouse
    writeLog("PlayerMenuActions", msg)
end

commands.saveUserData = function (player, args)
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"
    UserData = LoadJsonItems(filename)
    for key, value in pairs(args) do   
        if UserData[key] ~= nil then -- Проверяем, есть ли такой ключ в UserData            
            if key=="balance" or key=="bonus" then
                CheckBalance(UserData,args,key,value) -- проверяем баланс в файле равен балансу с клиента, если нет - переоформляем
            else
                UserData[key] = value -- Если ключ существует, перезаписываем значение
            end
        elseif key~="action" and key ~= "delta" then -- Если ключа нет в UserData, создаем его            
            UserData[key] = value
        end
    end
    SaveJsonItems(UserData,filename)
    local action
    if args["action"] then
        action = " >" .. args["action"] .. "< "
    else
        action = ""
    end
    local msg = nickname .. " " .. action .. "balance:" .. UserData["balance"] .. ", bonus:" .. UserData["bonus"] .. ", safehouse:" .. UserData["safehouse"] .. ", ShopCount:" ..UserData["ShopCount"] .. ", MaxShopCount:" ..UserData["MaxShopCount"]
    writeLog("PlayerMenuActions", msg)
end

commands.reloadUserData = function(player, args) --кнопка перезагрузка
    local nickname = player:getUsername()    
    local filename = "users/" .. nickname .. ".json"
    UserData = LoadJsonItems(filename)
    sendServerCommand('BalanceAndSH', 'onGetData', {UserData = UserData})
end

commands.getServerTime = function(player, args) --Получение серверного времени    
    --print("Server Time:", os.time())
    args = {}
    args.time = os.time()
    sendServerCommand('BalanceAndSH', 'onGetServerTime1', args)
end

--Объявляем функцию прослушивания BalanceAndSH с клиента и выполнение команд
local function BalanceAndSH_OnClientCommand(module, command, player, args)
    if module == "BalanceAndSH" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(BalanceAndSH_OnClientCommand)