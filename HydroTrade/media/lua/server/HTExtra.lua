BoltsArrows = {};
BoltsArrows.SBolts = {x=0, y=1, z=2};
BoltsArrows.SArrows = {x=0, y=1, z=2};

Recipe = Recipe or {}
Recipe.OnCreate = Recipe.OnCreate or {}
Recipe.OnCreate.HydroTrade = Recipe.OnCreate.HydroTrade or {}

function recipe_htunpackkosmotsars(items, result, player)
    HCAddManySameItem("TAD.BobTA_African_Noodle_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_African_Rainbow_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Arms_Hip_Hop_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Arm_Push_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Arm_Wave_One_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Arm_Wave_Two_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Around_The_World_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Bboy_Hip_Hop_One_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Bboy_Hip_Hop_Three_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Bboy_Hip_Hop_Two_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Body_Wave_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Booty_Step_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Breakdance_Brooklyn_Uprock_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Cabbage_Patch_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Can_Can_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Chicken_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Crazy_Legs_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Defile_De_Samba_Parade_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Hokey_Pokey_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Kick_Step_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Macarena_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Maraschino_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_MoonWalk_One_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Northern_Soul_Spin_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Northern_Soul_Spin_On_Floor_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Raise_The_Roof_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Really_Twirl_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Rib_Pops_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Rockette_Kick_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Rumba_Dancing_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Running_Man_One_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Running_Man_Three_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Running_Man_Two_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Salsa_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Salsa_Double_Twirl_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Salsa_Double_Twirl_and_Clap_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Salsa_Side_to_Side_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Shimmy_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Shim_Sham_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Shuffling_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Side_to_Side_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Twist_One_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Twist_Two_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_Uprock_Indian_Step_Mag", 0, player);
    HCAddManySameItem("TAD.BobTA_YMCA_Mag", 0, player);
end

function recipe_htunpacksurvivorpack(items, result, player)
    HCAddManySameItem("Base.Bag_SurvivorBag", 0, player);
    HCAddManySameItem("Base.WaterBottleFull", 1, player);
    HCAddManySameItem("camping.CampfireKit", 0, player);
    HCAddManySameItem("Base.Axe", 0, player);
    HCAddManySameItem("Base.HuntingKnife", 0, player);
    HCAddManySameItem("Hydrocraft.HCMRE", 1, player);
    HCAddManySameItem("Base.Vest_BulletCivilian", 0, player);
    HCAddManySameItem("SM.Matches", 0, player);
    HCAddManySameItem("Base.Pot", 0, player);
    HCAddManySameItem("Hydrocraft.HCSleepingbagsleepin", 0, player);
end

function recipe_htunpackpolicepack(items, result, player)
    HCAddManySameItem("Base.Nightstick", 1, player);
    HCAddManySameItem("Base.Pistol", 0, player);
    HCAddManySameItem("Base.9mmClip", 0, player);
    HCAddManySameItem("Base.Bag_ZIP", 0, player);
    HCAddManySameItem("Base.Vest_BulletPolice", 0, player);
    HCAddManySameItem("Base.Hat_CrashHelmet_Police", 0, player);
    HCAddManySameItem("Base.Bullets9mmBox", 1, player);
    HCAddManySameItem("Base.HolsterDouble", 0, player);
    HCAddManySameItem("Base.Shoes_BlackBoots", 0, player);
end


function recipe_htunpackmilitarypack(items, result, player)
    HCAddManySameItem("Hydrocraft.HCShotgunSilencer", 0, player);
    HCAddManySameItem("Hydrocraft.HCUziSilencer", 0, player);
    HCAddManySameItem("Hydrocraft.HCAA12", 0, player);
    HCAddManySameItem("Hydrocraft.HCMagAA12", 0, player);
    HCAddManySameItem("Base.Pistol3", 0, player);
    HCAddManySameItem("Base.44Clip", 0, player);
    HCAddManySameItem("Base.Bag_ALICEpack_Army", 0, player);
    HCAddManySameItem("Base.Vest_BulletArmy", 0, player);
    HCAddManySameItem("Base.Hat_Army", 0, player);
    HCAddManySameItem("Base.Bullets44Box", 1, player);
    HCAddManySameItem("Base.ShotgunShellsBox", 3, player);
    HCAddManySameItem("Base.HolsterDouble", 0, player);
    HCAddManySameItem("Base.Shoes_BlackBoots", 0, player);
end

function recipe_htunpacksniperpack(items, result, player)
    HCAddManySameItem("Base.HuntingRifle", 0, player);
    HCAddManySameItem("Base.Revolver_Long", 0, player);
    HCAddManySameItem("Base.308Clip", 0, player);
    HCAddManySameItem("Base.Bag_Sniper_Pack", 0, player);
    HCAddManySameItem("Base.Hat_Killa_Visor", 0, player);
    HCAddManySameItem("Base.Hat_Killa", 0, player);
    HCAddManySameItem("Base.Armor_6B13", 0, player);
    HCAddManySameItem("Base.Ghillie_Top", 0, player);
    HCAddManySameItem("Base.308Box", 2, player);
    HCAddManySameItem("Base.Bullets44Box", 1, player);
    HCAddManySameItem("Base.HolsterDouble", 0, player);
    HCAddManySameItem("Base.Shoes_BlackBoots", 0, player);
end

function recipe_htunpackstormtrooperpack(items, result, player)
    HCAddManySameItem("Base.AssaultRifle2", 0, player);
    HCAddManySameItem("Base.Pistol2", 0, player);
    HCAddManySameItem("Base.M14Clip", 0, player);
    HCAddManySameItem("Base.45Clip", 0, player);
    HCAddManySameItem("Base.Bag_ARVN_Rucksack", 0, player);
    HCAddManySameItem("Base.Sheriff_Vest_Full", 0, player);
    HCAddManySameItem("Base.Hat_Maska_Visor", 0, player);
    HCAddManySameItem("Base.Hat_Maska", 0, player);
    HCAddManySameItem("Base.Bullets45Box", 1, player);
    HCAddManySameItem("Base.308Box", 2, player);
    HCAddManySameItem("Base.HolsterDouble", 0, player);
    HCAddManySameItem("Base.Shoes_BlackBoots", 0, player);
end

function recipe_htunpackswatpack(items, result, player)
    HCAddManySameItem("Base.Revolver_Long", 0, player);
    HCAddManySameItem("Base.AssaultRifle", 0, player);
    HCAddManySameItem("Base.556Clip", 0, player);
    HCAddManySameItem("Base.Bag_Tactical_Alice", 0, player);
    HCAddManySameItem("Base.Armor_Defender", 0, player);
    HCAddManySameItem("Base.Hat_RiotHelmet", 0, player);
    HCAddManySameItem("Base.Bullets44Box", 1, player);
    HCAddManySameItem("Base.556Box", 2, player);
    HCAddManySameItem("Base.HolsterDouble", 0, player);
    HCAddManySameItem("Base.Shoes_BlackBoots", 0, player);
end

--выдача миски
function recipe_htgiveBowl(items, result, player)
    HCAddManySameItem("Base.Bowl", 0, player);
end

--выдача пустой металлической бочки
function recipe_htgivebarrel(items, result, player)
    HCAddManySameItem("Hydrocraft.HCBarrelmetalempty", 0, player);
end

--выдача мусора при добыче
function recipe_htgivebarrel(items, result, player)
    HCAddManySameItem("Hydrocraft.HCBarrelmetalempty", 0, player);
end

--выдача токсичной бочки
function recipe_htgivetoxicbarrel(items, result, player)
    HCAddManySameItem("Base.toxicbarrel", 0, player);
end

--Спавн ресурсов при копании шахты
function htdigbigquarry(items, result, player)
    local digshoe = ZombRand(8);
    if digshoe == 7 then
        player:getInventory():AddItem("Hydrocraft.HCDirt");
    elseif digshoe == 6 then		
        player:getInventory():AddItem("Base.Stone");
    elseif digshoe == 5 then	
        player:getInventory():AddItem("Hydrocraft.HCSandstone");
    elseif digshoe == 4 then
        player:getInventory():AddItem("Hydrocraft.HCGreyclay");
    elseif digshoe == 3 then
       player:getInventory():AddItem("Base.Stone");
    elseif digshoe == 2 then
        player:getInventory():AddItem("Base.SharpedStone");
    elseif digshoe == 1 then
       player:getInventory():AddItem("Hydrocraft.HCZombiebones");   
    elseif digshoe == 0 then
       player:getInventory():AddItem("Base.Worm");      
    end
end