--********************************************************************************
--**                             ALEKSANDR OPEKUNOV | ZUU                       **
--**                BASED ON ISMiniScoreboardUI BY ROBERT JOHNSON               **
--********************************************************************************


IST15KKillboardUI = ISPanel:derive("IST15KKillboardUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

if not getT15KKillboardInstance then
    require('shared/T15KillboardUtils')
end

local T15KKillboard = getT15KKillboardInstance()

function IST15KKillboardUI:initialise()
    ISPanel.initialise(self)
end

function IST15KKillboardUI:createChildren()
    ISPanel.createChildren(self)
    local btnWid = 80
    local btnHgt = FONT_HGT_SMALL + 2

    local y = 10 + FONT_HGT_SMALL + 10

    self.playerList = ISScrollingListBox:new(10, 50, self.width - 20, self.height - 80)
    self.playerList:initialise()
    self.playerList:instantiate()
    self.playerList.itemheight = 22
    self.playerList.selected = 0
    self.playerList.joypadParent = self
    self.playerList.font = UIFont.NewSmall
    self.playerList.doDrawItem = self.drawPlayers
    self.playerList.drawBorder = true
    self.playerList.onRightMouseUp = IST15KKillboardUI.onRightMousePlayerList
    self.playerList:addColumn("#", 0)
    self.playerList:addColumn(getText("IGUI_T15KKillboard_Name"), 35)
    self.playerList:addColumn(getText("IGUI_T15KKillboard_Kills"), 160)
    self:addChild(self.playerList)

    self.no = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, getText("UI_btn_close"), self, IST15KKillboardUI.onClick)
    self.no.internal = "CLOSE"
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise()
    self.no:instantiate()
    self.no.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
    self:addChild(self.no)

    if getCore():getDebug() or isAdmin() then
        self.no = ISButton:new(self.playerList.x, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, "CLEAR", self, IST15KKillboardUI.onClick)
        self.no.internal = "CLEAR"
        self.no.anchorTop = false
        self.no.anchorBottom = true
        self.no:initialise()
        self.no:instantiate()
        self.no.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.9 }
        self:addChild(self.no)
    end

end

function IST15KKillboardUI:onRightMousePlayerList(x, y)
    local row = self:rowAt(x, y)
    if row < 1 or row > #self.items then
        return
    end
    self.selected = row
    local scoreboard = self.parent
    scoreboard:doPlayerListContextMenu(self.items[row].item, self:getX() + 30, self:getY() + self:getHeight() + 20)
end

function IST15KKillboardUI:doPlayerListContextMenu(player, x, y)
    if getCore():getDebug() or isAdmin() then
        local playerNum = self.admin:getPlayerNum()
        local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
        context:addOption(getText("IGUI_T15KKillboard_Delete"), self, IST15KKillboardUI.onCommand, player, "DELETE")
    end
end

function IST15KKillboardUI:onCommand(player, command)
    if command == "DELETE" then
        local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_T15KKillboard_Confirm"), true, nil, function(_, btn)
            if btn.internal == "YES" then
                print("Delete from killboard: " .. player.user)
                sendClientCommand("T15KKillboardModule", "playerRemove", { player.user })
            end
        end);
        modal:initialise()
        modal:addToUIManager()
    end
end

function IST15KKillboardUI:updateList(table)
    self.playerList:clear()

    if table == nil then
        local item = {}
        item.user = getText("IGUI_T15KKillboard_Loading")
        item.kills = nil
        self.playerList:addItem(getText("IGUI_T15KKillboard_Loading"), item)
        return
    end

    for i = 1, #table do
        local item = {}
        item.user = table[i][1]
        item.kills = table[i][2]
        --item.survivals = table[i][3] FUTURE: for Survival kill list
        local item0 = self.playerList:addItem(item.user, item)
        --tooltip
        if isAdmin() then
            item0.tooltip = T15KKillboard.timeDiffInString(table[i][4])
        end
    end
end

function IST15KKillboardUI:drawPlayers(y, item, alt)

    local iconSize = FONT_HGT_SMALL
    local a = 0.9

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end
    self:drawText(tostring(item.index), 3, y + 2, 1, 1, 1, a, self.font)

    if item.index <= 3 then
        local texture = getTexture("media/textures/UI_Icon_Star_" .. item.index .. ".png")
        if texture then
            self:drawTextureScaledAspect2(texture, 12, y + (self.itemheight - iconSize) / 2 - 1, iconSize, iconSize, 1, 1, 1, 1);
        end
    end
    self:drawText(item.item.user, self.columns[2].size + 3, y + 2, 1, 1, 1, a, self.font)
    self:drawText(tostring(item.item.kills), self.columns[3].size + 3, y + 4, 1, 1, 1, a, self.font)

    return y + self.itemheight
end

function IST15KKillboardUI:prerender()
    local z = 10
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawText(getText("IGUI_T15KKillboard_Rank_Title") .. " " .. T15KKillboard.getSandboxVar("PlayersPerPage"), self.width / 2 - (getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_T15KKillboard_Rank_Title") .. " " .. T15KKillboard.getSandboxVar("PlayersPerPage")) / 2), z, 1, 1, 1, 1, UIFont.Small)
end

function IST15KKillboardUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    elseif button.internal == "CLEAR" then
        local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_T15KKillboard_Clear"), true, nil, function(_, btn)
            if btn.internal == "YES" then
                sendClientCommand("T15KKillboardModule", "clearKillboard", {})
            end
        end);
        modal:initialise()
        modal:addToUIManager()
    end
end

function IST15KKillboardUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    self:onClose()
    IST15KKillboardUI.instance = nil
end

function IST15KKillboardUI:new(x, y, width, height, onClose, player)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 }
    o.width = width
    o.height = height
    o.admin = getPlayer()
    o.moveWithMouse = true
    o.killboard = {}
    o.onClose = onClose
    IST15KKillboardUI.instance = o
    return o
end
