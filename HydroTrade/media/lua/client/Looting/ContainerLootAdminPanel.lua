require "ISUI/ISCollapsableWindow"

ContainerLootAdminPanel = ISCollapsableWindow:derive("ContainerLootAdminPanel")
ContainerLootAdminPanel.instance = nil

local PANEL_W = 580
local PANEL_H = 560
local LABEL_COL_WIDTH = 0.44

local function boolText(v)
    return v and getText("IGUI_ContainerLootBackup_Yes") or getText("IGUI_ContainerLootBackup_No")
end

local function valueColor(key, raw, info)
    if key == "items:size" and (tonumber(raw) or 0) == 0 then
        return 0.95, 0.35, 0.35, 1
    end
    if key == "isExplored" or key == "isHasBeenLooted" then
        if info and (info.itemCount or 0) == 0 and info.isExplored and info.hasBeenLooted then
            return 0.95, 0.7, 0.25, 1
        end
    end
    if key == "eligibleForBackup" and raw == true then
        return 0.45, 0.9, 0.45, 1
    end
    if key == "BackupFailed" and raw == true then
        return 0.95, 0.35, 0.35, 1
    end
    return 0.92, 0.92, 0.92, 1
end

function ContainerLootAdminPanel.getCenteredXY(width, height)
    local core = getCore()
    local x = math.max(0, math.floor((core:getScreenWidth() - width) / 2))
    local y = math.max(0, math.floor((core:getScreenHeight() - height) / 2))
    return x, y
end

function ContainerLootAdminPanel.OnOpenPanel(info, obj, container)
    local x, y = ContainerLootAdminPanel.getCenteredXY(PANEL_W, PANEL_H)
    if ContainerLootAdminPanel.instance == nil then
        ContainerLootAdminPanel.instance = ContainerLootAdminPanel:new(x, y, PANEL_W, PANEL_H)
        ContainerLootAdminPanel.instance:initialise()
        ContainerLootAdminPanel.instance:instantiate()
    else
        ContainerLootAdminPanel.instance:setX(x)
        ContainerLootAdminPanel.instance:setY(y)
    end
    ContainerLootAdminPanel.instance.obj = obj
    ContainerLootAdminPanel.instance.container = container
    ContainerLootAdminPanel.instance:setInfo(info)
    ContainerLootAdminPanel.instance:addToUIManager()
    ContainerLootAdminPanel.instance:setVisible(true)
    return ContainerLootAdminPanel.instance
end

function ContainerLootAdminPanel:initialise()
    ISCollapsableWindow.initialise(self)
    self.title = getText("IGUI_ContainerLootBackup_Title")
    self.resizable = true
    self.minimumWidth = 460
    self.minimumHeight = 380
end

function ContainerLootAdminPanel:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local listY = th + pad + 36
    local btnH = 26
    local bottomH = btnH + pad * 2

    self.summaryLabel = ISLabel:new(pad, th + pad, 20, "", 1, 1, 1, 1, UIFont.Medium, true)
    self.summaryLabel:initialise()
    self:addChild(self.summaryLabel)

    self.hintLabel = ISLabel:new(pad, th + pad + 22, 16, "", 0.75, 0.75, 0.75, 1, UIFont.Small, true)
    self.hintLabel:initialise()
    self:addChild(self.hintLabel)

    self.infoList = ISScrollingListBox:new(pad, listY, self.width - pad * 2, self.height - listY - bottomH)
    self.infoList:initialise()
    self.infoList:instantiate()
    self.infoList.itemheight = 22
    self.infoList.font = UIFont.Small
    self.infoList.drawBorder = true
    self.infoList.doDrawItem = ContainerLootAdminPanel.drawInfoRow
    self.infoList.target = self
    self:addChild(self.infoList)

    local refreshBtn = ISButton:new(pad, self.height - pad - btnH, 120, btnH, getText("IGUI_ContainerLootBackup_Refresh"), self, ContainerLootAdminPanel.onClickRefresh)
    refreshBtn:initialise()
    self:addChild(refreshBtn)

    local closeBtn = ISButton:new(self.width - pad - 120, self.height - pad - btnH, 120, btnH, getText("IGUI_CraftUI_Close"), self, ContainerLootAdminPanel.onClickClose)
    closeBtn:initialise()
    self:addChild(closeBtn)

    self.refreshBtn = refreshBtn
    self.closeBtn = closeBtn
    self.listPad = pad
    self.bottomH = bottomH
    self.listTop = listY
end

function ContainerLootAdminPanel:onResize()
    ISUIElement.onResize(self)
    local pad = self.listPad or 10
    local btnH = 26
    local listY = self.listTop or (self:titleBarHeight() + 46)
    local bottomH = self.bottomH or 46
    if self.infoList then
        self.infoList:setWidth(self.width - pad * 2)
        self.infoList:setHeight(self.height - listY - bottomH)
    end
    if self.closeBtn then
        self.closeBtn:setX(self.width - pad - 120)
        self.closeBtn:setY(self.height - pad - btnH)
    end
    if self.refreshBtn then
        self.refreshBtn:setY(self.height - pad - btnH)
    end
end

function ContainerLootAdminPanel:drawInfoRow(y, item, alt)
    local row = item.item
    if not row then
        return y + self.itemheight
    end

    if alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.1, 0.18, 0.18, 0.18)
    end
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight - 1, 0.9, 0.32, 0.32, 0.32)

    if row.sectionHeader then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.4, 0.12, 0.12, 0.12)
        self:drawText(row.sectionHeader, 8, y + 4, 0.9, 0.9, 0.9, 1, UIFont.Small)
        return y + self.itemheight
    end

    local labelW = math.floor(self:getWidth() * LABEL_COL_WIDTH)
    local label = (row.section and (row.section .. ".") or "") .. tostring(row.key or "")
    local vr, vg, vb, va = valueColor(row.key, row.raw, self.panelInfo)
    self:drawText(label, 8, y + 4, 0.65, 0.65, 0.65, 1, UIFont.Small)
    self:drawText(tostring(row.value or "-"), labelW + 8, y + 4, vr, vg, vb, va, UIFont.Small)
    return y + self.itemheight
end

function ContainerLootAdminPanel:updateSummary(info)
    if not info then
        self.summaryLabel:setName("")
        self.hintLabel:setName("")
        return
    end
    self.summaryLabel:setName(string.format("%s  |  %s: %d",
        info.containerType or "?",
        getText("IGUI_ContainerLootBackup_ItemCount"),
        info.itemCount or 0))

    if (info.itemCount or 0) == 0 and info.isExplored and info.respawnReason then
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintWillRespawn") .. ": " .. info.respawnReason)
    elseif (info.itemCount or 0) == 0 and info.isExplored and info.needsLegacyStamp then
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintLegacyStamp"))
    elseif (info.itemCount or 0) == 0 and info.isExplored and info.hoursUntilRespawn then
        local hint = getText("IGUI_ContainerLootBackup_HintTimerWait") .. string.format(" %.1f h", info.hoursUntilRespawn)
        if info.backupFailed then
            hint = hint .. getText("IGUI_ContainerLootBackup_HintBackupFailedShort")
        end
        if info.vanillaHoursUntilRespawn ~= nil then
            hint = hint .. string.format(getText("IGUI_ContainerLootBackup_HintVanillaTimer"), info.vanillaHoursUntilRespawn)
        elseif info.vanillaLootRespawnHour == 0 then
            hint = hint .. getText("IGUI_ContainerLootBackup_HintVanillaTimerZero")
        else
            hint = hint .. getText("IGUI_ContainerLootBackup_HintVanillaTimerNA")
        end
        self.hintLabel:setName(hint)
    elseif (info.itemCount or 0) == 0 and info.isExplored and info.hasBeenLooted then
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintEmptyLooted"))
    elseif info.backupFailed then
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintBackupFailed"))
    elseif info.eligible then
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintEligible"))
    else
        self.hintLabel:setName(getText("IGUI_ContainerLootBackup_HintIneligible") .. ": " .. tostring(info.ineligibleReason or "-"))
    end
end

function ContainerLootAdminPanel:setInfo(info)
    self.info = info
    self.panelInfo = info
    self:populateList()
    self:updateSummary(info)
end

function ContainerLootAdminPanel:populateList()
    self.infoList:clear()
    local info = self.info
    if not info or not info.debugRows then
        return
    end

    local lastSection = nil
    for _, row in ipairs(info.debugRows) do
        if row.section ~= lastSection then
            lastSection = row.section
            self.infoList:addItem(row.section, { sectionHeader = row.section })
        end
        self.infoList:addItem(row.key, row)
    end
end

function ContainerLootAdminPanel:onClickRefresh()
    if self.obj and self.container then
        self:setInfo(ContainerLootDebug.collectFullDebug(self.obj, self.container))
    elseif self.info then
        self:populateList()
        self:updateSummary(self.info)
    end
end

function ContainerLootAdminPanel:onClickClose()
    self:setVisible(false)
    self:removeFromUIManager()
    ContainerLootAdminPanel.instance = nil
end

function ContainerLootAdminPanel:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.95 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    return o
end
