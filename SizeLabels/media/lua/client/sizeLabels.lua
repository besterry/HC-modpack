STAR_MODS = STAR_MODS or {}
STAR_MODS.SizeLabels = STAR_MODS.SizeLabels or {}

--require "XpSystem/ISUI/ISCharacterScreen"

--Fixed for female (65 is normal)
local function getWeightFixed(player)
	local w = player:getNutrition():getWeight()
	if player:isFemale() then
		if w < 50 then
			w = 50 - (50 - w) * 0.333334
		end
		w = w - 15
	end
	return w
end
STAR_MODS.SizeLabels.getWeightFixed = getWeightFixed


local CSIZE= { "XXS",  "XS",  "S",  "M",  "L",  "XL",  "XXL",  "XXXL" }
STAR_MODS.SizeLabels.CSIZE = CSIZE
local CMSIZE={"(XXS)","(XS)","(S)","(M)","(L)","(XL)","(XXL)","(XXXL)"}
local CHANCE={  40,    140,    220,  330,  170,  50,    30,     20}
do
	local sum = 0
	for i,v in ipairs(CHANCE) do
		sum = sum + v
		CHANCE[i] = sum
	end
end
local function getRandomCSize()
	local r = ZombRand(1000) --0...999
	for i=7,1,-1 do
		if r >= CHANCE[i] then
			return i+1
		end
	end
	return 1
end
STAR_MODS.SizeLabels.getRandomCSize = getRandomCSize

local CHANCES = {
	ON_WEAR_VERY_TIGHT = 15,
	ON_WEAR_TIGHT = 5,
	BREAKFAST_MULT = 3,

	BREAK_TIGHT = 0.025,
	BREAK_VERY_TIGHT = 0.05,
	
	DROP_SPACY = 0.03,
	DROP_VERY_SPACY = 0.1,
	DROP_VERYVERY_SPACY = 0.15,
}

--spacy = тянется, breakfast = хлипкая, nofit = допускается только разница 1,
--drop = падает при действиях, nobreak = не рвется вообще
GLOBAL_CLOTHES_SLOTS = {
	BathRobe={spacy=true},
	Dress={breakfast=true},
	FullSuit={},
	Jacket={},
	JacketHat={},
	Legs1={nofit=true,spacy=true,low=true},
	Pants={drop=true,low=true},
	Shirt={breakfast=true},
	Skirt={breakfast=true,drop=true,low=true},
	Sweater={spacy=true},
	SweaterHat={spacy=true},
	TankTop={nofit=true,breakfast=true},
	Torso1Legs1={nofit=true},
	Tshirt={nofit=true,breakfast=true},
	Underwear={nofit=true,nobreak=true,low=true},
	ShortSleeveShirt={breakfast=true},
}
local SLOTS =  GLOBAL_CLOTHES_SLOTS

--ScriptManager.instance:getItem("Base.Battery"):DoParam("Weight = 0.05")




local function getSizeMale(w)
	if w > 120 then
		return 8
	elseif w > 105 then
		return 7
	elseif w > 91 then
		return 6
	elseif w > 76 then
		return 5
	elseif w > 63 then
		return 4
	elseif w > 55 then
		return 3
	elseif w > 46 then
		return 2
	end
	return 1
end
local function getSizeFemale(w)
	if w > 105 then
		return 8
	elseif w > 95 then
		return 7
	elseif w > 79 then
		return 6
	elseif w > 67 then
		return 5
	elseif w > 60 then
		return 4
	elseif w > 49 then
		return 3
	elseif w > 44 then
		return 2
	end
	return 1
end
local function getSizeChr(chr)
	local w = getWeightFixed(chr)
	return chr:isFemale() and getSizeFemale(w) or getSizeMale(w)
end


--CSize
do
	local IGUI_char_Sex = getText("IGUI_char_Sex")
	local IGUI_char_Weight = getText("IGUI_char_Weight")
	local TM = getTextManager()


	local old_drawTextRight,old_drawText,old_drawTexture,is_found_weight,is_found_icon
	--local smallFontHgt
	
	function ISCharacterScreen:drawCSize(x,y,font)
		local sz = getSizeChr(self.char)
		old_drawText(self, CMSIZE[sz], x + 2, y, 1,1,1,1, font or UIFont.Small);
		if STAR_MODS.NutritionIndicator then
			STAR_MODS.NutritionIndicator.sizeLabelsOffset = x + 2 + TM:MeasureStringX(font or UIFont.Small, CMSIZE[sz]);
		end
	end
	
	
	local function new_drawTextRight(self, val, x,y, ...)
		if val == IGUI_char_Weight then
			is_found_weight = true
			local nut = self.char:getNutrition()
			if nut:isIncWeight() or nut:isIncWeightLot() or nut:isDecWeight() then --after icon
				is_found_icon = true
			end
		end
		return old_drawTextRight(self, val, x,y, ...)
	end
	
	local weightStr, saved_x, saved_y, saved_font, weightWid
	local function new_drawText(self, s, x,y, a,b,c,d, font, ...)
		if is_found_weight then
			is_found_weight = false
			if self.char:isFemale() then
				local w = round(getWeightFixed(self.char), 0)
				s = tostring(w)
			end
			weightStr = s; --tostring(round(self.char:getNutrition():getWeight(), 0))
			weightWid = TM:MeasureStringX(UIFont.Small, weightStr);
			if is_found_icon then
				saved_x = x
				saved_y = y
				saved_font = font
			else
				self:drawCSize(x+weightWid, y, font);
			end
		end
		return old_drawText(self, s, x,y, a,b,c,d, font, ...)
	end
	
	--local function new_drawRect(self,x,y,w,h,...)
	--	if h == 1 and is_wait_rect and smallFontHgt then
	--		is_wait_rect = false
	--		y = y - smallFontHgt + 5
	--	end
	--	return old_drawRect(self,x,y,w,h,...)
	--end
	
	local function new_drawTexture(self, ...)
		if is_found_icon and not is_found_weight then
			is_found_icon = false
			local nutritionWidth = weightWid + 13 + 2;
			self:drawCSize(saved_x+nutritionWidth, saved_y, saved_font);
		end
		return old_drawTexture(self, ...)
	end
	

	local in_progress = false
	local old_render = ISCharacterScreen.render
---@diagnostic disable-next-line: duplicate-set-field
	function ISCharacterScreen:render()
		if in_progress then
			if old_drawText then
				if old_drawTextRight and self.drawTextRight == new_drawTextRight then
					self.drawTextRight = old_drawTextRight
				end
				if old_drawText and self.drawText == new_drawText then
					self.drawText = old_drawText
				end
				if old_drawTexture and self.drawTexture == new_drawTexture then
					self.drawTexture = old_drawTexture
				end
				old_drawTextRight = nil
				old_drawText = nil
				old_drawTexture = nil
			end
			return old_render(self)
		end
		is_found_weight = false
		is_found_icon = false
		old_drawTextRight = self.drawTextRight
		old_drawText = self.drawText
		old_drawTexture = self.drawTexture
		self.drawTextRight = new_drawTextRight
		self.drawText = new_drawText
		self.drawTexture = new_drawTexture
		in_progress = true
		old_render(self)
		in_progress = false
		if old_drawText then
			self.drawTextRight = old_drawTextRight
			self.drawText = old_drawText
			self.drawTexture = old_drawTexture
		end
	end
end



local function OnCutLabel(player, items)
	--print("move & cut")
	local inv = player:getInventory()
	for i,item in ipairs(items) do
		local container = item:getContainer()
    if container ~= inv then
			ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, container, inv))
		elseif item:isEquipped() then
			ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50));
    end
		ISTimedActionQueue.add(ISCutClothesLabel:new(player, item))
	end
end

local function OnCheckLabel(player, items)
	--move & check
	local inv = player:getInventory()
	for i,item in ipairs(items) do
		local container = item:getContainer()
    if container ~= inv then
			ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, container, inv))
    end
		ISTimedActionQueue.add(ISCheckClothesLabel:new(player, item))
	end
end

local function OnChangeSize(player, items, actionType)
	local inv = player:getInventory()
	for i,item in ipairs(items) do
		local container = item:getContainer()
    if container ~= inv then
			ISTimedActionQueue.add(ISInventoryTransferAction:new(player, item, container, inv))
    end
		ISTimedActionQueue.add(ISChangeClothesSize:new(player, item, actionType))
	end
end

local function addTooltip(option, title)
	local texture = getTexture("Item_Needle")
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	option.toolTip = toolTip;
	toolTip:setName(title);
	toolTip.description = getText("IGUI_Description")
	toolTip.texture = texture -- HACK: у тултипа есть интерфейс setTexture, но он не работает. Записываем напрямую в переменную инстанса
end

local invContextMenu1 = function(_player, context, worldobjects, test)
	local playerObj = getSpecificPlayer(_player);
	
	local cut_items
	local primary = playerObj:getPrimaryHandItem()
	local secondary = playerObj:getSecondaryHandItem()
	local is_scissors = primary and primary:getType() == "Scissors"
		or secondary and secondary:getType() == "Scissors"
	if is_scissors then
		cut_items = {}
		--print("is_scissors")
	end
	
	local items = {}
	local has_label
	local function mayCheckItem(item)
		has_label = false
		if instanceof(item,"Clothing") and SLOTS[item:getBodyLocation()] then
			local sz = item:getModData().sz
			if sz then 
				if sz < 10 then
					if is_scissors then
						table.insert(cut_items,item)
					end
				else -- sz > 10
					return true
				end
			end
			return not sz
		end
	end

	local item_can_reduced = {}
	local item_can_increased = {}
	local function setChangeSize(item)
		if instanceof(item,"Clothing") and SLOTS[item:getBodyLocation()] then
			local sz = item:getModData().sz
			local condition = item:getCondition()
			local fabric = item:getFabricType()
			if sz and condition > 0 and fabric ~= nil then
				if sz >= 1 and sz < 8 then
					table.insert(item_can_increased, item)
				end
				if sz <=8 and sz > 1 then
					table.insert(item_can_reduced, item)
				end
			end
		end
	end
	
	-- inventory item list
	for i,v in pairs(worldobjects) do
		if type(v) == 'table' then
			if v.items and #v.items > 1 then
				for i=2,#v.items do
					local item = v.items[i]
					if mayCheckItem(item) then
						table.insert(items,item)
					end
					setChangeSize(item)
				end
			end
		else
			if mayCheckItem(v) then
				table.insert(items,v)
			end
			setChangeSize(v)
		end
	end
	
	if #items > 0 then
		context:addOption(getText("IGUI_CheckLabel"), playerObj, OnCheckLabel, items)
	end

	if #item_can_increased > 0 or #item_can_reduced > 0 then
		local changeSizeOption = context:addOption(getText("IGUI_ChangeSize"), worldobjects, nil);
		local subMenu = ISContextMenu:getNew(context);
		context:addSubMenu(changeSizeOption, subMenu);

		if #item_can_increased > 0 then
			local title = getText("IGUI_ChangeSizeIncrese")
			local option = subMenu:addOption(title, playerObj, OnChangeSize, item_can_increased, '+')
			addTooltip(option, title)
		end
		if #item_can_reduced > 0 then
			local title = getText("IGUI_ChangeSizeReduse")
			local option = subMenu:addOption(title, playerObj, OnChangeSize, item_can_reduced, '-')
			addTooltip(option, title)
		end
	end

	--print("num cut items ",#cut_items)
	if is_scissors and #cut_items > 0 then
		context:addOption(getText("IGUI_CutLabel"), playerObj, OnCutLabel, cut_items)
	end
end
Events.OnFillInventoryObjectContextMenu.Add(invContextMenu1);


----------Clothes tooltips---------

local function getSizeItem(item)
	local data = item:getModData()
	return data.sz
end


do
	local MEMORY = {} --indexed
	local MEMORY_ASS = {}
	local function addMemory(item,size) --print('addMemory',size)
		local id = item:getID()
		if not MEMORY_ASS[id] then
			local data = {id=id, size=size}
			MEMORY_ASS[id] = data
			table.insert(MEMORY,data)
			if #MEMORY > 30 then
				data = table.remove(MEMORY,1)
				MEMORY_ASS[data.id] = nil
			end
			return --print('new',#MEMORY)
		end
		for i=#MEMORY,-1,1 do
			local data = MEMORY[i]
			if data.id == id then
				data.size = size
				if i == #MEMORY then
					return --print('ignore',#MEMORY)
				end
				table.remove(MEMORY,i)
				table.insert(MEMORY,data)
				return --print('move',#MEMORY)
			end
		end
	end
	local function getMemory(item) --print('getMemory',size)
		local id = item:getID()
		local data = MEMORY_ASS[id]
		--print("sz",data and data.size)
		return data and data.size
	end


	local COLOR_WHITE = {1,1,1}

	local cache_item = nil
	local cache_render_text = nil

	local old_render = ISToolTipInv.render
---@diagnostic disable-next-line: duplicate-set-field
	function ISToolTipInv:render()
		if self.item ~= cache_item then
			cache_item = self.item
			cache_render_text = nil
			local size = cache_item and getSizeItem(cache_item)
			if size then
				local p = getPlayer()
				local skill = p:getPerkLevel(Perks.Tailoring)
				if size < 10 then
					cache_render_text = CSIZE[size]
					--print(size, CSIZE[size])
					if skill < 5 then
						addMemory(cache_item, size)
					end
				else
					local real_size = size > 20 and size - 20 or size - 10
					local sz_mem = getMemory(cache_item)
					local sz_char = getSizeChr(p)
					local space = nil
					if skill >= 5 or skill == 4 and sz_char == real_size then
						cache_render_text=CMSIZE[real_size]
						addMemory(cache_item, real_size)
					elseif cache_item:isEquipped() then
						space = real_size - sz_char
						space = space >= 1 and 1 or (space <= -1 and -1 or 0)
					elseif sz_mem then --print(sz_mem)
						if sz_mem < 10 then
							cache_render_text=CMSIZE[sz_mem]
						else
							space = sz_mem - 50
						end
					else
						space = real_size - sz_char
						space = space >= 5-skill and 1 or (space <= -5+skill and -1 or nil)
					end
					if space then --print(space,space==-1)
						addMemory(cache_item, space + 50)
						if space == 1 then
							cache_render_text = getText("IGUI_B_Spacious")
						elseif space == -1 then
							cache_render_text = getText("IGUI_B_Tight")
						elseif space == 0 then
							cache_render_text = getText("IGUI_B_Fit")
						end
					end
				end
				if not cache_render_text then
					cache_render_text = "??"
				end
			end
		end
		if not cache_render_text then --small item (or error?)
			return old_render(self)
		end
		-- Ninja double injection in injection!
		local stage = 1
		local save_th = 0
		local old_setHeight = self.setHeight
---@diagnostic disable-next-line: duplicate-set-field
		self.setHeight = function(self, num, ...)
			if stage == 1 then
				stage = 2
				save_th = num
				num = num + 18
			else 
				stage = -1 --error
			end
			return old_setHeight(self, num, ...)
		end
		local old_drawRectBorder = self.drawRectBorder
---@diagnostic disable-next-line: duplicate-set-field
		self.drawRectBorder = function(self, ...)
			if stage == 2 then
				local col = COLOR_WHITE; -- {r,g,b}
				local font = UIFont[getCore():getOptionTooltipFont()];
				self.tooltip:DrawText(font, cache_render_text, 5, save_th-5, col[1], col[2], col[3], 1);
				stage = 3
			else
				stage = -1 --error
			end
			return old_drawRectBorder(self, ...)
		end
		old_render(self)
		self.setHeight = old_setHeight
		self.drawRectBorder = old_drawRectBorder
	end

end


local TIME_INST
local lastRip = 0
--Рвёт одежду
local function RipClothes(item, player)
	local tm = TIME_INST:getWorldAgeHours()
	local diff = tm - lastRip
	if diff < 0.25 then --15 минут еще не прошло
		return --print('15 minutes!')
	end
	--Ищем дырку
	if not item:getCanHaveHoles() then
		return --print("cant make hole")
	end
	local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
	if not coveredParts then
		return --print('no parts')
	end
	local found = {}
	local vis = item:getVisual()
	for i=1,coveredParts:size() do
		local part = coveredParts:get(i-1)
		if vis:getHole(part) == 0 then
			table.insert(found,part)
		end
	end
	if #found == 0 then
		return --print('no parts without hole')
	end
	local part = found[ZombRand(#found) + 1]
	vis:setHole(part); -----> NEW HOLE 100% !!
	lastRip = tm
	--print('set hole!')
	local cond = item:getCondition() - (item:getCondLossPerHole() or 0)
	if cond < 0 then
		cond = 0
	end
	item:setCondition(cond)
	if player then
		player:getEmitter():playSound("ClothesRipping");
	end
	return true
end



local function DropItem(item,player) -- 1: kept, 0: dropped
	if item:isFavorite() then
		item:setFavorite(false)
	end
	local sq = player:getCurrentSquare()
	local dropX,dropY,dropZ = ISInventoryTransferAction.GetDropItemOffset(player, sq, item)
	local inv = player:getInventory()
	player:removeWornItem(item)
	triggerEvent("OnClothingUpdated", player) --see ISUnequipAction:68
	inv:Remove(item)
	sq:AddWorldInventoryItem(item, dropX, dropY, dropZ)
	player:getEmitter():playSound("stab1")
	return true
end



--Проверяет всю надетую одежду. Рвёт, если надо.
--Неинициалиированная одежда получает размер персонажа.
--TODO: оптимизировать
local function CheckAllClothes(player, mult) --print('CheckAllClothes!!!',mult)
	local size = getSizeChr(player)
	local list = player:getWornItems()
	local items = {} --узкая
	local is_belt = false
	for i=0, list:size()-1 do
		local item = list:getItemByIndex(i);
		local loc = item:getBodyLocation()
		if loc == "Belt" then
			is_belt = true
		end
		local data = SLOTS[loc]
		if data then
			local sz = item:getModData().sz
			if not sz then --worn!
				sz = size
				item:getModData().sz = sz
			end
			while sz > 10 do sz = sz - 10 end
			if sz + (data.spacy and 1 or 0) < size then --tight
				table.insert(items, item)
			end
		end
	end
	mult = mult or 1
	while #items > 0 do
		local item = table.remove(items,ZombRand(#items)+1)
		local data = SLOTS[item:getBodyLocation()]
		local sz = item:getModData().sz
		while sz > 10 do sz = sz - 10 end
		local diff = size - (sz + (data.spacy and 1 or 0))
		local chance = diff == 1 and CHANCES.BREAK_TIGHT or CHANCES.BREAK_VERY_TIGHT
		chance = chance * mult
		if data.breakfast then
			chance = chance * CHANCES.BREAKFAST_MULT
		end
		--print(item:getType(),' RIP CHANCE ',tostring(chance)..'%')
		if ZombRand(10000) < chance * 100 then
			print('Rip Clothes! Chance was: ',tostring(chance)..'%')
			return RipClothes(item, player)
		end
	end
	if is_belt then
		return
	end
	local busy_hands = (player:getPrimaryHandItem() and 1 or 0) + (player:getSecondaryHandItem() and 1 or 0)
	if busy_hands < 2 then
		return
	end
	--Ремня точно нет. И руки заняты.
	items = {} --просторная
	for i=0, list:size()-1 do
		local item = list:getItemByIndex(i);
		local loc = item:getBodyLocation()
		local data = SLOTS[loc]
		if data and data.drop then
			local sz = item:getModData().sz
			while sz > 10 do sz = sz - 10 end
			if sz > size then --spacy
				table.insert(items, item)
			end
		end
	end	
	while #items > 0 do
		local item = table.remove(items,ZombRand(#items)+1)
		local data = SLOTS[item:getBodyLocation()]
		local sz = item:getModData().sz
		while sz > 10 do sz = sz - 10 end
		local diff = sz - size
		local chance = diff == 1 and CHANCES.DROP_SPACY or
			(diff == 2 and CHANCES.DROP_VERY_SPACY or CHANCES.DROP_VERYVERY_SPACY)
		chance = chance * mult
		--print(item:getType(),' DROP CHANCE ',tostring(chance)..'%')
		if ZombRand(10000) < chance * 100 then
			print('Drop Clothes! Chance was: ',tostring(chance)..'%')
			return DropItem(item, player)
		end
	end
end


local function setRightInsulation(item, diff)
	local ins = ScriptManager.instance:getItem(item:getFullType()):getInsulation()
	if not item:isEquipped() or diff == 0 then
		item:setInsulation(ins)
		return
	end
	if diff == 1 then
		ins = ins * 0.8
	elseif diff == 2 then
		ins = ins * 0.7
	elseif diff == 3 then
		ins = ins * 0.6
	else
		ins = ins * 0.5
	end
	item:setInsulation(ins) --until reload the game
end


local function CheckInsulation(player)
	local size = getSizeChr(player)
	local list = player:getWornItems()
	for i=0, list:size()-1 do
		local item = list:getItemByIndex(i);
		local data = SLOTS[item:getBodyLocation()]
		if data then
			local sz = item:getModData().sz
			if not sz then
				print("ERROR: no sz")
			else
				while sz > 10 do sz = sz - 10 end
				if sz >= size then --free space, lower insulation
					--print('free space',sz,size,item)
					local diff = sz - size
					setRightInsulation(item, diff)
				end
			end
		end
	end
end

--Player enters the world
Events.OnCreatePlayer.Add(function(id)
	local player = getSpecificPlayer(id)
	TIME_INST = GameTime:getInstance()
	lastRip = TIME_INST:getWorldAgeHours()
	CheckAllClothes(player)
	CheckInsulation(player)
end)


local STATES = {}
STATES[ClimbThroughWindowState.instance()] = true
STATES[ClimbOverFenceState.instance()] = true
STATES[ClimbOverWallState.instance()] = 1
STATES[ClimbSheetRopeState.instance()] = true
STATES[ClimbDownSheetRopeState.instance()] = true

local lastTick = 0
Events.EveryOneMinute.Add(function() --print('------- PER MINUTE ----')
	local tm = TIME_INST:getWorldAgeHours()
	local diff = tm - lastTick
	--print('diff',diff,tm,lastTick)
	if diff < 0.005 then --пол секунды
		return --print('OBLOM!')
	end
	lastTick = tm
	local player = getPlayer()
	if player:isAsleep() then
		return
	end
	if player:getVehicle() then
		return
	end
	local run,sprint = player:IsRunning(),player:isSprinting()
	local state = STATES[player:getCurrentState()]
	if run or sprint or state then
		local wall = state == 1
		local window = state and not wall
		local sneak = player:isSneaking()
		local mult = 1
			+ (run and 1 or 0) + (sneak and 2 or 0) + (sprint and 2.5 or 0)
			+ (window and 100 or 0) + (wall and 300 or 0)
		CheckAllClothes(player, mult)
	end
	CheckInsulation(player)
end)


--Момент надевания одежды.
do

	local old_wear_perform = ISWearClothing.perform
---@diagnostic disable-next-line: duplicate-set-field
	function ISWearClothing:perform()
		local data = SLOTS[self.item:getBodyLocation()]
		if not data then
			return old_wear_perform(self)
		end
		local mod_data = self.item:getModData()
		local sz = mod_data.sz
		while sz > 10 do sz = sz - 10 end
		local space = sz - getSizeChr(self.character)
		if space > -1 then
			return old_wear_perform(self)
		end
		if space < -2 + (data.nofit and 1 or 0) - (data.spacy and 1 or 0) then
			self.item:getContainer():setDrawDirty(true);
			self.item:setJobDelta(0.0);
			self.character:Say(getText("IGUI_SL_CantWear"))
			return --запрет одевания
		end
		local diff = -space - (data.spacy and 1 or 0)
		if diff > 0 then --1 or 2
			local chance = diff == 2 and CHANCES.ON_WEAR_VERY_TIGHT or CHANCES.ON_WEAR_TIGHT
			if data.breakfast then
				chance = chance * CHANCES.BREAKFAST_MULT
			end
			if ZombRand(100) < chance then
				RipClothes(self.item, self.character)
			end
			setRightInsulation(self.item, diff)
		end
		return old_wear_perform(self)
	end

	local old_wear_new = ISWearClothing.new
	function ISWearClothing:new(character, item, time, ...)
		local data = SLOTS[item:getBodyLocation()]
		if not data then
			return old_wear_new(self, character, item, time, ...)
		end
		local mod_data = item:getModData()
		local sz = mod_data.sz
		if not sz then --possible if spawned by admin
			sz = getRandomCSize()
			mod_data.sz = sz + 10
		end
		while sz > 10 do sz = sz - 10 end
		if not sz then
			sz = getRandomCSize()
			mod_data.sz = sz + 10
		end
		local space = sz - getSizeChr(character)
		if space > -1 then
			return old_wear_new(self, character, item, time, ...)
		end
		if space == -1 then
			time = time * 3
		elseif space == -2 then
			time = time * 4
		else
			time = time * 5
		end
		return old_wear_new(self, character, item, time, ...)
	end

end

--Момент снимания одежды (конец)
do
	local old_perform = ISUnequipAction.perform
---@diagnostic disable-next-line: duplicate-set-field
	function ISUnequipAction:perform()
		old_perform(self)
		if instanceof(self.item,"Clothing") and SLOTS[self.item:getBodyLocation()] then
			setRightInsulation(self.item, 0)
		end
	end
end


--Начало перетаскивания
do

	local old_start = ISInventoryTransferAction.start
---@diagnostic disable-next-line: duplicate-set-field
	function ISInventoryTransferAction:start()
		if self.srcContainer then
			local typ = self.srcContainer:getType()
			local item = self.item
			if self.srcContainer == self.character:getInventory() then
				if instanceof(item,"Clothing") and item:isEquipped() and SLOTS[item:getBodyLocation()] then
					setRightInsulation(item,0)
				end
			elseif typ == "inventorymale" or typ == "inventoryfemale" then
				if not instanceof(item,"Clothing") then
					return old_start(self) --Не шмотки игнорируем
				end
				local is_good = SLOTS[item:getBodyLocation()]
				if not is_good then
					return old_start(self)
				end
				local sz = item:getModData().sz
				if sz then
					return old_start(self) --Если уже есть размер, то нельзя его копировать
				end
				sz = getRandomCSize()
				local list = self.srcContainer:getItemsFromCategory("Clothing")
				for i=0,list:size()-1 do
					local item = list:get(i)
					local good = SLOTS[item:getBodyLocation()]
					if good then
						local data = item:getModData()
						if not data.sz then
							data.sz = sz + 10
						end
					end
				end				
			end
		end
		return old_start(self)
	end

end

--Fix extra option
do
	local old_createItem = ISClothingExtraAction.createItem
	function ISClothingExtraAction:createItem(item, itemType, ...)
		local result = old_createItem(self, item, itemType, ...)
		if instanceof(item, "Clothing") and instanceof(result, "Clothing") then
			local old_sz = item:getModData().sz --print('found sz')
			if not old_sz then
				old_sz = getRandomCSize()
			end
			result:getModData().sz = old_sz
		end
		return result
	end
end



