-- Author: FD --

PM_ShopInfo = ISPanel:derive("PM_ShopInfo");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local icon_info = getTexture("media/textures/pm_info.png")

function PM_ShopInfo:initialise()
    ISPanel.initialise(self);
    local btnWid = 150 --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок    
    local padBottom = 10 --Нижний отступ кнопки
    local x = 10; --Координата по горзонтали 
    local y = 15; --Координата по вертикали 

    --Заголовок "Информация"
    self.shoplabel = ISLabel:new(self:getWidth()/2 - 50, 10, FONT_HGT_MEDIUM, getText("IGUI_ShopInfoLabel"), 0, 1, 1, 1, UIFont.Medium, true)
    self.shoplabel:initialise()
    self.shoplabel:instantiate()
    self:addChild(self.shoplabel)

    --Содержание
    self.shop = ISLabel:new(x, self.shoplabel.y + y +10, FONT_HGT_MEDIUM, getText("IGUI_ShopInformation"), 1, 1, 1, 1, UIFont.Small, true)
    self.shop:initialise()
    self.shop:instantiate()
    self:addChild(self.shop)


    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth()/2 - btnWid/2, self:getHeight() - padBottom - btnHgt-5, btnWid-20, btnHgt, getText("UI_Close"), self, PM_ShopInfo.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true    
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.cancel);
end

function PM_ShopInfo:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();   
        PM_ShopInfo.instance = nil 
    end    
end

function PM_ShopInfo:render()
end

function PM_ShopInfo:new(x, y, width, height, player) --Функция создания окна
    local o = {} -- Создаем новый объект
    x = PM_ISMenu.instance.x + PM_ISMenu.instance.height / 2 - (height / 2) + 200;  
    y = PM_ISMenu.instance.y +PM_ISMenu.instance.width / 2 - (width / 2)+25;
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0.24, g=0.17, b=0.12, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    PM_ShopInfo.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    return o; -- Возвращаем созданный объект
end