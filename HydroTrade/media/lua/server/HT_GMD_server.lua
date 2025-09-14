if isClient() then return end

local MOD_NAME = "HT_GMD"
local Commands = {}

local ADMIN_IDS = { ["admin"] = true }

local function checkAdmin(player)
	if not player or not player.getSteamID then return false end
	local sid = player:getUsername()
	-- print("Server: Player steamid: " .. sid .. " " .. tostring(ADMIN_IDS[sid]))
	return ADMIN_IDS[sid] == true
end

-- Рекурсивная функция подсчета размера таблицы
local function countTableSize(t, maxDepth, currentDepth)
    if not t or type(t) ~= "table" then return 0 end
    if currentDepth > maxDepth then return 1 end
    
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
        if type(v) == "table" then
            count = count + countTableSize(v, maxDepth, currentDepth + 1)
        end
    end
    return count
end


Commands.onGetModdataPlayer = function(player, args)
    print("onGetModdataPlayer")
    local moddata = args.moddata
    local reciever = args.reciever
    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local findPlayer = players:get(i)
        if findPlayer:getUsername() == reciever then
            sendServerCommand(findPlayer, MOD_NAME, "onShowModdata", args)
            break
        end
    end
end

Commands.getPlayerModdata = function(player, args)
    local reciever = player:getUsername()
    local username = args.player
    local players = getOnlinePlayers()
    for i = 0, players:size() - 1 do
        local findPlayer = players:get(i)
        if findPlayer:getUsername() == username then            
            local args = {}
            args.reciever = reciever
            sendServerCommand(findPlayer, "PlayerHealth", "getModdataPlayer", args)
            break
        end
    end
end

-- get: вернуть всю ModData одним запросом
Commands.get = function(player, args)
    if not checkAdmin(player) then return end
    local success, result = pcall(function()
        local tableNames = ModData.getTableNames()
        -- print("Server: ModData.getTableNames() size: " .. tableNames:size())
        
        local responseData = {}
        
        for i = 0, tableNames:size() - 1 do
            local name = tableNames:get(i)
            local data = ModData.get(name)
            
            if data then
                -- Рекурсивная проверка размера с ограничением глубины
                local size = countTableSize(data, 3, 0) -- Максимум 3 уровня вложенности
                
                if size > 30000 then
                    -- print("Server: Table '" .. name .. "' too large (" .. size .. " entries), sending size only")
                    responseData[name] = {
                        data = nil,
                        size = size,
                        error = "Table too large (at least " .. size .. " entries). Cannot transmit."
                    }
                else
                    -- print("Server: Adding table '" .. name .. "' (" .. size .. " entries)")
                    responseData[name] = {
                        data = data,
                        size = size
                    }
                end
            else
                -- print("Server: Table '" .. name .. "' not found")
                responseData[name] = {
                    data = nil,
                    error = "Table not found"
                }
            end
        end
        
        -- print("Server: Sending complete ModData to client")
        return responseData
    end)
    
    if success then
        sendServerCommand(player, MOD_NAME, "onGet", { data = result })
    else
        -- print("Server: Error getting ModData: " .. tostring(result))
        sendServerCommand(player, MOD_NAME, "onGet", { 
            data = nil,
            error = "Error accessing ModData: " .. tostring(result)
        })
    end
end

-- deleteTable: удалить всю таблицу
Commands.deleteTable = function(player, args)
    if not checkAdmin(player) then return end
    local tableName = args.name
    if tableName then
        local success, result = pcall(function()
            local data = ModData.get(tableName)
            if data then
                ModData.remove(tableName)
                -- print("Server: Deleted table '" .. tableName .. "'")
                return { success = true, message = "Table '" .. tableName .. "' deleted successfully" }
            else
                return { success = false, message = "Table '" .. tableName .. "' not found" }
            end
        end)
        
        if success then
            writeLog("admin", "'" .. player:getUsername() .. "' Deleted table '" .. tableName .. "'")
            sendServerCommand(player, MOD_NAME, "onDeleteTable", result)
        else
            -- print("Server: Error deleting table '" .. tableName .. "': " .. tostring(result))
            sendServerCommand(player, MOD_NAME, "onDeleteTable", { 
                success = false,
                message = "Error deleting table: " .. tostring(result)
            })
        end
    end
end

-- deleteKey: удалить конкретный ключ из таблицы
Commands.deleteKey = function(player, args)
    if not checkAdmin(player) then return end
    local tableName = args.tableName
    local key = args.key
    if tableName and key then
        local success, result = pcall(function()
            local data = ModData.get(tableName)
            if data then
                local primaryKey = key
                local alternateKey = nil
                if type(key) == "string" then
                    local maybeNum = tonumber(key)
                    if maybeNum then alternateKey = maybeNum end
                elseif type(key) == "number" then
                    alternateKey = tostring(key)
                end

                local existsPrimary = data[primaryKey] ~= nil
                local existsAlt = alternateKey ~= nil and data[alternateKey] ~= nil

                if existsPrimary or existsAlt then
                    local actualKey = existsPrimary and primaryKey or alternateKey
                    data[actualKey] = nil
                    ModData.transmit(tableName)
                    -- print("Server: Deleted key '" .. tostring(actualKey) .. "' from table '" .. tableName .. "'")
                    return { success = true, message = "Key '" .. tostring(actualKey) .. "' deleted from table '" .. tableName .. "'" }
                else
                    return { success = false, message = "Key '" .. tostring(key) .. "' not found in table '" .. tableName .. "'" }
                end
            else
                return { success = false, message = "Table '" .. tableName .. "' not found" }
            end
        end)
        
        if success then
            writeLog("admin", "'" .. player:getUsername() .. "' Deleted key '" .. key .. "' from table '" .. tableName .. "'")
            sendServerCommand(player, MOD_NAME, "onDeleteKey", result)
        else
            -- print("Server: Error deleting key '" .. key .. "' from table '" .. tableName .. "': " .. tostring(result))
            sendServerCommand(player, MOD_NAME, "onDeleteKey", { 
                success = false,
                message = "Error deleting key: " .. tostring(result)
            })
        end
    end
end

local function onClientCommand(module, command, player, args)
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(onClientCommand)
