local commands = {} --Команды приходящие на сервер
commands.writeSeat = function(player, args)
    local vehicle = getVehicleById(args.vehicleId)
    if not vehicle:getModData()['playerLog'] then
        vehicle:getModData()['playerLog'] = {}
    end
    local modData = vehicle:getModData()['playerLog']
    if #modData >= 5 then
        table.remove(modData,1)
    end
    local currentUser = {name=args.name,time=args.time}
    table.insert(modData, currentUser)
    vehicle:getModData()['playerLog'] = modData
    args.modData = modData
    vehicle:transmitModData()
    sendServerCommand('CItransmitModData', "onSeatCar", args)
end

local function CISeat_OnClientCommand(module, command, player, args)
    if module == "CISeat" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(CISeat_OnClientCommand)