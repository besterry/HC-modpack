require "TimedActions/ISBaseTimedAction"

function ISRemoveBrokenGlass:perform()
    self.window:removeBrokenGlass()
    self.character:getInventory():AddItem("LabItems.MatShatteredGlass")
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISPickupBrokenGlass:perform()
    -- add random damage to hands if no gloves (done in pickUpMoveable)
    if ISMoveableTools.isObjectMoveable(self.glass) then        
        -- local moveable = ISMoveableTools.isObjectMoveable(self.glass)
        -- moveable:pickUpMoveable( self.character, self.square, self.glass, true )
        self.glass:removeFromWorld()
        triggerEvent("OnObjectAboutToBeRemoved", self.glass)
        self.glass:getSquare():transmitRemoveItemFromSquare(self.glass)
        self.character:getInventory():AddItem("LabItems.MatShatteredGlass")
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end