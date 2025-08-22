local Infliction = require("injectors/Infliction")

--- @param iso IsoPlayer
function AlterSkill(iso, name, duration, receive)
    --- @type Perk
    local perk = PerkFactory.getPerkFromName(name)

    local oldLvl = iso:getPerkLevel(perk);
    if (receive) then
        iso:LevelPerk(perk);
    else
        iso:LoseLevel(perk);
    end
    local newLvl = iso:getPerkLevel(perk);
    local diff = newLvl - oldLvl;

    local func = LevelSkill;
    if (receive) then
        func = LoseSkill;
    end

    ApplyInflictions(iso,
        Infliction:new(duration, math.abs(diff), func, perk:getName())
    )
end

--- @param iso IsoPlayer
function LevelSkill(iso, name)
    --- @type Perk
    local perk = PerkFactory.getPerkFromName(name)
    iso:LevelPerk(perk);
end

--- @param iso IsoPlayer
function LoseSkill(iso, name)
    --- @type Perk
    local perk = PerkFactory.getPerkFromName(name)
    iso:LoseLevel(perk);
end