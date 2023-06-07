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
        print("OPTION.snowscaler: ", snowscaler)
    end
  end
end)

function getSIWopts( )
    -- body
    print(" The snow ratio is set at ",snowscaler,"%")
end
-- fast re-init items @ player position 
function ssID()
    local p = getPlayer()
    SSnowOnDrainableSystem.instance:squareInitDrainables(p:getX(),p:getY(),p:getZ(),p:getCell())
end

-- lua table dump (use with print)
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- checks for valid objects at player pos/sq
function validitemtest()
    -- THIS IS V1: 
    local sq1 = getPlayer():getSquare()
    print(" check at ",sq1:getX(),' ',sq1:getY(),' ',sq1:getZ())
    if sq1:isOutside() then print(" since it's an outside square ") end
    local sq = getCell():getGridSquare(sq1:getX(),sq1:getY(),sq1:getZ())
    local arr = sq:getWorldObjects()
    for i=0,(arr:size()-1) do
        print(" item ",i," ",arr:get(i):getName() )--:getObjectName())
        if isValidIsoObject(arr:get(i)) then print(" this one IS valid ") end
    end
    return 
end

function luaitemstest()
    -- luaobjects at player pos
    local var = getPlayer():getSquare()
    local luaObject = SSnowOnDrainableSystem.instance.system:getObjectAt(var:getX(), var:getY(), var:getZ()):getModData()
    print("I have ",luaObject)
    --print("I have ",dump(luaObject))
    print("And it has ",#luaObject.item," items: ",dump(luaObject.item))
    for i=1,#luaObject.item do
        print(luaObject.item[i]:getName())--:getObjectName() 
    end
    return 
end

if isClient() then return end

-- we update the update
function SMetalDrumGlobalObject:update()
    if RainManager.isRaining() or getClimateManager():isSnowing() then
        self.waterMax = self.waterMax or ISMetalDrum.waterMax
        if self.waterAmount < self.waterMax then
            local square = self:getSquare()
            if square then self.exterior = square:isOutside() end
            if self.exterior then
                if not self.haveLogs and not self.haveCharcoal then
                    self.waterAmount = math.min(self.waterMax, self.waterAmount + (1 * ISMetalDrum.waterScale * snowscaler)/100)
                    if not getClimateManager():isSnowing() then 
                       self.waterAmount = math.min(self.waterMax, self.waterAmount + 1 * ISMetalDrum.waterScale)
                    end
                    self.taintedWater = true
                    local isoObject = self:getIsoObject()
                    if isoObject then -- object might have been destroyed
                        self:noise('added rain to barrel at '..self.x..","..self.y..","..self.z..' waterAmount='..self.waterAmount)
                        isoObject:setTaintedWater(true)
                        isoObject:setWaterAmount(self.waterAmount)
                        isoObject:transmitModData()
                    end
                end
            end
        end
    end

    if self.haveLogs and self.isLit then
        if not self.charcoalTick then
            self.charcoalTick = 1
        else
            self.charcoalTick = self.charcoalTick + 1
        end
        self:noise('charcoal update ' .. self.charcoalTick)
        if self.charcoalTick == 12 then
            self.haveLogs = false
            self.isLit = false
            self.haveCharcoal = true
            self.charcoalTick = nil
            if self.LightSource then
                -- FIXME: won't be synced in multiplayer
                getCell():removeLamppost(self.LightSource)
            end
        end
        self:changeSprite()
        self:setModData()
    end
end

