Events.OnPreDistributionMerge.Add(function() --OnPreDistributionMerge OnServerStarted OnGameBoot

require "Items/SuburbsDistributions"
require "Items/ProceduralDistributions"
require "Vehicles/VehicleDistributions"
require "Items/ItemPicker"	
	local Sandbox = SandboxVars.itemGPS.GpsDistributionMultiplier
	if Sandbox == 0 then return end
	local Multiplier = Sandbox + (Sandbox -1)
	--print("DistributionsMultiplier : "..Multiplier)

--	SuburbsDistributions.all.Outfit_Tourist = SuburbsDistributions.all.Outfit_Tourist or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(SuburbsDistributions["all"]["Outfit_Tourist"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_Tourist"].items, 0.05*Multiplier);

----------------------------------------------

--	SuburbsDistributions.all.Outfit_Camper = SuburbsDistributions.all.Outfit_Camper or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(SuburbsDistributions["all"]["Outfit_Camper"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_Camper"].items, 0.25*Multiplier);

	SuburbsDistributions.all.Outfit_Survivalist = SuburbsDistributions.all.Outfit_Survivalist or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist"].items, 0.07*Multiplier);

	SuburbsDistributions.all.Outfit_Survivalist02 = SuburbsDistributions.all.Outfit_Survivalist02 or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist02"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist02"].items, 0.07*Multiplier);

	SuburbsDistributions.all.Outfit_Survivalist03 = SuburbsDistributions.all.Outfit_Survivalist03 or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist03"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Survivalist03"].items, 0.07*Multiplier);

----------------------------------------------

--	SuburbsDistributions.all.Outfit_AmbulanceDriver = SuburbsDistributions.all.Outfit_AmbulanceDriver or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(SuburbsDistributions["all"]["Outfit_AmbulanceDriver"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_AmbulanceDriver"].items, 0.25*Multiplier);	
--
--	SuburbsDistributions.all.Outfit_FiremanFullSuit = SuburbsDistributions.all.Outfit_FiremanFullSuit or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
--	table.insert(SuburbsDistributions["all"]["Outfit_FiremanFullSuit"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_FiremanFullSuit"].items, 0.2*Multiplier);	
--
----------------------------------------------
--	SuburbsDistributions.all.Outfit_Police = SuburbsDistributions.all.Outfit_Police or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
--	table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_Police"].items, 0.4*Multiplier);
--
--		
--	SuburbsDistributions.all.Outfit_PoliceState = SuburbsDistributions.all.Outfit_PoliceState or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
--	table.insert(SuburbsDistributions["all"]["Outfit_PoliceState"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["all"]["Outfit_PoliceState"].items, 0.55*Multiplier);	

----------------------------------------------
	SuburbsDistributions.all.Outfit_PrivateMilitia = SuburbsDistributions.all.Outfit_PrivateMilitia or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_PrivateMilitia"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_PrivateMilitia"].items, 0.3*Multiplier);	

------------------------------------------------
	SuburbsDistributions.all.Outfit_Ranger = SuburbsDistributions.all.Outfit_Ranger or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_Ranger"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Ranger"].items, 0.5*Multiplier);	

	SuburbsDistributions.all.Outfit_Hunter = SuburbsDistributions.all.Outfit_Hunter or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_Hunter"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Hunter"].items, 0.4*Multiplier);	

----------------------------------------------
	SuburbsDistributions.all.Outfit_Ghillie = SuburbsDistributions.all.Outfit_Ghillie or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_Ghillie"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_Ghillie"].items, 0.8*Multiplier);	

	SuburbsDistributions.all.Outfit_ArmyCamoGreen = SuburbsDistributions.all.Outfit_ArmyCamoGreen or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_ArmyCamoGreen"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_ArmyCamoGreen"].items, 0.8*Multiplier);	

	SuburbsDistributions.all.Outfit_ArmyCamoDesert = SuburbsDistributions.all.Outfit_ArmyCamoDesert or {rolls = 1,items = {},junk= {rolls =1, items={}}}	
	table.insert(SuburbsDistributions["all"]["Outfit_ArmyCamoDesert"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["all"]["Outfit_ArmyCamoDesert"].items, 0.8*Multiplier);	


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

	SuburbsDistributions.Bag_WeaponBag = SuburbsDistributions.Bag_WeaponBag or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["Bag_WeaponBag"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["Bag_WeaponBag"].items, 0.2*Multiplier);	
	
	SuburbsDistributions.Bag_SurvivorBag = SuburbsDistributions.Bag_SurvivorBag or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["Bag_SurvivorBag"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["Bag_SurvivorBag"].items, 0.2*Multiplier);
	
	SuburbsDistributions.SurvivorCache1.SurvivorCrate = SuburbsDistributions.SurvivorCache1.SurvivorCrate or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["SurvivorCache1"]["SurvivorCrate"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["SurvivorCache1"]["SurvivorCrate"].items, 0.2*Multiplier);	
	
	SuburbsDistributions.SurvivorCache2.SurvivorCrate = SuburbsDistributions.SurvivorCache2.SurvivorCrate or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["SurvivorCache2"]["SurvivorCrate"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["SurvivorCache2"]["SurvivorCrate"].items, 0.2*Multiplier);

--	SuburbsDistributions.Bag_ALICEpack = SuburbsDistributions.Bag_ALICEpack or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(SuburbsDistributions["Bag_ALICEpack"].items, "Base.GPSdayz");--
--	table.insert(SuburbsDistributions["Bag_ALICEpack"].items, 0.6*Multiplier);

	SuburbsDistributions.Bag_ALICEpack_Army = SuburbsDistributions.Bag_ALICEpack_Army or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["Bag_ALICEpack_Army"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["Bag_ALICEpack_Army"].items, 0.75*Multiplier);

	SuburbsDistributions.Bag_Military = SuburbsDistributions.Bag_Military or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(SuburbsDistributions["Bag_Military"].items, "Base.GPSdayz");--
	table.insert(SuburbsDistributions["Bag_Military"].items, 0.8*Multiplier);


	
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
	--local Multiplier = SandboxVars.itemGPS.DistributionMultiplier
	--if Multiplier > 1 then
	--	Multiplier = Multiplier *2 
	--end

--	table.insert(ProceduralDistributions.list["CrateRandomJunk"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["CrateRandomJunk"].items, 0.01*Multiplier);
--
--
----------------------------------------------------------
--
--	table.insert(ProceduralDistributions.list["ControlRoomCounter"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["ControlRoomCounter"].items, 0.8*Multiplier);
--
--	table.insert(ProceduralDistributions.list["JanitorMisc"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["JanitorMisc"].items, 0.5*Multiplier);
--
--	table.insert(ProceduralDistributions.list["CrateElectronics"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["CrateElectronics"].items, 0.1*Multiplier);
--
--	table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["ElectronicStoreMisc"].items, 0.8*Multiplier);
--
--	table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["StoreShelfElectronics"].items, 0.8*Multiplier);
--
--	table.insert(ProceduralDistributions.list["GigamartHouseElectronics"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["GigamartHouseElectronics"].items, 0.8*Multiplier);
--
--	table.insert(ProceduralDistributions.list["CampingLockers"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["CampingLockers"].items, 0.05*Multiplier);


--------------------------------------------------------

--	table.insert(ProceduralDistributions.list["CampingStoreGear"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["CampingStoreGear"].items, 0.05*Multiplier);

	--table.insert(ProceduralDistributions.list["ElectronicStoreHAMRadio"].items, "Base.GPSdayz");--
	--table.insert(ProceduralDistributions.list["ElectronicStoreHAMRadio"].items, 3.6*Multiplier);

--	table.insert(ProceduralDistributions.list["GunStoreCounter"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["GunStoreCounter"].items, 0.3*Multiplier);

	table.insert(ProceduralDistributions.list["GunStoreDisplayCase"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["GunStoreDisplayCase"].items, 0.3*Multiplier);

--	table.insert(ProceduralDistributions.list["GunStoreShelf"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["GunStoreShelf"].items, 0.3*Multiplier);

	--table.insert(ProceduralDistributions.list["FirearmWeapons"].items, "Base.GPSdayz");--
	--table.insert(ProceduralDistributions.list["FirearmWeapons"].items, 0.35*Multiplier);


---------------------------------------------------------


--	table.insert(ProceduralDistributions.list["FireDeptLockers"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["FireDeptLockers"].items, 0.2*Multiplier);
--
--	table.insert(ProceduralDistributions.list["FireStorageOutfit"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["FireStorageOutfit"].items, 0.2*Multiplier);
--
--    --table.insert(ProceduralDistributions.list["PoliceStorageGuns"].items, "Base.GPSdayz");--
--	--table.insert(ProceduralDistributions.list["PoliceStorageGuns"].items, 1.35*Multiplier);
--
--	--table.insert(ProceduralDistributions.list["PoliceStorageAmmunition"].items, "Base.GPSdayz");--
--	--table.insert(ProceduralDistributions.list["PoliceStorageAmmunition"].items, 1.35*Multiplier);
--	
--	table.insert(ProceduralDistributions.list["PoliceDesk"].items, "Base.GPSdayz");--
--	table.insert(ProceduralDistributions.list["PoliceDesk"].items, 0.2*Multiplier);

	table.insert(ProceduralDistributions.list["PoliceLockers"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["PoliceLockers"].items, 0.1*Multiplier);

	table.insert(ProceduralDistributions.list["PoliceStorageOutfit"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["PoliceStorageOutfit"].items, 0.1*Multiplier);


-----------------------------------------------------------
	table.insert(ProceduralDistributions.list["LockerArmyBedroom"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["LockerArmyBedroom"].items, 0.3*Multiplier);	

	table.insert(ProceduralDistributions.list["ArmyHangarOutfit"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["ArmyHangarOutfit"].items, 0.8*Multiplier);

	--table.insert(ProceduralDistributions.list["ArmyStorageGuns"].items, "Base.GPSdayz");--
	--table.insert(ProceduralDistributions.list["ArmyStorageGuns"].items, 0.5*Multiplier);

	table.insert(ProceduralDistributions.list["ArmySurplusMisc"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["ArmySurplusMisc"].items, 0.3*Multiplier);

	table.insert(ProceduralDistributions.list["ArmyStorageElectronics"].items, "Base.GPSdayz");--
	table.insert(ProceduralDistributions.list["ArmyStorageElectronics"].items, 1*Multiplier);
	
	

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
	--local Multiplier = SandboxVars.itemGPS.DistributionMultiplier
	--if Multiplier > 1 then
	--	Multiplier = Multiplier *2
	--	print("VehicleDistributionsMultiplier : "..Multiplier)
	--end

--	VehicleDistributions.GloveBox = VehicleDistributions.GloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(VehicleDistributions["GloveBox"].junk.items, "Base.GPSdayz");--
--	table.insert(VehicleDistributions["GloveBox"].junk.items, 0.001*Multiplier);	
----------------------------------------------		
	VehicleDistributions.SurvivalistTruckBed = VehicleDistributions.SurvivalistTruckBed or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["SurvivalistTruckBed"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["SurvivalistTruckBed"].junk.items, 0.2*Multiplier);
----------------------------------------------		
--	VehicleDistributions.FireGloveBox = VehicleDistributions.FireGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(VehicleDistributions["FireGloveBox"].junk.items, "Base.GPSdayz");--
--	table.insert(VehicleDistributions["FireGloveBox"].junk.items, 0.3*Multiplier);
--
--	VehicleDistributions.TaxiGloveBox = VehicleDistributions.TaxiGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(VehicleDistributions["TaxiGloveBox"].junk.items, "Base.GPSdayz");--
--	table.insert(VehicleDistributions["TaxiGloveBox"].junk.items, 0.2*Multiplier);
--
--	VehicleDistributions.PostalGloveBox = VehicleDistributions.PostalGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(VehicleDistributions["PostalGloveBox"].junk.items, "Base.GPSdayz");--
--	table.insert(VehicleDistributions["PostalGloveBox"].junk.items, 0.2*Multiplier);
--
--	VehicleDistributions.AmbulanceGloveBox = VehicleDistributions.AmbulanceGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
--	table.insert(VehicleDistributions["AmbulanceGloveBox"].junk.items, "Base.GPSdayz");--
--	table.insert(VehicleDistributions["AmbulanceGloveBox"].junk.items, 0.3*Multiplier);
----------------------------------------------
	VehicleDistributions.PoliceTruckBed = VehicleDistributions.PoliceTruckBed or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["PoliceTruckBed"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["PoliceTruckBed"].junk.items, 0.05*Multiplier);

	VehicleDistributions.PoliceGloveBox = VehicleDistributions.PoliceGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["PoliceGloveBox"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["PoliceGloveBox"].junk.items, 0.1*Multiplier);
----------------------------------------------
	VehicleDistributions.RangerTruckBed = VehicleDistributions.RangerTruckBed or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["RangerTruckBed"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["RangerTruckBed"].junk.items, 0.2*Multiplier);

	VehicleDistributions.RangerGloveBox = VehicleDistributions.RangerGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["RangerGloveBox"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["RangerGloveBox"].junk.items, 0.5*Multiplier);

	VehicleDistributions.HunterTruckBed = VehicleDistributions.HunterTruckBed or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["HunterTruckBed"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["HunterTruckBed"].junk.items, 0.2*Multiplier);	

	VehicleDistributions.HunterGloveBox = VehicleDistributions.HunterGloveBox or {rolls = 1,items = {},junk= {rolls =1, items={}}}
	table.insert(VehicleDistributions["HunterGloveBox"].junk.items, "Base.GPSdayz");--
	table.insert(VehicleDistributions["HunterGloveBox"].junk.items, 0.5*Multiplier);

	end)