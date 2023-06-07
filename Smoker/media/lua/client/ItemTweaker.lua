-- *********************************
-- ** DarkSlayerEX's Item Tweaker **
-- *********************************

if not ItemTweaker then  ItemTweaker = {} end
if not TweakItem then  TweakItem = {} end
if not TweakItemData then  TweakItemData = {} end

--Prep code to make the changes to all item in the TweakItemData table.
function ItemTweaker.tweakItems()
	local item;
	for k,v in pairs(TweakItemData) do
		for t,y in pairs(v) do
			item = ScriptManager.instance:getItem(k);
			if item ~= nil then
				item:DoParam(t.." = "..y);
			----print(k..": "..t..", "..y);
			end
		end
	end
end

function TweakItem(itemName, itemProperty, propertyValue)
	if not TweakItemData[itemName] then
		TweakItemData[itemName] = {};
	end
	TweakItemData[itemName][itemProperty] = propertyValue;
end

-- Modify Base Cigarettes --
TweakItem("Base.Cigarettes","Count", "1");
TweakItem("Base.Cigarettes","Weight", "0.05");
TweakItem("Base.Cigarettes","Type", "Normal");
TweakItem("Base.Cigarettes","Icon", "SMPackClosed");
TweakItem("Base.Cigarettes","CantBeFrozen", "TRUE");

--- Support Hydrocraft ---
if getActivatedMods():contains("Hydrocraft") then
	TweakItem("Hydrocraft.HCFuelcanister","Type", "Drainable"); -- Брелок канистра
	TweakItem("Hydrocraft.HCFuelcanister","UseDelta", "0.0"); -- Брелок канистра
	TweakItem("Hydrocraft.HCFuelcanister","Weight", "0.1"); -- Брелок канистра
	TweakItem("Hydrocraft.HCPipetobacco","StressChange", "-5"); -- Глинянная трубка
	TweakItem("Hydrocraft.HCPipetobacco","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");  -- Глинянная трубка
	TweakItem("Hydrocraft.HCCorncobpipetobacco","StressChange", "-5"); -- Кукурузная трубка
	TweakItem("Hydrocraft.HCCorncobpipetobacco","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter"); -- Кукурузная трубка
	TweakItem("Hydrocraft.HCCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCCigarhandrolled","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCPipetobacco","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCCorncobpipetobacco","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCPipeopiumpure","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCCorncobpipeopiumpure","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCBongfull","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCBongacrylicfull","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCPipehemp","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Hydrocraft.HCCorncobpipehemp","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");	
end

-- Support GreenFire mod ---
if getActivatedMods():contains("jiggasGreenfireMod") then
	TweakItem("Greenfire.Bong","Icon", "BongSmoker");
	TweakItem("Greenfire.WeedBong","Icon", "BongSmoker");
	TweakItem("Greenfire.TobaccoBong","Icon", "BongSmoker");
	TweakItem("Greenfire.ShakeBong","Icon", "BongSmoker");
	TweakItem("Greenfire.KiefBong","Icon", "BongSmoker");
	TweakItem("Greenfire.HashBong","Icon", "BongSmoker");
	TweakItem("Greenfire.Joint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.Spliff","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.Blunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.MixedBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfMixedBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.KiefBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfKiefBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HashBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfHashBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.SpaceBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfSpaceBlunt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfJoint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.KiefJoint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfKiefJoint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HashJoint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfHashJoint","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.WeedBong","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.WeedPipe","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.ShakeBong","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.ShakePipe","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.KiefBong","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.KiefPipe","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HashBong","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HashPipe","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.CannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.PreCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfPreCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.DelCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfDelCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.ResCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfResCannaCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.GFCigarette","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.BluntCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfBluntCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.GFCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.HalfCigar","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.TobaccoBong","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("Greenfire.TobaccoPipe","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
end

if not getActivatedMods():contains("SVGLittering") then
	TweakItemData["Base.Chocolate"] = { ["ReplaceOnUse"] = "SM.ChocolateFoil"};
end

--- Support Littering mod ---
if getActivatedMods():contains("SVGLittering") then
	TweakItem("littering.CigaretteButt","Weight", "0.001");
	TweakItem("littering.CigaretteButt","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("littering.CigaretteButt","Type", "Food");
	TweakItem("littering.CigaretteButt","DisplayName", "Butt");
	TweakItem("littering.CigaretteButt","StressChange", "-1");
	TweakItem("littering.CigaretteButt","UnhappyChange", "3");
	TweakItem("littering.CigaretteButt","Icon", "SVGCigaretteLButt");
	TweakItem("littering.CigaretteButt","CustomContextMenu", "Smoke");
	TweakItem("littering.CigaretteButt","CantBeFrozen", "TRUE");
	TweakItem("littering.CigaretteButt","OnEat", "OnEat_Cigarettes");
	TweakItem("littering.CigaretteButt","EatType", "Cigarettes");
	TweakItem("littering.CigaretteButt","CustomEatSound", "sm_smoking");
	TweakItem("littering.CigaretteButt","ReplaceOnUse", "SM.CarbonizedFilter");

	TweakItem("littering.CigaretteButtL","HungerChange", "0");
	TweakItem("littering.CigaretteButtL","Weight", "0.001");
	TweakItem("littering.CigaretteButtL","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("littering.CigaretteButtL","Type", "Food");
	TweakItem("littering.CigaretteButtL","DisplayName", "Butt");
	TweakItem("littering.CigaretteButtL","StressChange", "-1");
	TweakItem("littering.CigaretteButtL","UnhappyChange", "3");
	TweakItem("littering.CigaretteButtL","Icon", "SVGCigaretteLButt");
	TweakItem("littering.CigaretteButtL","CustomContextMenu", "Smoke");
	TweakItem("littering.CigaretteButtL","CantBeFrozen", "TRUE");
	TweakItem("littering.CigaretteButtL","OnEat", "OnEat_Cigarettes");
	TweakItem("littering.CigaretteButtL","EatType", "Cigarettes");
	TweakItem("littering.CigaretteButtL","CustomEatSound", "sm_smoking");
	TweakItem("littering.CigaretteButtL","ReplaceOnUse", "SM.CarbonizedFilter");

	TweakItem("littering.CigaretteButtM","HungerChange", "0");
	TweakItem("littering.CigaretteButtM","Weight", "0.001");
	TweakItem("littering.CigaretteButtM","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
	TweakItem("littering.CigaretteButtM","Type", "Food");
	TweakItem("littering.CigaretteButtM","DisplayName", "Butt");
	TweakItem("littering.CigaretteButtM","StressChange", "-1");
	TweakItem("littering.CigaretteButtM","UnhappyChange", "3");
	TweakItem("littering.CigaretteButtM","Icon", "SVGCigaretteLButt");
	TweakItem("littering.CigaretteButtM","CustomContextMenu", "Smoke");
	TweakItem("littering.CigaretteButtM","CantBeFrozen", "TRUE");
	TweakItem("littering.CigaretteButtM","OnEat", "OnEat_Cigarettes");
	TweakItem("littering.CigaretteButtM","EatType", "Cigarettes");
	TweakItem("littering.CigaretteButtM","CustomEatSound", "sm_smoking");
	TweakItem("littering.CigaretteButtM","ReplaceOnUse", "SM.CarbonizedFilter");
	
end

--- Support ExploringTime mod ---
if getActivatedMods():contains("ExploringTime") then
--	TweakItem("filcher.XXXXXXXXXX","RequireInHandOrInventory", "SM.SMFoil_Lighter/Base.Matches/SM.Matches/Base.Lighter");
end

Events.OnGameBoot.Add(ItemTweaker.tweakItems)