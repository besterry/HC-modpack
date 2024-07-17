local nepengine_dashboardPrerender = ISVehicleDashboard.prerender
-- C:\Games\Steam\steamapps\common\ProjectZomboid\media\lua\client\Vehicles\ISUI\ISVehicleDashboard.lua


function ISVehicleDashboard:prerender()
	nepengine_dashboardPrerender(self)

	if not self.vehicle or not ISUIHandler.allUIVisible then return end -- don't run if not in a vehicle or UI is off... otherwise throws an error when getting out of a vehicle when it excutes one final time.
	local alpha = self:getAlphaFlick(0.65);                          -- flickering from crashes etc

	local part = self.vehicle:getPartById("Engine")
	local engineCondition = -1
	if part then
		engineCondition = part:getCondition()
	else
		return --is it possible to have a vehicle with no Engine?  No idea, but if it happens this mod is pointless.
	end
	--print ("#### in modded ISVehicleDashboard:prerender, engine condition is " .. engineCondition)
	if not self:checkEngineFull() and self.vehicle:isKeysInIgnition() and (not self.vehicle:isEngineRunning() and not self.vehicle:isEngineStarted()) then
		self.engineTex.backgroundColor = { r = 0.25, g = 0, b = 0, a = alpha }; --engine is at 0%
	else
		--print ("#### in modded ISVehicleDashboard:prerender section 2")
		if self.vehicle:isEngineRunning() then                     --running normally
			if engineCondition > 75 then
				self.engineTex.backgroundColor = { r = 0, g = 1, b = 0, a = alpha }; --green
			elseif engineCondition > 50 then
				self.engineTex.backgroundColor = { r = 1, g = 1, b = 0, a = alpha }; --yellow
			elseif engineCondition > 25 then
				self.engineTex.backgroundColor = { r = 1, g = 0.5, b = 0.1, a = alpha }; --orange
			else
				self.engineTex.backgroundColor = { r = 1, g = 0, b = 0, a = alpha }; --red
			end
		elseif self.vehicle:isEngineStarted() then                 --starting
			if engineCondition > 75 then
				self.engineTex.backgroundColor = { r = 0, g = 0.7, b = 0, a = alpha }; --green (70%)
			elseif engineCondition > 50 then
				self.engineTex.backgroundColor = { r = 0.7, g = 0.7, b = 0, a = alpha }; --yellow (70%)
			elseif engineCondition > 25 then
				self.engineTex.backgroundColor = { r = 0.7, g = 0.35, b = 0.07, a = alpha }; --orange (70%)
			else
				self.engineTex.backgroundColor = { r = 0.7, g = 0, b = 0, a = alpha }; --red (70%)
			end
		else                                                        -- engine is off
			self.engineTex.backgroundColor = { r = 0.5, g = 0.5, b = 0.5, a = alpha }; --grey
		end
	end
end
