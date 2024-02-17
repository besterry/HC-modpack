require "TimedActions/ISBaseTimedAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
local RICaction = ISBaseTimedAction:derive("RICaction")
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
----------------------------------------------------------------------------------------------------------------------------------------------------------
function RICaction:isValid()
	local vehicleTest 	= self.character:getUseableVehicle()
	local vehicleTestBoat = self.character:getVehicle()
	if  vehicleTestBoat                                                     		and
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatSailingYacht"        and 
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatSailingYacht_Ground" and  
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatMotor"               and 
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatMotor_Ground"        then 

    	return false
	end
	if (not vehicleTest and not vehicleTestBoat) or (vehicleTestBoat ~= self.vehicle and vehicleTest ~= self.vehicle) then return false end
	return true
end
-----------------------------------------------------------------------------------------------------	
function RICaction:update()
	local vehicleTest 	= self.character:getUseableVehicle()
	local vehicleTestBoat = self.character:getVehicle()
	if vehicleTestBoat and 
		vehicleTestBoat:getScript():getFullName() ~= "Base.BoatSailingYacht"        and 
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatSailingYacht_Ground" and  
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatMotor"               and 
    	vehicleTestBoat:getScript():getFullName() ~= "Base.BoatMotor_Ground"        then 
    	self:forceStop() 
    	return 
    end
	if not vehicleTest and not vehicleTestBoat then self:forceStop() return end
	if self.ADDsound and self.ADDsound ~= 0 and not self.character:getEmitter():isPlaying(self.ADDsound) then self.ADDsound = self.character:playSound("RIC_expulsePlayer") end
end
-----------------------------------------------------------------------------------------------------
function RICaction:start()
	self.ADDsound = self.character:playSound("RIC_expulsePlayer")
	--self.action = LuaTimedActionNew.new(self, self.character);
	self:setActionAnim("DropWhileMoving") --Rake DropWhileMoving RemoveBush Forage Pour ChainsawCutTree PickLock BiteReactBehind_Chainsaw RemoveBarricade
	--self.action:setActionAnim(_action);
	--self.character:Say(getText("IGUI_WillTakeLockOnCarDoor"))
	--return self.character:shouldBeTurning()
end
-----------------------------------------------------------------------------------------------------
function RICaction:stop()
    if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    self.ADDsound = self.character:playSound("RIC_respawnGround")
	ISBaseTimedAction.stop(self)
end
-----------------------------------------------------------------------------------------------------
function RICaction:perform()
	if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    self.ADDsound = self.character:playSound("RIC_respawnGround")
	local args = {self.vehicle:getId(),self.numSeat}
	RIC.SendClientCommand(self.character,self.command,args)
	ISBaseTimedAction.perform(self)
end
-----------------------------------------------------------------------------------------------------
function RICaction:new(character,vehicle,numSeat,command)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.numSeat = numSeat
	o.command = command
	o.maxTime = 500
	if o.character:isTimedActionInstant() then o.maxTime = 1 end
	if isAdmin() then o.maxTime = 30 end
	return o	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
return RICaction