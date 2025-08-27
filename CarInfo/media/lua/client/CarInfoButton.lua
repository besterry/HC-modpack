---@diagnostic disable: duplicate-set-field
local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_info.png")

function ISVehicleMechanics:createChildren()
    local o = old_ISVehicleMechanicscreateChildren(self)
    if isAdmin() then
        self.IconInfo = ISButton:new(5, 20, 25, 25, "", self, ISVehicleMechanics.onClickInfo)
        self.IconInfo.internal = "CARINFO"
        self.IconInfo:setImage(icon)
        self.IconInfo:setDisplayBackground(false)
        self.IconInfo.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
        self:addChild(self.IconInfo);
    end
    return o
end

function ISVehicleMechanics:onClickInfo()
    ModDataDebugPanel.OnOpenPanel(self.vehicle)
end
local currentVehicleId = nil
-- Улучшенное отслеживание игроков
local function OnEnterVehicleOnModData(player)
    if isAdmin() then return end
    
    local vehicle = player:getVehicle()
    if not vehicle then return end
    
    local args = {}    
    local name = player:getUsername()
    currentVehicleId = vehicle:getId()
    args.name = name
    args.vehicleId = currentVehicleId
    args.action = "enter"
    args.enterX = math.floor(player:getX())
    args.enterY = math.floor(player:getY())
    
    sendClientCommand(getPlayer(), 'CISeat', 'writeSeat', args)
end

local function OnExitVehicleOnModData(player)
    if isAdmin() then return end
    
    local name = player:getUsername()
    local vehicle = player:getVehicle()
    local vehicleId = nil
    if not vehicle then
        vehicleId = currentVehicleId
    else
        vehicleId = vehicle:getId()
    end
    -- Проверяем, есть ли сохраненный ID машины
    if not vehicleId then return end
    
    local args = {}    

    args.name = name
    args.vehicleId = vehicleId
    args.action = "exit"
    args.exitX = math.floor(player:getX())
    args.exitY = math.floor(player:getY())
    
    sendClientCommand(getPlayer(), 'CISeat', 'writeSeat', args)
end

Events.OnEnterVehicle.Add(OnEnterVehicleOnModData)
Events.OnExitVehicle.Add(OnExitVehicleOnModData)

-- Получение моддаты
local function receiveServerCommand(module, command, args)
    if module ~= 'CItransmitModData' then return end
    if command == 'onSeatCar' then
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle then return end
        vehicle:getModData()['playerLog'] = args.modData
    end
end
Events.OnServerCommand.Add(receiveServerCommand)