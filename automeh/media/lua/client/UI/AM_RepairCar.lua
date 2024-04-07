local iconReg = getTexture("media/textures/regok.png")
local iconNoReg = getTexture("media/textures/regno.png")
AM_RepairCar = ISPanelJoypad:derive("AM_RepairCar");
AutoMeh = AutoMeh or {}
local player
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local x1car,x2car,y1car,y2car

function AM_RepairCar:initialise() --Создание элементов окна
    ISPanelJoypad.initialise(self);
    player = getPlayer()
    x1car,x2car,y1car,y2car = AutoMeh.CheckZone("repair")
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
    self.CarNameAndNumber = ISLabel:new(x,  self.ItemEntry:getY()+35, FONT_HGT_SMALL,"", 1, 1, 1, 1, UIFont.Medium, true)
    self.CarNameAndNumber:initialise()
    self.CarNameAndNumber:instantiate()
    self:addChild(self.CarNameAndNumber)

    --Текст "Автомобиль"
    self.CarFind = ISLabel:new(self.ItemEntry:getX()+75,  self.GovSingCar:getY(), FONT_HGT_SMALL,getText("IGUI_AM_Car"), 1, 1, 1, 1, UIFont.Medium, true)
    self.CarFind:initialise()
    self.CarFind:instantiate()
    self:addChild(self.CarFind)

    --Текст "Регистрация"
    self.RegiststerCar = ISLabel:new(self.CarFind:getX()+125,  self.GovSingCar:getY() , FONT_HGT_SMALL,getText("IGUI_AM_Register"), 1, 1, 1, 1, UIFont.Medium, true)
    self.RegiststerCar:initialise()
    self.RegiststerCar:instantiate()
    self:addChild(self.RegiststerCar)

    --Выпадающий список деталей
    self.comboBox = ISComboBox:new(x, self.RegiststerCar:getY()+55, self:getWidth()-20, 20, self,self.onClickTab);
    self.comboBox:initialise();
    self.comboBox:instantiate();
    self:addChild(self.comboBox);

    --Детали запчасти
    self.InfoPart = ISLabel:new(x, self.comboBox:getY()+40, FONT_HGT_SMALL,getText("IGUI_AM_PartDetail"), 1, 1, 1, 1, UIFont.Medium, true)
    self.InfoPart:initialise()
    self.InfoPart:instantiate()
    self:addChild(self.InfoPart)

    --Надпись "Починка до"
    self.PartConditionLabel = ISLabel:new(x, self.InfoPart:getY()+40, FONT_HGT_SMALL,getText("IGUI_AM_Repair"), 1, 1, 1, 1, UIFont.Medium, true)
    self.PartConditionLabel:initialise()
    self.PartConditionLabel:instantiate()
    self:addChild(self.PartConditionLabel)

    --Ввод желаемого % ремонта
    self.partRepair = ISTextEntryBox:new("", self.PartConditionLabel:getX()+self.PartConditionLabel:getWidth()+7, self.PartConditionLabel:getY()-3, 50, 20)
    self.partRepair:initialise();
    self.partRepair:instantiate();
    self.partRepair:setOnlyNumbers(true)
    self:addChild(self.partRepair);

    --Цена ремонта
    self.TotalPriceLabel = ISLabel:new(self.partRepair:getX()+51, self.PartConditionLabel:getY()+1, FONT_HGT_SMALL,getText("IGUI_AM_Price"), 1, 1, 1, 1, UIFont.Medium, true)
    self.TotalPriceLabel:initialise()
    self.TotalPriceLabel:instantiate()
    self:addChild(self.TotalPriceLabel)

    --кнопка "Починить"
    self.repairBtn = ISButton:new(self:getWidth()/2-buttonWid/2, self:getHeight()-buttonHgt-10, buttonWid, buttonHgt, getText("IGUI_AM_RepairBtn"), self, AM_RepairCar.onClick);
    self.repairBtn.internal = "REPAIR";
    self.repairBtn:initialise();
    self.repairBtn:instantiate();
    self.repairBtn:setEnable(false)
    self.repairBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.repairBtn);

    --Текст: деталь повреждена (максимальное кол-во ремонтов)
    self.RepairedMaxLabel = ISLabel:new(self.PartConditionLabel:getX(), self.PartConditionLabel:getY()-buttonHgt/2-7, FONT_HGT_SMALL,getText("IGUI_AM_MaxRepairCount"), 1, 0, 0, 1, UIFont.Medium, true)
    self.RepairedMaxLabel:initialise()
    self.RepairedMaxLabel:instantiate()
    self.RepairedMaxLabel:setVisible(false)
    self:addChild(self.RepairedMaxLabel)

    --Кнопка замены детали
    self.renewBtn = ISButton:new(self:getWidth()-buttonWid-10, self.InfoPart:getY()-7, buttonWid, buttonHgt, getText("IGUI_AM_Renew"), self, AM_RepairCar.onClick);
    self.renewBtn.internal = "RENEW";
    self.renewBtn:initialise();
    self.renewBtn:instantiate();
    self.renewBtn:setEnabled(false)
    self.renewBtn:setVisible(false)
    self.renewBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.renewBtn);

    --кнопка "Создать ключ"
    self.CreateKeyBtn = ISButton:new(x, self:getHeight()-buttonHgt-10, buttonWid, buttonHgt, getText("IGUI_AM_CreateKey"), self, AM_RepairCar.onClick);
    self.CreateKeyBtn.internal = "CREATEKEY";
    self.CreateKeyBtn:initialise();
    self.CreateKeyBtn:instantiate();
    self.CreateKeyBtn:setVisible(false)
    self.CreateKeyBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.CreateKeyBtn);

    self.close = ISButton:new(self:getWidth()-buttonWid-10, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, AM_RepairCar.onClick);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);
end
local ConditionToRepair
local SelectedPart
local textEntry = 0
local textCheck
local vehicle
local money
function AM_RepairCar:CheckCar()
    if self.ItemEntry:getText() ~= "" and textCheck ~= self.ItemEntry:getText() then --Проверка введен ли гос.номер авто и ищем авто
        self:CheckCarAh()
    end
end

function AM_RepairCar:CheckCarAh() --Получение ТС и вызов функции заполнения комбобокса
    textCheck = self.ItemEntry:getText()
    textEntry = tonumber(self.ItemEntry:getText())
    vehicle = AutoMeh.CheckCarZone(x1car,x2car,y1car,y2car,textEntry)
    self:UpdatePartComboBox() --Заполнение комбобокса
end

function AM_RepairCar:UpdatePartComboBox() --Заполнение комбобокса
    self.comboBox:clear()  
    if vehicle then
        if vehicle:getModData().register and vehicle:getModData().register==player:getUsername() then self.CreateKeyBtn:setVisible(true) else self.CreateKeyBtn:setVisible(false) end --Кнопка создания ключа видна только владельцу
        if vehicle:getPartById("Engine") and vehicle:getPartById("Engine"):getCategory() ~= "nodisplay" then 
            local engine = vehicle:getPartById("Engine")
            local textEngine = tostring(getText("IGUI_AM_Engine") .. " " .. engine:getCondition() .. "%")
            self.comboBox:addOptionWithData(textEngine, {part=engine,nil}) --Двигатель
        end
        if vehicle:getPartById("Heater") and vehicle:getPartById("Heater"):getCategory() ~= "nodisplay" then
            local Heater = vehicle:getPartById("Heater")
            local textHeater = tostring(getText("IGUI_AM_Heater") .. " "..Heater:getCondition() .. "%")
            self.comboBox:addOptionWithData(textHeater, {part=Heater,nil}) --Печка
        end
        self.lastCheckPartItemCount = 0
        for i = 0, vehicle:getPartCount() - 1 do                
            local part = vehicle:getPartByIndex(i) --Получаем деталь
            local partItem = part:getInventoryItem() --Получаем предмет детали                
            if partItem and part:getCategory() ~= "nodisplay" then
                self.lastCheckPartItemCount =  self.lastCheckPartItemCount + 1
                local partName = partItem:getName()
                local Name = partName .. " " .. partItem:getCondition() .. "% (x" .. partItem:getHaveBeenRepaired()-1 .. ")"
                if partName then
                    self.comboBox:addOptionWithData(Name, {part=part,item=part:getInventoryItem()}) --Заполняем comboBox
                end
            end
        end
    else
        self.CarNameAndNumber:setName("") --Если нет авто стираем название
    end
end

function AM_RepairCar:GetNameCar()
    if vehicle then
        local NameCarAndNumber = getText("IGUI_VehicleName" .. getText(vehicle:getScript():getName())) .. " (H " .. vehicle:getModData().sqlId .. " KT)"
        self.CarNameAndNumber:setName(tostring(NameCarAndNumber))
        self:drawTextureScaledAspect(iconReg, self.CarFind:getX() +94, self.CarFind:getY()-6, 25, 25, 1, 1, 1, 1) --Авто найден галочка
    else
        self:drawTextureScaledAspect(iconNoReg, self.CarFind:getX() +93, self.CarFind:getY()-6, 25, 25, 1, 1, 1, 1)--Авто не найден крестик
    end
    if vehicle and vehicle:getModData().register then --Рисуем иконку галочку или крестик
        self:drawTextureScaledAspect(iconReg, self.RegiststerCar:getX() +95, self.RegiststerCar:getY()-6, 25, 25, 1, 1, 1, 1) --Регистраци на авто есть - галочка
    else
        self:drawTextureScaledAspect(iconNoReg, self.RegiststerCar:getX() +97, self.RegiststerCar:getY()-6, 25, 25, 1, 1, 1, 1) --Нет регистрации - крестик
    end
end

local RepairCountCheck
function AM_RepairCar:render()
    if AutoMeh.CheckDistance(self.geoX,self.geoY) then
        self:setVisible(false)
		self:removeFromUIManager()
		AM_RepairCar.instance = nil
        getPlayer():Say(getText("IGUI_MehFar"))
    end
    self:CheckCar() --Поиск авто по введеному номеру
    self:GetNameCar() --Отрисовка названия авто и иконок авто и регистрации 
    if self.partRepair:getText() ~= "" and self.partRepair:getText() ~= RepairCountCheck and SelectedPart then
        RepairCountCheck = self.partRepair:getText()
        ConditionToRepair = tonumber(self.partRepair:getText()) --Число желаемого ремонта
        local currentCondition = SelectedPart:getCondition()
        if ConditionToRepair and ConditionToRepair > currentCondition and ConditionToRepair <= 100 then --Проверка что игрок ввел правильно число для ремонта
            if SelectedPart == vehicle:getPartById("Engine") or SelectedPart == vehicle:getPartById("Heater") then
                money = AutoMeh.Pricing(SelectedPart,ConditionToRepair,false)
                self.TotalPriceLabel:setName(getText("IGUI_AM_Price").." " ..money)
                self.repairBtn:setEnable(true)
                self.RepairedMaxLabel:setVisible(false)
            elseif (SelectedPart:getInventoryItem():getHaveBeenRepaired())<=SandboxVars.NPC.MaxRepairPart then
                money = AutoMeh.Pricing(SelectedPart,ConditionToRepair,false)
                self.TotalPriceLabel:setName(getText("IGUI_AM_Price").. " "..money)
                self.repairBtn:setEnable(true)
                self.RepairedMaxLabel:setVisible(false)
            else
                self.RepairedMaxLabel:setVisible(true)
            end
        elseif SelectedPart ~= vehicle:getPartById("Engine") and SelectedPart ~= vehicle:getPartById("Heater") and ((SelectedPart:getInventoryItem():getHaveBeenRepaired()+1)>=SandboxVars.NPC.MaxRepairPart) then
            self.repairBtn:setEnable(false)
            self.RepairedMaxLabel:setVisible(false)
        else
            self.repairBtn:setEnable(false)
            self.RepairedMaxLabel:setVisible(false)
        end
    end
end

function AM_RepairCar:onClickTab() --Выбор детали в списке
    local playerName = player:getUsername()
    local confidantList = vehicle:getModData().Confidant or {}
    local confidantCheck = false
    self.RepairedMaxLabel:setVisible(false)
    self.partRepair:setText("")
    self.TotalPriceLabel:setName(getText("IGUI_AM_Price"))
    ConditionToRepair = nil
    for _, value in pairs(confidantList) do --Проверка есть ли игрок в списке доверенных
        if value == playerName then
            confidantCheck = true
            break
        end
    end
    if (playerName == vehicle:getModData().register) or confidantCheck then
        local SelectedData = self.comboBox.options[self.comboBox.selected] --Получение таблицы выбранного селектора
        SelectedPart = SelectedData.data.part --Получем из таблицы поле data SelectedData[name,data]
        self:UpdateInfo()
    else
        self.InfoPart:setName(getText("IGUI_AM_OnlyRegisterUse"))
    end
end

local priceRenew
function AM_RepairCar:UpdateInfo() --Обновление информации выбранной детали 
    local Condition = SelectedPart:getCondition() or 0
    local infoPart
    if SelectedPart == vehicle:getPartById("Engine") or SelectedPart ==  vehicle:getPartById("Heater") then
        infoPart = getText("IGUI_AM_Condition") .. Condition --getText("IGUI_AM_Detail") .. selectedText .. " \n" .. 
    else
        local broken = SelectedPart:getInventoryItem():getHaveBeenRepaired()-1
        infoPart = getText("IGUI_AM_Condition") .. Condition .. "% " .. getText("IGUI_AM_RepairCount") .. "x" .. broken --getText("IGUI_AM_Detail") .. selectedText .. " \n" ..
    end
    if SelectedPart then --Если выбрана деталь: рассчитать стоимость замены
        self.InfoPart:setName(infoPart) --Вывод стостояния детали
        priceRenew = AutoMeh.Pricing(SelectedPart,100,true) --Рассчет стоимости замены
        if priceRenew then
            self.renewBtn:setVisible(true)
            self.renewBtn:setEnabled(true)
        end
        if SelectedPart:getId() == "Engine" or SelectedPart:getId() == "Heater" then --Если двигатель или печка - скрыть "Замена"
            self.renewBtn:setEnabled(false)
            self.renewBtn:setVisible(false)
        else
            self.renewBtn:setVisible(true)
            self.renewBtn:setEnabled(true)
        end
    end
end


function AM_RepairCar:update() --Более редкое обновление чем рендер
    self.CreateKeyBtn:setTooltip(getText("IGUI_AM_CreateKeyText")..SandboxVars.NPC.AutomehCreateKeyPrice)--Отрисовка цены смены ключа
    if priceRenew then self.renewBtn:setTooltip(getText("IGUI_AM_Price_renew").." "..priceRenew) else self.renewBtn:setTooltip(nil) end
    if self.comboBox.options[self.comboBox.selected] then --Если выбрана деталь в комбобокс
        local SelectedData = self.comboBox.options[self.comboBox.selected].data --считываем data из выбранного элемента
        if SelectedData.item and SelectedData.part:getInventoryItem() ~= SelectedData.item then
            self.InfoPart:setName(getText("IGUI_AM_PartDetail"))
            self.partRepair:setText("")
            self.TotalPriceLabel:setName(getText("IGUI_AM_Price"))
            self.RepairedMaxLabel:setVisible(false)
            SelectedPart=nil
        end
    end

    local count = 0
    if vehicle then
        for i = 0, vehicle:getPartCount() - 1 do                
            local part = vehicle:getPartByIndex(i) --Получаем деталь
            local partItem = part:getInventoryItem() --Получаем предмет детали   
            if partItem and part:getCategory()~="nodisplay" then
                count = count + 1
            end
        end
    end
    if self.lastCheckPartItemCount and self.lastCheckPartItemCount~=count then --При изменении кол-ва обновить чекбокс
        self:CheckCarAh()
        self.InfoPart:setName(getText("IGUI_AM_PartDetail"))
        self.partRepair:setText("")
        self.TotalPriceLabel:setName(getText("IGUI_AM_Price"))
        self.RepairedMaxLabel:setVisible(false)
        SelectedPart=nil
    end
end

function AM_RepairCar:onClick(button) --Обработка нажатия кнопок
    local CurrentBalance = AutoMeh.BalancePlayer() or 0
    if button.internal == "REPAIR" then --Нужно списывать деньги с баланса  
        if self.partRepair:getText() == "" then return end
        if CurrentBalance >= money and SelectedPart then
            SelectedPart:getInventoryItem()
            local args = {}
            local RepairCount
            SelectedPart:setCondition(ConditionToRepair)
            args.partId = SelectedPart:getIndex() --args.partId = SelectedPart:getId()
            args.vehicleId = vehicle:getId()
            args.condition = ConditionToRepair
            args.coast = money --Цена
            if SelectedPart ~= vehicle:getPartById("Engine") and SelectedPart ~= vehicle:getPartById("Heater") then
                RepairCount = (SelectedPart:getInventoryItem():getHaveBeenRepaired())+1
                SelectedPart:getInventoryItem():setHaveBeenRepaired(RepairCount)      
                args.repaired = RepairCount
            end        
            self:UpdateInfo() --Обновление информации о детали 
            self:UpdatePartComboBox() --Обновление информации в комбобокс
            sendClientCommand("BS", "Withdraw", {money,0}) --Вычесть деньги
            sendClientCommand(getPlayer(),"AutoMeh","SetPart",args) --Поченить деталь
            self.repairBtn:setEnable(false)
        else
            player:Say(getText("IGUI_AM_No_Money"))
        end
    end
    if button.internal == "RENEW" then --Нужно списывать деньги с баланса
        if CurrentBalance >= priceRenew and SelectedPart then
            local args = {}
            local RepairCount
            SelectedPart:setCondition(100)
            args.partId = SelectedPart:getIndex()
            args.vehicleId = vehicle:getId()
            args.condition = 100
            args.coast = priceRenew --Цена
            if SelectedPart ~= vehicle:getPartById("Engine") and SelectedPart ~= vehicle:getPartById("Heater") then
                RepairCount = 1
                SelectedPart:getInventoryItem():setHaveBeenRepaired(1)
                args.repaired = RepairCount
            end        
            self:UpdateInfo() --Обновление информации о детали
            self:UpdatePartComboBox() --Обновление информации в комбобокс
            sendClientCommand("BS", "Withdraw", {priceRenew,0})
            sendClientCommand(getPlayer(),"AutoMeh","SetPart",args)
        else
            player:Say(getText("IGUI_AM_No_Money"))
        end
    end
    if button.internal == "CREATEKEY" then --Изменить цену
        if vehicle then
            if CurrentBalance >= SandboxVars.NPC.AutomehCreateKeyPrice then
                local itemKey = vehicle:createVehicleKey()
                local NameKey = itemKey:getDisplayName() .. " [H " .. vehicle:getModData().sqlId .. " KT]"
                itemKey:setName(NameKey)
                player:getInventory():AddItem(itemKey)
                sendClientCommand("BS", "Withdraw", {SandboxVars.NPC.AutomehCreateKeyPrice,0})
            else
                player:Say(getText("IGUI_AM_No_Money"))
            end
        end
    end
    if button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
        AM_RepairCar.instance = nil
    end
end

function AM_RepairCar:new(x, y, width, height, player,geoX,geoY) --Создание окна
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
    AM_RepairCar.instance = o
    return o;
end


--#region Функции отрисовки рамки и перемещения

function AM_RepairCar:prerender()
    self.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    local th = 16
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_AM_RepairCar"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);
end
function AM_RepairCar:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function AM_RepairCar:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function AM_RepairCar:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end
function AM_RepairCar:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end
function AM_RepairCar:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end
function AM_RepairCar:onMouseDownOutside(x, y)
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