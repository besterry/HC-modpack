local receiveServerCommand
local sendMessage = false

local function sendcm (vehicleId)
    local args = args or {}
    args.vehicleId = vehicleId
    sendClientCommand(getPlayer(), 'CargetSqlId', 'getSqlId', args)
end

receiveServerCommand = function(module, command, args)
    if module ~= 'CarOutSqlId' then return; end
    if command == 'onGetSql' then
        sendMessage = false
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle then return end
        vehicle:getModData().sqlId = args.sqlId
        --print("Load sql on server")        
    end
end
Events.OnServerCommand.Add(receiveServerCommand)

local old_render = ISVehicleMechanics.render
---@diagnostic disable-next-line: duplicate-set-field
function ISVehicleMechanics:render()
    local o = old_render(self)
    local register = self.vehicle:getModData().register
    if not self.vehicle:getModData().sqlId and not sendMessage then
        sendcm(self.vehicle:getId())
        sendMessage = true
    end

    self.sqlId = self.vehicle:getModData().sqlId or "Load"    
    local govSign = getText("IGUI_GovSign") .. self.sqlId .. " KT"        
    local govSignWidth = getTextManager():MeasureStringX(UIFont.Small, govSign)
    self:drawText(govSign, self.width - govSignWidth - 20, 120, 1, 1, 1, 1, UIFont.Small);
    local registerText
    if  register then
        registerText = getText("IGUI_CheckRegister") .. register
        self:drawText(registerText, self.width - govSignWidth - 200, 120, 1, 1, 1, 1, UIFont.Small);
    end

    -- Противоугонная сигнализация
    local antiTheft = self.vehicle:getModData().antiTheft
    if antiTheft and antiTheft.installed then
        local alarmLevel1Icon = getTexture("media/textures/AlarmSystem1.png")
        local alarmLevel2Icon = getTexture("media/textures/AlarmSystem2.png")
        local alarmLevel3Icon = getTexture("media/textures/AlarmSystem3.png")
        local alarmLevel4Icon = getTexture("media/textures/AlarmSystem4.png")
        local iconX = 10  -- Позиция слева
        local iconY = self.height - 40  -- Позиция снизу
        local iconToDraw = alarmLevel1Icon  -- По умолчанию уровень 1
    
        if antiTheft.level == 2 and alarmLevel2Icon then
            iconToDraw = alarmLevel2Icon
        elseif antiTheft.level == 3 and alarmLevel3Icon then
            iconToDraw = alarmLevel3Icon
        elseif antiTheft.level == 4 and alarmLevel4Icon then
            iconToDraw = alarmLevel4Icon
        end        
        if iconToDraw then
            self:drawTextureScaled(iconToDraw, iconX, iconY, 25, 25, 1, 1, 1, 1);
        end
    end
    
    return o
end