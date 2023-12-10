if VehicleZoneDistribution then

-- 1993 Saab 900 Turbo
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en93-900Turbo"] = {index = -1, spawnChance = 2};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en93-900Turbo"] = {index = -1, spawnChance = 2};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en93-900Turbo"] = {index = -1, spawnChance = 4};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en93-900Turbo"] = {index = -1, spawnChance = 2};

-- normal burnt cars.
VehicleZoneDistribution.normalburnt.vehicles["Base.en93-900Turbo_Torch"] = {index = -1, spawnChance = 2};

end