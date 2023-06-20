ETOMARAT = ETOMARAT or {}
ETOMARAT.CarTeleport = ETOMARAT.CarTeleport or {}
ETOMARAT.CarTeleport.MOD_NAME = 'CarTeleport'

---@param player IsoPlayer
---@param vehicle BaseVehicle
---@param xDif number
---@param yDif number
local moveCar = function(player, vehicle, xDif, yDif)
    if not player:isAccessLevel("admin") then
        print('NOT ADMIN')
    end
    -- local vihiclesArr = getCell():getVehicles()
	-- local result = nil
	-- for i = 0, vihiclesArr:size() - 1 do
	-- 	local vehicle = vihiclesArr:get(i)

	-- end

    -- local vehicleId, xDif, yDif = unpack(args)
    -- print('vehicleId, xDif, yDif: ', vehicleId, xDif, yDif)
    -- local vehicle = getVehicleById(vehicleId)
    print('vehicle: ', vehicle)
    if not vehicle then
        return
    end
    local carName = getText("IGUI_VehicleName" .. vehicle:getScript():getName())
    print('shared moveCar list: ', carName..' | sqlId: '..vehicle:getSqlId()..', vehicleId: '..vehicle:getId()..', keyId: '..vehicle:getKeyId())

    local field_count = getNumClassFields(vehicle)
    local transform_field = nil
    -- local tempTransform_fieldName = 'private final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.tempTransform'
    local jniTransform_fieldName = 'public final zombie.core.physics.Transform zombie.vehicles.BaseVehicle.jniTransform'
    for i=0, field_count-1 do
        local field = getClassField(vehicle, i)
        if tostring(field) == jniTransform_fieldName then
            print('found!')
            transform_field = field
        end
    end

    if transform_field then
        local v_transform = getClassFieldVal(vehicle, transform_field)
        print('v_transform: ', v_transform)
        local w_transform = vehicle:getWorldTransform(v_transform)
        print('w_transform: ', w_transform)
        local origin_field = getClassField(w_transform, 1)
        local origin = getClassFieldVal(w_transform, origin_field)
        print('origin', origin:x(), origin:y(), origin:z())
        origin:set(origin:x()-xDif, origin:y(), origin:z()-yDif)
        vehicle:setWorldTransform(w_transform)
        if isClient() then
            -- vehicle:update()
            vehicle:updateControls()
            vehicle:updateBulletStats()
            vehicle:updatePhysics()
            vehicle:updatePhysicsNetwork()
        end
    else
        print('transform_field not found')
    end
end

ETOMARAT.CarTeleport.moveCar = moveCar