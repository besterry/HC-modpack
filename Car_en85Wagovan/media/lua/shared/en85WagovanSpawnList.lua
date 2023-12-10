if VehicleZoneDistribution then

-- 1985 Honda Civic Wagon
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 4};

-- Trailer Parks, have a chance to spawn burnt cars, some on top of each others, it's like a pile of junk cars
VehicleZoneDistribution.trailerpark.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 3};

-- bad vehicles, moslty used in poor area, sometimes around pub etc.
VehicleZoneDistribution.bad.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 2};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 5};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 3};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en85Wagovan"] = {index = -1, spawnChance = 1};

end