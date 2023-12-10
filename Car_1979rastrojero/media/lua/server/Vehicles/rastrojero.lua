local distributionTable = VehicleDistributions[1]

VehicleDistributions.FleteTruckBed = {
    rolls = 3,
    items = {
            "GuitarAcoustic", 15,
            "BarBell", 8,
            "Broom", 60,
            "ChairLeg", 30,
            "Saucepan", 5,
            "Garbagebag", 4,
            "AlarmClock", 70,
			"Remote", 60,
			"RadioBlack", 60,	
			"TvAntique", 20,
			"BoxOfJars", 10,	
			"Paintbrush", 18,	
			"Rope", 5,
			"PaintbucketEmpty", 2,	
			"PropaneTank", 12,	
			"Drawer", 22,	
			"Bricktoys", 32,	
			"Doll", 44,	
			"DogChew", 4,	
			"Lamp", 45,	
			"Frame", 32,
			"SoccerBall", 92,			
    },
    junk = {
        rolls = 1,
        items = {
            "BaseballBat", 1,
            "CarBattery2", 4,
            "FirstAidKit", 4,
            "Jack", 2,
            "LugWrench", 8,
            "Wrench", 8,
        }
    }
}

VehicleDistributions.CarniTruckBed = {
    rolls = 3,
    items = {
            "Cooler", 11,
            "BaconRashers", 8,
            "Baloney", 30,
            "Chicken", 10,
            "MuttonChop", 50,
            "PorkChop", 40,
            "Steak", 20,
			"MeatPatty", 15,
			"FishFillet", 23,	
			"Salmon", 5,		
    },
    junk = {
        rolls = 1,
        items = {
            "BaseballBat", 1,
            "CarBattery2", 4,
            "FirstAidKit", 4,
            "Jack", 2,
            "LugWrench", 8,
            "Wrench", 8,
        }
    }
}


VehicleDistributions.ChataTruckBed = {
    rolls = 3,
    items = {
            "Hat_BalaclavaFull", 1,
            "WeldingMask", 2,
            "PickAxe", 5,
            "SmashedBottle", 10,
            "PlankNail", 50,
            "TrapMouse", 6,
            "Dirtbag", 20,
			"TinCanEmpty", 5,
			"Gravelbag", 23,	
			"SheetMetal", 35,	
			"ScrapMetal", 25,	
			"SmallSheetMetal", 15,		
			"UnusableMetal", 75,				
    },
    junk = {
        rolls = 1,
        items = {
            "BaseballBat", 1,
            "CarBattery2", 4,
            "FirstAidKit", 4,
            "Jack", 2,
            "LugWrench", 8,
            "Wrench", 8,
        }
    }
}



VehicleDistributions.rastrojero = {

    GloveBox = VehicleDistributions.GloveBox;
	TruckBed = VehicleDistributions.FarmerTruckBed;
    TruckBedOpen = VehicleDistributions.FarmerTruckBed;

}

VehicleDistributions.rastrojeroFlete = {

    GloveBox = VehicleDistributions.GloveBox;
	TruckBed = VehicleDistributions.FleteTruckBed;
    TruckBedOpen = VehicleDistributions.FleteTruckBed;

}

VehicleDistributions.rastrojeroCarni = {

    GloveBox = VehicleDistributions.GloveBox;
	TruckBed = VehicleDistributions.CarniTruckBed;
    TruckBedOpen = VehicleDistributions.CarniTruckBed;

}

VehicleDistributions.rastrojeroChata = {

    GloveBox = VehicleDistributions.GloveBox;
	TruckBed = VehicleDistributions.ChataTruckBed;
    TruckBedOpen = VehicleDistributions.ChataTruckBed;

}

distributionTable["1979rastrojero"] = { Normal = VehicleDistributions.rastrojero; }
distributionTable["1979rastrojeroFlete"] = { Normal = VehicleDistributions.rastrojeroFlete; }
distributionTable["1979rastrojeroCarni"] = { Normal = VehicleDistributions.rastrojeroCarni; }
distributionTable["1979rastrojeroChata"] = { Normal = VehicleDistributions.rastrojeroChata; }

