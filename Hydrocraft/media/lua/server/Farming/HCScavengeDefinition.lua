-- ***********************************************************
-- **                    Hydromancerx                       **
-- ***********************************************************

require "Farming/ScavengeDefinition";

getTexture("Item_HCGooseegg.png");
getTexture("Item_HCTurkeyegg.png");
getTexture("Item_HCChickenegg.png");
getTexture("Item_HCSparrowegg.png");
getTexture("Item_HCBirdnest.png");
getTexture("Item_HCBirdnesteggs.png");
getTexture("Item_HCBlackfeathers.png");
getTexture("Item_HCWhitefeathers.png");
getTexture("Item_HCStripedfeather.png");
getTexture("Item_HCBluejayfeather.png");
getTexture("Item_HCRedfeather.png");
getTexture("Item_HCSmallgamepoop.png");
getTexture("Item_HCBoarpoop.png");
getTexture("Item_HCDeerpoop.png");
getTexture("Item_HCBearpoop.png");
getTexture("Item_HCPigpoopferal.png");
getTexture("Item_HCSheeppoopferal.png");
getTexture("Item_HCGoatpoopferal.png");
getTexture("Item_HCCowpoopferal.png");
getTexture("Item_HCDonkeypoopferal.png");
getTexture("Item_HCHorsepoopferal.png");
getTexture("Item_HCStonearrowhead.png");

-- plants
local HCGooseegg = {};
HCGooseegg.type = "Hydrocraft.HCGooseegg";
HCGooseegg.minCount = 1;
HCGooseegg.maxCount = 1;
HCGooseegg.skill = 8;
local HCTurkeyegg = {};
HCTurkeyegg.type = "Hydrocraft.HCTurkeyegg";
HCTurkeyegg.minCount = 1;
HCTurkeyegg.maxCount = 1;
HCTurkeyegg.skill = 8;
local HCChickenegg = {};
HCChickenegg.type = "Hydrocraft.HCChickenegg";
HCChickenegg.minCount = 1;
HCChickenegg.maxCount = 1;
HCChickenegg.skill = 8;
local HCSparrowegg = {};
HCSparrowegg.type = "Hydrocraft.HCSparrowegg";
HCSparrowegg.minCount = 1;
HCSparrowegg.maxCount = 1;
HCSparrowegg.skill = 8;
local HCBirdnest = {};
HCBirdnest.type = "Hydrocraft.HCBirdnest";
HCBirdnest.minCount = 1;
HCBirdnest.maxCount = 1;
HCBirdnest.skill = 8;
local HCBirdnesteggs = {};
HCBirdnesteggs.type = "Hydrocraft.HCBirdnesteggs";
HCBirdnesteggs.minCount = 1;
HCBirdnesteggs.maxCount = 1;
HCBirdnesteggs.skill = 8;
local HCBlackfeathers = {};
HCBlackfeathers.type = "Hydrocraft.HCBlackfeathers";
HCBlackfeathers.minCount = 1;
HCBlackfeathers.maxCount = 2;
HCBlackfeathers.skill = 4;
local HCWhitefeathers = {};
HCWhitefeathers.type = "Hydrocraft.HCWhitefeathers";
HCWhitefeathers.minCount = 1;
HCWhitefeathers.maxCount = 2;
HCWhitefeathers.skill = 4;
local HCStripedfeather = {};
HCStripedfeather.type = "Hydrocraft.HCStripedfeather";
HCStripedfeather.minCount = 1;
HCStripedfeather.maxCount = 2;
HCStripedfeather.skill = 4;
local HCBluejayfeather = {};
HCBluejayfeather.type = "Hydrocraft.HCBluejayfeather";
HCBluejayfeather.minCount = 1;
HCBluejayfeather.maxCount = 2;
HCBluejayfeather.skill = 4;
local HCRedfeather = {};
HCRedfeather.type = "Hydrocraft.HCRedfeather";
HCRedfeather.minCount = 1;
HCRedfeather.maxCount = 2;
HCRedfeather.skill = 4;
local HCSmallgamepoop = {};
HCSmallgamepoop.type = "Hydrocraft.HCSmallgamepoop";
HCSmallgamepoop.minCount = 1;
HCSmallgamepoop.maxCount = 1;
HCSmallgamepoop.skill = 3;
local HCBoarpoop = {};
HCBoarpoop.type = "Hydrocraft.HCBoarpoop";
HCBoarpoop.minCount = 1;
HCBoarpoop.maxCount = 1;
HCBoarpoop.skill = 4;
local HCDeerpoop = {};
HCDeerpoop.type = "Hydrocraft.HCDeerpoop";
HCDeerpoop.minCount = 1;
HCDeerpoop.maxCount = 1;
HCDeerpoop.skill = 1;
local HCBearpoop = {};
HCBearpoop.type = "Hydrocraft.HCBearpoop";
HCBearpoop.minCount = 1;
HCBearpoop.maxCount = 1;
HCBearpoop.skill = 5;
local HCPigpoopferal = {};
HCPigpoopferal.type = "Hydrocraft.HCPigpoopferal";
HCPigpoopferal.minCount = 1;
HCPigpoopferal.maxCount = 1;
HCPigpoopferal.skill = 4;
local HCSheeppoopferal = {};
HCSheeppoopferal.type = "Hydrocraft.HCSheeppoopferal";
HCSheeppoopferal.minCount = 1;
HCSheeppoopferal.maxCount = 1;
HCSheeppoopferal.skill = 3;
local HCGoatpoopferal = {};
HCGoatpoopferal.type = "Hydrocraft.HCGoatpoopferal";
HCGoatpoopferal.minCount = 1;
HCGoatpoopferal.maxCount = 1;
HCGoatpoopferal.skill = 3;
local HCCowpoopferal = {};
HCCowpoopferal.type = "Hydrocraft.HCCowpoopferal";
HCCowpoopferal.minCount = 1;
HCCowpoopferal.maxCount = 1;
HCCowpoopferal.skill = 2;
local HCDonkeypoopferal = {};
HCDonkeypoopferal.type = "Hydrocraft.HCDonkeypoopferal";
HCDonkeypoopferal.minCount = 1;
HCDonkeypoopferal.maxCount = 1;
HCDonkeypoopferal.skill = 5;
local HCHorsepoopferal = {};
HCHorsepoopferal.type = "Hydrocraft.HCHorsepoopferal";
HCHorsepoopferal.minCount = 1;
HCHorsepoopferal.maxCount = 1;
HCHorsepoopferal.skill = 5;
local HCStonearrowhead = {};
HCStonearrowhead.type = "Hydrocraft.HCStonearrowhead";
HCStonearrowhead.minCount = 1;
HCStonearrowhead.maxCount = 1;
HCStonearrowhead.skill = 9;

table.insert(scavenges.insects, HCGooseegg);
table.insert(scavenges.insects, HCTurkeyegg);
table.insert(scavenges.insects, HCChickenegg);
table.insert(scavenges.insects, HCSparrowegg);
table.insert(scavenges.insects, HCBirdnest);
table.insert(scavenges.insects, HCBirdnesteggs);
table.insert(scavenges.insects, HCBlackfeathers);
table.insert(scavenges.insects, HCWhitefeathers);
table.insert(scavenges.insects, HCBrownfeathers);
table.insert(scavenges.insects, HCStripedfeather);
table.insert(scavenges.insects, HCBluejayfeather);
table.insert(scavenges.insects, HCRedfeather);
table.insert(scavenges.insects, HCSmallgamepoop);
table.insert(scavenges.insects, HCBoarpoopferal);
table.insert(scavenges.insects, HCDeerpoopferal);
table.insert(scavenges.insects, HCBearpoopferal);
table.insert(scavenges.insects, HCPigpoopferal);
table.insert(scavenges.insects, HCSheeppoopferal);
table.insert(scavenges.insects, HCGoatpoopferal);
table.insert(scavenges.insects, HCCowpoopferal);
table.insert(scavenges.insects, HCDonkeypoopferal);
table.insert(scavenges.insects, HCHorsepoopferal);
table.insert(scavenges.insects, HCStonearrowhead);
