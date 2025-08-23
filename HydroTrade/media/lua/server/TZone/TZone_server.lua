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

local function sendNotification(enable, title)
    local messageActivate = { message = "IGUI_Notify_TZone_Activate", color = {255, 0, 0} }
    local messageDeactivate = { message = "IGUI_Notify_TZone_Deactivate", color = {0, 255, 0} }
    local title = tostring(title)
    if enable then
        Notify.broadcast(messageActivate.message, { color=messageActivate.color, params={ title=title } })
    else
        Notify.broadcast(messageDeactivate.message, { color=messageDeactivate.color, params={ title=title } })
    end
end

Commands.toggleTZone = function(player, args) -- переключаем состояние зоны
	local title = args[1]
    local wasEnabled = TZone.Data.TZone[title].enable
	TZone.Data.TZone[title].enable = not TZone.Data.TZone[title].enable    
    -- Записываем время активации при включении зоны
	if TZone.Data.TZone[title].enable and not wasEnabled then -- если зона включена и не была включена раньше
		TZone.Data.TZone[title].activatedTime = getGameTime():getWorldAgeHours()
		TZone.Data.TZone[title].deactivatedTime = nil -- Сбрасываем время деактивации
	elseif not TZone.Data.TZone[title].enable and wasEnabled then
		TZone.Data.TZone[title].deactivatedTime = getGameTime():getWorldAgeHours() -- Записываем время деактивации
		TZone.Data.TZone[title].activatedTime = nil -- Сбрасываем время при выключении
	end
    
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

