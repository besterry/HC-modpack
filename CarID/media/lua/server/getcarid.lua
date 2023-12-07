local commands = {} --Команды приходящие на сервер
commands.getSqlId = function(player, args)
    local vehicle = getVehicleById(args.vehicleId)
    local sqlId = vehicle:getSqlId()
    local args = args or {}
    args.sqlId = sqlId
    args.vehicleId = args.vehicleId
    if not vehicle:getModData().sqlId or vehicle:getModData().sqlId == nil then
        vehicle:getModData().sqlId=sqlId
        vehicle:transmitModData()
        --print("Send new sqlid")
    end     
    sendServerCommand('CarOutSqlId', "onGetSql", args)
end


local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "CargetSqlId" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)