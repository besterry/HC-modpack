VehicleZoneDistribution = VehicleZoneDistribution or {};

-- Agro spawn --
-- Important! For spawn rate changing you should increase the area in "agrozones.lua" file. Don't change "spawnChance" here.

VehicleZoneDistribution.agrofarm = VehicleZoneDistribution.agrofarm or {}
VehicleZoneDistribution.agrofarm.vehicles = VehicleZoneDistribution.agrofarm.vehicles or {}
VehicleZoneDistribution.agrofarm.vehicles["Base.Agrotractor"] = {index = -1, spawnChance = 34};
VehicleZoneDistribution.agrofarm.vehicles["Base.TrailerAgroplough"] = {index = -1, spawnChance = 33};
VehicleZoneDistribution.agrofarm.vehicles["Base.TrailerAgroseeder"] = {index = -1, spawnChance = 33};
VehicleZoneDistribution.agrofarm.chanceToPartDamage = 20;
VehicleZoneDistribution.agrofarm.baseVehicleQuality = 0.7;
VehicleZoneDistribution.agrofarm.chanceToSpawnBurnt = 0;
VehicleZoneDistribution.agrofarm.randomAngle = true;
VehicleZoneDistribution.agrofarm.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.agrofarm.chanceToSpawnKey = 0;

VehicleZoneDistribution.agrotractor = VehicleZoneDistribution.agrotractor or {}
VehicleZoneDistribution.agrotractor.vehicles = VehicleZoneDistribution.agrotractor.vehicles or {}
VehicleZoneDistribution.agrotractor.vehicles["Base.Agrotractor"] = {index = -1, spawnChance = 100};
VehicleZoneDistribution.agrotractor.chanceToPartDamage = 20;
VehicleZoneDistribution.agrotractor.baseVehicleQuality = 0.7;
VehicleZoneDistribution.agrotractor.chanceToSpawnBurnt = 0;
VehicleZoneDistribution.agrotractor.randomAngle = true;
VehicleZoneDistribution.agrotractor.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.agrotractor.chanceToSpawnKey = 30;

VehicleZoneDistribution.agrotrailers = VehicleZoneDistribution.agrotrailers or {}
VehicleZoneDistribution.agrotrailers.vehicles = VehicleZoneDistribution.agrotrailers.vehicles or {}
VehicleZoneDistribution.agrotrailers.vehicles["Base.TrailerAgroplough"] = {index = -1, spawnChance = 50};
VehicleZoneDistribution.agrotrailers.vehicles["Base.TrailerAgroseeder"] = {index = -1, spawnChance = 50};
VehicleZoneDistribution.agrotrailers.chanceToPartDamage = 20;
VehicleZoneDistribution.agrotrailers.baseVehicleQuality = 0.7;
VehicleZoneDistribution.agrotrailers.chanceToSpawnBurnt = 0;
VehicleZoneDistribution.agrotrailers.randomAngle = true;
VehicleZoneDistribution.agrotrailers.chanceToSpawnSpecial = 0;
VehicleZoneDistribution.agrotrailers.chanceToSpawnKey = 0;