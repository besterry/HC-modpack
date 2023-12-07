-- Author: FD --

PM_Shop = ISPanel:derive("PM_ShopInfo");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function PM_Shop:initialise()
    ISPanel.initialise(self);


end
function PM_Shop:onClick(button)
end

function PM_Shop:render()
end

function PM_Shop:new(x, y, width, height, player) --Функция создания окна
    local o = {} -- Создаем новый объект
    x = PM_ISMenu.instance.x + PM_ISMenu.instance.height;  
    y = PM_ISMenu.instance.y;
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0.24, g=0.17, b=0.12, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    PM_Shop.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    return o; -- Возвращаем созданный объект
end