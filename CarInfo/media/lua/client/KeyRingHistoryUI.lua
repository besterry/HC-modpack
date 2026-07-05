if not isClient() then return end

require "ISUI/ISPanel"

CI_KeyRing = CI_KeyRing or {}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local COPY_BTN_W = 54
local COPY_BTN_H = 22
local COPY_BTN_PAD = 4
local SCROLLBAR_W = 17
local COPY_NOTICE_MS = 2000
local LINE_Y = { 2, 18, 32 }

local function getVehicleDisplayName(model)
    if not model then return getText("IGUI_CI_KeyRingHistoryUnknown") end
    local key = "IGUI_VehicleName" .. model
    local text = getText(key)
    if text == key then return model end
    return text
end

local function formatPlate(sqlId)
    return getText("IGUI_CI_PlateFormat", tostring(sqlId))
end

local function getEntryDate(entry)
    return entry.date or entry.dateEnter or "-"
end

local function formatEntryCopyText(entry)
    local dateLine = getText("IGUI_CI_KeyRingHistoryDate") .. ": " .. getEntryDate(entry)
    if entry.active then
        dateLine = dateLine .. " (" .. getText("IGUI_CI_KeyRingHistoryActive") .. ")"
    end
    return getVehicleDisplayName(entry.model) .. "\n"
        .. formatPlate(entry.sqlId) .. "\n"
        .. dateLine
end

CI_KeyRingHistoryUI = ISPanel:derive("CI_KeyRingHistoryUI")
CI_KeyRingHistoryUI.instance = nil

function CI_KeyRing.openHistoryUI(player, keyRing)
    if CI_KeyRingHistoryUI.instance then
        CI_KeyRingHistoryUI.instance:close()
    end

    local core = getCore()
    local width = 460
    local height = 420
    local x = (core:getScreenWidth() - width) / 2
    local y = (core:getScreenHeight() - height) / 2

    local ui = CI_KeyRingHistoryUI:new(x, y, width, height, player, keyRing)
    ui:initialise()
    ui:instantiate()
    ui:addToUIManager()
    CI_KeyRingHistoryUI.instance = ui
end

function CI_KeyRingHistoryUI:initialise()
    ISPanel.initialise(self)
end

function CI_KeyRingHistoryUI:showCopyNotice()
    self.copyNoticeUntil = getTimeInMillis() + COPY_NOTICE_MS
    if self.copyNoticeLabel then
        self.copyNoticeLabel:setVisible(true)
    end
end

function CI_KeyRingHistoryUI:copyEntry(entry)
    if not entry then return end
    local text = formatEntryCopyText(entry)
    if Clipboard and Clipboard.setClipboard then
        Clipboard.setClipboard(text)
    end
    self:showCopyNotice()
end

local function getCopyButtonX(list)
    local scrollbarPad = 0
    if list.isVScrollBarVisible and list:isVScrollBarVisible() then
        scrollbarPad = SCROLLBAR_W
    end
    return list:getWidth() - scrollbarPad - COPY_BTN_W - COPY_BTN_PAD
end

function CI_KeyRingHistoryUI:drawCopyButton(list, x, y, a)
    list:drawRect(x, y, COPY_BTN_W, COPY_BTN_H, 0.75, 0.15, 0.15, 0.15)
    list:drawRectBorder(x, y, COPY_BTN_W, COPY_BTN_H, a, 0.55, 0.55, 0.55, 1)
    local label = getText("IGUI_CI_CopyBtn")
    local tw = getTextManager():MeasureStringX(list.font, label)
    list:drawText(label, x + (COPY_BTN_W - tw) / 2, y + 4, 0.9, 0.9, 0.85, a, list.font)
end

function CI_KeyRingHistoryUI:isCopyButtonClick(list, row, x, y)
    if row < 1 or row > #list.items then return false end

    local copyX = getCopyButtonX(list)
    if x < copyX or x > copyX + COPY_BTN_W then return false end

    local yScroll = list:getYScroll()
    local relY = y + yScroll - (row - 1) * list.itemheight
    local copyY = (list.itemheight - COPY_BTN_H) / 2
    return relY >= copyY and relY <= copyY + COPY_BTN_H
end

function CI_KeyRingHistoryUI:handleHistoryListCopy(list, x, y)
    local row = list:rowAt(x, y)
    if row < 1 or row > #list.items then return false end

    local listItem = list.items[row]
    if not listItem or type(listItem.item) ~= "table" then return false end
    if not self:isCopyButtonClick(list, row, x, y) then return false end

    self:copyEntry(listItem.item)
    return true
end

function CI_KeyRingHistoryUI:createChildren()
    ISPanel.createChildren(self)

    local pad = 10
    local titleHgt = getTextManager():getFontHeight(UIFont.Medium) + 4

    self.titleLabel = ISLabel:new(pad, pad, titleHgt, getText("IGUI_CI_KeyRingHistoryTitle"), 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(self.titleLabel)

    local hintY = pad + titleHgt + 2
    self.hintLabel = ISLabel:new(pad, hintY, FONT_HGT_SMALL, getText("IGUI_CI_KeyRingHistoryHint"), 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self:addChild(self.hintLabel)

    local noticeText = getText("IGUI_CI_Copied")
    local noticeW = getTextManager():MeasureStringX(UIFont.Small, noticeText)
    self.copyNoticeLabel = ISLabel:new(self.width - pad - noticeW, pad + 2, FONT_HGT_SMALL, noticeText, 0.4, 0.9, 0.5, 1, UIFont.Small, true)
    self.copyNoticeLabel:setVisible(false)
    self:addChild(self.copyNoticeLabel)

    local listY = hintY + FONT_HGT_SMALL + 6
    local listH = self.height - listY - 40

    self.historyList = ISScrollingListBox:new(pad, listY, self.width - pad * 2, listH)
    self.historyList:initialise()
    self.historyList:instantiate()
    self.historyList.itemheight = 50
    self.historyList.selected = 0
    self.historyList.joypadParent = self
    self.historyList.font = UIFont.NewSmall
    self.historyList.drawBorder = true
    self:addChild(self.historyList)

    local panelRef = self
    local listRef = self.historyList
    function listRef:doDrawItem(y, item, alt)
        return panelRef:drawHistoryItem(self, y, item, alt)
    end
    function listRef:onMouseDown(x, y)
        if panelRef:handleHistoryListCopy(self, x, y) then
            return true
        end
        return ISScrollingListBox.onMouseDown(self, x, y)
    end

    local btnW = 120
    local btnH = 25
    local btnY = self.height - pad - btnH

    self.closeBtn = ISButton:new(self.width - pad - btnW, btnY, btnW, btnH, getText("IGUI_CraftUI_Close"), self, CI_KeyRingHistoryUI.onClose)
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self:addChild(self.closeBtn)

    self:populateList()
end

function CI_KeyRingHistoryUI:update()
    ISPanel.update(self)
    if self.copyNoticeUntil and getTimeInMillis() >= self.copyNoticeUntil then
        self.copyNoticeUntil = nil
        if self.copyNoticeLabel then
            self.copyNoticeLabel:setVisible(false)
        end
    end
end

function CI_KeyRingHistoryUI:populateList()
    self.historyList:clear()

    local history = CI_KeyRing.getHistory(self.keyRing)
    if #history == 0 then
        self.historyList:addItem(getText("IGUI_CI_KeyRingHistoryEmpty"), nil)
        self.historyList.itemheight = 22
        return
    end

    self.historyList.itemheight = 50
    for i, entry in ipairs(history) do
        self.historyList:addItem(tostring(i), entry)
    end
end

function CI_KeyRingHistoryUI:drawHistoryItem(list, y, item, alt)
    local a = 0.9
    list:drawRectBorder(0, y, list:getWidth(), list.itemheight - 1, a, list.borderColor.r, list.borderColor.g, list.borderColor.b)

    if list.selected == item.index then
        list:drawRect(0, y, list:getWidth(), list.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    if not item.item or type(item.item) ~= "table" then
        list:drawText(item.text or "", 10, y + 4, 1, 1, 1, a, list.font)
        return y + list.itemheight
    end

    local entry = item.item
    local modelLine = getVehicleDisplayName(entry.model)
    local plateLine = formatPlate(entry.sqlId)
    local dateLine = getText("IGUI_CI_KeyRingHistoryDate") .. ": " .. getEntryDate(entry)
    if entry.active then
        dateLine = dateLine .. " (" .. getText("IGUI_CI_KeyRingHistoryActive") .. ")"
    end

    local copyX = getCopyButtonX(list)
    local copyY = y + (list.itemheight - COPY_BTN_H) / 2

    list:drawText(modelLine, 10, y + LINE_Y[1], 1, 1, 1, a, list.font)
    list:drawText(plateLine, 10, y + LINE_Y[2], 0.85, 0.85, 0.7, a, list.font)
    list:drawText(dateLine, 10, y + LINE_Y[3], 0.75, 0.75, 0.75, a, list.font)

    self:drawCopyButton(list, copyX, copyY, a)

    return y + list.itemheight
end

function CI_KeyRingHistoryUI:onClose()
    self:close()
end

function CI_KeyRingHistoryUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    CI_KeyRingHistoryUI.instance = nil
end

function CI_KeyRingHistoryUI:new(x, y, width, height, player, keyRing)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.keyRing = keyRing
    o.copyNoticeUntil = nil
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.85 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.moveWithMouse = true
    return o
end
