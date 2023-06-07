NFHotkeys = NFHotkeys or {}

function NFHotkeys.toggleMovable()
    local player = getPlayer()
    local playerNum = player:getPlayerNum()
    local cursor
    if getCell():getDrag(playerNum) and getCell():getDrag(playerNum).isMoveableCursor then
        cursor = getCell():getDrag(playerNum)
    end
    if not cursor then
        cursor = ISMoveableCursor:new(player)
        getCell():setDrag(cursor, cursor.player)
        cursor:setMoveableMode("pickup")
    else
        if cursor:getMoveableMode() == "pickup" then
            cursor:exitCursor()
        end
    end
end