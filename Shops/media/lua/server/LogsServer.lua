if not isServer() then return end
require("DynamicPricing")
local LServer = {}

-- local logfile = "shops_transactions.log"
-- local msg = ""

function LServer.ProcessShopTransaction(player,args)
    local username = args.username
    local coords = args.coords
    local action = args.action
    local items = args.items

    -- Логирование на сервере
    local log = username .." ".. coords.x ..",".. coords.y ..",".. coords.z .." "..action.." ["
    local first = true
    for itemType, quantity in pairs(items) do
        if SandboxVars.Shops.DinamicPrice and action == "Sell" then
            DynamicPricing.onItemSold(itemType, quantity)
        end
        if first then
            first = false
            log = log .. itemType.."="..quantity
        else
            log = log.."," .. itemType.."="..quantity
        end
    end
    log = log.."]"
    writeLog("TransactionShop",log)
end

local function LS_OnClientCommand(module, command, player, args)
    if module == "LS" and LServer[command] then
        LServer[command](player, args)
    end
end

Events.OnClientCommand.Add(LS_OnClientCommand)