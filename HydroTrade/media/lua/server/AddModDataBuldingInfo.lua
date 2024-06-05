local function addModDataToInstance(instance)
    if instance then
        instance.modData["Builder"] = getPlayer():getUsername()
        instance.modData["Date"] = os.date("%d/%m/%Y")
    end
    return instance
end

local function wrapFunction(originalFunction)
    return function(...)
        local result = originalFunction(...)
        return addModDataToInstance(result)
    end
end

local original_ISWoodenWall_new = ISWoodenWall.new
ISWoodenWall.new = wrapFunction(original_ISWoodenWall_new)

local original_ISSimpleFurniture_new = ISSimpleFurniture.new --(name, sprite, northSprite)
ISSimpleFurniture.new = wrapFunction(original_ISSimpleFurniture_new)

local original_ISWoodenStairs_new = ISWoodenStairs.new --(sprite1, sprite2, sprite3, northSprite1, northSprite2, northSprite3, pillar, pillarNorth)
ISWoodenStairs.new = wrapFunction(original_ISWoodenStairs_new)

local original_ISDoubleDoor_new = ISDoubleDoor.new --(sprite, spriteIndex)
ISDoubleDoor.new = wrapFunction(original_ISDoubleDoor_new)

local original_ISWoodenDoor_new = ISWoodenDoor.new --(sprite, northSprite, openSprite, openNorthSprite)
ISWoodenDoor.new = wrapFunction(original_ISWoodenDoor_new)

local original_ISWoodenDoorFrame_new = ISWoodenDoorFrame.new --(sprite, northSprite, corner)
ISWoodenDoorFrame.new = wrapFunction(original_ISWoodenDoorFrame_new)

local original_ISAnvil_new = ISAnvil.new --(name, character, sprite, northSprite)
ISAnvil.new = wrapFunction(original_ISAnvil_new)

local original_ISMetalDrum_new = ISMetalDrum.new --(player, sprite)
ISMetalDrum.new = wrapFunction(original_ISMetalDrum_new)

local original_ISBSFurnace_new = ISBSFurnace.new --(name, sprite, litSprite)
ISBSFurnace.new = wrapFunction(original_ISBSFurnace_new)

local original_ISCompost_new = ISCompost.new --(name, sprite)
ISCompost.new = wrapFunction(original_ISCompost_new)

local original_ISDoubleTileFurniture_new = ISDoubleTileFurniture.new --(name, sprite1, sprite2, northSprite1, northSprite2)
ISDoubleTileFurniture.new = wrapFunction(original_ISDoubleTileFurniture_new)

local original_ISLightSource_new = ISLightSource.new --(sprite, northSprite, player)
ISLightSource.new = wrapFunction(original_ISLightSource_new)

local original_ISWoodenFloor_new = ISWoodenFloor.new --(sprite, northSprite)
ISWoodenFloor.new = wrapFunction(original_ISWoodenFloor_new)

local original_ISBarbedWire_new = ISBarbedWire.new --(sprite, northSprite)
ISBarbedWire.new = wrapFunction(original_ISBarbedWire_new)

local original_RainCollectorBarrel_new = RainCollectorBarrel.new --(player, sprite, waterMax)
RainCollectorBarrel.new = wrapFunction(original_RainCollectorBarrel_new)

local original_ISWoodenContainer_new = ISWoodenContainer.new --(sprite, northSprite)
ISWoodenContainer.new = wrapFunction(original_ISWoodenContainer_new)

-- local original_WaterPump_new = WaterPump.new --(player, sprite, waterMax) Hydrocraft
-- WaterPump.new = wrapFunction(original_WaterPump_new)

-- local original_Beehive_new = Beehive.new --(sprite, northSprite)
-- Beehive.new = wrapFunction(original_Beehive_new)




-- local original_ISWoodenWall_create = ISWoodenWall.new --(sprite, northSprite, corner)
-- function ISWoodenWall:new(sprite, northSprite, corner)
--     local o = original_ISWoodenWall_create(self, sprite, northSprite, corner)
--     o.modData["Builder"] = getPlayer():getUsername();
--     o.modData["Date"] = os.date("%d/%m/%Y") --День/Месяц/Год
--     return o
-- end