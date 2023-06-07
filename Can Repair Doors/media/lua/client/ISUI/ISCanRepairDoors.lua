
ISCanRepairDoors = {}
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function ISCanRepairDoors.addAction(_worldObjects, _door, _player, OriginHealthDoor, _system)
    local hammer
    local objet
    local time
    local sqDoor = _door:getSquare()
    local healthDoorTEST = _door:getHealth()
    if sqDoor:DistTo(_player) > 2 or (not isClient() and OriginHealthDoor < healthDoorTEST) then return end
    local inventory     = _player:getInventory()
    local Screwdriver   = inventory:getItemFromType("Screwdriver")

    _player:setPrimaryHandItem(nil);
    _player:setSecondaryHandItem(nil); 

    if inventory:contains("Hammer")             then hammer = inventory:getItemFromType("Hammer")
    elseif inventory:contains("BallPeenHammer") then hammer = inventory:getItemFromType("BallPeenHammer")
    end
    
    if _system == "wood" then 
        _player:setPrimaryHandItem(hammer);
        _player:setSecondaryHandItem(Screwdriver);
        time = 500
    elseif _system == "metal" then 
        _player:setPrimaryHandItem(hammer);
        _player:setSecondaryHandItem(Screwdriver);
        time = 800
    elseif _system == "epoxy" then 
        time = 750
    end 
    -------------------------------------------------------------
    if not isClient() then 
        ISTimedActionQueue.add(CanRepairDoorsAction:new(_player, _door, _system, healthDoorTEST, time)) --objet
    else
        local x = door:getX()
        local y = door:getY()
        local z = door:getZ()
        sendClientCommand("CRD_repairDoor_client","true",{x,y,z,_system, time})
    end
    -------------------------------------------------------------
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function ISCanRepairDoors.CheckDoor(_worldObjects, _door, _player)
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    local door = _door
    local x = door:getX()
    local y = door:getY()
    local z = door:getZ()
    sendClientCommand("CRD_checkDoor","true",{x,y,z})  
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function ISCanRepairDoors.actionDoor_admin(_worldObjects, _door, _player, nbr)
-----------------------------------------------------------------------------------------------------------------------------------------------------------
    local door = _door
    if isClient() then
        local x = door:getX()
        local y = door:getY()
        local z = door:getZ()
        sendClientCommand("CRD_actionDoor_admin","true",{x,y,z,nbr})  
    else
        local healthDoor = door:getHealth()
        local maxHealth = door:getMaxHealth()
        door:setHealth(maxHealth*nbr)
    end
end
																-- CONTEXT_MENU DOOR HOUSE
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function ISCanRepairDoors.createWorldMenu(_player, _context, _worldObjects)
	local door = nil
	for _, object in ipairs(_worldObjects) do
		if instanceof(object, "IsoDoor") or (instanceof(object, "IsoThumpable") and object:isDoor()) then
			door = object
			break
		end
	end
	---------------------------
	if not door then return end
	---------------------------
    local player = getSpecificPlayer(_player)
    local sqDoor = door:getSquare()
    if sqDoor:DistTo(player) > 2 then return end 
	local context 				= _context
	local inventory 			= player:getInventory()
	local inventoryHammer = inventory:contains("Hammer")
    local inventoryBallPeenHammer = inventory:contains("BallPeenHammer")
    local inventoryScrewdriver  = inventory:containsType("Screwdriver")
    local inventoryDoorsRepairKitWood  = inventory:containsType("DoorsRepairKitWood")
    local inventoryDoorsRepairKitMetal  = inventory:containsType("DoorsRepairKitMetal")
    local inventoryDoorsRepairKitEpoxy  = inventory:containsType("DoorsRepairKitEpoxy")
    local healthDoor = door:getHealth()
    local maxHealth = door:getMaxHealth() 
	local carpSkill 			= player:getPerkLevel(Perks.Woodwork)
	-------------------------------------------------------------
    local ISCanRepairDoorsMenuOption = context:addOption(getText("IGUI_CanRepairDoors_option"))
    local subMenuISCanRepairDoors = context:getNew(context)
    context:addSubMenu(ISCanRepairDoorsMenuOption, subMenuISCanRepairDoors)
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    if isAdmin() or getCore():getDebug() then
        if not isClient() then 
            ISCanRepairDoorsMenuOption.toolTip = ISToolTip:new()
            ISCanRepairDoorsMenuOption.toolTip:initialise()
            ISCanRepairDoorsMenuOption.toolTip:setVisible(false)   
            ISCanRepairDoorsMenuOption.toolTip:setName(tostring(healthDoor)) 
        end
        local option = subMenuISCanRepairDoors:addOption(getText("IGUI_repairDoorAdmin"),_worldObjects, ISCanRepairDoors.actionDoor_admin, door, player, 1)
        local option = subMenuISCanRepairDoors:addOption(getText("IGUI_reinforceDoorAdmin"),_worldObjects, ISCanRepairDoors.actionDoor_admin, door, player, 2)
    end
    if isClient() then 
        local option = subMenuISCanRepairDoors:addOption(getText("IGUI_CheckDoorMP"),_worldObjects, ISCanRepairDoors.CheckDoor, door, player)
    end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    local option = subMenuISCanRepairDoors:addOption(getText("IGUI_RepairDoorWithKitEpoxy"),_worldObjects, ISCanRepairDoors.addAction, door, player, healthDoor, "epoxy")
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    option.toolTip = ISToolTip:new()
    option.toolTip:initialise()
    option.toolTip:setVisible(false)
    option.toolTip:setName(getText("IGUI_Info"))
    --------------------
    if not isClient() then
        if healthDoor < (maxHealth/4) then
            local color = " <RGB:0.9,0,0> "
            option.toolTip.description = color .. getText("IGUI_veryBadlyHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth/4) and healthDoor < (maxHealth/2) then
            local color = " <RGB:0.8,0.4,0> "
            option.toolTip.description = color .. getText("IGUI_BadlyHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth/2) and healthDoor < (maxHealth-(maxHealth/5)) then
            local color = " <RGB:0.8,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_midleHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth-(maxHealth/5)) and healthDoor <= maxHealth then
            local color = " <RGB:0,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_maxHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor > maxHealth and healthDoor < (maxHealth+(maxHealth/5)) then
            local color = " <RGB:0,0.5,1> "
            option.toolTip.description = color .. getText("IGUI_damagedRenforcedHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor >= (maxHealth+(maxHealth/5)) and healthDoor > maxHealth then
            local color = " <RGB:0.6,0.4,0.9> "
            option.toolTip.description = color .. getText("IGUI_renforcedHealtDoor") .. " | " .. tostring(healthDoor) .. "/1000 | " .. " <LINE> "
            option.notAvailable = true
        end
    end    
    ------------------------------------------------------------------------------------------------------------------
    local color = " <RGB:1,1,1> " 
    option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_RepairDoorWithKitEpoxyINFO") .. " <LINE> " 
    ------------------------------------------------------------------------------------------------------------------
    if inventoryDoorsRepairKitEpoxy == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitEpoxy")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitEpoxy")) .. " <LINE> "
    end
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
    local option = subMenuISCanRepairDoors:addOption(getText("IGUI_RepairDoorWithKitWood"),_worldObjects, ISCanRepairDoors.addAction, door, player, healthDoor, "wood")
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    option.toolTip = ISToolTip:new()
    option.toolTip:initialise()
    option.toolTip:setVisible(false)
    option.toolTip:setName(getText("IGUI_Info"))
    --------------------
    if not isClient() then
        if healthDoor < (maxHealth/4) then
            local color = " <RGB:0.9,0,0> "
            option.toolTip.description = color .. getText("IGUI_veryBadlyHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth/4) and healthDoor < (maxHealth/2) then
            local color = " <RGB:0.8,0.4,0> "
            option.toolTip.description = color .. getText("IGUI_BadlyHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth/2) and healthDoor < (maxHealth-(maxHealth/5)) then
            local color = " <RGB:0.8,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_midleHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth-(maxHealth/5)) and healthDoor <= maxHealth then
            local color = " <RGB:0,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_maxHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor > maxHealth and healthDoor < (maxHealth+(maxHealth/5)) then
            local color = " <RGB:0,0.5,1> "
            option.toolTip.description = color .. getText("IGUI_damagedRenforcedHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor >= (maxHealth+(maxHealth/5)) and healthDoor > maxHealth then
            local color = " <RGB:0.6,0.4,0.9> "
            option.toolTip.description = color .. getText("IGUI_renforcedHealtDoor") .. " | " .. tostring(healthDoor) .. "/1000 | " .. " <LINE> "
            option.notAvailable = true
        end
    end    
    ------------------------------------------------------------------------------------------------------------------
    local color = " <RGB:1,1,1> " 
    option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_RepairDoorWithKitWoodINFO") .. " <LINE> "
    ------------------------------------------------------------------------------------------------------------------
     if carpSkill < 1 then
    --------------------------------------
        local color = " <RGB:0.8,0.5,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_CarpSkillNiv1Required") .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_CarpSkillNiv1Required") .. " <LINE> " 
    end
    if inventoryHammer == false and inventoryBallPeenHammer == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Hammer")) .. " <LINE> " 
        option.notAvailable = true
    else
    	local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Hammer")) .. " <LINE> "
    end
    --------------------------------------
    if inventoryScrewdriver == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> "
    end
    --------------------------------------
    if inventoryDoorsRepairKitWood == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitWood")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitWood")) .. " <LINE> "
    end
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    local option = subMenuISCanRepairDoors:addOption(getText("IGUI_RepairDoorWithKitMetal"),_worldObjects, ISCanRepairDoors.addAction, door, player, healthDoor, "metal")
    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    option.toolTip = ISToolTip:new()
    option.toolTip:initialise()
    option.toolTip:setVisible(false)
    option.toolTip:setName(getText("IGUI_Info"))
    --------------------
    if not isClient() then
        if healthDoor < (maxHealth/4) then
            local color = " <RGB:0.9,0,0> "
            option.toolTip.description = color .. getText("IGUI_veryBadlyHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor >= (maxHealth/4) and healthDoor < (maxHealth/2) then
            local color = " <RGB:0.8,0.4,0> "
            option.toolTip.description = color .. getText("IGUI_BadlyHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor >= (maxHealth/2) and healthDoor < (maxHealth-(maxHealth/5)) then
            local color = " <RGB:0.8,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_midleHealtDoor") .. " <LINE> "
            option.notAvailable = true
        elseif healthDoor >= (maxHealth-(maxHealth/5)) and healthDoor <= maxHealth then
            local color = " <RGB:0,0.8,0> "
            option.toolTip.description = color .. getText("IGUI_maxHealtDoor") .. " <LINE> "
        elseif healthDoor > maxHealth and healthDoor < (maxHealth+(maxHealth/5)) then
            local color = " <RGB:0,0.5,1> "
            option.toolTip.description = color .. getText("IGUI_damagedRenforcedHealtDoor") .. " <LINE> "
        elseif healthDoor >= (maxHealth+(maxHealth/5)) and healthDoor > maxHealth then
            local color = " <RGB:0.6,0.4,0.9> "
            option.toolTip.description = color .. getText("IGUI_renforcedHealtDoor") .. " | " .. tostring(healthDoor) .. "/1000 | " .. " <LINE> "
            option.notAvailable = true
        end
    end    
    ------------------------------------------------------------------------------------------------------------------
    local color = " <RGB:1,1,1> " 
    option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_RepairDoorWithKitMetalINFO") .. " <LINE> "
    ------------------------------------------------------------------------------------------------------------------
    if carpSkill < 2 then
    --------------------------------------
        local color = " <RGB:0.8,0.5,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_CarpSkillNiv2Required") .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("IGUI_CarpSkillNiv2Required") .. " <LINE> " 
    end
    --------------------------------------
    if inventoryHammer == false and inventoryBallPeenHammer == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Hammer")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Hammer")) .. " <LINE> "
    end
    --------------------------------------
    if inventoryScrewdriver == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.Screwdriver")) .. " <LINE> "
    end
        --------------------------------------
    if inventoryDoorsRepairKitMetal == false then
    --------------------------------------
        local color = " <RGB:0.9,0,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitMetal")) .. " <LINE> " 
        option.notAvailable = true
    else
        local color = " <RGB:0,0.8,0> "
        option.toolTip.description = option.toolTip.description .. color .. getText("ContextMenu_Require", getItemNameFromFullType("Base.DoorsRepairKitMetal")) .. " <LINE> "
    end
end
-----------------------------------------------------------------------
Events.OnFillWorldObjectContextMenu.Add(ISCanRepairDoors.createWorldMenu)
-----------------------------------------------------------------------









