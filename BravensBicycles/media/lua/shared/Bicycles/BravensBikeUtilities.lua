--***********************************************************
--**                       BitBraven                       **
--***********************************************************

BravensBikeUtils = {}

-- Give the player all the parts the bicycle has installed on it.
BravensBikeUtils.addPartsWithCondition = function(vehicle, inventory, character)

	for i=0, vehicle:getPartCount() - 1 do

		local part = vehicle:getPartByIndex(i)

		if part:getCategory() ~= "nodisplay" then
			
			local partItem = part:getInventoryItem()
		
			if partItem then
				inventory:AddItem(partItem)
			end
		end
	end
end

-- Install all of the parts in the player's inventory on the bicycle. Else, delete them from the bicycle.
BravensBikeUtils.setPartsToCondition = function(vehicle, inventory, character)

	if not BravensBikeUtils.isBike(vehicle) then return end

	for i=0, vehicle:getPartCount() - 1 do

		local part = vehicle:getPartByIndex(i)

		if part:getCategory() ~= "nodisplay" then

			local partItem = part:getInventoryItem()

			if(partItem) then
	
				local invPartItem = inventory:getItemFromType(partItem:getFullType())
	
				if(invPartItem) then
	
					if isClient() then
						sendClientCommand(character, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = invPartItem:getCondition() })
					else
						part:setCondition(invPartItem:getCondition())						
					end
	
					inventory:Remove(invPartItem)
				else
					BikeServer.RemoveBikePart(part, vehicle)
				end
			end
		end
	end
end

BravensBikeUtils.isFrame = function(item)

	local itemIsFrame = false
	local itemFullType = item:getFullType()

	if (itemFullType == "Base.BicycleFrameRegular" or itemFullType == "Base.BicycleFrameRegularScrap" or itemFullType == "Base.BicycleFrameMTB" or itemFullType == "Base.BicycleFrameMTBScrap") then
		itemIsFrame = true 
	end

	return itemIsFrame
end

BravensBikeUtils.isBike = function(vehicle)

	local vehicleIsBicycle = false
	local vehicleName

	if not BravensUtils.isNumber(vehicle) then
		vehicleName = vehicle:getScriptName()
	else
		vehicleName = getVehicleById(vehicle):getScriptName()
	end

	if not vehicleName then return vehicleIsBicycle end
	if (vehicleName == "Base.BicycleRegular" or vehicleName == "Base.BicycleRegularScrap" or vehicleName == "Base.BicycleMTB" or vehicleName == "Base.BicycleMTBScrap") then
		vehicleIsBicycle = true 
	end

	return vehicleIsBicycle
end

BravensBikeUtils.GetBike = function(vehicle)

	local vehicleName = nil

	if not BravensUtils.isNumber(vehicle) then
		vehicleName = vehicle:getScriptName()
	else
		vehicleName = getVehicleById(vehicle):getScriptName()
	end

	return vehicleName
end