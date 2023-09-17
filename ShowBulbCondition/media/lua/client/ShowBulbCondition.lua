ModShowBulbCondition = {}

local ISInventoryPane = ISInventoryPane
local Perks = Perks
local SandboxVars = SandboxVars
local getCore = getCore
local getSpecificPlayer = getSpecificPlayer
local isAltKeyDown = isAltKeyDown
local round = round

function ModShowBulbCondition:init()
    self.SandboxVars = SandboxVars.ShowBulbCondition or {}
    self.SandboxVars.RequireElectricityLevel = self.SandboxVars.RequireElectricityLevel or 0

    self.BulbTable = {
        ["Base.LightBulb"] = true,
        ["Base.LightBulbRed"] = true,
        ["Base.LightBulbGreen"] = true,
        ["Base.LightBulbBlue"] = true,
        ["Base.LightBulbYellow"] = true,
        ["Base.LightBulbCyan"] = true,
        ["Base.LightBulbMagenta"] = true,
        ["Base.LightBulbOrange"] = true,
        ["Base.LightBulbPurple"] = true,
        ["Base.LightBulbPink"] = true,
    }

    local color = getCore():getGoodHighlitedColor()
    self.fgBar = {r=color:getR(), g=color:getG(), b=color:getB(), a=1}
    self.fgText = {r=0.8, g=0.8, b=0.8, a=0.8}
    return self
end
local mod = ModShowBulbCondition:init()

local ISInventoryPane_prerender = ISInventoryPane.prerender
function ISInventoryPane:prerender()
    local playerObj = getSpecificPlayer(self.player)
    self.playerElectricityLevel = playerObj:getPerkLevel(Perks.Electricity)
    ISInventoryPane_prerender(self)
end

local ISInventoryPane_drawItemDetails = ISInventoryPane.drawItemDetails
function ISInventoryPane:drawItemDetails(item, y, xoff, yoff, red)
    if item and mod.BulbTable[item:getFullType()] and self.playerElectricityLevel >= mod.SandboxVars.RequireElectricityLevel then
        local condition = item:getCondition()
        local conditionMax = item:getConditionMax()
        local progress = condition / conditionMax
        local text
        if isAltKeyDown() then
            local repaired = item:getHaveBeenRepaired() - 1
            if repaired == 0 then
                text = ""
            else
                text = repaired .. "x"
            end
        else
            text = round(progress * 100) .. "%"
        end
        local top = self.headerHgt + y * self.itemHgt + yoff
        self:drawTextAndProgressBar(text, progress, xoff, top, mod.fgText, mod.fgBar)
    else
        ISInventoryPane_drawItemDetails(self, item, y, xoff, yoff, red)
    end
end
