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

    -- local vehicleId, xDif, yDif = unpack(args)
    -- local vehicle = getVehicleById(vehicleId)

    -- local field_count = getNumClassFields(vehicle)
    -- local transform_field = nil
    -- -- local tempTransform_fieldName = 'private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform'
    -- local jniTransform_fieldName = 'public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform'
    -- for i=0, field_count-1 do
    --     local field = getClassField(vehicle, i)
    --     if tostring(field) == jniTransform_fieldName then
    --         print('found!')
    --         transform_field = field
    --     end
    -- end

    -- if transform_field then
    --     local v_transform = getClassFieldVal(vehicle, transform_field)
    --     print('v_transform: ', v_transform)
    --     local w_transform = vehicle:getWorldTransform(v_transform)
    --     print('w_transform: ', w_transform)
    --     local origin_field = getClassField(w_transform, 1)
    --     local origin = getClassFieldVal(w_transform, origin_field)
    --     print('oX, oY', oX, oY)
    --     print('origin', origin:x(), origin:y(), origin:z())
    --     origin:set(origin:x()-xDif, origin:y(), origin:z()-yDif)
    --     vehicle:setWorldTransform(w_transform)
    -- else
    --     print('transform_field not found')
    -- end

    -- vehicle:updatePhysics()
    -- vehicle:updatePhysicsNetwork()
    -- -- if isClient() then
    -- --     vehicle
    -- -- end
end


-- ---@param player IsoPlayer
-- ---@param args getCarListArgs
-- Commands.getCarList = function(player, args)
--     local startPos, endPos, zPos = unpack(args)
--     print('server getCarList startPos, endPos, zPos ', startPos, endPos, zPos)
--     -- local startPos, endPos = args['startPos']
--     -- local endPos = args['endPos']
--     -- local zPos = args['zPos']
--     local world = getWorld();
--     local cell = world:getCell();
--     -- local vehiclesArr = cell:getVehicles()
--     local x1 = math.min(startPos.x, endPos.x)
--     local x2 = math.max(startPos.x, endPos.x)
--     local y1 = math.min(startPos.y, endPos.y)
--     local y2 = math.max(startPos.y, endPos.y)
--     local uniqueList = {}
--     for x = x1, x2 do
--         for y = y1, y2 do
--             local sq = cell:getGridSquare(x, y, zPos)
--             print('sq', sq)
--             local vehicleObj = sq:getVehicleContainer()
--             if vehicleObj then
--                 uniqueList[vehicleObj:getId()] = vehicleObj
--             end
--         end
--     end
--     local resultList = {}
--     for k,vehicle in pairs(uniqueList) do
--         local carName = getText("IGUI_VehicleName" .. vehicle:getScript():getName())
--         print('shared moveCar list: ', carName..' | sqlId: '..vehicle:getSqlId()..', vehicleId: '..vehicle:getId()..', keyId: '..vehicle:getKeyId())
--         table.insert(resultList, vehicle)
--     end

--     return resultList
-- end

local OnClientCommand = function(module, command, player, args)
	if module == MOD_NAME and Commands[command] then
		Commands[command](player, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)