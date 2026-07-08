require "ISUI/ISPanel"

ISFactionOfficersUI = ISPanel:derive("ISFactionOfficersUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

function ISFactionOfficersUI:initialise()
    ISPanel.initialise(self)

    local btnHgt2 = FONT_HGT_SMALL

    self.playerList = ISScrollingListBox:new(10, 40, self.width - 20, (FONT_HGT_SMALL + 2 * 2) * 8)
    self.playerList:initialise()
    self.playerList:instantiate()
    self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2
    self.playerList.selected = 0
    self.playerList.font = UIFont.NewSmall
    self.playerList.doDrawItem = self.drawPlayers
    self.playerList.drawBorder = true
    self:addChild(self.playerList)

    self.toggleOfficer = ISButton:new(10, self.playerList:getBottom() + 10, 70, btnHgt2, "", self, ISFactionOfficersUI.onClick)
    self.toggleOfficer.internal = "TOGGLE"
    self.toggleOfficer:initialise()
    self.toggleOfficer:instantiate()
    self.toggleOfficer.borderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    self.toggleOfficer.enable = false
    self:addChild(self.toggleOfficer)

    self.closeBtn = ISButton:new(0, self.toggleOfficer.y, 70, btnHgt2, getText("UI_Close"), self, ISFactionOfficersUI.onClick)
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self.closeBtn.borderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    self.closeBtn:setWidthToTitle(70)
    self.closeBtn:setX(self.width - self.closeBtn.width - 10)
    self:addChild(self.closeBtn)

    self:setHeight(self.closeBtn:getBottom() + 10)
    self:populateList()
end

function ISFactionOfficersUI:updateToggleButton()
    if not self.toggleOfficer then
        return
    end
    self.toggleOfficer:setWidthToTitle(70)
    if self.closeBtn then
        self.closeBtn:setX(self.width - self.closeBtn.width - 10)
    end
end

function ISFactionOfficersUI:populateList()
    self.playerList:clear()
    self.toggleOfficer.enable = false
    self.selectedPlayer = nil

    local faction = self.faction
    if not faction then
        return
    end

    local ownerName = faction:getOwner()
    local ownerItem = { name = ownerName, isOwner = true }
    self.playerList:addItem(ownerName .. " (" .. getText("IGUI_SafehouseUI_Owner") .. ")", ownerItem)

    for i = 0, faction:getPlayers():size() - 1 do
        local name = faction:getPlayers():get(i)
        local item = { name = name, isOwner = false }
        local label = name
        if HydroFactionRoles.isUsernameOfficer(name) then
            label = label .. " [" .. getText("IGUI_HydroFactionRoles_OfficerTag") .. "]"
        end
        self.playerList:addItem(label, item)
    end
end

function ISFactionOfficersUI:drawPlayers(y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
        if not item.item.isOwner then
            self.parent.selectedPlayer = item.item.name
            self.parent.toggleOfficer.enable = true
            if HydroFactionRoles.isUsernameOfficer(item.item.name) then
                self.parent.toggleOfficer.title = getText("IGUI_HydroFactionRoles_RemoveOfficer")
            else
                self.parent.toggleOfficer.title = getText("IGUI_HydroFactionRoles_AddOfficer")
            end
            self.parent:updateToggleButton()
        else
            self.parent.selectedPlayer = nil
            self.parent.toggleOfficer.enable = false
        end
    end

    self:drawText(item.text, 10, y + 2, 1, 1, 1, a, self.font)
    return y + self.itemheight
end

function ISFactionOfficersUI:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    local title = getText("IGUI_HydroFactionRoles_ManageOfficers")
    self:drawText(title, self.width / 2 - getTextManager():MeasureStringX(UIFont.Medium, title) / 2, 10, 1, 1, 1, 1, UIFont.Medium)
end

function ISFactionOfficersUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
        return
    end
    if button.internal == "TOGGLE" and self.selectedPlayer then
        local enabled = not HydroFactionRoles.isUsernameOfficer(self.selectedPlayer)
        HydroFactionRoles.requestSetOfficer(self.faction:getName(), self.selectedPlayer, enabled)
    end
end

function ISFactionOfficersUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISFactionOfficersUI.instance = nil
end

function ISFactionOfficersUI:new(x, y, width, height, faction, player)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 }
    o.faction = faction
    o.player = player
    o.moveWithMouse = true
    ISFactionOfficersUI.instance = o
    return o
end

function ISFactionOfficersUI.Open(faction, player)
    local w, h = 420, 320
    local ui = ISFactionOfficersUI:new(
        getCore():getScreenWidth() / 2 - w / 2,
        getCore():getScreenHeight() / 2 - h / 2,
        w, h, faction, player
    )
    ui:initialise()
    ui:addToUIManager()
    return ui
end
