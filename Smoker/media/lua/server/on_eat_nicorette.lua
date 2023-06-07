function OnEat_Nicorette(food, character, percent)
	if food:getType() == "SMGum" then
		local player = getSpecificPlayer(0);
		local DATAPlayer = player:getModData();
		DATAPlayer.OnEat_Nicorette = true;
		DATAPlayer.OnEat_Nicorette_Time = 0;
	end
end