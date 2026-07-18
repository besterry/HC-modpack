if not isClient() then return end

local BClient = {}

function BClient.OnReceiveGlobalModData(key, modData) -- получаем глобальные данные
    if not modData then return end
    ModData.remove(key)
    ModData.add(key, modData)
end
Events.OnReceiveGlobalModData.Add(BClient.OnReceiveGlobalModData)

function BClient.OnConnected() -- получаем данные баланса при подключении игрока
	ModData.request("CoinBalance")
end

function BClient.CreateAccount(args) -- получаем данные баланса при создании аккаунта
    -- print("BClient.CreateAccount")
    local player = getPlayer()
    if not player then return end
    local username = player:getUsername()
    ModData.get("CoinBalance")[username] = args.account
end

function BClient.ChangeBalance(args) -- меняем баланс текущего игрока
    -- print("BClient.ChangeBalance")
    local player = getPlayer()
    if not player then return end
    local coin = args.coin
    local specialCoin = args.specialCoin
    local account = BClientGetAccount(player)
    if not account then return end
    account.coin = coin
    account.specialCoin = specialCoin
end

function BClient.TransferReceived(noti) -- получаем средства от другого игрока
    local player = getPlayer()
    if not player then return end
    local sender = noti.sender
    local coinAmt = tonumber(noti.coin) or 0
    local specialAmt = tonumber(noti.specialCoin) or 0
    local account = BClientGetAccount(player)
    if not account then return end
    account.coin = account.coin + coinAmt
    account.specialCoin = account.specialCoin + specialAmt

    local msg
    local showSpecial = Currency.UseSpecialCoin and specialAmt > 0
    local showCoin = coinAmt > 0
    if showCoin and showSpecial then
        msg = getText("IGUI_Balance_TransferReceivedSpecial", sender, Currency.format(coinAmt), Currency.format(specialAmt))
    elseif showSpecial then
        msg = getText("IGUI_Balance_TransferReceivedEvent", sender, Currency.format(specialAmt))
    else
        msg = getText("IGUI_Balance_TransferReceived", sender, Currency.format(coinAmt))
    end
    if noti.message and noti.message ~= "" then
        msg = msg .. " | " .. tostring(noti.message)
    end
    player:playSound("Notification")
    player:setHaloNote(msg, 255, 255, 255, 400)
end

local function BS_OnServerCommand(module, command, args)
    if module== "BS" and BClient[command] then
        BClient[command](args)
    end
end

function BClientGetAccount(player) -- получаем данные баланса текущего игрока
    local username = player:getUsername()
    return ModData.get("CoinBalance")[username]
end

Events.OnServerCommand.Add(BS_OnServerCommand)
Events.OnConnected.Add(BClient.OnConnected)