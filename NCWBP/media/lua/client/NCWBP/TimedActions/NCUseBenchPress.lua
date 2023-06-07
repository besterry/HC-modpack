--[[
		Developed by Nichals
		Working Bench press 41.65+
]]

require "TimedActions/ISBaseTimedAction"

NCUseBenchPress = ISBaseTimedAction:derive("NCUseBenchPress");

function NCUseBenchPress:isValid()
	return true;
end

local function addXP(currentDelta)
	local player = getPlayer()
	local xp = player:getXp()
	local perkBoost = xp:getPerkBoost(Perks.Strength)
	local multiplier = xp:getMultiplier(Perks.Strength)
	local baseXP = 400

	if perkBoost == 1 then
		baseXP = baseXP * 1.75
	elseif perkBoost== 2 then
		baseXP = baseXP * 2
	elseif perkBoost== 3 then
		baseXP = baseXP * 2.25
	end

	if multiplier ~= 0 then
		baseXP = baseXP*multiplier
	end

	-- get xp multiply from sandbox options
	local strengthXPMultiply = SandboxVars.NCWorkingBenchPress.StrengthXPMultiply

	-- get body part and add stiffness.
	--NCUseBenchPress.addBodyStiffness(player)

	
	-- add xp when perform or stop
	xp:AddXP(Perks.Strength, baseXP* currentDelta * strengthXPMultiply)
end

NCUseBenchPress.addBodyStiffness = function(player)
	local bodypartHandL = player:getBodyDamage():getBodyPart(BodyPartType.Hand_L)
	NCUseBenchPress.addStiffness(bodypartHandL)
	local bodypartForeArmL = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L)
	NCUseBenchPress.addStiffness(bodypartForeArmL)
	local bodypartUpperArmL = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_L)
	NCUseBenchPress.addStiffness(bodypartUpperArmL)
	local bodypartHandR = player:getBodyDamage():getBodyPart(BodyPartType.Hand_R)
	NCUseBenchPress.addStiffness(bodypartHandR)
	local bodypartForeArmR = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_R)
	NCUseBenchPress.addStiffness(bodypartForeArmR)
	local bodypartUpperArmR = player:getBodyDamage():getBodyPart(BodyPartType.UpperArm_R)
	NCUseBenchPress.addStiffness(bodypartUpperArmR)
end

NCUseBenchPress.addStiffness = function(bodypart)
	local baseStiffness = bodypart:getStiffness()
	print(baseStiffness)
	baseStiffness = baseStiffness + 1
	print(baseStiffness)
	bodypart:setStiffness(baseStiffness)
end

local function reduceEndurance(stats, currentDelta, enduranceReduction)
	local enduranceChange = currentDelta * enduranceReduction
	stats:setEndurance(initialEndurance - enduranceChange)
end

function NCUseBenchPress:waitToStart()
	self.character:faceThisObject(self.machine);
	return self.character:shouldBeTurning();
end

function NCUseBenchPress:update()

	local isPlaying = self.gameSound
		and self.gameSound ~= 0
		and self.character:getEmitter():isPlaying(self.gameSound)

	if not isPlaying then
		local soundRadius = 13
		local volume = 6

		self.gameSound = self.character:getEmitter():playSound(self.soundFile);
		
		addSound(self.character,
				 self.character:getX(),
				 self.character:getY(),
				 self.character:getZ(),
				 soundRadius,
				 volume)
	end

	local currentDelta = self:getJobDelta()
	local deltaIncrease = currentDelta - self.deltaTabulated
	
	-- Update at every 0.01 delta milestone
	if deltaIncrease > 0.01 then
		reduceEndurance(self.character:getStats(), currentDelta, 0.85)
		
		self.deltaTabulated = currentDelta
	end
	
	self.character:faceThisObject(self.machine);
end

function NCUseBenchPress:start()

	local actionType = self.actionType

	self:setActionAnim(actionType)
	-- Loot is used as a backup action, so keep this
	self.character:SetVariable("LootPosition", "Mid")
	
	initialEndurance = self.character:getStats():getEndurance()
	
	self:setOverrideHandModels(nil, nil)
end

function NCUseBenchPress:stop()

	if self.gameSound and
		self.gameSound ~= 0 and
		self.character:getEmitter():isPlaying(self.gameSound) then
		self.character:getEmitter():stopSound(self.gameSound);
	end

	local soundRadius = 15
	local volume = 6
	local currentDelta = self:getJobDelta()
	local deltaIncrease = currentDelta - self.deltaTabulated
	
	
	reduceEndurance(self.character:getStats(), currentDelta, 0.85)
	addXP(currentDelta)
	
	self.deltaTabulated = currentDelta

	ISBaseTimedAction.stop(self);
end

function NCUseBenchPress:perform()

	-- Make sure game sound has stopped
	if self.gameSound and
		self.gameSound ~= 0 and
		self.character:getEmitter():isPlaying(self.gameSound) then
		self.character:getEmitter():stopSound(self.gameSound);
	end

	local soundRadius = 13
	local volume = 6
		
	addSound(self.character,
			 self.character:getX(),
			 self.character:getY(),
			 self.character:getZ(),
			 soundRadius,
			 volume)

	local currentDelta = self:getJobDelta()
	local deltaIncrease = currentDelta - self.deltaTabulated
	
	reduceEndurance(self.character:getStats(), currentDelta, 0.85)
	addXP(currentDelta)

	self.deltaTabulated = currentDelta

	ISBaseTimedAction.perform(self);
end

function NCUseBenchPress:new(character, machine, sound, actionType, length)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.machine = machine
	o.soundFile = sound
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = length
	o.gameSound = 0
	o.actionType = actionType
	o.deltaTabulated = 0
	return o;
end