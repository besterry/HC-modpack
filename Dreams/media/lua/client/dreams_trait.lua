require('NPCs/MainCreationMethods');

local function DoSnoringTrait()
	local SnoringTrait = TraitFactory.addTrait("Snoring", getText("UI_trait_Snoring"), -8, getText("UI_trait_SnoringDesc"), false);
end

Events.OnGameBoot.Add(DoSnoringTrait);