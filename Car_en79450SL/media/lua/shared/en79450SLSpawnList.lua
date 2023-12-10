if VehicleZoneDistribution then

-- 1979 Mercedes-Benz 450SL convertible
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en79450SL"] = {index = -1, spawnChance = 1};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en79450SL"] = {index = -1, spawnChance = 1};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en79450SL"] = {index = -1, spawnChance = 2};

-- sports vehicles, sometimes on good looking area.
VehicleZoneDistribution.sport.vehicles["Base.en79450SL"] = {index = -1, spawnChance = 1};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en79450SL"] = {index = -1, spawnChance = 1};

end