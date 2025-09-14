if isServer() then return end

ISChangeStatPlayersUI = ISPanel:derive("ISChangeStatPlayersUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISChangeStatPlayersUI:initialise()
    ISPanel.initialise(self)

    local pad = 10
    local y = pad
    local lblW = 150
    local fldW = self.width - lblW - pad * 3
    local rowH = FONT_HGT_SMALL + 8
    local btnH = math.max(22, FONT_HGT_SMALL + 4)

    self:addChild(ISLabel:new(pad, y, rowH, getText("IGUI_Username") .. ":", 1,1,1,1, UIFont.Small, true))
    self.lblUser = ISTextEntryBox:new(self.targetDisplayName or self.targetUsername, pad + lblW, y, fldW, rowH)
    self.lblUser:initialise(); self.lblUser:instantiate(); self.lblUser:setEditable(false)
    self:addChild(self.lblUser)
    y = y + rowH + 6

    self:addChild(ISLabel:new(pad, y, rowH, "Hours Survived:", 1,1,1,1, UIFont.Small, true))
    self.edHours = ISTextEntryBox:new("", pad + lblW, y, fldW, rowH)
    self.edHours:initialise(); self.edHours:instantiate()
    self.edHours:setOnlyNumbers(true)
    self:addChild(self.edHours)
    y = y + rowH + 6

    self:addChild(ISLabel:new(pad, y, rowH, "Zombie Kills:", 1,1,1,1, UIFont.Small, true))
    self.edKills = ISTextEntryBox:new("", pad + lblW, y, fldW, rowH)
    self.edKills:initialise(); self.edKills:instantiate()
    self.edKills:setOnlyNumbers(true)
    self:addChild(self.edKills)
    y = y + rowH + 10

    local btnW = math.floor((self.width - pad*3) / 3)

    self.btnSet = ISButton:new(pad, y, btnW, btnH, "Set", self, ISChangeStatPlayersUI.onClick)
    self.btnSet.internal = "SET"; self.btnSet:initialise(); self.btnSet:instantiate(); self:addChild(self.btnSet)

    self.btnAdd = ISButton:new(pad + btnW + pad, y, btnW, btnH, "Add", self, ISChangeStatPlayersUI.onClick)
    self.btnAdd.internal = "ADD"; self.btnAdd:initialise(); self.btnAdd:instantiate(); self:addChild(self.btnAdd)

    self.btnClose = ISButton:new(pad + (btnW + pad)*2, y, btnW, btnH, getText("UI_btn_close"), self, ISChangeStatPlayersUI.onClick)
    self.btnClose.internal = "CLOSE"; self.btnClose:initialise(); self.btnClose:instantiate(); self:addChild(self.btnClose)
end

function ISChangeStatPlayersUI:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
        return
    end

    local hours = self.edHours:getText(); hours = hours ~= "" and tonumber(hours) or nil
    local kills = self.edKills:getText(); kills = kills ~= "" and tonumber(kills) or nil
    local mode = button.internal == "ADD" and "add" or "set"

    if not self.targetUsername or self.targetUsername == "" then return end
    sendClientCommand(getPlayer(), "StatRestore", "setForUsername", {
        username = self.targetUsername,
        hours = hours,
        kills = kills,
        mode = mode,
    })

    self:close()
end

function ISChangeStatPlayersUI:prerender()
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawTextCentre("Change Player Stats", self.width/2, 6, 1,1,1,1, UIFont.Small)
end

function ISChangeStatPlayersUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISChangeStatPlayersUI.instance = nil
end

function ISChangeStatPlayersUI:new(x, y, w, h, targetUsername, targetDisplayName)
    local o = ISPanel:new(x, y, w, h)
    setmetatable(o, self); self.__index = self
    o.borderColor = {r=0.5, g=0.5, b=0.5, a=1}
    o.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.9}
    o.moveWithMouse = true
    o.targetUsername = targetUsername
    o.targetDisplayName = targetDisplayName or targetUsername
    return o
end

-- helper
function OpenChangeStatPlayersUI(username, displayName)
    if not isAdmin() then return end
    local w, h = 420, 180
    local ui = ISChangeStatPlayersUI:new(getMouseX() - w/2, getMouseY() - h/2, w, h, username, displayName)
    ui:initialise()
    ui:addToUIManager()
    ui:setVisible(true)
end

local function OnServerCommand(module, command, args)
    if module == "StatRestore" then
        if command == "setHoursSurvived" then
            local cur = getPlayer():getHoursSurvived()
            local val = tonumber(args.hours) or cur
            if args.mode == "add" then val = cur + val end
            getPlayer():setHoursSurvived(val)
        elseif command == "setZombieKills" then
            local cur = getPlayer():getZombieKills()
            local val = tonumber(args.kills) or cur
            if args.mode == "add" then val = cur + val end
            getPlayer():setZombieKills(val)
        end
    end
end
Events.OnServerCommand.Add(OnServerCommand)