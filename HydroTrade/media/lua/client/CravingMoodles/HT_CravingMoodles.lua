--[[
    HT Craving Moodles: qualitative protein / fat / carb deficit indicators.
    Client-only. Renders in the same moodle stack as vanilla / BigMoodles.
]]

local SPACING = 36
local RIGHT_OFFSET = 46
local TOP_OFFSET = 100
local ICON_SIZE = 32
-- Inventory icons are full-bleed 32x32; inset so they sit inside the amber rim.
local ICON_PAD = 5

local OSC_RATE = 0.8
local OSC_SCALAR = 15.6
local OSC_START = 1.0
local OSC_DECAY = 0.04

-- Custom amber circles (thin white rim, no red). Alpha baked into PNG for icon readability.
local BKG_AMBER = {
    getTexture("media/ui/Moodles/Moodle_Bkg_HT_Amber_1.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_HT_Amber_2.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_HT_Amber_3.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_HT_Amber_4.png"),
}

-- Vanilla inventory icons from UI.pack / UI2.pack (same as item scripts Icon=).
local CRAVINGS = {
    {
        key = "HT_CraveProtein",
        icon = getTexture("Item_Steak"),
        getValue = function(nut) return nut:getProteins() end,
    },
    {
        key = "HT_CraveLipids",
        icon = getTexture("Item_Butter"),
        getValue = function(nut) return nut:getLipids() end,
    },
    {
        key = "HT_CraveCarbs",
        icon = getTexture("Item_Bread"),
        getValue = function(nut) return nut:getCarbohydrates() end,
    },
}

local hudEnabled = true

function HT_CravingMoodles_IsHudEnabled()
    return hudEnabled
end

-- Nutrition clamp is -500..1000. Show only on deficit.
function HT_CravingMoodleLevel(value)
    if not value or value >= 0 then return 0 end
    if value >= -100 then return 1 end
    if value >= -250 then return 2 end
    if value >= -400 then return 3 end
    return 4
end

local levelFromValue = HT_CravingMoodleLevel

local function calcScale()
    local s = getCore():getScreenHeight() / 720 + 0.5
    s = s - s % 1
    if s < 1 then s = 1 end
    return s
end

local function nutritionEnabled()
    if SandboxVars and SandboxVars.Nutrition == false then
        return false
    end
    return true
end

local function countActiveVanillaMoodles(player)
    local moodles = player:getMoodles()
    if not moodles then return 0 end
    local count = 0
    local maxIndex = MoodleType.ToIndex(MoodleType.MAX)
    for i = 0, maxIndex - 1 do
        if moodles:getMoodleLevel(i) > 0 then
            count = count + 1
        end
    end
    return count
end

local function getCravingLevels(player)
    local levels = { 0, 0, 0 }
    if not player or player:isDead() or not nutritionEnabled() then
        return levels
    end
    local nut = player:getNutrition()
    if not nut then return levels end
    for i = 1, #CRAVINGS do
        levels[i] = levelFromValue(CRAVINGS[i].getValue(nut))
    end
    return levels
end

function HT_CravingMoodles_CountActive(player)
    if not hudEnabled or not player then
        return 0
    end
    local levels = getCravingLevels(player)
    local n = 0
    for i = 1, #levels do
        if (levels[i] or 0) > 0 then
            n = n + 1
        end
    end
    return n
end

local function isBigMoodlesActive(playerNum)
    local moodleUI = UIManager.getMoodleUI(playerNum or 0)
    if moodleUI and moodleUI:isVisible() then
        return false
    end
    return moodleUI == nil or not moodleUI:isVisible()
end

local cravingOsc = { 0, 0, 0 }
local cravingPrev = { 0, 0, 0 }
local stackOscillator = 0
local stackOscillatorStep = 0

local function updateStackOscillator()
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    stackOscillatorStep = stackOscillatorStep + OSC_RATE * 0.5 * dt
    stackOscillator = math.sin(stackOscillatorStep) * OSC_SCALAR
end

--[[
    Draw craving icons into an existing moodle stack renderer.
    Returns the next free slot index.
]]
function HT_CravingMoodles_AppendToStack(panel, player, slot, scale, fontHgt)
    if not hudEnabled then
        return slot
    end
    if not panel or not player or not nutritionEnabled() then
        return slot
    end

    updateStackOscillator()
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    if dt < 0.1 then dt = 0.1 end

    local levels = getCravingLevels(player)
    local showAdminDebug = isAdmin()
    local nut = showAdminDebug and player:getNutrition() or nil
    scale = scale or 1
    slot = slot or 0

    for i = 1, #CRAVINGS do
        local level = levels[i] or 0
        local prev = cravingPrev[i] or 0
        if level ~= prev then
            cravingOsc[i] = level > 0 and OSC_START or 0
            cravingPrev[i] = level
        end

        local osc = cravingOsc[i] or 0
        if osc > 0 then
            osc = osc - osc * OSC_DECAY * dt
            if osc < 0.01 then osc = 0 end
            cravingOsc[i] = osc
        end

        if level > 0 then
            local y = slot * SPACING * scale
            local x = stackOscillator * osc * scale
            local bkg = BKG_AMBER[level] or BKG_AMBER[1]
            local icon = CRAVINGS[i].icon
            if bkg and icon then
                panel:drawTextureScaledUniform(bkg, x, y, scale, 1, 1, 1, 1)
                local pad = ICON_PAD * scale
                local iconSize = (ICON_SIZE - ICON_PAD * 2) * scale
                panel:drawTextureScaled(icon, x + pad, y + pad, iconSize, iconSize, 1, 1, 1, 1)
            end

            if panel:isMouseOver() then
                local mx = panel:getMouseX()
                local my = panel:getMouseY()
                if mx >= 0 and mx < ICON_SIZE * scale and my >= y and my < y + ICON_SIZE * scale then
                    local name = getText("Moodles_" .. CRAVINGS[i].key .. "_lvl" .. level)
                    local desc = getText("Moodles_" .. CRAVINGS[i].key .. "_desc_lvl" .. level)
                    if showAdminDebug and nut then
                        local raw = CRAVINGS[i].getValue(nut)
                        desc = string.format("%s  [L%d  %.1f]", desc, level, raw)
                    end
                    local textW = math.max(
                        getTextManager():MeasureStringX(UIFont.Small, name),
                        getTextManager():MeasureStringX(UIFont.Small, desc)
                    )
                    panel:drawTextureScaled(nil, -16 - textW, y - 1, textW + 12, (2 + fontHgt) * 2, 0.6, 0, 0, 0)
                    panel:drawTextRight(name, -10, y + 1, 1, 1, 1, 1, UIFont.Small)
                    panel:drawTextRight(desc, -10, y + fontHgt + 1, 0.8, 0.8, 0.8, 1, UIFont.Small)
                end
            end

            slot = slot + 1
        end
    end

    return slot
end

local HT_CravingMoodles = ISUIElement:derive("HT_CravingMoodles")
local panels = {}

function HT_CravingMoodles:new(playerNum, player)
    local o = ISUIElement:new(0, 0, ICON_SIZE, SPACING * 3)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.player = player
    o.scale = 1
    o:setWantKeyEvents(false)
    return o
end

function HT_CravingMoodles:updatePosition()
    local playerNum = self.playerNum
    local left = getPlayerScreenLeft(playerNum)
    local top = getPlayerScreenTop(playerNum)
    local width = getPlayerScreenWidth(playerNum)
    local vanillaCount = countActiveVanillaMoodles(self.player)
    local distY = SPACING

    local moodleUI = UIManager.getMoodleUI(playerNum)
    if moodleUI and moodleUI:isVisible() then
        local okX, ax = pcall(function() return moodleUI:getAbsoluteX() end)
        local okY, ay = pcall(function() return moodleUI:getAbsoluteY() end)
        if moodleUI.MoodleDistY and moodleUI.MoodleDistY > 0 then
            distY = moodleUI.MoodleDistY
        end
        self.scale = 1
        if okX and okY and ax and ay then
            self:setX(ax)
            self:setY(ay + vanillaCount * distY)
            self:setWidth(ICON_SIZE)
            self:setHeight(SPACING * 3)
            return
        end
    end

    self.scale = 1
    self:setX(left + width - RIGHT_OFFSET - ICON_SIZE)
    self:setY(top + TOP_OFFSET + vanillaCount * SPACING)
    self:setWidth(ICON_SIZE)
    self:setHeight(SPACING * 3)
end

function HT_CravingMoodles:render()
    if not hudEnabled then return end
    if not self.player or self.player:isDead() then return end
    if not nutritionEnabled() then return end
    if isBigMoodlesActive(self.playerNum) then
        return
    end

    self:updatePosition()
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    HT_CravingMoodles_AppendToStack(self, self.player, 0, self.scale, fontHgt)
end

local function removePanel(playerNum)
    local panel = panels[playerNum]
    if panel then
        panel:removeFromUIManager()
        panels[playerNum] = nil
    end
end

local function ensurePanel(playerNum)
    local player = getSpecificPlayer(playerNum)
    if not player then
        removePanel(playerNum)
        return
    end

    if not hudEnabled then
        removePanel(playerNum)
        return
    end

    if isBigMoodlesActive(playerNum) then
        removePanel(playerNum)
        return
    end

    local panel = panels[playerNum]
    if not panel then
        panel = HT_CravingMoodles:new(playerNum, player)
        panel:initialise()
        panel:instantiate()
        panels[playerNum] = panel
        panel:addToUIManager()
    else
        panel.player = player
    end
    panel:updatePosition()
    panel:setVisible(true)
end

function HT_CravingMoodles_SetHudEnabled(enabled)
    hudEnabled = enabled == true
    for i = 0, getNumActivePlayers() - 1 do
        ensurePanel(i)
    end
    if not hudEnabled then
        for i = 0, 3 do
            removePanel(i)
        end
    end
end

local function onCreatePlayer(playerIndex, player)
    if player ~= getSpecificPlayer(playerIndex) then return end
    ensurePanel(playerIndex)
end

local function syncHudFromClientOptions()
    local enabled = true
    if ClientTweaker and ClientTweaker.Options and ClientTweaker.Options.GetBool then
        enabled = ClientTweaker.Options.GetBool("show_craving_moodles")
    end
    HT_CravingMoodles_SetHudEnabled(enabled)
end

local function onGameStart()
    syncHudFromClientOptions()
    for i = 0, getNumActivePlayers() - 1 do
        ensurePanel(i)
    end
end

local updateAccum = 0
local function onPlayerUpdate(player)
    local playerNum = player:getPlayerNum()
    if player ~= getSpecificPlayer(playerNum) then return end
    updateAccum = updateAccum + 1
    if updateAccum < 15 then return end
    updateAccum = 0
    ensurePanel(playerNum)
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnResolutionChange.Add(function()
    for i = 0, 3 do
        ensurePanel(i)
    end
end)
