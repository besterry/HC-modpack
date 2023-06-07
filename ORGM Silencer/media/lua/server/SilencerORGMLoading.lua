require "Item/SuburbsDistributions"
require "ORGMDistribution"

SSSilencer = {}

SSSilencer.getSprites = function()
	getTexture("Item_Silencer.png");	
	print (" ORGM Silencer / Suppressor Mod Sprites Loaded");
end
if(CivModTable) then table.insert(CivModTable, "Silencer.Silencer"); end
if (NonCivModTable) then table.insert(NonCivModTable, "Silencer.Silencer"); end
if (WeaponUpgrades) then
	if(WeaponUpgrades["Ber92"] ~= nil) then table.insert(WeaponUpgrades["Ber92"], "Silencer.Silencer"); end
	if(WeaponUpgrades["Glock17"] ~= nil) then table.insert(WeaponUpgrades["Glock17"], "Silencer.Silencer"); end
	if(WeaponUpgrades["M1911"] ~= nil) then table.insert(WeaponUpgrades["M1911"], "Silencer.Silencer"); end
	if(WeaponUpgrades["Glock20"] ~= nil) then table.insert(WeaponUpgrades["Glock20"], "Silencer.Silencer"); end
	if(WeaponUpgrades["Glock22"] ~= nil) then table.insert(WeaponUpgrades["Glock22"], "Silencer.Silencer"); end
	if(WeaponUpgrades["Glock21"] ~= nil) then table.insert(WeaponUpgrades["Glock21"], "Silencer.Silencer"); end
	if(WeaponUpgrades["Glock18"] ~= nil) then table.insert(WeaponUpgrades["Glock18"], "Silencer.Silencer"); end
	if(WeaponUpgrades["M16"] ~= nil) then table.insert(WeaponUpgrades["M16"], "Silencer.Silencer"); end
	if(WeaponUpgrades["AR15"] ~= nil) then table.insert(WeaponUpgrades["AR15"], "Silencer.Silencer"); end
	if(WeaponUpgrades["HKG3"] ~= nil) then table.insert(WeaponUpgrades["HKG3"], "Silencer.Silencer"); end
	if(WeaponUpgrades["HK91"] ~= nil) then table.insert(WeaponUpgrades["HK91"], "Silencer.Silencer"); end
	if(WeaponUpgrades["WaltherPPK"] ~= nil) then table.insert(WeaponUpgrades["WaltherPPK"], "Silencer.Silencer"); end
end
print (" ORGM Silencer / Suppressor Mod Loaded");

Events.OnGameBoot.Add(SSSilencer.getSprites);