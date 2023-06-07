require "TimedActions/ISBaseTimedAction"
ISCheckClothesLabel = ISBaseTimedAction:derive("ISCheckClothesLabel");

function ISCheckClothesLabel:isValid()
	return self.character:getInventory():contains(self.item)
end

--function ISCheckClothesLabel:waitToStart()
--	return false
--end

function ISCheckClothesLabel:setAnimName1()
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
	--return anim
end


function ISCheckClothesLabel:update()
	self.item:setJobDelta(self:getJobDelta());
	if self.must_anim_next then
		self.must_anim_next = false
		self:setAnimName1();
		--self:setOverrideHandModels(nil, nil)
	end
	local now = os.time()
	if now - self.start_time > 6 then
		self.start_time = now
		self.action:stopTimedActionAnim()
		self:setOverrideHandModels(nil, nil)
		self.must_anim_next = true
	end
end

function ISCheckClothesLabel:start()
	self.start_time = os.time()

  self.item:setJobType(getText("IGUI_JobType_CheckLabel"));
  self.item:setJobDelta(0.0);

	self:setAnimName1();

	--self:setActionAnim("Loot")
	--self.character:SetVariable("LootPosition", "Mid")
	self:setOverrideHandModels(nil, nil);
end

function ISCheckClothesLabel:stop()
	--ISHealthPanel.setBodyPartActionForPlayer(self.otherPlayer, self.bodyPart, nil, nil, nil)
	ISBaseTimedAction.stop(self);
	self.item:setJobDelta(0.0);
end

function ISCheckClothesLabel:perform()
	-- needed to remove from queue / start next.
	self.item:setJobDelta(0.0);
	ISBaseTimedAction.perform(self);
	--print('check!!')
	local say_size = false
	local item = self.item
	local data = item:getModData()
	local sz = data.sz
	if not sz then
		data.sz = STAR_MODS.SizeLabels.getRandomCSize()
		say_size = true
	elseif sz > 20 then
		local phrases = {"IGUI_NoLabel_Say1", "IGUI_NoLabel_Say2", "IGUI_NoLabel_Say3"}
		local phrase = phrases[ZombRand(3) + 1]
		self.character:Say(getText(phrase))
	elseif sz > 10 then
		data.sz = sz - 10
		say_size = true
	else
		print('ERROR: label already revealed')
	end
	if say_size then
		local phrase = tostring(STAR_MODS.SizeLabels.CSIZE[data.sz])
		--print(sz,phrase,STAR_MODS.SizeLabels.CSIZE)
		self.character:Say(phrase)
		local level = self.character:getPerkLevel(Perks.Tailoring)
		if level < 1 then
			self.character:getXp():AddXP(Perks.Tailoring, 0.5);
		end
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
function ISCheckClothesLabel:new(player, item) --print('create action!')
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
	return o;
end
