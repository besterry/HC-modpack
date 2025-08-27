require "AntiTheft/AntiTheftClient"
-- Author FD
RegisterCar = ISPanelJoypad:derive("RegisterCar");
AutoMeh = AutoMeh or {}
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local iconKey = getTexture("media/textures/KeyCar.png")
local iconNoKey = getTexture("media/textures/NoKeyCar.png")
local icongovsign = getTexture("media/textures/govsign.png")
local iconnogovsign = getTexture("media/textures/nogovsign.png")
local iconDriversLicense = getTexture("media/textures/DriversLicense.png")
local iconnoDriversLicense = getTexture("media/textures/noDriversLicense.png")
local iconReg = getTexture("media/textures/regok.png")
local iconNoReg = getTexture("media/textures/regno.png")
local x1car,x2car,y1car,y2car

function RegisterCar:initialise() --Создание элементов окна
    ISPanelJoypad.initialise(self);
    x1car,x2car,y1car,y2car = AutoMeh.CheckZone("register")

    local fontHgt = FONT_HGT_SMALL
    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Select area") + 12
    local buttonWid3 = getTextManager():MeasureStringX(UIFont.Small, "Close") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid3), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10

    self.RegCarInfo = ISLabel:new(10, 53, FONT_HGT_SMALL, getText("IGUI_RegCarInfo"), 1, 1, 1, 1, UIFont.Small, true)
    self.RegCarInfo:initialise()
    self.RegCarInfo:instantiate()
    self:addChild(self.RegCarInfo)

    self.textCarID = ISLabel:new(10, 83, FONT_HGT_SMALL, getText("IGUI_Car_ID"), 1, 1, 1, 1, UIFont.Small, true)
    self.textCarID:initialise()
    self.textCarID:instantiate()
    self:addChild(self.textCarID)

    self.ItemEntry = ISTextEntryBox:new("", 140, 80, 50, 20)
    self.ItemEntry:initialise();
    self.ItemEntry:instantiate();
    self.ItemEntry:setOnlyNumbers(true)
    self:addChild(self.ItemEntry);

    self.CheckRegister = ISLabel:new(self.ItemEntry:getX()+60, self.ItemEntry:getY()+2, FONT_HGT_SMALL, getText("IGUI_CheckRegister"), 1, 1, 1, 1, UIFont.Small, true)
    self.CheckRegister:initialise()
    self.CheckRegister:instantiate()
    self:addChild(self.CheckRegister)

    self.select = ISButton:new((self:getWidth() / 6) - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("IGUI_RegisterCar"), self, RegisterCar.onClick);
    self.select.internal = "SELECT";
    self.select:initialise();
    self.select:instantiate();
    self.select.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.select);

    self.ConfidantBtn = ISButton:new((self:getWidth() / 6) - buttonWid/2, self:getHeight() - padBottom - buttonHgt - self.select:getHeight() - 5, buttonWid, buttonHgt, getText("IGUI_ConfidantBtn"), self, RegisterCar.onClick);
    self.ConfidantBtn.internal = "Confidant";
    self.ConfidantBtn:initialise();
    self.ConfidantBtn:instantiate();
    self.ConfidantBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ConfidantBtn);

    self.deselect = ISButton:new((self:getWidth() / 2) - buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("IGUI_UnRegisterCar"), self, RegisterCar.onClick);
    self.deselect.internal = "DESELECT";
    self.deselect:initialise();
    self.deselect:instantiate();
    self.deselect.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.deselect);

    self.close = ISButton:new((self:getWidth() / 2) + buttonWid/1.5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, RegisterCar.onClick);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);

    -- Кнопка противоугонки
    self.antiTheftBtn = ISButton:new(self.close:getX(), self.close:getY() - buttonHgt - 5, buttonWid, buttonHgt, getText("IGUI_AntiTheft"), self, self.onAntiTheft)
    self.antiTheftBtn:initialise()
    self.antiTheftBtn:instantiate()
    self:addChild(self.antiTheftBtn)
    
end

local vehicleForSend --Переменная, которая получает экземляр BaseVehicle и используется в дальнейшем

function RegisterCar:onAntiTheft()
    if AM_AntiTheft and AM_AntiTheft.instance then
        AM_AntiTheft.instance:removeFromUIManager()
        AM_AntiTheft.instance = nil
    else
        if vehicleForSend then
            local x = self:getX() + self:getWidth() + 5
            local y = self:getY()
            local ui = AM_AntiTheft:new(x, y, 200, 200, getPlayer(), vehicleForSend)
            ui:initialise();
            ui:addToUIManager();
            AM_AntiTheft.instance = ui;
        end
    end
end


local function sendcm (vehicleForSend) --Запрос на сервер регистрации ТС
    local args = {}
    local username = getPlayer():getUsername()
    args.vehicleId = vehicleForSend:getId()
    vehicleForSend:getModData().register = username
    sendClientCommand(getPlayer(), "RegisterCar", "SetRegister", args)
end

local keyCheck, numberCheck, dockCheck = false, false, false
function RegisterCar:render() --Обработка наличия предметов и активации кнопки     
    local player = getPlayer()
    if AutoMeh.CheckDistance(self.geoX,self.geoY) then --Проверка дистанции до автомеханика
        self:setVisible(false)
		self:removeFromUIManager()
        vehicleForSend = nil
        player:Say(getText("IGUI_MehFar"))
        RegisterCar.instance = nil
    end

    local inventory = player:getInventory()
    local lootCount = inventory:getItems():size()    
    for i = lootCount, 1, -1 do -- Проверка наличия необходимого предмета в инвентаре игрока для регистрации ТС
        local item = inventory:getItems():get(i - 1)
        if item and item:getFullType() == SandboxVars.NPC.AutomehRegisterDock then
            dockCheck = true
            break
        else
            dockCheck = false
        end
    end

    local keys = {}    
    for i = lootCount, 1, -1 do -- Получение ключа из инвентаря для дальнейшего сравнения
        local item = inventory:getItems():get(i - 1)
        if item and item:getType() == "CarKey" then
            local key = item:getKeyId()
            keys[key]=true
            break
        end
    end

    local CarNumtext = tonumber(self.ItemEntry:getText())--Переменная для хранения введеного текста и преобразование в номер
    local vehicle = AutoMeh.CheckCarZone(x1car,x2car,y1car,y2car,CarNumtext) --Поиск vehicle в зоне регистрации и сравнение её номера
    if vehicle then
        local keyCar = vehicle:getKeyId()
        keyCheck = keys[keyCar] ~= nil --Если есть машина - сравниваем ключи и возвращаем true, если ключ найден
        numberCheck = vehicle:getModData().sqlId == CarNumtext --Сравниваем введенного номера, true если номер совпал
        vehicleForSend = vehicle --Передаем в ТС для дальнейшей работы
    else
        keyCheck = false
        numberCheck = false
        vehicleForSend = nil
    end
    --Проверка сесть ли регистрация
    if vehicleForSend and vehicleForSend:getModData().register then
        self:drawTextureScaledAspect(iconReg, self.CheckRegister:getX() + 80, self.ItemEntry:getY()-2, 25, 25, 1, 1, 1, 1) --Отрисовка иконки галочки
        if vehicleForSend:getModData().register == player:getUsername() then self.deselect:setEnable(true) self.antiTheftBtn:setEnable(true) end --Снятие регистрации только для владельца
    else
        self:drawTextureScaledAspect(iconNoReg, self.CheckRegister:getX()+80, self.ItemEntry:getY()-2, 25, 25, 1, 1, 1, 1) --Отрисовка иконки крестика
        self.deselect:setEnable(false) --Отключение кнопки "Снять с регистрации"
        self.antiTheftBtn:setEnable(false) --Отключение кнопки "Противоугонка"
    end
    local x = self.ItemEntry:getX()-40
    -- Отображение иконок в зависимости от результатов проверок
    if keyCheck then --Есть ли у игрока ключи от этого авто
        self:drawTextureScaledAspect(iconKey, x, self.ItemEntry:getY() + 32, 25, 25, 1, 1, 1, 1)
    else
        self:drawTextureScaledAspect(iconNoKey, x, self.ItemEntry:getY() + 32, 25, 25, 1, 1, 1, 1)
    end

    if numberCheck then --Иконка проверки введеного номера и его совпадение
        self:drawTextureScaledAspect(icongovsign, x+40, self.ItemEntry:getY() + 25, 40, 40, 1, 1, 1, 1)
    else
        self:drawTextureScaledAspect(iconnogovsign, x+40, self.ItemEntry:getY() + 25, 40, 40, 1, 1, 1, 1)
    end

    if dockCheck then --Иконка проверки наличия документов
        self:drawTextureScaledAspect(iconDriversLicense, x+90, self.ItemEntry:getY() + 25, 35, 35, 1, 1, 1, 1)        
    else
        self:drawTextureScaledAspect(iconnoDriversLicense, x+90, self.ItemEntry:getY() + 25, 35, 35, 1, 1, 1, 1)
    end

    if keyCheck and numberCheck and dockCheck and vehicleForSend and not vehicleForSend:getModData().register then
        self.select:setEnable(true) --Кнопка Регистрация
    else
        self.select:setEnable(false) --Кнопка Регистрация
    end
    if vehicleForSend and vehicleForSend:getModData().register then --Есть ли регистрация
        self.ConfidantBtn:setEnable(true) --кнопка Доверенности
    else
        self.ConfidantBtn:setEnable(false) --кнопка Доверенности
    end
end

local function DeleteItem() --Удаление предмета из инвентаря игрока за регистрацию
    local player = getPlayer()
    local inventory = player:getInventory()
    local lootCount = inventory:getItems():size()
    for i = lootCount, 1, -1 do
        local item = inventory:getItems():get(i - 1)        
        if item and item:getFullType() == SandboxVars.NPC.AutomehRegisterDock then
            inventory:Remove(item)
            break
        end
    end
end

function RegisterCar:onClick(button)
    if button.internal == "SELECT" then --Регистрация
        DeleteItem()
        sendcm(vehicleForSend)
    end
    if button.internal == "DESELECT" then --Снять с учета
        local args = {}
        args.vehicleId = vehicleForSend:getId()
        vehicleForSend:getModData().register = nil
        vehicleForSend:getModData().Confidant = nil
        sendClientCommand(getPlayer(), 'RegisterCar', 'DelRegister', args)
    end   
    if button.internal == "Confidant" then --Доверенности
        local ui = ConfidantCarUI:new(0, 0, 150, 277, getPlayer(),vehicleForSend); 
        ui:initialise();
        ui:addToUIManager();
    end
    if button.internal == "CLOSE" then
        self:setVisible(false)
		self:removeFromUIManager()
        vehicleForSend = nil
        RegisterCar.instance = nil
        return;
    end
end

local function receiveServerCommand(module, command, args)
    if module ~= "RegisterCar" then return; end
    if command == "onSetRegister" then
        if args.result then
            local vehicle = getVehicleById(args.vehicleId)
            if vehicle then 
                vehicle:getModData().register = args.username
            end
        end
    elseif command == "onDelRegister" then
        if args.result then
            local vehicle = getVehicleById(args.vehicleId)
            if vehicle then
                vehicle:getModData().register = nil
            end
        end
    end
end
Events.OnServerCommand.Add(receiveServerCommand)

function RegisterCar:new(x, y, width, height, player, geoX, geoY) --Создание окна
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.geoX = geoX
    o.geoY = geoY
    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end
    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end
    o.name = nil;
    o.backgroundColor = {r=0, g=0, b=0, a=0.5};
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.width = width;
    o.height = height;
    o.anchorLeft = true;
    o.anchorRight = true;
    o.anchorTop = true;
    o.anchorBottom = true;
    o.player = player;
    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png");
    o.numLines = 1
    o.maxLines = 1
    o.multipleLine = false
    o.selectStart = false
    o.selectEnd = false
    o.startPos = nil
    o.endPos = nil
    o.zPos = 0
    RegisterCar.instance = o
    return o;
end


--#region Функции отрисовки рамки и перемещения

function RegisterCar:prerender()
    self.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    local th = 16
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_Register_Title"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);
end
function RegisterCar:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function RegisterCar:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function RegisterCar:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end
function RegisterCar:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end
function RegisterCar:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end
function RegisterCar:onMouseDownOutside(x, y)
    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
    if self.selectStart then
        self.startPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectStart = false
        self.selectEnd = true
    elseif self.selectEnd then
        self.endPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectEnd = false
    end
end
--#endregion Функции отрисовки рамки и перемещения