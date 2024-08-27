--
 require "Traps/TrapDefinition"

local sparrow = {};
sparrow.type = "sparrow";
sparrow.item = "Hydrocraft.HCSparrowdead";
sparrow.minHour = 19;
sparrow.maxHour = 5;
sparrow.minSize = 7;
sparrow.maxSize = 18;
sparrow.zone = {};
sparrow.zone["TownZone"] = 50;
sparrow.zone["TrailerPark"] = 40;
sparrow.zone["FarmLand"] = 30;
sparrow.zone["Vegitation"] = 20;
sparrow.zone["Forest"] = 10;
sparrow.zone["DeepForest"] = 10;
sparrow.traps = {};
sparrow.traps["Base.TrapStick"] = 30;
sparrow.baits = {};
sparrow.baits["Base.Bread"] = 20;
sparrow.baits["Base.BreadSlices"] = 20;
sparrow.baits["Base.Worm"] = 10;
sparrow.baits["Base.Corn"] = 10;
sparrow.baits["Base.Cereal"] = 20;
sparrow.baits["Base.Popcorn"] = 50;
sparrow.baits["Hydrocraft.HCCornwhite"] = 10;
sparrow.baits["Hydrocraft.HCCornblue"] = 10;
sparrow.baits["Hydrocraft.HCCornred"] = 10;
sparrow.baits["Hydrocraft.HCTermite"] = 10;
sparrow.baits["Hydrocraft.HCMolecricket"] = 10;
sparrow.baits["Hydrocraft.HCMaggot"] = 10;
sparrow.baits["Hydrocraft.HCBeetlegrub"] = 10;
 
local pigeon = {};
pigeon.type = "pigeon";
pigeon.item = "Hydrocraft.HCPigeondead";
pigeon.minHour = 19;
pigeon.maxHour = 5;
pigeon.minSize = 7;
pigeon.maxSize = 18;
pigeon.zone = {};
pigeon.zone["TownZone"] = 50;
pigeon.zone["TrailerPark"] = 40;
pigeon.zone["FarmLand"] = 30;
pigeon.zone["Vegitation"] = 20;
pigeon.zone["Forest"] = 10;
pigeon.zone["DeepForest"] = 10;
pigeon.traps = {};
pigeon.traps["Base.TrapStick"] = 30;
pigeon.baits = {};
pigeon.baits["Base.Bread"] = 20;
pigeon.baits["Base.BreadSlices"] = 20;
pigeon.baits["Base.Worm"] = 10;
pigeon.baits["Base.Corn"] = 10;
pigeon.baits["Base.Cereal"] = 20;
pigeon.baits["Base.Popcorn"] = 50;
pigeon.baits["Hydrocraft.HCCornwhite"] = 10;
pigeon.baits["Hydrocraft.HCCornblue"] = 10;
pigeon.baits["Hydrocraft.HCCornred"] = 10;
pigeon.baits["Hydrocraft.HCTermite"] = 10;
pigeon.baits["Hydrocraft.HCMolecricket"] = 10;
pigeon.baits["Hydrocraft.HCMaggot"] = 10;
pigeon.baits["Hydrocraft.HCBeetlegrub"] = 10;
pigeon.baits["Base.Peanuts"] = 20;



local quail = {};
quail.type = "quail";
quail.item = "Hydrocraft.HCQuaildead";
quail.minHour = 19;
quail.maxHour = 5;
quail.minSize = 9;
quail.maxSize = 19;
quail.zone = {};
quail.zone["TownZone"] = 2;
quail.zone["TrailerPark"] = 2;
quail.zone["FarmLand"] = 30;
quail.zone["Vegitation"] = 30;
quail.zone["Forest"] = 15;
quail.zone["DeepForest"] = 10;
quail.traps = {};
quail.traps["Base.TrapStick"] = 30;
quail.baits = {};
quail.baits["Base.Bread"] = 10;
quail.baits["Base.BreadSlices"] = 10;
quail.baits["Base.Worm"] = 10;
quail.baits["Base.Corn"] = 20;
quail.baits["Base.Cereal"] = 20;
quail.baits["Base.Popcorn"] = 20;
quail.baits["Hydrocraft.HCCornwhite"] = 50;
quail.baits["Hydrocraft.HCCornblue"] = 20;
quail.baits["Hydrocraft.HCCornred"] = 20;
quail.baits["Hydrocraft.HCTermite"] = 10;
quail.baits["Hydrocraft.HCMolecricket"] = 10;
quail.baits["Hydrocraft.HCMaggot"] = 10;
quail.baits["Hydrocraft.HCBeetlegrub"] = 10;
quail.baits["Base.Peanuts"] = 20;

 
local grouse = {};
grouse.type = "grouse";
grouse.item = "Hydrocraft.HCGrousedead";
grouse.minHour = 19;
grouse.maxHour = 5;
grouse.minSize = 10;
grouse.maxSize = 20;
grouse.zone = {};
grouse.zone["TownZone"] = 2;
grouse.zone["TrailerPark"] = 2;
grouse.zone["FarmLand"] = 15;
grouse.zone["Vegitation"] = 15;
grouse.zone["Forest"] = 20;
grouse.zone["DeepForest"] = 15;
grouse.traps = {};
grouse.traps["Base.TrapStick"] = 30;
grouse.baits = {};
grouse.baits["Base.Bread"] = 10;
grouse.baits["Base.BreadSlices"] = 10;
grouse.baits["Base.Worm"] = 10;
grouse.baits["Base.Corn"] = 20;
grouse.baits["Base.Cereal"] = 20;
grouse.baits["Base.Popcorn"] = 20;
grouse.baits["Hydrocraft.HCCornwhite"] = 20;
grouse.baits["Hydrocraft.HCCornblue"] = 50;
grouse.baits["Hydrocraft.HCCornred"] = 20;
grouse.baits["Hydrocraft.HCTermite"] = 10;
grouse.baits["Hydrocraft.HCMolecricket"] = 10;
grouse.baits["Hydrocraft.HCMaggot"] = 10;
grouse.baits["Hydrocraft.HCBeetlegrub"] = 10;
grouse.baits["Base.Peanuts"] = 20;


local turkey = {};
turkey.type = "turkey";
turkey.item = "Hydrocraft.HCTurkeydead";
turkey.strength = 25;
turkey.minHour = 19;
turkey.maxHour = 5;
turkey.minSize = 10;
turkey.maxSize = 20;
turkey.zone = {};
turkey.zone["TownZone"] = 2;
turkey.zone["TrailerPark"] = 2;
turkey.zone["FarmLand"] = 15;
turkey.zone["Vegitation"] = 15;
turkey.zone["Forest"] = 20;
turkey.zone["DeepForest"] = 15;
turkey.traps = {};
turkey.traps["Base.TrapStick"] = 30;
turkey.baits = {};
turkey.baits["Base.Bread"] = 10;
turkey.baits["Base.BreadSlices"] = 10;
turkey.baits["Base.Worm"] = 10;
turkey.baits["Base.Corn"] = 20;
turkey.baits["Base.Cereal"] = 20;
turkey.baits["Base.Popcorn"] = 20;
turkey.baits["Hydrocraft.HCCornwhite"] = 20;
turkey.baits["Hydrocraft.HCCornblue"] = 20;
turkey.baits["Hydrocraft.HCCornred"] = 50;
turkey.baits["Hydrocraft.HCTermite"] = 10;
turkey.baits["Hydrocraft.HCMolecricket"] = 10;
turkey.baits["Hydrocraft.HCMaggot"] = 10;
turkey.baits["Hydrocraft.HCBeetlegrub"] = 10;
turkey.baits["Base.Peanuts"] = 20;


local chickenm = {};
chickenm.type = "chickenm";
chickenm.item = "Hydrocraft.HCChickendead";
chickenm.strength = 22;
chickenm.minHour = 19;
chickenm.maxHour = 5;
chickenm.minSize = 12;
chickenm.maxSize = 50;
chickenm.zone = {};
chickenm.zone["TownZone"] = 2;
chickenm.zone["TrailerPark"] = 2;
chickenm.zone["FarmLand"] = 30;
chickenm.zone["Vegitation"] = 20;
chickenm.zone["Forest"] = 10;
chickenm.zone["DeepForest"] = 10;
chickenm.traps = {};
chickenm.traps["Base.TrapStick"] = 30;
chickenm.baits = {};
chickenm.baits["Base.Bread"] = 10;
chickenm.baits["Base.BreadSlices"] = 10;
chickenm.baits["Base.Worm"] = 10;
chickenm.baits["Base.Corn"] = 50;
chickenm.baits["Base.Cereal"] = 20;
chickenm.baits["Base.Popcorn"] = 20;
chickenm.baits["Hydrocraft.HCCornwhite"] = 20;
chickenm.baits["Hydrocraft.HCCornblue"] = 20;
chickenm.baits["Hydrocraft.HCCornred"] = 20;
chickenm.baits["Hydrocraft.HCTermite"] = 10;
chickenm.baits["Hydrocraft.HCMolecricket"] = 10;
chickenm.baits["Hydrocraft.HCMaggot"] = 10;
chickenm.baits["Hydrocraft.HCBeetlegrub"] = 10;
chickenm.baits["Base.Peanuts"] = 20;



local chickenf = {};
chickenf.type = "chickenf";
chickenf.item = "Hydrocraft.HCChickendead2";
chickenf.strength = 20;
chickenf.minHour = 19;
chickenf.maxHour = 5;
chickenf.minSize = 12;
chickenf.maxSize = 50;
chickenf.zone = {};
chickenf.zone["TownZone"] = 2;
chickenf.zone["TrailerPark"] = 2;
chickenf.zone["FarmLand"] = 30;
chickenf.zone["Vegitation"] = 20;
chickenf.zone["Forest"] = 10;
chickenf.zone["DeepForest"] = 10;
chickenf.traps = {};
chickenf.traps["Base.TrapStick"] = 30;
chickenf.baits = {};
chickenf.baits["Base.Bread"] = 10;
chickenf.baits["Base.BreadSlices"] = 10;
chickenf.baits["Base.Worm"] = 10;
chickenf.baits["Base.Corn"] = 50;
chickenf.baits["Base.Cereal"] = 20;
chickenf.baits["Base.Popcorn"] = 20;
chickenf.baits["Hydrocraft.HCCornwhite"] = 20;
chickenf.baits["Hydrocraft.HCCornblue"] = 20;
chickenf.baits["Hydrocraft.HCCornred"] = 20;
chickenf.baits["Hydrocraft.HCTermite"] = 10;
chickenf.baits["Hydrocraft.HCMolecricket"] = 10;
chickenf.baits["Hydrocraft.HCMaggot"] = 10;
chickenf.baits["Hydrocraft.HCBeetlegrub"] = 10;
chickenf.baits["Base.Peanuts"] = 20;


local muskrat = {};
muskrat.type = "muskrat";
muskrat.item = "Hydrocraft.HCMuskratdead";
muskrat.strength = 5;
muskrat.minHour = 5;
muskrat.maxHour = 19;
muskrat.minSize = 10;
muskrat.maxSize = 30;
muskrat.zone = {};
muskrat.zone["TownZone"] = 2;
muskrat.zone["TrailerPark"] = 2;
muskrat.zone["FarmLand"] = 2;
muskrat.zone["Vegitation"] = 15;
muskrat.zone["Forest"] = 30;
muskrat.zone["DeepForest"] = 30;
muskrat.traps = {};
muskrat.traps["Base.TrapCage"] = 30;
muskrat.traps["Base.TrapSnare"] = 20;
muskrat.traps["Base.TrapBox"] = 20;
muskrat.traps["Base.TrapCrate"] = 20;
muskrat.baits = {};
muskrat.baits["Base.BaitFish"] = 30;
muskrat.baits["Base.FrogMeat"] = 20;
muskrat.baits["Hydrocraft.HCBark"] = 10;
muskrat.baits["Hydrocraft.HCBirchbark"] = 10;
muskrat.baits["Hydrocraft.HCCrab"] = 20;
muskrat.baits["Hydrocraft.HCCrayfish"] = 30;

local groundhog = {};
groundhog.type = "groundhog";
groundhog.item = "Hydrocraft.HCGroundhogdead";
groundhog.strength = 5;
groundhog.minHour = 19;
groundhog.maxHour = 5;
groundhog.minSize = 10;
groundhog.maxSize = 30;
groundhog.zone = {};
groundhog.zone["TownZone"] = 2;
groundhog.zone["TrailerPark"] = 2;
groundhog.zone["FarmLand"] = 10;
groundhog.zone["Vegitation"] = 20;
groundhog.zone["Forest"] = 30;
groundhog.zone["DeepForest"] = 20;
groundhog.traps = {};
groundhog.traps["Base.TrapCage"] = 30;
groundhog.traps["Base.TrapSnare"] = 20;
groundhog.traps["Base.TrapBox"] = 20;
groundhog.traps["Base.TrapCrate"] = 20;
groundhog.baits = {};
groundhog.baits["Base.Carrots"] = 30;
groundhog.baits["Base.Lettuce"] = 30;
groundhog.baits["farming.Cabbage"] = 10;
groundhog.baits["Base.Corn"] = 10;
groundhog.baits["farming.Potato"] = 10;
groundhog.baits["Base.Peach"] = 15;
groundhog.baits["Hydrocraft.HCCornwhite"] = 20;
groundhog.baits["Hydrocraft.HCCornblue"] = 20;
groundhog.baits["Hydrocraft.HCCornred"] = 10;
groundhog.baits["Hydrocraft.HCBark"] = 10;
groundhog.baits["Hydrocraft.HCMaggot"] = 10;
groundhog.baits["Hydrocraft.HCBeetlegrub"] = 10;

local nutria = {};
nutria.type = "nutria";
nutria.item = "Hydrocraft.HCNutriadead";
nutria.strength = 24;
nutria.minHour = 5;
nutria.maxHour = 19;
nutria.minSize = 15;
nutria.maxSize = 60;
nutria.zone = {};
nutria.zone["TownZone"] = 2;
nutria.zone["TrailerPark"] = 2;
nutria.zone["FarmLand"] = 2;
nutria.zone["Vegitation"] = 15;
nutria.zone["Forest"] = 30;
nutria.zone["DeepForest"] = 30;
nutria.traps = {};
nutria.traps["Base.TrapCage"] = 30;
nutria.traps["Base.TrapSnare"] = 20;
nutria.traps["Base.TrapBox"] = 20;
nutria.traps["Base.TrapCrate"] = 20;
nutria.baits = {};
nutria.baits["Base.Carrots"] = 30;
nutria.baits["Base.Lettuce"] = 30;
nutria.baits["farming.Cabbage"] = 10;
nutria.baits["Base.Corn"] = 15;
nutria.baits["farming.Potato"] = 10;
nutria.baits["Base.Cereal"] = 10;
nutria.baits["Hydrocraft.HCCornwhite"] = 15;
nutria.baits["Hydrocraft.HCCornblue"] = 15;
nutria.baits["Hydrocraft.HCCornred"] = 10;
nutria.baits["Hydrocraft.HCBark"] = 10;
nutria.baits["Hydrocraft.HCBirchbark"] = 10;

local beaver = {};
beaver.type = "beaver";
beaver.item = "Hydrocraft.HCBeaverdead";
beaver.strength = 24;
beaver.minHour = 19;
beaver.maxHour = 5;
beaver.minSize = 15;
beaver.maxSize = 60;
beaver.zone = {};
beaver.zone["TownZone"] = 2;
beaver.zone["TrailerPark"] = 2;
beaver.zone["FarmLand"] = 2;
beaver.zone["Vegitation"] = 15;
beaver.zone["Forest"] = 30;
beaver.zone["DeepForest"] = 30;
beaver.traps = {};
beaver.traps["Base.TrapCage"] = 30;
beaver.traps["Base.TrapSnare"] = 20;
beaver.traps["Base.TrapBox"] = 20;
beaver.traps["Base.TrapCrate"] = 20;
beaver.baits = {};
beaver.baits["Hydrocraft.HCBark"] = 30;
beaver.baits["Hydrocraft.HCBirchbark"] = 20;
beaver.baits["Base.Carrots"] = 20;

local opossum = {};
opossum.type = "opossum";
opossum.item = "Hydrocraft.HCOpossumdead";
opossum.strength = 5;
opossum.minHour = 5;
opossum.maxHour = 19;
opossum.minSize = 10;
opossum.maxSize = 30;
opossum.zone = {};
opossum.zone["TownZone"] = 20;
opossum.zone["TrailerPark"] = 20;
opossum.zone["FarmLand"] = 20;
opossum.zone["Vegitation"] = 20;
opossum.zone["Forest"] = 20;
opossum.zone["DeepForest"] = 20;
opossum.traps = {};
opossum.traps["Base.TrapCage"] = 30;
opossum.traps["Base.TrapSnare"] = 20;
opossum.traps["Base.TrapBox"] = 20;
opossum.traps["Base.TrapCrate"] = 20;
opossum.baits = {};
opossum.baits["Base.Orange"] = 30;
opossum.baits["Base.Lemon"] = 20;
opossum.baits["Base.FrogMeat"] = 10;
opossum.baits["Base.DeadMouse"] = 10;
opossum.baits["Base.WildEggs"] = 10;
opossum.baits["Hydrocraft.HCCrayfish"] = 10;
opossum.baits["Hydrocraft.Lime"] = 20;

local skunk = {};
skunk.type = "skunk";
skunk.item = "Hydrocraft.HCSkunkdead";
skunk.strength = 24;
skunk.minHour = 5;
skunk.maxHour = 19;
skunk.minSize = 15;
skunk.maxSize = 60;
skunk.zone = {};
skunk.zone["TownZone"] = 20;
skunk.zone["TrailerPark"] = 20;
skunk.zone["FarmLand"] = 20;
skunk.zone["Vegitation"] = 20;
skunk.zone["Forest"] = 20;
skunk.zone["DeepForest"] = 20;
skunk.traps = {};
skunk.traps["Base.TrapCage"] = 30;
skunk.traps["Base.TrapSnare"] = 20;
skunk.traps["Base.TrapBox"] = 20;
skunk.traps["Base.TrapCrate"] = 20;
skunk.baits = {};
skunk.baits["Base.Worm"] = 10;
skunk.baits["Base.FrogMeat"] = 10;
skunk.baits["Base.DeadMouse"] = 10;
skunk.baits["Base.DeadBird"] = 10;
skunk.baits["Base.WildEggs"] = 10;
skunk.baits["Base.TunaTinOpen"] = 30;
skunk.baits["Base.DogfoodOpen"] = 20;
skunk.baits["Hydrocraft.HCCrayfish"] = 10;
skunk.baits["Hydrocraft.HCHoney"] = 20;
skunk.baits["Hydrocraft.HCJarhoney"] = 20;

local raccoon = {};
raccoon.type = "raccoon";
raccoon.item = "Hydrocraft.HCRaccoondead";
raccoon.strength = 30;
raccoon.minHour = 5;
raccoon.maxHour = 19;
raccoon.minSize = 20;
raccoon.maxSize = 80;
raccoon.zone = {};
raccoon.zone["TownZone"] = 20;
raccoon.zone["TrailerPark"] = 20;
raccoon.zone["FarmLand"] = 20;
raccoon.zone["Vegitation"] = 20;
raccoon.zone["Forest"] = 20;
raccoon.zone["DeepForest"] = 20;
raccoon.traps = {};
raccoon.traps["Base.TrapCage"] = 30;
raccoon.traps["Base.TrapSnare"] = 20;
raccoon.traps["Base.TrapBox"] = 20;
raccoon.traps["Base.TrapCrate"] = 20;
raccoon.baits = {};
raccoon.baits["Base.FrogMeat"] = 10;
raccoon.baits["Base.DeadMouse"] = 10;
raccoon.baits["Base.DeadRat"] = 10;
raccoon.baits["Base.WildEggs"] = 10;
raccoon.baits["Base.TunaTinOpen"] = 10;
raccoon.baits["Base.DogfoodOpen"] = 10;
raccoon.baits["Base.Bread"] = 10;
raccoon.baits["Base.BreadSlices"] = 10;
raccoon.baits["Base.PeanutButter"] = 20;
raccoon.baits["farming.BaconBits"] = 10;
raccoon.baits["Base.Chocolate"] = 10;
raccoon.baits["Base.Orange"] = 10;
raccoon.baits["farming.Apple"] = 10;
raccoon.baits["Base.Processedcheese"] = 10;
raccoon.baits["Hydrocraft.HCCrayfish"] = 10;
raccoon.baits["Hydrocraft.HCJellybeans"] = 30;

local fox = {};
fox.type = "fox";
fox.item = "Hydrocraft.HCFoxdead";
fox.strength = 30;
fox.minHour = 19;
fox.maxHour = 5;
fox.minSize = 20;
fox.maxSize = 80;
fox.zone = {};
fox.zone["TownZone"] = 10;
fox.zone["TrailerPark"] = 10;
fox.zone["FarmLand"] = 15;
fox.zone["Vegitation"] = 20;
fox.zone["Forest"] = 20;
fox.zone["DeepForest"] = 20;
fox.traps = {};
fox.traps["Base.TrapCage"] = 30;
fox.traps["Base.TrapSnare"] = 20;
fox.traps["Base.TrapBox"] = 20;
fox.traps["Base.TrapCrate"] = 20;
fox.baits = {};
fox.baits["Base.FrogMeat"] = 10;
fox.baits["Base.DeadMouse"] = 10;
fox.baits["Base.DeadRat"] = 10;
fox.baits["Base.DeadSquirrel"] = 10;
fox.baits["Base.DeadRabbit"] = 30;
fox.baits["Base.DeadBird"] = 10;
fox.baits["Base.WildEggs"] = 30;
fox.baits["Base.DogfoodOpen"] = 20;
fox.baits["Base.Chicken"] = 30;
fox.baits["Base.Egg"] = 30;
fox.baits["Hydrocraft.HCCrayfish"] = 10;
fox.baits["Hydrocraft.HCChickendead"] = 30;
fox.baits["Hydrocraft.HCChickendead2"] = 30;


local live_rabbit_male = {};
live_rabbit_male.type = "live_rabbit_male";
-- after how many hour the animal will start to destroy the cage/escape
live_rabbit_male.strength = 24;
-- item given to the player
live_rabbit_male.item = "Base.DeadRabbit"; --Hydrocraft.HCRabbitmale
-- hour this animal will be out and when you can catch it
live_rabbit_male.minHour = 19;
live_rabbit_male.maxHour = 5;
-- min and max "size" (understand hunger reduction) of the animal
live_rabbit_male.minSize = 30;
live_rabbit_male.maxSize = 100;
-- chance to get the animals per zone
live_rabbit_male.zone = {};
live_rabbit_male.zone["TownZone"] = 2;
live_rabbit_male.zone["TrailerPark"] = 2;
live_rabbit_male.zone["Vegitation"] = 10;
live_rabbit_male.zone["Forest"] = 12;
live_rabbit_male.zone["DeepForest"] = 15;
-- chance to get animals for each trap
live_rabbit_male.traps = {};
live_rabbit_male.traps["Base.TrapCage"] = 40;
-- chance to attract animal per bait
live_rabbit_male.baits = {};
live_rabbit_male.baits["Base.Carrots"] = 45;
live_rabbit_male.baits["Base.Apple"] = 35;
live_rabbit_male.baits["Base.Lettuce"] = 40;
live_rabbit_male.baits["Base.BellPepper"] = 40;
live_rabbit_male.baits["farming.Cabbage"] = 40;
live_rabbit_male.baits["Base.Corn"] = 35;
live_rabbit_male.baits["Base.Banana"] = 35;
live_rabbit_male.baits["farming.Potato"] = 35;
live_rabbit_male.baits["farming.Tomato"] = 35;
live_rabbit_male.baits["Base.Peach"] = 35;
live_rabbit_male.baits["Hydrocraft.HCGrass"] = 20;

local live_rabbit_female = {};
live_rabbit_female.type = "live_rabbit_female";
-- after how many hour the animal will start to destroy the cage/escape [через сколько часов животное начнет крушить клетку/сбегать]
live_rabbit_female.strength = 24;
-- item given to the player
live_rabbit_female.item = "Base.DeadRabbit"; --Hydrocraft.HCRabbitfemale
-- hour this animal will be out and when you can catch it [в какое время попадается животное, с 19 вечера до 5 утра]
live_rabbit_female.minHour = 19;
live_rabbit_female.maxHour = 5;
-- min and max "size" (understand hunger reduction) of the animal [минимальный и максимальный «размер» (понимаете, уменьшение голода) животного]
live_rabbit_female.minSize = 30;
live_rabbit_female.maxSize = 100;
-- chance to get the animals per zone [шанс получить животных в каждой зоне]
live_rabbit_female.zone = {};
live_rabbit_female.zone["TownZone"] = 2;
live_rabbit_female.zone["TrailerPark"] = 2;
live_rabbit_female.zone["Vegitation"] = 10;
live_rabbit_female.zone["Forest"] = 12;
live_rabbit_female.zone["DeepForest"] = 15;
-- chance to get animals for each trap [шанс получить животных за каждую ловушку]
live_rabbit_female.traps = {};
live_rabbit_female.traps["Base.TrapCage"] = 40;
-- chance to attract animal per bait [вероятность привлечения животного на приманку]
live_rabbit_female.baits = {};
live_rabbit_female.baits["Base.Carrots"] = 45;
live_rabbit_female.baits["Base.Apple"] = 35;
live_rabbit_female.baits["Base.Lettuce"] = 40;
live_rabbit_female.baits["Base.BellPepper"] = 40;
live_rabbit_female.baits["farming.Cabbage"] = 40;
live_rabbit_female.baits["Base.Corn"] = 35;
live_rabbit_female.baits["Base.Banana"] = 35;
live_rabbit_female.baits["farming.Potato"] = 35;
live_rabbit_female.baits["farming.Tomato"] = 35;
live_rabbit_female.baits["Base.Peach"] = 35;
live_rabbit_female.baits["Hydrocraft.HCGrass"] = 20;

function getAnimal(Animals, aniString)
    local thisIsTheOne = -1;
    for x=1, #Animals do
            if Animals[x].type == aniString then
                    thisIsTheOne = x;
			end		
    end
    return thisIsTheOne;
end

-- Rabbit Bait
Animals[getAnimal(Animals, "rabbit")].baits["Hydrocraft.HCGrass"] = 20;

-- Squirrel Bait
Animals[getAnimal(Animals, "squirrel")].baits["Hydrocraft.HCPinenuts"] = 20;
Animals[getAnimal(Animals, "squirrel")].baits["Hydrocraft.HCChestnut2"] = 20;
Animals[getAnimal(Animals, "squirrel")].baits["Hydrocraft.HCHickorynuts2"] = 20;

-- Bird Bait
Animals[getAnimal(Animals, "bird")].baits["Hydrocraft.HCTermite"] = 10;
Animals[getAnimal(Animals, "bird")].baits["Hydrocraft.HCMolecricket"] = 10;
Animals[getAnimal(Animals, "bird")].baits["Hydrocraft.HCMaggot"] = 10;
Animals[getAnimal(Animals, "bird")].baits["Hydrocraft.HCBeetlegrub"] = 10;

-- Mouse Bait
Animals[getAnimal(Animals, "mouse")].baits["Hydrocraft.HCCheddar"] = 40;

-- Rat Bait
Animals[getAnimal(Animals, "rat")].baits["Hydrocraft.HCCheddar"] = 40;

table.insert(Animals, pigeon);
table.insert(Animals, quail);
table.insert(Animals, grouse);
table.insert(Animals, turkey);
table.insert(Animals, chickenm);
table.insert(Animals, chickenf);
table.insert(Animals, muskrat);
table.insert(Animals, groundhog);
table.insert(Animals, nutria);
table.insert(Animals, beaver);
table.insert(Animals, opossum);
table.insert(Animals, skunk);
table.insert(Animals, raccoon);
table.insert(Animals, fox);
table.insert(Animals, live_rabbit_male);
table.insert(Animals, live_rabbit_female);