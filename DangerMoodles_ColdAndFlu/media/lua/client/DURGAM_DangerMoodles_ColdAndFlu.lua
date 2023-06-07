--=============================
--***************************
--***** Danger Moodles  *****
--***************************
--****** Cold and Flu *******
--***************************
--**** Coded by: ogreLeg ****
--***************************
--** v1.2 for Builds 40-41 **
--=============================

--------------version checker---------------------------------------------------------------------------------------------------------	
local MOD_ID = "DangerMoodlesColdAndFlu"

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



--------------For Build 40---------------------------------------------------------------------------------------------------------	

function DURGAM_flu(zombie)
    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        local stats = player:getStats();
--      SEVERE COLD ADDS FEVER START
		
		if player:getBodyDamage():getColdStrength() >= 90 then
		    player:getBodyDamage():setFoodSicknessLevel(99);
		end
	
--      SEVERE COLD ADDS FEVER END

--      SICKNESS FATIGUE START
	
		if player:getBodyDamage():getColdStrength() >= 90 and player:getBodyDamage():getFoodSicknessLevel() >= 90 then
		    stats:setEndurance(0.25)
		    stats:setFatigue(stats:getFatigue() + 0.6)
		end

--      SICKNESS FATIGUE END

--      FEVER DAMAGE START
	    if stats:getSickness() > 0.26 then
	        for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                local b = player:getBodyDamage():getBodyParts():get(i);
                b:AddDamage(0.05);
	        end
	    end
--      FEVER DAMAGE END
    end
end

if 40 <= gameVersionNum and gameVersionNum < 41 then

Events.EveryTenMinutes.Add(DURGAM_flu);

end
--------------For Build 40---------------------------------------------------------------------------------------------------------
--
--------------For Build 41---------------------------------------------------------------------------------------------------------	

function DURGAM_fluBETA(zombie)
    for playerIndex = 0, getNumActivePlayers()-1 do
        local player = getSpecificPlayer(playerIndex);
        local stats = player:getStats();
--      SEVERE COLD ADDS FEVER START		
		if player:getBodyDamage():getColdStrength() >= 75 then
		    player:getBodyDamage():setPoisonLevel(player:getBodyDamage():getPoisonLevel() + 1);
--		    player:getBodyDamage():setFoodSicknessLevel(99);
		end
--      SEVERE COLD ADDS FEVER END

--      SICKNESS FATIGUE START		
		if player:getBodyDamage():getColdStrength() >= 75 and player:getBodyDamage():getFoodSicknessLevel() >= 90 then
		    stats:setEndurance(0.25)
		    stats:setFatigue(stats:getFatigue() + 0.6)
		end
--      SICKNESS FATIGUE END

--      FEVER DAMAGE START
	    if stats:getSickness() > 0.26 then
	        for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                local b = player:getBodyDamage():getBodyParts():get(i);
                b:AddDamage(0.05);
	        end
	    end
--      FEVER DAMAGE END
    end	
end

if gameVersionNum >= 41 then

--Events.EveryOneMinute.Add(testItNew);
Events.OnPlayerUpdate.Add(playCheckNEW);
Events.EveryTenMinutes.Add(DURGAM_fluBETA);

end
--------------For Build 41---------------------------------------------------------------------------------------------------------