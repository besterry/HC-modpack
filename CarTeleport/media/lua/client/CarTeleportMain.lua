---@class position
---@field x number
---@field y number



---@param startPos position
---@param endPos position
---@param zPos number
---@return BaseVehicle[]
local getCarsListByCoord = function(startPos, endPos, zPos)
    print('getCarsListByCoord', bcUtils.dump(startPos), bcUtils.dump(endPos))
    local cell = getCell()
    local vehiclesArr = cell:getVehicles()
    local x1 = math.min(startPos.x, endPos.x)
    local x2 = math.max(startPos.x, endPos.x)
    local y1 = math.min(startPos.y, endPos.y)
    local y2 = math.max(startPos.y, endPos.y)
    local resultList = {}
    for x = x1, x2 do
        for y = y1, y2 do
            for i = 0, vehiclesArr:size() - 1 do
                local vehicle = vehiclesArr:get(i)
                if vehicle:isIntersectingSquare(x, y, zPos) then
                    table.insert(resultList, vehicle)
                end
            end
            -- local sq = cell:getGridSquare(x, y, zPos)
            -- -- getCell():getVehicles()
            -- -- BaseVehicle:isIntersectingSquare(x, y, z)
            -- if self.itemType:isSelected(1) then
            --     for i=0, sq:getObjects():size()-1 do
            --         if instanceof(sq:getObjects():get(i), "IsoWorldInventoryObject") then
            --             local item = sq:getObjects():get(i)
            --             table.insert(itemBuffer, { it = item, square = sq })
            --         end
            --     end
            -- elseif self.itemType:isSelected(2) then
            --     for i=0, sq:getStaticMovingObjects():size()-1 do
            --         if instanceof(sq:getStaticMovingObjects():get(i), "IsoDeadBody") then
            --             local item = sq:getStaticMovingObjects():get(i)
            --             table.insert(itemBuffer, { it = item, square = sq })
            --         end
            --     end
            -- end
        end
    end
    -- for i, itemData in ipairs(itemBuffer) do
    --     local sq = itemData.square
    --     local item = itemData.it
    --     if self.itemType:isSelected(1) then
    --         sq:transmitRemoveItemFromSquare(item);
    --         item:removeFromWorld()
    --         item:removeFromSquare()
    --         item:setSquare(nil)
    --     elseif self.itemType:isSelected(2) then
    --         sq:removeCorpse(item, false);
    --     end
    -- end
    return resultList
end

local export = {
    getCarsListByCoord = getCarsListByCoord
}

return export


