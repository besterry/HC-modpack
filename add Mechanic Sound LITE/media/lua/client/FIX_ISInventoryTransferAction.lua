require "TimedActions/ISInventoryTransferAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
local upperLayer = {}
upperLayer.ISInventoryTransferAction = {}
ISInventoryTransferAction_soundADD = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISInventoryTransferAction.update = ISInventoryTransferAction.update
function ISInventoryTransferAction:update()
	upperLayer.ISInventoryTransferAction.update(self)
	local insideVehicle = self.character:getVehicle()

	if ISInventoryTransferAction.putSound ~= 0 and ISInventoryTransferAction.putSound and self.character:getEmitter():isPlaying(ISInventoryTransferAction.putSound) then
		self.character:getEmitter():stopSound(ISInventoryTransferAction.putSound)
	end
	----------------------------------------------------------------------------------------------------------------------------------
	if ISInventoryTransferAction_soundADD == nil and not insideVehicle then 
		ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("Transfer_item_snd")
	elseif ISInventoryTransferAction_soundADD == nil and insideVehicle then
		ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("inside_Transfer_item_snd")
	end

	if ISInventoryTransferAction_soundADD and  not self.character:getEmitter():isPlaying(ISInventoryTransferAction_soundADD) and not insideVehicle then
		ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("Transfer_item_snd")
	elseif ISInventoryTransferAction_soundADD and  not self.character:getEmitter():isPlaying(ISInventoryTransferAction_soundADD) and insideVehicle then
		ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("inside_Transfer_item_snd")
	end
	----------------------------------------------------------------------------------------------------------------------------------
	if ISInventoryTransferAction_counter == nil then ISInventoryTransferAction_counter = 35 end
	ISInventoryTransferAction_counter = ISInventoryTransferAction_counter +1
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISInventoryTransferAction.start = ISInventoryTransferAction.start
function ISInventoryTransferAction:start()
	upperLayer.ISInventoryTransferAction.start(self)
	local insideVehicle = self.character:getVehicle()
	--------------------------------------------------------------------------
	--Events.OnPlayerUpdate.Remove(ISInventoryTransferAction_delay_stop_sound)
	--------------------------------------------------------------------------
	--ISInventoryTransferAction_counter = nil 
	--if ISInventoryTransferAction_counter == nil then ISInventoryTransferAction_counter = 35 end
	if ISInventoryTransferAction.putSound ~= 0 and ISInventoryTransferAction.putSound and self.character:getEmitter():isPlaying(ISInventoryTransferAction.putSound) then
		self.character:getEmitter():stopSound(ISInventoryTransferAction.putSound)
	end
	----------------------------------------------------------------------------------------------------------------
	if not insideVehicle then ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("Transfer_item_snd")
	elseif insideVehicle then ISInventoryTransferAction_soundADD = self.character:getEmitter():playSound("inside_Transfer_item_snd")
	end
	---------------------------------------------------------------------
	if ISInventoryTransferAction_counter == nil or ISInventoryTransferAction_counter == 0 then Events.OnPlayerUpdate.Add(ISInventoryTransferAction_delay_stop_sound) end
	---------------------------------------------------------------------
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISInventoryTransferAction.stop = ISInventoryTransferAction.stop
function ISInventoryTransferAction:stop()
	upperLayer.ISInventoryTransferAction.stop(self)
	local insideVehicle = self.character:getVehicle()
	--------------------------------------------------------------------------------------
	if ISInventoryTransferAction_soundADD ~= 0 and ISInventoryTransferAction_soundADD and self.character:getEmitter():isPlaying(ISInventoryTransferAction_soundADD) then
		self.character:getEmitter():stopSound(ISInventoryTransferAction_soundADD)
	end
	if not insideVehicle then self.character:getEmitter():playSound("Transfer_item_STOP" .. (ZombRand(4)+1))
	elseif insideVehicle then self.character:getEmitter():playSound("inside_Transfer_item_STOP" .. (ZombRand(4)+1))
	end
	ISInventoryTransferAction_soundADD = nil
	ISInventoryTransferAction_counter = nil 
	------------------------------------------------------------------------
	Events.OnPlayerUpdate.Remove(ISInventoryTransferAction_delay_stop_sound)
	------------------------------------------------------------------------
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ISInventoryTransferAction_delay_stop_sound()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local player = getSpecificPlayer(0)
	if ISInventoryTransferAction_counter == nil then ISInventoryTransferAction_counter = 35 end
	if ISInventoryTransferAction_counter <= 0 then --(ISInventoryTransferAction_soundADD ~= 0 and ISInventoryTransferAction_soundADD) and 
		if ISInventoryTransferAction_soundADD ~= 0 and ISInventoryTransferAction_soundADD and player:getEmitter():isPlaying(ISInventoryTransferAction_soundADD) then
			player:getEmitter():stopSound(ISInventoryTransferAction_soundADD)
		end
		ISInventoryTransferAction_counter = nil 
		ISInventoryTransferAction_soundADD = nil
		------------------------------------------------------------------------
		Events.OnPlayerUpdate.Remove(ISInventoryTransferAction_delay_stop_sound)
		------------------------------------------------------------------------
		return
	end
	--player:Say('update')
	ISInventoryTransferAction_counter = ISInventoryTransferAction_counter -1
end