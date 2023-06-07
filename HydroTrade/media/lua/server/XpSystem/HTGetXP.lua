require "XpSystem/XpUpdate";

-- Выдать 0.5 очков опыта в фермерство
function HTFarming_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Farming, 0.5);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в строительство
function HTConstructionGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Woodwork, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в кулинарию
function HTCookingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Cooking, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в фермерство
function HTFarmingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Farming, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в первую помощь
function HTDoctorGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Doctor, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в первую помощь
function HTElectricityGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Electricity, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в металосварку
function HTMetalWeldingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.MetalWelding, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в механику
function HTMechanicsGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Mechanics, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в шитье
function HTTailoringGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Tailoring, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в звероловство
function HTTrappingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Trapping, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в рыболовство
function HTFishingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.Fishing, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end

-- Выдать 160 очков опыта в собирательство
function HTPlantScavengingGuide_OnGiveXP(recipe, ingredients, result, player)
    player:getXp():AddXP(Perks.PlantScavenging, 160);
	-- player:getStats():setHunger(player:getStats():getHunger()+0.01)
end


