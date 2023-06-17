-- Traits gains based on body conditions are going to be handled in this function.
function traitsGainsByBodyConditions(player)
    --print("DT Logger: running traitsGainsByBodyConditions function");
    --------------- TRAITS APPLIED/REMOVED FOR "EMACIATED" ---------------
    if player:HasTrait("Emaciated") then
        --
    --------------- TRAITS APPLIED/REMOVED FOR "VERY UNDERWEIGHT" ---------------
    elseif player:HasTrait("Very Underweight") then
        -- Removing Traits
        if player:HasTrait("Flimsy") then
            player:getTraits():remove("Flimsy");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Flimsy"), false, HaloTextHelper.getColorGreen());
            player:LevelPerk(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
        end
        -- Gaining Traits 
        if not player:HasTrait("Frail") then
            player:getTraits():add("Frail");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Frail"), true, HaloTextHelper.getColorRed());
            player:LoseLevel(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
            player:LoseLevel(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
        end
        if not player:HasTrait("Thinskinned") then
            player:getTraits():add("Thinskinned");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_ThinSkinned"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("Asthmatic") then
            player:getTraits():add("Asthmatic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("SlowHealer") then
            player:getTraits():add("SlowHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("ProneToIllness") then
            player:getTraits():add("ProneToIllness");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_pronetoillness"), true, HaloTextHelper.getColorRed());
        end

    --------------- TRAITS APPLIED/REMOVED FOR "UNDERWEIGHT" ---------------
    elseif player:HasTrait("Underweight") then
        -- Removing Traits
        if player:HasTrait("Frail") then
            player:getTraits():remove("Frail");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Frail"), false, HaloTextHelper.getColorGreen());
            player:LevelPerk(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
            player:LevelPerk(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
        end
        if player:HasTrait("Thinskinned") then
            player:getTraits():remove("Thinskinned");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_ThinSkinned"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("Asthmatic") then
            player:getTraits():remove("Asthmatic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("LightEater") then
            player:getTraits():remove("LightEater");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("LowThirst") then
            player:getTraits():remove("LowThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("NeedsLessSleep") then
            player:getTraits():remove("NeedsLessSleep");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LessSleep"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("ThickSkinned") then
            player:getTraits():remove("ThickSkinned");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("Resilient") then
            player:getTraits():remove("Resilient");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_resilient"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("FastHealer") then
            player:getTraits():remove("FastHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("SlowHealer") and player:getPerkLevel(Perks.Fitness) >= 8 then
            player:getTraits():remove("SlowHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("ProneToIllness") and player:getPerkLevel(Perks.Fitness) >= 9 then
            player:getTraits():remove("ProneToIllness");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_pronetoillness"), false, HaloTextHelper.getColorGreen());
        end
    
        -- Gaining Traits
        if not player:HasTrait("SlowHealer") and player:getPerkLevel(Perks.Fitness) < 8 then
            player:getTraits():add("SlowHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("ProneToIllness") and player:getPerkLevel(Perks.Fitness) < 9 then
            player:getTraits():add("ProneToIllness");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_pronetoillness"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("Flimsy") then
            player:getTraits():add("Flimsy");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Flimsy"), true, HaloTextHelper.getColorRed());
            player:LoseLevel(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
        end

    --------------- TRAITS APPLIED/REMOVED FOR A HEALTHY CHARACTER ---------------
    elseif not player:HasTrait("Emaciated") and not player:HasTrait("Very Underweight") and not player:HasTrait("Underweight") and not player:HasTrait("Overweight") and not player:HasTrait("Obese") then
        -- Removing traits
        if player:HasTrait("Flimsy") then
            player:getTraits():remove("Flimsy");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Flimsy"), false, HaloTextHelper.getColorGreen());
            player:LevelPerk(Perks.Strength);
            player:getXp():setXPToLevel(Perks.Strength, player:getPerkLevel(Perks.Strength));
        end
        if player:HasTrait("ProneToIllness") then
            player:getTraits():remove("ProneToIllness");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_pronetoillness"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("SlowHealer") then
            player:getTraits():remove("SlowHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_SlowHealer"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("HeartyAppitite") and not (player:getMoodles():getMoodleLevel(MoodleType.Stress) >= 3 or player:getMoodles():getMoodleLevel(MoodleType.Unhappy) >= 3) then
            player:getTraits():remove("HeartyAppitite");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("HighThirst") then
            player:getTraits():remove("HighThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("Asthmatic") then
            player:getTraits():remove("Asthmatic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), false, HaloTextHelper.getColorGreen());
        end
        -- Gaining traits
        -- "Light Eater" and "Low Thirst" when having Fitness and Strenght at Lv6 or more.
        if player:getPerkLevel(Perks.Strength) >= 6 and player:getPerkLevel(Perks.Fitness) >= 6 then
            if not player:HasTrait("LightEater") and not (player:getMoodles():getMoodleLevel(MoodleType.Stress) >= 3 or player:getMoodles():getMoodleLevel(MoodleType.Unhappy) >= 3) then
                player:getTraits():add("LightEater");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), true, HaloTextHelper.getColorGreen());
            end
            if not player:HasTrait("LowThirst") then
                player:getTraits():add("LowThirst");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("LightEater") then
                player:getTraits():remove("LightEater");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), false, HaloTextHelper.getColorRed());
            end
            if player:HasTrait("LowThirst") then
                player:getTraits():remove("LowThirst");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), false, HaloTextHelper.getColorRed());
            end
        end
        -- "Thick skinned" when having Strength Lv7 or more
        if player:getPerkLevel(Perks.Strength) >= 7 then
            if not player:HasTrait("ThickSkinned") then
                player:getTraits():add("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("ThickSkinned") then
                player:getTraits():remove("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), false, HaloTextHelper.getColorRed());
            end
        end
        -- "Need Less Sleep" when having a good mood and Fitness Lv7 or more.
        if player:getMoodles():getMoodleLevel(MoodleType.Stress) == 0 and player:getMoodles():getMoodleLevel(MoodleType.Bored) == 0 and player:getMoodles():getMoodleLevel(MoodleType.Unhappy) == 0 and player:getMoodles():getMoodleLevel(MoodleType.Hungry) <= 1 and player:getPerkLevel(Perks.Fitness) >= 7 then
            if not player:HasTrait("NeedsLessSleep") then
                player:getTraits():add("NeedsLessSleep");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LessSleep"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("NeedsLessSleep") then
                player:getTraits():remove("NeedsLessSleep");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LessSleep"), false, HaloTextHelper.getColorRed());
            end
        end
        -- "Fast Healer" when having Fitness at Lv8 or more.
        if player:getPerkLevel(Perks.Fitness) >= 8 then
            if not player:HasTrait("FastHealer") then
                player:getTraits():add("FastHealer");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("FastHealer") then
                player:getTraits():remove("FastHealer");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), false, HaloTextHelper.getColorRed());
            end
        end
        -- "Resilient" when having Fitness at Lv9 or more.
        if player:getPerkLevel(Perks.Fitness) >= 9 then
            if not player:HasTrait("Resilient") then
                player:getTraits():add("Resilient");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_resilient"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("Resilient") then
                player:getTraits():remove("Resilient");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_resilient"), false, HaloTextHelper.getColorRed());
            end
        end

    --------------- TRAITS APPLIED/REMOVED FOR "OVERWEIGHT" ---------------
    elseif player:HasTrait("Overweight") then
        -- Removing traits
        if player:HasTrait("LightEater") then
            player:getTraits():remove("LightEater");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_lighteater"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("LowThirst") then
            player:getTraits():remove("LowThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LowThirst"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("NeedsLessSleep") then
            player:getTraits():remove("NeedsLessSleep");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_LessSleep"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("Resilient") then
            player:getTraits():remove("Resilient");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_resilient"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("FastHealer") then
            player:getTraits():remove("FastHealer");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_FastHealer"), false, HaloTextHelper.getColorRed());
        end
        if player:HasTrait("HeartyAppitite") and player:getPerkLevel(Perks.Fitness) >= 6 and player:getPerkLevel(Perks.Strength) >= 6 and not (player:getMoodles():getMoodleLevel(MoodleType.Stress) >= 3 or player:getMoodles():getMoodleLevel(MoodleType.Unhappy) >= 3) then
            player:getTraits():remove("HeartyAppitite");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("HighThirst") and player:getPerkLevel(Perks.Fitness) >= 6 and player:getPerkLevel(Perks.Strength) >= 6 then
            player:getTraits():remove("HighThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), false, HaloTextHelper.getColorGreen());
        end
        if player:HasTrait("Asthmatic") then
            player:getTraits():remove("Asthmatic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), false, HaloTextHelper.getColorGreen());
        end
        -- Gaining Traits
        -- "Thick skinned" when having Strength Lv7 or more
        if player:getPerkLevel(Perks.Strength) >= 7 then
            if not player:HasTrait("ThickSkinned") then
                player:getTraits():add("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("ThickSkinned") then
                player:getTraits():remove("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), false, HaloTextHelper.getColorRed());
            end
        end
        if not player:HasTrait("HeartyAppitite") and (player:getPerkLevel(Perks.Fitness) < 6 or player:getPerkLevel(Perks.Strength) < 6) then
            player:getTraits():add("HeartyAppitite");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("HighThirst") and (player:getPerkLevel(Perks.Fitness) < 6 or player:getPerkLevel(Perks.Strength) < 6) then
            player:getTraits():add("HighThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), true, HaloTextHelper.getColorRed());
        end

    --------------- TRAITS APPLIED/REMOVED FOR "OBESE" ---------------
    elseif player:HasTrait("Obese") then
        -- Removing Traits
        -- Gaining Traits
        -- "Thick skinned" when having Strength Lv7 or more
        if player:getPerkLevel(Perks.Strength) >= 7 then
            if not player:HasTrait("ThickSkinned") then
                player:getTraits():add("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), true, HaloTextHelper.getColorGreen());
            end
        else
            if player:HasTrait("ThickSkinned") then
                player:getTraits():remove("ThickSkinned");
                HaloTextHelper.addTextWithArrow(player, getText("UI_trait_thickskinned"), false, HaloTextHelper.getColorRed());
            end
        end
        if not player:HasTrait("HeartyAppitite") then
            player:getTraits():add("HeartyAppitite");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_heartyappetite"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("HighThirst") then
            player:getTraits():add("HighThirst");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_HighThirst"), true, HaloTextHelper.getColorRed());
        end
        if not player:HasTrait("Asthmatic") then
            player:getTraits():add("Asthmatic");
            HaloTextHelper.addTextWithArrow(player, getText("UI_trait_Asthmatic"), true, HaloTextHelper.getColorRed());
        end
    end
end