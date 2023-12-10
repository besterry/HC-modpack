
----------------------------------------
----------- I hate coding... -----------
----------------------------------------

NickNoobsVehicle = NickNoobsVehicle or {};

function NickNoobsVehicle.Check()
	
	local player = getPlayer()
	local isInVehicle = player:isSeatedInVehicle()
	
	if isInVehicle == true then
	
		local vehicle = player:getVehicle()
		
		if vehicle and 
			(string.find(vehicle:getScriptName(), "toyotahilux89singlecab") or 
			string.find(vehicle:getScriptName(), "toyotahilux89extracab") or 
			string.find(vehicle:getScriptName(), "toyotahilux89dualcab")) then
	
			player:SetVariable("NickNoobsVehicle", "true")
			
			local seat = vehicle:getSeat(player)
			if seat then
				if seat == 0 then
					player:SetVariable("NickNoobsVehicle_Driver", "true")
				else 
					player:SetVariable("NickNoobsVehicle_Driver", "false")
				end	
			else return end
			
		else return end	
	else return end
end

local originalEnterVehicle = ISEnterVehicle["start"]

function ISEnterVehicle:start()
	
	local vehicle = self.vehicle
	
	if not vehicle and 
		(string.find(vehicle:getScriptName(), "toyotahilux89singlecab") or	
		string.find(vehicle:getScriptName(), "toyotahilux89extracab") or 
		string.find(vehicle:getScriptName(), "toyotahilux89dualcab")) then
		
		originalEnterVehicle(self)

	else 
	
		self.character:SetVariable("NickNoobsVehicle", "true")
		
		local seat = self.seat
		if seat then
		
			if seat == 0 then
			
				self.character:SetVariable("NickNoobsVehicle_Driver", "true")
				
			else 
			
				self.character:SetVariable("NickNoobsVehicle_Driver", "false")
		
			end
			
		else return end
		
		originalEnterVehicle(self)
	
	end
end

function NickNoobsVehicle.SwitchSeat(self)

	local vehicle = self:getVehicle()
	
	if vehicle and 
		(string.find(vehicle:getScriptName(), "toyotahilux89singlecab") or
		string.find(vehicle:getScriptName(), "toyotahilux89extracab") or 
		string.find(vehicle:getScriptName(), "toyotahilux89dualcab")) then
	
		self:SetVariable("NickNoobsVehicle", "true")
		
		local seat = vehicle:getSeat(self)
		if seat then
		
			if seat == 0 then
			
				self:SetVariable("NickNoobsVehicle_Driver", "true")
				
			else 
			
				self:SetVariable("NickNoobsVehicle_Driver", "false")
		
			end	
		else return end
	else return end
end

function NickNoobsVehicle.Clear(self)
    self:SetVariable("NickNoobsVehicle", "false")
	self:SetVariable("NickNoobsVehicle_Driver", "false")
end

Events.OnLoad.Add(NickNoobsVehicle.Check)
Events.OnExitVehicle.Add(NickNoobsVehicle.Clear)
Events.OnSwitchVehicleSeat.Add(NickNoobsVehicle.SwitchSeat)