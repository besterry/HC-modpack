local function render(currGenInstance)
    --if currGenInstance:getIsVisible() then
        local square = currGenInstance.object:getSquare()
        local allowOutsideGens = SandboxVars.AllowExteriorGenerator
        local generatorRange = 20 -- Completely unused in the IsoGenerator file for some reason so we get to redefine!

        local currX = square:getX()
        local currY = square:getY()

        local minX = currX - generatorRange
        local maxX = currX + generatorRange

        local minY = currY - generatorRange
        local maxY = currY + generatorRange

        local minZ = math.max(0, square:getZ() - 3)
        local maxZ = math.min(8, square:getZ() + 3)

        --[[if currMarker then
            getWorldMarkers:remove
        end]]

        --[[for zIterator = minZ, maxZ - 1 do
            for xIterator = minX, maxX - 1 do
                for yIterator = minY, maxY - 1 do
                    local withinRadius = IsoUtils.DistanceToSquared(xIterator + 0.5, yIterator + 0.5, currX + 0.5, currY + 0.5) <= (generatorRange * generatorRange)
                    if withinRadius and (allowOutsideGens or square:isOutside()) then
                        local newSq = getCell():getOrCreateGridSquare(xIterator, yIterator, zIterator);
                        if newSq then
                            --[[local floor = newSq:getFloor()
                            if floor then
                                floor:setHighlighted(true);
                                floor:setHighlightColor(1,1,0,0.2);
                            end
                        end
                    end
                end
            end
        end]]
        --print("rendering")
        currGenInstance.currMarkers = {} -- Add a new variable for this. Otherwise overwrite the original.
        for zIterator = minZ, maxZ - 1 do
            local newSq = getCell():getOrCreateGridSquare(currX, currY, zIterator);
            if newSq then
                local isActive = currGenInstance.object:isActivated()
                local r = isActive and 0 or 1
                local g = isActive and 1 or 0

                table.insert(currGenInstance.currMarkers, getWorldMarkers():addGridSquareMarker(newSq, r, g, 0.0, true, (generatorRange / 13) * 20))
            end
        end
    --end
end

local function clearMarkers(currGenInstance)
    local markers = currGenInstance.currMarkers
    if markers then
        for i = #markers, 1, -1 do
            local removedSuccessfully = getWorldMarkers():removeGridSquareMarker(markers[i])
            while not removedSuccessfully do
                removedSuccessfully = getWorldMarkers():removeGridSquareMarker(markers[i])
            end
            --print("Removed: "..tostring(removedSuccessfully))
            table.remove(markers, i)
        end
    end
end

--[[local function hookToTick(currGenInstance)
    if not hooked then
        hooked = true
        render(currGenInstance)
        --Events.OnTick.Add(render)
    end
end]]

local classicUpdate = ISGeneratorInfoWindow.update
function ISGeneratorInfoWindow:update()
    --if self:getIsVisible() then
    local wasOn = self.generatorOnLastUpdate
    if self.object:isActivated() ~= wasOn and self:getIsVisible() then
        --print("change Detected")
        self.generatorOnLastUpdate = self.object:isActivated()
        clearMarkers(self)
        render(self)
    end
    --end
    classicUpdate(self)
end

local classicVisible = ISGeneratorInfoWindow.setVisible
function ISGeneratorInfoWindow:setVisible(visible, joypadData)
    --print("Turning visible: "..tostring(visible))
    if visible then
        self.generatorOnLastUpdate = self.object:isActivated()
        --print("starting render..")
        clearMarkers(self)
        render(self)
    end
    classicVisible(self, visible, joypadData)
end

local classicInitial = ISGeneratorInfoWindow.initialise
function ISGeneratorInfoWindow:initalise()
    self.generatorOnLastUpdate = self.object:isActivated()
    classicInitial(self)
end

--[[local classicClose = ISGeneratorInfoWindow.close
function ISGeneratorInfoWindow:close()
    hooked = false
    for i = #currMarkers, 1, -1 do
        getWorldMarkers():removeGridSquareMarker(currMarkers[i])
        table.remove(currMarkers, i)
    end
    --Events.OnTick.Remove(render)
    classicClose(self)
end]]

local classicClose = ISGeneratorInfoWindow.removeFromUIManager
function ISGeneratorInfoWindow:removeFromUIManager() -- Overwrite the original method in ISCollapsableWindow. Should hopefully derive from ISCollapsableWindow and whatever THAT derives from.
    --hooked = false
    classicClose(self)
    clearMarkers(self)
end