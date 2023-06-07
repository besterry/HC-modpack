STAR_MODS = STAR_MODS or {}
STAR_MODS.SizeLabels = STAR_MODS.SizeLabels or {}

local in_progress = true
local old_fn = nil
local old = Events.OnPlayerUpdate.Add
local RemoveHook = function()
	Events.OnPlayerUpdate.Add = old
end
STAR_MODS.SizeLabels.P4AddictedToWeightCompatibility = RemoveHook
if STAR_MODS.SizeLabels.P4AddictedToWeightCompatibility_Disabled then
	return
end
Events.OnPlayerUpdate.Add = function(fn)
	old(function(player, ...)
		if in_progress then
			if old_fn then
				old_fn = nil
				
			end
			return fn(player, ...)
		end
		in_progress = true
		local fixed_weight = STAR_MODS.SizeLabels.getWeightFixed(player)
		local nutrition = player:getNutrition()
		local m = getmetatable(nutrition)
		old_fn = m.__index.getWeight
		m.__index.getWeight = function()
			return fixed_weight
		end
		local result, msg = pcall(fn, player, ...)
		m.__index.getWeight = old_fn
		if result == false then
			error(msg)
			return 
		end
		in_progress = false
	end)
	RemoveHook()
end



local Init = function ()
	if P4WeightIndicator then
		in_progress = false
	end
end
Events.OnGameBoot.Add(Init)







