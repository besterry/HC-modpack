if VehicleZoneDistribution then

-- 1971 Chrysler New Yorker
-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en71_NewYorker"] = {index = -1, spawnChance = 3};

-- Trailer Parks, have a chance to spawn burnt cars, some on top of each others, it's like a pile of junk cars
VehicleZoneDistribution.trailerpark.vehicles["Base.en71_NewYorker"] = {index = -1, spawnChance = 2};

-- bad vehicles, moslty used in poor area, sometimes around pub etc.
VehicleZoneDistribution.bad.vehicles["Base.en71_NewYorker"] = {index = -1, spawnChance = 3};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en71_NewYorker"] = {index = -1, spawnChance = 3};

-- normal burnt cars.
VehicleZoneDistribution.normalburnt.vehicles["Base.en71_NewYorker_Burned"] = {index = -1, spawnChance = 2};

end