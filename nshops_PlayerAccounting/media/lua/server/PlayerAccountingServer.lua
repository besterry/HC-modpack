if isClient() then return end

ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}

local MOD_NAME = ETOMARAT.PlayerAccounting.MOD_NAME
local EVENT_TYPES = ETOMARAT.PlayerAccounting.EVENT_TYPES

local base_BServer = {}

-- Блок очистки от старых данных

local function parseDateTime(dateTimeStr) -- Функция для парсинга даты из строки
    local day, month, year, hour, minute = dateTimeStr:match("(%d+)/(%d+)/(%d+) (%d+):(%d+)")
    if not day then return nil end
    return {
        day = tonumber(day),
        month = tonumber(month),
        year = tonumber(year),
        hour = tonumber(hour),
        minute = tonumber(minute)
    }
end

local function isRecordOlderThanMonths(recordDate, months) -- Функция для проверки, является ли запись старше N месяцев
    local currentTime = getGameTime()
    local currentYear = currentTime:getYear()
    local currentMonth = currentTime:getMonth()
    local recordYear = recordDate.year
    local recordMonth = recordDate.month
    -- Вычисляем разность в месяцах ()
    local monthsDiff = (currentYear - recordYear) * 12 + (currentMonth - recordMonth)
    return monthsDiff > months
end

local DATA_RETENTION_MONTHS = 12 -- Сохраняем последние 12 месяца (заменить на настройку песочницы)

-- Функция для очистки старых записей
local function cleanOldRecords(data)
    local cleaned = false
    for username, records in pairs(data) do
        if type(records) == "table" then
            local newRecords = {}
            for i, record in ipairs(records) do
                if type(record) == "table" and #record > 0 then
                    local recordDate = parseDateTime(record[1])
                    if recordDate and not isRecordOlderThanMonths(recordDate, DATA_RETENTION_MONTHS) then
                        table.insert(newRecords, record)
                    else
                        cleaned = true
                    end
                end
            end
            if #newRecords > 0 then
                data[username] = newRecords
            else
                data[username] = nil -- Удаляем запись, если пустая
            end            
        end
    end
    return cleaned
end


local getDateTimeStr = function ()
    local gt = getGameTime()
    local minutes = tostring(gt:getMinutes())
    local hours = tostring(gt:getHour())
    if #minutes == 1 then
        minutes = '0'..minutes
    end
    if #hours == 1 then
        hours = '0'..hours
    end
    return ('%s/%s/%s %s:%s'):format(gt:getDay(), gt:getMonth(), gt:getYear(), hours, minutes)
end

---@class ServerAccaunting
local ServerAccaunting = {}

function ServerAccaunting:new(modData)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    ---@type modData
    self.data = modData
    return o
end

function ServerAccaunting:transmit()
    ModData.add(MOD_NAME, self.data)
    ModData.transmit(MOD_NAME)
end

---@param player IsoPlayer | string
---@param event_type event_type
---@param coin integer | nil
---@param specialCoin integer | nil
---@param recipient string | nil
---@param note string | nil
function ServerAccaunting:insert(player, event_type, coin, specialCoin, recipient, note)
    local username = player
    if type(player) ~= "string" then
        username = player:getUsername()
    end
    local dt = getDateTimeStr()
    local old_table = self.data[username] or {} -- Таблица для игрока
    local entry = {
        dt,
        event_type,
        coin,
        specialCoin,
        recipient
    }
    if note and note ~= "" then
        entry[6] = note
    end
    table.insert(old_table, entry)

    while #old_table > 30 do
        table.remove(old_table, 1)  -- Remove the oldest record
    end

    self.data[username] = old_table -- Таблица для игрока
    ModData.add(MOD_NAME, self.data) -- сохраняем данные в моддате сервера
    local args = {
        username = username,
        table = old_table
    }
    local playerObj = nil
    local players = getOnlinePlayers()
    if players then
        for i = 0, players:size() - 1 do
            local p = players:get(i)
            if p:getUsername() == username then
                playerObj = p
                break
            end
        end
    end
    
    if playerObj then
        sendServerCommand(playerObj, "PlayerAccounting", "Insert", args)
    end
end

---@param player IsoPlayer
function ServerAccaunting:CreateAccount(player)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    local type = EVENT_TYPES.Create
    if account then
        type = EVENT_TYPES.Linked
    end
    self:insert(player, type)
end

---@param player IsoPlayer
---@param args integer[]
function ServerAccaunting:Deposit(player, args)
    local coin, specialCoin = unpack(args)
    self:insert(player, EVENT_TYPES.Deposit, coin, specialCoin)
end

---@param player IsoPlayer
---@param args integer[]
function ServerAccaunting:Withdraw(player, args)
    local coin, specialCoin = unpack(args)
    self:insert(player, EVENT_TYPES.Withdraw, coin, specialCoin)
end

---@param player IsoPlayer
---@param args (integer | string)[]
function ServerAccaunting:Transfer(player, args)
    local coin, specialCoin, recipient, note = unpack(args)
    ---@cast coin integer
    if type(note) ~= "string" or note == "" then
        note = nil
    end
    self:insert(player, EVENT_TYPES.TransferOut, coin, specialCoin, recipient, note)
    self:insert(recipient, EVENT_TYPES.TransferIn, coin, specialCoin, player:getUsername(), note)
end

---@type ServerAccaunting
local serverAccaunting = nil

local function initGlobalModData(isNewGame)
    local modData = ModData.getOrCreate(MOD_NAME);     
    local cleaned = cleanOldRecords(modData) -- Очищаем старые записи при инициализации
    if cleaned then
        ModData.add(MOD_NAME, modData)
    end
    serverAccaunting = ServerAccaunting:new(modData)
	ModData.transmit(MOD_NAME)
end
Events.OnInitGlobalModData.Add(initGlobalModData);



base_BServer.CreateAccount = BServer.CreateAccount
---@param player IsoPlayer
function BServer.CreateAccount(player, args) -- Создание аккаунта, привязка кошелька
    base_BServer.CreateAccount(player, args)
    serverAccaunting:CreateAccount(player)
end

base_BServer.Deposit = BServer.Deposit
function BServer.Deposit(player, args) -- Продажа в скупку, перевод на счёт
    base_BServer.Deposit(player, args)
    serverAccaunting:Deposit(player, args)
end

base_BServer.Transfer = BServer.Transfer
function BServer.Transfer(player, args)
    base_BServer.Transfer(player, args)
    serverAccaunting:Transfer(player, args)
end


base_BServer.Withdraw = BServer.Withdraw
function BServer.Withdraw(player, args)
    base_BServer.Withdraw(player, args)
    serverAccaunting:Withdraw(player, args)
end