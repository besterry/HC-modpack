--**************************************************
--**                    BUHORL                    **
--**************************************************

if isClient() then return end

require "ISBaseObject"

SGlobalItemSystem = ISBaseObject:derive("SGlobalItemSystem")

function SGlobalItemSystem:noise(message)
	if self.wantNoise then print(self.systemName..': '..message) end
end

function SGlobalItemSystem:new(name)
	-- Create the GlobalObjectSystem called NAME and load gos_NAME.bin if it exists.
	local system = SGlobalObjects.registerSystem(name)
	-- NOTE: The table for this Lua object is the same one the SGlobalItemSystem
	-- Java object created.  The Java class calls some of this Lua object's methods.
	-- At this point, system:getModData() has already been read from disk if the
	-- gos_name.bin file existed.
	local o = system:getModData()
	setmetatable(o, self)
	self.__index = self
	o.system = system
	o.systemName = name
	o.wantNoise = getDebug()
	o:initSystem()
	o:initLuaObjects()
	o:noise('#objects='..system:getObjectCount())
	return o
end

function SGlobalItemSystem:initSystem()
end

function SGlobalItemSystem:getInitialStateForClient()
	-- Return a Lua table that is used to initialize the client-side system.
	-- This is called when a client connects in multiplayer, and after
	-- server-side systems are created in singleplayer.
	return nil
end

function SGlobalItemSystem:getLuaObjectCount()
	return self.system:getObjectCount()
end

function SGlobalItemSystem:getLuaObjectByIndex(index)
	return self.system:getObjectByIndex(index-1):getModData()
end

function SGlobalItemSystem:initLuaObjects()
	for i=1,self.system:getObjectCount() do
		local globalObject = self.system:getObjectByIndex(i-1)
		local luaObject = self:newLuaObject(globalObject)
		self:noise('added luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
	end
end

function SGlobalItemSystem:isValidIsoObject(isoObject)
	error "override this method"
end

function SGlobalItemSystem:getIsoObjectOnSquare(square)
	if not square then return nil end
	for i=1,square:getObjects():size() do
		local isoObject = square:getObjects():get(i-1)
		if self:isValidIsoObject(isoObject) then
			return isoObject
		end
	end
	return nil
end

function SGlobalItemSystem:getIsoObjectAt(x, y, z)
	local square = getCell():getGridSquare(x, y, z)
	return self:getIsoObjectOnSquare(square)
end

function SGlobalItemSystem:newLuaObject(globalObject)
	-- Return an object derived from SGlobalObject
	error "override this method"
end

function SGlobalItemSystem:newLuaObjectAt(x, y, z)
	local globalObject = self.system:newObject(x, y, z)
	local luaObject = self:newLuaObject(globalObject)
	self:newLuaObjectOnClient(luaObject)
	return luaObject
end

function SGlobalItemSystem:newLuaObjectOnSquare(square)
	return self:newLuaObjectAt(square:getX(), square:getY(), square:getZ())
end

function SGlobalItemSystem:removeLuaObject(luaObject)
	if not luaObject or (luaObject.luaSystem ~= self) then return end
	self:noise('removing luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
	luaObject:aboutToRemoveFromSystem()
	self:removeLuaObjectOnClient(luaObject)
	self.system:removeObject(luaObject.globalObject)
	self:noise('#objects='..self.system:getObjectCount())
end

function SGlobalItemSystem:removeLuaObjectAt(x, y, z)
	local luaObject = self:getLuaObjectAt(x, y, z)
	self:removeLuaObject(luaObject)
end

function SGlobalItemSystem:removeLuaObjectOnSquare(square)
	local luaObject = self:getLuaObjectOnSquare(square)
	self:removeLuaObject(luaObject)
end

function SGlobalItemSystem:newLuaObjectOnClient(luaObject)
	self.system:addGlobalObjectOnClient(luaObject.globalObject)
end

function SGlobalItemSystem:removeLuaObjectOnClient(luaObject)
	self.system:removeGlobalObjectOnClient(luaObject.globalObject)
end

function SGlobalItemSystem:getLuaObjectAt(x, y, z)
	local globalObject = self.system:getObjectAt(x, y, z)
	return globalObject and globalObject:getModData() or nil
end

function SGlobalItemSystem:getLuaObjectOnSquare(square)
	if not square then return nil end
	return self:getLuaObjectAt(square:getX(), square:getY(), square:getZ())
end

function SGlobalItemSystem:loadIsoObject(isoObject)
	if not isoObject or not isoObject:getSquare() then return end
	if not self:isValidIsoObject(isoObject) then return end
	local square = isoObject:getSquare()
	local luaObject = self:getLuaObjectOnSquare(square)
	if luaObject then
		self:noise('found isoObject with a luaObject '..luaObject.x..','..luaObject.y..','..luaObject.z)
		luaObject:stateToIsoObject(isoObject)
	else
		self:noise('found isoObject without a luaObject '..square:getX()..','..square:getY()..','..square:getZ())
		local globalObject = self.system:newObject(square:getX(), square:getY(), square:getZ())
		local luaObject = self:newLuaObject(globalObject)
		luaObject:stateFromIsoObject(isoObject)
		self:noise('#objects='..self.system:getObjectCount())
		self:newLuaObjectOnClient(luaObject)
	end
end

function SGlobalItemSystem:sendCommand(command, args)
	self.system:sendCommand(command, args)
end

function SGlobalItemSystem:OnClientCommand(command, playerObj, args)
	-- CGlobalObjectSystem:sendCommand() arguments are routed to this method
	-- in both singleplayer *and* multiplayer.
end

function SGlobalItemSystem:OnDestroyIsoThumpable(isoObject, playerObj)
	self:OnObjectAboutToBeRemoved(isoObject)
end

function SGlobalItemSystem:OnObjectAdded(isoObject)
	if not self:isValidIsoObject(isoObject) then return end
	self:loadIsoObject(isoObject:getWorldItem())
end

function SGlobalItemSystem:OnObjectAboutToBeRemoved(isoObject)
	if not self:isValidIsoObject(isoObject) then return end
	local luaObject = self:getLuaObjectOnSquare(isoObject:getSquare())
	if not luaObject then return end
	--local thisitem = luaObject.item
	--print( "SIS! numitems: ", thisitem)
	luaObject:removeIsoObject(isoObject)
	if #luaObject.item == 0 then  
		self:removeLuaObject(luaObject)
	end
end

function SGlobalItemSystem:OnIsoObjectChangedItself(isoObject)
	-- A Java object changed it's state. Sync the global object.
	-- For example, after a generator runs out of fuel and shuts itself off.
	if not isoObject or not isoObject:getSquare() then return end
	self:noise('OnIsoObjectChangedItself')
	if not self:isValidIsoObject(isoObject) then return end
	local square = isoObject:getSquare()
	local luaObject = self:getLuaObjectOnSquare(square)
	if luaObject then
		luaObject:OnIsoObjectChangedItself(isoObject)
--		self.system:updateGlobalObjectOnClient(luaObject.globalObject)
	end
end

-- Java calls this method when a chunk with GlobalObjects managed by this system is loaded.
-- This is how GlobalObjects with a missing IsoObject are removed.
-- Instead of using the LoadGridSquare event and checking every location,
-- this event is triggered only for chunks that have GlobalObjects belonging
-- to this particular system.
function SGlobalItemSystem:OnChunkLoaded(wx, wy)
--	    print(" CHUNK LOADED ")
	local globalObjects = self.system:getObjectsInChunk(wx, wy)
	for i=1,globalObjects:size() do
		local globalObject = globalObjects:get(i-1)
		local square = getCell():getGridSquare(globalObject:getX(), globalObject:getY(), globalObject:getZ())
		local isoObject = self:getIsoObjectOnSquare(square)
		self.instance:reInitLuaObjects(getCell())
		if not isoObject then
			print('found luaObject without an isoObject')
			self:noise('found luaObject without an isoObject')
			self:removeLuaObject(globalObject:getModData())
		end
	end
	-- This returns the ArrayList to a pool for reuse.  There's no harm if
	-- you forget to call it.
	self.system:finishedWithList(globalObjects)
end

function SGlobalItemSystem:reInitLuaObjects( cell )
	error "override this method"
end

local function OnDestroyIsoThumpable(luaClass, isoObject, playerObj)
	luaClass.instance:OnDestroyIsoThumpable(isoObject, playerObj)
end

local function OnObjectAdded(luaClass, isoObject)
	luaClass.instance:OnObjectAdded(isoObject)
end

local function OnObjectAboutToBeRemoved(luaClass, isoObject)
	luaClass.instance:OnObjectAboutToBeRemoved(isoObject)
end

local function OnGameBoot(luaClass)
	if not isServerSoftReset() then return end
	print(" >>> GAME BOOT INIT <<< ")
	luaClass.instance = luaClass:new()
end

local function OnSGlobalObjectSystemInit(luaClass)
	print(" >>> SGOS INIT <<< ")
	luaClass.instance = luaClass:new()
end

local function OnClientCommand(module, command, player, args)
	if module ~= 'SFarmingSystem' then return end
	if Commands[command] then
		local argStr = ''
		for k,v in pairs(args) do argStr = argStr..' '..k..'='..v end
		noise('OnClientCommand '..module..' '..command..argStr)
		SFarmingSystem.instance:receiveCommand(player, command, args)
	end
end

Events.OnClientCommand.Add(OnClientCommand)

function SGlobalItemSystem.RegisterSystemClass(luaClass)
	if luaClass == SGlobalItemSystem then error "replace : with . before RegisterSystemClass" end

	-- This is to support reloading a derived class file in the Lua debugger.
	for i=1,SGlobalObjects.getSystemCount() do
		local system = SGlobalObjects.getSystemByIndex(i-1)
		if system:getModData().Type == luaClass.Type then
			luaClass.instance = system:getModData()
			return
		end
	end
	
	Events.OnDestroyIsoThumpable.Add(function(isoObject, playerObj) OnDestroyIsoThumpable(luaClass, isoObject, playerObj) end)
	Events.OnObjectAdded.Add(function(isoObject) OnObjectAdded(luaClass, isoObject) end)
	Events.OnObjectAboutToBeRemoved.Add(function(isoObject) OnObjectAboutToBeRemoved(luaClass, isoObject) end)
	-- For now we only want the initial system, not two instances
	Events.OnGameBoot.Add(function() OnGameBoot(luaClass) end)
	Events.OnSGlobalObjectSystemInit.Add(function() OnSGlobalObjectSystemInit(luaClass) end)
end

