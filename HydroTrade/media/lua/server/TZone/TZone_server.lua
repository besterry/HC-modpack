local MOD_NAME = "TZone"

TZone = TZone or {}
TZone.Data = TZone.Data or {}
TZone.Data.TZone = TZone.Data.TZone or {}

local Commands = {}
Commands.addTZone = function(player, args) -- добавляем зону
	local title, x, y, x2, y2 = args[1], args[2], args[3], args[4], args[5]
    TZone.Data.TZone[title] = {x = x, y = y, x2 = x2, y2 = y2, enable = false} -- По умолчанию зона выключена
    ModData.add(MOD_NAME, TZone.Data.TZone) -- добавляем зону в ModData
    ModData.transmit(MOD_NAME) -- отправляем зону всем клиентам
end

Commands.removeTZone = function(player, args) -- удаляем зону
	local title = args[1]
    TZone.Data.TZone[title] = nil
    ModData.add(MOD_NAME, TZone.Data.TZone) 
    ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "onRemoveTZone", args) -- пришлось добавить этот костыль, иначе не работает (моддата трансмитится не сразу)
end

local function sendNotification( enable, title)
	local messageActivate = { message = "IGUI_Notify_TZone_Activate", color = {255, 0, 0} } -- красный
	local messageDeactivate = { message = "IGUI_Notify_TZone_Deactivate", color = {0, 255, 0} } -- зелёный
	if enable then
		Notify.broadcast(messageActivate.message .. " " .. title, { color=messageActivate.color })
	else
		Notify.broadcast(messageDeactivate.message .. " " .. title, { color=messageDeactivate.color })
	end
end

Commands.toggleTZone = function(player, args) -- переключаем состояние зоны
	local title = args[1]
	TZone.Data.TZone[title].enable = not TZone.Data.TZone[title].enable
	sendNotification(TZone.Data.TZone[title].enable, title)
	ModData.add(MOD_NAME, TZone.Data.TZone)
	ModData.transmit(MOD_NAME)
	sendServerCommand(MOD_NAME, "onToggleTZone", args) -- пришлось добавить этот костыль, иначе не работает (моддата трансмитится не сразу)
end

local OnClientCommand = function(module, command, player, args) 
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end
Events.OnClientCommand.Add(OnClientCommand)


local function initGlobalModData(isNewGame)
    TZone.Data.TZone = ModData.getOrCreate(MOD_NAME);
	ModData.transmit(MOD_NAME)
end
Events.OnInitGlobalModData.Add(initGlobalModData); -- инициализация моддата при загрузке сервера

