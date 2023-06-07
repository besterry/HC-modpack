--**************************************************
--**                    BUHORL                    **
--**************************************************

if isClient() then return end

-- Add ModOptions 

local OPTIONS = SIS_MOD.OPTIONS
local snowscaler = 50

-- Check actual options at game loading.
Events.OnGameStart.Add(function()
  if not isClient() then -- only host may take these options
    --print("checkbox1 = ", OPTIONS.box1)
    --print("checkbox2 = ", OPTIONS.box2)
    if OPTIONS.snowscaler ~= nil then 
        snowscaler = OPTIONS.snowscaler*25
    end
  end
end)

----------------------------------------------------

require "GlobalItems/SGlobalItem"
require "GlobalItems/SGlobalItemSystem"

------------------------------
--- First the GlobalObject ---
------------------------------

SSnowOnDrainableObject = SGlobalItem:derive("SSnowOnDrainableObject");

function SSnowOnDrainableObject:new(luaSystem, globalObject)
    local o = SGlobalObject.new(self, luaSystem, globalObject)
    return o
end

function SSnowOnDrainableObject:initNew()
    self.exterior = false
    self.itemsquare = "vacio"--'not-assigned'
    self.item = nil
end

function SSnowOnDrainableObject:stateFromIsoObject(isoObject)
    self.exterior = isoObject:getSquare():isOutside()
    --self.itemsquare = "patata"--isoObject:getSquare()
    self.itemsquare = isoObject:getSquare()
    self.item = {}
    if instanceof(isoObject, "InventoryItem") then 
        target = isoObject
    end
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        target = isoObject:getItem()
    end
    table.insert(self.item, target)
end

function SSnowOnDrainableObject:stateToIsoObject(isoObject)
    --self.itemsquare = "patatas"--isoObject:getSquare()
--    self.itemsquare = isoObject:getSquare()
    if instanceof(isoObject, "InventoryItem") then 
        target = isoObject
    end
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        target = isoObject:getItem()
    end
    table.insert(self.item, target)
    print(" >>> SSnowOnDrainableObject: now we have ",#self.item," items")
    print(" >>> SSnowOnDrainableObject: ", target:getName()," has been inserted")
    --print(self.item[isoObject])
end

function stateToIsoObject(luaObject, isoObject)
    --luaObject.itemsquare = "patatas"--isoObject:getSquare()
--    luaObject.itemsquare = isoObject:getSquare()
    if instanceof(isoObject, "InventoryItem") then 
        target = isoObject
    end
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        target = isoObject:getItem()
    end
    table.insert(luaObject.item, target)
    print(" >>> SSnowOnDrainableObject: now we have ",#luaObject.item," items")
    print(" >>> SSnowOnDrainableObject: ", target:getName()," has been inserted")
    --print(luaObject.item[isoObject])
end

function SSnowOnDrainableObject:removeIsoObject(isoObject)
    if instanceof(isoObject, "InventoryItem") then 
        target = isoObject
    end
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        target = isoObject:getItem()
    end
    local tj = 0
    print( ">>> SSnowOnDrainableObject: we start with ",#self.item," items")
    for j=1,#self.item do
        print(" SIS!Object iteration: ",self.item[j]:getName())
        if self.item[j] == target then 
            tj = j
        end
    end
    if tj == 0 then error(" >>> No isoObjects could be removed") else
        table.remove(self.item, tj)
        print(" >>> SSnowOnDrainableObject: now we have ",#self.item," items")
    end
end

local function removeNthIsoObject(luaObject, nth)
    print( ">>> SSnowOnDrainableObject: we start with ",#luaObject.item," items")
    if nth == 0 then error(" >>> No isoObjects could be removed") else
        table.remove(luaObject.item, nth)
    end
    print(" >>> SSnowOnDrainableObject: now we have ",#luaObject.item," items")
end

-----------------------------------------------
--- Then the System for parent GlobalObject ---
-----------------------------------------------

SSnowOnDrainableSystem = SGlobalItemSystem:derive("SSnowOnDrainableSystem")

function SSnowOnDrainableSystem:new()
    local o = SGlobalItemSystem.new(self, "itemsnowsystem")
    return o
end

function SSnowOnDrainableSystem:initSystem()
    SGlobalItemSystem.initSystem(self)

    -- Specify GlobalObjectSystem fields that should be saved.
    self.system:setModDataKeys({})
    
    -- Specify GlobalObject fields that should be saved.
    -- We don't save the items because the item references get lost on game restart (so it's useless)
    self.system:setObjectModDataKeys({'exterior','itemsquare'})  --[[, 'item'--]]
end

function SSnowOnDrainableSystem:isValidIsoObject(isoObject)
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        if (instanceof(isoObject:getItem(), "InventoryItem")) then
           return isoObject:getItem():shouldUpdateInWorld()
        end
    end
    if (instanceof(isoObject, "InventoryItem")) then
       return isoObject:shouldUpdateInWorld()
    end
end

function isValidIsoObject(isoObject)
    if instanceof(isoObject, "IsoWorldInventoryObject") then
        if (instanceof(isoObject:getItem(), "InventoryItem")) then
            return isoObject:getItem():shouldUpdateInWorld()
        end
    end
    if (instanceof(isoObject, "InventoryItem")) then
        return isoObject:shouldUpdateInWorld()
    end
end

function SSnowOnDrainableSystem:isValidNormalObject(isoObject)
     if instanceof(isoObject, "IsoWorldInventoryObject") then
        if (instanceof(isoObject:getItem(), "InventoryItem")) then
            if isoObject:getItem():shouldUpdateInWorld() then
                SSnowOnDrainableSystem.instance:OnObjectAdded(isoObject:getItem())
                return true
            end
        end
    end
    if (instanceof(isoObject, "InventoryItem")) then
        if isoObject:shouldUpdateInWorld() then
            SSnowOnDrainableSystem.instance:OnObjectAdded(isoObject)
            return true
        end
    end
    return false
end

function SSnowOnDrainableSystem:newLuaObject(globalObject)
    return SSnowOnDrainableObject:new(self, globalObject)
end

function SSnowOnDrainableSystem:removeNthIsoObject(luaObject, nth)
    print( ">>> SSnowOnDrainableObject: we start with ",#self.item," items")
    if nth == 0 then error(" >>> No isoObjects could be removed") else
        table.remove(self.item, nth)
    end
    print(" >>> SSnowOnDrainableObject: now we have ",#self.item," items")
end

function SSnowOnDrainableSystem:OnClientCommand(command, playerObj, args)
    -- CGlobalObjectSystem:sendCommand() arguments are routed to this method
    -- in both singleplayer *and* multiplayer.
    if command == "testIsoObject" then
        self:reInitLuaObjects(playerObj.getCell())
    end
    if command == "addIsoObject" then
        --SSnowOnDrainableSystem.instance:OnObjectAdded(isoObject)
        self:squareInitDrainables(args[1], args[2], args[3], playerObj:getCell())
    end
end

function SSnowOnDrainableSystem:squareInitDrainables( x, y, z, cell )
    print(" check at ",x,' ',y,' ',z)
    local sq = cell:getGridSquare(x,y,z)
    if sq ~= nil then --skip luaObjects from a different grid, they will be called in a different execution
        local arr = sq:getWorldObjects()
        local luaObject = self:getLuaObjectAt(x, y, z)
        if luaObject == nil then
            luaObject = self:newLuaObjectAt(x, y, z)
        end
        luaObject.item = {}
        for i=0,(arr:size()-1) do
            print(" item ",i," ",arr:get(i):getName() )--:getObjectName())
            if isValidIsoObject(arr:get(i)) then
                print(" this one IS valid ") 
                self:getLuaObjectAt(x, y, z):stateToIsoObject(arr:get(i))
            end
        end
    end
end
    

function SSnowOnDrainableSystem:reInitLuaObjects( cell )
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        print("Init system at: ",luaObject.x,luaObject.y,luaObject.z)
        local sq = cell:getGridSquare(luaObject.x,luaObject.y,luaObject.z)--luaObject.itemsquare
        if sq ~= nil then --skip luaObjects from a different grid, they will be called in a different execution
            local arr = sq:getWorldObjects()
            local a = arr:size()
            -- We set the luaObject's item to an empty table since it will be replaced by all the posible square items 
            luaObject.item = {}
            for i=0,(a-1) do
                print(" item ",i," ",arr:get(i):getItem():getName() )--:getObjectName())
                if isValidIsoObject(arr:get(i):getItem()) then 
                    print(" this one IS valid ") 
                    stateToIsoObject(luaObject, arr:get(i):getItem())
                end
            end
        end
    end
end

function SSnowOnDrainableSystem:addSnowyWater() 
    if snowscaler == nil then snowscaler = 50 end
    if not getClimateManager():isSnowing() then return end --it's not raining
    for i=1,self:getLuaObjectCount() do
        local luaObject = self:getLuaObjectByIndex(i)
        local dirtyitems = {} --objects to remove
        if luaObject.item ~= null then  -- end if the luaObject has no items
        for j=1,#luaObject.item do
            local currentItem = luaObject.item[j]
            local target = currentItem  
            local square = nil
            if (instanceof(currentItem, "InventoryItem")) then 
                if target:getWorldItem() == nil then 
                    square = nil
                    -- the item changed states while it wasn't snowing, reInit the sq
                    self:squareInitDrainables( luaObject.x, luaObject.y, luaObject.z, getCell() )
                else
                    square = target:getWorldItem():getSquare()
                end
            else 
                if (instanceof(currentItem, "IsoWorldInventoryObject")) then 
                    target = currentItem:getItem()
                    square = target:getWorldItem():getSquare()
                else --if the item isn't valid, which shouldn't happen
                    target = nil
                    print(currentItem)
                    error(" SYS!Object -> is not IsoWorldInventoryObject nor InventoryItem, Exiting now")
                    return
                end 
            end
            if square then --double check
                luaObject.exterior = square:isOutside()
            end
            if square ~= nil and luaObject.exterior then
                if target:IsDrainable() then --we don't need to check the item, proceed as usual
                    --print(" SYS!Fill: ",target)
                    target:setUsedDelta(target:getUsedDelta() + 0.0005f * snowscaler * RainManager.getRainIntensity() * target:getRainFactor())
                    --target:setTaintedWater(true)
                   -- target:updateWeight()
                    --if (target:getUsedDelta() >= 1.0f) then
                    --    target:setUsedDelta(1.0f)
                    --    target:updateWeight()
                    --    print(" SYS!Object -> to be removed")
                    --    table.insert(dirtyitems, j)
                    --end
                    --target:getWorldItem():swapItem(target)
                    if target:getRainFactor() > 0 then 
                        --print(" SYS!Object -> getUsedDelta() ",target:getUsedDelta()) 
                        target:setUsedDelta(target:getUsedDelta() + 0.0005f * snowscaler * RainManager.getRainIntensity() * target:getRainFactor())
                        target:setTaintedWater(true)
                        target:updateWeight()
                        if (target:getUsedDelta() >= 1.0f) then
                            target:setUsedDelta(1.0f)
                            target:updateWeight()
                            print(" SYS!Object -> to be removed")
                            table.insert(dirtyitems, j)
                        end
                        target:getWorldItem():swapItem(target)
                        --print(target:getWorldItem():transmitCompleteItemToClients()) --
                    end
                else --we need to change the item from empty to fillable
                    --print(" SYS!EmptyTransform: ",target)
                    worldItem2 = target:getWorldItem()
                    square2 = worldItem2:getSquare()
                    if (square2 ~= null and square2:isOutside()) then
                        createItem2 = InventoryItemFactory.CreateItem(target:getReplaceOnUseOnString())
                        createItem2:setCondition(target:getCondition())
                        if (createItem2:IsDrainable() and createItem2:canStoreWater()) then
                            --createItem2:setTaintedWater(true)
                            --if (createItem2:getRainFactor() == 0.0f) then
                            --    target.rainFactorZero = true
                            --    return;
                            --end
                            createItem2:setUsedDelta(0.0005f * snowscaler * RainManager.getRainIntensity() * createItem2:getRainFactor())
                            createItem2:setTaintedWater(true)
                            worldItem2:swapItem(createItem2)
                            luaObject.item[j] = createItem2
                        end
                    end   
                end
            end
        end
        end
        --remove this luaObject's dirty objects
        for k=1,#dirtyitems do
            print( " SYS!Filled item ",k," : item @ ",dirtyitems[k])
            removeNthIsoObject(luaObject, dirtyitems[k])
        end
        dirtyitems = {}
    end
end

SGlobalItemSystem.RegisterSystemClass(SSnowOnDrainableSystem)

local noise = function(msg)
    SGlobalItemSystem.instance:noise(msg)
end

-- every minute we check if it's snowing, to fill our item
local function EveryOneMinute()
    SSnowOnDrainableSystem.instance:addSnowyWater()    
end

local function OnGameStart()
    print( " THE GAME HAS BOOTED; INIT LUA OBJECT IS EXECUTED ; SNOW RATIO AT: ", snowscaler,"%")
    SSnowOnDrainableSystem.instance:reInitLuaObjects(getPlayer():getCell())    
end

Events.EveryOneMinute.Add(EveryOneMinute)
Events.OnGameStart.Add(OnGameStart)

-- use the following line in console to force cell system restart:
-- SSnowOnDrainableSystem.instance:reInitLuaObjects(getPlayer():getCell())

