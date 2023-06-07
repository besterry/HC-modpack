require "TimedActions/ISBaseTimedAction"
ISChangeClothesSize = ISBaseTimedAction:derive("ISChangeClothesSize");

local SM_INST = ScriptManager.instance

local MATERIAL_COUNT = 2
local THREAD_DELTA = 0.2

local THREAD_NAME = 'Thread'

local FABRIC_TABLE = {
	Cotton = 'RippedSheets',
	Denim = 'DenimStrips',
	Leather = 'LeatherStrips'
}

local TOOLS_NAMES = {
	'Needle',
	'Scissors'
}

local function getDisplayName(nameStr)
	return SM_INST:FindItem(nameStr):getDisplayName()
end

local function getUnavailableToolsNamesList(character)
	local result = {}
	for index, value in ipairs(TOOLS_NAMES) do
		if not character:HasItem(value) then
			local displayName = getDisplayName(value)
			table.insert(result, displayName)
		end
	end
	return result
end

local function getUnavailableMaterialsTable(inventory, material)
	local materialsArr = inventory:FindAll(material)
	local materialsFoundInt = materialsArr:size()
	local displayName = getDisplayName(material)
	local remainingCount = materialsFoundInt < MATERIAL_COUNT and MATERIAL_COUNT - materialsFoundInt or 0
	return {
		name = displayName,
		count = remainingCount
	}
end

local function getThreadDeltaSum(inventory)
	local threadsArr = inventory:FindAll(THREAD_NAME)
	local deltaSum = 0
	for i = 1, threadsArr:size(), 1 do
		deltaSum = deltaSum + threadsArr:get(i-1):getDelta()
	end
	return deltaSum
end

local function renderNeedsStr(neededToolslist, neededMaterialTable, threadDeltaSum)
	local prefix = getText('IGUI_NeedToolsAndMaterialsPrefix')
---@diagnostic disable-next-line: deprecated
	local resultList = {unpack(neededToolslist)} -- Копируем список, чтобы случайно не мутировать его. Это best practice
	local remainingMatCount = neededMaterialTable['count']

	if remainingMatCount ~= 0 then
		table.insert(resultList, neededMaterialTable['name'] .. ' ' .. remainingMatCount .. getText('IGUI_Pieces'))
	end
	if threadDeltaSum < THREAD_DELTA  then
		local needDeltaPercenatges = (THREAD_DELTA - threadDeltaSum) * 100 -- NOTE: Считаем нить в процентах, это понятнее пользователю
		-- local renderNeedPercenatges = ('%.2g'):format(needDeltaPercenatges) -- NOTE: Оставляем только 2 знака после запятой
		local renderNeedPercenatges = math.floor(needDeltaPercenatges + 0.5) -- NOTE: округляем до целого процента
		renderNeedPercenatges = renderNeedPercenatges == 0 and 1 or renderNeedPercenatges -- NOTE: Если округлилось до 0, показываем 1
		table.insert(resultList, getDisplayName(THREAD_NAME) .. ' ' .. renderNeedPercenatges .. '%')
	end
	return prefix .. table.concat(resultList, ', ')
end

local function useConsumableItems(inventory, material)
	for i=MATERIAL_COUNT,1,-1 do
		inventory:Remove(material)
	end
	local deltaRemains = THREAD_DELTA
	local threadsArr = inventory:FindAll(THREAD_NAME)
	for i = 1, threadsArr:size(), 1 do
		local thisThread = threadsArr:get(i-1) 
		local thisDelta = thisThread:getDelta()
		if thisDelta < deltaRemains then
			deltaRemains = deltaRemains - thisDelta
			thisDelta = 0
			thisThread:setDelta(thisDelta)
		else
			thisDelta = thisDelta - deltaRemains
			thisThread:setDelta(thisDelta)
			deltaRemains = 0
		end
		if thisDelta == 0 then
			inventory:Remove(thisThread) -- NOTE: удаляем пустую катушку
			-- NOTE: В игре есть баг с математикой, если отнимать от 1 по 0.2, то рано или поздно возникают цифры далеко после запятой. 
			-- Так что часто в катушке остаётся немного нитки. Но с этим видимо ничего не поделать. Это происходит не только с нитками. 
			-- На работоспособность это не влияет
		end
	end
end

function ISChangeClothesSize:perform()
	self.item:setJobDelta(0.0);
	ISBaseTimedAction.perform(self);

	local character = self.character

	local tailoringLvl = character:getPerkLevel(Perks.Tailoring)
	if tailoringLvl < 8 then
		self.character:Say(getText('IGUI_NeedPerkLvl'))
		return
	end

	local item = self.item
	local actionType = self.actionType
	local inventory = character:getInventory()
	local data = item:getModData()
	local fabric = item:getFabricType() -- Cotton, Denim, Leather
	local material = FABRIC_TABLE[fabric]

	local neededToolslist = getUnavailableToolsNamesList(character)
	local neededMaterialTable = getUnavailableMaterialsTable(inventory, material)
	local threadDeltaSum = getThreadDeltaSum(inventory)

	if #neededToolslist ~= 0 or neededMaterialTable['count'] ~= 0 or threadDeltaSum < THREAD_DELTA then
		local needsStr = renderNeedsStr(neededToolslist, neededMaterialTable, threadDeltaSum)
		character:Say(needsStr)
		return
	end

	useConsumableItems(inventory, material)

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
	o.stopOnWalk = false;
	o.stopOnRun = true;
	o.maxTime = o.plot.time
	o.actionType = actionType
	return o;
end

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