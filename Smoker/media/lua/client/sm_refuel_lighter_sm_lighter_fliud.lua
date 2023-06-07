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

function TimedRefuelLighter_FromSMLighterFluid(player, item)
	ISTimedActionQueue.add(TimedRefuelLF4:new(player, item, 200))
end

TimedRefuelLF4 = ISBaseTimedAction:derive("TimedRefuelLF4")

function TimedRefuelLF4:isValid()
	-- Оставляем без изменений
	return true;
end

function TimedRefuelLF4:start()
	-- Что происходит в начале действия (может быть пустым)
end

function TimedRefuelLF4:stop()
	-- Что происходит, если действие было прервано
	ISBaseTimedAction.stop(self) -- строка обязательна
end

--- Заправить зажигалку контекстным меню ---
function TimedRefuelLF4:perform()
	-- выполняется после задержки
	local player = self.character;
	local lighter = self.item;
	local lighter_delta;
	if not player or lighter == nil then return end

		if lighter:getType() == "Lighter" then
			lighter_delta = lighter:getUsedDelta();
			for i = 0, player:getInventory():getItems():size() - 1 do
				local item = player:getInventory():getItems():get(i);
				if item:getType() == "SMLighterFluid" or item:getType() == "WaterBottlePetrol" then
					local fuelcanister = item;
					if fuelcanister:getUsedDelta() > 0 then
						local fuelcanister_delta = fuelcanister:getUsedDelta();
						local need_fuel_lighter = (1 - lighter_delta);

						if fuelcanister_delta >= need_fuel_lighter then
							fuelcanister:setUsedDelta(fuelcanister_delta - need_fuel_lighter/10);
							lighter:setUsedDelta(lighter:getUsedDelta() + need_fuel_lighter*2);
					
							elseif fuelcanister_delta < need_fuel_lighter then
							fuelcanister:setUsedDelta(fuelcanister_delta - need_fuel_lighter/10);
							lighter:setUsedDelta(lighter_delta + fuelcanister_delta*2);
						end
					end
					break
				end
			end
		end
		
		if lighter:getType() == "SMEmptyLighter" then
			local add_lighter = "Base.Lighter";
			player:getInventory():Remove(lighter);
			for i = 0, player:getInventory():getItems():size() - 1 do
				local item = player:getInventory():getItems():get(i);
				if item:getType() == "SMLighterFluid" or item:getType() == "WaterBottlePetrol" then
					local fuelcanister = item;
					if fuelcanister:getUsedDelta() > 0 then
						local fuelcanister_delta = fuelcanister:getUsedDelta();
						local refill_lighter = player:getInventory():AddItem(add_lighter);
						refill_lighter:setUsedDelta(0);

						if fuelcanister_delta > 0 then
							fuelcanister:setUsedDelta(fuelcanister_delta - 1/10);
							refill_lighter:setUsedDelta(1);
							elseif fuelcanister_delta < 0.1  then
							fuelcanister:setUsedDelta(fuelcanister_delta - 1/10);
							refill_lighter:setUsedDelta(refill_lighter + fuelcanister_delta*2);
						end
					end
					break
				end
			end
		end
		
		ISBaseTimedAction.perform(self)
end

function TimedRefuelLF4:new(player, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = player -- переменная обязательно должна называться character
	o.item = item
	o.stopOnWalk = false -- прерывать при ходьбе
	o.stopOnRun = true -- прерывать при беге
	o.maxTime = time
	return o;
end

--Проверяет предмет, по которому кликнули пустая-ли это зажигалка
local function checkInvItemLighter_FromSMLighterFluid(player, context, worldobjects, item)
	local lighter = item:getType();
	local check_PetrolCan;

	if not lighter then
	return end
	
	if not isItemValid(player, item) then return -- no dupe anymore
	end
	
	if lighter ~= "Lighter" and lighter ~= "SMEmptyLighter" then
	return end
	
	if (lighter == "Lighter" and item:getUsedDelta() < 0.98) or (lighter == "SMEmptyLighter") then -- находим пустую зажигалку в инвентаре с дельтой меньше единицы
		check_lighter = true
	end
	
	if check_lighter ~= true then
	return end -- если нет подходящей зажигалки,  то не показывать меню

	for i = 0, player:getInventory():getItems():size() - 1 do 
		local PetrolCan = player:getInventory():getItems():get(i);
		if PetrolCan:getType() == "SMLighterFluid" or PetrolCan:getType() == "WaterBottlePetrol" then
			if PetrolCan:getUsedDelta() > 0 then
				check_PetrolCan = true
				break
			end
		end
	end

	if check_PetrolCan ~= true then
	return end

	if check_lighter == true and check_PetrolCan == true then
		local option = context:addOption(getText("IGUI_Refuel_Lighter"), player, TimedRefuelLighter_FromSMLighterFluid, item); --- надпись меню
		if not isItemValid(player, item) then
			DisableOption(option, getText("IGUI_ContextMenu_Cant_Action")) --- надпись о невозможности выполнить (не подходят условия)
		end
	end	
end

local invContextMenuMenuRefuelLighter_FromSMLighterFluid = function(_player, context, worldobjects, test)
	local playerObj = getSpecificPlayer(_player);
	for i,k in pairs(worldobjects) do
	-- inventory item list
		if instanceof(k, "InventoryItem") then
			checkInvItemLighter_FromSMLighterFluid(playerObj, context, worldobjects, k);          
			elseif not instanceof(k, "InventoryItem") and k.items and #k.items > 1 then
			checkInvItemLighter_FromSMLighterFluid(playerObj, context, worldobjects, k.items[1]);
		end
	end
end

Events.OnFillInventoryObjectContextMenu.Add(invContextMenuMenuRefuelLighter_FromSMLighterFluid); -- контекстное меню для заправки зажигалки