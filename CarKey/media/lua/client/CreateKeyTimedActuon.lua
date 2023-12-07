require "TimedActions/ISBaseTimedAction"
require "CreateKeyButton"
ISVehicleMechanicsAction = ISBaseTimedAction:derive("ISVehicleMechanicsAction");

function ISVehicleMechanicsAction:isValid()
    return true;
end

function ISVehicleMechanicsAction:update()
end

function ISVehicleMechanicsAction:start()
    if self.Hotwired then
        if self.HotwiredTool or isAdmin() then
            -- Здесь добавьте код анимации ремонта замка зажигания
            self.character:playAnimation("YourRepairAnimation")
        else
            getPlayer():Say(getText('IGUI_HotwiredTool'))
        end
    elseif self.check or isAdmin() then
        -- Здесь добавьте код анимации создания ключей
        self.character:playAnimation("YourKeyCreationAnimation")
    else
        getPlayer():Say(getText('IGUI_NeedKeyKit'))
    end
end

function ISVehicleMechanicsAction:stop()
    ISBaseTimedAction.stop(self);
end

function ISVehicleMechanicsAction:perform()
    if self.Hotwired then
        if self.HotwiredTool or isAdmin() then
            DeleteItemFromHand()
            DeleteHotwired(getPlayer(), self.vehicle)
        else
            getPlayer():Say(getText('IGUI_HotwiredTool'))
        end
    elseif self.check or isAdmin() then
        DeleteItemFromHand()
        local itemKey = self.vehicle:createVehicleKey()
        local NameKey = itemKey:getDisplayName()
        itemKey:setName(NameKey)
        getPlayer():getInventory():AddItem(itemKey)
    else
        getPlayer():Say(getText('IGUI_NeedKeyKit'))
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function ISVehicleMechanicsAction:new(playerNum, vehicle, check, Hotwired, HotwiredTool)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum;
    o.vehicle = vehicle;
    o.check = check;
    o.Hotwired = Hotwired;
    o.HotwiredTool = HotwiredTool;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = 5; -- Максимальное время анимации
    return o;
end
