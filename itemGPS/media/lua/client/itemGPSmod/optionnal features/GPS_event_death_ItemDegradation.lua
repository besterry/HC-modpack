
local function OnPlayerDeath()
	local canBeDestroyed = SandboxVars.itemGPS.canBeDestroyed
	if canBeDestroyed == 0 then return end
	--print("canBeDestroyed > 0 : " .. canBeDestroyed)
	local rand = ZombRand(canBeDestroyed)
	if rand >= 2 then return end
	local player = getSpecificPlayer(0)
	if not player then return end
	local square = player:getCurrentSquare()
	local gps = itemGPSmod.LastGps
	if gps then 
		if gps:getWorldItem() ~= nil and gps:getWorldItem():getSquare() == square then--gps:getContainer() and gps:getContainer():getType() == "floor" then
			gps:getWorldItem():getSquare():transmitRemoveItemFromSquare(gps:getWorldItem())
            gps:getWorldItem():getSquare():removeWorldObject(gps:getWorldItem());
			--gps:removeFromWorld()
	      	--gps:removeFromSquare()	
		  	-- gps:getContainer():Remove(gps);	
		   	gps:setWorldItem(nil);	    
		    ISInventoryPage.dirtyUI()
		    local type = gps:getType()
		    square:AddWorldInventoryItem("Base.".. type .. "Destroyed", 0, 0, 0);
		    itemGPSmod.LastGps = nil
            return			
		end
	end

	for i=0, player:getInventory():getItems():size()-1 do
		local item = player:getInventory():getItems():get(i)
		if item:hasTag("GPSmod") or item:hasTag("GPSmodCar") then
			gpsINV = item
			break
		end
	end
		
	if gpsINV then
		
		player:removeAttachedItem(gpsINV)
		gpsINV:setAttachedSlotType(nil);
		gpsINV:setAttachedToModel(nil);
		player:getInventory():Remove(gpsINV)
		player:removeFromHands(gpsINV)
		ISInventoryPage.renderDirty = true
		local type = gpsINV:getType()
		player:getInventory():AddItem("Base.".. type .. "Destroyed")
		
		return
	end
end
----------------------------------------
Events.OnPlayerDeath.Add(OnPlayerDeath)
-----------------------------------------------------------------------------------------------------------------------------------------------------------


--	local containers = ISInventoryPaneContextMenu.getContainers(player) -- containerList--
--	for i=1,containers:size() do
--		local container = containers:get(i-1)
--		if container then
--			for j=1,container:getItems():size() do
--				local item = container:getItems():get(j-1)		
--				if item then
--					local type = item:getType()
--					if type == "GPSdayz" then
--						local worldObj = item:getWorldItem()
--						if  worldObj then 
--							worldObj:getSquare():transmitRemoveItemFromSquare(worldObj)
--							worldObj:removeFromWorld()
--	      					worldObj:removeFromSquare()	
--	      					ISInventoryPage.dirtyUI()
--	      					square:AddWorldInventoryItem("Base.GPSdestroyed", 0, 0, 0);
--	      					return
--						end
--					end
--				end
--			end
--		end	
--	end