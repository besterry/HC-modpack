-- BLOODLUST TRAIT
function bloodlustTrait(player)
    print("DT Logger: running bloodlustTrait function");
    if not player:isAsleep() then
        player:getModData().DTtimesinceLastKill = player:getModData().DTtimesinceLastKill + 1;
        -- IF PLAYER HAVEN'T KILLED ZOMBIES FOR 24 HOURS, THEN THE MOOD WILL BE AFFECTED EVERY HOUR
        if player:getModData().DTtimesinceLastKill > 24 then
            -- STRESS
            DTincreaseStress(player, 0.15);
            -- BOREDOM
            DTincreaseBoredom(player, 15);
            -- UNHAPPYNESS
            DTincreaseUnhappyness(player, 5);
        end
    end
    print("DT Logger: DTtimesinceLastKill value is " .. player:getModData().DTtimesinceLastKill);
end
function bloodlustTraitOnZombieKill(player)
    print("DT Logger: running bloodlustTraitOnZombieKill function");
    -- IF THE PLAYER KILLED A ZOMBIE THE NEGATIVE MOODS ARE REDUCED
    if player:getZombieKills() > player:getModData().DTKillscheck then
        -- STRESS
        DTdecreaseStress(player, 0.05);
        DTdecreaseStressFromCigarettes(player, 0.10);
        -- BOREDOM
        DTdecreaseBoredom(player, 5);
        -- UNHAPPYNESS
        DTdecreaseUnhappyness(player, 10);
        player:getModData().DTKillscheck = player:getZombieKills();
        player:getModData().DTtimesinceLastKill = 0;
    end
end