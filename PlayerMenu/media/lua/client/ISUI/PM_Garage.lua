-- Author: FD --

PM_Garage = ISPanel:derive("PM_Garage");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local icon_info = getTexture("media/textures/pm_info.png")
local icon_money = getTexture("media/textures/pm_money.png")
local icon_diam = getTexture("media/textures/pm_diamond.png")
PM.EditGarage = false
PM.DeleteGarage = false

function PM_Garage:initialise()
    ISPanel.initialise(self);
    self.Player = getPlayer()
    local btnWid = 150                                  --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок
    local padBottom = 10                                --Нижний отступ кнопки
    local x = 10;                                       --Координата по горзонтали
    local y = 15;                                       --Координата по вертикали

    --Заголовок "Мой гараж"
    self.shoplabel = ISLabel:new(self:getWidth() / 2 - 60, 10, FONT_HGT_MEDIUM, getText("IGUI_My_Garage"), 0, 1, 1, 1,
        UIFont.Medium, true)
    self.shoplabel:initialise()
    self.shoplabel:instantiate()
    self:addChild(self.shoplabel)

    --Описание
    self.InfoLabel = ISLabel:new(self:getWidth() / 2 - 60, 10, FONT_HGT_SMALL, getText("IGUI_My_Garage"), 0, 1, 1, 1,
    UIFont.Medium, true)
    self.InfoLabel:initialise()
    self.InfoLabel:instantiate()
    self:addChild(self.InfoLabel)

    --Чекбокс редактирования
    self.EditGarage = ISTickBox:new(10, self:getHeight() - padBottom - btnHgt - 35, 15, 15, "", self, self.clicked)
    self.EditGarage:initialise();
    self.EditGarage:instantiate();
    self.EditGarage.selected[1] = PM.EditGarage;
    self:addChild(self.EditGarage);
    self.EditGarage:addOption(getText("IGUI_editshopTB"));

    --Чекбокс удаления
    self.DeleteGarage = ISTickBox:new(10, self.EditGarage:getY() - 20, 15, 15, "", self, self.clickeddelete)
    self.DeleteGarage:initialise();
    self.DeleteGarage:instantiate();
    self.DeleteGarage.selected[1] = PM.DeleteGarage;
    self:addChild(self.DeleteGarage);
    self.DeleteGarage:addOption(getText("IGUI_DeleteGarageCheckBox"));

    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth() / 2 - (btnWid - 20) / 2, self:getHeight() - padBottom - btnHgt - 5,
        btnWid - 20, btnHgt, getText("UI_Close"), self, PM_Garage.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 }
    self.cancel.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.cancel);
end

function PM_Garage:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        PM_Garage.instance = nil
    end
end

function PM_Garage:checkSafeHouse()
    local square = self.player:getCurrentSquare()        -- Получаем текущую клетку игрока.
    if not square then return false end
    local safehouse = SafeHouse.getSafeHouse(square)     -- Получаем объект убежища для текущей клетки.
    if safehouse and safehouse:isOwner(self.player) then -- Проверяем, существует ли убежище и принадлежит ли оно игроку.
        return true
    else
        self.Player:Say(getText("IGUI_Not_in_safehouse_or_not_owner")) --Not in safehouse or not owner
        self.EditGarage.selected[1] = false
        return false
    end
end

local function hasGarageSpriteInSafehouse(player, spriteName)
    local safehouse = SafeHouse.getSafeHouse(player:getCurrentSquare())
    if not safehouse then
        return false
    end

    -- Перебираем все клетки убежища
    local sx, sy = safehouse:getX(), safehouse:getY()
    local ex, ey = safehouse:getX2(), safehouse:getY2()

    for x = sx, ex do
        for y = sy, ey do
            local square = getCell():getGridSquare(x, y, 0)
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    if object:getTextureName() and string.find(string.lower(object:getTextureName()), string.lower(spriteName)) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function PM_Garage:clickeddelete()
    local check = self:checkSafeHouse()
    if self.DeleteGarage.selected[1] and check then
        PM.DeleteGarage = true
    else
        PM.DeleteGarage = false
    end
end

function PM_Garage:clicked()
    local check = self:checkSafeHouse()
    if check then
        if hasGarageSpriteInSafehouse(self.player, "garage_0") then
            -- Если уже существует, выполняем нужные действия.
            self.player:Say(getText("IGUI_GarageAlreadyExists"))--Garage already exists in the safehouse.
            PM.EditGarage = false
            check = false
            self.EditGarage.selected[1] = false
            return
        end
    end
    if self.EditGarage.selected[1] and check then
        PM.EditGarage = true
    else
        PM.EditGarage = false
    end
end

function PM_Garage:update()
    if PM.DeleteGarage then
        self.DeleteGarage.selected[1] = true
    else
        self.DeleteGarage.selected[1] = false
    end
    if PM.EditGarage then
        self.EditGarage.selected[1] = true
    else
        self.EditGarage.selected[1] = false
    end
    -- if PM.ShopCount == PM.MaxShopCount and self.EditGarage.selected[1] then --Автоотключение установки гаража
    --     self.EditGarage.selected[1] = false
    --     getPlayer():Say(getText('IGUI_editshopTBdisable'))
    -- end
end

function PM_Garage:new(x, y, width, height, player) --Функция создания окна
    local o = {}                                    -- Создаем новый объект
    x = PM_ISMenu.instance.x + PM_ISMenu.instance.height / 2 - (height / 2);
    y = PM_ISMenu.instance.y + PM_ISMenu.instance.width / 2 - (width / 2);
    o = ISPanel:new(x, y, width, height);                          -- Создание объекта окна с заданными размерами
    setmetatable(o, self)                                          -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self                                            -- Устанавка индекса текущего объекта как self
    o.borderColor = { r = 0.48, g = 0.25, b = 0.0, a = 1 };        -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = { r = 0.24, g = 0.17, b = 0.12, a = 0.8 }; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width;                                               -- Устанавка ширины окна
    o.height = height;                                             -- Устанавка высоты окна
    o.player = player;                                             -- Устанавка игрока
    o.moveWithMouse = true;                                        -- Разрешаем перемещение окна с помощью мыши
    PM_Garage.instance = o;                                        -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 };  -- Устанавливаем цвет границы кнопки
    return o;                                                      -- Возвращаем созданный объект
end
