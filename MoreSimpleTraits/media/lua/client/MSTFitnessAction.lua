-- EXERCISE TRAIT EFFECTS
function ISFitnessAction:exeLooped()
    player = self.character;
    if getActivatedMods():contains("DynamicTraits") then
        -- If the player has the trait "Prodigy", extra experience is added to Strength or/and Fitness on each loop (depending on the exercise)
        -- If the player has the trait "Physically Active" the negative moods are reduced when doing exercise
        -- If the player has the trait "Sedentary" extra pain is added the the bodyparts based on the exercise
        if self.exercise == "squats" then
            if player:HasTrait("Prodigy") then
                -- Adding 5.0XP
                player:getXp():AddXP(Perks.Fitness, (self.exeData.xpMod * 20));
            end 
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "UpperLeg_L", ZombRand(7));
                DTapplyPain(player, 0, "UpperLeg_R", ZombRand(7));
                DTapplyPain(player, 0, "LowerLeg_L", ZombRand(7));
                DTapplyPain(player, 0, "LowerLeg_R", ZombRand(7));
            end
        elseif self.exercise == "pushups" then
            if player:HasTrait("Prodigy") then
                -- Adding 5.0XP
                player:getXp():AddXP(Perks.Strength, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "ForeArm_L", ZombRand(7));
                DTapplyPain(player, 0, "ForeArm_R", ZombRand(7));
                DTapplyPain(player, 0, "UpperArm_L", ZombRand(7));
                DTapplyPain(player, 0, "UpperArm_R", ZombRand(7));
            end
        elseif self.exercise == "situp" then
            if player:HasTrait("Prodigy") then
                -- Adding 5.0XP
                player:getXp():AddXP(Perks.Fitness, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "Torso_Lower", ZombRand(15));
            end
        elseif self.exercise == "burpees" then
            if player:HasTrait("Prodigy") then
                -- Adding 4.0XP
                player:getXp():AddXP(Perks.Fitness, (self.exeData.xpMod * 20));
                player:getXp():AddXP(Perks.Strength, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "UpperLeg_L", ZombRand(5));
                DTapplyPain(player, 0, "UpperLeg_R", ZombRand(5));
                DTapplyPain(player, 0, "LowerLeg_L", ZombRand(5));
                DTapplyPain(player, 0, "LowerLeg_R", ZombRand(5));
                DTapplyPain(player, 0, "ForeArm_L", ZombRand(5));
                DTapplyPain(player, 0, "ForeArm_R", ZombRand(5));
                DTapplyPain(player, 0, "UpperArm_L", ZombRand(5));
                DTapplyPain(player, 0, "UpperArm_R", ZombRand(5));
            end
        elseif self.exercise == "barbellcurl" then
            if player:HasTrait("Prodigy") then
                -- Adding 6.0XP
                player:getXp():AddXP(Perks.Strength, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "ForeArm_L", ZombRand(10));
                DTapplyPain(player, 0, "ForeArm_R", ZombRand(10));
                DTapplyPain(player, 0, "UpperArm_L", ZombRand(10));
                DTapplyPain(player, 0, "UpperArm_R", ZombRand(10));
            end
        elseif self.exercise == "dumbbellpress" then
            if player:HasTrait("Prodigy") then
                -- Adding 9.0XP
                player:getXp():AddXP(Perks.Strength, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "ForeArm_L", ZombRand(10));
                DTapplyPain(player, 0, "ForeArm_R", ZombRand(10));
                DTapplyPain(player, 0, "UpperArm_L", ZombRand(13));
                DTapplyPain(player, 0, "UpperArm_R", ZombRand(13));
            end
        elseif self.exercise == "bicepscurl" then
            if player:HasTrait("Prodigy") then
                -- Adding 9.0XP
                player:getXp():AddXP(Perks.Strength, (self.exeData.xpMod * 20));
            end
            if player:HasTrait("Sedentary") then
                DTapplyPain(player, 0, "ForeArm_L", ZombRand(10));
                DTapplyPain(player, 0, "ForeArm_R", ZombRand(10));
                DTapplyPain(player, 0, "UpperArm_L", ZombRand(13));
                DTapplyPain(player, 0, "UpperArm_R", ZombRand(13));
            end
        end
        -- IMPROVE THE MOODLE IF PHYSICALLY ACTIVE IS PRESENT
        if player:HasTrait("PhysicallyActive") then
            DTdecreaseStress(player, 0.05);
            DTdecreaseStressFromCigarettes(player, 0.05);
            DTdecreaseUnhappyness(player, 5);
            DTdecreaseBoredom(player, 5);
        -- GIVE BOREDOM IF SEDENTARY IS PRESENT
        elseif player:HasTrait("Sedentary") then
            DTincreaseBoredom(player, 7);
        end
        player:getModData().DTObtainLoseActiveSedentary = player:getModData().DTObtainLoseActiveSedentary + 10;
        if player:getModData().DTObtainLoseActiveSedentary > 70000 then
		    player:getModData().DTObtainLoseActiveSedentary = 70000;
	    end
        -- IF THE ROLL IS 0 THEN THE NEXT TRAITS ARE POSITIVELY AFFECTED: SMOKER, ALCOHOLIC, ANOREXIC
        if ZombRand(15) == 0 then
            -- SMOKER
            if player:HasTrait("Smoker") then
                player:getModData().DTdaysSinceLastSmoke = player:getModData().DTdaysSinceLastSmoke + ZombRand(5);
            end
            -- ALCOHOLIC
            player:getModData().DThoursSinceLastDrink = player:getModData().DThoursSinceLastDrink + ZombRand(3);
            player:getModData().DTthresholdToObtainAlcoholic = player:getModData().DTthresholdToObtainAlcoholic - ZombRand(3);
            -- ANOREXIC
            player:getModData().DTthresholdToObtainLoseAnorexy = player:getModData().DTthresholdToObtainLoseAnorexy + ZombRand(7);
        end
        DTincreaseWetness(player, 0, 1);
    end
    if getActivatedMods():contains("MoreSimpleTraits") then
        if self.exercise == "squats" then
            if player:HasTrait("SoreLegsTrait")then
            MSTincreasePain(player, ZombRand(4), "UpperLeg_L", ZombRand(4)+1);	
            MSTincreasePain(player, ZombRand(4), "UpperLeg_R", ZombRand(4)+1);	
            MSTincreasePain(player, ZombRand(4), "LowerLeg_L", ZombRand(4)+1);	
            MSTincreasePain(player, ZombRand(4), "LowerLeg_R", ZombRand(4)+1);
            end	
            elseif self.exercise == "burpees" then
            if player:HasTrait("SoreLegsTrait")then
            MSTincreasePain(player, ZombRand(4), "UpperLeg_L", ZombRand(4)+2);	
            MSTincreasePain(player, ZombRand(4), "UpperLeg_R", ZombRand(4)+2);	
            MSTincreasePain(player, ZombRand(4), "LowerLeg_L", ZombRand(4)+2);	
            MSTincreasePain(player, ZombRand(4), "LowerLeg_R", ZombRand(4)+2);
            MSTincreasePain(player, ZombRand(3), "Foot_L", ZombRand(3)+2);	
            MSTincreasePain(player, ZombRand(3), "Foot_R", ZombRand(3)+2);		
            end
        end
    end
	self.repnb = self.repnb + 1;
	self.fitness:exerciseRepeat();
	self:setFitnessSpeed();
end