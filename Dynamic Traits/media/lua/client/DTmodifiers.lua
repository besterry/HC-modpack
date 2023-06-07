function DTincreasePoison(player, chance, poison)
    print("DT Logger: running DTincreasePoison function");
    local currentFoodPoison = player:getBodyDamage():getFoodSicknessLevel();
    if chance == 0 then
        player:playEmote("dtpoisonvomit");
        if player:HasTrait("WeakStomach") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.3));
        elseif player:HasTrait("WeakStomach") and player:HasTrait("ProneToIllness") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.5));
        elseif player:HasTrait("WeakStomach") and player:HasTrait("Resilient") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.1));
        elseif player:HasTrait("ProneToIllness") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.2));
        elseif player:HasTrait("ProneToIllness") and player:HasTrait("IronGut") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.9));
        elseif player:HasTrait("IronGut") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.7));
        elseif player:HasTrait("IronGut") and player:HasTrait("Resilient") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.5));
        elseif player:HasTrait("Resilient") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.8));
        else
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + poison);
        end
        if player:getBodyDamage():getFoodSicknessLevel() > 99 then
            player:getBodyDamage():setFoodSicknessLevel(99);
        end
    end
end

function DTincreasePoisonByWounds(player, chance, poison)
    print("DT Logger: running DTincreasePoisonByWounds function");
    local currentFoodPoison = player:getBodyDamage():getFoodSicknessLevel();
    if chance == 0 then
        player:playEmote("dtpoisonvomit");
        if player:HasTrait("Thinskinned") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.2));
        elseif player:HasTrait("Thinskinned") and player:HasTrait("ProneToIllness") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.5));
        elseif player:HasTrait("ProneToIllness") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 1.3));
        elseif player:HasTrait("ThickSkinned") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.8));
        elseif player:HasTrait("ThickSkinned") and player:HasTrait("Resilient") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.5));
        elseif player:HasTrait("Resilient") then
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + (poison * 0.7));
        else
            player:getBodyDamage():setFoodSicknessLevel(currentFoodPoison + poison);
        end
        if player:getBodyDamage():getFoodSicknessLevel() > 99 then
            player:getBodyDamage():setFoodSicknessLevel(99);
        end
    end
end

function DTincreaseStress(player, stress)
    print("DT Logger: running DTincreaseStress function");
    local currentStress = player:getStats():getStress();
    if player:HasTrait("NervousWreck") then
        player:getStats():setStress(currentStress + (stress * 1.3));
    else
        player:getStats():setStress(currentStress + stress);
    end
    if player:getStats():getStress() > 0.99 then
        player:getStats():setStress(0.99);
    end
end

function DTdecreaseStress(player, stress)
    print("DT Logger: running DTdecreaseStress function");
    local currentStress = player:getStats():getStress();
    player:getStats():setStress(currentStress - stress);
    if player:getStats():getStress() < 0 then
        player:getStats():setStress(0);
    end
end

function DTdecreaseStressFromCigarettes(player, stress)
    print("DT Logger: running DTdecreaseStressFromCigarettes function");
    local currentStressByCigarettes = player:getStats():getStressFromCigarettes();
    player:getStats():setStressFromCigarettes(currentStressByCigarettes - stress);
    if player:getStats():getStressFromCigarettes() < 0 then
        player:getStats():setStressFromCigarettes(0);
    end
end

function DTincreaseUnhappyness(player, unhappyness)
    print("DT Logger: running DTincreaseUnhappyness function");
    local currentUnhappyness = player:getBodyDamage():getUnhappynessLevel();
    if player:HasTrait("Melancholic") then
        player:getBodyDamage():setUnhappynessLevel(currentUnhappyness + (unhappyness * 1.3));
    else
        player:getBodyDamage():setUnhappynessLevel(currentUnhappyness + unhappyness);
    end
    if player:getBodyDamage():getUnhappynessLevel() > 99 then
        player:getBodyDamage():setUnhappynessLevel(99);
    end
end

function DTdecreaseUnhappyness(player, unhappyness)
    print("DT Logger: running DTdecreaseUnhappyness function");
    local currentUnhappyness = player:getBodyDamage():getUnhappynessLevel();
    player:getBodyDamage():setUnhappynessLevel(currentUnhappyness - unhappyness);
    if player:getBodyDamage():getUnhappynessLevel() < 0 then
        player:getBodyDamage():setUnhappynessLevel(0);
    end
end

function DTincreaseBoredom(player, boredom)
    print("DT Logger: running DTincreaseBoredom function");
    local currentBoredom = player:getBodyDamage():getBoredomLevel();
    player:getBodyDamage():setBoredomLevel(currentBoredom + 15);
    if player:getBodyDamage():getBoredomLevel() > 99 then
        player:getBodyDamage():setBoredomLevel(99);
    end
end

function DTdecreaseBoredom(player, boredom)
    print("DT Logger: running DTdecreaseBoredom function");
    local currentBoredom = player:getBodyDamage():getBoredomLevel();
    player:getBodyDamage():setBoredomLevel(currentBoredom - 5);
    if player:getBodyDamage():getBoredomLevel() < 0 then
        player:getBodyDamage():setBoredomLevel(0);
    end
end

function DTincreaseFatigue(player, chance, fatigue)
    print("DT Logger: running DTincreaseFatigue function");
    if chance == 0 then
        local currentFatigue = player:getStats():getFatigue();
        player:getStats():setFatigue(currentFatigue + fatigue);
        if player:getStats():getFatigue() > 0.99 then
            player:getStats():setFatigue(0.99);
        end
    end
end

function DTdecreaseEndurance(player, chance, endurance)
    print("DT Logger: running DTdecreaseEndurance function");
    if chance == 0 then
        local currentEndurance = player:getStats():getEndurance();
        player:getStats():setEndurance(currentEndurance - endurance);
        if player:getStats():getEndurance() < 0 then
            player:getStats():setEndurance(0);
        end
    end
end

function DTluckyUnluckyModifier(player, randomRange)
    print("DT Logger: running DTluckyUnluckyModifier function");
    if player:HasTrait("Lucky") then
        return ZombRand(randomRange)
    elseif player:HasTrait("Unlucky") then
        return (ZombRand(randomRange) * -1)
    else
        return 0
    end
end

function DTapplyPain(player, chance, bodyPart, pain)
    print("DT Logger: running DTapplyPain function");
    if chance == 0 then
        local bodyPartAux = BodyPartType.FromString(bodyPart);
        local playerBodyPart = player:getBodyDamage():getBodyPart(bodyPartAux);
        local currentPain = playerBodyPart:getPain();
        playerBodyPart:setAdditionalPain(currentPain + pain);
        if playerBodyPart:getPain() > 99 then
            playerBodyPart:setAdditionalPain(99);
        end
    end
end

function DTrandomNumberForKills(player, range)
    print("DT Logger: running DTrandomNumberForKills function");
    local randNum = ZombRand(range - player:getZombieKills() - player:getHoursSurvived() + (DTluckyUnluckyModifier(player, (range / 10)) * -1));
    if randNum < 0 then
        randNum = 0;
    end
    return randNum;
end

function DTincreaseWetness(player, wetness)
    print("DT Logger: running DTincreaseWetness function");
    local currentWetness = player:getBodyDamage():getWetness();
    player:getBodyDamage():setWetness(currentWetness + wetness);
    if player:getBodyDamage():getWetness() > 99 then
        player:getBodyDamage():setWetness(99);
    end
end

function applyXPBoost(player, perk, boostLevel)
    print("DT Logger: running applyXPBoost function");
    local currentXPBoost = player:getXp():getPerkBoost(perk);
    local newBoost = currentXPBoost + boostLevel;
    if newBoost > 3 then
        player:getXp():setPerkBoost(perk, 3);
    else
        player:getXp():setPerkBoost(perk, newBoost);
    end
end

function generateACold(player, baseRange, coldStrength)
    print("DT Logger: running generateACold function");
    local currentColdStrength = player:getBodyDamage():getColdStrength();
    local auxRange = baseRange;
    -- Increases the range if Outdoorsman is present
    if player:HasTrait("Outdoorsman") then
        auxRange = auxRange * 1.3;
    end
    -- Increases the range if Resilient is present
    if player:HasTrait("Resilient") then
        auxRange = auxRange * 1.5;
    -- Decreases the range if ProneToIllness is present
    elseif player:HasTrait("ProneToIllness") then
        auxRange = auxRange * 0.5;
    end
    local range = auxRange - player:getModData().DTgenerateAColdChance;
    if range < 0 then
        range = 0;
    end
    if ZombRand(range) == 0 then
        player:getBodyDamage():setHasACold(true);
        player:getBodyDamage():setColdStrength(currentColdStrength + coldStrength);
        player:getModData().DTgenerateAColdChance = 0;
    end
end

function DTincreaseItemWetness(item, rainIntensity, windIntensity, extraValue)
    print("DT Logger: running DTincreaseItemWetness function");
    local currentWetness = item:getWetness();
    local waterResistance = item:getWaterResistance();
    local newWetness = currentWetness + rainIntensity + windIntensity + extraValue - waterResistance;
    if newWetness >= 99 then
        item:setWetness(99);
    else
        item:setWetness(newWetness);
    end
end