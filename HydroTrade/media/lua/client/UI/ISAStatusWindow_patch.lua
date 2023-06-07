local activeMods = getActivatedMods()
if not activeMods:contains("ISA_41") then
    return
end

local isa = require "ISAUtilities"
local statusWindow = isa.StatusWindow
--require "ISAStatusWindow"
local function render()
    --if currGenInstance:getIsVisible() then
        local square = statusWindow.instance.luaPB:getSquare()
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
        
        print("rendering")
        statusWindow.currMarkers = {} -- Add a new variable for this. Otherwise overwrite the original.
        for zIterator = minZ, maxZ - 1 do
            local newSq = getCell():getOrCreateGridSquare(currX, currY, zIterator);
            if newSq then
                local luaObject = statusWindow.instance.luaPB
                local isActive = luaObject.on and luaObject.charge > 0
                local r = isActive and 0 or 1
                local g = isActive and 1 or 0

                table.insert(statusWindow.currMarkers, getWorldMarkers():addGridSquareMarker(newSq, r, g, 0.0, true, (generatorRange / 13) * 20))
            end
        end
    --end
end



local function clearMarkers()
    local markers = statusWindow.currMarkers
    if markers then
        for i = #markers, 1, -1 do
            local removedSuccessfully = getWorldMarkers():removeGridSquareMarker(markers[i])
            while not removedSuccessfully do
                removedSuccessfully = getWorldMarkers():removeGridSquareMarker(markers[i])
            end
            print("Removed: "..tostring(removedSuccessfully))
            table.remove(markers, i)
        end
    end
end

local classicRender = statusWindow.render
function statusWindow:render()
    --if self:getIsVisible() then
    local wasOn = statusWindow.instance.generatorOnLastUpdate
    local luaObject = statusWindow.instance.luaPB
    if luaObject then
        local isOn = luaObject.on and luaObject.charge > 0
        if isOn ~= wasOn and self:getIsVisible() then
            print("change Detected")
            statusWindow.instance.generatorOnLastUpdate = isOn
            clearMarkers()
            render()
        end
    end
    --end
    classicRender(self)
end

--[[local classicVisible = statusWindow.setVisible
function statusWindow:setVisible(visible, joypadData)
    print("Turning visible: "..tostring(visible))
    if visible then
        print("Visible! Fetching lua object..")
        local luaObject = statusWindow.instance.luaPB
        print(luaObject)
        if luaObject then
            local isOn = luaObject.on and luaObject.charge > 0
            self.generatorOnLastUpdate = isOn
            print("starting render..")
            clearMarkers(self)
            render(self)
        end
    end
    classicVisible(self, visible, joypadData)
end]]

local classicOpenPanel = statusWindow.OnOpenPanel
function statusWindow.OnOpenPanel(...)
    classicOpenPanel(...)
    --if visible then
    print("Visible! Fetching lua object..")
    local luaObject = statusWindow.instance.luaPB
    print(luaObject)
    if luaObject then
        local isOn = luaObject.on and luaObject.charge > 0
        statusWindow.instance.generatorOnLastUpdate = isOn
        print("starting render..")
        clearMarkers()
        render()
    end
    --end
end

local classicInitial = statusWindow.initialise
function statusWindow:initalise()
    local luaObject = statusWindow.instance.luaPB
    if luaObject then
        local isOn = luaObject.on and luaObject.charge > 0
        statusWindow.instance.generatorOnLastUpdate = isOn
    end
    classicInitial(self)
end

local classicClose = statusWindow.removeFromUIManager
function statusWindow:removeFromUIManager() -- Overwrite the original method in ISCollapsableWindow. Should hopefully derive from ISCollapsableWindow and whatever THAT derives from.
    clearMarkers()
    classicClose(self)
end