local commands = {} --Команды приходящие на сервер
commands.writeSeat = function(player, args)    
    local vehicle = getVehicleById(args.vehicleId)
	local modData = vehicle:getModData()['playerLog'] or {}
	local playerIndex
	for i, entry in ipairs(modData) do if entry.name == args.name then playerIndex = i break end end -- Поиск индекса игрока в 'playerLog' по имени
	if playerIndex then 	-- Если игрок найден, обновляем его время и перемещаем его в начало таблицы
        if not args.timeExit then 
		    modData[playerIndex].timeEnter = args.time
            modData[playerIndex].timeExit = "In car"
        else
            modData[playerIndex].timeExit = args.timeExit
        end
		table.insert(modData, 1, table.remove(modData, playerIndex))
	else
		local currentUser = { name = args.name, timeEnter = args.time, timeExit = "In car" }-- Если игрок не найден, создаем новую запись и добавляем ее в начало таблицы
		table.insert(modData, 1, currentUser)
		if #modData > 5 then table.remove(modData, #modData) end -- Если таблица превысила максимальный размер, удаляем последнюю запись
	end
	vehicle:getModData()['playerLog'] = modData
	args.modData = modData
	vehicle:transmitModData()
	sendServerCommand('CItransmitModData', "onSeatCar", args)

    --Старый вариант, просто сохраняющий последние 5 посадок в авто
    -- local vehicle = getVehicleById(args.vehicleId)
    -- if not vehicle:getModData()['playerLog'] then
    --     vehicle:getModData()['playerLog'] = {}
    -- end
    -- local modData = vehicle:getModData()['playerLog']
    -- if #modData >= 5 then
    --     table.remove(modData,1)
    -- end
    -- local currentUser = {name=args.name,time=args.time}
    -- table.insert(modData, currentUser)
    -- vehicle:getModData()['playerLog'] = modData
    -- args.modData = modData
    -- vehicle:transmitModData()
    -- sendServerCommand('CItransmitModData', "onSeatCar", args)
end

local function CISeat_OnClientCommand(module, command, player, args)
    if module == "CISeat" and commands[command] then
        commands[command](player, args)
    end
end
Events.OnClientCommand.Add(CISeat_OnClientCommand)