require "Items/ProceduralDistributions"

local list = ProceduralDistributions.list
local targets = {ArtStorePen = 5, BedroomSideTable = 1, BookstoreStationery = 5,
	ClassroomDesk = 3, ClassroomMisc = 3, ClassroomShelves = 3,
	CrateOfficeSupplies = 3, CrateRandomJunk = 0.5, DeskGeneric = 3,
	GigamartSchool = 3, KitchenRandom = 3, LibraryCounter = 3,
	LivingRoomShelf = 0.8, LivingRoomShelfNoTapes = 0.8, Locker = 2,
	OfficeCounter = 3, OfficeDesk = 3, OfficeDeskHome = 3, OfficeDrawers = 3,
	OfficeShelfSupplies = 5, PoliceDesk = 3, PostOfficeSupplies = 3,
	RandomFiller = 1, SchoolLockers = 1, ShelfGeneric = 0.8}
local item = "BicPen.BicPen"

for k,v in pairs(targets) do
	table.insert(list[k].items, item)
	table.insert(list[k].items, v)
end

targets = {counter = 2, inventoryfemale = 0.8, inventorymale = 0.8, sidetable = 2}
for k,v in pairs(targets) do
	table.insert(Distributions[1].all[k].items, item)
	table.insert(Distributions[1].all[k].items, v)
end

targets = {Bag_WorkerBag = 1, Bag_Schoolbag = 1, Briefcase = 5, Suitcase = 3}
for k,v in pairs(targets) do
	table.insert(Distributions[1][k].items, item)
	table.insert(Distributions[1][k].items, v)
end

