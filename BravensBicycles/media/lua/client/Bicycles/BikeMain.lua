--***********************************************************
--**                       BitBraven                       **
--***********************************************************

local OnExitVehicle = ISVehicleMenu.onExit
local tickCounter = 0

-- Damage variables
local bikeEngine
local bikeCondition = 0

--#region AUXILIARY FUNCTIONS

local EnteredBike = function(vehicle, playerObj)

		-- Haxx to disable vehicle UI, fix invisible parts and get the bicycle started
		if (vehicle:isDriver(playerObj)) then

			if getPlayerVehicleDashboard(playerObj:getPlayerNum()).vehicle ~= nil then

				getPlayerVehicleDashboard(playerObj:getPlayerNum()):setVehicle(nil)

				vehicle:setHotwired(true)
				vehicle:engineDoRunning()

				ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("Engine"))
				ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("GasTank"))
				ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("Battery"))
				ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("TireFrontRight"))
				ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("TireRearRight"))

			end

			if getWorld():getGameMode() == "Multiplayer" then --MP Haxx
				sendClientCommand(playerObj, 'vehicle', 'startEngine', {haveKey=true})
			end
		end
end

-- Assign a variable depending on bike type. Simplifies the use of animations.
local GetBikeType = function(bikeName)

	-- Remove scrap from the vehicle name to make my life easier
	bikeName = bikeName:gsub("Scrap", "")
	local bikeType = ""

	if (bikeName == "Base.BicycleRegular") then
		bikeType = "BikeRegular"
	elseif (bikeName == "Base.BicycleMTB") then
		bikeType = "BikeMTB"
	end

	return bikeType
end

-- Throw the player off the bicycle!
local FallOut = function(playerObj)

	local vehicle = playerObj:getVehicle()
	BravensUtils.TryStopSoundClip(vehicle, "BicycleRide")

	vehicle:exit(playerObj)
	vehicle:setHotwired(false)

	playerObj:setBumpFallType("pushedFront")
	playerObj:setBumpType("stagger")
	playerObj:setBumpDone(false)
	playerObj:setBumpFall(true)
end

-- Perform occasional checks so as to conserve performance
local OccasionalCheck = function()

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		-- Sound check
		local bikeSpeed = vehicle:getCurrentSpeedKmHour()

		if (bikeSpeed > -0.15 and bikeSpeed < 0.15) then
			BravensUtils.TryStopSoundClip(vehicle, "BicycleRide")
		else
			BravensUtils.TryPlaySoundClip(vehicle, "BicycleRide")
		end

		-- Collision check
		if bikeEngine then

			if bikeEngine:getCondition() ~= bikeCondition then

				-- 30% chance to fall off when you collide
				if (ZombRand(100) <= 30) then
					FallOut(playerObj)
				end

				bikeCondition = bikeEngine:getCondition()
			end
		end
	end
end
--#endregion

--#region EVENT LISTENERS

local everyTenMinutes = function()

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		if vehicle:getCurrentSpeedKmHour() ~= 0 then

			local fitnessLevel = playerObj:getPerkLevel(Perks.Fitness)

			if fitnessLevel ~= 10 then -- Give some EXP for pedalling every now and then
				playerObj:getXp():AddXP(Perks.Fitness, 30 * fitnessLevel)
			end
		end
	end
end

local everyOneMinute = function()

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		local bikeSpeed = vehicle:getCurrentSpeedKmHour()

		if (bikeSpeed > 1 or bikeSpeed < -1) then

			-- Make the player warmer from pedalling
			if playerObj:getTemperature() < 36 then
				playerObj:setTemperature(playerObj:getTemperature() + (0.1 * vehicle:getCurrentSpeedKmHour()))
			end

			local stats = playerObj:getStats()

			-- Drain the player's stamina from pedalling
			if stats:getEndurance() > 0.21 then
				stats:setEndurance(stats:getEndurance() - (0.00038 * vehicle:getCurrentSpeedKmHour()))
			else
				FallOut(playerObj) -- Crawl out through the fallout, baby!
			end
		end
	end
end

-- Make it so zombies attack the player if they're close enough and the player is pedalling very slowly
local onZombieUpdate = function(zombie)

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		local bodyDamage = playerObj:getBodyDamage()

		if vehicle:getDistanceSq(zombie) < 1 then

			if vehicle:getCurrentSpeedKmHour() > 5 or vehicle:getCurrentSpeedKmHour() < -5 then return end

			if not zombie:isCrawling() and not zombie:isOnFloor() then

				if not zombie:getVariableBoolean("AttackDidDamage") and zombie:getHitReaction() ~= "ZombieGrab" then

					if (ZombRand(300) == 1) then
						zombie:setHitReaction("ZombieGrab")
						bodyDamage:AddRandomDamageFromZombie(zombie, nil)
					end
				end
			end
		end
	end
end

local onTick = function(tick)

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		if tickCounter < 70 then
			tickCounter = tickCounter + 1
		else
			OccasionalCheck()
			tickCounter = 0
		end
	end
end

local OnEnterVehicle = function(playerObj)

	local vehicle = playerObj:getVehicle(); if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		bikeEngine = vehicle:getPartById("Engine")
		bikeCondition = 100
		playerObj:SetVariable("BikeType", GetBikeType(vehicle:getScriptName()))

		local windowPart = vehicle:getPartById("WindowFront")

		if windowPart and windowPart:getWindow():isOpen() == false then -- Force window open
			local args = { vehicle = vehicle:getId(), part = windowPart:getId(), open = true }
			sendClientCommand(playerObj, 'vehicle', 'setWindowOpen', args)
		end

		EnteredBike(vehicle, playerObj)

		-- Subscribe to events only when on a bicycle to conserve performance
		Events.EveryTenMinutes.Add(everyTenMinutes)
		Events.EveryOneMinute.Add(everyOneMinute)
		Events.OnZombieUpdate.Add(onZombieUpdate)
		Events.OnTick.Add(onTick)
	end
end

local OnGameStart = function()
	local playerObj = getPlayer(); if not playerObj then return end
	OnEnterVehicle(playerObj)
end
--#endregion

--#region VANILLA OVERRIDES

ISVehicleMenu.onExit = function(playerObj, seatFrom)

	local vehicle = playerObj:getVehicle();
	if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		bikeEngine = nil

		-- Delay because game is now sending this command earlier for <<SOME REASON™>>
		BravensUtils.DelayFunction(function()

			playerObj:SetVariable("BikeType", "")
			BravensUtils.TryStopSoundClip(vehicle, "BicycleRide")
			vehicle:shutOff()

			-- Remove unnecessary event listeners
			Events.EveryTenMinutes.Remove(everyTenMinutes)
			Events.EveryOneMinute.Remove(everyOneMinute)
			Events.OnZombieUpdate.Remove(onZombieUpdate)
			Events.OnTick.Remove(onTick)
		end, 50);
	end

	OnExitVehicle(playerObj, seatFrom)
end
--#endregion

Events.OnGameStart.Add(OnGameStart);
Events.OnEnterVehicle.Add(OnEnterVehicle)
