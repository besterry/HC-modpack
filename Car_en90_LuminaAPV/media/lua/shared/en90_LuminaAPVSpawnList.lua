if VehicleZoneDistribution then

-- 1990 Chevrolet Lumina APV
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en90_LuminaAPV"] = {index = -1, spawnChance = 3};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en90_LuminaAPV"] = {index = -1, spawnChance = 3};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en90_LuminaAPV"] = {index = -1, spawnChance = 3};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en90_LuminaAPV"] = {index = -1, spawnChance = 1};

-- normal burnt cars.
VehicleZoneDistribution.normalburnt.vehicles["Base.en90_LuminaAPV_Burned"] = {index = -1, spawnChance = 2};

end