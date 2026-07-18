require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

TransferUI = ISPanel:derive("TransferUI")
TransferUI.instance = nil
TransferUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
TransferUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()
TransferUI.transferInProgress = false
TransferUI.accountsCache = {}
TransferUI.MSG_MAX = 40

local PANEL_W = 420
local PANEL_H = 460
local INSET = 28
local FOOTER_H = 50

local COL_LABEL = { r = 0.72, g = 0.68, b = 0.55, a = 1 }
local COL_TITLE = { r = 0.88, g = 0.78, b = 0.45, a = 1 }
local COL_GREEN = { r = 0.38, g = 0.78, b = 0.45, a = 1 }
local COL_GOLD = { r = 0.90, g = 0.78, b = 0.32, a = 1 }
local COL_MUTED = { r = 0.50, g = 0.48, b = 0.40, a = 1 }
local COL_ERROR = { r = 0.92, g = 0.38, b = 0.30, a = 1 }
local COL_RECIPIENT = { r = 1.0, g = 0.86, b = 0.38, a = 1 }
local COL_INK = { r = 0.82, g = 0.80, b = 0.72, a = 1 }

local TEX = {}

local function loadTextures()
    TEX.btn = getTexture("media/ui/knoxbank_btn.png")
    TEX.btnSend = getTexture("media/ui/knoxbank_btn_send.png")
    TEX.close = getTexture("media/ui/knoxbank_close.png")
end

local function drawPanelChrome(ui)
    local w, h = ui.width, ui.height
    ui:drawRect(0, 0, w, h, 1, 0.11, 0.10, 0.07)
    ui:drawRect(3, 3, w - 6, h - 6, 1, 0.05, 0.06, 0.05)
    ui:drawRectBorder(0, 0, w, h, 0.95, 0.55, 0.45, 0.22)
    ui:drawRectBorder(2, 2, w - 4, h - 4, 0.55, 0.38, 0.30, 0.16)

    ui:drawRect(16, 12, w - 32, 56, 0.98, 0.06, 0.07, 0.055)
    ui:drawRectBorder(16, 12, w - 32, 56, 0.75, 0.48, 0.38, 0.22)

    if ui.sectionLines then
        for _, ly in ipairs(ui.sectionLines) do
            ui:drawRect(INSET, ly, w - INSET * 2, 1, 0.45, 0.42, 0.34, 0.18)
        end
    end

    local footerY = h - FOOTER_H + 4
    local footerBoxH = FOOTER_H - 10
    ui:drawRect(16, footerY, w - 32, footerBoxH, 0.9, 0.055, 0.06, 0.05)
    ui:drawRectBorder(16, footerY, w - 32, footerBoxH, 0.55, 0.40, 0.30, 0.18)

    -- Заклёпки: без правого верхнего угла (там крестик)
    local rivet = { { 7, 7 }, { 7, h - 12 }, { w - 12, h - 12 } }
    for _, p in ipairs(rivet) do
        ui:drawRect(p[1], p[2], 5, 5, 1, 0.42, 0.34, 0.16)
        ui:drawRect(p[1] + 1, p[2] + 1, 3, 3, 1, 0.62, 0.52, 0.28)
    end
end
local function styleBrassButton(btn, useSendTex)
    btn.borderColor = { r = 0.55, g = 0.45, b = 0.22, a = 0.9 }
    btn.backgroundColor = { r = 0.12, g = 0.11, b = 0.07, a = 0.85 }
    btn.backgroundColorMouseOver = { r = 0.22, g = 0.20, b = 0.12, a = 0.95 }
    btn.backgroundColorPressed = { r = 0.08, g = 0.10, b = 0.07, a = 1 }
    if useSendTex and TEX.btnSend then
        btn:setImage(TEX.btnSend)
    elseif TEX.btn then
        btn:setImage(TEX.btn)
    end
    btn:setTextureRGBA(1, 1, 1, 0.85)
end

local function sanitizeTransferMessage(raw)
    if not raw or raw == "" then
        return nil
    end
    local msg = string.trim(tostring(raw))
    if msg == "" then
        return nil
    end
    msg = string.gsub(msg, "[\r\n\t]", " ")
    msg = string.gsub(msg, "%s+", " ")
    if #msg > TransferUI.MSG_MAX then
        msg = string.sub(msg, 1, TransferUI.MSG_MAX)
    end
    if msg == "" then
        return nil
    end
    return msg
end

function TransferUI:show(player)
    if TransferUI.instance then
        TransferUI.instance:setVisible(false)
        TransferUI.instance:removeFromUIManager()
        TransferUI.instance = nil
    end
    TransferUI.instance = TransferUI:new(0, 0, PANEL_W, PANEL_H, player)
    TransferUI.instance:initialise()
    TransferUI.instance:instantiate()
    TransferUI.instance:addToUIManager()
    TransferUI.instance:setVisible(true)
    TransferUI.instance:refreshAccounts()
    TransferUI.instance:bringToTop()
    return TransferUI.instance
end

function TransferUI:new(x, y, width, height, player)
    loadTextures()
    if x == 0 and y == 0 then
        x = (getCore():getScreenWidth() / 2) - (width / 2)
        y = (getCore():getScreenHeight() / 2) - (height / 2)
    end
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.player = player
    o.recipient = nil
    o.sectionLines = {}
    o.fgBar = { r = 0.45, g = 0.7, b = 0.35, a = 0.75 }
    o.moveWithMouse = true
    return o
end

function TransferUI:initialise()
    ISPanel.initialise(self)
end

function TransferUI:prerender()
    drawPanelChrome(self)
end

function TransferUI:render()
    ISPanel.render(self)

    local title = "KNOX BANK"
    local sub = getText("IGUI_Balance_Transfer")
    local tw = getTextManager():MeasureStringX(UIFont.Medium, title)
    local titleX = (self.width - tw) / 2
    self:drawText(title, titleX, 18, COL_TITLE.r, COL_TITLE.g, COL_TITLE.b, 1, UIFont.Medium)

    local sw = getTextManager():MeasureStringX(UIFont.Small, sub)
    self:drawText(sub, (self.width - sw) / 2, 42, COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small)

    local footer = getText("IGUI_Balance_TransferFooter")
    local fw = getTextManager():MeasureStringX(UIFont.Small, footer)
    local footerY = self.height - FOOTER_H + 4
    local footerBoxH = FOOTER_H - 10
    local textY = footerY + (footerBoxH - TransferUI.SMALL_FONT_HGT) / 2
    self:drawText(footer, (self.width - fw) / 2, textY, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 0.9, UIFont.Small)

    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then
        self.transferInProgress = false
        return
    end
    if not (currentAction.Type == "SendTransferAction") then
        self.transferInProgress = false
        return
    end
    self:drawProgressBar(self.width - INSET - 100, footerY - 12, 90, 8, currentAction.action:getJobDelta(), self.fgBar)
end

function TransferUI:layoutBalance()
    if not self.balanceLabel then
        return
    end
    local labelW = getTextManager():MeasureStringX(UIFont.Small, UIText.Balance)
    self.balanceLabel:setX((self.width - labelW) / 2)

    local coinImg = Currency.CoinsTexture.Coin
    local iconW = coinImg.scale + 4
    local coinText = self.balanceCoinLabel:getName() or "0"
    local coinTextW = getTextManager():MeasureStringX(UIFont.Medium, coinText)
    local leftGroupW = iconW + 4 + coinTextW
    local groupGap = 28
    local totalW = leftGroupW

    local rightGroupW = 0
    if Currency.UseSpecialCoin and self.balanceSpecialCoinLabel then
        local specialText = self.balanceSpecialCoinLabel:getName() or "0"
        local specialTextW = getTextManager():MeasureStringX(UIFont.Medium, specialText)
        rightGroupW = iconW + 4 + specialTextW
        totalW = leftGroupW + groupGap + rightGroupW
    end

    local startX = (self.width - totalW) / 2
    self.balanceCoinTex:setX(startX)
    self.balanceCoinLabel:setX(startX + iconW + 4)

    if Currency.UseSpecialCoin and self.balanceSpecialCoinTex then
        local sx = startX + leftGroupW + groupGap
        self.balanceSpecialCoinTex:setX(sx)
        self.balanceSpecialCoinLabel:setX(sx + iconW + 4)
    end
end

function TransferUI:refreshAccounts()
    if not self.accountItems then
        return
    end
    local keepRecipient = self.recipient
    self.accountItems:clear()
    local accounts = Balance.getAccountsList()
    local username = self.player:getUsername()
    for _, name in pairs(accounts) do
        if name ~= username then
            self.accountItems:addItem(name)
        end
    end
    self.accountsCache = self.accountItems.items
    self.accountItems.selected = 0
    if keepRecipient then
        for i, row in ipairs(self.accountItems.items) do
            if row.text == keepRecipient then
                self.accountItems.selected = i
                break
            end
        end
        if self.accountItems.selected == 0 then
            self:setRecipient(nil)
        end
    else
        self:setRecipient(nil)
    end
    if self.filterEntry then
        local filterText = string.trim(self.filterEntry:getInternalText() or "")
        if filterText ~= "" then
            self:filter()
        end
    end
end

function TransferUI:update()
    if not self:getIsVisible() then
        return
    end
    local username = self.player:getUsername()
    local coin, specialCoin = Balance.getUserBalance(username)
    if self.balanceCoinLabel then
        self.balanceCoinLabel:setName("" .. Currency.format(coin))
    end
    if self.balanceSpecialCoinLabel then
        self.balanceSpecialCoinLabel:setName("" .. Currency.format(specialCoin))
    end
    self:layoutBalance()

    if self.msgCountLabel and self.messageEntry then
        local len = #(self.messageEntry:getInternalText() or "")
        self.msgCountLabel:setName(len .. "/" .. TransferUI.MSG_MAX)
    end

    if self.transferInProgress then
        return
    end

    local transferCoin = tonumber(self.transferCoin:getInternalText()) or 0
    local transferSpecialCoin = tonumber(self.transferSpecialCoin:getInternalText()) or 0
    local overCoin = transferCoin > coin
    local overSpecial = transferSpecialCoin > specialCoin
    local hasAmount = transferCoin > 0 or transferSpecialCoin > 0
    local canSend = self.recipient and hasAmount and not overCoin and not overSpecial

    if self.errorLabel then
        if overCoin or overSpecial then
            self.errorLabel:setName(getText("IGUI_Balance_TransferNotEnough"))
            self.errorLabel:setVisible(true)
        elseif hasAmount and not self.recipient then
            self.errorLabel:setName(getText("IGUI_Balance_TransferNoRecipient"))
            self.errorLabel:setVisible(true)
        else
            self.errorLabel:setName("")
            self.errorLabel:setVisible(false)
        end
    end

    if canSend then
        self.sendButton.enable = true
        self.sendButton:setVisible(true)
        self.cancelButton.enable = false
        self.cancelButton:setVisible(false)
    else
        self.sendButton.enable = false
        self.sendButton:setVisible(true)
        self.cancelButton.enable = false
        self.cancelButton:setVisible(false)
    end
end

function TransferUI:setRecipient(accountName)
    self.recipient = accountName
    if self.toPrefixLabel then
        self.toPrefixLabel:setName(getText("IGUI_Balance_TransferTo") .. " ")
    end
    if self.toNameLabel then
        if accountName then
            self.toNameLabel:setName(accountName)
            self.toNameLabel.r = COL_RECIPIENT.r
            self.toNameLabel.g = COL_RECIPIENT.g
            self.toNameLabel.b = COL_RECIPIENT.b
            self.toNameLabel.a = 1
        else
            self.toNameLabel:setName(getText("IGUI_Balance_TransferNobody"))
            self.toNameLabel.r = COL_MUTED.r
            self.toNameLabel.g = COL_MUTED.g
            self.toNameLabel.b = COL_MUTED.b
            self.toNameLabel.a = 1
        end
    end
end

function TransferUI:onMouseDownAccountItem(x, y)
    ISScrollingListBox.onMouseDown(self, x, y)
    if not self.selected then
        return
    end
    local selectedRow = self.items[self.selected]
    if not selectedRow then
        return
    end
    local ui = TransferUI.instance
    if ui then
        ui:setRecipient(selectedRow.text)
    end
end

function TransferUI:filter()
    local filterText = string.lower(string.trim(self.filterEntry:getInternalText() or ""))
    local source = self.accountsCache or {}
    self.accountItems:clear()
    for _, v in ipairs(source) do
        if filterText == "" or string.contains(string.lower(v.text), filterText) then
            self.accountItems:addItem(v.text)
        end
    end
    self.accountItems.selected = 0
    if self.recipient then
        for i, row in ipairs(self.accountItems.items) do
            if row.text == self.recipient then
                self.accountItems.selected = i
                return
            end
        end
        self:setRecipient(nil)
    end
end

function TransferUI:onFilterChange()
    if TransferUI.instance then
        TransferUI.instance:filter()
    end
end

local function twoDecimal(entry)
    local quantity = entry:getInternalText()
    if not tonumber(quantity) then
        return
    end
    local curPos = entry:getCursorPos()
    if string.find(quantity, "%.") then
        entry:setText(string.format("%.02f", quantity))
        entry:setCursorPos(curPos)
    end
end

function TransferUI:onCoinChange()
    twoDecimal(self)
end

function TransferUI:onSpecialCoinChange()
    twoDecimal(self)
end

function TransferUI:onMessageChange()
    local ui = TransferUI.instance
    if not ui or not ui.messageEntry then
        return
    end
    local text = ui.messageEntry:getInternalText() or ""
    if #text > TransferUI.MSG_MAX then
        local curPos = ui.messageEntry:getCursorPos()
        ui.messageEntry:setText(string.sub(text, 1, TransferUI.MSG_MAX))
        ui.messageEntry:setCursorPos(math.min(curPos, TransferUI.MSG_MAX))
    end
end

function TransferUI:addQuickAmount(amount)
    local cur = tonumber(self.transferCoin:getInternalText()) or 0
    if amount == "max" then
        local coin = Balance.getUserBalance(self.player:getUsername())
        self.transferCoin:setText(tostring(coin))
        return
    end
    if amount == "clear" then
        self.transferCoin:setText("0")
        self.transferSpecialCoin:setText("0")
        return
    end
    self.transferCoin:setText(tostring(cur + amount))
end

function TransferUI:onClose()
    self:close()
end

function TransferUI:close()
    self.recipient = nil
    self.transferInProgress = false
    self:setVisible(false)
    self:removeFromUIManager()
    TransferUI.instance = nil
end

function TransferUI:clearAfterTransfer()
    self:setRecipient(nil)
    self.transferCoin:setText("0")
    self.transferSpecialCoin:setText("0")
    if self.messageEntry then
        self.messageEntry:setText("")
    end
    if self.errorLabel then
        self.errorLabel:setVisible(false)
    end
end

function TransferUI:cancelBtn()
    self.sendButton.enable = true
    self.sendButton:setVisible(true)
    self.cancelButton.enable = false
    self.cancelButton:setVisible(false)
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    if not currentAction then
        return
    end
    if not (currentAction.Type == "SendTransferAction") then
        return
    end
    currentAction.action:forceStop()
end

function TransferUI:sendBtn()
    self.transferInProgress = true
    local transfer = {}
    transfer.coin = math.abs(tonumber(self.transferCoin:getInternalText()) or 0)
    transfer.specialCoin = math.abs(tonumber(self.transferSpecialCoin:getInternalText()) or 0)
    transfer.recipient = self.recipient
    transfer.message = sanitizeTransferMessage(self.messageEntry and self.messageEntry:getInternalText() or "")
    self.sendButton.enable = false
    self.sendButton:setVisible(false)
    self.cancelButton.enable = true
    self.cancelButton:setVisible(true)
    local action = SendTransferAction:new(self.player, self, transfer)
    ISTimedActionQueue.add(action)
end

function TransferUI:createChildren()
    local x = INSET
    local contentW = self.width - INSET * 2
    self.sectionLines = {}

    self.closeBtn = ISButton:new(self.width - 26, 6, 18, 18, "X", self, TransferUI.onClose)
    self.closeBtn:initialise()
    self.closeBtn.borderColor = { r = 0.55, g = 0.45, b = 0.22, a = 0.85 }
    self.closeBtn.backgroundColor = { r = 0.08, g = 0.08, b = 0.06, a = 0.7 }
    self.closeBtn.backgroundColorMouseOver = { r = 0.22, g = 0.18, b = 0.10, a = 0.95 }
    self.closeBtn.backgroundColorPressed = { r = 0.12, g = 0.10, b = 0.07, a = 1 }
    if TEX.close then
        self.closeBtn:setImage(TEX.close)
        self.closeBtn:setTitle("")
    end
    self.closeBtn:setTextureRGBA(1, 1, 1, 1)
    self:addChild(self.closeBtn)

    -- Баланс
    local y = 78
    table.insert(self.sectionLines, y - 6)
    self.balanceLabel = ISLabel:new(x, y, TransferUI.SMALL_FONT_HGT, UIText.Balance, COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small, true)
    self:addChild(self.balanceLabel)

    local coinImg = Currency.CoinsTexture.Coin
    self.balanceCoinTex = ISImage:new(x, y + 18, 0, 0, coinImg.texture)
    self.balanceCoinTex.scaledWidth = coinImg.scale + 4
    self.balanceCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.balanceCoinTex)

    self.balanceCoinLabel = ISLabel:new(x + 24, y + 18, TransferUI.MEDIUM_FONT_HGT, "0", COL_GREEN.r, COL_GREEN.g, COL_GREEN.b, 1, UIFont.Medium, true)
    self:addChild(self.balanceCoinLabel)

    coinImg = Currency.CoinsTexture.SpecialCoin
    self.balanceSpecialCoinTex = ISImage:new(x + 190, y + 18, 0, 0, coinImg.texture)
    self.balanceSpecialCoinTex.scaledWidth = coinImg.scale + 4
    self.balanceSpecialCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.balanceSpecialCoinTex)

    self.balanceSpecialCoinLabel = ISLabel:new(x + 214, y + 18, TransferUI.MEDIUM_FONT_HGT, "0", COL_GOLD.r, COL_GOLD.g, COL_GOLD.b, 1, UIFont.Medium, true)
    self:addChild(self.balanceSpecialCoinLabel)
    self:layoutBalance()

    -- Получатель
    y = 140
    table.insert(self.sectionLines, y - 8)
    self.recipientSectionLabel = ISLabel:new(x, y, TransferUI.SMALL_FONT_HGT, getText("IGUI_Balance_TransferRecipient"), COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small, true)
    self:addChild(self.recipientSectionLabel)

    local searchY = y + 26
    self.filterLabel = ISLabel:new(x, searchY + 4, 1, UIText.Search, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Small, true)
    self:addChild(self.filterLabel)

    self.filterEntry = ISTextEntryBox:new("", x + 50, searchY, contentW - 50, 20)
    self.filterEntry.font = UIFont.Small
    self.filterEntry:initialise()
    self.filterEntry:instantiate()
    self.filterEntry:setText("")
    self.filterEntry:setClearButton(true)
    self.filterEntry.backgroundColor = { r = 0.04, g = 0.05, b = 0.04, a = 0.95 }
    self.filterEntry.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.7 }
    self.filterEntry.onTextChange = TransferUI.onFilterChange
    self:addChild(self.filterEntry)

    local listY = searchY + 28
    self.accountItems = ISScrollingListBox:new(x, listY, contentW, 78)
    self.accountItems:initialise()
    self.accountItems:instantiate()
    self.accountItems.font = UIFont.Small
    self.accountItems.itemheight = 2 + TransferUI.SMALL_FONT_HGT + 6
    self.accountItems.selected = 0
    self.accountItems.joypadParent = self
    self.accountItems.drawBorder = true
    self.accountItems.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.75 }
    self.accountItems.backgroundColor = { r = 0.03, g = 0.04, b = 0.03, a = 0.9 }
    self.accountItems.SMALL_FONT_HGT = self.SMALL_FONT_HGT
    self.accountItems.MEDIUM_FONT_HGT = self.MEDIUM_FONT_HGT
    self.accountItems.onMouseDown = TransferUI.onMouseDownAccountItem
    self:addChild(self.accountItems)

    local toY = listY + 78 + 12
    self.toPrefixLabel = ISLabel:new(x, toY, TransferUI.MEDIUM_FONT_HGT, getText("IGUI_Balance_TransferTo") .. " ", COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Medium, true)
    self:addChild(self.toPrefixLabel)

    local prefixW = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_Balance_TransferTo") .. " ")
    self.toNameLabel = ISLabel:new(x + prefixW, toY, TransferUI.MEDIUM_FONT_HGT, getText("IGUI_Balance_TransferNobody"), COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Medium, true)
    self:addChild(self.toNameLabel)

    self:refreshAccounts()

    -- Сумма
    y = toY + TransferUI.MEDIUM_FONT_HGT + 14
    table.insert(self.sectionLines, y - 8)
    self.amountSectionLabel = ISLabel:new(x, y, TransferUI.SMALL_FONT_HGT, getText("IGUI_Balance_TransferAmount"), COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small, true)
    self:addChild(self.amountSectionLabel)

    coinImg = Currency.CoinsTexture.Coin
    self.transferCoinTex = ISImage:new(x, y + 22, 0, 0, coinImg.texture)
    self.transferCoinTex.scaledWidth = coinImg.scale + 4
    self.transferCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.transferCoinTex)

    self.transferCoin = ISTextEntryBox:new("0", x + 24, y + 18, 120, 20)
    self.transferCoin.font = UIFont.Small
    self.transferCoin:initialise()
    self.transferCoin:instantiate()
    self.transferCoin:setOnlyNumbers(true)
    self.transferCoin.backgroundColor = { r = 0.04, g = 0.05, b = 0.04, a = 0.95 }
    self.transferCoin.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.7 }
    self.transferCoin.onTextChange = TransferUI.onCoinChange
    self:addChild(self.transferCoin)

    coinImg = Currency.CoinsTexture.SpecialCoin
    self.transferSpecialCoinTex = ISImage:new(x + 160, y + 22, 0, 0, coinImg.texture)
    self.transferSpecialCoinTex.scaledWidth = coinImg.scale + 4
    self.transferSpecialCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.transferSpecialCoinTex)

    self.transferSpecialCoin = ISTextEntryBox:new("0", x + 184, y + 18, 120, 20)
    self.transferSpecialCoin.font = UIFont.Small
    self.transferSpecialCoin:initialise()
    self.transferSpecialCoin:instantiate()
    self.transferSpecialCoin:setOnlyNumbers(true)
    self.transferSpecialCoin.backgroundColor = { r = 0.04, g = 0.05, b = 0.04, a = 0.95 }
    self.transferSpecialCoin.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.7 }
    self.transferSpecialCoin.onTextChange = TransferUI.onSpecialCoinChange
    self:addChild(self.transferSpecialCoin)

    local quickY = y + 46
    local quickW = 48
    local quickGap = 5
    local quickAmounts = { 1000, 10000, 100000 }
    for i, amount in ipairs(quickAmounts) do
        local label = string.format("%dK", amount / 1000)
        local bx = x + (i - 1) * (quickW + quickGap)
        local btn = ISButton:new(bx, quickY, quickW, 18, label, self, function(ui)
            ui:addQuickAmount(amount)
        end)
        btn:initialise()
        styleBrassButton(btn, false)
        self:addChild(btn)
    end
    local maxBtn = ISButton:new(x + 3 * (quickW + quickGap), quickY, quickW, 18, "Max", self, function(ui)
        ui:addQuickAmount("max")
    end)
    maxBtn:initialise()
    styleBrassButton(maxBtn, false)
    self:addChild(maxBtn)

    local clearBtn = ISButton:new(x + 4 * (quickW + quickGap), quickY, 28, 18, "X", self, function(ui)
        ui:addQuickAmount("clear")
    end)
    clearBtn:initialise()
    styleBrassButton(clearBtn, false)
    clearBtn.borderColor = { r = 0.55, g = 0.3, b = 0.25, a = 0.9 }
    clearBtn.tooltip = getText("IGUI_Balance_TransferClearAmount")
    self:addChild(clearBtn)

    self.errorLabel = ISLabel:new(x, quickY + 20, TransferUI.SMALL_FONT_HGT, "", COL_ERROR.r, COL_ERROR.g, COL_ERROR.b, 1, UIFont.Small, true)
    self.errorLabel:setVisible(false)
    self:addChild(self.errorLabel)

    -- Сообщение
    y = quickY + 34
    table.insert(self.sectionLines, y - 6)
    self.messageLabel = ISLabel:new(x, y, TransferUI.SMALL_FONT_HGT, getText("IGUI_Balance_TransferMessage"), COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small, true)
    self:addChild(self.messageLabel)

    self.msgCountLabel = ISLabel:new(x + contentW - 42, y, TransferUI.SMALL_FONT_HGT, "0/" .. TransferUI.MSG_MAX, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Small, true)
    self:addChild(self.msgCountLabel)

    self.messageEntry = ISTextEntryBox:new("", x, y + 16, contentW - 100, 22)
    self.messageEntry.font = UIFont.Small
    self.messageEntry:initialise()
    self.messageEntry:instantiate()
    self.messageEntry:setText("")
    self.messageEntry.backgroundColor = { r = 0.04, g = 0.05, b = 0.04, a = 0.95 }
    self.messageEntry.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.7 }
    self.messageEntry.onTextChange = TransferUI.onMessageChange
    self:addChild(self.messageEntry)

    self.sendButton = ISButton:new(x + contentW - 92, y + 14, 92, 26, UIText.Send, self, TransferUI.sendBtn)
    self.sendButton:initialise()
    self.sendButton.enable = false
    styleBrassButton(self.sendButton, true)
    self:addChild(self.sendButton)

    self.cancelButton = ISButton:new(x + contentW - 92, y + 14, 92, 26, UIText.Cancel, self, TransferUI.cancelBtn)
    self.cancelButton:initialise()
    self.cancelButton.enable = false
    self.cancelButton:setVisible(false)
    styleBrassButton(self.cancelButton, false)
    self:addChild(self.cancelButton)

    if not Currency.UseSpecialCoin then
        self.balanceSpecialCoinTex:setVisible(false)
        self.balanceSpecialCoinLabel:setVisible(false)
        self.transferSpecialCoin:setVisible(false)
        self.transferSpecialCoinTex:setVisible(false)
    end

    -- Высота строго по контенту + футер, без пустоты
    local contentBottom = y + 16 + 26
    local newH = contentBottom + FOOTER_H
    self:setHeight(newH)
    self:setY((getCore():getScreenHeight() / 2) - (newH / 2))
end

function TransferUI:onMouseDown(x, y)
    -- Перетаскивание панели за шапку
    if y < 78 then
        self.moving = true
        self.downX = self:getMouseX()
        self.downY = self:getMouseY()
    end
    return ISPanel.onMouseDown(self, x, y)
end

function TransferUI:onMouseMove(dx, dy)
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
    return ISPanel.onMouseMove(self, dx, dy)
end

function TransferUI:onMouseUp(x, y)
    self.moving = false
    return ISPanel.onMouseUp(self, x, y)
end

function TransferUI:onMouseUpOutside(x, y)
    self.moving = false
    return ISPanel.onMouseUpOutside(self, x, y)
end
