--***********************************************************
--**                       BitBraven                       **
--***********************************************************

local OnExitVehicle = ISVehicleMenu.onExit
local tickCounter = 0
local bbDebugTick = 0
local bbLastVehicleScriptName = nil

-- true = печать в console.txt (Logs). Поза починена, по умолчанию выкл.
local BB_BIKE_ANIM_DEBUG = false

local BikeAnimDebug = function(msg)
	if BB_BIKE_ANIM_DEBUG then
		print("[BB_BikeAnim] " .. tostring(msg))
	end
end

-- Damage variables
local bikeEngine
local bikeCondition = 0

--#region AUXILIARY FUNCTIONS

local EnteredBike = function(vehicle, playerObj)
		-- Haxx to disable vehicle UI, fix invisible parts and get the bicycle started
		if (vehicle:isDriver(playerObj)) then

			if getPlayerVehicleDashboard(playerObj:getPlayerNum()).vehicle ~= nil then

				getPlayerVehicleDashboard(playerObj:getPlayerNum()):setVehicle(nil)				

				-- ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("Engine"))
				-- ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("GasTank"))
				-- ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("Battery"))
				-- ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("TireFrontRight"))
				-- ISVehicleMechanics.onCheatRepairPart(playerObj, vehicle:getPartById("TireRearRight"))
				local engine = vehicle:getPartById("Engine") -- Двигатель				
				if engine then engine:setCondition(100) end
				
				local gasTank = vehicle:getPartById("GasTank") -- Бак				
				if gasTank then 
					gasTank:setCondition(100) 
					gasTank:setContainerContentAmount(100) -- 100 топлива
				end
				
				local battery = vehicle:getPartById("Battery") -- Аккумулятор				
				if battery then
					battery:setCondition(100)
					local itm = battery:getInventoryItem()
					if itm and itm.setUsedDelta then itm:setUsedDelta(1.0) end
					vehicle:transmitPartItem(battery)
				end
				
				
				local tireFrontRight = vehicle:getPartById("TireFrontRight") -- Переднее правое колесо				
				if tireFrontRight then tireFrontRight:setCondition(100) end
				
				local tireRearRight = vehicle:getPartById("TireRearRight") -- Заднее правое колесо				
				if tireRearRight then tireRearRight:setCondition(100) end

				vehicle:setHotwired(true)
				vehicle:engineDoRunning()

			end

			-- if getWorld():getGameMode() == "Multiplayer" then --MP Haxx
			-- 	sendClientCommand(playerObj, 'vehicle', 'startEngine', {haveKey=true})
			-- end
		end
end

-- Must match m_StringValue in AnimSets/player-vehicle/idle/*.xml
local GetBikeType = function(bikeName)
	bikeName = bikeName:gsub("Scrap", "")
	if bikeName == "Base.BicycleRegular" then
		return "BikeRegular"
	elseif bikeName == "Base.BicycleMTB" then
		return "BikeMTB"
	end
	return ""
end

local GetBikeAnimClip = function(bikeName)
	bikeName = bikeName:gsub("Scrap", "")
	if bikeName == "Base.BicycleRegular" then
		return "The_Bike_Idle"
	elseif bikeName == "Base.BicycleMTB" then
		return "The_MTBike_Idle"
	end
	return ""
end

local ClearNickNoobsVehicleVars = function(playerObj, source)
	-- Car_hondacrv95 / Car_toyotahilux89: баг ставит NickNoobsVehicle=true на ВСЕ ТС
	if playerObj:isVariable("NickNoobsVehicle", "true") or playerObj:isVariable("NickNoobsVehicle_Driver", "true") then
		playerObj:SetVariable("NickNoobsVehicle", "false")
		playerObj:SetVariable("NickNoobsVehicle_Driver", "false")
		BikeAnimDebug(source .. ": cleared NickNoobsVehicle vars")
	end
end

local LogBikeAnimState = function(playerObj, vehicle, source)
	if not BB_BIKE_ANIM_DEBUG or not playerObj then return end

	local expectedClip = vehicle and GetBikeAnimClip(vehicle:getScriptName()) or "?"
	local expectedType = vehicle and GetBikeType(vehicle:getScriptName()) or "?"
	local vehicleScriptName = playerObj:getVariableString("VehicleScriptName") or ""
	local bikeType = playerObj:getVariableString("BikeType") or ""
	local nickNoobs = playerObj:getVariableString("NickNoobsVehicle") or ""
	local nickNoobsDriver = playerObj:getVariableString("NickNoobsVehicle_Driver") or ""
	local animState = ""
	local actionState = ""
	local childState = ""

	local okAnim, animResult = pcall(function() return playerObj:getAnimationStateName() end)
	if okAnim and animResult then animState = animResult end

	local okAction, actionResult = pcall(function() return playerObj:getCurrentActionContextStateName() end)
	if okAction and actionResult then actionState = actionResult end

	local okChild, childResult = pcall(function()
		local ctx = playerObj:getActionContext()
		if not ctx then return "" end
		local child = ctx:getChildStateAt(0)
		if child then return child:getName() end
		return ""
	end)
	if okChild and childResult then childState = childResult end

	if bbLastVehicleScriptName ~= vehicleScriptName then
		BikeAnimDebug("VehicleScriptName: '" .. tostring(bbLastVehicleScriptName) .. "' -> '" .. vehicleScriptName .. "' (" .. source .. ")")
		bbLastVehicleScriptName = vehicleScriptName
	end

	BikeAnimDebug(string.format(
		"[%s] veh=%s clip=%s type=%s | VSN='%s' BikeType='%s' | NickNoobs='%s' Driver='%s' | anim=%s action=%s child=%s",
		source,
		vehicle and vehicle:getScriptName() or "?",
		expectedClip,
		expectedType,
		vehicleScriptName,
		bikeType,
		nickNoobs,
		nickNoobsDriver,
		animState,
		actionState,
		childState
	))
end

local ApplyBikeAnimVariables = function(playerObj, vehicle, source)
	local animClip = GetBikeAnimClip(vehicle:getScriptName())
	local bikeType = GetBikeType(vehicle:getScriptName())
	if animClip == "" then return end

	ClearNickNoobsVehicleVars(playerObj, source)
	playerObj:SetVariable("VehicleScriptName", animClip)
	playerObj:SetVariable("BikeType", bikeType)

	BikeAnimDebug(source .. ": set VSN='" .. animClip .. "' BikeType='" .. bikeType .. "'")
	LogBikeAnimState(playerObj, vehicle, source .. "/afterSet")
end

local ApplyBikeSeatPose = function(playerObj, vehicle, source)
	source = source or "ApplyBikeSeatPose"
	local seat = vehicle:getSeat(playerObj)
	ApplyBikeAnimVariables(playerObj, vehicle, source)
	vehicle:setCharacterPosition(playerObj, seat, "inside")
	vehicle:transmitCharacterPosition(seat, "inside")
end

local SetBikeAnimVariable = function(playerObj, vehicle, source)
	ApplyBikeAnimVariables(playerObj, vehicle, source or "SetBikeAnimVariable")
end

local ClearBikeAnimVariable = function(playerObj)
	playerObj:SetVariable("VehicleScriptName", "")
	playerObj:clearVariable("BikeType")
	BikeAnimDebug("ClearBikeAnimVariable")
end

-- Throw the player off the bicycle!
local FallOut = function(playerObj)

	local vehicle = playerObj:getVehicle()
	BravensUtils.TryStopSoundClip(vehicle, "BicycleRide")

	vehicle:exit(playerObj)
	vehicle:setHotwired(false)
	vehicle:shutOff()

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
			local diff = math.abs(bikeCondition - bikeEngine:getCondition())
			if diff > 6 then  
				if (ZombRand(100) <= 40) then 
					FallOut(playerObj)
				end
			end
			
			if diff ~= 0 then  
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
-- Делаем так, чтобы зомби атаковали игрока, если он едет очень медленно
local onZombieUpdate = function(zombie)
	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end
	if not BravensBikeUtils.isBike(vehicle) then return end
	if not zombie:getTarget() == playerObj then return end
	if vehicle:getCurrentSpeedKmHour() > 5 or vehicle:getCurrentSpeedKmHour() < -5 then return end
	if not zombie:isAttacking() then return end
	if vehicle:getDistanceSq(zombie) > 1 then return end

	if(ZombRand(100) == 1) then
		playerObj:getBodyDamage():AddRandomDamageFromZombie(zombie, nil)
	end
end

local onTick = function(tick)
	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle(); if not vehicle then return end
	if BravensBikeUtils.isBike(vehicle) then
		local expectedClip = GetBikeAnimClip(vehicle:getScriptName())
		local expectedType = GetBikeType(vehicle:getScriptName())
		local needsFix = false

		if expectedClip ~= "" and playerObj:getVariableString("VehicleScriptName") ~= expectedClip then
			needsFix = true
		end
		if expectedType ~= "" and playerObj:getVariableString("BikeType") ~= expectedType then
			needsFix = true
		end
		if playerObj:isVariable("NickNoobsVehicle", "true") or playerObj:isVariable("NickNoobsVehicle_Driver", "true") then
			needsFix = true
		end

		if needsFix then
			SetBikeAnimVariable(playerObj, vehicle, "onTick/fix")
		end

		if BB_BIKE_ANIM_DEBUG then
			bbDebugTick = bbDebugTick + 1
			if bbDebugTick >= 120 then
				LogBikeAnimState(playerObj, vehicle, "onTick/status")
				bbDebugTick = 0
			end
		end

		if tickCounter < 70 then
			tickCounter = tickCounter + 1
		else
			OccasionalCheck()
			tickCounter = 0
		end
	end
end

local OnEnterVehicle = function(playerObj)
	local vehicle = playerObj:getVehicle(); if not vehicle then return end -- Получаем велосипед игрока
	if BravensBikeUtils.isBike(vehicle) then -- Если велосипед
		bikeEngine = vehicle:getPartById("Engine") -- Получаем двигатель велосипеда
		bikeCondition = 100 -- Устанавливаем состояние двигателя на 100%
		ApplyBikeSeatPose(playerObj, vehicle, "OnEnterVehicle")
		BravensUtils.DelayFunction(function()
			if playerObj:getVehicle() == vehicle then
				ApplyBikeSeatPose(playerObj, vehicle, "OnEnterVehicle/delayed")
			end
		end, 30)
		local windowPart = vehicle:getPartById("WindowFront") -- Получаем часть велосипеда

		if windowPart and windowPart:getWindow():isOpen() == false then -- Если окно закрыто
			local args = { vehicle = vehicle:getId(), part = windowPart:getId(), open = true } --подготовка аргументов
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
-- Обёртка в конце цепочки, после car-модов (NickNoobs)

local chained_ISEnterVehicle_start = ISEnterVehicle.start
function ISEnterVehicle:start()
	chained_ISEnterVehicle_start(self)
	if self.vehicle and BravensBikeUtils.isBike(self.vehicle) then
		SetBikeAnimVariable(self.character, self.vehicle, "ISEnterVehicle:start/chain")
	end
end

local chained_ISEnterVehicle_perform = ISEnterVehicle.perform
function ISEnterVehicle:perform()
	chained_ISEnterVehicle_perform(self)
	if self.vehicle and BravensBikeUtils.isBike(self.vehicle) then
		ApplyBikeSeatPose(self.character, self.vehicle, "ISEnterVehicle:perform/chain")
	end
end

local chained_ISExitVehicle_perform = ISExitVehicle.perform
function ISExitVehicle:perform()
	if self.character:getVehicle() and BravensBikeUtils.isBike(self.character:getVehicle()) then
		ClearBikeAnimVariable(self.character)
	end
	chained_ISExitVehicle_perform(self)
end

ISVehicleMenu.onExit = function(playerObj, seatFrom)
	local vehicle = playerObj:getVehicle();
	if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		bikeEngine = nil

		-- Delay because game is now sending this command earlier for <<SOME REASON™>>
		BravensUtils.DelayFunction(function()

			playerObj:SetVariable("VehicleScriptName", "")
			playerObj:clearVariable("BikeType")
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

BikeAnimDebug("BikeMain.lua loaded, debug=" .. tostring(BB_BIKE_ANIM_DEBUG))
