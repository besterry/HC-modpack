local distributionTable = VehicleDistributions[1]

VehicleDistributions.GloveBoxen88_F40 = {
    rolls = 4,
    items = {
        "BeerBottle", 6,
        "BeerCan", 8,
        "BluePen", 3,
        "Cigarettes", 8,
        "Cologne", 4,
        "Comb", 4,
        "CombinationPadlock", 1,
        "CreditCard", 4,
        "Disc_Retail", 4,
        "FrillyUnderpants_Black", 9,
        "FrillyUnderpants_Pink", 9,
        "FrillyUnderpants_Red", 5,
        "Lipstick", 6,
        "Magazine", 7,
        "MakeupEyeshadow", 6,
        "MakeupFoundation", 6,
        "PillsAntiDep", 40,
        "PillsBeta", 40,
        "Shoes_RedTrainers", 0.8,
        "WhiskeyEmpty", 20,
    },
    junk = {
        rolls = 1,
        items = {
            "CameraExpensive", 0.5,
            "Corkscrew", 3,
            "Glasses_Aviators", 20,
            "Gloves_LeatherGloves", 10,
            "GolfBall", 6,
            "Money", 60,
            "Pistol", 1,
            "Pistol2", 1,
            "Pistol3", 1,
            "TennisBall", 5,
            "Wallet", 4,
            "Wallet2", 4,
            "Wallet3", 4,
            "Wallet4", 4,
            "WhiskeyFull", 10,
        }
    }
}

VehicleDistributions.en88_F40 = {
    GloveBox = VehicleDistributions.GloveBoxen88_F40;
    TruckBed = VehicleDistributions.TrunkSports;
}

distributionTable["en88_F40"] = { Normal = VehicleDistributions.en88_F40; }