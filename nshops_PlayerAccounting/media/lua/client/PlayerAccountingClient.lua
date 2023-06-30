ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}

local MOD_NAME = ETOMARAT.PlayerAccounting.MOD_NAME
local log = {}

-- local username = getPlayer():getUsername()

-- ---@class Accounting
-- local Accounting = {}

-- ---@param username string
-- function Accounting:new(username)
-- 	local o = {}
-- 	setmetatable(o, self)
-- 	self.__index = self
--     o.username = username
--     o.log = nil
--     return o
-- end

-- ---@param log table
-- function Accounting:setLog(log)
--     self.log = log
-- end

-- local accountingInst = Accounting:new(username)

---@return AccountingTotal
local getTotal = function ()
    local username = getPlayer():getUsername()
    return ModData.get("CoinBalance")[username]
end

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
    -- local modData = ModData.getOrCreate(MOD_NAME);
    -- local username = getPlayer():getUsername()
    -- log = modData[username]
    -- print('log1', bcUtils.dump(log))
    -- accountingInst:setLog(log)
end

Events.OnInitGlobalModData.Add(initGlobalModData);

local onReceiveGlobalModData = function(tableName, data)
	if tableName == MOD_NAME then
        local username = getPlayer():getUsername()
        log = data[username]
        -- print('log2',  bcUtils.dump(log))
        -- accountingInst:setLog(log)
    end
end

Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData);

return {
    getTotal = getTotal,
    getLog = getLog
}