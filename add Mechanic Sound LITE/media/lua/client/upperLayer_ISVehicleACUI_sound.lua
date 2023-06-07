--
-- Created by IntelliJ IDEA.
-- User: RJ
-- Date: 04/12/2017
-- Time: 10:19
-- To change this template use File | Settings | File Templates.
--

--require "ISUI/ISPanelJoypad"
require "Vehicles/ISUI/ISVehicleACUI"
----------------------------------------------------------------------------------------------------------------------------------------------
local upperLayer = {}
upperLayer.ISVehicleACUI = {}
-----------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISVehicleACUI.changeKnob = ISVehicleACUI.changeKnob
function ISVehicleACUI:changeKnob()
   	upperLayer.ISVehicleACUI.changeKnob(self)
   	self.ADDsound = self.vehicle:playSound("HeatSelect" .. (ZombRand(4)+1))
   		
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
upperLayer.ISVehicleACUI.onClick = ISVehicleACUI.onClick
function ISVehicleACUI:onClick(button)
    upperLayer.ISVehicleACUI.onClick(self, button)

    if button.internal == "OK" then	

		local vehicle = self.character:getVehicle()
		
		if not self.heater:getModData().active then	

			--self.ADDsound = self.character:playSound("HeaterOnOff" .. (ZombRand(4)+1)
				
			ADDsoundMecanic_Heater = vehicle:getEmitter():playSound("HeaterVentil")
		else
			if ADDsoundMecanic_Heater and ADDsoundMecanic_Heater ~= 0 then vehicle:getEmitter():stopSound(ADDsoundMecanic_Heater) end								
			ADDsoundMecanic_Heater = vehicle:getEmitter():playSound("HeaterVentilStop")
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------


--local rand = ZombRand(4)
--if rand == 1 then self.character:playSound("HeatSelect1") end
--if rand == 2 then self.character:playSound("HeatSelect2") end
--if rand == 3 then self.character:playSound("HeatSelect3") end
--if rand == 0 then self.character:playSound("HeatSelect4") end

--local rand = ZombRand(4)

--if rand == 1 then self.character:playSound("HeaterOnOff1") end
--if rand == 2 then self.character:playSound("HeaterOnOff2") end
--if rand == 3 then self.character:playSound("HeaterOnOff3") end
--if rand == 0 then self.character:playSound("HeaterOnOff4") end

--if rand == 1 then self.character:playSound("HeaterOnOff1") end
--if rand == 2 then self.character:playSound("HeaterOnOff2") end
--if rand == 3 then self.character:playSound("HeaterOnOff3") end
--if rand == 0 then self.character:playSound("HeaterOnOff4") end