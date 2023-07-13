require 'Foraging/forageSystem'

Events.onAddForageDefs.Add(function()

	--New categoryHidden
	local Artifacts = {
		name                    = "Artifacts",
		typeCategory            = "Other",
		identifyCategoryPerk    = "PlantScavenging",
		identifyCategoryLevel   = 4,
		categoryHidden          = false,
		validFloors             = { "ANY" },
		zoneChance              = {
			DeepForest      = 100, -- Дефолт все 15
			Forest          = 100,
			Vegitation      = 100,
			FarmLand        = 100,
			Farm            = 100,
			TrailerPark     = 100,
			TownZone        = 100,
			Nav             = 100,
		},
	}

forageSystem.addCatDef(Artifacts);
	
--New items

	local ArtifactCell = {
	type = "stalker.ArtifactCell",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactChain = {
	type = "stalker.ArtifactChain",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactCrystal = {
	type = "stalker.ArtifactCrystal",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 1,
			Vegitation          = 5,
			FarmLand            = 5,
			Farm                = 5,
			TrailerPark         = 5,
			TownZone            = 10,
			Nav                 = 5,
		},
	};

	local ArtifactCrystalThorn = {
	type = "stalker.ArtifactCrystalThorn",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 1,
			Vegitation          = 5,
			FarmLand            = 10,
			Farm                = 10,
			TrailerPark         = 5,
			TownZone            = 5,
			Nav                 = 1,
		},
	};

	local ArtifactEye = {
	type = "stalker.ArtifactEye",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 1,
			Vegitation          = 1,
			FarmLand            = 1,
			Farm                = 1,
			TrailerPark         = 5,
			TownZone            = 10,
			Nav                 = 10,
		},
	};

	local ArtifactFirefly = {
	type = "stalker.ArtifactFirefly",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 5,
			DeepForest          = 10,
			Vegitation          = 1,
			FarmLand            = 1,
			Farm                = 1,
			TrailerPark         = 1,
			TownZone            = 1,
			Nav                 = 1,
		},
	};

	local ArtifactFountain = {
	type = "stalker.ArtifactFountain",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactHeart = {
	type = "stalker.ArtifactHeart",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactMamasBeads = {
	type = "stalker.ArtifactMamasBeads",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 1,
			Vegitation          = 1,
			FarmLand            = 5,
			Farm                = 5,
			TrailerPark         = 5,
			TownZone            = 5,
			Nav                 = 5,
		},
	};

	local ArtifactPellicle = {
	type = "stalker.ArtifactPellicle",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 5,
			Vegitation          = 1,
			FarmLand            = 1,
			Farm                = 1,
			TrailerPark         = 1,
			TownZone            = 1,
			Nav                 = 1,
		},
	};

	local ArtifactPhantomStar = {
	type = "stalker.ArtifactPhantomStar",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactSeraphim = {
	type = "stalker.ArtifactSeraphim",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactSignet = {
	type = "stalker.ArtifactSignet",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactSnowflake = {
	type = "stalker.ArtifactSnowflake",
	--skill=2,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 5,
			DeepForest          = 1,
			Vegitation          = 1,
			FarmLand            = 1,
			Farm                = 1,
			TrailerPark         = 1,
			TownZone            = 1,
			Nav                 = 1,
		},
	};

	local ArtifactSoul = {
	type = "stalker.ArtifactSoul",
	--skill=2,
	xp=10,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 1,
			DeepForest          = 1,
			Vegitation          = 5,
			FarmLand            = 5,
			Farm                = 5,
			TrailerPark         = 5,
			TownZone            = 1,
			Nav                 = 1,
		},
	};

	local ArtifactSourpuss = {
	type = "stalker.ArtifactSourpuss",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactStoneFlower = {
	type = "stalker.ArtifactStoneFlower",
	--skill=2,
	xp=10,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 5,
			DeepForest          = 5,
			Vegitation          = 10,
			FarmLand            = 10,
			Farm                = 10,
			TrailerPark         = 10,
			TownZone            = 25,
			Nav                 = 10,
		},
	};

	local ArtifactSun = {
	type = "stalker.ArtifactSun",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

	local ArtifactUrchin = {
	type = "stalker.ArtifactUrchin",
	--skill=2,
	xp=10,
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 5,
			DeepForest          = 5,
			Vegitation          = 1,
			FarmLand            = 1,
			Farm                = 1,
			TrailerPark         = 1,
			TownZone            = 1,
			Nav                 = 1,
		},
	};

	local ArtifactWrenched = {
	type = "stalker.ArtifactWrenched",
	itemTags = { "FindArtifact" },
        categories = { "Artifacts" },
		zones           = {
			Forest              = 100,
			DeepForest          = 100,
			Vegitation          = 100,
			FarmLand            = 100,
			Farm                = 100,
			TrailerPark         = 100,
			TownZone            = 100,
			Nav                 = 100,
		},
	};

--Adding them to the foraging system
forageSystem.addItemDef(ArtifactCell);
forageSystem.addItemDef(ArtifactChain);
forageSystem.addItemDef(ArtifactCrystal);
forageSystem.addItemDef(ArtifactCrystalThorn);
forageSystem.addItemDef(ArtifactEye);
forageSystem.addItemDef(ArtifactFirefly);
forageSystem.addItemDef(ArtifactFountain);
forageSystem.addItemDef(ArtifactHeart);
forageSystem.addItemDef(ArtifactMamasBeads);
forageSystem.addItemDef(ArtifactPellicle);
forageSystem.addItemDef(ArtifactPhantomStar);
forageSystem.addItemDef(ArtifactSeraphim);
forageSystem.addItemDef(ArtifactSignet);
forageSystem.addItemDef(ArtifactSnowflake);
forageSystem.addItemDef(ArtifactSoul);
forageSystem.addItemDef(ArtifactSourpuss);
forageSystem.addItemDef(ArtifactStoneFlower);
forageSystem.addItemDef(ArtifactSun);
forageSystem.addItemDef(ArtifactUrchin);
forageSystem.addItemDef(ArtifactWrenched);

end)