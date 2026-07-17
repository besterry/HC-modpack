if isServer() then return end

require "ISUI/ISPanel"
require "ISUI/ISToolTip"

WalletBalanceHUD = ISPanel:derive("WalletBalanceHUD")

local CONF_FILE = "WalletBalanceHUD.ini"
local CLOCK_GAP = -1 -- общая линия рамки с часами
local SCREEN_MARGIN = 8
local MOODLE_FALLBACK = 72

local CHIP_W = 12
local CHIP_H = 15
local BODY_PAD = 3
local SCREEN_INSET = 2
local SEP = " · "

-- Корпус ближе к часам: тёмный, тонкая рамка
local BODY = { r = 0.05, g = 0.05, b = 0.06, a = 0.78 }
local BODY_EDGE = { r = 0.45, g = 0.45, b = 0.45, a = 0.55 }
local CHIP = { r = 0.30, g = 0.26, b = 0.14, a = 0.75 }
local CHIP_LINE = { r = 0.48, g = 0.40, b = 0.20, a = 0.50 }
local SCREEN = { r = 0.02, g = 0.03, b = 0.025, a = 0.90 }
local SCREEN_EDGE = { r = 0.18, g = 0.20, b = 0.16, a = 0.40 }

-- Приглушённый зелёный баланс / золотистый special
local LED_GREEN = { r = 0.30, g = 0.62, b = 0.36, a = 0.78 }
local LED_GREEN_DIM = { r = 0.12, g = 0.28, b = 0.16, a = 0.35 }
local LED_GOLD = { r = 0.62, g = 0.50, b = 0.22, a = 0.78 }
local LED_GOLD_DIM = { r = 0.28, g = 0.22, b = 0.10, a = 0.35 }
local LED_SEP = { r = 0.35, g = 0.35, b = 0.32, a = 0.50 }

local function loadPref()
    local reader = getFileReader(CONF_FILE, true)
    if not reader then
        return false
    end
    local line = reader:readLine()
    reader:close()
    return line == "1"
end

local function savePref(visible)
    local writer = getFileWriter(CONF_FILE, true, false)
    if not writer then
        return
    end
    writer:write(visible and "1" or "0")
    writer:close()
end

function WalletBalanceHUD.isPrefVisible()
    return WalletBalanceHUD.prefVisible == true
end

function WalletBalanceHUD.setPrefVisible(visible)
    WalletBalanceHUD.prefVisible = visible and true or false
    savePref(WalletBalanceHUD.prefVisible)
    if WalletBalanceHUD.instance then
        WalletBalanceHUD.instance:syncVisibility()
    end
end

function WalletBalanceHUD.togglePref()
    WalletBalanceHUD.setPrefVisible(not WalletBalanceHUD.isPrefVisible())
end

local function getLinkedWornWallet(player)
    if not player then
        return nil
    end
    local wallet = player:getWornItem("Wallet")
    if not wallet then
        return nil
    end
    local md = wallet:getModData()
    if not md or not md.linkedTo or not md.belongsTo then
        return nil
    end
    local username = player:getUsername()
    if md.belongsTo ~= username then
        return nil
    end
    local account = Balance.getUserAccount(username)
    if not account or account.linkedTo ~= md.linkedTo then
        return nil
    end
    return wallet
end

local function getMoodleRightReserve(playerNum)
    local screenW = getCore():getScreenWidth()
    local moodleUI = UIManager.getMoodleUI(playerNum or 0)
    if moodleUI then
        local ok, absX = pcall(function()
            return moodleUI:getAbsoluteX()
        end)
        if ok and absX and absX > 0 and absX < screenW then
            return math.max(MOODLE_FALLBACK, screenW - absX + 6)
        end
        local okW, w = pcall(function()
            return moodleUI:getWidth()
        end)
        if okW and w and w > 0 then
            return math.max(MOODLE_FALLBACK, w + 16)
        end
    end
    return MOODLE_FALLBACK
end

local function formatCompact(amount)
    local n = tonumber(amount) or 0
    local neg = n < 0
    if neg then
        n = -n
    end
    local text
    if n >= 1000000000 then
        text = string.format("%.1fB", n / 1000000000)
    elseif n >= 1000000 then
        text = string.format("%.1fM", n / 1000000)
    elseif n >= 10000 then
        text = string.format("%.1fK", n / 1000)
    else
        text = Currency.format(n)
    end
    if neg then
        return "-" .. text
    end
    return text
end

function WalletBalanceHUD:new()
    local o = ISPanel:new(0, 0, 120, 22)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.coinExact = 0
    o.specialExact = 0
    o.coinCompact = "0"
    o.specialCompact = "0"
    o.showSpecial = true
    o.hovering = false
    -- Без anchorRight: иначе панель «липнет» к правому краю экрана и уезжает от часов
    o.anchorLeft = true
    o.anchorRight = false
    o.anchorTop = true
    o.anchorBottom = false
    return o
end

function WalletBalanceHUD:initialise()
    ISPanel.initialise(self)
    if self.javaObject then
        -- Нужен ПКМ по панели
        self.javaObject:setConsumeMouseEvents(true)
    end
    self.toolTip = ISToolTip:new()
    self.toolTip:initialise()
    self.toolTip:setVisible(false)
    self.toolTip:setOwner(self)
    self.toolTip:addToUIManager()
end

function WalletBalanceHUD:canDisplay()
    if not WalletBalanceHUD.isPrefVisible() then
        return false
    end
    if MainScreen.instance and MainScreen.instance:isReallyVisible() then
        return false
    end
    local player = getPlayer()
    if not player or player:isDead() then
        return false
    end
    return getLinkedWornWallet(player) ~= nil
end

function WalletBalanceHUD:syncVisibility()
    local show = self:canDisplay()
    if self:getIsVisible() ~= show then
        self:setVisible(show)
    end
    if not show and self.toolTip then
        self.toolTip:setVisible(false)
        self.hovering = false
    end
    return show
end

function WalletBalanceHUD:refreshBalance()
    local player = getPlayer()
    if not player then
        return
    end
    local coin, specialCoin = Balance.getUserBalance(player:getUsername())
    self.coinExact = coin
    self.specialExact = specialCoin
    self.coinCompact = formatCompact(coin)
    self.showSpecial = Currency.UseSpecialCoin == true
    if self.showSpecial then
        self.specialCompact = formatCompact(specialCoin)
    end
end

function WalletBalanceHUD:getContentWidth(font)
    local tm = getTextManager()
    local coinW = tm:MeasureStringX(font, self.coinCompact or "0")
    local w = coinW
    if self.showSpecial then
        local sepW = tm:MeasureStringX(font, SEP)
        local specialW = tm:MeasureStringX(font, self.specialCompact or "0")
        w = w + sepW + specialW
    end
    return BODY_PAD + CHIP_W + 5 + SCREEN_INSET * 2 + w + BODY_PAD + 4
end

function WalletBalanceHUD:updateLayout()
    local font = UIFont.Small
    local fontH = getTextManager():getFontHeight(font)
    local contentW = self:getContentWidth(font)
    local height = math.max(CHIP_H + BODY_PAD * 2, fontH + 8)

    local player = getPlayer()
    local playerNum = player and player:getPlayerNum() or 0
    local screenW = getCore():getScreenWidth()
    local moodleReserve = getMoodleRightReserve(playerNum)
    local maxRight = screenW - moodleReserve

    local clock = UIManager.getClock()
    local x, y, width

    if clock and clock:isDateVisible() then
        -- getX/getY: те же координаты, что у часов (не absolute)
        local clockX = clock:getX()
        local clockY = clock:getY()
        local clockW = clock:getWidth()
        local clockH = clock:getHeight()

        x = clockX
        y = clockY + clockH + CLOCK_GAP
        width = clockW

        -- Ужимаем только справа под moodle, левый край часов не трогаем
        if x + width > maxRight then
            width = maxRight - x
        end
        if width < contentW then
            width = contentW
            if x + width > maxRight then
                width = maxRight - x
            end
        end
    else
        width = contentW
        x = maxRight - width
        y = SCREEN_MARGIN
    end

    if x < 0 then
        x = 0
    end

    self:setWidth(width)
    self:setHeight(height)
    self:setX(x)
    self:setY(y)
end

function WalletBalanceHUD:hideTip()
    if self.toolTip then
        self.toolTip:setVisible(false)
    end
    self.hovering = false
end

function WalletBalanceHUD:onTransfer()
    local player = getPlayer()
    if not player then
        return
    end
    if TransferUI and TransferUI.show then
        TransferUI:show(player)
    elseif Currency and Currency.transfer then
        Currency.transfer(nil, nil, player)
    end
end

function WalletBalanceHUD:onShowAccounting()
    if ShowPlayerAccountingUI then
        ShowPlayerAccountingUI()
    end
end

function WalletBalanceHUD:onRightMouseUp(x, y)
    if not self:getIsVisible() then
        return false
    end
    local player = getPlayer()
    if not player then
        return false
    end

    self:hideTip()

    local context = ISContextMenu.get(player:getPlayerNum(), getMouseX(), getMouseY())
    local transferLabel = (UIText and UIText.Transfer) or getText("IGUI_Balance_Transfer")
    context:addOption(transferLabel, self, self.onTransfer)

    if ShowPlayerAccountingUI then
        context:addOption(getText("IGUI_Show_Accounting"), self, self.onShowAccounting)
    end

    context:addOption(getText("IGUI_Wallet_HideBalance"), nil, function()
        WalletBalanceHUD.setPrefVisible(false)
    end)

    return true
end

function WalletBalanceHUD:isMouseOverPanel()
    local mx = getMouseX()
    local my = getMouseY()
    local ax = self:getAbsoluteX()
    local ay = self:getAbsoluteY()
    return mx >= ax and mx <= ax + self.width and my >= ay and my <= ay + self.height
end

function WalletBalanceHUD:updateStatementTip()
    if not self.toolTip then
        return
    end
    local over = self:isMouseOverPanel()
    if not over then
        if self.hovering then
            self.toolTip:setVisible(false)
            self.hovering = false
        end
        return
    end

    local player = getPlayer()
    local username = player and player:getUsername() or ""
    self.toolTip:setName(getText("IGUI_Wallet_Statement"))
    local desc = getText("IGUI_Wallet_StatementAccount", username)
    desc = desc .. " <LINE> " .. getText("IGUI_Wallet_StatementCoin") .. " " .. Currency.format(self.coinExact)
    if self.showSpecial then
        desc = desc .. " <LINE> " .. getText("IGUI_Wallet_StatementSpecial") .. " " .. Currency.format(self.specialExact)
    end
    self.toolTip.description = desc
    self.toolTip.followMouse = true
    self.toolTip.maxLineWidth = 280
    self.toolTip:setVisible(true)
    self.hovering = true
end

function WalletBalanceHUD:drawLedText(text, x, y, color, dim)
    self:drawText(text, x + 1, y + 1, dim.r, dim.g, dim.b, dim.a, UIFont.Small)
    self:drawText(text, x, y, color.r, color.g, color.b, color.a, UIFont.Small)
end

function WalletBalanceHUD:prerender()
    if not self:getIsVisible() then
        return
    end
    if not self:canDisplay() then
        self:syncVisibility()
        return
    end

    self:refreshBalance()
    self:updateLayout()
    self:updateStatementTip()

    local w, h = self.width, self.height

    self:drawRectStatic(0, 0, w, h, BODY.a, BODY.r, BODY.g, BODY.b)
    self:drawRectBorderStatic(0, 0, w, h, BODY_EDGE.a, BODY_EDGE.r, BODY_EDGE.g, BODY_EDGE.b)

    local chipX = BODY_PAD
    local chipY = math.floor((h - CHIP_H) / 2)
    self:drawRectStatic(chipX, chipY, CHIP_W, CHIP_H, CHIP.a, CHIP.r, CHIP.g, CHIP.b)
    self:drawRectBorderStatic(chipX, chipY, CHIP_W, CHIP_H, CHIP_LINE.a * 0.8, CHIP_LINE.r, CHIP_LINE.g, CHIP_LINE.b)
    self:drawRectStatic(chipX + 2, chipY + 3, CHIP_W - 4, 1, CHIP_LINE.a, CHIP_LINE.r, CHIP_LINE.g, CHIP_LINE.b)
    self:drawRectStatic(chipX + 2, chipY + 7, CHIP_W - 4, 1, CHIP_LINE.a, CHIP_LINE.r, CHIP_LINE.g, CHIP_LINE.b)
    self:drawRectStatic(chipX + 2, chipY + 11, CHIP_W - 4, 1, CHIP_LINE.a, CHIP_LINE.r, CHIP_LINE.g, CHIP_LINE.b)

    local sx = chipX + CHIP_W + 4
    local sy = SCREEN_INSET
    local sw = w - sx - BODY_PAD
    local sh = h - SCREEN_INSET * 2
    self:drawRectStatic(sx, sy, sw, sh, SCREEN.a, SCREEN.r, SCREEN.g, SCREEN.b)
    self:drawRectBorderStatic(sx, sy, sw, sh, SCREEN_EDGE.a, SCREEN_EDGE.r, SCREEN_EDGE.g, SCREEN_EDGE.b)
end

function WalletBalanceHUD:render()
    if not self:getIsVisible() then
        return
    end

    local font = UIFont.Small
    local fontH = getTextManager():getFontHeight(font)
    local tm = getTextManager()
    local sx = BODY_PAD + CHIP_W + 4
    local sw = self.width - sx - BODY_PAD

    local coinW = tm:MeasureStringX(font, self.coinCompact)
    local totalTextW = coinW
    local sepW = 0
    local specialW = 0
    if self.showSpecial then
        sepW = tm:MeasureStringX(font, SEP)
        specialW = tm:MeasureStringX(font, self.specialCompact)
        totalTextW = totalTextW + sepW + specialW
    end

    local tx = sx + math.floor((sw - totalTextW) / 2)
    local ty = math.floor((self.height - fontH) / 2)

    self:drawLedText(self.coinCompact, tx, ty, LED_GREEN, LED_GREEN_DIM)
    tx = tx + coinW

    if self.showSpecial then
        self:drawText(SEP, tx, ty, LED_SEP.r, LED_SEP.g, LED_SEP.b, LED_SEP.a, font)
        tx = tx + sepW
        self:drawLedText(self.specialCompact, tx, ty, LED_GOLD, LED_GOLD_DIM)
    end
end

function WalletBalanceHUD.tickSync(player)
    if not player or player ~= getPlayer() then
        return
    end
    local ui = WalletBalanceHUD.instance
    if not ui then
        return
    end
    -- Даже когда панель скрыта: экипировка / загрузка баланса
    ui:syncVisibility()
end

function WalletBalanceHUD.create()
    WalletBalanceHUD.prefVisible = loadPref()
    if WalletBalanceHUD.instance then
        WalletBalanceHUD.instance:syncVisibility()
        return WalletBalanceHUD.instance
    end
    local ui = WalletBalanceHUD:new()
    ui:initialise()
    ui:instantiate()
    ui:addToUIManager()
    ui:setVisible(false)
    WalletBalanceHUD.instance = ui
    ui:syncVisibility()
    return ui
end

Events.OnGameStart.Add(function()
    WalletBalanceHUD.create()
end)

Events.OnCreatePlayer.Add(function(playerIndex, player)
    if playerIndex ~= 0 then
        return
    end
    WalletBalanceHUD.create()
end)

-- Надеть / снять кошелёк
Events.OnClothingUpdated.Add(function(player)
    WalletBalanceHUD.tickSync(player)
end)

-- После логина CoinBalance приходит асинхронно: без этого HUD не видит linkedTo
Events.OnReceiveGlobalModData.Add(function(key, modData)
    if key ~= "CoinBalance" then
        return
    end
    if WalletBalanceHUD.instance then
        WalletBalanceHUD.instance:syncVisibility()
    end
end)
