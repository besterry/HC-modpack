if isServer() then return end
TZone = TZone or {}
local ZombieSprinter = SandboxVars.ToxicZone.ZombieSprinter or false
local ZombieSprinterChance = SandboxVars.ToxicZone.SprinterChance or 1
local ZombieSprinterRadius = SandboxVars.ToxicZone.SprinterRadius or 30
local ZombieSprinterMax = SandboxVars.ToxicZone.SprinterMax or 1
local tickCounter = 0

local WEAK_STIMS = {
	"injectorItems.injector_trimadol",
	"injectorItems.injector_morphine",
	"injectorItems.injector_norepinephrine",
	"injectorItems.injector_meldonin",
	"injectorItems.injector_zagustin",
}

local MEDIUM_STIMS = {
	"injectorItems.injector_adrenaline",
	"injectorItems.injector_etg",
	"injectorItems.injector_xtg",
	"injectorItems.injector_ahf1",
	"injectorItems.injector_p22",
	"injectorItems.injector_pnb",
	"injectorItems.injector_mule",
	"injectorItems.injector_sj1",
	"injectorItems.injector_sj9",
	"injectorItems.injector_perfotoran",
}

local STRONG_STIMS = {
	"injectorItems.injector_propital",
	"injectorItems.injector_sj6",
	"injectorItems.injector_sj12",
	"injectorItems.injector_btg2a2",
	"injectorItems.injector_btg3",
	"injectorItems.injector_obdolbos",
	"injectorItems.injector_obdolbos2",
}

local function pickRandom(list)
	return list[ZombRand(#list) + 1]
end

local function addLootItem(zombie, itemType)
	if zombie and itemType then
		zombie:getInventory():AddItem(itemType)
	end
end

function TZone.isSprinterZombie(zombie)
	if not zombie then return false end
	local modData = zombie:getModData()
	return modData and (modData.wasSprinter or modData.sprinterActivated) or false
end

local function rollNormalLoot(zombie)
	local roll = ZombRand(1000)
	if roll < 25 then
		addLootItem(zombie, pickRandom(WEAK_STIMS))
	elseif roll < 30 then
		addLootItem(zombie, "Hydrocraft.GasFilterUsed")
	elseif roll < 33 then
		addLootItem(zombie, "Base.ShotgunShellsBox")
	end
end

local function rollSprinterBonus(zombie)
	local roll = ZombRand(1000)
	if roll < 550 then
		return
	elseif roll < 800 then
		addLootItem(zombie, pickRandom(WEAK_STIMS))
	elseif roll < 920 then
		addLootItem(zombie, pickRandom(MEDIUM_STIMS))
	elseif roll < 970 then
		addLootItem(zombie, pickRandom(STRONG_STIMS))
	elseif roll < 990 then
		addLootItem(zombie, "Hydrocraft.GasFilter")
	elseif roll < 995 then
		addLootItem(zombie, "Hydrocraft.latexfabric")
	end
end

local function OnHitZombie(zombie, player, bodyPart, damage)
	ZombieSprinter = SandboxVars.ToxicZone.ZombieSprinter or false
	if not ZombieSprinter then return end
	if not player or not zombie then return end
	if TZone.isPlayerInTZone(player) then
		ZombieSprinterChance = SandboxVars.ToxicZone.SprinterChance or 1
		if ZombRand(100) < ZombieSprinterChance then
			local cell = getCell()
			local zombies = cell:getZombieList()
			local playerX = player:getX()
			local playerY = player:getY()
			ZombieSprinterMax = SandboxVars.ToxicZone.SprinterMax or 1
			local maxSprinters = ZombieSprinterMax
			local currentSprinters = 0
			for i = 0, zombies:size() - 1 do
				if currentSprinters >= maxSprinters then break end

				local nearbyZombie = zombies:get(i)
				if nearbyZombie and nearbyZombie:isAlive() then
					local zombieX = nearbyZombie:getX()
					local zombieY = nearbyZombie:getY()
					local distance = math.sqrt((playerX - zombieX)^2 + (playerY - zombieY)^2)
					if distance >= 2 and distance <= 10 then
						nearbyZombie:setTarget(player)
						nearbyZombie:playSound("Sprinter_Screech_" .. ZombRand(1, 6))
						nearbyZombie:setWalkType("sprint"..tostring(ZombRand(1, 5)))
						local modData = nearbyZombie:getModData()
						modData.sprinterActivated = true
						modData.wasSprinter = true
						currentSprinters = currentSprinters + 1
						ZombieSprinterRadius = SandboxVars.ToxicZone.SprinterRadius or 30
						addSound(player, playerX, playerY, 0, ZombieSprinterRadius, 90)
						local function createDelayedSound(delay)
							local tickCount = 0
							local function delayedSound()
								tickCount = tickCount + 1
								if tickCount == delay then
									addSound(player, playerX, playerY, 0, ZombieSprinterRadius, 90)
									Events.OnTick.Remove(delayedSound)
								end
							end
							Events.OnTick.Add(delayedSound)
						end
						createDelayedSound(30)
						createDelayedSound(60)
					end
				end
			end
		end
	end
end

local function onZombieUpdate(zombie)
	tickCounter = tickCounter + 1
	if tickCounter < 500 then
		return
	end
	tickCounter = 0
	if TZone.isPlayerInTZone(zombie) then
		local modData = zombie:getModData()
		if modData.sprinterActivated then
			if zombie:isAlive() and not zombie:getTarget() then
				zombie:setWalkType("slow"..tostring(ZombRand(1, 4)))
				modData.sprinterActivated = nil
			end
		end
	end
end

local function SpawnLoot(zombie)
	if not TZone.isPlayerInTZone(zombie) then
		return
	end
	rollNormalLoot(zombie)
	if TZone.isSprinterZombie(zombie) then
		rollSprinterBonus(zombie)
	end
end

Events.OnHitZombie.Add(OnHitZombie)
Events.OnZombieDead.Add(SpawnLoot)
Events.OnZombieUpdate.Add(onZombieUpdate)
