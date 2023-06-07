
require "TimedActions/ISBaseTimedAction"
-----------------------------------------------------------------------------------------------------------------------------------------------------------
CanRepairDoorsAction = ISBaseTimedAction:derive("CanRepairDoorsAction")
----------------------------------------------------------------------------------------------------------------------------------------------------------
function CanRepairDoorsAction:isValid()
	return true
end
	
function CanRepairDoorsAction:update()
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	if self.ADDsound and self.ADDsound ~= 0 and not self.character:getEmitter():isPlaying(self.ADDsound) then self.ADDsound = self.character:playSound(self.Sound) end
	----------------------------------------------------------------------------------------------------------------------------------------------------------end
	if not isClient() then 
		local healthDoorTEST = self.door:getHealth()
		if self.healthDoor < healthDoorTEST then self:forceStop() end
	end
end

function CanRepairDoorsAction:start()	
	self.character:faceThisObjectAlt(self.door)
	if self.system == "epoxy" then self:setActionAnim("Picklock") else self:setActionAnim("Build") end 
	--------------------------------------------
	self.ADDsound = self.character:playSound(self.Sound)
	--------------------------------------------
	return self.character:shouldBeTurning()
end

function CanRepairDoorsAction:stop()
    -----------------------------------------------------------------------------------------------------
    if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    -----------------------------------------------------------------------------------------------------
	ISBaseTimedAction.stop(self)
end

function CanRepairDoorsAction:perform()
	-----------------------------------------------------------------------------------------------------
	if self.ADDsound and self.ADDsound ~= 0 then self.character:getEmitter():stopSound(self.ADDsound) end
    -----------------------------------------------------------------------------------------------------
	local inventory = self.character:getInventory()	
	local pdata = getPlayerData(self.character:getPlayerNum())
	if pdata ~= nil then
		pdata.playerInventory:refreshBackpacks()
		pdata.lootInventory:refreshBackpacks()
	end		

	local healthDoor = self.healthDoor
    local maxHealth = self.door:getMaxHealth() 
    local carpSkill = self.character:getPerkLevel(Perks.Woodwork)

	if self.system == "wood" then
		local woodAdd = ((maxHealth/17)*carpSkill)+(healthDoor/5)+(ZombRand(25)*carpSkill)
		self.objet = inventory:getItemFromType("DoorsRepairKitWood")
		self.healthAdd = woodAdd
		self.ADDsound = self.character:playSound("CanRepairDoors_wood")
		if not isClient() then
			self.door:setHealth(healthDoor+woodAdd)
			if self.door:getHealth() > maxHealth then self.door:setHealth(maxHealth) end
		end
	elseif self.system == "metal" then
    	local metalAdd = ((maxHealth/20)*carpSkill)+(healthDoor/3)+(ZombRand(20)*carpSkill)
    	self.objet = inventory:getItemFromType("DoorsRepairKitMetal")
		self.healthAdd = metalAdd
		self.ADDsound = self.character:playSound("CanRepairDoors_metal")
		if not isClient() then
			self.door:setHealth(healthDoor+metalAdd)
			if self.door:getHealth() > (maxHealth*2) then self.door:setHealth(maxHealth*2) end
		end
	elseif self.system == "epoxy" then
    	local epoxyAdd = (maxHealth/6)+(healthDoor/6)+ZombRand(80)
    	self.objet = inventory:getItemFromType("DoorsRepairKitEpoxy")
		self.healthAdd = epoxyAdd
		if not isClient() then
			self.door:setHealth(healthDoor+epoxyAdd)
			if self.door:getHealth() > maxHealth then self.door:setHealth(maxHealth) end
		end
	end
	self.character:removeFromHands(self.objet)
	self.character:getInventory():DoRemoveItem(self.objet) 

	if isClient() then
		local x = self.door:getX()
	    local y = self.door:getY()
	    local z = self.door:getZ()
		sendClientCommand("CRD_apply_repairDoor_client","true",{x,y,z,self.system,healthDoor,self.healthAdd})
	end
	ISBaseTimedAction.perform(self)
end

function CanRepairDoorsAction:new(character, door, system, healthDoor, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.door = door
	o.system = system
	o.healthDoor = healthDoor
	if system == "epoxy" then o.Sound = "CanRepairDoors_epoxy" else o.Sound = "Hammering" end
	o.maxTime = time
	if o.character:isTimedActionInstant() or isAdmin() then o.maxTime = 10 end
	return o	
end
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
