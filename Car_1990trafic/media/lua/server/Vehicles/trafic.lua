local distributionTable = VehicleDistributions[1]


VehicleDistributions.TrunktraficLechero = {
    rolls = 5,
    items = {
            "EmptyJar", 4,
            "Milk", 80,
            "EggCarton", 20,
            "Icecream", 50,
            "Butter", 50,
            "Cheese", 40,
            "Yoghurt", 70,
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




VehicleDistributions.trafic = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunkHeavy;
    TruckBedOpen = VehicleDistributions.TrunkHeavy;
}

VehicleDistributions.traficRojo = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunkHeavy;
    TruckBedOpen = VehicleDistributions.TrunkHeavy;
}

VehicleDistributions.traficNegro = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunkHeavy;
    TruckBedOpen = VehicleDistributions.TrunkHeavy;
}

VehicleDistributions.traficAmarillo = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunkHeavy;
    TruckBedOpen = VehicleDistributions.TrunkHeavy;
}

VehicleDistributions.traficVerde = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunkHeavy;
    TruckBedOpen = VehicleDistributions.TrunkHeavy;
}

VehicleDistributions.traficLechero = {

    GloveBox = VehicleDistributions.GloveBox;
    TruckBed = VehicleDistributions.TrunktraficLechero;
    TruckBedOpen = VehicleDistributions.TrunktraficLechero;
}

VehicleDistributions.traficATC = {

    GloveBox = VehicleDistributions.RadioGloveBox;
	TruckBed = VehicleDistributions.RadioTruckBed;
    TruckBedOpen = VehicleDistributions.RadioTruckBed;
}

VehicleDistributions.traficPasajeros = {

    GloveBox = VehicleDistributions.PostalGloveBox;
    TruckBed = VehicleDistributions.PostalTruckBed;
    TruckBedOpen = VehicleDistributions.PostalTruckBed;
}

VehicleDistributions.traficAmbulancia = {

    GloveBox = VehicleDistributions.AmbulanceGloveBox;
    TruckBed = VehicleDistributions.AmbulanceTruckBed;
    TruckBedOpen = VehicleDistributions.AmbulanceTruckBed;
}

VehicleDistributions.traficCamper = {

    GloveBox = VehicleDistributions.HunterGloveBox;
    TruckBed = VehicleDistributions.HunterTruckBed;
    TruckBedOpen = VehicleDistributions.HunterTruckBed;
}


distributionTable["1990trafic"] = { Normal = VehicleDistributions.trafic; }
distributionTable["1990traficRojo"] = { Normal = VehicleDistributions.traficRojo; }
distributionTable["1990traficNegro"] = { Normal = VehicleDistributions.traficNegro; }
distributionTable["1990traficAmarillo"] = { Normal = VehicleDistributions.traficAmarillo; }
distributionTable["1990traficVerde"] = { Normal = VehicleDistributions.traficVerde; }
distributionTable["1990traficLechero"] = { Normal = VehicleDistributions.traficLechero; }
distributionTable["1990traficATC"] = { Normal = VehicleDistributions.traficATC; }
distributionTable["1990traficPasajeros"] = { Normal = VehicleDistributions.traficPasajeros; }
distributionTable["1990traficAmbulancia"] = { Normal = VehicleDistributions.traficAmbulancia; }
distributionTable["1990traficCamper"] = { Normal = VehicleDistributions.traficCamper; }