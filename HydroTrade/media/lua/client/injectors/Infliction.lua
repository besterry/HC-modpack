local Infliction = {}
Infliction.__index = Infliction

local function getFunctionName(func)
    for key, value in pairs(_G) do
        if value == func and type(value) == "function" then
            return key
        end
    end
    return nil
end

function Infliction:new(delay, duration, func, ...)
    local name = getFunctionName(func)
    local obj = {
        func = name or function(entity) end,
        delay = delay or 0,
        duration = duration or 0,
        args = {...}
    }
    setmetatable(obj, self)
    return obj
end

-- At first this function was included in the Infliction class itself.
-- Modifying plain tables to resemble classes seems too costly in the long run.
function ApplyEffect(infliction, player)
    local func = _G[infliction.func]
    if func and type(func) == "function" then
        func(player, unpack(infliction.args))
    end
end

return Infliction