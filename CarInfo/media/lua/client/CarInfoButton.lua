local old_ISVehicleMechanicscreateChildren = ISVehicleMechanics.createChildren
local icon = getTexture("media/textures/car_info.png")

function ISVehicleMechanics:createChildren()
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

function ISVehicleMechanics:onClickInfo()
    -- local modData = self.vehicle:getModData()
    -- print("modData:",modData)
    ModDataDebugPanel.OnOpenPanel(self.vehicle)
    getTimestamp()
end

function getTimestamp()
    local time = getTimeInMillis()
    local time = os.date("%d/%m-%H:%M", (time+10800000)/1000)
    return time
end

local function OnEnterVehicleOnModData(player)
    local time = getTimestamp()
    local name = player:getUsername()
    local vehicle = player:getVehicle()
    --local modData = vehicle:getModData()
    if not vehicle:getModData()['playerLog'] then
        vehicle:getModData()['playerLog'] = {}
    end
    local modData = vehicle:getModData()['playerLog']

    --modData.playerLog = modData.playerLog or {}

    if #modData >= 3 then
        table.remove(modData,1)
    end
    local currentUser = {name=name,time=time}
    table.insert(modData, currentUser)

    for i=#modData, 1, -1 do
        print(modData[i].name," ",modData[i].time)
    end
    vehicle:getModData()['playerLog'] = modData
    vehicle:transmitModData()
end
Events.OnEnterVehicle.Add(OnEnterVehicleOnModData)