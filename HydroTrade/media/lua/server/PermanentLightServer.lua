-- Keep admin permanent lights lit; restore after toggle/fuel cheats.

if not isServer() then return end

local MOD_KEY = "HydroPermanentLight"

local function isPermanentLight(obj)
	return obj and instanceof(obj, "IsoThumpable") and obj:hasModData() and obj:getModData()[MOD_KEY]
end

local function getPermanentLightAt(x, y, z)
	local gs = getCell():getGridSquare(x, y, z)
	if not gs then return nil end
	local special = gs:getSpecialObjects()
	if not special then return nil end
	for i = 0, special:size() - 1 do
		local o = special:get(i)
		if isPermanentLight(o) then
			return o
		end
	end
	return nil
end

local function ensurePermanentLight(obj)
	if not isPermanentLight(obj) then return end

	obj:setIsDismantable(false)
	obj:setIsThumpable(false)
	obj:setHaveFuel(true)
	obj:setLifeLeft(1.0)
	obj:setLifeDelta(0.0)

	if not obj:isLightSourceOn() then
		obj:toggleLightSource(true)
		obj:sendObjectChange("lightSource")
	end
end

local function onLoadGridsquare(square)
	if not square then return end
	local special = square:getSpecialObjects()
	if not special then return end
	for i = 0, special:size() - 1 do
		ensurePermanentLight(special:get(i))
	end
end

local function onClientCommand(module, command, player, args)
	if module ~= "object" or not args then return end
	if command ~= "toggleLight" and command ~= "removeFuel" and command ~= "insertFuel" then return end
	local o = getPermanentLightAt(args.x, args.y, args.z)
	if o then
		ensurePermanentLight(o)
	end
end

Events.LoadGridsquare.Add(onLoadGridsquare)
Events.OnClientCommand.Add(onClientCommand)
