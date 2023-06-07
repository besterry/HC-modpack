require "Foraging/forageDefinitions"

-- Adds custom traits to the Foraging buffs/debuffs
if forageSkills then
    forageSkills.Pluviophile = {
		name                    = "Pluviophile",
		type                    = "trait",
		visionBonus             = 0.5,
		weatherEffect           = 10,
		darknessEffect          = 0,
		specialisations         = {
			["MedicinalPlants"] = 3,
			["Berries"]         = 5,
            ["Mushrooms"]       = 5,
            ["WildPlants"]      = 5,
		},
	}
	forageSkills.Pluviophobia = {
		name                    = "Pluviophobia",
		type                    = "trait",
		visionBonus             = -0.5,
		weatherEffect           = 0,
		darknessEffect          = 0,
		specialisations         = {
			["MedicinalPlants"] = -5,
			["Berries"]         = -5,
            ["Mushrooms"]       = -5,
            ["WildPlants"]      = -5,
		},
	}
end
