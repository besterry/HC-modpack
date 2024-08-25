local function showModdata(obj)
    if not isAdmin() then return; end
    local moddata = obj:getModData()
    ItemModDataPanel.OnOpenPanel(obj)
end

local function ContextMenu(player, context, worldobjects, test)
    if not isAdmin() then return; end
	local sq = nil
    local addedObjects = {}  -- Таблица для отслеживания уже добавленных объектов

    for i,v in ipairs(worldobjects) do
        local square = v:getSquare();
        if square and sq == nil then
            sq = square
        end
        if v:hasModData() then --instanceof(v, "IsoObject") and
            local objectIndex = v:getObjectIndex()
            if not addedObjects[objectIndex] then --Исключаем дубли
                addedObjects[objectIndex] = true
                -- print(v:getObjectIndex())
                -- getTextureName playershop_0
                --getSpriteName nil
                --getScriptName None
                --getObjectName возвращает IsoObject, Trumpable
                local text = v:getTextureName() or v:getSpriteName() or v:getScriptName() or v:getName() or "No name"
                context:addOption(getText("IGUI_Show_IsoObject_modData").. " "..text, v, showModdata)
            end
        end
    end

    if sq ~= nil then
        -- Для пола отключено, т.к. пол является isoObject и определяется в функции выше
        -- local floor = sq:getFloor() -- Получаем объект пола на текущем квадрате
        -- if floor and floor:hasModData() then
        --     local text = floor:getTextureName() or floor:getSpriteName() or floor:getScriptName() or "Wooden Floor"
        --     context:addOption(getText("IGUI_Show_Floor_modData")..text, floor, showModdata)
        -- end

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
            context:addOption(getText("IGUI_Show_player_modData") .. " " .. clickedPlayer:getUsername(), clickedPlayer, showModdata)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(ContextMenu);
