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
    local coin = Currency.format(noti.coin)
    local specialCoin = Currency.format(noti.specialCoin)
    local account = BClientGetAccount(player)
    if not account then return end
    account.coin = account.coin + noti.coin
    account.specialCoin = account.specialCoin + noti.specialCoin

    local msg = getText("IGUI_Balance_TransferReceivedSpecial",sender,coin,specialCoin)
    if not Currency.UseSpecialCoin then
        msg = getText("IGUI_Balance_TransferReceived",sender,coin)
    end
    player:playSound("Notification")
    player:setHaloNote(msg, 255,255,255,400);
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