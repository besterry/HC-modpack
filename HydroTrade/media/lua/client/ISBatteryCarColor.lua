
local original_dahboardPrerender = ISVehicleDashboard.prerender
-- C:\Games\Steam\steamapps\common\ProjectZomboid\media\lua\client\Vehicles\ISUI\ISVehicleDashboard.lua


function ISVehicleDashboard:prerender()
	
	original_dahboardPrerender(self)

	if not self.vehicle or not ISUIHandler.allUIVisible then return end  -- don't run if not in a vehicle or UI is off... otherwise throws an error when getting out of a vehicle when it excutes one final time.
	local alpha = self:getAlphaFlick(0.65); -- flickering from crashes etc
	local chargelevel = self.vehicle:getBatteryCharge()
	
	if self.vehicle:isEngineRunning() or self.vehicle:isKeysInIgnition() then
		
		--print ("#### Battery Charge is " .. chargelevel)
		
		if chargelevel > 0.75 then
			self.batteryTex.backgroundColor = {r=0, g=1, b=0, a=alpha};
		elseif chargelevel > 0.50 then
			self.batteryTex.backgroundColor = {r=1, g=1, b=0, a=alpha};
		elseif chargelevel > 0.25 then
			self.batteryTex.backgroundColor = {r=1, g=0.5, b=0.1, a=alpha};
		elseif chargelevel > 0.01 then
			self.batteryTex.backgroundColor = {r=1, g=0, b=0, a=alpha};
		else
			self.batteryTex.backgroundColor = {r=0.5, g=0, b=0, a=alpha};
		end
	end	
end