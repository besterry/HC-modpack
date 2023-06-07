require("TimedActions/ISTakePillAction")

NFTakePillsAction = ISTakePillAction:derive("NFTakePillsAction")

function NFTakePillsAction:perform()
    self.item:getContainer():setDrawDirty(true)
    self.item:setJobDelta(0.0)
    for _ = 1, self.count do
        self.character:getBodyDamage():JustTookPill(self.item)
    end

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function NFTakePillsAction:new (character, item, count)
    local o = ISTakePillAction:new(character, item, 165)
    setmetatable(o, self)
    self.__index = self
    o.count = count
    o.maxTime = o.maxTime + 5 * (count - 1)
    return o
end
