ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}

local MOD_NAME = ETOMARAT.PlayerAccounting.MOD_NAME

---@return AccountingTotal
local getTotal = function ()
    local username = getPlayer():getUsername()
    return ModData.get("CoinBalance")[username]
end


local PlayerAccountingClient = {}

function PlayerAccountingClient.Insert(args)
    -- print("PlayerAccountingClient.Insert")
    -- local username = getPlayer():getUsername()
    ModData.get(MOD_NAME)[args.username] = args.table
    local log = args
    if #log > 0 then
        triggerEvent('onPlayerAccountingChange')
    end
end

local function PlayerAccounting_OnServerCommand(module, command, args)
    -- print("PlayerAccounting_OnServerCommand", module, command, args)
    if module== "PlayerAccounting" and PlayerAccountingClient[command] then
        PlayerAccountingClient[command](args)
    end
end
Events.OnServerCommand.Add(PlayerAccounting_OnServerCommand)

---@return modDataEntry[]
local getLog = function ()
    local username = getPlayer():getUsername()
    return ModData.get(MOD_NAME)[username]
end

local initGlobalModData = function (isNewGame)    
    if ModData.exists(MOD_NAME) then
        ModData.remove(MOD_NAME);
    end
	ModData.request(MOD_NAME)
end
Events.OnInitGlobalModData.Add(initGlobalModData);

local onReceiveGlobalModData = function(tableName, data)
	if tableName == MOD_NAME then
        local username = getPlayer():getUsername()
        local log = data[username]
        if log and #log > 0 then
            triggerEvent('onPlayerAccountingChange')
        end
    end
end
Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData);

return {
    getTotal = getTotal,
    getLog = getLog
}