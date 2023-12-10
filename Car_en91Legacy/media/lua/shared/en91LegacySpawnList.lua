if VehicleZoneDistribution then

-- 1991 Subaru Legacy wagon
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en91Legacy"] = {index = -1, spawnChance = 4};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en91Legacy"] = {index = -1, spawnChance = 3};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en91Legacy"] = {index = -1, spawnChance = 2};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en91Legacy"] = {index = -1, spawnChance = 2};

end