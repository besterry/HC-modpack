local distributionTable = VehicleDistributions[1]

VehicleDistributions.GloveBoxfuegoTuning = {
    rolls = 4,
    items = {
        "BluePen", 3,
        "Cigarettes", 6,
        "Cologne", 4,
        "CreditCard", 4,
        "Earbuds", 2,
        "Magazine", 7,
        "Razor", 4,
        "ToiletPaper", 4,
		"Underwear2", 9,
		"BeerBottle", 60,
		"BeerCan", 8,
		"PillsAntiDep", 7,
		"PlasticCup", 4,
		"Underpants_White", 8,
		"Underpants_Black", 10,
		"FrillyUnderpants_Black", 9,
		"FrillyUnderpants_Pink", 7,
		"FrillyUnderpants_Red", 1,	
    },
    junk = {
        rolls = 1,
        items = {

        }
    }
}

VehicleDistributions.TrunkfuegoTuning = {
    rolls = 4,
    items = {
        "EmptyPetrolCan", 5,
        "WhiskeyEmpty", 1,
		"BeerBottle", 70,
		"Speaker", 10,
		"Plasticbag", 40,
        "RubberBand", 6,		
        "Twine", 10,
		"BeerCan", 80,		
    },
    junk = {
        rolls = 1,
        items = {
            "BaseballBat", 1,
            "CarBattery1", 4,
            "CorpseFemale", 0.01,
            "CorpseMale", 0.01,
            "LugWrench", 8,
            "Wrench", 8,
			"Jack", 2,
        }
    }
}


VehicleDistributions.GloveBoxfuegoSport = {
    rolls = 4,
    items = {
            "FirstAidKit", 5,
            "HandTorch", 9,
            "Cube", 60,
            "Rubberducky", 7,
            "MechanicMag3", 12,

    },
    junk = {
        rolls = 1,
        items = {

        }
    }
}

VehicleDistributions.TrunkfuegoSport = {
    rolls = 4,
    items = {
            "Bag_DuffelBag", 15,
            "Toolbox", 30,
            "Extinguisher", 40,
            "CarBatteryCharger", 12,
            "Jack", 6,
            "LugWrench", 9,
            "TirePump", 20,	
            "MetalPipe", 1,
            "PetrolCan", 10,
            "CarBattery3", 10,	
            "ModernCarMuffler3", 12,
            "EngineParts", 30,
            "ModernSuspension3", 30,
    },
    junk = {
        rolls = 1,
        items = {
            "BaseballBat", 1,
            "CarBattery1", 4,
            "CorpseFemale", 0.01,
            "CorpseMale", 0.01,
            "LugWrench", 8,
            "Wrench", 8,
			"Jack", 2,
        }
    }
}



VehicleDistributions.fuego = {

	GloveBox = VehicleDistributions.GloveBox;   
	TruckBed = VehicleDistributions.TrunkSports;
	TruckBedOpen = VehicleDistributions.TrunkSports;
}

VehicleDistributions.fuegoTuning = {

	GloveBox = VehicleDistributions.GloveBoxfuegoTuning;   
	TruckBed = VehicleDistributions.TrunkfuegoTuning;
	TruckBedOpen = VehicleDistributions.TrunkfuegoTuning;
}

VehicleDistributions.fuegoSport = {

	GloveBox = VehicleDistributions.GloveBoxfuegoSport;   
	TruckBed = VehicleDistributions.TrunkfuegoSport;
	TruckBedOpen = VehicleDistributions.TrunkfuegoSport;
}

distributionTable["1988fuego"] = { Normal = VehicleDistributions.fuego; }
distributionTable["1988fuegoTuning"] = { Normal = VehicleDistributions.fuegoTuning; }
distributionTable["1988fuegoSport"] = { Normal = VehicleDistributions.fuegoSport; }

