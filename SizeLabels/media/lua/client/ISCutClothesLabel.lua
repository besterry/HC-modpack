require "TimedActions/ISBaseTimedAction"
ISCutClothesLabel = ISBaseTimedAction:derive("ISCutClothesLabel");

function ISCutClothesLabel:isValid()
	return self.character:getInventory():contains(self.item)
end

--function ISCutClothesLabel:waitToStart()
--	return false
--end


function ISCutClothesLabel:update()
	self.item:setJobDelta(self:getJobDelta());
	--[[if self.must_anim_next then
		self.must_anim_next = false
		self:setActionAnim("Loot")
		--self:setOverrideHandModels(nil, nil)
	end
	local now = os.time()
	if now - self.start_time > 6 then
		self.start_time = now
		self.action:stopTimedActionAnim()
		self:setOverrideHandModels(nil, nil)
		self.must_anim_next = true
	end--]]
end

function ISCutClothesLabel:start()
	--self.start_time = os.time()

  self.item:setJobType(getText("IGUI_JobType_CutLabel"));
  self.item:setJobDelta(0.0);

	self:setActionAnim("Loot");
	self:setOverrideHandModels(nil, nil);
	
	--self.character:getEmitter():playSound("SewingScissors");
	self.sound = self.character:playSound("SewingScissors");
	local radius = 10
	addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), radius, radius)
end

function ISCutClothesLabel:stop()
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
		self.sound = nil
	end
	ISBaseTimedAction.stop(self);
	self.item:setJobDelta(0.0);
end

function ISCutClothesLabel:perform() --print('perform')
	if self.sound then
		self.character:getEmitter():stopSound(self.sound)
		self.sound = nil
	end
	-- needed to remove from queue / start next.
	self.item:setJobDelta(0.0);
	ISBaseTimedAction.perform(self);
	--print('cut!!')
	local item = self.item
	local data = item:getModData()
	local sz = data.sz
	if not sz or sz > 20 then
		return
	end
	while sz < 20 do
		sz = sz + 10
	end
	data.sz = sz
	local level = self.character:getPerkLevel(Perks.Tailoring)
	if level < 1 then
		self.character:getXp():AddXP(Perks.Tailoring, 0.5);
	end
	
end



--time==100 ~ 2.1 seconds
function ISCutClothesLabel:new(player, item) --print('create action!')
	local o = {}
	setmetatable(o, self)
	self.__index = self;
	o.character = player;
	o.item = item
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.maxTime = 320
	return o;
end
