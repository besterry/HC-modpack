--***********************************************************
--**                       BitBraven                       **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISBikesTimedAction = ISBaseTimedAction:derive("BikesTimeAction")

ISBikesTimedAction.isValid = function(self)
    return true
end

ISBikesTimedAction.update = function(self)

end

ISBikesTimedAction.start = function(self)
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition", "Low")

    if self.typeTimeAction == "lift" then
        BravensUtils.TryPlaySoundClip(self.character, "BikeHandle")
    end
end

ISBikesTimedAction.stop = function(self)
    ISBaseTimedAction.stop(self)

    if self.typeTimeAction == "lift" then
        BravensUtils.TryStopSoundClip(self.character, "BikeHandle")
    end
end

ISBikesTimedAction.perform = function(self)

    if self.typeTimeAction == "pickUp" then

        local inventory = self.character:getInventory()
        local newFrame = inventory:AddItem(self.frameName)

        newFrame:getModData().frameColor = self.vehicle:getSkinIndex(); -- Цвет рамы
        newFrame:getModData().rustAmount = self.vehicle:getRust(); -- Ржавчина
        -- newFrame:getModData().modData = self.vehicle:getModData(); -- Мод данные
        -- Копируем все данные из modData, кроме frameColor и rustAmount и sqlid
        local frameModData = newFrame:getModData()
        for key, value in pairs(self.vehicle:getModData()) do
            if key ~= "frameColor" and key ~= "rustAmount" and key ~= "sqlid" then
                frameModData[key] = value
            end
        end

        BravensBikeUtils.addPartsWithCondition(self.vehicle, inventory, self.character)

        if isClient() then
            sendClientCommand(self.character, "vehicle", "remove", { vehicle = self.vehicle:getId() })
        else
            self.vehicle:permanentlyRemove()
        end

        BravensUtils.TirePlayer(self.character, 0.25)
        BravensUtils.TryPlaySoundClip(self.character, "BikeHandle")
    end
    
    if self.typeTimeAction == "place" then

        local inventory = self.character:getInventory()
        -- local framecolor = self.item:getModData().frameColor or 0 -- Цвет рамы
        -- local rustAmount = self.item:getModData().rustAmount or 0 -- Ржавчина
        -- local modData = self.item:getModData() or {} -- Мод данные
        inventory:Remove(self.item)
        BikeClient.SpawnBike(self.vehicleName, self.item)
        BravensUtils.TirePlayer(self.character, 0.25)
    end

    if self.typeTimeAction == "lift" then
        BikeServer.LiftBike(self.vehicle, self.character)
    end

    if self.typeTimeAction == "lockUnlock" then

        local args = { vehicle = self.vehicle:getId(), part = self.door:getId(), locked = self.lock }
        sendClientCommand(self.character, 'vehicle', 'setDoorLocked', args)
    
        if self.lock == true then
            self.inventory:AddItem("BicycleLockKey")
            self.inventory:Remove(self.inventory:getItemFromType("BicycleLock"))
        else
            self.inventory:Remove(self.inventory:getItemFromType("BicycleLockKey"))
            self.inventory:AddItem("BicycleLock")
        end
    
        BravensUtils.TryPlaySoundClip(self.character, "BicycleChain")
    end

    ISBaseTimedAction.perform(self)
end

ISBikesTimedAction.PickUpAction = function(self, character, vehicle, time, frameName)
    
    local action = ISBaseTimedAction.new(self, character);
    action.typeTimeAction = "pickUp"
    action.vehicle = vehicle
    action.stopOnWalk = true
    action.stopOnRun = true
    action.maxTime = time
    action.fromHotbar = false
    action.frameName = frameName
    if action.character:isTimedActionInstant() then action.maxTime = 1; end
    return action
end

ISBikesTimedAction.PlaceAction = function(self, character, item, time, vehicleName)

    local action = ISBaseTimedAction.new(self, character)
    action.typeTimeAction = "place"
    action.item = item
    action.stopOnWalk = true
    action.stopOnRun = true
    action.maxTime = time
    action.fromHotbar = false
    action.vehicleName = vehicleName

    if action.character:isTimedActionInstant() then action.maxTime = 1; end
    return action
end

ISBikesTimedAction.LiftAction = function(self, character, vehicle, time)

    local action = ISBaseTimedAction.new(self, character)
    action.typeTimeAction = "lift"
    action.vehicle = vehicle
    action.stopOnWalk = true
    action.stopOnRun = true
    action.maxTime = time
    action.fromHotbar = false

    if action.character:isTimedActionInstant() then action.maxTime = 1; end
    return action
end

ISBikesTimedAction.LockUnlock = function(self, character, inventory, vehicle, door, lock, time)

    local action = ISBaseTimedAction.new(self, character)
    action.typeTimeAction = "lockUnlock"
    action.character = character
    action.vehicle = vehicle
    action.inventory = inventory
    action.vehicle = vehicle
    action.door = door
    action.lock = lock
    action.stopOnWalk = true
    action.stopOnRun = true
    action.maxTime = time
    action.fromHotbar = false

    if action.character:isTimedActionInstant() then action.maxTime = 1; end
    return action
end

return TimeAction