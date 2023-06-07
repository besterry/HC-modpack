require "CommonTemplates/CommonDistributions"
require "ATA/ATATruckItemDistributions"

local distributionTable = VehicleDistributions[1]

-- ATAArmyBus ATASchoolBus ATAPrisonBus
distributionTable["ATAArmyBus"] = {
    Normal = VehicleDistributions.Ranger,
}

distributionTable["ATASchoolBus"] = {
    Normal = VehicleDistributions.NormalStandard,
    Specific = { VehicleDistributions.Fisherman, VehicleDistributions.Carpenter, VehicleDistributions.Farmer, VehicleDistributions.Electrician, VehicleDistributions.MetalWelder, VehicleDistributions.Survivalist, VehicleDistributions.ConstructionWorker, VehicleDistributions.Painter},
}

distributionTable["ATAPrisonBus"] = {
    Normal = VehicleDistributions.Police,
}

table.insert(VehicleDistributions, 1, distributionTable);


