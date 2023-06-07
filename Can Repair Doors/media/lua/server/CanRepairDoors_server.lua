if not isServer() then return end

local function CRD_OnClientCommand(module, command, player,arguments)
---------------------------------------------------------------------
    if module == "CRD_checkDoor" then
        local x = arguments[1]
        local y = arguments[2]
        local z = arguments[3]
        local sq = getWorld():getCell():getGridSquare(x, y, z)       
        for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            if instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor())then
            	local door = o
                local healthDoor = door:getHealth()
                local maxHealth = door:getMaxHealth()
                door:getSquare():transmitModdata();
        		sendServerCommand(player,"CRD_checkDoor", "true",{healthDoor,maxHealth}) 
        		break
            end
        end
       -- print("CRD_checkDoor server")
 ---------------------------------------------------    
    elseif module == "CRD_actionDoor_admin" then 
    	local x = arguments[1]
        local y = arguments[2]
        local z = arguments[3]
        local nbr = arguments[4]
        local sq = getWorld():getCell():getGridSquare(x, y, z)
        for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            if instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor())then 
            	local door = o
    			local maxHealth = door:getMaxHealth()
                door:setHealth(maxHealth*nbr)
                local healthDoor = door:getHealth()
        		sendServerCommand(player,"CRD_actionDoor_admin", "true",{healthDoor}) 
        		break
            end
        end
        --print("CRD_repairDoor_admin server")        
    ---------------------------------------------------    
    elseif module == "CRD_repairDoor_client" then 
    	local x = arguments[1]
        local y = arguments[2]
        local z = arguments[3]
        local system = arguments[4]
        local time = arguments[5]

        local sq = getWorld():getCell():getGridSquare(x, y, z)
        for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            if instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor()) then
            	local door = o
                local healthDoor = door:getHealth()
                local maxHealth = door:getMaxHealth()
                sendServerCommand(player,"CRD_repairDoor_client", "true",{x,y,z, system, healthDoor, time, maxHealth})
        		break
            end
        end
        --print("CRD_repairDoor_client server")
    ---------------------------------------------------    
    elseif module == "CRD_apply_repairDoor_client" then 
    	local x = arguments[1]
        local y = arguments[2]
        local z = arguments[3]
        local system = arguments[4]
        local healthDoor = arguments[5]
        local healthAdd = arguments[6]

        local sq = getWorld():getCell():getGridSquare(x, y, z)
        for i=0,sq:getObjects():size()-1 do
            local o = sq:getObjects():get(i)
            if (instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor())) and healthDoor >= o:getHealth() then
            	local door = o
            	local maxHealth = door:getMaxHealth() 
                if system == "wood" or system == "epoxy" then
					door:setHealth(healthDoor+healthAdd)
					if door:getHealth() > maxHealth then door:setHealth(maxHealth) end
				elseif system == "metal" then
					door:setHealth(healthDoor+healthAdd)
					if door:getHealth() > (maxHealth*2) then door:setHealth(maxHealth*2) end
				end
				local healthDoorResult = door:getHealth() 
				sendServerCommand(player,"CRD_checkDoor", "true",{healthDoorResult,maxHealth})
        		break
            elseif (instanceof(o, 'IsoDoor') or (instanceof(o, "IsoThumpable") and o:isDoor())) and healthDoor < o:getHealth() then
            	sendServerCommand(player,"CRD_impossibleHealthRaised", "true",{system})
            	break
            end
        end	
        --print("CRD_apply_repairDoor_client")
    ---------------------------------------------------    
    end
end
------------------------------------------------   
Events.OnClientCommand.Add(CRD_OnClientCommand)
------------------------------------------------  





--CRD = CRD or {}
--CRD.checkDoor = function(player,door)
--    print("CRD_checkDoor server")
-- --   local ply = getSpecificPlayer(player)
----    ply:Say("CRD_checkDoor server")
--    --local healthDoor = door:getHealth()
--    --door:sendObjectChange('state')
--    --door:setHealth(healthDoor)
--    --door:transmitModData()
--    --door:transmitCompleteItemToServer()
--    --door:transmitUpdatedSpriteToClients()
--    --o:sendObjectChange("paintable")
--    --drum:getIsoObject():transmitModData()
--    --door:transmitCompleteItemToClients()
--    --sendServerCommand(player,"CRD_checkDoor", "true",{door,healthDoor}) 
--end