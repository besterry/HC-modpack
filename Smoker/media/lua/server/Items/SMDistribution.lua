require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'
require 'Vehicles/VehicleDistributions'

-- Normal distribution
--bin

table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMEmptyPack");
table.insert(SuburbsDistributions["all"]["bin"].items, 2.0);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMEmptyPackLight");
table.insert(SuburbsDistributions["all"]["bin"].items, 1.0);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMEmptyPackMenthol");
table.insert(SuburbsDistributions["all"]["bin"].items, 1.0);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMEmptyPackGold");
table.insert(SuburbsDistributions["all"]["bin"].items, 0.5);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMButt");
table.insert(SuburbsDistributions["all"]["bin"].items, 4.0);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.SMButt2");
table.insert(SuburbsDistributions["all"]["bin"].items, 3.0);
table.insert(SuburbsDistributions["all"]["bin"].items, "SM.ChocolateFoil");
table.insert(SuburbsDistributions["all"]["bin"].items, 1.0);

if not getActivatedMods():contains("10YL_ALL") then
--inventorymale
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "SM.SMNicorette");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.0005);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "SM.Matches");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.01);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "SM.SMPack");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.01);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "SM.SMPackLight");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.001);
table.insert(SuburbsDistributions["all"]["inventorymale"].items, "SM.SMPackGold");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.0001);

--inventoryfemale
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.SMNicorette");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.001);
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.Matches");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.01);
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.SMPack");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.01);
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.SMPackLight");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.001);
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.SMPackMenthol");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.001);
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "SM.SMPackGold");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.0001);

--sidetable
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMPack");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.02);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMPackLight");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.02);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMPackMenthol");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.02);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMPackGold");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.005);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMCartonCigarettesLight");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.002);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMCartonCigarettesMenthol");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.001);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMCartonCigarettesGold");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 0.0001);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.Ashtray");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 3.0);
table.insert(SuburbsDistributions["all"]["sidetable"].items, "SM.SMLighterFluid");
table.insert(SuburbsDistributions["all"]["sidetable"].items, 1.0);


--officedrawers
--[[
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMPackLight");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.8);
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMPackMenthol");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.5);
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMPackGold");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.05);
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMCartonCigarettesLight");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.1);
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMCartonCigarettesMenthol");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.1);
table.insert(SuburbsDistributions["all"]["officedrawers"].items, "SM.SMCartonCigarettesGold");
table.insert(SuburbsDistributions["all"]["officedrawers"].items, 0.005);
--]]

--other

--Procedural Distributions
--BarCounterMisc
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMFullPack");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.4);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMFullPackLight");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.3);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMFullPackMenthol");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.2);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMFullPackGold");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.1);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.05);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.04);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.03);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 0.01);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 4);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.SMLighterFluid");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 3);
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["BarCounterMisc"].items, 3);

--Janitor
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.03);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.02);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.001);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0,02);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.02);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.01);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.005);
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, "SM.SMLighterFluid");
table.insert(ProceduralDistributions["list"]["JanitorMisc"].items, 0.5);

--Kitchen
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.03);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.02);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.01);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.04);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.03);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.02);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 0.005);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 5);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 2);
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, "SM.SMLighterFluid");
table.insert(ProceduralDistributions["list"]["KitchenRandom"].items, 2);

--Locker
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.03);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.02);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.01);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.04);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.003);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.002);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["Locker"].items, 0.001);
table.insert(ProceduralDistributions["list"]["Locker"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["Locker"].items, 2);

--LockerClassy
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.3);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.2);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.01);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.004);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.003);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.002);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 0.001);
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["LockerClassy"].items, 1);

--PrisonCellRandom
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.04);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.03);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.01);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.03);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.02);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.01);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.001);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 1);
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["PrisonCellRandom"].items, 0.1);

--StoreCounterTobacco
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 5);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.Lighter");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 2);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMFullPack");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 1);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMFullPackLight");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.2);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMFullPackMenthol");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.1);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMFullPackGold");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.05);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMCartonCigarettes");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.3);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMCartonCigarettesLight");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.2);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMCartonCigarettesMenthol");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.1);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMCartonCigarettesGold");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 0.05);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.SMLighterFluid");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 1);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 2);
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["StoreCounterTobacco"].items, 2);

--WardrobeChild
table.insert(ProceduralDistributions["list"]["WardrobeChild"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["WardrobeChild"].items, 0.001);
table.insert(ProceduralDistributions["list"]["WardrobeChild"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["WardrobeChild"].items, 0.01);

--WardrobeMan
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, 0.01);
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, "SM.SMPackGold");
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, 0.001);
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, "SM.SMLighterFluid");
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, 0.5);
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, 1.0);
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, "SM.Matches");
table.insert(ProceduralDistributions["list"]["WardrobeMan"].items, 0.5);

--WardrobeRedneck
table.insert(ProceduralDistributions["list"]["WardrobeRedneck"].items, "SM.SMPackMenthol");
table.insert(ProceduralDistributions["list"]["WardrobeRedneck"].items, 1);

--WardrobeWoman
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, "SM.SMPackLight");
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, 0.1);
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, "SM.SMNicorette");
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, 2);
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, "SM.Ashtray");
table.insert(ProceduralDistributions["list"]["WardrobeWoman"].items, 2);

--MedicalClinicDrugs
table.insert(ProceduralDistributions["list"]["MedicalClinicDrugs"].items, "SM.SMNicoretteBox");
table.insert(ProceduralDistributions["list"]["MedicalClinicDrugs"].items, 2);

--MedicalStorageDrugs
table.insert(ProceduralDistributions["list"]["MedicalStorageDrugs"].items, "SM.SMNicoretteBox");
table.insert(ProceduralDistributions["list"]["MedicalStorageDrugs"].items, 2);

--Vehicle Distributions
--GloveBox SM.SMNicorette SM.SMPack

table.insert(VehicleDistributions["GloveBox"].items, "SM.SMLighterFluid");
table.insert(VehicleDistributions["GloveBox"].items, 0.01);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMPack");
table.insert(VehicleDistributions["GloveBox"].items, 0.05);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMNicorette");
table.insert(VehicleDistributions["GloveBox"].items, 0.01);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMPackLight");
table.insert(VehicleDistributions["GloveBox"].items, 0.03);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMPackMenthol");
table.insert(VehicleDistributions["GloveBox"].items, 0.02);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMPackGold");
table.insert(VehicleDistributions["GloveBox"].items, 0.01);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMCartonCigarettes");
table.insert(VehicleDistributions["GloveBox"].items, 0.0004);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMCartonCigarettesLight");
table.insert(VehicleDistributions["GloveBox"].items, 0.0003);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMCartonCigarettesMenthol");
table.insert(VehicleDistributions["GloveBox"].items, 0.0002);
table.insert(VehicleDistributions["GloveBox"].items, "SM.SMCartonCigarettesGold");
table.insert(VehicleDistributions["GloveBox"].items, 0.0001);
table.insert(VehicleDistributions["GloveBox"].items, "SM.Matches");
table.insert(VehicleDistributions["GloveBox"].items, 0.05);
end