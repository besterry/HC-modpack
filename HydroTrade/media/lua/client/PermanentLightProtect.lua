-- Block player interaction with admin permanent lights (toggle/fuel/pickup).

local MOD_KEY = "HydroPermanentLight"

local function isPermanentLight(obj)
	return obj and instanceof(obj, "IsoThumpable") and obj:hasModData() and obj:getModData()[MOD_KEY]
end

local function findPermanentLight(worldobjects)
	if not worldobjects then return nil end
	for _, obj in ipairs(worldobjects) do
		if isPermanentLight(obj) then
			return obj
		end
		local square = obj and obj:getSquare()
		if square then
			local special = square:getSpecialObjects()
			if special then
				for i = 0, special:size() - 1 do
					local o = special:get(i)
					if isPermanentLight(o) then
						return o
					end
				end
			end
		end
	end
	return nil
end

local function stripLightOptions(context)
	if not context then return end
	local names = {
		getText("ContextMenu_Turn_Off"),
		getText("ContextMenu_Turn_On"),
		getText("ContextMenu_Remove_Battery"),
		getText("ContextMenu_Add_Battery"),
		getText("ContextMenu_AddBattery"),
	}
	for _, name in ipairs(names) do
		if context.removeOptionByName then
			context:removeOptionByName(name)
		elseif context.options then
			for i = #context.options, 1, -1 do
				local opt = context.options[i]
				if opt and opt.name == name then
					table.remove(context.options, i)
				end
			end
		end
	end
end

local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
	if test then return end
	if not findPermanentLight(worldobjects) then return end
	stripLightOptions(context)
end

Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu)

local originalCanPickUp = ISMoveableSpriteProps.canPickUpMoveableInternal
function ISMoveableSpriteProps:canPickUpMoveableInternal(character, square, object, isMulti)
	if isPermanentLight(object) then
		return false
	end
	if originalCanPickUp then
		return originalCanPickUp(self, character, square, object, isMulti)
	end
	return false
end

if ISToggleLightSourceAction then
	local originalToggleValid = ISToggleLightSourceAction.isValid
	function ISToggleLightSourceAction:isValid()
		if isPermanentLight(self.lightSource) then
			return false
		end
		return originalToggleValid(self)
	end
end

if ISRemoveLightSourceFuelAction then
	local originalRemoveFuelValid = ISRemoveLightSourceFuelAction.isValid
	function ISRemoveLightSourceFuelAction:isValid()
		if isPermanentLight(self.lightSource) then
			return false
		end
		return originalRemoveFuelValid(self)
	end
end

if ISInsertLightSourceFuelAction then
	local originalInsertFuelValid = ISInsertLightSourceFuelAction.isValid
	function ISInsertLightSourceFuelAction:isValid()
		if isPermanentLight(self.lightSource) then
			return false
		end
		return originalInsertFuelValid(self)
	end
end
