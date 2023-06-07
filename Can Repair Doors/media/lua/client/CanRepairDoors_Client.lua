local function CRD_OnServerCommand(module, command, arguments)
    local player=getPlayer()
----------------------------------------------------------
    if module == "CRD_checkDoor" then 
    	if isAdmin() or getCore():getDebug() then player:Say("Health door = "..tostring(arguments[1])) end
    	local healthDoor = arguments[1]
    	local maxHealth = arguments[2]
--setHaloNote(, 255,255,255,300);
    	if healthDoor < (maxHealth/4) then
        	local msg = getText("IGUI_veryBadlyHealtDoor")
        	player:setHaloNote(msg, 255, 90, 0, 300)
		elseif (healthDoor >= (maxHealth/4) and healthDoor < (maxHealth/2)) then
		    local msg = getText("IGUI_BadlyHealtDoor")
		    player:setHaloNote(msg, 255, 150, 0, 300)
		elseif (healthDoor >= (maxHealth/2) and healthDoor < (maxHealth-(maxHealth/5))) then
		    local msg = getText("IGUI_midleHealtDoor")
		    player:setHaloNote(msg, 255, 210, 0, 300)
		elseif (healthDoor >= (maxHealth-(maxHealth/5)) and healthDoor <= maxHealth) then
		    local msg = getText("IGUI_maxHealtDoor")
		    player:setHaloNote(msg, 100, 220, 100, 300)
		elseif (healthDoor > maxHealth and healthDoor < (maxHealth+(maxHealth/5))) then
			local msg = getText("IGUI_damagedRenforcedHealtDoor")
		    player:setHaloNote(msg, 0, 175, 230, 300)
		elseif healthDoor >= (maxHealth+(maxHealth/5)) and healthDoor > maxHealth then   
			local msg = getText("IGUI_renforcedHealtDoor").." | "..tostring(healthDoor).."/1000 |"
			player:setHaloNote(msg, 160, 100, 255, 300)
		end 
    	--print("CRD_checkDoor client")    	
----------------------------------------------------------
	elseif module == "CRD_actionDoor_admin" then 
		local msg = "Health door = "..tostring(arguments[1])
		player:setHaloNote(msg, 236, 131, 190, 300)
		--print("CRD_repairDoor client")
----------------------------------------------------------
	elseif module == "CRD_repairDoor_client" then 
		local x = arguments[1]
		local y = arguments[2]
		local z = arguments[3]
		local system = arguments[4]
		local healthDoor = arguments[5]
		local time = arguments[6]
		local maxHealth = arguments[7]
		local sq = getWorld():getCell():getGridSquare(x, y, z)
		if healthDoor < (maxHealth/4) then
        	if (system ~= "wood" and system ~= "epoxy") then
        		local msg = getText("IGUI_CRD_Impossible_reinforce")
        		player:setHaloNote(msg, 210, 210, 210, 300)
		    	return
		    end
		elseif (healthDoor >= (maxHealth/4) and healthDoor < (maxHealth/2)) then
			if (system ~= "wood" and system ~= "epoxy")  then
		    	local msg = getText("IGUI_CRD_Impossible_reinforce")
		    	player:setHaloNote(msg, 210, 210, 210, 300)
		    	return
		    end
		elseif (healthDoor >= (maxHealth/2) and healthDoor < (maxHealth-(maxHealth/5))) then
			if (system ~= "wood" and system ~= "epoxy")  then
		    	local msg = getText("IGUI_CRD_Impossible_reinforce")
		    	player:setHaloNote(msg, 210, 210, 210, 300)
		    	return
		    end
		elseif (healthDoor >= (maxHealth-(maxHealth/5)) and healthDoor <= maxHealth) then
			if system ~= "metal" then
		    	local msg = getText("IGUI_CRD_Impossible_repair")
		    	player:setHaloNote(msg, 210, 210, 210, 300)
		    	return
		    end
		elseif (healthDoor > maxHealth and healthDoor < (maxHealth+(maxHealth/5))) then
			if system ~= "metal" then
		    	local msg = getText("IGUI_CRD_Impossible_repair")
		    	player:setHaloNote(msg, 210, 210, 210, 300)
		    	return
		    end
		elseif healthDoor >= (maxHealth+(maxHealth/5)) and healthDoor > maxHealth then  
		    local msg = getText("IGUI_CRD_Impossible_isFullReinforced")
		    player:setHaloNote(msg, 210, 210, 210, 300)
		    return
		end 
		for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            if instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor())then              
        		ISTimedActionQueue.add(CanRepairDoorsAction:new(player, o, system, healthDoor, time))
            	break
            end
        end
		--print("CRD_repairDoor client")
----------------------------------------------------------
	elseif module == "CRD_impossibleHealthRaised"  then
		local system = arguments[1]
		if system == "wood" then 
	        player:getInventory():AddItem("Base.DoorsRepairKitWood")
	    elseif system == "metal" then 
	        player:getInventory():AddItem("Base.DoorsRepairKitMetal")
	    elseif system == "epoxy" then 
	        player:getInventory():AddItem("Base.DoorsRepairKitEpoxy")
	    end 
		local msg = getText("IGUI_CRD_impossibleHealthRaised")
		player:setHaloNote(msg, 236, 131, 190, 300)
----------------------------------------------------------
	end
end
-----------------------------------------------
Events.OnServerCommand.Add(CRD_OnServerCommand)
-----------------------------------------------
