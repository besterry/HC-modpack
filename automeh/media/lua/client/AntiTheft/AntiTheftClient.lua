require "AM_Tools"
AutoMeh = AutoMeh or {}
AM_AntiTheft = ISPanelJoypad:derive("AM_AntiTheft")

function AM_AntiTheft:initialise()
    ISPanelJoypad.initialise(self)
    
    local fontHgt = getTextManager():getFontHeight(UIFont.Small)
    local buttonWid = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_AntiTheftSystem")) + 20
    local buttonHgt = math.max(fontHgt + 6, 25)
    self.status =  getText("IGUI_AntiTheftStatusLoading")
    self.colorStatus = {r=1, g=1, b=1, a=1}

    -- Заголовок
    self.title = ISLabel:new(10, 10, fontHgt, getText("IGUI_AntiTheftSystem"), 1, 1, 1, 1, UIFont.Medium, true)
    self.title:initialise()
    self.title:instantiate()
    self:addChild(self.title)
    
    -- Описание
    self.description = ISLabel:new(10, self.title:getY() + buttonHgt + 5, fontHgt, getText("IGUI_AntiTheftDescription"), 1, 1, 1, 1, UIFont.Small, true)
    self.description:initialise()
    self.description:instantiate()
    self:addChild(self.description)

    -- Кнопка закрытия по центру экрана
    self.closeBtn = ISButton:new((self:getWidth() / 2) - buttonWid/2, self:getHeight() - buttonHgt - 5, buttonWid, buttonHgt, getText("IGUI_Close"), self, self.close)
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self:addChild(self.closeBtn)

    -- Кнопка снятия над кнопкой закрытия
    self.removeBtn = ISButton:new((self:getWidth() / 2) - buttonWid/2, self.closeBtn:getY() - buttonHgt - 5, buttonWid, buttonHgt, getText("IGUI_AntiTheftRemove"), self, self.onRemove)
    self.removeBtn:initialise()
    self.removeBtn:instantiate()
    self:addChild(self.removeBtn)

    -- Кнопка установки над кнопкой закрытия
    self.installBtn = ISButton:new((self:getWidth() / 2) - buttonWid/2, self.removeBtn:getY() - buttonHgt - 5, buttonWid, buttonHgt, getText("IGUI_AntiTheftInstall"), self, self.onInstall)
    self.installBtn:initialise()
    self.installBtn:instantiate()
    self:addChild(self.installBtn)

    -- Информация о статусе
    self.statusLabel = ISLabel:new(10, self.installBtn:getY() - buttonHgt, fontHgt, "", self.colorStatus.r, self.colorStatus.g, self.colorStatus.b, self.colorStatus.a, UIFont.Small, true)
    self.statusLabel:initialise()
    self.statusLabel:instantiate()
    self:addChild(self.statusLabel) 
    
    
    -- Проверяем статус сразу
    self:checkAntiTheftStatus()
end

function AM_AntiTheft:checkAntiTheftStatus()
    local vehicle = self.vehicle
    if not vehicle then
        self.status = getText("IGUI_AntiTheftStatusCarNotFound")
        self.colorStatus = {r=1, g=0, b=0, a=1} -- Красный
        return
    end
    local antiTheft = vehicle:getModData().antiTheft

    if antiTheft and antiTheft.installed then
        self.status = getText("IGUI_AntiTheftStatusInstalled")
        self.installBtn:setEnable(false)
        self.removeBtn:setEnable(true)
        self.colorStatus = {r=0, g=1, b=0, a=1} -- Зеленый
    else
        self.status = getText("IGUI_AntiTheftStatusNotInstalled")
        self.installBtn:setEnable(true)
        self.removeBtn:setEnable(false)
        self.colorStatus = {r=1, g=0, b=0, a=1} -- Красный
    end
end

function AM_AntiTheft:onInstall()
    local vehicle = self.vehicle
    if not vehicle then return end
    local CurrentBalance = AutoMeh.BalancePlayer() or 0
    if CurrentBalance >= SandboxVars.NPC.AntiTheftPrice then
        local vehicleId = vehicle:getId()
        sendClientCommand("BS", "Withdraw", {SandboxVars.NPC.AntiTheftPrice,0})
        sendClientCommand("AntiTheft", "InstallAntiTheft", {vehicleId = vehicleId})
    else
        self.player:Say(getText("IGUI_AM_No_Money"))
    end
end

function AM_AntiTheft:onRemove()
    local vehicle = self.vehicle
    if not vehicle then return end
    local vehicleId = vehicle:getId()
    sendClientCommand("AntiTheft", "RemoveAntiTheft", { vehicleId = vehicleId})
end

function AM_AntiTheft:close()
    self:removeFromUIManager()
    if AM_AntiTheft.instance == self then
        AM_AntiTheft.instance = nil
    end
end

-- Обработчики ответов сервера
local function onInstallAntiTheft(args)
    if args.result and AM_AntiTheft.instance then
        AM_AntiTheft.instance.status = getText("IGUI_AntiTheftStatusInstalled")
        AM_AntiTheft.instance.colorStatus = {r=0, g=1, b=0, a=1} -- Зеленый
        AM_AntiTheft.instance.installBtn:setEnable(false)
        AM_AntiTheft.instance.removeBtn:setEnable(true)
        local vehicle = getVehicleById(args.vehicleId)
        if vehicle then 
            vehicle:getModData().antiTheft = {
                installed = true,
                installer = args.installer,
                installDate = args.installDate,
                level = 1
            }
        end
    end
end

local function onRemoveAntiTheft(args)
    if args.result and AM_AntiTheft.instance then
        AM_AntiTheft.instance.status = getText("IGUI_AntiTheftStatusRemoved")
        AM_AntiTheft.instance.colorStatus = {r=1, g=0, b=0, a=1} -- Красный
        AM_AntiTheft.instance.installBtn:setEnable(true)
        AM_AntiTheft.instance.removeBtn:setEnable(false)
    end
    local vehicle = getVehicleById(args.vehicleId)
    if vehicle then 
        vehicle:getModData().antiTheft = nil
    end
end

local function onTheftAttempt(args)
    getPlayer():Say(getText("IGUI_AntiTheftTheftAttempt"))
end

Events.OnServerCommand.Add(function(module, command, args)
    if module == "AntiTheft" then
        if command == "onInstallAntiTheft" then
            onInstallAntiTheft(args)
        elseif command == "onRemoveAntiTheft" then
            onRemoveAntiTheft(args)
        elseif command == "onTheftAttempt" then
            onTheftAttempt(args)
        end
    end
end)

function AM_AntiTheft:render()    
    ISPanelJoypad.render(self)
    self.statusLabel:setName(self.status)
    self.statusLabel:setColor(self.colorStatus.r, self.colorStatus.g, self.colorStatus.b, self.colorStatus.a)
end

function AM_AntiTheft:prerender()
    self:drawRect(0, 0, self.width, self.height, 0.8, 0.1, 0.1, 0.1)
    self:drawRectBorder(0, 0, self.width, self.height, 1, 0.5, 0.5, 0.5)    
    ISPanelJoypad.prerender(self)
    -- self.removeBtn.tooltip = getText("IGUI_AntiTheftRemove")
    self.installBtn.tooltip = getText("IGUI_Price_AntiTheft") .. SandboxVars.NPC.AntiTheftPrice
end

function AM_AntiTheft:new(x, y, width, height, player ,vehicle)
    local o = ISPanelJoypad.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.player = player
    o.vehicle = vehicle
    o:initialise()
    return o
end

function AM_AntiTheft:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function AM_AntiTheft:onMouseUp(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
end

function AM_AntiTheft:onMouseMove(dx, dy)
    if self.moving then
        self:setX(self:getX() + dx)
        self:setY(self:getY() + dy)
        self:bringToTop()
    end
end

function AM_AntiTheft:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
end

function AM_AntiTheft:onMouseDownOutside(x, y)
    -- Оставляем пустым как в AM_Confidant
end