---@diagnostic disable: param-type-mismatch
local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_keykit.png")
local check = false
local Hotwired = false
local HotwiredTool = false
-- player:getInventory():Remove("Base.SprayPaint") -- удаление предмета

---@diagnostic disable-next-line: duplicate-set-field
function ISVehicleMechanics:createChildren()
    local o = old_ISVehicleMechanicscreateChildren(self)
    self.paintigIcon = ISButton:new(self.width-30, 65, 30, 30, "", self, ISVehicleMechanics.onClickKey)
    self.paintigIcon.internal = "CREATEKEY"
    self.paintigIcon:setImage(icon)
    self.paintigIcon:setDisplayBackground(false)
    self.paintigIcon.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self:addChild(self.paintigIcon);
    return o
end

local function CheckInventory()
    local item1 = getPlayer():getPrimaryHandItem()-- получаем предмет в правой руке игрока
    local item2 = getPlayer():getSecondaryHandItem() -- получаем предмет в левой руке игрока
    if (item1 and item1:getFullType()  == "Base.KeyKit") or (item2 and item2:getFullType()  == "Base.KeyKit") then
        check = true
    else
        check = false
    end
    if (item1 and item1:getFullType()  == "Base.HotwiredKit") or (item2 and item2:getFullType()  == "Base.HotwiredKit") then
        HotwiredTool = true
    else
        HotwiredTool = false
    end
end

local function DeleteItem()
    local item1 = getPlayer():getPrimaryHandItem()-- получаем предмет в правой руке игрока
    local item2 = getPlayer():getSecondaryHandItem() -- получаем предмет в левой руке игрока
    if (item1 and item1:getFullType() == "Base.KeyKit") or (item2 and item2:getFullType() == "Base.KeyKit") or isAdmin() then
		if item1 and item1:getFullType()  == "Base.KeyKit" then
			getPlayer():getPrimaryHandItem():Use()
			getPlayer():getInventory():Remove(item1)
        end
		if item2 and item2:getFullType()  == "Base.KeyKit" then
			getPlayer():getSecondaryHandItem():Use()
			getPlayer():getInventory():Remove(item2)
        end
    end
    if (item1 and item1:getFullType() == "Base.HotwiredKit") or (item2 and item2:getFullType() == "Base.HotwiredKit") or isAdmin() then
		if item1 and item1:getFullType()  == "Base.HotwiredKit" then
			getPlayer():getPrimaryHandItem():Use()
			getPlayer():getInventory():Remove(item1)
        end
		if item2 and item2:getFullType()  == "Base.HotwiredKit" then
			getPlayer():getSecondaryHandItem():Use()
			getPlayer():getInventory():Remove(item2)
        end
    end
end

local old_render = ISVehicleMechanics.render
---@diagnostic disable-next-line: duplicate-set-field
function ISVehicleMechanics:render()
    local o = old_render(self)
    CheckInventory()
    if self.vehicle:isHotwired() then
        Hotwired = true
    else
        Hotwired = false
    end
    return o
end

function ISVehicleMechanics:onClickKey()
	if Hotwired then
        if HotwiredTool or isAdmin() then
            --ISVehicleMechanics.onCheatHotwire(playerObj, self.vehicle, false, false)
            DeleteItem()
            DeleteHotwired(getPlayer(), self.vehicle)
        else
            getPlayer():Say(getText('IGUI_HotwiredTool'))
        end
    elseif check or isAdmin() then
        DeleteItem()
        local itemKey = self.vehicle:createVehicleKey()
        local NameKey = itemKey:getDisplayName() --.. " " .. self.sqlId
        itemKey:setName(NameKey)
        getPlayer():getInventory():AddItem(itemKey)
        --ISVehicleMechanics.onCheatGetKey(playerObj, self.vehicle)         
        --print("Item key:", item," KeyID:",item:getKeyId()," Number:",item:getNumberOfKey()," getSaveType():", item:getSaveType())
    else
        getPlayer():Say(getText('IGUI_NeedKeyKit'))
    end
end

--self.context:addOption("CHEAT: Hotwire", playerObj, ISVehicleMechanics.onCheatHotwire, self.vehicle, true, false)
function DeleteHotwired(playerObj, vehicle)
    local hotwired = false
    local broken = false
    sendClientCommand(playerObj, "vehicle", "cheatHotwire", { vehicle = vehicle:getId(), hotwired = hotwired, broken = broken})
end