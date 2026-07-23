--[[
    Active injector moodles: green Good backgrounds + item icons.
    Stacks with vanilla / BigMoodles / craving moodles.
]]

local SPACING = 36
local RIGHT_OFFSET = 46
local TOP_OFFSET = 100
local ICON_SIZE = 32
local ICON_PAD = 5
local MAX_TOOLTIP_LINES = 10

local OSC_RATE = 0.8
local OSC_SCALAR = 15.6
local OSC_START = 1.0
local OSC_DECAY = 0.04

local BKG_GOOD = {
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_1.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_2.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_3.png"),
    getTexture("media/ui/Moodles/Moodle_Bkg_Good_4.png"),
}

local iconCache = {}
local oscById = {}
local prevLevelById = {}

local function calcScale()
    local s = getCore():getScreenHeight() / 720 + 0.5
    s = s - s % 1
    if s < 1 then s = 1 end
    return s
end

local function getIcon(entry)
    if not entry then
        return nil
    end
    local key = entry.icon or entry.id
    if iconCache[key] ~= nil then
        return iconCache[key]
    end
    local tex = getTexture(entry.icon or ("Item_" .. tostring(entry.id)))
    if not tex and entry.id then
        tex = getTexture("item_" .. entry.id)
    end
    if not tex and entry.id then
        tex = getTexture("media/textures/item_" .. entry.id .. ".png")
    end
    iconCache[key] = tex
    return tex
end

local function stripTags(text)
    if not text or text == "" then
        return ""
    end
    text = text:gsub("<br%s*/?>", "\n")
    text = text:gsub("<BR%s*/?>", "\n")
    text = text:gsub("<LINE>", "\n")
    text = text:gsub("<[^>]+>", "")
    text = text:gsub("\r", "")
    text = text:gsub("\n+", "\n")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function splitLines(text)
    local lines = {}
    if not text or text == "" then
        return lines
    end
    for line in string.gmatch(text .. "\n", "(.-)\n") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            lines[#lines + 1] = line
        end
    end
    return lines
end

local function getDisplayName(entry)
    if entry.fullType then
        local n = getItemNameFromFullType(entry.fullType)
        if n and n ~= "" and n ~= entry.fullType then
            return n
        end
    end
    return entry.id or "Injector"
end

local function getTooltipLines(entry)
    local key = entry.tooltipKey
    local raw = key and getText(key) or ""
    if not raw or raw == "" or raw == key then
        raw = getText("Moodles_HT_Injector_fallback")
    end
    return splitLines(stripTags(raw))
end

local function levelLabel(level)
    return getText("Moodles_HT_Injector_lvl" .. tostring(level))
end

local function countActiveVanillaMoodles(player)
    local moodles = player:getMoodles()
    if not moodles then
        return 0
    end
    local count = 0
    local maxIndex = MoodleType.ToIndex(MoodleType.MAX)
    for i = 0, maxIndex - 1 do
        if moodles:getMoodleLevel(i) > 0 then
            count = count + 1
        end
    end
    return count
end

local function countCravingMoodles(player)
    if not HT_CravingMoodles_CountActive then
        return 0
    end
    return HT_CravingMoodles_CountActive(player)
end

local function isBigMoodlesActive(playerNum)
    local moodleUI = UIManager.getMoodleUI(playerNum or 0)
    if moodleUI and moodleUI:isVisible() then
        return false
    end
    return moodleUI == nil or not moodleUI:isVisible()
end

local stackOscillator = 0
local stackOscillatorStep = 0

local function updateStackOscillator()
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    stackOscillatorStep = stackOscillatorStep + OSC_RATE * 0.5 * dt
    stackOscillator = math.sin(stackOscillatorStep) * OSC_SCALAR
end

--[[
    Draw active injector icons into an existing moodle stack.
    Returns the next free slot index.
]]
function HT_InjectorMoodles_AppendToStack(panel, player, slot, scale, fontHgt)
    if not panel or not player or not HT_InjectorStatus then
        return slot
    end

    updateStackOscillator()
    local dt = UIManager.getMillisSinceLastRender() / 33.3
    if dt < 0.1 then
        dt = 0.1
    end

    local list = HT_InjectorStatus.GetActive(player)
    scale = scale or 1
    slot = slot or 0
    fontHgt = fontHgt or getTextManager():getFontHeight(UIFont.Small)

    for i = 1, #list do
        local entry = list[i]
        local id = entry.id
        local level = HT_InjectorStatus.GetLevel(entry)
        local prev = prevLevelById[id] or 0
        if level ~= prev then
            oscById[id] = level > 0 and OSC_START or 0
            prevLevelById[id] = level
        end

        local shaking = HT_InjectorStatus.ShouldShake(entry)
        local osc = oscById[id] or 0
        if shaking then
            osc = math.max(osc, 0.55)
            oscById[id] = osc
        elseif osc > 0 then
            osc = osc - osc * OSC_DECAY * dt
            if osc < 0.01 then
                osc = 0
            end
            oscById[id] = osc
        end

        if level > 0 then
            local y = slot * SPACING * scale
            local x = stackOscillator * osc * scale
            local bkg = BKG_GOOD[level] or BKG_GOOD[1]
            local icon = getIcon(entry)
            if bkg then
                panel:drawTextureScaledUniform(bkg, x, y, scale, 1, 1, 1, 1)
            end
            if icon then
                local pad = ICON_PAD * scale
                local iconSize = (ICON_SIZE - ICON_PAD * 2) * scale
                panel:drawTextureScaled(icon, x + pad, y + pad, iconSize, iconSize, 1, 1, 1, 1)
            end

            local hovered = false
            if panel:isMouseOver() then
                local mx = panel:getMouseX()
                local my = panel:getMouseY()
                hovered = mx >= 0 and mx < ICON_SIZE * scale and my >= y and my < y + ICON_SIZE * scale
            end

            -- Always-visible code + timer (hidden while full tooltip is open).
            if not hovered then
                local timeStr = HT_InjectorStatus.FormatTime(entry.remaining)
                local label = HT_InjectorStatus.GetShortLabel(entry) .. " " .. timeStr
                local labelW = getTextManager():MeasureStringX(UIFont.Small, label)
                local labelX = x - 6 * scale
                local labelY = y + (ICON_SIZE * scale - fontHgt) * 0.5
                local lr, lg, lb = 0.92, 0.95, 0.85
                if shaking then
                    lr, lg, lb = 1.0, 0.85, 0.35
                end
                panel:drawTextureScaled(nil, labelX - labelW - 4, labelY - 1, labelW + 8, fontHgt + 2, 0.45, 0, 0, 0)
                panel:drawTextRight(label, labelX, labelY, lr, lg, lb, 1, UIFont.Small)
            end

            if hovered then
                    local timeStr = HT_InjectorStatus.FormatTime(entry.remaining)
                    local name = getDisplayName(entry) .. "  " .. timeStr
                    local status = levelLabel(level)
                    local tipLines = getTooltipLines(entry)
                    local lines = { name, status }
                    for li = 1, math.min(#tipLines, MAX_TOOLTIP_LINES - 2) do
                        lines[#lines + 1] = tipLines[li]
                    end

                    local textW = 0
                    for li = 1, #lines do
                        textW = math.max(textW, getTextManager():MeasureStringX(UIFont.Small, lines[li]))
                    end
                    local boxH = (2 + fontHgt) * #lines
                    panel:drawTextureScaled(nil, -16 - textW, y - 1, textW + 12, boxH, 0.6, 0, 0, 0)
                    for li = 1, #lines do
                        local a = (li <= 2) and 1 or 0.85
                        panel:drawTextRight(lines[li], -10, y + 1 + (li - 1) * fontHgt, a, a, a, 1, UIFont.Small)
                    end
            end

            slot = slot + 1
        end
    end

    return slot
end

local HT_InjectorMoodles = ISUIElement:derive("HT_InjectorMoodles")
local panels = {}

function HT_InjectorMoodles:new(playerNum, player)
    local o = ISUIElement:new(0, 0, ICON_SIZE, SPACING * 8)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.player = player
    o.scale = 1
    o:setWantKeyEvents(false)
    return o
end

function HT_InjectorMoodles:updatePosition()
    local playerNum = self.playerNum
    local left = getPlayerScreenLeft(playerNum)
    local top = getPlayerScreenTop(playerNum)
    local width = getPlayerScreenWidth(playerNum)
    local above = countActiveVanillaMoodles(self.player) + countCravingMoodles(self.player)
    local distY = SPACING
    local activeCount = HT_InjectorStatus and HT_InjectorStatus.CountActive(self.player) or 0

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
            self:setY(ay + above * distY)
            self:setWidth(ICON_SIZE)
            self:setHeight(math.max(SPACING, activeCount * SPACING))
            return
        end
    end

    self.scale = 1
    self:setX(left + width - RIGHT_OFFSET - ICON_SIZE)
    self:setY(top + TOP_OFFSET + above * SPACING)
    self:setWidth(ICON_SIZE)
    self:setHeight(math.max(SPACING, activeCount * SPACING))
end

function HT_InjectorMoodles:render()
    if not self.player or self.player:isDead() then
        return
    end
    if isBigMoodlesActive(self.playerNum) then
        return
    end
    if not HT_InjectorStatus or HT_InjectorStatus.CountActive(self.player) < 1 then
        return
    end

    self:updatePosition()
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    HT_InjectorMoodles_AppendToStack(self, self.player, 0, self.scale, fontHgt)
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

    if isBigMoodlesActive(playerNum) then
        removePanel(playerNum)
        return
    end

    local panel = panels[playerNum]
    if not panel then
        panel = HT_InjectorMoodles:new(playerNum, player)
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

local function onCreatePlayer(playerIndex, player)
    if player ~= getSpecificPlayer(playerIndex) then
        return
    end
    ensurePanel(playerIndex)
end

local function onGameStart()
    for i = 0, getNumActivePlayers() - 1 do
        ensurePanel(i)
    end
end

local updateAccum = 0
local function onPlayerUpdate(player)
    local playerNum = player:getPlayerNum()
    if player ~= getSpecificPlayer(playerNum) then
        return
    end
    updateAccum = updateAccum + 1
    if updateAccum < 15 then
        return
    end
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
