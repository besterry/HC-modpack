if VehicleZoneDistribution then

-- 1984 Ford Bronco II
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 2};

-- Trailer Parks, have a chance to spawn burnt cars, some on top of each others, it's like a pile of junk cars
VehicleZoneDistribution.trailerpark.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 2};

-- bad vehicles, moslty used in poor area, sometimes around pub etc.
VehicleZoneDistribution.bad.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 1};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 2};

-- good vehicles, used in good looking area, they're meant to spawn only good cars, so they're on every good looking house.
VehicleZoneDistribution.good.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 1};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en83Bronco2"] = {index = -1, spawnChance = 2};

end