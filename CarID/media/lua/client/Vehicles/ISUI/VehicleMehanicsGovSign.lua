local old_render = ISVehicleMechanics.render
local old_mehWindows = ISVehicleMechanics.initParts
local vehicleId = nil
local sqlId = "Load"
local receiveServerCommand

function sendcm (vehicleId)    
    local args = args or {}
    args.vehicleId = vehicleId
    --print("args.vehicleId:", args.vehicleId)
    sendClientCommand(getPlayer(), 'CargetSqlId', 'getSqlId', args)
    Events.OnServerCommand.Add(receiveServerCommand)
end

receiveServerCommand = function(module, command, args)
    if module ~= 'CarOutSqlId' then return; end
    if command == 'onGetSql' then
        --print("args:",args.sqlId)
        sqlId = args.sqlId
        Events.OnServerCommand.Remove(receiveServerCommand)            
    end
end


function ISVehicleMechanics:render()    
    local o = old_render(self)   
    if not (vehicleId == self.vehicle:getId()) then
        vehicleId = self.vehicle:getId()
        sendcm (vehicleId)
    else   
        local govSign = getText("IGUI_GovSign") .. sqlId .. " KT" --self.vehicle:getId()
        local govSignWidth = getTextManager():MeasureStringX(UIFont.Small, govSign)
        self:drawText(govSign, self.width - govSignWidth - 20, 120, 1, 1, 1, 1, UIFont.Small);
    end
    return o
end

