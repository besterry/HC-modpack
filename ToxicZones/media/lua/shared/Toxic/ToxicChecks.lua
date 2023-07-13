--local GeigerRange = SandboxVars.ToxicZonesStalker.GeigerCounterRange or 2;

local core = getCore()
local width = core:getScreenWidth();
local height = core:getScreenHeight();
local toxicOverlay = getTexture("media/textures/UI/ToxicOverlay.png");
local toxicAlpha = 0;
local toxicOvCap = false;

ProtectiveMasks = {
	"Exohelm",
	"ExohelmBandit",
	"ExohelmCS",
	"ExohelmDuty",
	"ExohelmEcologists",
	"ExohelmFreedom",
	"ExohelmLoner",
	"ExohelmMercs",
	"ExohelmMilitary",
	"ExohelmMonolith",
	"GP5GasMask",
	"M40GasMask",
	"PPM88",
	"GP10Z",
	"SEVAHelm",
	"SEVAHelmBandit",
	"SEVAHelmCS",
	"SEVAHelmDuty",
	"SEVAHelmEcologist",
	"SEVAHelmFreedom",
	"SEVAHelmMercs",
	"SEVAHelmMonolith",
	"SEVAHelmMonolithGreen",
	"SovietPMG",
	"Sphere08HelmetMilitary",
	"Sphere08HelmetCS",
	"Sphere08HelmetDuty",
	"Sphere08HelmetFreedom",
	"Sphere08HelmetMercs",
	"Sphere08HelmetMonolith",
	"SphereM12Helmet",
	"SphereM12HelmetCS",
	"SphereM12HelmetDuty",
	"SphereM12HelmetFreedom",
	"SphereM12HelmetMercs",
	"SphereM12HelmetMonolith",
	"SteelHelmMask",
	"CS2aGasMask",
	"PBF1",
	"PBF1CS",
	"PBF1Duty",
	"PBF1Freedom",
	"PBF2",
	"PBF2CS",
	"PBF2Duty",
	"PBF2Freedom",
	"RespiratorGold",
	"RespiratorSilver",
	"RespiratorCS",
	"RespiratorFreedom",
	"RespiratorDuty",
	"RespiratorMonolith",
}

--Simplified from planetalgol's Toxic Fog version
function protectiveMaskEquipped(player)
	if player:isGodMod() then return true end
	local inventory = player:getInventory()	
	local it = inventory:getItems()		
	if player and inventory then
		for i = 0, it:size()-1 do
			local item = it:get(i)
			if player:isEquippedClothing(item) then
				local iType = item:getType()		
				for i = 1, #ProtectiveMasks do
					if ProtectiveMasks[i] == iType then
						local percent = 1
						if item:getModData().percent then
							percent = item:getModData().percent;
						end
						if percent > 0 then
							item:getModData().percent = percent - 0.00001;
							if item:getModData().percent < 0 then
								item:getModData().percent = 0;
							end
							return true
						else
							return false
						end
					end
				end	
			end
		end
	end
	return false
end


function shouldTakeToxicDamage(player)
	if not isInToxicZone(player) then return false end
	if protectiveMaskEquipped(player) then return false end

	local toxic_Fog = ( 0.15 * ( GameTime.getInstance():getMultiplier() / 1.6) )
	local stats = player:getStats()
	local fatigue = stats:getFatigue()
	local isOnline = (isClient() or isServer()) 
	local sleepOK = isOnline and getServerOptions():getBoolean("SleepAllowed") and getServerOptions():getBoolean("SleepNeeded")

	if fatigue < 1 and (sleepOK or not isOnline) then
		stats:setFatigue( fatigue + ( 0.001 * toxic_Fog ) )
	end	
	toxic_Fog = (toxic_Fog * SandboxVars.ToxicZonesStalker.ToxicDamageMultiplier / 2)
	local damage = player:getBodyDamage()
	damage:getBodyPart(BodyPartType.Head):ReduceHealth(0.1 * toxic_Fog); 
    damage:getBodyPart(BodyPartType.Torso_Upper):ReduceHealth(0.1 * toxic_Fog);
    damage:getBodyPart(BodyPartType.Neck):ReduceHealth(0.1 * toxic_Fog);
	damage:ReduceGeneralHealth(0.015 * toxic_Fog)
	--print("HEAD -- " .. tostring( damage:getBodyPart(BodyPartType.Head):getHealth()))
	if damage:getBodyPart(BodyPartType.Head):getHealth() < 1 then 
		damage:getBodyPart(BodyPartType.Head):setHealth(0)
	end
	if damage:getBodyPart(BodyPartType.Torso_Upper):getHealth() < 1 then 
		damage:getBodyPart(BodyPartType.Torso_Upper):setHealth(0)
	end
	if damage:getBodyPart(BodyPartType.Neck):getHealth() < 1 then 
		damage:getBodyPart(BodyPartType.Neck):setHealth(0)
	end
end

function isInToxicZone(player)
	local isToxic = false
	local tagX, tagY = math.floor(player:getX() / 100), math.floor(player:getY() / 100)
	local regionTag = tostring(tagX) .. "x" .. tostring(tagY);
	local toxicZoneRegions = ModData.getOrCreate("ToxicZoneRegions")

	if toxicZoneRegions == nil then 
		ModData.request("ToxicZoneRegions")
		toxicZone = ModData.get("ToxicZoneRegions")
	end
	if not toxicZoneRegions[regionTag] then
		--player:Say(regionTag .. " No zones here");
		isToxic = false
		checkSurroundings(player)
		toxicOvCap = isToxic
		return isToxic
	else
	    for i, w in pairs(toxicZoneRegions[regionTag]) do
			local zone = i
			local startX = toxicZoneRegions[regionTag][zone].startX
			local startY = toxicZoneRegions[regionTag][zone].startY
			local endX = toxicZoneRegions[regionTag][zone].endX
			local endY = toxicZoneRegions[regionTag][zone].endY

			if player:getX() < startX or player:getX() > endX or player:getY() < startY or player:getY() > endY then
				isToxic = false
			else
				isToxic = true
				--player:Say(regionTag .. " Inside zone: " .. zone);

				if player:getInventory():contains("Base.ContaminantDetector", false, false) then
					local rando = ZombRand(6)
					if rando == 0 then
						player:playSound("GeigerCounter");
					elseif rando == 1 then
						player:playSound("GeigerCounter2");
					elseif rando == 2 then
						player:playSound("GeigerCounter3");
					elseif rando == 3 then
						player:playSound("GeigerCounter4");
					end
				end
				toxicOvCap = isToxic
				return isToxic
			end
		end
		--player:Say(regionTag .. " Outside zones in the area");
		checkSurroundings(player)
		toxicOvCap = isToxic
		return isToxic
	end
end

function checkSurroundings(player)
	local cell = player:getCell()
    local x, y = player:getX(), player:getY();
    local xx, yy
    for xx =-1,1 do
        for yy =-1,1 do
            local square = cell:getGridSquare(x+xx, y+yy, 0)
            if square then
                local toxicSq = isToxicSquare(square)
				if toxicSq == true then
					if player:getInventory():contains("Base.ContaminantDetector", false, false) then
						local rando = ZombRand(8)
							if rando == 0 then
								player:playSound("GeigerCounterWeak");
							elseif rando == 1 then
								player:playSound("GeigerCounterWeak2");
							end
					end
				return
				end  
			end
		end
	end
    for xx =-SandboxVars.ToxicZonesStalker.GeigerCounterRange,SandboxVars.ToxicZonesStalker.GeigerCounterRange do
        for yy =-SandboxVars.ToxicZonesStalker.GeigerCounterRange,SandboxVars.ToxicZonesStalker.GeigerCounterRange do
            local square = cell:getGridSquare(x+xx, y+yy, 0)
            if square then
                local toxicSq = isToxicSquare(square)
				if toxicSq == true then
					if player:getInventory():contains("Base.ContaminantDetector", false, false) then
						local rando = ZombRand(20)
							if rando == 0 then
								player:playSound("GeigerCounterWeak");
							elseif rando == 1 then
								player:playSound("GeigerCounterWeak2");
							end
					end
				return
				end  
			end
		end
	end
end

function isToxicSquare(square)
	local isToxic = false
	local tagX, tagY = math.floor(square:getX() / 100), math.floor(square:getY() / 100)
	local regionTag = tostring(tagX) .. "x" .. tostring(tagY);
	local toxicZoneRegions = ModData.getOrCreate("ToxicZoneRegions")
	if toxicZoneRegions == nil then 
		ModData.request("ToxicZonetoxicZoneRegions")
		toxicZone = ModData.get("ToxicZonetoxicZoneRegions")
	end
	if not toxicZoneRegions[regionTag] then
		isToxic = false
		return isToxic
	else
    	for i, w in pairs(toxicZoneRegions[regionTag]) do
			local zone = i
			local startX = toxicZoneRegions[regionTag][zone].startX
			local startY = toxicZoneRegions[regionTag][zone].startY
			local endX = toxicZoneRegions[regionTag][zone].endX
			local endY = toxicZoneRegions[regionTag][zone].endY

			if startX > endX then
				startX = toxicZoneRegions[regionTag][zone].endX
				endX = toxicZoneRegions[regionTag][zone].startX
			end
			if startY > endY then
				startY = toxicZoneRegions[regionTag][zone].endY
				endY = toxicZoneRegions[regionTag][zone].startY
			end
			if square:getX() < startX or square:getX() > endX or square:getY() < startY or square:getY() > endY then

			else
				isToxic = true
				return isToxic
			end
		end
	end
	return isToxic
end

Events.OnPlayerUpdate.Add(shouldTakeToxicDamage);
Events.OnPreUIDraw.Add(function()
	if toxicOvCap then
		toxicAlpha = toxicAlpha + 0.05;
		if toxicAlpha > 0.6 then toxicAlpha = 0.6 end;
	else
		toxicAlpha = toxicAlpha - 0.05;
		if toxicAlpha < 0 then toxicAlpha = 0 end;
	end

	if toxicAlpha > 0 then
		UIManager.DrawTexture( toxicOverlay, 0, 0, width, height, toxicAlpha)
	end
end)