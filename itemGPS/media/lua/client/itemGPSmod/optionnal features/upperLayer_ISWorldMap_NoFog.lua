require "ISUI/Maps/ISWorldMap"

local upperLayer = {}
upperLayer.ISWorldMap = {}

        
upperLayer.ISWorldMap.updateJoypad = ISWorldMap.updateJoypad
function ISWorldMap:updateJoypad()
    upperLayer.ISWorldMap.updateJoypad(self)
    local noMap = SandboxVars.itemGPS.WorldMap
    local wmap = CheckMapItem()
    if (noMap == 0 or (noMap == 1 and not itemGPSmod.gps and not wmap)) and not isAdmin() then  
        --self.close() 
        if ISWorldMap_instance and ISWorldMap_instance:isVisible() then
            local player = getSpecificPlayer(0)
            local playerNum = player and player:getPlayerNum()
            if playerNum then 
                ISWorldMap.HideWorldMap(playerNum) 
            end
        end
    end

    local noFogOnWorldMap = SandboxVars.itemGPS.noFogOnWorldMap  
    local noFogOnMiniMap = SandboxVars.itemGPS.noFogOnMiniMap 
    local syncMinimapFogToWorldMap = SandboxVars.itemGPS.syncMinimapFogToWorldMap 
    local gps = (itemGPSmod.gps and (itemGPSmod.gps:getType() == "GPSdayz" or itemGPSmod.gps:getType() == "GPS_315" or itemGPSmod.gps:getType() == "GPS_H800"))
    local sync = (gps and noFogOnMiniMap == true and syncMinimapFogToWorldMap == true)
    self.hideUnvisitedAreas = self.mapAPI:getBoolean("HideUnvisited")
    if self.hideUnvisitedAreas == true and (noFogOnWorldMap == true or sync or isAdmin()) then 
        self.hideUnvisitedAreas = false
        self.mapAPI:setBoolean("HideUnvisited", false)
        --self.mapAPI:resetView()
    elseif self.hideUnvisitedAreas == false and noFogOnWorldMap == false and not sync and not isAdmin() then
        self.hideUnvisitedAreas = true
        self.mapAPI:setBoolean("HideUnvisited", true)
    end
end