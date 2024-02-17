-- Author: FD --

PM_SafeHouseMenu = ISPanel:derive("PM_SafeHouseMenu");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local icon_home = getTexture("media/textures/pm_house.png")
local icon_money = getTexture("media/textures/pm_money.png")

function PM_SafeHouseMenu:initialise()
    ISPanel.initialise(self);
    local btnWid = 150 --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок    
    local padBottom = 10 --Нижний отступ кнопки
    local x = 10; --Координата по горзонтали 
    local y = 15; --Координата по вертикали 

    --Заголовок "Моё убежище"
    self.sh = ISLabel:new(self:getWidth()/2 - 50, 10, FONT_HGT_MEDIUM, getText("IGUI_SafeHouseLabel"), 0, 1, 0, 1, UIFont.Medium, true)
    self.sh:initialise()
    self.sh:instantiate()
    self:addChild(self.sh)

    --Надпись "Текущий размер"
    self.safehouse = ISLabel:new(x, self.sh.y + y +10, FONT_HGT_MEDIUM, getText("IGUI_SafeHouseSize"), 1, 1, 1, 1, UIFont.Small, true)
    self.safehouse:initialise()
    self.safehouse:instantiate()
    self:addChild(self.safehouse)

    --Целочисленное значение размера "Текущий размер"
    self.safehousesize = ISLabel:new(x + self.safehouse:getWidth() + 5, self.sh.y + y +10, FONT_HGT_MEDIUM, "", 1, 1, 1, 1, UIFont.Small, true)
    self.safehousesize:initialise()
    self.safehousesize:instantiate()
    self:addChild(self.safehousesize)

    --Надпись "Следующий размер"
    self.safehousenext = ISLabel:new(x, self.safehousesize.y + y, FONT_HGT_MEDIUM, getText("IGUI_SafeHouseNextSize"), 1, 1, 1, 1, UIFont.Small, true)
    self.safehousenext:initialise()
    self.safehousenext:instantiate()
    self:addChild(self.safehousenext)

    --Следующее расширение
    self.safehousenextsize = ISLabel:new(x + self.safehouse:getWidth() + 5, self.safehousesize.y + y, FONT_HGT_MEDIUM, "", 0, 1, 0, 1, UIFont.Small, true)
    self.safehousenextsize:initialise()
    self.safehousenextsize:instantiate()
    self:addChild(self.safehousenextsize)

    --Надпись "Стоймость расширения"
    self.pricelabel = ISLabel:new(x, self.safehousenextsize.y + y, FONT_HGT_MEDIUM, getText("IGUI_PriceLabel"), 1, 1, 1, 1, UIFont.Small, true)
    self.pricelabel:initialise()
    self.pricelabel:instantiate()
    self:addChild(self.pricelabel)

    --Цена расширения
    self.price = ISLabel:new(x + self.safehouse:getWidth() + 5, self.safehousenextsize.y + y, FONT_HGT_MEDIUM, "100", 1, 1, 0, 1, UIFont.Small, true)
    self.price:initialise()
    self.price:instantiate()
    self:addChild(self.price)

    --кнопка "Расширить"
    self.EXPAND = ISButton:new(self:getWidth()/2 - btnWid/2, self.pricelabel.y + y + 10, btnWid, btnHgt, getText("IGUI_Expand"), self, PM_SafeHouseMenu.onClick);
    self.EXPAND.internal = "EXPAND"; 
    self.EXPAND:initialise();
    self.EXPAND:instantiate();
    self.EXPAND.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.EXPAND.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.EXPAND);

    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth()/2 - btnWid/2, self:getHeight() - padBottom - btnHgt-5, btnWid, btnHgt, getText("UI_Close"), self, PM_SafeHouseMenu.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true    
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.cancel);
end

function PM_SafeHouseMenu:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();   
        PM_SafeHouseMenu.instance = nil  
    end
    if button.internal == "EXPAND" then --Расширение        
        if PM.Balance < 100 then
            getPlayer():Say(getText('IGUI_NoMoney'))
        else
            getPlayer():Say(getText('IGUI_SuccessESH'))
            local saveData = {}
            saveData.delta = 100
            saveData.balance = PM.Balance
            saveData.safehouse = (math.sqrt(PM.SafeHouseSize)+1)^2
            saveData.MaxShopCount = PM.MaxShopCount
            saveData.action = "buy expand safehouse"
            sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
            -- local safehouse = (math.sqrt(PM.SafeHouseSize)+1)^2
            -- local balanceOld = PM.Balance
            -- local balanceNew = PM.Balance - 100
            -- local saveData = {safehouse,balanceOld,balanceNew}
            -- sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveData', {userData=saveData})
            LoadBalanceAndSafeHousePlayer()
        end
    end    
end

function PM_SafeHouseMenu:render()
    self:drawTextureScaledAspect(icon_money,self.safehouse:getWidth() + 40,self.price.y+1,15,15,1,1,1,1)
    self:drawTextureScaledAspect(icon_home,self.sh.x - 25,6,20,20,1,1,1,1)
    --self.safehousesize.name = tostring(PM.SafeHouseSize)
    self.safehousesize.name = tostring(PM.SafeHouseSize) .. " (" .. math.sqrt(PM.SafeHouseSize) .. "x" .. math.sqrt(PM.SafeHouseSize) .. ")"
    if PM.SafeHouseSize < 1225 then
        self.safehousenextsize.name = tostring((math.sqrt(PM.SafeHouseSize)+1)^2) .. " (" .. math.sqrt(PM.SafeHouseSize)+1 .. "x" .. math.sqrt(PM.SafeHouseSize)+1 .. ")"
    else
        self.safehousenextsize.name = getText('IGUI_MaxSize')
    end

    if PM.SafeHouseSize == 1225 then
        self.EXPAND.enable = false
    else
        self.EXPAND.enable = true
    end
end

function PM_SafeHouseMenu:new(x, y, width, height, player) --Функция создания окна
    local o = {} -- Создаем новый объект
    x = PM_ISMenu.instance.x + PM_ISMenu.instance.height / 2 - (height / 2);  
    y = PM_ISMenu.instance.y +PM_ISMenu.instance.width / 2 - (width / 2);
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0.24, g=0.17, b=0.12, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    PM_SafeHouseMenu.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    return o; -- Возвращаем созданный объект
end