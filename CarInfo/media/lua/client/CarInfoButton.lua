---@diagnostic disable: duplicate-set-field
local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_info.png")

function ISVehicleMechanics:createChildren() -- Переопределение стандартной функции отрисовки интерфейса и добавление кнопки, если игрок-админ
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

function ISVehicleMechanics:onClickInfo() --Событие по нажатию кнопки "Информация"
    ModDataDebugPanel.OnOpenPanel(self.vehicle)
end

local function getTimestamp() --Блок расчета текущего времени
    local time = getTimeInMillis()
    local time = os.date("%H:%M  %d.%m", (time+10800000)/1000)
    return time
end

local vehicle 
--Отслеживания последних садившихся игроков
local function OnEnterVehicleOnModData(player)
    if isAdmin then print("Exit, admin"); return end
    -- print("No admin")
    local args = {}    
    local time = getTimestamp()
    local name = player:getUsername()
    vehicle = player:getVehicle()
    args.time = time
    args.name = name
    args.vehicleId = vehicle:getId()
    sendClientCommand(getPlayer(), 'CISeat', 'writeSeat', args)
end
Events.OnEnterVehicle.Add(OnEnterVehicleOnModData)

--Отслеживания последних выходивших игроков
local function OnExitVehicleOnModData(player)
    if isAdmin then return end
    local args = {}    
    local time = getTimestamp()
    local name = player:getUsername()
    args.timeExit = time
    args.name = name
    args.vehicleId = vehicle:getId()
    sendClientCommand(getPlayer(), 'CISeat', 'writeSeat', args)
end
Events.OnExitVehicle.Add(OnExitVehicleOnModData)

--------------------Получение моддаты-------------------
local receiveServerCommand
receiveServerCommand = function(module, command, args)
    if module ~= 'CItransmitModData' then return; end
    if command == 'onSeatCar' then
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle then return end
        vehicle:getModData()['playerLog'] = args.modData
    end
end
Events.OnServerCommand.Add(receiveServerCommand)