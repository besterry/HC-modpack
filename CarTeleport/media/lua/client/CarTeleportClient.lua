local CarTeleport = ETOMARAT.CarTeleport
local MOD_NAME = CarTeleport.MOD_NAME

local Commands = {}
local CacheMap = {}

---@param startPos position
---@param endPos position
---@param zPos number
---@return BaseVehicle[]
local getCarsListByCoord = function(startPos, endPos, zPos)
    local cell = getCell()
    -- local vehiclesArr = cell:getVehicles()
    local x1 = math.min(startPos.x, endPos.x)
    local x2 = math.max(startPos.x, endPos.x)
    local y1 = math.min(startPos.y, endPos.y)
    local y2 = math.max(startPos.y, endPos.y)
    local uniqueList = {}
    for x = x1, x2 do
        for y = y1, y2 do
            local sq = cell:getGridSquare(x, y, zPos)
            local vehicleObj = sq:getVehicleContainer()
            if vehicleObj then
                uniqueList[vehicleObj:getId()] = vehicleObj
            end
        end
    end
    local resultList = {}
    for k,v in pairs(uniqueList) do
        table.insert(resultList, v)
    end

    return resultList
end

---@param vehicleList BaseVehicle[]
local removeCars = function(vehicleList)
    for k,v in pairs(vehicleList) do
        if not isAdmin() then
            print('NOT ADMIN') -- TODO: return
        end
        sendClientCommand('vehicle', 'remove', {vehicle = v:getId()})
    end
end

---@param vehicleList BaseVehicle[]
local startMove = function(vehicleList)
    local player = getPlayer()
    local username = player:getUsername()
    CacheMap[username] = vehicleList
    local vehicleIdList = {}
    for k,vehicle in pairs(vehicleList) do
        table.insert(vehicleIdList, vehicle:getId())
    end

    sendClientCommand(MOD_NAME, 'saveCars', vehicleIdList)
end

---@param xDif number
---@param yDif number
local spawnCars = function(xDif, yDif)
    if not isAdmin() then
        print('NOT ADMIN') -- TODO: return
    end
    local args = {
        xDif,
        yDif
    }
    sendClientCommand(MOD_NAME, 'spawn', args)
end

---@param xDif number
---@param yDif number
local moveCars = function(xDif, yDif)
    local args = {
        -- vehicle:getId(),
        xDif,
        yDif
    }

    sendClientCommand(MOD_NAME, 'moveCars', args)
    -- local player = getPlayer()
    -- local username = player:getUsername()
    -- local vehicleList = CacheMap[username]

    -- for k,vehicle in pairs(vehicleList) do
        -- local oX = vehicle:getX()
        -- local oY = vehicle:getY()
        -- vehicle:setActiveInBullet(true)
        -- -- -- vehicle:setPhysicsActive(false)
        -- vehicle:setX(oX - xDif)
        -- vehicle:setY(oX - yDif)
        -- vehicle:setActiveInBullet(false)
        -- vehicle:setPhysicsActive(true)
        -- local args = {
        --     -- vehicle:getId(),
        --     xDif,
        --     yDif
        -- }

        -- sendClientCommand(MOD_NAME, 'moveCar', args)
        
        -- print(field, ' -- ', i, ' val: ', getClassFieldVal(vehicle, field))
        -- public zombie.iso.IsoChunk zombie.vehicles.BaseVehicle.chunk    --     23
        -- public boolean zombie.vehicles.BaseVehicle.waitFullUpdate       --     31
        -- public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform     --     40
        -- public int zombie.vehicles.BaseVehicle.netPlayerTimeout         --     47
        -- final zombie.core.utils.UpdateLimit zombie.vehicles.BaseVehicle.limitPhysicSend         --     111
        -- zombie.iso.Vector2 zombie.vehicles.BaseVehicle.limitPhysicPositionSent  --     112
        -- final zombie.core.utils.UpdateLimit zombie.vehicles.BaseVehicle.limitPhysicValid        --     113
        -- private final zombie.core.utils.UpdateLimit zombie.vehicles.BaseVehicle.limitCrash      --     114
        -- public final org.joml.Matrix4f zombie.vehicles.BaseVehicle.vehicleTransform     --     153
        -- private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform   --     157
        -- private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform2  --     158
        -- private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform3  --     159
        -- public long zombie.vehicles.BaseVehicle.physicActiveCheck       --     162
        -- public boolean zombie.vehicles.BaseVehicle.isReliable   --     197
        -- public static final java.lang.ThreadLocal zombie.vehicles.BaseVehicle.TL_vector2_pool   --     198
        -- public static final java.lang.ThreadLocal zombie.vehicles.BaseVehicle.TL_vector2f_pool  --     199
        -- public static final java.lang.ThreadLocal zombie.vehicles.BaseVehicle.TL_vector3f_pool  --     200
        -- public static final java.lang.ThreadLocal zombie.vehicles.BaseVehicle.TL_matrix4f_pool  --     201
        -- public static final java.lang.ThreadLocal zombie.vehicles.BaseVehicle.TL_quaternionf_pool       --     202

        -- local field_count = getNumClassFields(vehicle)
        -- local transform_field = nil
        -- local tempTransform_fieldName = 'private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform'
        -- local jniTransform_fieldName = 'public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform'
        -- for i=0, field_count-1 do
        --     local field = getClassField(vehicle, i)
        --     print(tostring(field) .. ' -- ' .. i .. ' val: ', getClassFieldVal(vehicle, field))
        --     -- if tostring(field) == jniTransform_fieldName then
        --     --     print('found!')
        --     --     transform_field = field
        --     -- end
        -- end

        -- if transform_field then
        --     -- local v_transform = transform_field:get(vehicle)
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

        -- local func_count = getNumClassFunctions(vehicle)
        -- for i=0, func_count-1 do
        --     print(getClassFunction(vehicle, i), ' -- ', i)
        -- end
        -- print('allocVector3f client', vehicle:allocVector3f())
        -- print('car coords: ', oX, oY)
    -- end
end

-- ---@param startPos position
-- ---@param endPos position
-- ---@param zPos number
-- local sendGetCarList = function(startPos, endPos, zPos)
--     local args = {
--         startPos,
--         endPos,
--         zPos
--     }
--     sendClientCommand(MOD_NAME, 'getCarList', args)
-- end

---@param args moveCarArgs
Commands.moveCar = function(args)
    print('client moveCar')
    local xDif, yDif = unpack(args)
    local player = getPlayer()
    local username = player:getUsername()
    local vehicleList = CacheMap[username]
    for k,vehicle in pairs(vehicleList) do
        local id = vehicle:getId()
        local keyId = vehicle:getKeyId()
        local thisVehicle = getVehicleById(id)
        if thisVehicle and thisVehicle:getKeyId() == keyId then
            CarTeleport.moveCar(player, vehicle, xDif, yDif)
        end
    end
    player:Say('client moveCar')
end

---@param module string
---@param command string
---@param args any
local receiveServerCommand = function(module, command, args)
    if module ~= MOD_NAME then return; end
    if Commands[command] then
        Commands[command](args);
    end
end

Events.OnServerCommand.Add(receiveServerCommand);

local export = {
    getCarsListByCoord = getCarsListByCoord,
    removeCars = removeCars,
    moveCars = moveCars,
    startMove = startMove,
    spawnCars = spawnCars
}

return export
