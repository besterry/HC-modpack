if AutoGate == nil then AutoGate = {} end
if AutoGate.Utils == nil then AutoGate.Utils = {} end

function AutoGate.Utils.InstallGate(args)
    local square = getCell():getGridSquare(args.x,args.y,args.z)
    local door = AutoGate.Utils.GetGateFromSquare(square)
    local gate = AutoGate.Utils.GetFullGate(door)
    local corner = gate[1]
    corner:setIsContainer(true)
    corner:getContainer():setOnlyAcceptCategory("Item")
    for i,dr in ipairs(gate) do
        dr:getModData()["AutoGate_gateFrequency_X"] = corner:getX()
        dr:getModData()["AutoGate_gateFrequency_Y"] = corner:getY()
        dr:getModData()["AutoGate_gateFrequency_Z"] = corner:getZ()
        dr:getModData()["AutoGate_gateFrequency_PAIRED"] = nil
        --dr:setIsLocked(true)
    end
end

function AutoGate.Utils.GetGateFromSquare(gSquare)
    for i=0,gSquare:getObjects():size()-1 do
        local o = gSquare:getObjects():get(i)
        local name = tostring(o:getName())
        if (instanceof(o, "IsoThumpable")) and ((name == "Double Door") or (name == "Double Metal Pole Gate") or (name == "Double Metal Wire Gate")) then
            return o
        end
    end
end

function AutoGate.Utils.GetGateCorner(obj)
    local ObjSquare = obj:getSquare()
    local isNorth = obj:getNorth()
    local ObjProp = tonumber(ObjSquare:getProperties():Val("DoubleDoor"))
    local x = ObjSquare:getX()
    local y = ObjSquare:getY()
    local z = ObjSquare:getZ()
    if ObjProp == 1 or ObjProp == 5 then
        return ObjSquare
    end
    if isNorth then
        if ObjProp == 2 then
            return getCell():getGridSquare(x-1,y,z)
        elseif ObjProp == 3 then
            return getCell():getGridSquare(x-2,y,z)
        elseif ObjProp == 4 or ObjProp == 8 then
            return getCell():getGridSquare(x-3,y,z)
        elseif ObjProp == 6 then
            return getCell():getGridSquare(x,y-1,z)
        else
            return getCell():getGridSquare(x-3,y-1,z)
        end
    else
        if ObjProp == 2 then
            return getCell():getGridSquare(x,y+1,z)
        elseif ObjProp == 3 then
            return getCell():getGridSquare(x,y+2,z)
        elseif ObjProp == 4 or ObjProp == 8 then
            return getCell():getGridSquare(x,y+3,z)
        elseif ObjProp == 6 then
            return getCell():getGridSquare(x-1,y,z)
        else
            return getCell():getGridSquare(x-1,y+3,z)
        end
    end
end

function AutoGate.Utils.GetFullGate(obj)
    local s = {}
    local corner = AutoGate.Utils.GetGateCorner(obj)
    local isNorth = obj:getNorth()
    local x = corner:getX()
    local y = corner:getY()
    local z = corner:getZ()
    s[1] = AutoGate.Utils.GetGateFromSquare(corner)
    local aX = 0
    local aY = 0
    for i=1,3 do
        if isNorth then
            aX = i
        else
            aY = -i 
        end
        local cell = getCell():getGridSquare(x+aX, y+aY, z)
        local objInCell = AutoGate.Utils.GetGateFromSquare(cell)
        if objInCell then
            table.insert(s, objInCell)
        end
    end
    if isNorth then
        y = y+1
    else
        x = x+1 
    end
    for i=0,3 do
        if isNorth then
            aX = i
        else
            aY = -i 
        end
        local cell = getCell():getGridSquare(x+aX, y+aY, z)
        local objInCell = AutoGate.Utils.GetGateFromSquare(cell)
        if objInCell then
            table.insert(s, objInCell)
        end
    end
    return s
end

function AutoGate.Utils.makeCopy(objTo, objFrom)
    local fqcs = AutoGate.Utils.GetFrequency(objFrom)
    if fqcs then
        objTo:getModData()["AutoGate_gateFrequency_X"] = fqcs[1]
        objTo:getModData()["AutoGate_gateFrequency_Y"] = fqcs[2]
        objTo:getModData()["AutoGate_gateFrequency_Z"] = fqcs[3]
        objTo:getModData()["AutoGate_gateFrequency_PAIRED"] = fqcs[4]
        objTo:setName(objFrom:getName())
    end
end

function AutoGate.Utils.pairGateCtrl(ctrl, door)
    local fqcs = AutoGate.Utils.GetFrequency(door)
    local code = ZombRand(100, 999)
    if fqcs then
        ctrl:getModData()["AutoGate_gateFrequency_X"] = fqcs[1]
        ctrl:getModData()["AutoGate_gateFrequency_Y"] = fqcs[2]
        ctrl:getModData()["AutoGate_gateFrequency_Z"] = fqcs[3]
        ctrl:getModData()["AutoGate_gateFrequency_PAIRED"] = code
        ctrl:setName(ctrl:getName().. " #".. code)
    end
    local gate = AutoGate.Utils.GetFullGate(door)
    for i, dr in ipairs(gate) do
        dr:getModData()["AutoGate_gateFrequency_PAIRED"] = code
        dr:transmitModData()
    end
end

function AutoGate.Utils.GetFrequency(obj)
    local fqcs = {}
    fqcs[1] = obj:getModData()["AutoGate_gateFrequency_X"]
    if fqcs[1] == nil then
        return nil
    end
    fqcs[2] = obj:getModData()["AutoGate_gateFrequency_Y"]
    fqcs[3] = obj:getModData()["AutoGate_gateFrequency_Z"]
    fqcs[4] = obj:getModData()["AutoGate_gateFrequency_PAIRED"]
    return fqcs
end