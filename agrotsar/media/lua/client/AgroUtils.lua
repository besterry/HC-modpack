require('luautils')

AgroUtils = {}
AgroUtils.AREA_L = "AgroLeft"
AgroUtils.AREA_R = "AgroRight"

function AgroUtils.isTractor(vehicle)
    return vehicle and vehicle:getScriptName() == "Base.Agrotractor"
end

function AgroUtils.isPlow(trailer)
    return trailer and trailer:getScriptName() == "Base.TrailerAgroplough"
end

function AgroUtils.isSeeder(trailer)
    return trailer and trailer:getScriptName() == "Base.TrailerAgroseeder"
end

function AgroUtils.isMoving(vehicle)
    return vehicle:getCurrentSpeedKmHour() > 1 or vehicle:getCurrentSpeedKmHour() < -1
end

function AgroUtils.isMovingForward(vehicle)
    return vehicle:getCurrentSpeedKmHour() > 1
end

function AgroUtils.isTrailerActivated(trailer)
    return trailer:getModData().isActivated
end

function AgroUtils.toggleTrailerActivated(trailer, forceState)
    trailer:getModData().isActivated = forceState ~= nil and forceState or not trailer:getModData().isActivated
    trailer:transmitModData()
    trailer:updateParts()
    AGROVehicles.AgroPlowshareModel(trailer, trailer:getPartById("AgroPlowshareLeft"))
    AGROVehicles.AgroPlowshareModel(trailer, trailer:getPartById("AgroPlowshareRight"))
end

function AgroUtils.lowerPartCondition(vehicle, part, conditionDelta, dropBroken)
    local newCondition = part:getCondition() - conditionDelta
    part:setCondition(newCondition)
    vehicle:transmitPartCondition(part)
    if newCondition <= 0 then
        if dropBroken then
            local item = part:getInventoryItem()
            local areaCenter = vehicle:getAreaCenter(part:getArea())
            local square = getSquare(areaCenter:getX(), areaCenter:getY(), vehicle:getZ())

            part:setInventoryItem(nil)
            square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
            AGROVehicles.UninstallComplete.AgroPlowshare(vehicle, part)
        end
        part:getVehicle():transmitPartItem(part)
        vehicle:getEmitter():playSound("PZ_MetalSnap")
    end
    vehicle:updateParts()
end

function AgroUtils.canUsePlow(trailer)
    local partL = AgroUtils.getPlowshareForArea(trailer, AgroUtils.AREA_L)
    local partR = AgroUtils.getPlowshareForArea(trailer, AgroUtils.AREA_R)
    if partL:getCondition() == 0 and partR:getCondition() == 0 then
        return false
    end
    return true
end

function AgroUtils.getPlowshareForArea(trailer, area)
    if area == AgroUtils.AREA_L then
        return trailer:getPartById("AgroPlowshareLeft")
    elseif area == AgroUtils.AREA_R then
        return trailer:getPartById("AgroPlowshareRight")
    end
end

function AgroUtils.canUseSeeder(trailer)
    local partL = AgroUtils.getSeederFlapForArea(trailer, AgroUtils.AREA_L)
    local partR = AgroUtils.getSeederFlapForArea(trailer, AgroUtils.AREA_R)
    if partL:getCondition() == 0 and partR:getCondition() == 0 then
        return false
    end
    return true
end

function AgroUtils.getSeederFlapForArea(trailer, area)
    if area == AgroUtils.AREA_L then
        return trailer:getPartById("AgroSeederPlateLeft")
    elseif area == AgroUtils.AREA_R then
        return trailer:getPartById("AgroSeederPlateRight")
    end
end

function AgroUtils.getSeederTankForArea(trailer, area)
    if area == AgroUtils.AREA_L then
        return trailer:getPartById("AgroSeederTankLeft")
    elseif area == AgroUtils.AREA_R then
        return trailer:getPartById("AgroSeederTankRight")
    end
end

function AgroUtils.removeContainerItems(arrayList)
    if not arrayList then return end

    for i = 0, arrayList:size() - 1 do
        local item = arrayList:get(i)
        item:getContainer():Remove(item)
    end
end

function AgroUtils.isOnHardFloor(square)
    for i = 1, square:getObjects():size() do
        local obj = square:getObjects():get(i - 1)
        if obj:getTextureName() and (luautils.stringStarts(obj:getTextureName(), "floors_exterior_street") or
                luautils.stringStarts(obj:getTextureName(), "blends_street_01")) then
            -- gravel
            --texName == "blends_street_01_16"
            --        or texName == "blends_street_01_17"
            --        or texName == "blends_street_01_18"
            --        or texName == "blends_street_01_19"
            --        or texName == "blends_street_01_20"
            --        or texName == "blends_street_01_21"
            --        or texName == "blends_street_01_48"
            --        or texName == "blends_street_01_53"
            --        or texName == "blends_street_01_54"
            --        or texName == "blends_street_01_55"
            return true
        end
    end
    return false
end

function AgroUtils.canDigOnSquare(square)
    for i = 1, square:getObjects():size() do
        local obj = square:getObjects():get(i - 1)
        if obj:getTextureName() and (luautils.stringStarts(obj:getTextureName(), "floors_exterior_natural") or
                luautils.stringStarts(obj:getTextureName(), "blends_natural_01")) then
            return true
        end
    end
    return false
end

function AgroUtils.canPlantOnSquare(square)
    local plant = CFarmingSystem.instance:getLuaObjectOnSquare(square)
    if plant and plant.state == "plow" then
        return true
    end
    return false
end

function AgroUtils.removeAllButFloor(square)
    local count = 0
    if not square then return count end
    for i = square:getObjects():size(), 2, -1 do
        local isoObject = square:getObjects():get(i - 1)
        square:transmitRemoveItemFromSquare(isoObject)
    end
    for i = square:getStaticMovingObjects():size(), 1, -1 do
        local isoObject = square:getStaticMovingObjects():get(i - 1)
        if instanceof(isoObject, "IsoDeadBody") then
            square:removeCorpse(isoObject, false)
        end
        count = count + 1
    end
    if count > 0 and SandboxVars.BloodLevel > 1 then
        for _ = 1, count * ZombRand(3, 10) do
            square:getChunk():addBloodSplat(
                    square:getX() + ZombRandFloat(-0.5, 0.5),
                    square:getY() + ZombRandFloat(-0.5, 0.5),
                    square:getZ(),
                    ZombRand(20))
        end
    end
    return count
end