-- c:\Users\FD\Zomboid\Workshop\HydroServer\Contents\mods\Shops\media\lua\client\TimedActions\ATMSellAction.lua
require "TimedActions/ISBaseTimedAction"
local Nfunction = require "Nfunction"

ATMSellAction = ISBaseTimedAction:derive("ATMSellAction")

function ATMSellAction:isValid()
	return true
end

function ATMSellAction:waitToStart()
	return self.character:shouldBeTurning()
end

function ATMSellAction:update()
	if not self.ui or not self.ui:getIsVisible() then 
		self:forceStop()
	end
end

function ATMSellAction:start()
end

function ATMSellAction:stop()
	ISBaseTimedAction.stop(self)
end

function ATMSellAction:perform()
	local playerInv = self.character:getInventory()
	local inventoryItems = {}
	local inventory = playerInv:getItems()
	for i = 0, inventory:size() - 1 do
		local item = inventory:get(i)
		if not (item:isEquipped() or item:isFavorite()) then
			inventoryItems[item:getID()] = item
		end
	end

	local total = 0
	local totalSpecial = 0

	for _, entry in ipairs(self.ui.itemsToSell) do
		local invItem = inventoryItems[entry.id]
		if invItem then
			local price = Nfunction.drainablePrice(invItem, entry.priceFull)
			if entry.specialCoin then
				totalSpecial = totalSpecial + price
			else
				total = total + price
			end
			if SandboxVars.Shops.SellLog then Nfunction.buildLogShop(invItem:getFullType()) end
			invItem:getContainer():Remove(invItem)
		end
	end

	if SandboxVars.Shops.SellLog then
		local sq = self.atm and self.atm:getSquare() or self.character:getSquare()
		local coords = { x = sq:getX(), y = sq:getY(), z = sq:getZ() }
		Nfunction.logShop(coords, "ATMSell")
	end

	if total > 0 or totalSpecial > 0 then
		sendClientCommand("BS", "Deposit", { total, totalSpecial })
	end
	if total > 0 or totalSpecial > 0 then self.character:playSound("CashRegister") end

	self.ui.itemsToSell = {}
	self.ui:close()
	ISBaseTimedAction.perform(self)
end

function ATMSellAction:new(character, ui, atmWo)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.ui = ui
	o.atm = atmWo
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = 100
	return o
end