-- During testing: keep vanilla/MoreBuilds/HC/Welding context menus intact.
-- HT Catalog is an extra entry (+ hotkey), not a replacement yet.

HT_BuildMenuGate = HT_BuildMenuGate or {}
HT_BuildMenuGate._installed = false

local function refreshGroundMaterials(playerObj)
	if not playerObj then
		return
	end
	local square = playerObj:getCurrentSquare()
	if not square then
		return
	end
	if buildUtil and buildUtil.checkMaterialOnGround then
		ISBuildMenu.materialOnGround = buildUtil.checkMaterialOnGround(square)
	end
end

HT_BuildMenuGate.openCatalog = function(playerNum)
	refreshGroundMaterials(getSpecificPlayer(playerNum))
	if HT_BuildRecipes then
		HT_BuildRecipes.init()
	end
	HT_BuildCatalogUI.Open(playerNum)
end

HT_BuildMenuGate.onFillWorldObjectContextMenu = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then
		return true
	end
	if getCore():getGameMode() == "LastStand" then
		return
	end

	local playerObj = getSpecificPlayer(player)
	if not playerObj or playerObj:getVehicle() then
		return
	end

	if test then
		return ISWorldObjectContextMenu.setTest()
	end

	-- Extra entry while we test the new UI. Legacy menus stay registered by their mods.
	context:addOption(getText("IGUI_HT_BuildCatalog_Title") .. " [HT]", worldobjects, function()
		HT_BuildMenuGate.openCatalog(player)
	end)
end

HT_BuildMenuGate.onKeyPressed = function(key)
	if key == getCore():getKey("HT_BuildCatalog_Open") then
		local player = getPlayer()
		if not player then
			return
		end
		if HT_BuildCatalogUI.instance then
			HT_BuildCatalogUI.instance:close()
		else
			HT_BuildMenuGate.openCatalog(player:getPlayerNum())
		end
	end
end

HT_BuildMenuGate.install = function()
	if HT_BuildMenuGate._installed then
		return
	end
	HT_BuildMenuGate._installed = true
	-- Do NOT Remove(ISBuildMenu / MoreBuilds / Blacksmith / Hydrocraft).
	Events.OnFillWorldObjectContextMenu.Add(HT_BuildMenuGate.onFillWorldObjectContextMenu)
	if HT_BuildRecipes and HT_BuildRecipes.init then
		HT_BuildRecipes.init()
	end
end

local function registerKeyBinding()
	local seen = false
	for _, bind in ipairs(keyBinding) do
		if bind.value == "HT_BuildCatalog_Open" then
			seen = true
			break
		end
	end
	if not seen then
		table.insert(keyBinding, { value = "[HT_BuildCatalog]" })
		table.insert(keyBinding, { value = "HT_BuildCatalog_Open", key = Keyboard.KEY_B })
	end
end

Events.OnGameBoot.Add(registerKeyBinding)

Events.OnGameStart.Add(function()
	HT_BuildMenuGate.install()
end)

Events.OnKeyPressed.Add(HT_BuildMenuGate.onKeyPressed)
