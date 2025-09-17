if not isServer() then return end

BServer = {}

local logfile = "timestamp_economy.log"
local msg = ""
require("CoinB")


function BServer.OnInitGlobalModData()
    ModData.getOrCreate("CoinBalance")
end
Events.OnInitGlobalModData.Add(BServer.OnInitGlobalModData)

function BServer.writeLog(msg)
    if Valhalla and Valhalla.Commands then
        local args = {file = logfile, line = msg}
        Valhalla.Commands.writeToLog(nil, args)
        return
    end
    --print(msg)
    writeLog("Balance",msg)
end

function BServer.CreateAccount(player,args)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    if account then -- если уже есть аккаунт, то связываем его с новым кошельком
        account.linkedTo = args[1]
        msg= "Link: %s linked new wallet: %s"
        msg = string.format(msg,username,args[1])
        BServer.writeLog(msg)
    else
        ModData.get("CoinBalance")[username] = {coin = 0, specialCoin = 0, linkedTo = args[1]}
        msg= "NewAccount: %s, Coin: 0 SpecialCoin: 0"
        msg = string.format(msg,username,args[1])
        BServer.writeLog(msg)
        ModData.transmit("CoinBalance")
    end
    local account = ModData.get("CoinBalance")[username]
    sendServerCommand(player, "BS", "CreateAccount", {account = account})
    -- ModData.transmit("CoinBalance")
end

function BServer.Deposit(player, args)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    if not account then return end
    account.coin = account.coin + args[1]
    account.specialCoin = account.specialCoin + args[2]

    msg = "%s Deposit: Coins: %s Special: %s [oldBalance: Coin: %s SpecialCoin: %s -> newBalance: Coin: %s SpecialCoin: %s]"
    msg = string.format(msg, username, account.coin-(account.coin - args[1]) , account.specialCoin-(account.specialCoin - args[2]) , account.coin - args[1], account.specialCoin - args[2], account.coin, account.specialCoin)
    BServer.writeLog(msg)

    -- ModData.transmit("CoinBalance")
    -- print("BServer.Deposit")
    sendServerCommand(player, "BS", "ChangeBalance", {coin = account.coin, specialCoin = account.specialCoin })
    SaveCoinBalancefd()    
end

function BServer.Transfer(player,args)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    local recipientAccount = ModData.get("CoinBalance")[args[3]]
    if not account or not recipientAccount then return end
    account.coin = account.coin-args[1]
    account.specialCoin = account.specialCoin-args[2]
    recipientAccount.coin = recipientAccount.coin+args[1]
    recipientAccount.specialCoin = recipientAccount.specialCoin+args[2]

    msg = "Transfer: %s -> %s  Coin:%s Special:%s [Sender: %s oldBalance: Coin: %s SpecialCoin %s -> newBalance: Coin: %s SpecialCoin %s Recipient: %s oldBalance: Coin: %s SpecialCoin %s -> newBalance: Coin: %s SpecialCoin %s]"
    msg = string.format(msg,username,args[3],account.coin-account.coin+args[1],account.specialCoin-account.specialCoin+args[2],username,account.coin+args[1],account.specialCoin+args[2],account.coin,account.specialCoin,
    args[3],recipientAccount.coin-args[1],recipientAccount.specialCoin-args[2],recipientAccount.coin,recipientAccount.specialCoin)
    BServer.writeLog(msg)
    SaveCoinBalancefd()

    -- print("BServer.Transfer")
    sendServerCommand(player, "BS", "ChangeBalance", {coin = account.coin, specialCoin = account.specialCoin }) -- списываем средства у отправителя
    -- ModData.transmit("CoinBalance")
    local noti = { 
        sender = username,
        coin = args[1],
        specialCoin = args[2],
    }

    local players = getOnlinePlayers()
    local playersSize = players:size()
    if not playersSize then return end
    for i = 0, playersSize - 1, 1 do
        local playerRecipient = players:get(i)
        if playerRecipient:getUsername() == args[3] then
            sendServerCommand(playerRecipient, "BS", "TransferReceived", noti)
            break;
        end
    end
end

function BServer.Withdraw(player,args)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    if not account then return end
    if account.coin >= args[1] then
        account.coin = account.coin-args[1]
    end
    if account.specialCoin >= args[2] then
        account.specialCoin = account.specialCoin-args[2]
    end

    msg = "%s Withdraw: Coin %s Special %s [oldBalance: Coin: %s SpecialCoin %s -> newBalance: Coin: %s SpecialCoin %s]"
    msg = string.format(msg,username,account.coin+args[1]-account.coin,account.specialCoin+args[2]-account.specialCoin,account.coin+args[1],account.specialCoin+args[2],account.coin,account.specialCoin)
    BServer.writeLog(msg)
    SaveCoinBalancefd()

    -- ModData.transmit("CoinBalance")
    sendServerCommand(player, "BS", "ChangeBalance", {coin = account.coin, specialCoin = account.specialCoin })
end

-- Списание средств по имени аккаунта (для операций магазина от имени владельца)
function BServer.WithdrawByName(player,args)
    local username = args[1]
    local coin = args[2] or 0
    local specialCoin = args[3] or 0
    local account = ModData.get("CoinBalance")[username]
    if not account then return end
    if account.coin >= coin then
        account.coin = account.coin-coin
    else
        coin = account.coin
        account.coin = 0
    end
    if account.specialCoin >= specialCoin then
        account.specialCoin = account.specialCoin-specialCoin
    else
        specialCoin = account.specialCoin
        account.specialCoin = 0
    end
    msg = "%s WithdrawByName: Coin %s Special %s [newBalance: Coin: %s SpecialCoin %s]"
    msg = string.format(msg,username,coin,specialCoin,account.coin,account.specialCoin)
    BServer.writeLog(msg)
    SaveCoinBalancefd()
    -- обновим баланс, если владелец онлайн
    local players = getOnlinePlayers()
    local playersSize = players:size()
    for i = 0, playersSize - 1, 1 do
        local p = players:get(i)
        if p:getUsername() == username then
            sendServerCommand(p, "BS", "ChangeBalance", {coin = account.coin, specialCoin = account.specialCoin })
            break
        end
    end
end

-- Зачисление средств по имени аккаунта (для операций магазина от имени владельца)
function BServer.DepositByName(player,args)
    local username = args[1]
    local coin = args[2] or 0
    local specialCoin = args[3] or 0
    local account = ModData.get("CoinBalance")[username]
    if not account then return end
    account.coin = account.coin + coin
    account.specialCoin = account.specialCoin + specialCoin
    msg = "%s DepositByName: Coin %s Special %s [newBalance: Coin: %s SpecialCoin %s]"
    msg = string.format(msg,username,coin,specialCoin,account.coin,account.specialCoin)
    BServer.writeLog(msg)
    SaveCoinBalancefd()
    local players = getOnlinePlayers()
    local playersSize = players:size()
    for i = 0, playersSize - 1, 1 do
        local p = players:get(i)
        if p:getUsername() == username then
            sendServerCommand(p, "BS", "ChangeBalance", {coin = account.coin, specialCoin = account.specialCoin })
            break
        end
    end
end
local function BS_OnClientCommand(module, command, player, args)
    if module == "BS" and BServer[command] then
        BServer[command](player, args)
    end
end

Events.OnClientCommand.Add(BS_OnClientCommand)