require "ISUI/ISToolTip"
require "TimedActions/ISBaseTimedAction"

local function newToolTip()
	local toolTip = ISToolTip:new();
	toolTip:initialise();
	toolTip:setVisible(false);
	return toolTip;
end

local function DisableOption(option, text)
	option.notAvailable = true
	local tooltip = newToolTip();
	tooltip.description = text;
	option.toolTip = tooltip;
end

local function isItemValid(player, item)
	return item:getContainer() == player:getInventory();
end

function TimedMovingCigaretessToPack(player, type_cigarettes, counter_cigarettes, item)
	local counter = counter_cigarettes * 30
	ISTimedActionQueue.add(TimedMovingCigaretess:new(player, type_cigarettes, item, counter))
end

TimedMovingCigaretess = ISBaseTimedAction:derive("TimedMovingCigaretess")

function TimedMovingCigaretess:isValid()
	-- Оставляем без изменений
	return true;
end

function TimedMovingCigaretess:start()
	-- Что происходит в начале действия (может быть пустым)
end

function TimedMovingCigaretess:stop()
	-- Что происходит, если действие было прервано
	ISBaseTimedAction.stop(self) -- строка обязательна
end

--- Переместить сигареты --- -- выполняется после задержки времени
function TimedMovingCigaretess:perform()
	local pack_cigarettes = self.item;
	local type_cigarettes = self.type_cigarettes;
	if pack_cigarettes == nil then
	return end
	local player = self.character;
	local cigarettess_count = player:getInventory():FindAll(type_cigarettes)
	if cigarettess_count:size() ~= 0 then
		for i = 0, cigarettess_count:size() - 1 do
			if pack_cigarettes:getUsedDelta() < 1 then
				player:getInventory():Remove(type_cigarettes);
				pack_cigarettes:setUsedDelta(pack_cigarettes:getUsedDelta()+0.05);
				if pack_cigarettes:getUsedDelta() > 0.98 then
					pack_cigarettes:setUsedDelta(1)
				end
			end
		end
	end
	ISBaseTimedAction.perform(self)
end

function TimedMovingCigaretess:new(player, type_cigarettes, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = player -- переменная обязательно должна называться character
	o.item = item
	o.type_cigarettes = type_cigarettes
	o.stopOnWalk = false -- прерывать при ходьбе
	o.stopOnRun = true -- прерывать при беге
	o.maxTime = time
	return o;
end

local function checkInvItemCigarettes(player, context, worldobjects, item)

	local player = getPlayer();
	local pack_cigarettes = item:getType();
	local check_pack_cigarettes;
	local item_cigaretess;
	local type_cigarettes;
	local check_item_cigaretess;
	local counter_cigarettes;

	if not pack_cigarettes then return 	end
	if not isItemValid(player, item) then
		return -- no dupe anymore
	end
	
	if tostring(pack_cigarettes) ~= "SMPack" and tostring(pack_cigarettes) ~= "SMPackLight" and tostring(pack_cigarettes) ~= "SMPackMenthol" and tostring(pack_cigarettes) ~= "SMPackGold" then return end

	if item:getUsedDelta() < 1 then
		check_pack_cigarettes = true;
	end
	
	if tostring(pack_cigarettes) == "SMPack" then type_cigarettes = "SMCigarette"
		elseif tostring(pack_cigarettes) == "SMPackLight" then type_cigarettes = "SMCigaretteLight"
		elseif tostring(pack_cigarettes) == "SMPackMenthol" then type_cigarettes = "SMPCigaretteMenthol"
		elseif tostring(pack_cigarettes) == "SMPackGold" then type_cigarettes = "SMPCigaretteGold"
	end
	
	counter_cigarettes = player:getInventory():FindAll(type_cigarettes);
	if counter_cigarettes:size() >= 2 then
		check_item_cigaretess = true
		counter_cigarettes = counter_cigarettes:size()
	end
	
	if check_pack_cigarettes ~= true then return end
	if check_item_cigaretess ~= true then return end
	
--- Показ контекстно меню на предмете...
	local option = context:addOption(getText("IGUI_MovingCigarettes"), player, TimedMovingCigaretessToPack, type_cigarettes, counter_cigarettes, item); --- надпись меню
	if not isItemValid(player, item) then
		DisableOption(option, getText("IGUI_ContextMenu_Cant_Action")) --- надпись о невозможности выполнить (не подходят условия)
	end
end


local invContextMenuMenuMovingCigarettes = function(_player, context, worldobjects, test)
	local playerObj = getSpecificPlayer(_player);

	for i,k in pairs(worldobjects) do
	-- inventory item list
		if instanceof(k, "InventoryItem") then
			checkInvItemCigarettes(playerObj, context, worldobjects, k);          
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
			checkInvItemCigarettes(playerObj, context, worldobjects, k.items[1]);
		end
	end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenuMenuMovingCigarettes);