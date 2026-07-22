if isClient() then
    return
end

if not getT15KKillboardInstance then
    require "shared/T15KKillboardUtils"
end

local T15KKillboard = getT15KKillboardInstance()

local pairs = pairs
local table = table

local function playerIsAdmin(player)
    if not player then
        return false
    end
    local lvl = player:getAccessLevel()
    return lvl == "Admin" or lvl == "admin"
end

-- любой staff кроме None (для исключения из топа)
local function playerIsStaff(player)
    if not player then
        return false
    end
    local lvl = player:getAccessLevel()
    if not lvl or lvl == "" then
        return false
    end
    lvl = string.lower(tostring(lvl))
    return lvl ~= "none"
end

local function shouldCountInRanking(player)
    if T15KKillboard.getSandboxVar("CountAdmins") then
        return true
    end
    return not playerIsStaff(player)
end

local function newStore()
    return {
        monthKey = T15KKillboard.getMonthKey(),
        lastKnown = {},
        monthly = {},
        allTime = {},
        liveCurrentKills = true,
        unclaimedRewards = {},
        pendingAnnounce = nil,
    }
end

local function isLegacyStore(raw)
    if type(raw) ~= "table" or raw.monthKey ~= nil then
        return false
    end
    for _, data in pairs(raw) do
        if type(data) == "table" and type(data[1]) == "number" then
            return true
        end
    end
    return false
end

local function ensureStore()
    local md = getGameTime():getModData()
    local raw = md.T15KKillboard

    if raw == nil then
        md.T15KKillboard = newStore()
        return md.T15KKillboard
    end

    if isLegacyStore(raw) then
        local migrated = newStore()
        -- старый формат был "текущие убийства персонажа" в плоской таблице
        for username, data in pairs(raw) do
            if type(data) == "table" and type(data[1]) == "number" then
                migrated.allTime[username] = { data[1], data[2] or 0, data[3] or getTimestamp() }
                migrated.lastKnown[username] = data[1]
            end
        end
        md.T15KKillboard = migrated
        return migrated
    end

    raw.lastKnown = raw.lastKnown or {}
    raw.monthly = raw.monthly or {}
    raw.allTime = raw.allTime or {}
    raw.unclaimedRewards = raw.unclaimedRewards or {}
    raw.monthKey = raw.monthKey or T15KKillboard.getMonthKey()
    -- переход с накопленного all-time на текущие getZombieKills
    if not raw.liveCurrentKills then
        raw.allTime = {}
        raw.liveCurrentKills = true
    end
    return raw
end

local function prepareRankTable(dirtyTable)
    local maxPlayers = T15KKillboard.getSandboxVar("PlayersPerPage") or 30
    local minKills = T15KKillboard.getSandboxVar("MinKills") or 0
    local preparedTable = {}

    for username, data in pairs(dirtyTable or {}) do
        local kills = data[1] or 0
        if kills >= minKills then
            if #preparedTable > 0 then
                for i = 1, #preparedTable do
                    if kills <= preparedTable[#preparedTable - i + 1][2] then
                        table.insert(preparedTable, #preparedTable - i + 2, { username, data[1], data[2], data[3] })
                        break
                    end
                    if i == #preparedTable then
                        table.insert(preparedTable, 1, { username, data[1], data[2], data[3] })
                    end
                end
            else
                preparedTable[1] = { username, data[1], data[2], data[3] }
            end
        end
    end

    for i = maxPlayers + 1, #preparedTable do
        preparedTable[i] = nil
    end

    return preparedTable
end

local function formatWinnerDetail(place, winner)
    if not winner then
        return nil
    end
    local detail = "#" .. tostring(place) .. " " .. tostring(winner.user) .. " (" .. tostring(winner.kills) .. ")"
    if winner.item and winner.item ~= "" then
        detail = detail .. " | " .. tostring(winner.item)
        if winner.count and winner.count > 1 then
            detail = detail .. " x" .. tostring(winner.count)
        end
    end
    return detail
end

-- объявление только когда есть онлайн (рестарт в 00:00 обычно без игроков)
local function tryAnnouncePending(store)
    local pa = store.pendingAnnounce
    if not pa or pa.announced then
        return
    end
    local online = getOnlinePlayers and getOnlinePlayers() or nil
    if not online or online:size() < 1 then
        return
    end

    if Notify and Notify.broadcast then
        Notify.broadcast("IGUI_T15KKillboard_News_Header", {
            color = { 255, 215, 0 },
            params = { v = tostring(pa.monthKey or "") },
        })
        for place = 1, 3 do
            local detail = formatWinnerDetail(place, pa.winners and pa.winners[place])
            if detail then
                Notify.broadcast("IGUI_T15KKillboard_News_Place", {
                    color = { 255, 215, 0 },
                    params = { v = detail },
                })
            end
        end
    end

    if T15KKillboard.isSinglePlayer() then
        triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "monthAnnounce", { monthKey = pa.monthKey })
    else
        sendServerCommand("T15K_Rank_From_Server", "monthAnnounce", { monthKey = pa.monthKey })
    end

    pa.announced = true
end

local function enqueueMonthRewards(store)
    local top = prepareRankTable(store.monthly)
    local rewards = T15KKillboard.copyRewardConfig(T15KKillboard.getRewardConfig())
    store.unclaimedRewards = store.unclaimedRewards or {}

    local winners = {}
    for place = 1, 3 do
        local entry = top[place]
        local conf = rewards[place]
        if entry then
            winners[place] = {
                user = entry[1],
                kills = entry[2],
                item = (conf and conf.item) or "",
                count = (conf and conf.count) or 1,
            }
            if conf and conf.item and conf.item ~= "" then
                table.insert(store.unclaimedRewards, {
                    monthKey = store.monthKey,
                    place = place,
                    user = entry[1],
                    item = conf.item,
                    count = conf.count or 1,
                })
            end
        end
    end

    store.pendingAnnounce = {
        monthKey = store.monthKey,
        winners = winners,
        announced = false,
    }
    -- снимок для UI всем игрокам
    store.lastMonthResults = {
        monthKey = store.monthKey,
        winners = winners,
    }
end

local function rolloverMonthIfNeeded(store)
    local currentKey = T15KKillboard.getMonthKey()
    if store.monthKey == currentKey then
        return false
    end

    if store.monthly and next(store.monthly) ~= nil then
        enqueueMonthRewards(store)
    end

    store.monthly = {}
    store.monthKey = currentKey
    T15KKillboard.applyNextRewardsToSandbox()
    return true
end

-- макс. прирост за один апдейт (защита от stale-пакета после смерти)
local function maxMonthlyDeltaPerUpdate()
    local tick = T15KKillboard.getSandboxVar("ServerTickRate") or 1
    if tick == 1 then
        return 8000 -- ~10 мин
    elseif tick == 2 then
        return 25000 -- ~1 час
    end
    return 100000 -- ~сутки
end

local function applyDelta(store, username, zKills, sKills)
    zKills = tonumber(zKills) or 0
    sKills = tonumber(sKills) or 0
    local ts = getTimestamp()

    -- вкладка "Текущие": абсолютный getZombieKills (сброс при смерти)
    if zKills > 0 then
        store.allTime[username] = { zKills, sKills, ts }
    else
        store.allTime[username] = nil
    end

    local last = store.lastKnown[username]

    -- смерть / ресет: НЕ ставим 0 (иначе stale-пакет со старыми киллами = +весь счётчик в месяц)
    -- следующий апдейт только фиксирует baseline без кредита в monthly
    if last ~= nil and zKills < last then
        store.lastKnown[username] = nil
        return
    end

    if last == nil then
        if zKills > 0 then
            store.lastKnown[username] = zKills
        end
        return
    end

    local delta = zKills - last
    if delta <= 0 then
        store.lastKnown[username] = zKills
        return
    end

    local maxDelta = maxMonthlyDeltaPerUpdate()
    if delta > maxDelta then
        print("[T15KKillboard] suspicious delta ignored for " .. tostring(username)
            .. ": +" .. tostring(delta) .. " (max " .. tostring(maxDelta) .. "), rebaseline")
        store.lastKnown[username] = zKills
        return
    end

    store.lastKnown[username] = zKills

    local monthly = store.monthly[username]
    if monthly then
        monthly[1] = (monthly[1] or 0) + delta
        monthly[2] = sKills
        monthly[3] = ts
    else
        store.monthly[username] = { delta, sKills, ts }
    end
end

local function ensureJsonLib()
    if Json and Json.Encode and Json.Decode then
        return true
    end
    local paths = {
        "mods/PlayerMenu/media/lua/server/Json",
        "server/Json",
    }
    for i = 1, #paths do
        local ok, err = pcall(function()
            require(paths[i])
        end)
        if Json and Json.Encode and Json.Decode then
            return true
        end
        if not ok then
            print("[T15KKillboard] Json require failed (" .. paths[i] .. "): " .. tostring(err))
        end
    end
    return false
end

local function pmLoadUserData(filename)
    if PlayerMenuAPI and PlayerMenuAPI.LoadJsonItems then
        return PlayerMenuAPI.LoadJsonItems(filename)
    end
    if not ensureJsonLib() then
        return nil
    end
    local reader = getFileReader(filename, false)
    if not reader then
        return {
            balance = 0,
            bonus = 0,
            safehouse = 625,
            ShopCount = 0,
            MaxShopCount = 5,
            autoloot = 0,
            GarageMaxCount = 1,
        }
    end
    local json = ""
    local line = reader:readLine()
    while line ~= nil do
        json = json .. line
        line = reader:readLine()
    end
    reader:close()
    if json == "" then
        return { balance = 0, bonus = 0, safehouse = 625, ShopCount = 0, MaxShopCount = 5, GarageMaxCount = 1 }
    end
    local ok, data = pcall(function()
        return Json.Decode(json)
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function pmSaveUserData(filename, userData)
    if PlayerMenuAPI and PlayerMenuAPI.SaveJsonItems then
        PlayerMenuAPI.SaveJsonItems(userData, filename)
        return true
    end
    if not ensureJsonLib() then
        return false
    end
    local writer = getFileWriter(filename, true, false)
    if not writer then
        return false
    end
    writer:write(Json.Encode(userData))
    writer:close()
    return true
end

local function ensurePlayerMenuAPI()
    if PlayerMenuAPI and PlayerMenuAPI.LoadJsonItems and PlayerMenuAPI.SaveJsonItems then
        return true
    end
    local paths = {
        "mods/PlayerMenu/media/lua/server/UserDataFromJson",
        "server/UserDataFromJson",
    }
    for i = 1, #paths do
        local ok, err = pcall(function()
            require(paths[i])
        end)
        if PlayerMenuAPI and PlayerMenuAPI.LoadJsonItems and PlayerMenuAPI.SaveJsonItems then
            return true
        end
        if not ok then
            print("[T15KKillboard] PlayerMenu require failed (" .. paths[i] .. "): " .. tostring(err))
        end
    end
    -- достаточно Json + прямой I/O (без API)
    return ensureJsonLib()
end

-- донатная валюта PM: users/<nick>.json → balance
local function givePMBalance(player, amount)
    amount = tonumber(amount) or 0
    if not player or amount < 1 then
        return false
    end
    if not ensurePlayerMenuAPI() then
        print("[T15KKillboard] PlayerMenu/Json unavailable, cannot grant PM.Balance (is PlayerMenu on the server?)")
        return false
    end
    local nickname = player:getUsername()
    local filename = "users/" .. nickname .. ".json"
    local userData = pmLoadUserData(filename)
    if not userData then
        print("[T15KKillboard] failed to load " .. filename)
        return false
    end
    userData.balance = (tonumber(userData.balance) or 0) + amount
    if not pmSaveUserData(filename, userData) then
        print("[T15KKillboard] failed to save " .. filename)
        return false
    end
    if writeLog then
        writeLog("PlayerMenuActions", nickname .. " >T15KKillboard reward balance+" .. tostring(amount) .. "< balance:" .. tostring(userData.balance))
    end
    sendServerCommand(player, "BalanceAndSH", "onGetData", { UserData = userData })
    return true
end

local function giveItemStack(player, fullType, count)
    if not player or not fullType or fullType == "" or count < 1 then
        return false
    end
    local inv = player:getInventory()
    if not inv then
        return false
    end
    if inv.AddItems then
        inv:AddItems(fullType, count)
    else
        for _ = 1, count do
            inv:AddItem(fullType)
        end
    end
    return true
end

local function giveReward(player, fullType, count)
    if T15KKillboard.isPMBalanceReward(fullType) then
        return givePMBalance(player, count)
    end
    return giveItemStack(player, fullType, count)
end

local function getPendingForUser(store, username)
    local out = {}
    for i = 1, #(store.unclaimedRewards or {}) do
        local r = store.unclaimedRewards[i]
        if r and r.user == username then
            table.insert(out, r)
        end
    end
    return out
end

local function sendPendingToPlayer(player)
    if not player then
        return
    end
    local store = ensureStore()
    local pending = getPendingForUser(store, player:getUsername())
    if T15KKillboard.isSinglePlayer() then
        triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "pendingRewards", pending)
    else
        sendServerCommand(player, "T15K_Rank_From_Server", "pendingRewards", pending)
    end
end

local function tryClaimRewards(player)
    if not player then
        return
    end
    local store = ensureStore()
    local queue = store.unclaimedRewards
    if not queue or #queue == 0 then
        sendPendingToPlayer(player)
        return
    end

    local username = player:getUsername()
    local remain = {}
    local granted = {}

    for i = 1, #queue do
        local r = queue[i]
        if r.user == username then
            if giveReward(player, r.item, r.count or 1) then
                table.insert(granted, r)
            else
                table.insert(remain, r)
            end
        else
            table.insert(remain, r)
        end
    end

    store.unclaimedRewards = remain

    if #granted > 0 then
        if T15KKillboard.isSinglePlayer() then
            triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "rewardsGranted", granted)
        else
            sendServerCommand(player, "T15K_Rank_From_Server", "rewardsGranted", granted)
        end
    end
    sendPendingToPlayer(player)
end

local function adminEnqueueTestReward(player)
    if not playerIsAdmin(player) and not (getCore and getCore():getDebug()) then
        return
    end
    local store = ensureStore()
    store.unclaimedRewards = store.unclaimedRewards or {}
    local cfg = T15KKillboard.getRewardConfig()
    local item = (cfg[1] and cfg[1].item ~= "" and cfg[1].item) or "Base.Axe"
    local count = (cfg[1] and cfg[1].count) or 1
    table.insert(store.unclaimedRewards, {
        monthKey = store.monthKey .. "-test",
        place = 1,
        user = player:getUsername(),
        item = item,
        count = count,
    })
    -- не выдаём сразу: игрок жмёт кнопку "Получить"
    sendPendingToPlayer(player)
end

local function buildPayload(store)
    local serverNow = getTimestamp()
    return {
        monthKey = store.monthKey,
        serverNow = serverNow,
        monthEndTs = T15KKillboard.getMonthEndTs(serverNow),
        monthly = prepareRankTable(store.monthly),
        allTime = prepareRankTable(store.allTime),
        rewards = T15KKillboard.copyRewardConfig(T15KKillboard.getRewardConfig()),
        nextRewards = T15KKillboard.copyRewardConfig(T15KKillboard.getNextRewardConfig()),
        lastMonthResults = store.lastMonthResults,
    }
end

local function broadcastRankTable(payload)
    if T15KKillboard.isSinglePlayer() then
        triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "true", payload)
        return
    end
    local online = getOnlinePlayers and getOnlinePlayers() or nil
    if not online or online:size() < 1 then
        return
    end
    local ok, err = pcall(function()
        sendServerCommand("T15K_Rank_From_Server", "true", payload)
    end)
    if not ok then
        print("[T15KKillboard] broadcastRankTable failed: " .. tostring(err))
    end
end

local function serverUpdateT15KRankTable()
    local store = ensureStore()
    rolloverMonthIfNeeded(store)
    tryAnnouncePending(store)
    broadcastRankTable(buildPayload(store))
end

local function OnClientCommandT15KRank(module, command, player, args)
    if module ~= "T15KKillboardModule" then
        return
    end

    local store = ensureStore()
    rolloverMonthIfNeeded(store)
    tryAnnouncePending(store)

    if command == "playerRemove" then
        if not playerIsAdmin(player) and not (getCore and getCore():getDebug()) then
            return
        end
        local user = args[1]
        store.monthly[user] = nil
        store.allTime[user] = nil
        store.lastKnown[user] = nil
        serverUpdateT15KRankTable()
    elseif command == "adjustMonthly" then
        if not playerIsAdmin(player) and not (getCore and getCore():getDebug()) then
            return
        end
        local user = args and args[1]
        local amount = tonumber(args and args[2]) or 0
        if not user or user == "" or amount == 0 then
            return
        end
        amount = math.floor(amount)
        local entry = store.monthly[user]
        local before = 0
        if entry then
            before = entry[1] or 0
        end
        local after = before + amount
        if after <= 0 then
            store.monthly[user] = nil
            after = 0
        else
            if entry then
                entry[1] = after
                entry[3] = getTimestamp()
            else
                store.monthly[user] = { after, 0, getTimestamp() }
            end
        end
        print("[T15KKillboard] adjustMonthly " .. tostring(user) .. ": " .. tostring(before) .. " -> " .. tostring(after)
            .. " (" .. tostring(amount) .. ") by " .. tostring(player:getUsername()))
        if writeLog then
            writeLog("T15KKillboard", player:getUsername() .. " adjustMonthly " .. user .. " " .. before .. "->" .. after .. " (" .. amount .. ")")
        end
        serverUpdateT15KRankTable()
    elseif command == "clearKillboard" then
        if not playerIsAdmin(player) and not (getCore and getCore():getDebug()) then
            return
        end
        local mode = args and args[1]
        if mode == T15KKillboard.MODE_ALLTIME then
            store.allTime = {}
        elseif mode == T15KKillboard.MODE_MONTHLY then
            store.monthly = {}
        else
            store.monthly = {}
            store.allTime = {}
            store.lastKnown = {}
        end
        serverUpdateT15KRankTable()
    elseif command == "playerUpdate" then
        local username = args[1]
        local zKills = args[2] or 0
        local sKills = args[3] or 0
        if shouldCountInRanking(player) then
            applyDelta(store, username, zKills, sKills)
        else
            store.lastKnown[username] = zKills
            store.allTime[username] = nil
        end
        sendPendingToPlayer(player)
    elseif command == "claimRewards" then
        tryClaimRewards(player)
    elseif command == "requestPending" then
        sendPendingToPlayer(player)
    elseif command == "adminTestReward" then
        adminEnqueueTestReward(player)
    elseif command == "requestRank" then
        -- клиент запросил таблицу (после входа / открытия UI)
        if player then
            local payload = buildPayload(store)
            if T15KKillboard.isSinglePlayer() then
                triggerEvent("OnServerCommand", "T15K_Rank_From_Server", "true", payload)
            else
                pcall(function()
                    sendServerCommand(player, "T15K_Rank_From_Server", "true", payload)
                end)
            end
        end
    end
end

Events.OnClientCommand.Add(OnClientCommandT15KRank)

-- только rollover/announce; broadcast на старте без клиентов роняет MultiLuaJavaInvoker
local function onServerBootCheckMonth()
    if isClient() then
        return
    end
    local store = ensureStore()
    rolloverMonthIfNeeded(store)
    tryAnnouncePending(store)
end

if Events.OnServerStarted then
    Events.OnServerStarted.Add(onServerBootCheckMonth)
end
if Events.OnInitGlobalModData then
    Events.OnInitGlobalModData.Add(onServerBootCheckMonth)
end

local serverUpdateTickRate = T15KKillboard.getSandboxVar("ServerTickRate")

if serverUpdateTickRate == 1 or T15KKillboard.isSinglePlayer() then
    Events.EveryTenMinutes.Add(serverUpdateT15KRankTable)
elseif serverUpdateTickRate == 2 then
    Events.EveryHours.Add(serverUpdateT15KRankTable)
else
    Events.EveryDays.Add(serverUpdateT15KRankTable)
end
