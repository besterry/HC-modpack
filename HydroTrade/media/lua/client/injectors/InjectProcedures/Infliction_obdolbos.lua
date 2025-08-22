--- This function is unique and requires it's own handler with some separate logic.
--- A good example of a non-config injector.

local function rollInfliction(chance, player, ...)
    if ZombRand(100) < chance then
        ApplyInflictions(player, ...)
    end
end

local Infliction = require("injectors/Infliction")
--- @param player IsoPlayer
function Obdolbos_OnInject(_, player, _)
    local positiveEffects = {
        {chance = 25,
            inflictions = {Infliction:new(1, 2, AlterSkill, Perks.Fitness:getName(), 600, true)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 2, AlterSkill, Perks.Strength:getName(), 600, true)}
        },
        {
            chance = 25,
            inflictions = {
                Infliction:new(1, 2, AlterSkill, Perks.Woodwork:getName(),     300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Cooking:getName(),      300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Farming:getName(),      300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Doctor:getName(),       300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Electricity:getName(),  300, true),
                Infliction:new(1, 2, AlterSkill, Perks.MetalWelding:getName(), 300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Mechanics:getName(),    300, true),
                Infliction:new(1, 2, AlterSkill, Perks.Tailoring:getName(),    300, true),
            }
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 2, AlterSkill, Perks.Nimble:getName(), 600, true)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 2, AlterSkill, Perks.Maintenance:getName(), 600, true)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 1, AlterEndurance, 20)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 600, AlterHealth, 0.1)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 600, AlterEndurance, 0.5)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(1, 1, AlterWeightCap, 5)}
        },
    }
    for _, effect in ipairs(positiveEffects) do
        rollInfliction(effect.chance, player, unpack(effect.inflictions))
    end

    local negativeEffects = {
        {
            chance = 25,
            inflictions = {Infliction:new(5, 1, MultiplyLimbDamage, 20)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(5, 600, Tremor, 15)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(5, 600, AlterHunger, 0.06)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(5, 600, AlterThirst, 0.06)}
        },
        {
            chance = 25,
            inflictions = {Infliction:new(5, 5, AlterHealth, -100)} --- :3
        },
    }
    for _, effect in ipairs(negativeEffects) do
        rollInfliction(effect.chance, player, unpack(effect.inflictions))
    end
end