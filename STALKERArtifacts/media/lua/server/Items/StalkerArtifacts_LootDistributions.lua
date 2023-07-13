require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'

local mods = getActivatedMods();
local dontLoad = false;
for i=0, mods:size()-1, 1 do
	if mods:get(i) == "ToxicZonesSTALKER" then
		dontLoad = true
	end
end

if dontload == false then

--BookstoreMisc
table.insert(ProceduralDistributions["list"]["BookstoreMisc"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["BookstoreMisc"].items, 2);

--Crate Magazines
table.insert(ProceduralDistributions["list"]["CrateMagazines"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["CrateMagazines"].items, 0.75);

--Library Books
table.insert(ProceduralDistributions["list"]["LibraryBooks"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LibraryBooks"].items, 0.75);

-- Living Room Shelf
table.insert(ProceduralDistributions["list"]["LivingRoomShelf"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LivingRoomShelf"].items, 0.075);

-- Living Room Shelf (no tapes)
table.insert(ProceduralDistributions["list"]["LivingRoomShelfNoTapes"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["LivingRoomShelfNoTapes"].items, 0.075);

-- Magazine rack mixed
table.insert(ProceduralDistributions["list"]["MagazineRackMixed"].items, "RadiationMag");
table.insert(ProceduralDistributions["list"]["MagazineRackMixed"].items, 0.3);

--postbox (general)
table.insert(SuburbsDistributions["all"]["postbox"].items, "RadiationMag");
table.insert(SuburbsDistributions["all"]["postbox"].items, 0.2);

--Postal
table.insert(VehicleDistributions["Postal"]["TruckBed"].items, "RadiationMag");
table.insert(VehicleDistributions["Postal"]["TruckBed"].items, 1);

end