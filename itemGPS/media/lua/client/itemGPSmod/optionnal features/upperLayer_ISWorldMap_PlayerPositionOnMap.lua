
	local upperLayer = {}
	upperLayer.ISWorldMap = {}
	itemGPSmod = itemGPSmod or {}

	upperLayer.ISWorldMap.updateJoypad = ISWorldMap.updateJoypad
	function ISWorldMap:updateJoypad()
	    upperLayer.ISWorldMap.updateJoypad(self)
	    if SandboxVars.itemGPS.RedMarkerOnMap == 2 then return end
		if (SandboxVars.itemGPS.RedMarkerOnMap == 1 and itemGPSmod.gps) or isAdmin() then	
		  	self.mapAPI:setBoolean("Players", true) 
		else
			self.mapAPI:setBoolean("Players", false) 
		end
	end

	upperLayer.ISWorldMap.onCenterOnPlayer = ISWorldMap.onCenterOnPlayer
	function ISWorldMap:onCenterOnPlayer()
	    upperLayer.ISWorldMap.onCenterOnPlayer(self)
		if SandboxVars.itemGPS.RedMarkerOnMap == 2 then return end
		if (itemGPSmod.gps and self.mapAPI:getBoolean("Players") == true) or isAdmin() then
			--true
		elseif SandboxVars.itemGPS.CenterPlayerInaccuracyOnMap == false and self.mapAPI:getBoolean("Players") == false then
	        self.mapAPI:resetView()
		elseif itemGPSmod.BRIDE_centerPlayer ~= true and self.mapAPI:getBoolean("Players") == false then

            ISWorldMap_instance.mapAPI:setZoom(16) -- 15

    		local radiusZoom 	 = SandboxVars.itemGPS.CenterPlayerInaccuracyRadius

            itemGPSmod.X_ZoomOnMap = self.character:getX()+ZombRand(-250,250)+ ZombRand(-radiusZoom,radiusZoom)+ZombRand(-60,60) --100,100 90
            itemGPSmod.Y_ZoomOnMap = self.character:getY()+ZombRand(-250,250)+ ZombRand(-radiusZoom,radiusZoom)+ZombRand(-60,60) --80,80
    
            itemGPSmod.BRIDE_centerPlayer = true

            self.mapAPI:centerOn(itemGPSmod.X_ZoomOnMap, itemGPSmod.Y_ZoomOnMap)
			-------------------------------------------------------
	    elseif itemGPSmod.BRIDE_centerPlayer == true and self.mapAPI:getBoolean("Players") == false then
	    	self.mapAPI:centerOn(itemGPSmod.X_ZoomOnMap, itemGPSmod.Y_ZoomOnMap)
	    end    
	end
	
	upperLayer.ISWorldMap.new = ISWorldMap.new
	function ISWorldMap:new(x, y, width, height)
	    local o = upperLayer.ISWorldMap.new( self, x, y, width, height)
	    -- o.beep = 0 ???
    	if not isAdmin() and SandboxVars.itemGPS.RedMarkerOnMap ~= 2 then 
    	    o.showPlayers = false
    	else
    	    o.showPlayers = true
    	end
    	return o
	end

	itemGPSmod.BRIDE_centerPlayer = false
	local function DEBRIDE()
		if SandboxVars.itemGPS.CenterPlayerInaccuracyOnMap == false or SandboxVars.itemGPS.RedMarkerOnMap == 2 then return end
		if itemGPSmod.BRIDE_centerPlayer ~= false then itemGPSmod.BRIDE_centerPlayer = false end
	end
	----------------------------------------------------------------------
	Events.EveryHours.Add(DEBRIDE)

