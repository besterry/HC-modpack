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
    if not self.vehicle:getModData().sqlId and not sendMessage then
        sendcm(self.vehicle:getId())
        sendMessage = true
    end

    self.sqlId = self.vehicle:getModData().sqlId or "Load"    
    local govSign = getText("IGUI_GovSign") .. self.sqlId .. " KT"        
    local govSignWidth = getTextManager():MeasureStringX(UIFont.Small, govSign)
    self:drawText(govSign, self.width - govSignWidth - 20, 120, 1, 1, 1, 1, UIFont.Small);
    return o
end