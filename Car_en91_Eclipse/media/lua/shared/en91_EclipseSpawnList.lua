if VehicleZoneDistribution then

-- Parking Stall, common parking stall with random cars, the most used one (shop parking lots, houses etc.)
VehicleZoneDistribution.parkingstall.vehicles["Base.en91_Eclipse"] = {index = -1, spawnChance = 1};
VehicleZoneDistribution.parkingstall.vehicles["Base.en91_Talon"] = {index = -1, spawnChance = 1};

-- Trailer Parks, have a chance to spawn burnt cars, some on top of each others, it's like a pile of junk cars
VehicleZoneDistribution.trailerpark.vehicles["Base.en91_Eclipse"] = {index = -1, spawnChance = 1};
-- VehicleZoneDistribution.trailerpark.vehicles["Base.en91_EclipseTuner"] = {index = -1, spawnChance = 1};
VehicleZoneDistribution.trailerpark.vehicles["Base.en91_Talon"] = {index = -1, spawnChance = 1};

-- bad vehicles, moslty used in poor area, sometimes around pub etc.
VehicleZoneDistribution.bad.vehicles["Base.en91_Eclipse"] = {index = -1, spawnChance = 1};
-- VehicleZoneDistribution.bad.vehicles["Base.en91_EclipseTuner"] = {index = -1, spawnChance = 1};
VehicleZoneDistribution.bad.vehicles["Base.en91_Talon"] = {index = -1, spawnChance = 1};

-- medium vehicles, used in some of the good looking area, or in suburbs
VehicleZoneDistribution.medium.vehicles["Base.en91_Eclipse"] = {index = -1, spawnChance = 2};
VehicleZoneDistribution.medium.vehicles["Base.en91_Talon"] = {index = -1, spawnChance = 2};

-- junkyard, spawn damaged & burnt vehicles, less chance of finding keys but more cars.
-- also used for the random car crash.
VehicleZoneDistribution.junkyard.vehicles["Base.en91_Eclipse"] = {index = -1, spawnChance = 1};
VehicleZoneDistribution.junkyard.vehicles["Base.en91_Talon"] = {index = -1, spawnChance = 1};

-- normal burnt cars.
VehicleZoneDistribution.normalburnt.vehicles["Base.en91_Eclipse_Burned"] = {index = -1, spawnChance = 2};

end