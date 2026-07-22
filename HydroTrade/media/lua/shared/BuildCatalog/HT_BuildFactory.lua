-- Applies catalog recipe costs onto building objects at setDrag time.
-- create() may still call vanilla/MoreBuilds/HC builders; their need:/use:/xp: are replaced.
-- Editing balance = change recipe needs/uses/skills/tools/section/xp only.

HT_BuildFactory = HT_BuildFactory or {}

local function startsWith(s, prefix)
	return type(s) == "string" and string.sub(s, 1, #prefix) == prefix
end

HT_BuildFactory.clearCosts = function(modData)
	if not modData then
		return
	end
	local keys = {}
	for k, _ in pairs(modData) do
		if startsWith(k, "need:") or startsWith(k, "use:") or startsWith(k, "xp:") then
			table.insert(keys, k)
		end
	end
	for _, k in ipairs(keys) do
		modData[k] = nil
	end
end

HT_BuildFactory.applyCosts = function(obj, active)
	if not obj or not active then
		return
	end
	if not obj.modData then
		obj.modData = {}
	end
	HT_BuildFactory.clearCosts(obj.modData)
	if active.needs then
		for _, n in ipairs(active.needs) do
			if n.item and n.count then
				obj.modData["need:" .. n.item] = n.count
			end
		end
	end
	if active.uses then
		for _, u in ipairs(active.uses) do
			if u.item and u.count then
				obj.modData["use:" .. u.item] = u.count
			end
		end
	end
	if active.xp then
		for perkId, amount in pairs(active.xp) do
			obj.modData["xp:" .. perkId] = amount
		end
	end
	if active.tools then
		local hasTorch = false
		local hasMask = false
		local hasHammer = false
		for _, tool in ipairs(active.tools) do
			if tool == "BlowTorch" then
				hasTorch = true
			elseif tool == "WeldingMask" then
				hasMask = true
			elseif tool == "Hammer" then
				hasHammer = true
			end
		end
		if hasTorch then
			obj.firstItem = "BlowTorch"
			obj.craftingBank = obj.craftingBank or "BlowTorch"
			obj.noNeedHammer = true
			if hasMask then
				obj.secondItem = "WeldingMask"
			end
		elseif hasHammer and MoreBuild and MoreBuild.equipToolPrimary then
			MoreBuild.equipToolPrimary(obj, obj.player, "Hammer")
		end
	end
end

-- Override getCell() briefly so legacy onBuild* setDrag picks up our costs.
HT_BuildFactory.runCreate = function(playerNum, active, createFn)
	if not createFn then
		return
	end
	if not active then
		createFn(playerNum)
		return
	end
	local realGetCell = getCell
	local realCell = realGetCell and realGetCell() or nil
	if not realCell then
		createFn(playerNum)
		return
	end
	local proxy = {
		setDrag = function(_, obj, player)
			HT_BuildFactory.applyCosts(obj, active)
			realCell:setDrag(obj, player)
		end,
	}
	local oldGetCell = getCell
	getCell = function()
		return proxy
	end
	local ok, err = pcall(createFn, playerNum)
	getCell = oldGetCell
	if not ok then
		print("[HT_BuildFactory] create failed: " .. tostring(err))
	end
end
