-- ShopsMoney: UI и клиентская логика редактирования CoinBalance

local MODULE_NAME = "BS"

-- UI: окно редактирования баланса
ShopsMoneyUI = ISCollapsableWindow:derive("ShopsMoneyUI")

function ShopsMoneyUI:initialise()
    ISCollapsableWindow.initialise(self)
end

function ShopsMoneyUI:new(x, y, width, height, playerObj)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.player = playerObj
    o.resizable = false
    o.drawFrame = true
    o.title = "Money editor"
    o:setup()
    return o
end

function ShopsMoneyUI:setup()
    self:setResizable(false)
    self:setWantKeyEvents(true)
end

function ShopsMoneyUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local line = 30
    local y = self:titleBarHeight() + pad
    local labelW = 110
    local entryW = self.width - labelW - pad * 3
    local entryH = 24
    local btnW = 100
    local btnH = 25

    self.statusLbl = ISLabel:new(pad, y, entryH, "", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.statusLbl)
    y = y + line

    -- Username
    self.uLbl = ISLabel:new(pad, y + 4, entryH, "Username:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.uLbl)
    self.usernameEntry = ISTextEntryBox:new("", pad + labelW, y, entryW, entryH)
    self.usernameEntry:initialise()
    self.usernameEntry:instantiate()
    self:addChild(self.usernameEntry)
    y = y + line

    -- Coin
    self.cLbl = ISLabel:new(pad, y + 4, entryH, "coin:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.cLbl)
    self.coinEntry = ISTextEntryBox:new("0", pad + labelW, y, entryW, entryH)
    self.coinEntry:initialise()
    self.coinEntry:instantiate()
    if self.coinEntry.setOnlyNumbers then self.coinEntry:setOnlyNumbers(true) end
    self:addChild(self.coinEntry)
    y = y + line

    -- specialCoin
    self.scLbl = ISLabel:new(pad, y + 4, entryH, "specialCoin:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.scLbl)
    self.specialCoinEntry = ISTextEntryBox:new("0", pad + labelW, y, entryW, entryH)
    self.specialCoinEntry:initialise()
    self.specialCoinEntry:instantiate()
    if self.specialCoinEntry.setOnlyNumbers then self.specialCoinEntry:setOnlyNumbers(true) end
    self:addChild(self.specialCoinEntry)
    y = y + line + 10

    -- Buttons: Load, Save, Close
    self.loadBtn = ISButton:new(pad, y, btnW, btnH, getText("IGUI_Shop_Balance") or "Load", self, ShopsMoneyUI.onLoad)
    self.loadBtn.internal = "LOAD"
    self.loadBtn:initialise()
    self.loadBtn:instantiate()
    self:addChild(self.loadBtn)

    self.saveBtn = ISButton:new(pad + btnW + 8, y, btnW, btnH, getText("IGUI_SaveShop") or "Save", self, ShopsMoneyUI.onSave)
    self.saveBtn.internal = "SAVE"
    self.saveBtn:initialise()
    self.saveBtn:instantiate()
    self:addChild(self.saveBtn)

    self.closeBtn = ISButton:new(self.width - pad - btnW, y, btnW, btnH, getText("IGUI_Close") or "Close", self, ShopsMoneyUI.onClose)
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self:addChild(self.closeBtn)
end

function ShopsMoneyUI:prnStatus(text, r, g, b)
    self.statusLbl.name = tostring(text or "")
    self.statusLbl.r = r or 1
    self.statusLbl.g = g or 1
    self.statusLbl.b = b or 1
end

local function trim(s)
    if not s then return "" end
    return s:match("^%s*(.-)%s*$")
end

function ShopsMoneyUI:onLoad()
    local username = trim(self.usernameEntry:getText())
    if username == "" then
        self:prnStatus("Write username", 1, 0.4, 0.4)
        return
    end
    self:prnStatus("Request balance...", 1, 1, 0.6)
    sendClientCommand(MODULE_NAME, "GetBalance", { username = username })
end

function ShopsMoneyUI:onSave()
    local username = trim(self.usernameEntry:getText())
    if username == "" then
        self:prnStatus("Write username", 1, 0.4, 0.4)
        return
    end
    local coin = tonumber(self.coinEntry:getText()) or 0
    local specialCoin = tonumber(self.specialCoinEntry:getText()) or 0
    self:prnStatus("Saving...", 1, 1, 0.6)
    sendClientCommand(MODULE_NAME, "SetBalance", { username = username, coin = coin, specialCoin = specialCoin })
end

function ShopsMoneyUI:onClose()
    self:close()
end

function ShopsMoneyUI:close()
    self:removeFromUIManager()
    ShopsMoneyUI.instance = nil
end

-- Обработка ответов сервера
local function onServerCommand(module, command, args)
    if module ~= MODULE_NAME then return end
    local ui = ShopsMoneyUI.instance
    if command == "GetBalanceResult" then
        -- print("onServerCommand: GetBalanceResult")
        if ui then
            if args and args.username then
                ui.usernameEntry:setText(tostring(args.username))
            end
            if args and args.coin ~= nil then
                ui.coinEntry:setText(tostring(args.coin or 0))
            end
            if args and args.specialCoin ~= nil then
                ui.specialCoinEntry:setText(tostring(args.specialCoin or 0))
            end
            ui:prnStatus(args and args.message or "Loaded", 0.8, 1, 0.8)
        end
    elseif command == "SetBalanceResult" then
        -- print("onServerCommand: SetBalanceResult")
        if ui then
            local ok = args and args.success
            if ok then
                ui:prnStatus(args and args.message or "Saved", 0.8, 1, 0.8)
            else
                ui:prnStatus(args and args.message or "Error saving", 1, 0.5, 0.5)
            end
        end
    end
end
Events.OnServerCommand.Add(onServerCommand)

-- Добавление кнопки в админ-панель
local old_ISAdminPanelUI_create = ISAdminPanelUI and ISAdminPanelUI.create

if ISAdminPanelUI then
    function ISAdminPanelUI:create()
        if old_ISAdminPanelUI_create then old_ISAdminPanelUI_create(self) end

        local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
        local btnWid = 150
        local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
        local btnGapY = 5

        local last_btn = self.children[self.IDMax - 1]
        if last_btn and last_btn.internal == "CANCEL" then
            last_btn = self.children[self.IDMax - 2]
        end
        local x = last_btn and last_btn.x or 0
        local y = last_btn and (last_btn.y + btnHgt + btnGapY) or 0

        if getAccessLevel() == "admin" then
            self.ShopsMoneyBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_SMH_AdminBtn") or "Money balance", self, ISAdminPanelUI.onOptionMouseDownShopsMoney)
            self.ShopsMoneyBtn.internal = "AdminShopsMoney"
            self.ShopsMoneyBtn:initialise()
            self.ShopsMoneyBtn:instantiate()
            self.ShopsMoneyBtn.borderColor = self.buttonBorderColor
            self:addChild(self.ShopsMoneyBtn)
        end
    end

    function ISAdminPanelUI:onOptionMouseDownShopsMoney()
        if ShopsMoneyUI.instance then
            ShopsMoneyUI.instance:close()
        else
            local ui = ShopsMoneyUI:new(50, 50, 420, 220, getPlayer())
            ui:initialise()
            ui:addToUIManager()
            ShopsMoneyUI.instance = ui
        end
    end
end


