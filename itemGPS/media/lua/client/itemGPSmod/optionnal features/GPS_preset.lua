local n = 150
local preset = {
    
    doevalley_MA     = {x=5484,y=9595},
    marchridge      = {x=10122,y=12731},
    muldraugh = {
        muldraugh_N     = {x=10605,y=9271},
        muldraugh_S     = {x=10600,y=10587}
    },
    louisville = {
        louisville_IS   = {x=12613,y=4357},
        louisville_MS   = {x=12415,y=3626},
        louisville_MNE  = {x=13389,y=1381},
        louisville_S    = {x=13313,y=3025},
        louisville_W    = {x=12074,y=2562},
        louisville_E    = {x=13828,y=2394},
        louisville_C    = {x=12598,y=1798},
        louisville_L    = {x=13238,y=2650},
        louisville_INW  = {x=12064,y=1538},
        louisville_N    = {x=12597,y=1174}
    },
    riverside = {
        riverside_L     = {x=5722,y=6494},
        riverside_I     = {x=5504,y=5954},
        riverside_W     = {x=5881,y=5294},
        riverside_C     = {x=6447,y=5326},
        riverside_E     = {x=6837,y=5402}
    },
    Rosewood        = {x=8121,y=11505},
    valleystation = {
        valleystation_M = {x=13739,y=5792},
        valleystation   = {x=12567,y=5348}
    },
    westpoint = {
        westpoint_W     = {x=11128,y=6750},
        Westpoint_C     = {x=11876,y=6855}
    }
}
local possiblePreset = {
    --RavenCreek = {
    --    RavenCreek_NW = {x=8700,y=9600},
    --    RavenCreek_W = {x=8700,y=9900},
    --    RavenCreek_SW = {x=8700,y=10200},
    --    RavenCreek_N = {x=9000,y=9600},
    --    RavenCreek_C = {x=9000,y=9900},
    --    RavenCreek_S = {x=9000,y=10200},
    --    RavenCreek_NE = {x=9300,y=9600},
    --    RavenCreek_E = {x=9300,y=9900},
    --    RavenCreek_SE = {x=9300,y=10200}
    --},
    Chestown = {x=4500-n,y=6600-n},
--    lakeivytownship = {
--        lakeivytownship_NW = {x=8700-n,y=9600-n},
--        lakeivytownship_W = {x=8700-n,y=9900-n},
--        lakeivytownship_SW = {x=8700-n,y=10200-n},
--        lakeivytownship_N = {x=9000-n,y=9600-n},
--        lakeivytownship_C = {x=9000-n,y=9900-n},
--        lakeivytownship_S = {x=9000-n,y=10200-n},
--        lakeivytownship_NE = {x=9300-n,y=9600-n},
--        lakeivytownship_E = {x=9300-n,y=9900-n},
--        lakeivytownship_SE = {x=9300-n,y=10200-n}
--    },
    Seaside = {x=12300-n,y=300-n},
    Grapeseed = {x=7200-n,y=11100-n},
    Ashenwood = {
        Ashenwood_S = {x=11400-n,y=11400-n},
        Ashenwood_N = {x=11400-n,y=11100-n}
    },
    RabbitHashKY = {
        RabbitHashKY_W = {x=9000-n,y=7200-n},  
        RabbitHashKY_E = {x=9300-n,y=7200-n}
    },
    KingsmouthKY = {
        KingsmouthKY_NW = {x=3000-n,y=3900-n},
        KingsmouthKY_SE = {x=4200-n,y=5100-n}
    },
--    wilboreky = {
--        wilboreky_NW = {x=4500-n,y=9900-n}, 
--        wilboreky_NE = {x=4800-n,y=9900-n},
--        wilboreky_W = {x=4500-n,y=10200-n}, 
--        wilboreky_E = {x=4800-n,y=10200-n},
--        wilboreky_SW = {x=4500-n,y=10500-n}, 
--        wilboreky_SE = {x=4800-n,y=10500-n}
--    },
    Trelai_4x4_Steam = {x=6600-n,y=6600-n}, --Starting Cell. (16 Cells)
    Utopia = {x=7200-n,y=9600-n},
--    Petroville = {
--        wilboreky_NW = {x=10500-n,y=11700-n}, --to 
--        wilboreky_NE = {x=11100-n,y=11700-n},
--        wilboreky_W = {x=10500-n,y=12000-n}, --to 
--        wilboreky_E = {x=11100-n,y=12000-n},
--        wilboreky_SW = {x=10500-n,y=12300-n}, --to 
--        wilboreky_SE = {x=11100-n,y=12300-n}
--    },
--    Taylorsville = {
--        wilboreky_CWN = {x=9300-n,y=6300-n},
--        wilboreky_CN = {x=9600-n,y=6300-n},
--        wilboreky_CNE = {x=9900-n,y=6300-n},
--        wilboreky_NE = {x=10200-n,y=6300-n},
--        wilboreky_W = {x=9000-n,y=6600-n},
--        wilboreky_CW = {x=9300-n,y=6600-n},
--        wilboreky_C = {x=9600-n,y=6600-n},
--        wilboreky_CE = {x=9900-n,y=6600-n},
--        wilboreky_E = {x=10200-n,y=6600-n},
--        wilboreky_SW = {x=9000-n,y=6900-n},
--        wilboreky_CSW = {x=9300-n,y=6900-n},
--        wilboreky_CS = {x=9600-n,y=6900-n},
--        wilboreky_CSE = {x=9900-n,y=6900-n},
--        wilboreky_SE = {x=10200-n,y=6900-n},
--        wilboreky_CS = {x=9600-n,y=7200-n},
--        wilboreky_CSE = {x=9900-n,y=7200-n}
--    }
    --BedfordFalls = {x=1000,y=1000},
    --Blackwood = {x=1000,y=1000},
    --Pitstop = {x=1000,y=1000},
    --Mod_Phoenix = {x=1000,y=1000},
    --NewEkron = {x=1000,y=1000},
    --Greenleaf = {x=1000,y=1000},
    --wildberries = {x=1000,y=1000},
    --Fort_Knox = {x=1000,y=1000}
}
--[[
local player = getPlayer()
local x,y = player:getX():,player:getZ():
print("RavenCreek = {x="..x.."y="..y.."},")
]]
Events.OnGameBoot.Add(function()
    for i,v in pairs(possiblePreset) do
        --preset[tostring(i)] = v
        if getActivatedMods():contains(tostring(i)) then preset[tostring(i)] = v end
    end
    require("itemGPSmod/GPS_functionUI");
    local contextMenu
    local ISMiniMapInner_onRightMouseUp = ISMiniMapInner.onRightMouseUp
    function ISMiniMapInner:onRightMouseUp(x, y)
        ISMiniMapInner_onRightMouseUp(self,x,y)
        if not self.player then return end   
        if not self.gps then return end 
        local function getContext (pos,index)
            local keyMenu = contextMenu:addOption(getText("IGUI_itemGPS_areaMenu_"..tostring(index)))
            local subMenu = ISContextMenu:getNew(contextMenu);
            contextMenu:addSubMenu(keyMenu, subMenu);
            --print("...............TEST "..tostring(self))
            if self.option2 == true then
                local option = subMenu:addOption("1.set waypoint", self, self.Waypoint_clic, pos.x, pos.y, 1)
            end
            if self.option3 == true then
                local option = subMenu:addOption("2.set waypoint", self, self.Waypoint_clic, pos.x, pos.y, 2)
            end
    
            if isAdmin() or getCore():getDebug() then
                local option = subMenu:addOption("Teleport to",nil,function()
                    self.player:setX(pos.x)
                    self.player:setY(pos.y)
                    self.player:setZ(0)
                    self.player:setLx(pos.x)
                    self.player:setLy(pos.y)
                    self.player:setLz(0)
                end)
            end
        end

        local playerNum = 0
        local context = self.GPScontext


        if context then
            local presetOption = context:addOption("Preset")
            local presetContext = ISContextMenu:getNew(context);
            context:addSubMenu(presetOption, presetContext);
    
            for i,v in pairs(preset)do
                if not v.x then
                    local keyMenu = presetContext:addOption(getText("IGUI_itemGPS_areaMenu_"..tostring(i)))
                    local subMenu = ISContextMenu:getNew(presetContext);
                    presetContext:addSubMenu(keyMenu, subMenu);
                    contextMenu = subMenu
                    for _,d in pairs(v)do
                        getContext(d,_)
                    end
                else
                    contextMenu = presetContext
                    getContext(v,i)
                end
            end
        end
    end
end)