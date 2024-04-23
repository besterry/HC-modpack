BlackMarketAuto = ISPanelJoypad:derive("BlackMarketAuto")
AutoMeh = AutoMeh or {}
local td = getTexture("media/textures/TD.png")
local x1car,x2car,y1car,y2car
function BlackMarketAuto:initialise() --Создание элементов окна
    ISPanelJoypad.initialise(self)
    x1car,x2car,y1car,y2car = AutoMeh.CheckZone("blackmarketauto") --Получение координат зоны
    self.player = getPlayer()
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local fontHgt = FONT_HGT_SMALL
    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Select area") + 12
    local buttonWid3 = getTextManager():MeasureStringX(UIFont.Small, "Close") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid3), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10
    local x = 10

    --"Гос.номер:"
    self.GovSingCar = ISLabel:new(x, 60 , FONT_HGT_SMALL,getText("IGUI_AM_GovSign"), 1, 1, 1, 1, UIFont.Medium, true)
    self.GovSingCar:initialise()
    self.GovSingCar:instantiate()
    self:addChild(self.GovSingCar)

    --Строка ввода номера
    self.ItemEntry = ISTextEntryBox:new("", self.GovSingCar:getX()+80, self.GovSingCar:getY()-2, 60, 20)
    self.ItemEntry:initialise();
    self.ItemEntry:instantiate();
    self.ItemEntry:setOnlyNumbers(true)
    self:addChild(self.ItemEntry);   

    --Название автомобяли + номер
    self.CarNameAndNumber = ISLabel:new(x, self.ItemEntry:getY()+35, FONT_HGT_SMALL,"", 1, 1, 1, 1, UIFont.Medium, true)
    self.CarNameAndNumber:initialise()
    self.CarNameAndNumber:instantiate()
    self:addChild(self.CarNameAndNumber)

    --Кнопка убрать взлом
    self.delhotwire = ISButton:new(5, self:getHeight()-buttonHgt*2-20, buttonWid, buttonHgt, getText("IGUI_AM_DELHOTWIRE"), self, BlackMarketAuto.onClick);
    self.delhotwire.internal = "DELHOTWIRE";
    self.delhotwire:initialise();
    self.delhotwire:instantiate();
    self.delhotwire:setTooltip(getText("IGUI_AM_DeleteHotwire_BlackMarket")..(SandboxVars.NPC.PriceDeleteHotwireBlackMarket)) 
    self.delhotwire.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.delhotwire);

    --Кнопка удаление регистрации
    self.delreg = ISButton:new(self.delhotwire:getWidth()+10 , self.delhotwire:getY(), buttonWid, buttonHgt, getText("IGUI_AM_DELREG"), self, BlackMarketAuto.onClick);
    self.delreg.internal = "DELREG";
    self.delreg:initialise();
    self.delreg:instantiate();
    self.delreg:setTooltip(getText("IGUI_AM_Delete_RegisterCar_BlackMarket")..SandboxVars.NPC.PriceDeleteRegisterBlackMarket)
    self.delreg.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.delreg);

    --кнопка "Создать ключ"
    self.CreateKeyBtn = ISButton:new(self.delreg:getX()+ self.delreg:getWidth() +5, self.delhotwire:getY(), buttonWid, buttonHgt, getText("IGUI_AM_CreateKey"), self, BlackMarketAuto.onClick);
    self.CreateKeyBtn.internal = "CREATEKEY";
    self.CreateKeyBtn:initialise();
    self.CreateKeyBtn:instantiate();
    self.CreateKeyBtn:setTooltip(getText("IGUI_AM_CreateKeyText")..(SandboxVars.NPC.AutomehCreateKeyPrice*SandboxVars.NPC.PriceMultiplierBlackMarketCreateKey))
    self.CreateKeyBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.CreateKeyBtn);

    --Кнопка закрытия окна 
    self.close = ISButton:new(self:getWidth()/2-buttonWid/2, self:getHeight() - x - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, BlackMarketAuto.onClick)
    self.close.internal = "CLOSE"
    self.close:initialise()
    self.close:instantiate()
    self.close.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.close)

    self.textCheck = nil
    self.textEntry = 0
    self.vehicle = nil
end

function BlackMarketAuto:CheckCar()
    if self.ItemEntry:getText() ~= "" and self.textCheck ~= self.ItemEntry:getText() then --Проверка введен ли гос.номер авто и ищем авто
        self.textCheck = self.ItemEntry:getText()
        self:CheckCarAh() --Вызов функции поиска автомобиля
    end
end


function BlackMarketAuto:CheckCarAh() --Получение ТС и вызов функции заполнения комбобокса    
    self.textEntry = tonumber(self.ItemEntry:getText()) --Введеный номер
    self.vehicle = AutoMeh.CheckCarZone(x1car,x2car,y1car,y2car,self.textEntry) --Получение экземпляра авто по указанному номеру
end

function BlackMarketAuto:render()
    self:drawTextureScaledAspect(td, self.ItemEntry:getX()+80, self.ItemEntry:getY()-50, 200, 90, 1, 1, 1, 1)
end

function BlackMarketAuto:update()    
    self:CheckCar()
    if AutoMeh.CheckDistance(self.geoX,self.geoY) then --Проверка дистанции до нпс
        self:setVisible(false)
		self:removeFromUIManager()
        self.player:Say(getText("IGUI_AM_BlackMarketAuto_Far"))
        BlackMarketAuto.instance = nil
    end
    if self.vehicle and self.vehicle:getModData().sqlId then
        local NameCarAndNumber = getText("IGUI_VehicleName" .. getText(self.vehicle:getScript():getName())) .. " (H " .. self.vehicle:getModData().sqlId .. " KT)"
        self.CarNameAndNumber:setName(tostring(NameCarAndNumber))
        if self.vehicle:getModData().register then self.delreg:setEnable(true); end
        if self.vehicle:isHotwired() then self.delhotwire:setEnable(true); self.CreateKeyBtn:setEnable(false); 
        else self.CreateKeyBtn:setEnable(true); self.delhotwire:setEnable(false); end
    else
        self.CarNameAndNumber:setName(getText("IGUI_AM_Selected_Car"))
        self.delreg:setEnable(false)
        self.delhotwire:setEnable(false)
        self.CreateKeyBtn:setEnable(false)
    end
end


function BlackMarketAuto:onClick(button)
    local CurrentBalance = AutoMeh.BalancePlayer() or 0
    if button.internal == "DELHOTWIRE" then
        if CurrentBalance >= SandboxVars.NPC.PriceDeleteHotwireBlackMarket then
            local hotwired = false
            local broken = false
            sendClientCommand(self.player, "vehicle", "cheatHotwire", { vehicle = self.vehicle:getId(), hotwired = hotwired, broken = broken})
            sendClientCommand("BS", "Withdraw", {SandboxVars.NPC.PriceDeleteHotwireBlackMarket,0})
            local args = {}
            args.action = "delete car hotwired"
            args.price = SandboxVars.NPC.PriceDeleteHotwireBlackMarket
            args.vehiclesqlid = self.vehicle:getModData().sqlId
            sendClientCommand(self.player, "AutoMeh", "logserver", args) --логирование на сервере
            self.delhotwire:setEnable(false)
        else
            self.player:Say(getText("IGUI_AM_No_Money"))
        end
    end
    if button.internal == "DELREG" then
        if CurrentBalance >= SandboxVars.NPC.PriceDeleteRegisterBlackMarket then
            local args = {}
            args.vehicleId = self.vehicle:getId()
            self.vehicle:getModData().register = nil
            self.vehicle:getModData().Confidant = nil
            sendClientCommand("BS", "Withdraw", {SandboxVars.NPC.PriceDeleteRegisterBlackMarket,0})
            sendClientCommand(self.player, 'RegisterCar', 'DelRegister', args) --Есть логирование на стороне сервера
            self.delreg:setEnable(false)
        else
            self.player:Say(getText("IGUI_AM_No_Money"))
        end
    end
    if button.internal == "CREATEKEY" then
        if self.vehicle then
            if CurrentBalance >= SandboxVars.NPC.AutomehCreateKeyPrice*SandboxVars.NPC.PriceMultiplierBlackMarketCreateKey then
                local itemKey = self.vehicle:createVehicleKey()
                local NameKey = itemKey:getDisplayName() .. " [H " .. self.vehicle:getModData().sqlId .. " KT]"
                itemKey:setName(NameKey)
                self.player:getInventory():AddItem(itemKey)
                sendClientCommand("BS", "Withdraw", {SandboxVars.NPC.AutomehCreateKeyPrice*SandboxVars.NPC.PriceMultiplierBlackMarketCreateKey,0})
                local args = {}
                args.action = "create car key"
                args.price = SandboxVars.NPC.PriceDeleteHotwireBlackMarket
                args.vehiclesqlid = self.vehicle:getModData().sqlId
                sendClientCommand(self.player, "AutoMeh", "logserver", args)
            else
                self.player:Say(getText("IGUI_AM_No_Money"))
            end
        end
    end
    if button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
        PenaltyParkingUI.instance = nil
    end
end


function BlackMarketAuto:new(x, y, width, height, player, geoX, geoY) --Создание окна
    local o = ISPanelJoypad:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    if y == 0 then
        o.y = o:getMouseY() - (height / 2)
        o:setY(o.y)
    end
    if x == 0 then
        o.x = o:getMouseX() - (width / 2)
        o:setX(o.x)
    end
    o.geoX = geoX
    o.geoY = geoY
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
    BlackMarketAuto.instance = o
    return o;
end

--#region Функции отрисовки рамки и перемещения

function BlackMarketAuto:prerender()
    self.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    local th = 16
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_AM_BlackMarketAuto"), self:getWidth() / 3, 20, 1, 1, 1, 1, UIFont.NewLarge);
end
function BlackMarketAuto:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function BlackMarketAuto:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function BlackMarketAuto:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end
function BlackMarketAuto:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end
function BlackMarketAuto:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end
function BlackMarketAuto:onMouseDownOutside(x, y)
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