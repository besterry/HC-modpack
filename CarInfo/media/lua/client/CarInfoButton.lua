local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_info.png")

function ISVehicleMechanics:createChildren() -- Переопределение стандартной функции отрисовки интерфейса и добавление кнопки, если игрок-админ
    local o = old_ISVehicleMechanicscreateChildren(self)
    if isAdmin() then
        self.IconInfo = ISButton:new(5, 20, 25, 25, "", self, ISVehicleMechanics.onClickInfo)
        self.IconInfo.internal = "CARINFO"
        self.IconInfo:setImage(icon)
        --self.IconInfo:setDisplayBackground(false)
        self.IconInfo.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
        self:addChild(self.IconInfo);
    end
    return o
end

function ISVehicleMechanics:onClickInfo() --Событие по нажатию кнопки информация
    -- local modData = self.vehicle:getModData()
    -- print("modData:",modData)
    ModDataDebugPanel.OnOpenPanel(self.vehicle)
    --getTimestamp()
end

function getTimestamp() --Блок расчета текущего времени
    local time = getTimeInMillis()
    local time = os.date("%d/%m-%H:%M", (time+10800000)/1000)
    return time
end

local function OnEnterVehicleOnModData(player) --Блок отслеживания последних садившихся игроков
    local args = {}    
    local time = getTimestamp()
    local name = player:getUsername()
    local vehicle = player:getVehicle()

    -----Блок отправки изменения моддаты на сервере-----
    args.time = time
    args.name = name
    args.vehicleId = vehicle:getId()
    sendClientCommand(getPlayer(), 'CISeat', 'writeSeat', args)
    ----------------------------------------------------
end
Events.OnEnterVehicle.Add(OnEnterVehicleOnModData)

--------------------Получение------------------
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