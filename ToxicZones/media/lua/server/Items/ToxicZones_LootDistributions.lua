require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

--All tables
table.insert(SuburbsDistributions["all"]["counter"].junk, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["counter"].junk, 0.2);

table.insert(SuburbsDistributions["all"]["crate"].items, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["crate"].items, 0.01);

table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["inventoryfemale"].items, 0.001);

table.insert(SuburbsDistributions["all"]["inventorymale"].items, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["inventorymale"].items, 0.001);

table.insert(SuburbsDistributions["all"]["metal_shelves"].items, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["metal_shelves"].items, 0.01);

table.insert(SuburbsDistributions["all"]["sidetable"].junk, "ContaminantDetector");
table.insert(SuburbsDistributions["all"]["sidetable"].junk, 0.005);

table.insert(SuburbsDistributions["Bag_ALICEpack_Army"].items, "ContaminantDetector");
table.insert(SuburbsDistributions["Bag_ALICEpack_Army"].items, 0.01);

--Army Hangar Outfit
table.insert(ProceduralDistributions["list"]["ArmyHangarOutfit"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["ArmyHangarOutfit"].items, 0.05);

--Army Storage Electronics
table.insert(ProceduralDistributions["list"]["ArmyStorageElectronics"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["ArmyStorageElectronics"].items, 0.5);

--Army Storage Outfit
table.insert(ProceduralDistributions["list"]["ArmyStorageOutfit"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["ArmyStorageOutfit"].items, 0.05);

--BookstoreMisc
table.insert(ProceduralDistributions["list"]["BookstoreMisc"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["BookstoreMisc"].items, 2);

--Control Room Counter
table.insert(ProceduralDistributions["list"]["ControlRoomCounter"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["ControlRoomCounter"].items, 0.05);

--Crate Electronics
table.insert(ProceduralDistributions["list"]["CrateElectronics"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["CrateElectronics"].items, 0.05);

--Crate Magazines
table.insert(ProceduralDistributions["list"]["CrateMagazines"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["CrateMagazines"].items, 0.75);

--Crate Random Junk
table.insert(ProceduralDistributions["list"]["CrateRandomJunk"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["CrateRandomJunk"].items, 0.001);

--Engineer Tools
table.insert(ProceduralDistributions["list"]["EngineerTools"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["EngineerTools"].items, 0.05);

--Library Books
table.insert(ProceduralDistributions["list"]["LibraryBooks"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LibraryBooks"].items, 0.75);

-- Living Room Shelf
table.insert(ProceduralDistributions["list"]["LivingRoomShelf"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LivingRoomShelf"].items, 0.075);

-- Living Room Shelf (no tapes)
table.insert(ProceduralDistributions["list"]["LivingRoomShelfNoTapes"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LivingRoomShelfNoTapes"].items, 0.075);

--Locker Army Bedroom
table.insert(ProceduralDistributions["list"]["LockerArmyBedroom"].items, "ContaminantDetector");
table.insert(ProceduralDistributions["list"]["LockerArmyBedroom"].items, 0.5);

-- Magazine rack mixed
table.insert(ProceduralDistributions["list"]["MagazineRackMixed"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["MagazineRackMixed"].items, 0.3);

--postbox (general)
table.insert(SuburbsDistributions["all"]["postbox"].items, "RadiationMag");
table.insert(SuburbsDistributions["all"]["postbox"].items, 0.2);

--Postal
table.insert(VehicleDistributions["Postal"]["TruckBed"].items, "RadiationMag");
table.insert(VehicleDistributions["Postal"]["TruckBed"].items, 1);