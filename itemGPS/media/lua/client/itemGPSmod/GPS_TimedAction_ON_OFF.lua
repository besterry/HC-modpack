
require "TimedActions/ISBaseTimedAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
GPS_TimedAction_ON_OFF = ISBaseTimedAction:derive("GPS_TimedAction_ON_OFF")
----------------------------------------------------------------------------------------------------------------------------------------------------------
function GPS_TimedAction_ON_OFF:isValid()
	if self.setOn == true and self.item:hasTag("GPSmodCar") then
		if self.vehicleInside and self.vehicleInside:getBatteryCharge() > 0 and (self.vehicleInside:isKeysInIgnition() or self.vehicleInside:isHotwired()) then
			local testPart = self.vehicleInside:getPartById("GloveBox");
		
			if testPart and testPart:getItemContainer():contains(self.item) and testPart:getItemContainer():containsType("GPScable") then
				return true
			end
		end
		return false
	end
	return true
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
function GPS_TimedAction_ON_OFF:perform()
	if not self.item then return end
	if self.setOn == false then 
		itemGPSmod.playSoundGPS(self.character, self.item:getType().."_Beep_OFF")
	elseif (self.item:hasTag("GPSmod") and self.item:getUsedDelta() and self.item:getUsedDelta() > 0.005) or self.item:hasTag("GPSmodCar") then
		itemGPSmod.playSoundGPS(self.character, self.item:getType().."_Beep_ON")
	else  
		self.setOn = false
		if (self.item:getUsedDelta() and self.item:getUsedDelta() > 0) then 
			itemGPSmod.playSoundGPS(self.character, self.item:getType().."_Beep_chargeLOW") 
		else 
			getSoundManager():PlayWorldSound("GPS_Key_1", self.character:getSquare(), 1, 20, 2, true) 
		end 
	end
	itemGPSmod.ToggleMiniMap(self.character, self.setOn, self.item)
	ISBaseTimedAction.perform(self)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
function GPS_TimedAction_ON_OFF:new(character,item,setOn)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.stopOnWalk = false
	o.stopOnRun = false
	o.character = character
	o.item = item
	o.setOn = setOn
	o.maxTime = 0
	o.vehicleInside = character:getVehicle()
	return o	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
