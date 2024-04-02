if not isServer() then return end

local function SaveJsonItems(filename, tableToSave) -- функция записи в json файл
    local jsonToSave = Json.Encode(tableToSave)
    local fileWriterObj = getFileWriter(filename, false, false)
    fileWriterObj:write(jsonToSave)
    fileWriterObj:close()
end

local function LoadJsonItems(filename) --чтение с файла json
    local fileReaderObj = getFileReader(filename, false)
    if not fileReaderObj then --Создание таблицы, если файл не найден
        local defaultData = {}; return defaultData
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

local commands = {}
commands.purchaseAutoLoot = function (player, args) --Запись при покупке
    local filePath = "users/AutoLoot-table.json"
    local localdata = LoadJsonItems(filePath) -- предполагается что мы получаем массив
    if type(localdata) ~= "table" then -- Если данные не в виде таблицы, создаем новую таблицу
        localdata = {}
    end
    local newData = {
        user = player:getUsername(),
        time = args.autoloot
    }
    --print("User:",newData.user," Time:",newData.time)
    table.insert(localdata, newData) -- Добавление нового объекта в вашу таблицу
    SaveJsonItems(filePath, localdata) -- Сохранение обратно в файл
end

commands.getPlayers = function(player, args)
    local filePath = "users/AutoLoot-table.json"
    local localdata = LoadJsonItems(filePath)
    local currentTime = os.time() --string.format("%.3f", args.time)
    for i = #localdata, 1, -1 do
        local entry = localdata[i]
        -- print("entry.time:",entry.time)
        -- print("SandboxVars:",SandboxVars.AutoLoot.DurabilityAutoLoot * 24 * 60 * 60)
        -- print("currentTime:",currentTime)       
        if entry.time + (SandboxVars.AutoLoot.DurabilityAutoLoot * 24 * 60 * 60) < currentTime then
            table.remove(localdata, i) -- удаляем старую запись из таблицы
        end
    end
    SaveJsonItems(filePath, localdata) -- сохраняем обновленную таблицу
    local args = {}
    args.localdata = localdata
    args.currentTime = currentTime
    sendServerCommand(player, 'AdminAutoLoot', 'onGetPlayers', args)
    --print("Send")
end

local function autoloot_OnClientCommand(module, command, player, args)
    if module == "AdminAutoLoot" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(autoloot_OnClientCommand)