--***********************************************************
--**                       BitBraven                       **
--***********************************************************

local headlight

local OnClientCommand = function(module, command, player, args)

	if not args then return end

	if module == "vehicle" then

		if not args["vehicle"] then return end

		local vehicle = getVehicleById(args["vehicle"])
		if not BravensBikeUtils.isBike(vehicle) then return end

		if command == "installPart" then

			local part = vehicle:getPartById(args["part"])

			if(args["part"] == "Headlight") then --Create custom headlight
				part:createSpotLight(0.7, 0.5, 0.5, 0.5, 0.5, 0.5)
			end
		end
	end
end

local OnEnterVehicle = function(playerObj)

	local vehicle = playerObj:getVehicle()
	if not vehicle then return end

	if BravensBikeUtils.isBike(vehicle) then

		--We keep track of the presence of a headlight at all times
		if (not headlight) then

			local headlightPart = vehicle:getPartById("Headlight")
			if not headlightPart:getInventoryItem() then return end
			headlight = headlightPart
		end
	end
end

local everyOneMinute = function()

	local playerObj = getPlayer(); if not playerObj then return end
	local vehicle = playerObj:getVehicle()

	if not vehicle then

		if headlight then

			vehicle = headlight:getVehicle()

			if vehicle then
				vehicle:setHeadlightsOn(false)
			end

			headlight = nil
		end

		return
	elseif BravensBikeUtils.isBike(vehicle) then
		
		if (vehicle:getCurrentSpeedKmHour() > 1 or vehicle:getCurrentSpeedKmHour() < -1) then

			-- Power the dynamo headlight
			if (headlight and vehicle:getHeadlightsOn()) == false then
				vehicle:setHeadlightsOn(true)
			end
		else
			--Turn off the dynamo headlight
			if vehicle:getHeadlightsOn() == true then
				vehicle:setHeadlightsOn(false)
			end
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
Events.OnEnterVehicle.Add(OnEnterVehicle)
Events.EveryOneMinute.Add(everyOneMinute)