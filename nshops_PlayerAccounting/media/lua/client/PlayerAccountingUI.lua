require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"

local main = require "PlayerAccountingClient"

PlayerAccountingUI = ISPanel:derive("PlayerAccountingUI")
PlayerAccountingUI.instance = nil
PlayerAccountingUI.SMALL_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()
PlayerAccountingUI.MEDIUM_FONT_HGT = getTextManager():getFontFromEnum(UIFont.Medium):getLineHeight()

local EVENT_TYPES = ETOMARAT.PlayerAccounting.EVENT_TYPES

local PANEL_W = 420
local PANEL_H = 520
local INSET = 28
local FOOTER_H = 48
local ROW_BASE_H = 40
local ROW_NOTE_EXTRA = 14

local COL_LABEL = { r = 0.72, g = 0.68, b = 0.55, a = 1 }
local COL_TITLE = { r = 0.88, g = 0.78, b = 0.45, a = 1 }
local COL_GREEN = { r = 0.38, g = 0.78, b = 0.45, a = 1 }
local COL_GOLD = { r = 0.90, g = 0.78, b = 0.32, a = 1 }
local COL_MUTED = { r = 0.50, g = 0.48, b = 0.40, a = 1 }
local COL_RED = { r = 0.92, g = 0.38, b = 0.30, a = 1 }
local COL_INK = { r = 0.82, g = 0.80, b = 0.72, a = 1 }

local TEX = {}

local function loadTextures()
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

    local rivet = { { 7, 7 }, { 7, h - 12 }, { w - 12, h - 12 } }
    for _, p in ipairs(rivet) do
        ui:drawRect(p[1], p[2], 5, 5, 1, 0.42, 0.34, 0.16)
        ui:drawRect(p[1] + 1, p[2] + 1, 3, 3, 1, 0.62, 0.52, 0.28)
    end
end

local function buildEntryTitle(eventType, recipient)
    if eventType == EVENT_TYPES.Linked then
        return getText("IGUI_Accounting_Linked_Wallet")
    end
    if eventType == EVENT_TYPES.TransferIn then
        return getText("IGUI_Accounting_Transfer_In") .. (recipient or "")
    end
    if eventType == EVENT_TYPES.TransferOut then
        return getText("IGUI_Accounting_Transfer_Out") .. (recipient or "")
    end
    if eventType == EVENT_TYPES.Deposit then
        return getText("IGUI_Accounting_Deposit")
    end
    if eventType == EVENT_TYPES.Withdraw then
        return getText("IGUI_Accounting_Withdraw")
    end
    return tostring(eventType or "")
end

local function isCreditEvent(eventType)
    return eventType == EVENT_TYPES.TransferIn
        or eventType == EVENT_TYPES.Deposit
        or eventType == EVENT_TYPES.Linked
end

function PlayerAccountingUI:show()
    if PlayerAccountingUI.instance then
        PlayerAccountingUI.instance:setVisible(true)
        PlayerAccountingUI.instance:addToUIManager()
        PlayerAccountingUI.instance:refresh()
        PlayerAccountingUI.instance:bringToTop()
        return PlayerAccountingUI.instance
    end
    local ui = PlayerAccountingUI:new(0, 0, PANEL_W, PANEL_H)
    ui:initialise()
    ui:instantiate()
    ui:addToUIManager()
    ui:setVisible(true)
    ui:bringToTop()
    PlayerAccountingUI.instance = ui
    return ui
end

function PlayerAccountingUI:new(x, y, width, height)
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
    o.playerObj = getPlayer()
    o.sectionLines = {}
    o.entryCount = 0
    o.moveWithMouse = true
    return o
end

function PlayerAccountingUI:initialise()
    ISPanel.initialise(self)
    self.onPlayerAccountingChange_handler = function()
        if PlayerAccountingUI.instance and PlayerAccountingUI.instance:getIsVisible() then
            PlayerAccountingUI.instance:refresh()
        end
    end
    Events.onPlayerAccountingChange.Add(self.onPlayerAccountingChange_handler)
end

function PlayerAccountingUI:prerender()
    drawPanelChrome(self)
end

function PlayerAccountingUI:render()
    ISPanel.render(self)

    local title = "KNOX BANK"
    local tw = getTextManager():MeasureStringX(UIFont.Medium, title)
    self:drawText(title, (self.width - tw) / 2, 18, COL_TITLE.r, COL_TITLE.g, COL_TITLE.b, 1, UIFont.Medium)

    local sub = getText("IGUI_Accounting_Title") .. "  ·  " .. (self.playerObj and self.playerObj:getUsername() or "")
    local sw = getTextManager():MeasureStringX(UIFont.Small, sub)
    self:drawText(sub, (self.width - sw) / 2, 42, COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small)

    local footer = getText("IGUI_Accounting_Entries", tostring(self.entryCount or 0))
    local fw = getTextManager():MeasureStringX(UIFont.Small, footer)
    local footerY = self.height - FOOTER_H + 4
    local footerBoxH = FOOTER_H - 10
    local textY = footerY + (footerBoxH - PlayerAccountingUI.SMALL_FONT_HGT) / 2
    self:drawText(footer, (self.width - fw) / 2, textY, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 0.9, UIFont.Small)
end

function PlayerAccountingUI:layoutBalance()
    if not self.balanceLabel then
        return
    end
    local labelW = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_Accounting_Balance"))
    self.balanceLabel:setX((self.width - labelW) / 2)

    local coinImg = Currency.CoinsTexture.Coin
    local iconW = coinImg.scale + 4
    local coinText = self.balanceCoinLabel:getName() or "0"
    local coinTextW = getTextManager():MeasureStringX(UIFont.Medium, coinText)
    local leftGroupW = iconW + 4 + coinTextW
    local groupGap = 28
    local totalW = leftGroupW

    if Currency.UseSpecialCoin and self.balanceSpecialCoinLabel then
        local specialText = self.balanceSpecialCoinLabel:getName() or "0"
        local specialTextW = getTextManager():MeasureStringX(UIFont.Medium, specialText)
        totalW = leftGroupW + groupGap + iconW + 4 + specialTextW
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

function PlayerAccountingUI:refreshBalance()
    local balance = main.getTotal() or { coin = 0, specialCoin = 0 }
    local coin = tonumber(balance.coin) or 0
    local specialCoin = tonumber(balance.specialCoin) or 0
    if self.balanceCoinLabel then
        self.balanceCoinLabel:setName("" .. Currency.format(coin))
    end
    if self.balanceSpecialCoinLabel then
        self.balanceSpecialCoinLabel:setName("" .. Currency.format(specialCoin))
    end
    self:layoutBalance()
end

function PlayerAccountingUI:buildLogEntries()
    local logData = main.getLog() or {}
    local entries = {}
    for i = #logData, 1, -1 do
        local row = logData[i]
        if row then
            local dt, eventType, coin, specialCoin, recipient, note = unpack(row)
            coin = tonumber(coin) or 0
            specialCoin = tonumber(specialCoin) or 0
            note = note and tostring(note) or ""
            if note == "" then
                note = nil
            end
            local credit = isCreditEvent(eventType)
            local hasAmount = coin > 0 or specialCoin > 0
            local hasNote = note ~= nil
            local rowH = ROW_BASE_H
            if not hasAmount and eventType == EVENT_TYPES.Linked then
                rowH = 28
            end
            if hasNote then
                rowH = rowH + ROW_NOTE_EXTRA
            end
            local entry = {
                dt = tostring(dt or ""),
                eventType = eventType,
                title = buildEntryTitle(eventType, recipient),
                coin = coin,
                specialCoin = specialCoin,
                isCredit = credit,
                note = note,
                rowH = rowH,
            }
            table.insert(entries, entry)
        end
    end
    return entries
end

function PlayerAccountingUI:refreshLog()
    if not self.logList then
        return
    end
    self.logList:clear()
    local entries = self:buildLogEntries()
    self.entryCount = #entries
    for _, entry in ipairs(entries) do
        self.logList:addItem(entry.title, entry)
    end
    self.logList.selected = 0
end

function PlayerAccountingUI:refresh()
    self:refreshBalance()
    self:refreshLog()
end

function PlayerAccountingUI:doDrawItem(y, item, alt)
    local entry = item.item
    if not entry then
        return y
    end
    local h = entry.rowH or ROW_BASE_H
    item.height = h

    if y + self:getYScroll() >= self.height then
        return y + h
    end
    if y + h + self:getYScroll() <= 0 then
        return y + h
    end

    if alt then
        self:drawRect(0, y, self:getWidth(), h - 1, 0.12, 0.08, 0.09, 0.07)
    end
    self:drawRect(0, y + h - 1, self:getWidth(), 1, 0.35, 0.35, 0.30, 0.16)

    local pad = 8
    local dateW = getTextManager():MeasureStringX(UIFont.Small, entry.dt)
    self:drawText(entry.dt, pad, y + 4, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 1, UIFont.Small)

    local titleX = pad + math.max(dateW + 10, 110)
    local title = entry.title or ""
    local maxTitleW = self:getWidth() - titleX - 12
    while getTextManager():MeasureStringX(UIFont.Small, title) > maxTitleW and #title > 4 do
        title = string.sub(title, 1, #title - 4) .. "..."
    end
    self:drawText(title, titleX, y + 4, COL_INK.r, COL_INK.g, COL_INK.b, 1, UIFont.Small)

    local amountCol = entry.isCredit and COL_GREEN or COL_RED
    local showCoin = (entry.coin or 0) > 0
    local showSpecial = Currency.UseSpecialCoin and (entry.specialCoin or 0) > 0
    local showAmount = entry.eventType ~= EVENT_TYPES.Linked and (showCoin or showSpecial)
    if showAmount then
        local ax = pad
        local ay = y + 4 + PlayerAccountingUI.SMALL_FONT_HGT
        local sign = entry.isCredit and "+" or "-"
        local iconSize = 14

        if showCoin then
            local coinImg = Currency.CoinsTexture.Coin
            if coinImg and coinImg.texture then
                self:drawTextureScaledAspect(coinImg.texture, ax, ay + 1, iconSize, iconSize, 1, 1, 1, 1)
                ax = ax + iconSize + 4
            end
            local coinText = sign .. Currency.format(entry.coin)
            self:drawText(coinText, ax, ay, amountCol.r, amountCol.g, amountCol.b, 1, UIFont.Small)
            ax = ax + getTextManager():MeasureStringX(UIFont.Small, coinText) + 12
        end

        if showSpecial then
            local specialImg = Currency.CoinsTexture.SpecialCoin
            if specialImg and specialImg.texture then
                self:drawTextureScaledAspect(specialImg.texture, ax, ay + 1, iconSize, iconSize, 1, 1, 1, 1)
                ax = ax + iconSize + 4
            end
            local specialText = sign .. Currency.format(entry.specialCoin)
            self:drawText(specialText, ax, ay, amountCol.r, amountCol.g, amountCol.b, 1, UIFont.Small)
        end
    end

    if entry.note then
        local noteY = y + 4 + PlayerAccountingUI.SMALL_FONT_HGT * (showAmount and 2 or 1)
        local note = getText("IGUI_Accounting_Note") .. " " .. entry.note
        local maxNoteW = self:getWidth() - pad * 2
        while getTextManager():MeasureStringX(UIFont.Small, note) > maxNoteW and #note > 4 do
            note = string.sub(note, 1, #note - 4) .. "..."
        end
        self:drawText(note, pad, noteY, COL_MUTED.r, COL_MUTED.g, COL_MUTED.b, 0.85, UIFont.Small)
    end

    return y + h
end

function PlayerAccountingUI:createChildren()
    local x = INSET
    local contentW = self.width - INSET * 2
    self.sectionLines = {}

    self.closeBtn = ISButton:new(self.width - 26, 6, 18, 18, "X", self, PlayerAccountingUI.onClose)
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

    local y = 78
    table.insert(self.sectionLines, y - 6)
    self.balanceLabel = ISLabel:new(x, y, PlayerAccountingUI.SMALL_FONT_HGT, getText("IGUI_Accounting_Balance"), COL_LABEL.r, COL_LABEL.g, COL_LABEL.b, 1, UIFont.Small, true)
    self:addChild(self.balanceLabel)

    local coinImg = Currency.CoinsTexture.Coin
    self.balanceCoinTex = ISImage:new(x, y + 18, 0, 0, coinImg.texture)
    self.balanceCoinTex.scaledWidth = coinImg.scale + 4
    self.balanceCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.balanceCoinTex)

    self.balanceCoinLabel = ISLabel:new(x + 24, y + 18, PlayerAccountingUI.MEDIUM_FONT_HGT, "0", COL_GREEN.r, COL_GREEN.g, COL_GREEN.b, 1, UIFont.Medium, true)
    self:addChild(self.balanceCoinLabel)

    coinImg = Currency.CoinsTexture.SpecialCoin
    self.balanceSpecialCoinTex = ISImage:new(x + 190, y + 18, 0, 0, coinImg.texture)
    self.balanceSpecialCoinTex.scaledWidth = coinImg.scale + 4
    self.balanceSpecialCoinTex.scaledHeight = coinImg.scale + 4
    self:addChild(self.balanceSpecialCoinTex)

    self.balanceSpecialCoinLabel = ISLabel:new(x + 214, y + 18, PlayerAccountingUI.MEDIUM_FONT_HGT, "0", COL_GOLD.r, COL_GOLD.g, COL_GOLD.b, 1, UIFont.Medium, true)
    self:addChild(self.balanceSpecialCoinLabel)

    if not Currency.UseSpecialCoin then
        self.balanceSpecialCoinTex:setVisible(false)
        self.balanceSpecialCoinLabel:setVisible(false)
    end

    y = 140
    table.insert(self.sectionLines, y - 8)
    local listH = self.height - y - FOOTER_H - 8
    self.logList = ISScrollingListBox:new(x, y, contentW, listH)
    self.logList:initialise()
    self.logList:instantiate()
    self.logList.font = UIFont.Small
    self.logList.itemheight = ROW_BASE_H
    self.logList.selected = 0
    self.logList.joypadParent = self
    self.logList.drawBorder = true
    self.logList.borderColor = { r = 0.45, g = 0.38, b = 0.2, a = 0.75 }
    self.logList.backgroundColor = { r = 0.03, g = 0.04, b = 0.03, a = 0.9 }
    self.logList.doDrawItem = PlayerAccountingUI.doDrawItem
    self.logList.SMALL_FONT_HGT = PlayerAccountingUI.SMALL_FONT_HGT
    self:addChild(self.logList)

    self:refresh()
end

function PlayerAccountingUI:onClose()
    self:destroy()
end

function PlayerAccountingUI:destroy()
    if self.onPlayerAccountingChange_handler then
        Events.onPlayerAccountingChange.Remove(self.onPlayerAccountingChange_handler)
        self.onPlayerAccountingChange_handler = nil
    end
    self:setVisible(false)
    self:removeFromUIManager()
    if PlayerAccountingUI.instance == self then
        PlayerAccountingUI.instance = nil
    end
end

function PlayerAccountingUI:onMouseDown(x, y)
    if y < 78 then
        self.moving = true
        self.downX = self:getMouseX()
        self.downY = self:getMouseY()
    end
    return ISPanel.onMouseDown(self, x, y)
end

function PlayerAccountingUI:onMouseMove(dx, dy)
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
    end
    return ISPanel.onMouseMove(self, dx, dy)
end

function PlayerAccountingUI:onMouseUp(x, y)
    self.moving = false
    return ISPanel.onMouseUp(self, x, y)
end

function PlayerAccountingUI:onMouseUpOutside(x, y)
    self.moving = false
    return ISPanel.onMouseUpOutside(self, x, y)
end

function PlayerAccountingUI:onMouseWheel(del)
    if self.logList then
        return self.logList:onMouseWheel(del)
    end
    return false
end

local onPreFillInventoryObjectContextMenu = function(playerIndex, context, items)
    items = ISInventoryPane.getActualItems(items)
    if not items or #items > 1 then
        return
    end
    local item = items[1]
    if not item then
        return
    end
    local itemType = item:getFullType()
    if not Currency.Wallets[itemType] then
        return
    end
    if not item:isInPlayerInventory() then
        return
    end
    local player = getSpecificPlayer(playerIndex)
    local username = player:getUsername()
    if not (item:getModData().belongsTo == username) then
        return
    end
    context:addOption(getText("IGUI_Show_Accounting"), nil, function()
        PlayerAccountingUI:show()
    end)
end

Events.OnPreFillInventoryObjectContextMenu.Add(onPreFillInventoryObjectContextMenu)

function ShowPlayerAccountingUI()
    return PlayerAccountingUI:show()
end
