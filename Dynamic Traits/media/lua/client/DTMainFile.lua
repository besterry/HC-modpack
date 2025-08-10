-- OnPlayerUpdate Main Method to call others
function DTOnPlayerUpdateMain(player)
    -- INITIALIZATIONS FOR AN EXISTING CHARACTER
    DTBaseGameCharacterDetails.DoExistingCharacterInitializations(player);
    
    -- MORE TRAITS COMPATIBILITY EVENTS CALL
    if getActivatedMods():contains("DynamicMoreTraits") then
        MTDBaseGameCharacterDetails.DoExistingCharacterInitializations(player);
    end
end
Events.OnPlayerUpdate.Add(DTOnPlayerUpdateMain);

-- EveryOneMinutes Main Method to call others
function DTEveryOneMinuteMain()

    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        if not player then return end
        -- CALL TO OTHER METHODS THAT RUNS BASED ON THE EveryOneMinute EVENT
        traitsGainsByBodyConditions(player);
        traitsByMoods(player);
        traitsByRecipes(player);

        if not player:HasTrait("Dextrous") or not player:HasTrait("Organized") then
            traitsByMovingObjects(player);
        end
        rainTraits(player);

        if player:HasTrait("Agoraphobic") or player:HasTrait("Claustophobic") then
            agoraphobicClaustrophobicTraits(player);
        end

        if not player:HasTrait("NightVision") then
            catsEyes(player);
        end

        if not player:HasTrait("Outdoorsman") then
            outdoorsmanTrait(player);
        end

        -- CALL THE FUNCTIONS IF THE EXPANDED MOODLE IS ACTIVATED
        if getActivatedMods():contains("DynamicTraitsEME") then
            increaseClothingWetnessUnderRain(player);
        end
    end
end
Events.EveryOneMinute.Add(DTEveryOneMinuteMain);

-- EveryTenMinutes Main Method to call others
function DTEveryTenMinutesMain()

    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        if not player then return end
        -- CALL TO OTHER METHODS THAT RUNS BASED ON THE EveryTenMinutes EVENT
        if player:HasTrait("Agoraphobic") or player:HasTrait("Claustophobic") then
            luckyUnluckyEffectsForAgoraClaustroTraits(player);
        end
        if player:HasTrait("Anorexy") then
            anorexyTraitHungerSymptoms(player);
        end
        activeSedentaryTraits(player);
        nightmaresTrait(player);

        -- CALL THE FUNCTIONS IF THE EXPANDED MOODLE IS ACTIVATED
        if getActivatedMods():contains("DynamicTraitsEME") then
            fracturesIfHeavyLoad(player);
            expandedWetnessMoodle(player);
            expandedHasAColdMoodle(player);
            expandedPanicMoodle(player);
            expandedStressMoodle(player);
            expandedSickMoodle(player);
            increaseBodyWetnessByItemWetness(player);
        end

        poisonByOverdose(player);

        if player:HasTrait("Smoker") then
            smokerCough(player);
        end

        -- MORE TRAITS COMPATIBILITY EVENTS CALL
        if getActivatedMods():contains("DynamicMoreTraits") then
            checkPeriodicallyCurrentTraits();
        end
    end
end
Events.EveryTenMinutes.Add(DTEveryTenMinutesMain);

-- EveryHours Main Method to call others
function DTEveryHoursMain()

    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        -- CALL TO OTHER METHODS THAT RUNS BASED ON THE EveryHours EVENT
        if player:HasTrait("Smoker") then
            smokerTrait(player);
        end
        alcoholicTrait(player);
        anorexyTrait(player);
        if player:HasTrait("Anorexy") then
            anorexyTraitPassiveSymptoms(player);
        end
        exerciseMultiplierIfMaxRegularity(player);
        if player:HasTrait("Bloodlust") then
            bloodlustTrait(player);
        end
        if player:getModData().DTisNervousWreck == true then
            nervousWreckTrait(player);
        end
        if player:getModData().DTisMelancholic == true then
            melancholicTrait(player);
        end
        pillsOverdoseDecrease(player);
    end
end
Events.EveryHours.Add(DTEveryHoursMain);

-- OnZombieDead Main Method to call others
function DTOnZombieDeadMain(zombie)

    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        -- CALL TO OTHER METHODS THAT RUNS BASED ON THE OnZombieDead EVENT
        if not player:HasTrait("Desensitized") then
            traitsGainsByKills(player);
        end
        if player:HasTrait("Bloodlust") then
            bloodlustTraitOnZombieKill(player);
        end
    end
end
Events.OnZombieDead.Add(DTOnZombieDeadMain);

-- LevelPerk Main Method to call others
function DTLevelPerkMain(player, perk, perkLevel, addBuffer)

    -- CALL TO OTHER METHODS THAT RUNS BASED ON THE LevelPerk EVENT
    traitsGainsByLevel(player, perk, perkLevel);
    recipesByPerksLevel(player, perk, perkLevel);

    -- MORE TRAITS COMPATIBILITY EVENTS CALL
    if getActivatedMods():contains("DynamicMoreTraits") then
        MTDtraitsGainsByLevel(player, perk, perkLevel);
    end
end
Events.LevelPerk.Add(DTLevelPerkMain);

-- OnWeaponHitTree Main Method to call others
function DTOnWeaponHitTreeMain(player, weapon)

    -- CALL TO OTHER METHODS THAT RUNS BASED ON THE OnWeaponHitTree EVENT
    tweaksToOnHitTree(player, weapon);
end
Events.OnWeaponHitTree.Add(DTOnWeaponHitTreeMain);

-- OnWeaponSwingHitPoint Main Method to call others
function DTOnWeaponSwingHitPointMain(player, weapon)

    -- CALL TO OTHER METHODS THAT RUNS BASED ON THE OnWeaponSwingHitPoint EVENT
    tweaksToSwingWeapon(player, weapon);
end
Events.OnWeaponSwingHitPoint.Add(DTOnWeaponSwingHitPointMain);