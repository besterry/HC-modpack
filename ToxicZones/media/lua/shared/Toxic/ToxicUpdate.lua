ToxicUpdate = {}

ToxicUpdate.createRegionsModData = function(table)
	local regions = {}
	
	for i, w in pairs(table) do
		local zone = i
		local startingX = math.floor(table[zone].startX / 100);
		local endX = math.floor(table[zone].endX / 100);
		local startingY = math.floor(table[zone].startY / 100);
		local endY = math.floor(table[zone].endY / 100);
		
		if startingX > endX then
			local x2 = endX;
			endX = startingX;
			startingX = x2;
		end
		if startingY > endY then
			local y2 = endY;
			endY = startingY;
			startingY = y2;
		end
		-- test corners
		local regionTag = tostring(startingX) .. "x" .. tostring(startingY);
		regions[regionTag] = regions[regionTag] or {}
		if not regions[regionTag][zone] then
			regions[regionTag][zone] = table[zone]
		end	

		regionTag = tostring(endX) .. "x" .. tostring(startingY);
		regions[regionTag] = regions[regionTag] or {}
		if not regions[regionTag][zone] then
			regions[regionTag][zone] = table[zone]
		end

		regionTag = tostring(startingX) .. "x" .. tostring(endY);
		regions[regionTag] = regions[regionTag] or {}
		if not regions[regionTag][zone] then
			regions[regionTag][zone] = table[zone]
		end	

		regionTag = tostring(endX) .. "x" .. tostring(endY);
		regions[regionTag] = regions[regionTag] or {}
		if not regions[regionTag][zone] then
			regions[regionTag][zone] = table[zone]
		end			
		
		--try testing each fake square
		for xN=startingX, endX do
			for yN=startingY, endY do
				local regionTag = tostring(xN) .. "x" .. tostring(yN);
				regions[regionTag] = regions[regionTag] or {}
				
				if not regions[regionTag][zone] then
					regions[regionTag][zone] = table[zone]
				end			
           end
        end
	end
	return regions
end

Events.OnInitGlobalModData.Add(function(bool)
	if isClient() then
		ModData.request("ToxicZone")
		ModData.request("ToxicZoneRegions")
	else
		ModData.getOrCreate("ToxicZone")
		ModData.getOrCreate("ToxicZoneRegions")
	end
end)

Events.OnReceiveGlobalModData.Add(function(key, table)
	if key == "ToxicZone" then
		ModData.remove("ToxicZone")
		ModData.getOrCreate("ToxicZone")
		ModData.add("ToxicZone", table)

		--create list by chunks and restart the list of squares
		ModData.remove("ToxicZoneSquares")
		local regionsTable = ToxicUpdate.createRegionsModData(table)
		ModData.getOrCreate("ToxicZoneRegions")
		ModData.add("ToxicZoneRegions", regionsTable)

		if isServer() then
			ModData.transmit("ToxicZone")
			ModData.transmit("ToxicZoneRegions")
		end
	end
end)