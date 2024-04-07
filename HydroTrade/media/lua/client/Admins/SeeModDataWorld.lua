local function showModdata(obj)
    if not isAdmin() then return; end
    local moddata = obj:getModData()
    ItemModDataPanel.OnOpenPanel(obj)
end

local function ContextMenu(player, context, worldobjects, test)
    if not isAdmin() then return; end
	local sq = nil

    for i,v in ipairs(worldobjects) do
        local square = v:getSquare();
        if square and sq == nil then
            sq = square
        end
        if instanceof(v, "IsoObject") then
            print(v)
            context:addOption(getText("IGUI_Show_IsoObject_modData"), v, showModdata)
        end
    end

    if sq ~= nil then
        local clickedPlayer = nil
        
        for x=sq:getX()-1, sq:getX()+1 do
            for y=sq:getY()-1, sq:getY()+1 do
                local sq2 = getCell():getGridSquare(x, y, sq:getZ());
				if sq2 then
                    for i=0,sq2:getMovingObjects():size()-1 do
                        if instanceof(sq2:getMovingObjects():get(i), "IsoPlayer") then
                            clickedPlayer = sq2:getMovingObjects():get(i)
                        end
                    end
                end
            end
        end
        if clickedPlayer then
            context:addOption(getText("IGUI_Show_player_modData"), clickedPlayer, showModdata)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu);
