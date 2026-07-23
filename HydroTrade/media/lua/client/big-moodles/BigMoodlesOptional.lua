local enabled = false
local scale = 1
local panels = {}

local SPACING = 36
local RIGHT_OFFSET = 46
local TOP_OFFSET = 100
local ICON_SIZE = 32

local BKG_GOOD = {
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_1.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_2.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_3.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png"),
}
local BKG_BAD = {
    getTexture("media/ui/Moodles/Moodle_Bkg_Bad_1.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Bad_2.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Bad_3.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Bad_4.png"),
}
local BKG_NEUTRAL = BKG_BAD[1]

-- Order must match MoodleType.FromIndex (not enum ordinal):
-- ... Zombie(18), FoodEaten(19), Hyperthermia(20), Hypothermia(21), Windchill(22), CantSprint(23)
local ICON_PATHS = {
    "media/ui/Moodles/Moodle_Icon_Endurance.png",
    "media/ui/Moodles/Moodle_Icon_Tired.png",
    "media/ui/Moodles/Moodle_Icon_Hungry.png",
    "media/ui/Moodles/Moodle_Icon_Panic.png",
    "media/ui/Moodles/Moodle_Icon_Sick.png",
    "media/ui/Moodles/Moodle_Icon_Bored.png",
    "media/ui/Moodles/Moodle_Icon_Unhappy.png",
    "media/ui/Moodles/Moodle_Icon_Bleeding.png",
    "media/ui/Moodles/Moodle_Icon_Wet.png",
    "media/ui/Moodles/Moodle_Icon_Cold.png",
    "media/ui/Moodles/Moodle_Icon_Angry.png",
    "media/ui/Moodles/Moodle_Icon_Stressed.png",
    "media/ui/Moodles/Moodle_Icon_Thirsty.png",
    "media/ui/Moodles/Moodle_Icon_Injured.png",
    "media/ui/Moodles/Moodle_Icon_Pain.png",
    "media/ui/Moodles/Moodle_Icon_HeavyLoad.png",
    "media/ui/Moodles/Moodle_Icon_Drunk.png",
    "media/ui/Moodles/Moodle_Icon_Dead.png",
    "media/ui/Moodles/Moodle_Icon_Zombie.png",
    "media/ui/Moodles/Moodle_Icon_Hungry.png",
    "media/ui/weather/Moodle_Icon_TempHot.png",
    "media/ui/weather/Moodle_Icon_TempCold.png",
    "media/ui/Moodle_Icon_Windchill.png",
    "media/ui/Moodle_Icon_CantSprint.png",
}

local icons = {}
for i = 1, #ICON_PATHS do
    icons[i - 1] = getTexture(ICON_PATHS[i])
end

local function calcScale()
    local s = getCore():getScreenHeight() / 720 + 0.5
    s = s - s % 1
    if s < 1 then s = 1 end
    return s
end

-- MoodleType.GoodBadNeutral: 1 = good, 2 = bad
local function getBackground(gbn, level)
    if gbn == 1 then return BKG_GOOD[level] or BKG_GOOD[1] end
    if gbn == 2 then return BKG_BAD[level] or BKG_BAD[1] end
    return BKG_NEUTRAL
end

local function hideVanillaMoodles()
    for i = 0, 3 do
        local moodleUI = UIManager.getMoodleUI(i)
        if moodleUI then
            moodleUI:setVisible(false)
            UIManager.RemoveElement(moodleUI)
        end
    end
end

local function restoreVanillaMoodles()
    local ui = UIManager.getUI()
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local moodleUI = UIManager.getMoodleUI(i)
            if not moodleUI then
                local ok = pcall(function()
                    local m = MoodlesUI.new()
                    m:setCharacter(player)
                    UIManager.setMoodleUI(i, m)
                    ui:add(m)
                end)
                if not ok then
                    print("BigMoodles: failed to restore vanilla moodles for player " .. i)
                end
            else
                moodleUI:setCharacter(player)
                moodleUI:setVisible(true)
                if not moodleUI:getParent() then
                    ui:add(moodleUI)
                end
            end
        end
    end
end

local function setVanillaVisible(visible)
    if visible then
        restoreVanillaMoodles()
    else
        hideVanillaMoodles()
    end
end

local ISScaledMoodles = ISUIElement:derive("ISScaledMoodles")

local OSC_RATE = 0.8
local OSC_SCALAR = 15.6
local OSC_START = 1.0
local OSC_DECAY = 0.04

local oscillator = 0
local oscillatorStep = 0

local function updateOscillator()
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    oscillatorStep = oscillatorStep + OSC_RATE * 0.5 * dt
    oscillator = math.sin(oscillatorStep) * OSC_SCALAR
end

function ISScaledMoodles:new(playerNum, player)
    local o = ISUIElement:new(0, 0, ICON_SIZE, 500)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.player = player
    o.scale = scale
    o.prevLevels = {}
    o.oscLevels = {}
    o:setWantKeyEvents(false)
    return o
end

function ISScaledMoodles:updatePosition()
    self.scale = scale
    local left = getPlayerScreenLeft(self.playerNum)
    local top = getPlayerScreenTop(self.playerNum)
    local width = getPlayerScreenWidth(self.playerNum)
    self:setX(left + width - RIGHT_OFFSET - ICON_SIZE * self.scale)
    self:setY(top + TOP_OFFSET)
    self:setWidth(ICON_SIZE * self.scale)
end

function ISScaledMoodles:render()
    if not self.player or self.player:isDead() then return end

    local moodles = self.player:getMoodles()
    if not moodles then return end

    updateOscillator()

    local maxIndex = MoodleType.ToIndex(MoodleType.MAX)
    local slot = 0
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    if dt < 0.1 then dt = 0.1 end

    for i = 0, maxIndex - 1 do
        local level = moodles:getMoodleLevel(i)
        local prev = self.prevLevels[i] or 0

        if level ~= prev then
            if level > 0 then
                self.oscLevels[i] = OSC_START
            else
                self.oscLevels[i] = 0
            end
            self.prevLevels[i] = level
        end

        local osc = self.oscLevels[i] or 0
        if osc > 0 then
            osc = osc - osc * OSC_DECAY * dt
            if osc < 0.01 then osc = 0 end
            self.oscLevels[i] = osc
        end

        if level > 0 then
            local y = slot * SPACING * self.scale
            local x = oscillator * osc * self.scale
            local gbn = moodles:getGoodBadNeutral(i)
            local bkg = getBackground(gbn, level)
            local icon = icons[i]
            if bkg and icon then
                self:drawTextureScaledUniform(bkg, x, y, self.scale, 1, 1, 1, 1)
                self:drawTextureScaledUniform(icon, x, y, self.scale, 1, 1, 1, 1)
            end

            if self:isMouseOver() then
                local mx = self:getMouseX()
                local my = self:getMouseY()
                if mx >= 0 and mx < ICON_SIZE * self.scale and my >= y and my < y + ICON_SIZE * self.scale then
                    local mt = MoodleType.FromIndex(i)
                    local name = MoodleType.getDisplayName(mt, level)
                    local desc = MoodleType.getDescriptionText(mt, level)
                    local textW = math.max(
                        getTextManager():MeasureStringX(UIFont.Small, name),
                        getTextManager():MeasureStringX(UIFont.Small, desc)
                    )
                    self:drawTextureScaled(nil, -16 - textW, y - 1, textW + 12, (2 + fontHgt) * 2, 0.6, 0, 0, 0)
                    self:drawTextRight(name, -10, y + 1, 1, 1, 1, 1, UIFont.Small)
                    self:drawTextRight(desc, -10, y + fontHgt + 1, 0.8, 0.8, 0.8, 1, UIFont.Small)
                end
            end

            slot = slot + 1
        end
    end

    -- Append HydroTrade craving + injector moodles into the same stack
    if HT_CravingMoodles_AppendToStack then
        slot = HT_CravingMoodles_AppendToStack(self, self.player, slot, self.scale, fontHgt) or slot
    end
    if HT_InjectorMoodles_AppendToStack then
        HT_InjectorMoodles_AppendToStack(self, self.player, slot, self.scale, fontHgt)
    end
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

    local panel = panels[playerNum]
    if not panel then
        panel = ISScaledMoodles:new(playerNum, player)
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

local function refreshPanels()
    if not enabled then
        for i = 0, 3 do
            removePanel(i)
        end
        setVanillaVisible(true)
        return
    end

    setVanillaVisible(false)
    for i = 0, getNumActivePlayers() - 1 do
        ensurePanel(i)
    end
    for i = getNumActivePlayers(), 3 do
        removePanel(i)
    end
end

local statsAPI = nil
local oldAdjustPositions = nil

local function hookStatsAPI()
    if statsAPI or not getActivatedMods():contains("StatsAPI") then return end

    local ok, LuaMoodles = pcall(require, "StatsAPI/moodles/LuaMoodles")
    if not ok then return end

    statsAPI = LuaMoodles
    oldAdjustPositions = LuaMoodles.adjustPositions
    LuaMoodles.adjustPositions = function()
        if enabled then
            LuaMoodles.scale = calcScale()
        else
            LuaMoodles.scale = 1
        end
        oldAdjustPositions()
    end
end

local function applyOption(value)
    enabled = value == true
    scale = enabled and calcScale() or 1

    hookStatsAPI()

    if statsAPI then
        statsAPI.scale = scale
        statsAPI.adjustPositions()
        return
    end

    refreshPanels()
end

local function onCreatePlayer(playerIndex)
    if enabled and not statsAPI then
        hideVanillaMoodles()
        ensurePanel(playerIndex)
    end
end

local function onResolutionChange()
    scale = enabled and calcScale() or 1
    if statsAPI then
        statsAPI.adjustPositions()
        return
    end
    if enabled then
        hideVanillaMoodles()
    end
    for i = 0, 3 do
        local panel = panels[i]
        if panel then
            panel:updatePosition()
        end
    end
end

local function onGameStart()
    if enabled and not statsAPI then
        refreshPanels()
    end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)
Events.OnResolutionChange.Add(onResolutionChange)

Events.OnTickEvenPaused.Add(function()
    if enabled and not statsAPI then
        hideVanillaMoodles()
    end
end)

if ModOptions and ModOptions.getInstance then
    local function onModOptionsApply(optionValues)
        applyOption(optionValues.settings.options.big_moodles_enabled)
    end

    local SETTINGS = {
        options_data = {
            big_moodles_enabled = {
                name = "UI_BigMoodles_Enable",
                tooltip = "UI_BigMoodles_Enable_tooltip",
                default = false,
                OnApplyMainMenu = onModOptionsApply,
                OnApplyInGame = onModOptionsApply,
            },
        },
        mod_id = "HydroTrade_h",
        mod_shortname = "HydroTrade",
        mod_fullname = "HydroTrade",
    }

    ModOptions:getInstance(SETTINGS)
    ModOptions:loadFile()
    Events.OnPreMapLoad.Add(function()
        onModOptionsApply({ settings = SETTINGS })
    end)
else
    Events.OnGameStart.Add(function()
        applyOption(false)
    end)
end
