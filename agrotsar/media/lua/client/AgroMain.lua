require('AgroUtils')

local Agro = {}

-- All seeds in the game
local seeds = {}

function Agro:new(character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.vehicle = nil
    o.trailer = nil
    o.squares = {} -- { IsoGridSquare1 = timestampMs, ... }
    o.counter = {} -- { AgroUtils.AREA_L = count, AgroUtils.AREA_R = count }
    -- AreaCenter coordinates after trailer activation
    --o.areaLCoord = { x = areaLeftX, y = areaLeftY }
    --o.areaRCoord = { x = areaRightX, y = areaRightY }
    --o.ignoreInitialCoord = false
    Agro.instance = o
    return o
end

function Agro:resetAll()
    --self.character = nil -- Do not reset here
    self.vehicle = nil
    self.trailer = nil
    self.squares = {}
    self.areaLCoord = nil
    self.areaRCoord = nil
    self.ignoreInitialCoord = false
    self.counter = {}
end

function Agro:playSound()
    if not self.sound or not self.trailer:getEmitter():isPlaying(self.sound) then
        self.sound = self.trailer:getEmitter():playAmbientLoopedImpl("AgroHardSurface")
    end
end

function Agro:stopSound()
    if self.sound and self.sound ~= 0 and self.trailer:getEmitter():isPlaying(self.sound) then
        self.trailer:getEmitter():stopSound(self.sound)
    end
end

function Agro:onPlowTick()
    if AgroUtils.isMoving(self.trailer) then
        local areaLVector2 = self.trailer:getAreaCenter(AgroUtils.AREA_L)
        local areaLCoord = { x = areaLVector2:getX(), y = areaLVector2:getY() }
        local areaRVector2 = self.trailer:getAreaCenter(AgroUtils.AREA_R)
        local areaRCoord = { x = areaRVector2:getX(), y = areaRVector2:getY() }

        if not self.ignoreInitialCoord then
            if self.areaLCoord and self.areaRCoord then
                if math.abs(self.areaLCoord.x - areaLCoord.x) < 0.5 and math.abs(self.areaLCoord.y - areaLCoord.y) < 0.5 then
                    return
                end
                if math.abs(self.areaRCoord.x - areaRCoord.x) < 0.5 and math.abs(self.areaRCoord.y - areaRCoord.y) < 0.5 then
                    return
                end
                self.ignoreInitialCoord = true
            else
                self.areaLCoord = areaLCoord
                self.areaRCoord = areaRCoord
                return
            end
        end

        local areaLSquare = getSquare(areaLVector2:getX(), areaLVector2:getY(), self.trailer:getZ())
        local areaRSquare = getSquare(areaRVector2:getX(), areaRVector2:getY(), self.trailer:getZ())

        self:plowSquare(areaLSquare, AgroUtils.AREA_L)
        self:plowSquare(areaRSquare, AgroUtils.AREA_R)

        if AgroUtils.isOnHardFloor(areaLSquare) or AgroUtils.isOnHardFloor(areaRSquare) then
            self:playSound()
        else
            self:stopSound()
        end
    else
        self:stopSound()
    end
end

function Agro:plowSquare(square, area)
    local timestamp = getTimestampMs()
    local timestampSquare = self.squares[square]

    -- 5 sec cooldown
    if not timestampSquare or timestamp > timestampSquare + 5000 then
        self.squares[square] = timestamp

        local part = AgroUtils.getPlowshareForArea(self.trailer, area)
        if part:getCondition() == 0 then return end

        local partConditionDelta = 0
        self.counter[area] = self.counter[area] and self.counter[area] + 1 or 1
        -- 50% chance to lose 1 condition per 3 squares
        if self.counter[area] % 3 == 0 then
            partConditionDelta = partConditionDelta + ZombRand(2)
        end

        local objects = AgroUtils.removeAllButFloor(square)
        if AgroUtils.canDigOnSquare(square) then
            if AgroUtils.isMovingForward(self.trailer) and square:getFloor() then
                local args = { x = square:getX(), y = square:getY(), z = square:getZ() }
                sendClientCommand(self.character, 'object', 'shovelGround', args)
                CFarmingSystem.instance:sendCommand(self.character, 'plow', args)
            end
        elseif AgroUtils.isOnHardFloor(square) then
            partConditionDelta = partConditionDelta + ZombRand(2, 5)
        end

        if objects > 0 then
            -- Lose 3 condition per each IsoMovingObject
            partConditionDelta = partConditionDelta + objects * 3
        end
        if partConditionDelta > 0 then
            AgroUtils.lowerPartCondition(self.trailer, part, partConditionDelta, true)
        end
    end
end

function Agro:onSeederTick()
    local areaLVector2 = self.trailer:getAreaCenter(AgroUtils.AREA_L)
    local areaRVector2 = self.trailer:getAreaCenter(AgroUtils.AREA_R)
    local areaLSquare = getSquare(areaLVector2:getX(), areaLVector2:getY(), self.trailer:getZ())
    local areaRSquare = getSquare(areaRVector2:getX(), areaRVector2:getY(), self.trailer:getZ())

    self:plantOnSquare(areaLSquare, AgroUtils.AREA_L)
    self:plantOnSquare(areaRSquare, AgroUtils.AREA_R)
end

function Agro:plantOnSquare(square, area)
    local timestamp = getTimestampMs()
    local timestampSquare = self.squares[square]

    if not timestampSquare or timestamp > timestampSquare + 1000 then
        self.squares[square] = timestamp

        local tankPart = AgroUtils.getSeederTankForArea(self.trailer, area)
        if not tankPart:getInventoryItem() then return end

        local tankContainer = tankPart:getItemContainer()
        if tankContainer:getItems():isEmpty() then return end

        local flapPart = AgroUtils.getSeederFlapForArea(self.trailer, area)
        if flapPart:getCondition() == 0 then return end

        local flapPartConditionDelta = 0
        self.counter[area] = self.counter[area] and self.counter[area] + 1 or 1
        -- Lose 1 condition per 3 seconds or squares
        if self.counter[area] % 3 == 0 then
            flapPartConditionDelta = flapPartConditionDelta + 1
        end

        local seedInfo, seedItems
        local firstItem = tankContainer:getItems():get(0)
        if firstItem then
            seedInfo = seeds[firstItem:getFullType()]
            if seedInfo then
                seedItems = tankContainer:getSomeType(firstItem:getFullType(), seedInfo.required)
            else
                -- Foreign object
                self.trailer:getEmitter():playSound("AgroSeederFOD")
                AgroUtils.toggleTrailerActivated(self.trailer, false)

                flapPartConditionDelta = flapPartConditionDelta + 20
            end
        end

        -- Plant if enough seeds
        if seedInfo and seedItems and seedItems:size() == seedInfo.required and AgroUtils.canPlantOnSquare(square) then
            local args = { x = square:getX(), y = square:getY(), z = square:getZ(), typeOfSeed = seedInfo.typeOfSeed }
            CFarmingSystem.instance:sendCommand(self.character, 'seed', args)
        end
        -- Seeds only or nil
        AgroUtils.removeContainerItems(seedItems)

        if flapPartConditionDelta > 0 then
            AgroUtils.lowerPartCondition(self.trailer, flapPart, flapPartConditionDelta, false)
        end
    end
end

local nextCheckTime = 0
local function onTick()
    local timestamp = getTimestampMs()
    if timestamp < nextCheckTime then return end
    nextCheckTime = timestamp + 200

    local agro = Agro.instance
    if not agro.vehicle then return end

    local trailer = agro.vehicle:getVehicleTowing()
    if trailer then
        if AgroUtils.isPlow(trailer) then
            agro.trailer = trailer
            if AgroUtils.isTrailerActivated(agro.trailer) then
                if AgroUtils.canUsePlow(agro.trailer) then
                    agro:onPlowTick()
                else
                    AgroUtils.toggleTrailerActivated(agro.trailer, false)
                end
                return
            else
                agro:stopSound()
            end
        elseif AgroUtils.isSeeder(trailer) then
            agro.trailer = trailer
            if AgroUtils.isTrailerActivated(agro.trailer) then
                if AgroUtils.canUseSeeder(agro.trailer) then
                    agro:onSeederTick()
                else
                    AgroUtils.toggleTrailerActivated(agro.trailer, false)
                end
                return
            end
        end
    else
        agro.trailer = nil
        agro.squares = {}
        agro.counter = {}
    end
    agro.areaLCoord = nil
    agro.areaRCoord = nil
    agro.ignoreInitialCoord = false
end

local function onVehicle(character)
    local agro = Agro.instance
    if instanceof(character, 'IsoPlayer') and character:isLocalPlayer() then
        local vehicle = character:getVehicle()
        if AgroUtils.isTractor(vehicle) then
            agro.vehicle = vehicle

            Events.OnTick.Add(onTick)
        else
            if character == agro.character then
                Events.OnTick.Remove(onTick)

                agro:resetAll()
            end
        end
    end
end

local function onCreatePlayer(id)
    if getCore():isDedicated() then return end

    local playerObj = getSpecificPlayer(id)
    if not playerObj or not playerObj:isLocalPlayer() then return end

    Agro:new(playerObj)
    Events.OnEnterVehicle.Add(onVehicle)
    Events.OnExitVehicle.Add(onVehicle)
end

local function onPlayerDeath(playerObj)
    if not playerObj:isLocalPlayer() then return end

    Events.OnEnterVehicle.Remove(onVehicle)
    Events.OnExitVehicle.Remove(onVehicle)
    Events.OnTick.Remove(onTick)
    Agro.instance = nil
end

local function onGameStart()
    for typeOfSeed, props in pairs(farming_vegetableconf.props) do
        seeds[props.seedName] = { typeOfSeed = typeOfSeed, required = props.seedsRequired }
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnPlayerDeath.Add(onPlayerDeath)
Events.OnGameStart.Add(onGameStart)