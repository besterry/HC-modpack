
require "TimedActions/ISBaseTimedAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
respawnCar_TimedAction = ISBaseTimedAction:derive("respawnCar_TimedAction")
----------------------------------------------------------------------------------------------------------------------------------------------------------
function respawnCar_TimedAction:isValid()
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
	
function respawnCar_TimedAction:update()
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
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	if self.ADDsound and self.ADDsound ~= 0 and not self.character:getEmitter():isPlaying(self.ADDsound) then self.ADDsound = self.character:playSound("RIC_expulsePlayer") end
	----------------------------------------------------------------------------------------------------------------------------------------------------------
end

function respawnCar_TimedAction:start()
	--------------------------------------------
	self.ADDsound = self.character:playSound("RIC_expulsePlayer")
	--------------------------------------------
	--self.action = LuaTimedActionNew.new(self, self.character);
	self:setActionAnim("DropWhileMoving") --Rake DropWhileMoving RemoveBush Forage Pour ChainsawCutTree PickLock BiteReactBehind_Chainsaw RemoveBarricade
	--self.action:setActionAnim(_action);
	--self.character:Say(getText("IGUI_WillTakeLockOnCarDoor"))
	--return self.character:shouldBeTurning()
end

function respawnCar_TimedAction:stop()
    -----------------------------------------------------------------------------------------------------
    if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    self.ADDsound = self.character:playSound("RIC_respawnGround")
    -----------------------------------------------------------------------------------------------------
	--self.character:Say(getText("IGUI_Merde"))

	ISBaseTimedAction.stop(self)
end

function respawnCar_TimedAction:perform()
	sendClientCommand("RespawnINcar_expulse_player","true",{self.vehicle:getId(),self.character:getOnlineID(),self.numSeat}) 
	-----------------------------------------------------------------------------------------------------
	if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    self.ADDsound = self.character:playSound("RIC_respawnGround")
    -----------------------------------------------------------------------------------------------------
	ISBaseTimedAction.perform(self)
end

function respawnCar_TimedAction:new(character,vehicle,numSeat)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = vehicle
	o.numSeat = numSeat
	o.maxTime = 500
	if o.character:isTimedActionInstant() then o.maxTime = 1 end
	if isAdmin() then o.maxTime = 30 end
	return o	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
