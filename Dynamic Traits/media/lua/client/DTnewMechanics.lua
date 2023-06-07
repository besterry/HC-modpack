-- Grant XP multiplier if the regularity is maxed
function exerciseMultiplierIfMaxRegularity(player)
	print("DT Logger: running exerciseMultiplierIfMaxRegularity function");
	--print("function exerciseMultiplierIfMaxRegularity is called");
	player:getXp():addXpMultiplier(Perks.Fitness, 1, player:getPerkLevel(Perks.Fitness), 10); -- Grant an XP multiplier to avoid lua errors.
	player:getXp():getMultiplierMap():remove(Perks.Fitness); -- Remove the current XP multiplier
    player:getXp():addXpMultiplier(Perks.Strength, 1, player:getPerkLevel(Perks.Strength), 10); -- Grant an XP multiplier to avoid lua errors.
	player:getXp():getMultiplierMap():remove(Perks.Strength); -- Remove the current XP multiplier
	if player:getFitness():getRegularity("squats") == 100 then
		player:getXp():addXpMultiplier(Perks.Fitness, 3, player:getPerkLevel(Perks.Fitness), 10);
	end
	if player:getFitness():getRegularity("pushups") == 100 then
		player:getXp():addXpMultiplier(Perks.Strength, 3, player:getPerkLevel(Perks.Strength), 10);
	end
	if player:getFitness():getRegularity("situp") == 100 then
		player:getXp():addXpMultiplier(Perks.Fitness, 3, player:getPerkLevel(Perks.Fitness), 10);
	end
	if player:getFitness():getRegularity("burpees") == 100 then
		player:getXp():addXpMultiplier(Perks.Fitness, 3, player:getPerkLevel(Perks.Fitness), 10);
		player:getXp():addXpMultiplier(Perks.Strength, 3, player:getPerkLevel(Perks.Strength), 10);
	end
	if player:getFitness():getRegularity("barbellcurl") == 100 then
		player:getXp():addXpMultiplier(Perks.Strength, 3, player:getPerkLevel(Perks.Strength), 10);
	end
	if player:getFitness():getRegularity("dumbbellpress") == 100 then
		player:getXp():addXpMultiplier(Perks.Strength, 3, player:getPerkLevel(Perks.Strength), 10);
	end
	if player:getFitness():getRegularity("bicepscurl") == 100 then
		player:getXp():addXpMultiplier(Perks.Strength, 3, player:getPerkLevel(Perks.Strength), 10);
	end
	-- If Fitness is at Lv10 remove the granted multiplier
	if player:getPerkLevel(Perks.Fitness) == 10 then
		player:getXp():addXpMultiplier(Perks.Fitness, 1, player:getPerkLevel(Perks.Fitness), 10); -- Grant an XP multiplier to avoid lua errors.
		player:getXp():getMultiplierMap():remove(Perks.Fitness); -- Remove the current XP multiplier
	end
	-- If Strength is at Lv10 remove the granted multiplier
	if player:getPerkLevel(Perks.Strength) == 10 then
		player:getXp():addXpMultiplier(Perks.Strength, 1, player:getPerkLevel(Perks.Strength), 10); -- Grant an XP multiplier to avoid lua errors.
		player:getXp():getMultiplierMap():remove(Perks.Strength); -- Remove the current XP multiplier
	end
end