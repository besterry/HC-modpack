if isClient() then return end

local CarTeleport = ETOMARAT.CarTeleport
local MOD_NAME = CarTeleport.MOD_NAME

local Commands = {}
local CacheMap = {}

---@param player IsoPlayer
---@param vehicleIdList integer[]
Commands.saveCars = function(player, vehicleIdList)
    local username = player:getUsername()
    local vehicleList = {}
    for k,vehicleId in pairs(vehicleIdList) do
        table.insert(vehicleList, getVehicleById(vehicleId))
    end
    CacheMap[username] = vehicleList
end

---@param player IsoPlayer
---@param args moveCarArgs
Commands.moveCar = function(player, args)
    print('server moveCar')
    local xDif, yDif = unpack(args)
    local username = player:getUsername()
    local vehicleList = CacheMap[username]
    for k,vehicle in pairs(vehicleList) do
        CarTeleport.moveCar(player, vehicle, xDif, yDif)
    end
    sendServerCommand(MOD_NAME, 'moveCar', args)
end

local OnClientCommand = function(module, command, player, args)
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)