--=============================
--***************************
--***** Danger Moodles  *****
--***************************
--**** Deadly Infections ****
--***************************
--**** Coded by: ogreLeg ****
--***************************
--** v1.3 for Builds 40-41 **
--=============================

--------------version checker---------------------------------------------------------------------------------------------------------	
local MOD_ID = "DangerMoodlesDeadlyInfections"

local gameVersion = getCore():getVersionNumber()
local gameVersionNum = 0
local tempIndex, _ = string.find(gameVersion, " ")
if tempIndex ~= nil then
    
    gameVersionNum = tonumber(string.sub(gameVersion, 0, tempIndex))
    if gameVersionNum == nil then 
        tempIndex, _ = string.find(gameVersion, ".") + 1 
        gameVersionNum = tonumber(string.sub(gameVersion, 0, tempIndex))
    end
else
    gameVersionNum = tonumber(gameVersion)
end
tempIndex = nil
gameVersion = nil
--------------version checker---------------------------------------------------------------------------------------------------------	

local DURGAMfinalCheck = 0

--------------For Build 40---------------------------------------------------------------------------------------------------------	

local function playCheck()
    DURGAM_deathByBleach()
end

function DURGAM_deadlyInfection(zombie)
for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        local stats = player:getStats();
--      DEADLY INFECTION START

    local infectedHead = player:getBodyDamage():getBodyPart(BodyPartType.Head):getWoundInfectionLevel()
	local infectedNeck = player:getBodyDamage():getBodyPart(BodyPartType.Neck):getWoundInfectionLevel()
	local infectedTorsoUpper = player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getWoundInfectionLevel()
	local infectedUpperArmL = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getWoundInfectionLevel()
	local infectedUpperArmR = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getWoundInfectionLevel()
	local infectedForeArmL = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getWoundInfectionLevel()
	local infectedForeArmR = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getWoundInfectionLevel()
	local infectedHandL = player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getWoundInfectionLevel()
	local infectedHandR = player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getWoundInfectionLevel()
	local infectedTorsoLower = player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getWoundInfectionLevel()
	local infectedGroin = player:getBodyDamage():getBodyPart(BodyPartType.Groin):getWoundInfectionLevel()
	local infectedUpperLegL = player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getWoundInfectionLevel()
	local infectedUpperLegR = player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getWoundInfectionLevel()
	local infectedLowerLegL = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getWoundInfectionLevel()
	local infectedLowerLegR = player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getWoundInfectionLevel()
    local infectedFootL = player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getWoundInfectionLevel()
	local infectedFootR = player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getWoundInfectionLevel()
	local infectedAll = math.max(infectedHead, infectedNeck, infectedTorsoUpper, infectedUpperArmL, infectedUpperArmR, infectedForeArmL, infectedForeArmR, infectedHandL, infectedHandR, infectedTorsoLower, infectedGroin, infectedUpperLegL, infectedUpperLegR, infectedLowerLegL, infectedLowerLegR, infectedFootL, infectedFootR);
	
	if player:getBodyDamage():getBodyPart(BodyPartType.Head):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Head):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Head):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Head):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Head):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.Neck):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Neck):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Neck):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Neck):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Neck):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getWoundInfectionLevel() + 1);
		end
	end	
	if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.Groin):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Groin):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Groin):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Groin):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Groin):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):HasInjury() then
	    player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):HasInjury() then
		player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getWoundInfectionLevel() + 1);
		end
	end
	if player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):HasInjury() then
        player:getBodyDamage():setPoisonLevel(infectedAll);
		if player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):bandaged() == false and ZombRand(5) >= 2 then
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setInfectedWound(true);
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setWoundInfectionLevel(player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getWoundInfectionLevel() + 1);
		end
	end
	if infectedAll <= 0 then
	    getPlayer():getBodyDamage():setFoodSicknessLevel(getPlayer():getBodyDamage():getFoodSicknessLevel() - 5);
	end
	
--      DEADLY INFECTION END
end
end

if 40 <= gameVersionNum and gameVersionNum < 41 then

Events.OnPlayerUpdate.Add(playCheck);
Events.EveryTenMinutes.Add(DURGAM_deadlyInfection);

end
--------------For Build 40---------------------------------------------------------------------------------------------------------
--
--------------For Build 41---------------------------------------------------------------------------------------------------------	

function playCheckNEW(zombie)
	DURGAM_deathByBleach()
end	

function DURGAM_deathByBleach(zombie)
for playerIndex = 0, getNumActivePlayers()-1 do
    local player = getSpecificPlayer(playerIndex);
--      DEATH BY BLEACH START
    if player:getBodyDamage():getPoisonLevel() >= 100 then
	    player:getBodyDamage():getBodyPart(BodyPartType.Head):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Neck):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Groin):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):AddDamage(100);
		player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):AddDamage(100);
	end
--      DEATH BY BLEACH END
end
end

function DURGAM_deadlyInfectionBETA(zombie)
for playerIndex = 0, getNumActivePlayers()-1 do
    local player = getSpecificPlayer(playerIndex);
	local stats = player:getStats();
	local infectedAll = 1
--      DEADLY INFECTION START
	
	if player:getBodyDamage():getBodyPart(BodyPartType.Head):isInfectedWound() then
	    --player:Say("Head Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Neck):isInfectedWound() then
	    --player:Say("Neck Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):isInfectedWound() then
	    --player:Say("Torso Upper Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):isInfectedWound() then
	    --player:Say("Arm Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):isInfectedWound() then
	    --player:Say("Arm Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):isInfectedWound() then
	    --player:Say("Arm Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):isInfectedWound() then
	    --player:Say("Arm Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):isInfectedWound() then
	    --player:Say("Hand Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):isInfectedWound() then
	    --player:Say("Hand Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):isInfectedWound() then
	    --player:Say("Torso Lower Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Groin):isInfectedWound() then
	    --player:Say("Leg Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):isInfectedWound() then
	    --player:Say("Leg Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):isInfectedWound() then
	    --player:Say("Leg Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):isInfectedWound() then
	    --player:Say("Leg Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):isInfectedWound() then
	    --player:Say("Leg Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):isInfectedWound() then
	    --player:Say("Foot Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):isInfectedWound() then
	    --player:Say("Foot Infection")
		stats:setPain(stats:getPain() + 3)
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + infectedAll);
	else
	    if player:getBodyDamage():getColdStrength() <= 74 and DURGAMfinalCheck <= 0 then
		    if player:getBodyDamage():getPoisonLevel() <= 30 then
	            player:getBodyDamage():setFoodSicknessLevel(player:getBodyDamage():getFoodSicknessLevel() - 7);
			end
		    if player:getBodyDamage():getFoodSicknessLevel() <= 25 and player:getBodyDamage():getColdStrength() <= 74 then
		        if player:getBodyDamage():getPoisonLevel() <= 99 then
				    player:getBodyDamage():setFoodSicknessLevel(0);
				end
		    end
	end
		if player:getBodyDamage():getPoisonLevel() <= 0 then
		    player:getBodyDamage():setPoisonLevel(0);
		end
	end
	if player:getBodyDamage():getPoisonLevel() >= 3 and player:getBodyDamage():getPoisonLevel() <= 30 then
		player:getBodyDamage():setPoisonLevel(3);    
	end
	if player:getBodyDamage():getFoodSicknessLevel() >= 30 then
	    player:getBodyDamage():setFoodSicknessLevel(player:getBodyDamage():getFoodSicknessLevel() - 1.2)
	end

--      DEADLY INFECTION END

--      DIRTY BANDAGE START
	if player:getBodyDamage():getBodyPart(BodyPartType.Head):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Head):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Head):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Head):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Head):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Head):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Head):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Head):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Head):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Head):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Head):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Head):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Head):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Head):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Head):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Head):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Head):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Neck):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Neck):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Neck):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Neck):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Neck):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Neck):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Neck):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Neck):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Neck):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Neck):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Neck):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Neck):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Neck):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Neck):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Neck):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Neck):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Neck):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Hand_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Torso_Lower):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Groin):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Groin):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Groin):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Groin):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Groin):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Groin):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Groin):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Groin):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Groin):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Groin):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Groin):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Groin):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Groin):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Groin):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Groin):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Groin):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Groin):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.UpperLeg_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.LowerLeg_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_L):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	
	elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):bandaged() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):isBandageDirty() then
		player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
		if ZombRand(10) >= 4 then
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setInfectedWound(true)
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setWoundInfectionLevel(0.001)
		end
		if player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getCutTime() > 0 then
	        --player:Say("Cut")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setCutTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getCutTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getBiteTime() > 0 then
	        --player:Say("Bitten")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setBiteTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getBiteTime() + 0.04)
	    elseif player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):HasInjury() and player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getScratchTime() > 0 then
	        --player:Say("Scratched")
		    player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):setScratchTime(player:getBodyDamage():getBodyPart(BodyPartType.Foot_R):getScratchTime() + 0.10)
	    end
		DURGAMfinalCheck = 1
		DURGAM_finalCheckOne()
	else
        DURGAMfinalCheck = 0
		DURGAM_finalCheckZero()
	end
	
--      DIRTY BANDAGE END
end
end

function DURGAM_finalCheckOne()
    DURGAMfinalCheck = 1
end

function DURGAM_finalCheckZero()
    DURGAMfinalCheck = 0
end

if gameVersionNum >= 41 then

--Events.EveryOneMinute.Add(testItNew);
Events.OnPlayerUpdate.Add(playCheckNEW);
Events.EveryTenMinutes.Add(DURGAM_deadlyInfectionBETA);

end
--------------For Build 41---------------------------------------------------------------------------------------------------------