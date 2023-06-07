require "TimedActions/ISBaseTimedAction"

AutoGateAction = ISBaseTimedAction:derive("AutoGateAction")

function AutoGateAction:isValid()
	return true
end

function AutoGateAction:update()
	local uispeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    if uispeed ~= 1 then
        UIManager.getSpeedControls():SetCurrentGameSpeed(1)
    end
end

function AutoGateAction:start()
    local pos = self.obj:getFacingPosition(self.character:getPlayerMoveDir())
    if not self.obj:getNorth() then
        self.character:facePosition(pos:getX(), pos:getY()+1)
    else
        self.character:facePosition(pos:getX()+1, pos:getY())
    end
    local inv = self.character:getInventory()
    local torch = inv:FindAndReturn("BlowTorch")
    local mask = inv:FindAndReturn("WeldingMask")
    if torch and mask then
        self.character:setPrimaryHandItem(torch)
        self.character:setClothingItem_Head(mask)
        self:setOverrideHandModels(torch, nil)
    end
    self:setActionAnim("BlowTorch")
    --self.character:getEmitter():playSound("BlowTorch")
end

function AutoGateAction:stop()
	ISBaseTimedAction.stop(self)
end

function AutoGateAction:perform()
        
    local inv = self.character:getInventory()
    inv:Remove(inv:FindAndReturn("GateComponents"))
    ISBaseTimedAction.perform(self)
    local args = {x = self.obj:getX(), y = self.obj:getY(), z = self.obj:getZ()}
    if isClient() then
        sendClientCommand("AutoGate", "install", args)
    else
        AutoGate.Utils.InstallGate(args)
    end
    self.character:Say("Done! I need a controller to pair.")
end 

function AutoGateAction:new(character, obj)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    o.character = character
    o.gate = AutoGate.Utils.GetFullGate(obj)
    o.obj = obj
	o.maxTime = 300
	return o
end





