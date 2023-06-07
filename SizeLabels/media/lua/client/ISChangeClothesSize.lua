require "TimedActions/ISBaseTimedAction"
ISChangeClothesSize = ISBaseTimedAction:derive("ISChangeClothesSize");

function ISChangeClothesSize:isValid()
	return self.character:getInventory():contains(self.item)
end

function ISChangeClothesSize:setAnimName1()
	local anim = self.plot[#self.plot]
	if #self.plot > 1 then
		table.remove(self.plot)
	end
	if anim == "Loot" then
		self:setActionAnim(anim)
	else
		self:setActionAnim(CharacterActionAnims.Bandage)
		self:setAnimVariable("BandageType", anim);
	end
end


function ISChangeClothesSize:update()
	self.item:setJobDelta(self:getJobDelta());
	if self.must_anim_next then
		self.must_anim_next = false
		self:setAnimName1();
	end
	local now = os.time()
	if now - self.start_time > 6 then
		self.start_time = now
		self.action:stopTimedActionAnim()
		self:setOverrideHandModels(nil, nil)
		self.must_anim_next = true
	end
end

function ISChangeClothesSize:start()
	self.start_time = os.time()

  self.item:setJobType(getText("IGUI_JobType_CheckLabel"));
  self.item:setJobDelta(0.0);

	self:setAnimName1();
	self:setOverrideHandModels(nil, nil);
end

function ISChangeClothesSize:stop()
	ISBaseTimedAction.stop(self);
	self.item:setJobDelta(0.0);
end

function ISChangeClothesSize:perform()
	local MATERIAL_COUNT = 2
	local THREAD_DELTA = 0.2 -- Thread

	self.item:setJobDelta(0.0);
	ISBaseTimedAction.perform(self);

	local fabric_table = {
		Cotton = 'RippedSheets',
		Denim = 'DenimStrips',
		Leather = 'LeatherStrips'
	}

	local level = self.character:getPerkLevel(Perks.Tailoring)
	if level < 8 then
		self.character:Say(getText('IGUI_NeedPerkLvl'))
		return
	end

	local character = self.character
	local item = self.item
	local inv = character:getInventory()

	local actionType = self.actionType
	local data = item:getModData()
	local fabric = item:getFabricType() -- Cotton, Denim, Leather
	local material = fabric_table[fabric]

	local hasNeedle = character:hasItems('Needle', 1)
	local hasScissors = character:hasItems('Scissors', 1)
	local hasMaterials = character:hasItems(material, MATERIAL_COUNT)
	local thread = inv:FindAndReturn('Thread')
	local threadDelta = 0
	local hasThread = false

	if thread and thread:getDelta() >= THREAD_DELTA then
		threadDelta = thread:getDelta()
		hasThread = true
	end	

	if hasNeedle and hasScissors and hasMaterials and hasThread then
		for i=MATERIAL_COUNT,1,-1 do 
			inv:Remove(material)
		end
		thread:setDelta(threadDelta - THREAD_DELTA)
	else
		getPlayer():Say(getText('IGUI_NeedToolsAndMaterials'))
		--self.character:Say(getText('IGUI_NeedToolsAndMaterials'))
		return
	end

	if actionType == '+' then
		data.sz = data.sz + 1
	end
	if actionType == '-' then
		data.sz = data.sz - 1
	end
end

local fix_speed = 0.35
local function fix(t)
    return math.floor(t * fix_speed)
end

local PLOT = {
	Upper = { --from ending
		{"LowerBody", "UpperBody", time=fix(580)},
		{"LowerBody", "UpperBody", time=fix(290)},
		{"LowerBody", time=fix(200)},
		{"LowerBody", time=fix(100)},
	},
	Lower = {
		{"LowerBody", time=fix(580)},
		{"LowerBody", time=fix(290)},
		{"LowerBody", time=fix(200)},
		{"LowerBody", time=fix(100)},
	},
	Inv = {
		{"Loot", time=fix(580)},
		{"Loot", time=fix(290)},
		{"Loot", time=fix(200)},
		{"Loot", time=fix(100)},
	},
}


local function easyCopy(src)
	local t = {}
	for k,v in pairs(src) do
		t[k] = v
	end
	return t
end

--time==100 ~ 2.1 seconds
function ISChangeClothesSize:new(player, item, actionType) --print('create action!')
	local o = {}
	setmetatable(o, self)
	self.__index = self;
	o.character = player;
	o.item = item
	local skill = player:getPerkLevel(Perks.Tailoring) + 1 --1..4
	if skill > 4 then
		skill = 4
	end
	if not item:isEquipped() then
		o.plot = easyCopy(PLOT.Inv[skill])
	else
		local slot_data = GLOBAL_CLOTHES_SLOTS[item:getBodyLocation()]
		local low = slot_data and slot_data.low
		if low then
			o.plot = easyCopy(PLOT.Lower[skill])
		else
			o.plot = easyCopy(PLOT.Upper[skill])
		end
	end
	--local bodyPart = BloodBodyPartType.UpperLeg_L
	--o.bodyPart = bodyPart;
	--o.anim = xxx or "LowerBody" --LowerBody UpperBody LeftLeg LeftArm
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.maxTime = o.plot.time
	o.actionType = actionType
	print('o.actionType', o.actionType)
	return o;
end
