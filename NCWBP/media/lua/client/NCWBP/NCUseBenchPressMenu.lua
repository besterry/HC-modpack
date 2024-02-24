--[[
		Developed by Nichals
		Working Bench press 41.65+
]]

NCUseBenchPressMenu = {};
NCUseBenchPressMenu.doBuildMenu = function(player, context, worldobjects)

	local benchObject = nil
	local benchGroupName = nil

	for _,object in ipairs(worldobjects) do
		local square = object:getSquare()
		if not square then
			return
		end
		
		for i=1,square:getObjects():size() do
			local thisObject = square:getObjects():get(i-1)
			
			if thisObject:getSprite() then
				local properties = thisObject:getSprite():getProperties()
				if properties == nil then
					return
				end
				
				local groupName = nil
				local customName = nil
				local gridPos = nil

				if properties:Is("SpriteGridPos") then
					gridPos = properties:Val("SpriteGridPos")
				end
				
				if properties:Is("GroupName") or properties:Is("CustomName") then
					groupName = properties:Val("GroupName")
					customName = properties:Val("CustomName")
				end
				
				if customName == "Contraption" then				
					benchObject = thisObject
					benchGroupName = groupName
					break
				end
				
			end 
		end 
	end

	if not benchObject then 
		return 
	end
	
	local soundFile = nil
	local contextMenu = nil
	local actionType = nil
	
	if benchGroupName == "Fitness" then
		local spriteName = benchObject:getSprite():getName()
	
		soundFile = "bench_sound"
		contextMenu = getText("IGUI_Use_Bench")
		actionType = "UseBench"
	else
		return
	end

	context:addOption(getText(contextMenu),
					  worldobjects,
					  NCUseBenchPressMenu.onUseBench,
					  getSpecificPlayer(player),
					  benchObject,
					  soundFile,
					  actionType,
					  5760)
	
end

NCUseBenchPressMenu.getFrontSquare = function(square, facing)
	local value = nil
	
	if facing == "S" then
		value = square:getS()
	elseif facing == "E" then
		value = square:getE()
	elseif facing == "W" then
		value = square:getW()
	elseif facing == "N" then
		value = square:getN()
	end
	
	return value
end

NCUseBenchPressMenu.getFacing = function(properties)

	local facing = nil
	
	if properties:Is("Facing") then
		facing = properties:Val("Facing")
	end
	return facing
end

NCUseBenchPressMenu.walkToFront = function(thisPlayer, benchObject)

	local controllerSquare = nil
	local spriteName = benchObject:getSprite():getName()
	if not spriteName then
		return false
	end

	local properties = benchObject:getSprite():getProperties()
	local facing = NCUseBenchPressMenu.getFacing(properties)
	if facing == nil then
		return false
	end
	
	local frontSquare = NCUseBenchPressMenu.getFrontSquare(benchObject:getSquare(), facing)
	local turn = NCUseBenchPressMenu.getFrontSquare(frontSquare, facing)
	
	if not frontSquare then
		return false
	end
	if not controllerSquare then
		controllerSquare = benchObject:getSquare()
	end
	if AdjacentFreeTileFinder.privTrySquare(controllerSquare, frontSquare) then
		ISTimedActionQueue.add(ISWalkToTimedAction:new(thisPlayer, frontSquare))
		thisPlayer:faceLocation(turn:getX(), turn:getY())
		return true
	end
	return false
end


NCUseBenchPressMenu.onUseBench = function(worldobjects, player, machine, soundFile, actionType, length)
	if NCUseBenchPressMenu.walkToFront(player, machine) then
	
		forceDropHeavyItems(player)
		
		for i=0,player:getWornItems():size()-1 do
			local item = player:getWornItems():get(i):getItem();
			if item and instanceof(item, "InventoryContainer") then
				ISTimedActionQueue.add(ISUnequipAction:new(player, item, 50));
				return
			end
		end
		
		if player:getMoodles():getMoodleLevel(MoodleType.Endurance) > 2 then
			player:Say("Too exhausted to use")
			return
		end
		if player:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) > 2 then
			player:Say("Too heavy to use")
			return
		end
		if player:getMoodles():getMoodleLevel(MoodleType.Pain) > 3 then
			player:Say("Too much pain to use")
			return
		end

		ISTimedActionQueue.add(NCUseBenchPress:new(player, machine, soundFile, actionType, length, squareToTurn))
	end
end

Events.OnPreFillWorldObjectContextMenu.Add(NCUseBenchPressMenu.doBuildMenu);
