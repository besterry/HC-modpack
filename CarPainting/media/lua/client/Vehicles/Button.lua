local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_paint.png")
local iconoff = getTexture("media/textures/car_paint_off.png")
local check = false

function ISVehicleMechanics:createChildren()
    local o = old_ISVehicleMechanicscreateChildren(self)  
    self.paintigIcon = ISButton:new(self.width-28-15, 30, 35, 35, "", self, ISVehicleMechanics.onClick)
    self.paintigIcon.internal = "PAINTCAR"
    self.paintigIcon:setImage(icon)
    self.paintigIcon:setDisplayBackground(false)
    self.paintigIcon.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self:addChild(self.paintigIcon);
    return o
end

function CheckInventory()
    local item1 = getPlayer():getPrimaryHandItem()-- получаем предмет в правой руке игрока
    local item2 = getPlayer():getSecondaryHandItem() -- получаем предмет в левой руке игрока
    if (item1 and item1:getFullType()  == "Base.SprayPaint") or (item2 and item2:getFullType()  == "Base.SprayPaint") then 
        check = true 
    else 
        check = false 
    end
    -- player:getInventory():Remove("Base.SprayPaint") -- удаляем предмет
end

local old_render = ISVehicleMechanics.render
function ISVehicleMechanics:render()    
    local o = old_render(self)  
    CheckInventory()
    if check then
        self.paintigIcon:setImage(icon)
    else
        self.paintigIcon:setImage(iconoff)
    end
    return o
end

function ISVehicleMechanics:onClick()
	if check or isAdmin() then
        Create(self.vehicle)
    else
        getPlayer():Say(getText('IGUI_NeedPaint'))
    end
end

local ui = nil
function Create(vehicle)
    ui = ui or VehicleHSV:new(getPlayer())
	ui:setVisible(true)
	ui:addToUIManager()
	ui:setVehicle(vehicle or getSpecificPlayer(0):getVehicle())
end