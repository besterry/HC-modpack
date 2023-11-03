local commands = {} --Команды приходящие на сервер
commands.getSqlId = function(player, args)
    local vehicle = getVehicleById(args.vehicleId)
    local sqlId = vehicle:getSqlId()
    local args = args or {}
    args.sqlId = sqlId
    --print("sqlid:", args.sqlId)
    sendServerCommand('CarOutSqlId', "onGetSql", args)
end


local function CargetSqlId_OnClientCommand(module, command, player, args)
    if module == "CargetSqlId" and commands[command] then
        commands[command](player, args)
    end
end

Events.OnClientCommand.Add(CargetSqlId_OnClientCommand)