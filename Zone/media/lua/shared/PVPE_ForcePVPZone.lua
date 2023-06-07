ForcePVPZone = {}
ForcePVPZone.PvpZoneList = {} 
ForcePVPZone.listSize = 0
ForcePVPZone.__index = ForcePVPZone

function ForcePVPZone:addPvpZone(title, x, y, x2, y2)
    -- print("ForcePVPZone:addPvpZone")
    if title then
        local pvpZoneObj = ForcePVPZone.new(nil, title, x, y, x2, y2)
        ForcePVPZone.PvpZoneList[title] = pvpZoneObj
        ForcePVPZone.listSize = ForcePVPZone.listSize + 1
        local modTable = ModData.get("ForcePvpZoneTable")
        modTable.PvpZoneList = ForcePVPZone.PvpZoneList
        modTable.listSize = ForcePVPZone.listSize
        ModData.transmit("ForcePvpZoneTable")
    end
    return pvpZoneObj
end

function ForcePVPZone:removePvpZone(title)
    if title and ForcePVPZone.PvpZoneList[title] then
        ForcePVPZone.PvpZoneList[title] = nil
        ForcePVPZone.listSize = ForcePVPZone.listSize - 1
        local modTable = ModData.get("ForcePvpZoneTable")
        modTable.PvpZoneList = ForcePVPZone.PvpZoneList
        modTable.listSize = ForcePVPZone.listSize
        ModData.transmit("ForcePvpZoneTable")
    end
end

function ForcePVPZone:getZoneByTitle(title)
    if title then
        return ForcePVPZone.PvpZoneList[title]
    else
        return nil
    end
end

function ForcePVPZone:getPvpZone(x, y)
    -- print("ForcePVPZone:getPvpZone")
    for name, zone in pairs(ForcePVPZone.PvpZoneList) do
        if (x >= zone.x and x < zone.x2 and y >= zone.y and y < zone.y2) then
            return zone
        end
    end
    return nil
end

function ForcePVPZone:new(title, x, y, x2, y2)
    local o = {}
    setmetatable(o, ForcePVPZone)
    if x > x2 then
        local n = x2
        x2 = x
        x = n
    end
    if y > y2 then
        local n2 = y2
        y2 = y
        y = n2
    end
    o.x = x
    o.x2 = x2
    o.y = y
    o.y2 = y2
    o.title = title
    o.size = math.abs(x - x2 + (y - y2))
    return o
end

Events.OnInitGlobalModData.Add(function()
	if isClient() then
		ModData.request("ForcePvpZoneTable")
        local modTable = ModData.get("ForcePvpZoneTable")
        if modTable then
            ForcePVPZone.PvpZoneList = modTable.PvpZoneList
            ForcePVPZone.listSize = modTable.listSize
        end
	else
		local modData = ModData.getOrCreate("ForcePvpZoneTable")
        local filename = getServerName() .. "_pvpzone.lua"
        if not modData.listSize or modData.listSize < 1 then
            modData.PvpZoneList = {}
            modData.listSize = 0
            if serverFileExists(filename) then
                reloadServerLuaFile(filename)
                for _, t in ipairs(ServerPvpZoneList) do
                    modData.listSize = modData.listSize + 1
                    local pvpZoneObj = ForcePVPZone.new(nil, t.title, t.x, t.y, t.x2, t.y2)
                    modData.PvpZoneList[t.title] = pvpZoneObj
                end
            end
        end
        ModData.transmit("ForcePvpZoneTable")
	end
end)

Events.OnReceiveGlobalModData.Add(function(_module, _packet)
	if _module == "ForcePvpZoneTable" and _packet then
		ModData.add("ForcePvpZoneTable", _packet)
		if isClient() then
            ForcePVPZone.PvpZoneList = _packet.PvpZoneList
            ForcePVPZone.listSize = _packet.listSize
        else
			ModData.transmit("ForcePvpZoneTable")
            local writeFile = getFileWriter(getServerName() .. "_pvpzone.lua", true, false)
            writeFile:write("ServerPvpZoneList = {\r\n");
            for title, obj in pairs(_packet.PvpZoneList) do
                writeFile:write("\t{title = \"" .. title .. "\", x = " .. tostring(obj.x) .. ", y = " .. tostring(obj.y) .. ", x2 = " .. tostring(obj.x2) .. ", y2 = " .. tostring(obj.y2).. "},\r\n");
            end
            writeFile:write("}");
            writeFile:close()
		end
	end
end)