require "CommonTemplates/CommonDistributions"

local distributionTable = VehicleDistributions[1]
-- ATAJeepClassic ATAJeepArcher ATAJeepRubicon
distributionTable["ATAJeepClassic"] = {
    Normal = VehicleDistributions.NormalStandard,
    Specific = { VehicleDistributions.Hunter, VehicleDistributions.Fisherman, VehicleDistributions.Carpenter, VehicleDistributions.Farmer, VehicleDistributions.Electrician, VehicleDistributions.MetalWelder, VehicleDistributions.Survivalist, VehicleDistributions.ConstructionWorker, VehicleDistributions.Painter },
}
distributionTable["ATAJeepArcher"] = {
    Normal = VehicleDistributions.NormalStandard,
    Specific = { VehicleDistributions.Hunter, VehicleDistributions.Fisherman, VehicleDistributions.Carpenter, VehicleDistributions.Farmer, VehicleDistributions.Electrician, VehicleDistributions.MetalWelder, VehicleDistributions.Survivalist, VehicleDistributions.ConstructionWorker, VehicleDistributions.Painter },
}
distributionTable["ATAJeepRubicon"] = {
    Normal = VehicleDistributions.NormalStandard,
    Specific = { VehicleDistributions.Hunter, VehicleDistributions.Fisherman, VehicleDistributions.Carpenter, VehicleDistributions.Farmer, VehicleDistributions.Electrician, VehicleDistributions.MetalWelder, VehicleDistributions.Survivalist, VehicleDistributions.ConstructionWorker, VehicleDistributions.Painter },
}

table.insert(VehicleDistributions, 1, distributionTable);


