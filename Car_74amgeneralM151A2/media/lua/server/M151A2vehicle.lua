--***********************************************************
--**                   KI5 / bikinihorst                   **
--***********************************************************

M151A2 = {
	parts = {
		Bumper = {
			M151A2Bumper = {
				Bumper1 = "M151A2Bumper1_Item",
				Bumper2 = "M998Bullbar1_Item",
			},
			default = "first",
		},
		Tarp = {
			M151A2Tarp = {
				Tarp1 = "M151A2Tarp1_Item",
			},
			default = "trve_random",
			noPartChance = 50,
		},
		CabArmor = {
			M151A2CabArmor = {
				CabArmor1 = "M151A2CabArmor1_Item",
			},
			default = "trve_random",
			noPartChance = 95,
		},
		WindshieldArmor = {
			M151A2WindshieldArmor = {
				WindshieldArmor1 = "M151A2WindshieldArmor1_Item",
			},
			default = "trve_random",
			noPartChance = 95,
		},
		BarrierLeft = {
			M151A2BarrierLeft = {
				BarrierLeft1 = "M151A2BarrierLeft1_Item",
			},
		},
		BarrierRight = {
			M151A2BarrierRight = {
				BarrierRight1 = "M151A2BarrierRight1_Item",
			},
		},
		SpareTire = {
			M151A2SpareTire = {
				SpareTire1 = "V102Tire2",
			},
			default = "trve_random",
			noPartChance = 50,
		},
	},
};

KI5:createVehicleConfig(M151A2);

function M151A2.ContainerAccess.Trunk(vehicle, part, chr)
	if chr:getVehicle() == vehicle then
		local seat = vehicle:getSeat(chr)
		return seat == 3 or seat == 2 or seat == 1 or seat == 0;
	elseif chr:getVehicle() then
		return false
	else
		if not vehicle:isInArea(part:getArea(), chr) then return false end
		local doorPart = vehicle:getPartById("TrunkDoor")
		if doorPart and doorPart:getDoor() and not doorPart:getDoor():isOpen() then
			return false
		end
		return true
	end
end