-- \Shops\media\lua\client\TimedActions\ATMSellAction.lua
require "TimedActions/ISBaseTimedAction"
local Nfunction = require "Nfunction"
require "ShopSellInventory"

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
	local inventoryItems = ShopSellInventory.buildItemMap(self.character)

	local total = 0
	local totalSpecial = 0

	local cartItems = self.ui.cartItems and self.ui.cartItems.items or {}
	for i = 1, #cartItems do
		local entry = cartItems[i].item
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
		Nfunction.logShop(coords, "ATMSell [price: " .. total .. "c/" .. totalSpecial .. "s]")
	end

	if total > 0 or totalSpecial > 0 then
		sendClientCommand("BS", "Deposit", { total, totalSpecial })
	end
	if total > 0 or totalSpecial > 0 then self.character:playSound("CashRegister") end

	self.ui.cartItems:clear()
	self.ui.actionInProgress = false
	self.ui:refreshItems()
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