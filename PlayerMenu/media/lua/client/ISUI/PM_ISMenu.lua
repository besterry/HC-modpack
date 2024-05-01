-- Author: FD --

require "ISUI/UserPanel/ISAddSHUI"
PM_ISMenu = ISPanel:derive("PM_ISMenu");
local mods = getActivatedMods();
local dontLoad = false;
for i = 0, mods:size() - 1, 1 do
    if mods:get(i) == "AutoLoot" or mods:get(i) == "AutoLoot_h" then
        dontLoad = true
    end
end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local icon_money = getTexture("media/textures/pm_money.png")
local icon_diam = getTexture("media/textures/pm_diamond.png")
local timer = 200
local BalancePlayer = "Loading..."
local SafeHouseSize = "Loading..."
local ShopCount = "Loading..."


PM = PM or {} -- Глобальный контейнер PlayerMenu
-- Обновление информации о клиенте при входе на сервер
OnCheckPlayer = function()
    Events.OnTick.Add(OnTickCheck);
end
OnTickCheck = function()
    local player = getPlayer()
    if not player then return end
    LoadBalanceAndSafeHousePlayer()
    Events.OnTick.Remove(OnTickCheck)
end
Events.OnCreatePlayer.Add(OnCheckPlayer)
--Можно сократить, но событие не смог подобрать
--Events.OnConnected.Add(LoadBalanceAndSafeHousePlayer)

--Запрос баланса и размера привата игрока
function LoadBalanceAndSafeHousePlayer()
    sendClientCommand(getPlayer(), 'BalanceAndSH', 'getData', {})
    local receiveServerCommand
    receiveServerCommand = function(module, command, args)
        if module ~= 'BalanceAndSH' then return; end
        if command == 'onGetData' then
            BalancePlayer = args['UserData'].balance
            SafeHouseSize = args['UserData'].safehouse
            ShopCount = args['UserData'].ShopCount
            PM.bonus = args['UserData'].bonus
            PM.Balance = BalancePlayer
            PM.SafeHouseSize = SafeHouseSize
            PM.ShopCount = ShopCount
            PM.MaxShopCount = args['UserData'].MaxShopCount
            --print(BalancePlayer)
            --print(SafeHouseSize)
            --print(ShopCount)
            local old_MaxSizeSH = MaxSizeSH
            MaxSizeSH = SafeHouseSize
            Events.OnServerCommand.Remove(receiveServerCommand)
        end
    end
    Events.OnServerCommand.Add(receiveServerCommand)
end

function PM_ISMenu:initialise()
    ISPanel.initialise(self);
    LoadBalanceAndSafeHousePlayer()
    local btnWid = 150                                  --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок
    local padBottom = 10                                --Нижний отступ кнопки
    local y = 10;                                       --Вертикаль
    local x = 10;                                       --Горизонталь

    --Надпись баланс
    self.balancetext = ISLabel:new(x, y, FONT_HGT_MEDIUM, getText("IGUI_Balance"), 1, 1, 1, 1, UIFont.Medium, true)
    self.balancetext.tooltip = "IGUI_SafehouseUI_RemoveConfirm_for_Support_Server"
    self.balancetext:initialise()
    self.balancetext:instantiate()
    self:addChild(self.balancetext)

    --Баланс игрока
    self.balance = ISLabel:new(x + self.balancetext:getWidth() + 5, y, FONT_HGT_MEDIUM, "", 255, 215, 0, 1, UIFont
    .Medium, true)
    self.balance:initialise()
    self.balance:instantiate()
    self:addChild(self.balance)

    --бонусный баланс
    self.bonus = ISLabel:new(x + self.balance:getWidth() + 145, y, FONT_HGT_MEDIUM, "", 0, 0.75, 1, 1, UIFont.Medium,
        true)
    self.bonus:initialise()
    self.bonus:instantiate()
    self:addChild(self.bonus)

    --кнопка убежище
    self.SHBTN = ISButton:new(x, self.balancetext.y + 25, btnWid, btnHgt, getText("IGUI_SafeHouseButton"), self,
        PM_ISMenu.onClick);
    self.SHBTN.internal = "SHBTN";
    self.SHBTN.textColor = { r = 0, g = 1, b = 0, a = 0.8 };
    self.SHBTN.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
    self.SHBTN:initialise();
    self.SHBTN:instantiate();
    self.SHBTN.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.SHBTN);

    --кнопка Мой магазин
    self.SHOPBTN = ISButton:new(x, self.SHBTN.y + 35, btnWid, btnHgt, getText("IGUI_PMShopButton"), self,
        PM_ISMenu.onClick);
    self.SHOPBTN.internal = "SHOPBTN";
    self.SHOPBTN.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
    self.SHOPBTN.textColor = { r = 0, g = 1, b = 1, a = 0.8 };
    self.SHOPBTN:initialise();
    self.SHOPBTN:instantiate();
    self.SHOPBTN.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.SHOPBTN);

    --кнопка Мой гараж
    self.Garage = ISButton:new(x, self.SHOPBTN.y + 35 * 2, btnWid, btnHgt, getText("IGUI_My_Garage"), self,
        PM_ISMenu.onClick);
    self.Garage.internal = "GARAGE";
    self.Garage.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
    self.Garage.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 };
    self.Garage:initialise();
    self.Garage:instantiate();
    self.Garage.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.Garage);

    --кнопка Магазин
    self.Shop = ISButton:new(x, self.Garage.y + 35, btnWid, btnHgt, getText("IGUI_PMShop"), self, PM_ISMenu.onClick);
    self.Shop.internal = "SHOP";
    self.Shop.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
    self.Shop.textColor = { r = 1, g = 1, b = 0, a = 0.8 };
    self.Shop:initialise();
    self.Shop:instantiate();
    self.Shop.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.Shop);
    self.Shop:setEnabled(false) -- отключение кнопки магазин (в разработке)
    self.Shop:setVisible(false)

    if dontLoad then
        local y_coord
        if self.Shop:isVisible() then
            y_coord = self.Shop.y + 35
        else
            y_coord = self.SHOPBTN.y + 35
        end
        --кнопка Автолут
        self.AutoLoot = ISButton:new(x, y_coord, btnWid, btnHgt, getText("IGUI_AutoLoot"), self, PM_ISMenu.onClick);
        self.AutoLoot.internal = "AutoLoot";
        self.AutoLoot.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
        self.AutoLoot.textColor = { r = 1, g = 1, b = 0, a = 0.8 };
        self.AutoLoot:initialise();
        self.AutoLoot:instantiate();
        self.AutoLoot.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
        self:addChild(self.AutoLoot);
    end

    --кнопка обновить баланс
    self.reload = ISButton:new(x, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_Reload"), self,
        PM_ISMenu.onClick);
    self.reload.internal = "RELOADS";
    self.reload.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 };
    self.reload:initialise();
    self.reload:instantiate();
    self.reload.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.reload);

    --Статус обновления (не используется)
    self.status = ISLabel:new(self.reload.x, self.reload.y - 20, FONT_HGT_MEDIUM, "", 0, 1, 0, 1, UIFont.Small, true)
    self.status:initialise()
    self.status:instantiate()
    self:addChild(self.status)

    --кнопка Отмена (закрыть окно)
    self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt,
        getText("UI_Close"), self, PM_ISMenu.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 }
    self.cancel.borderColor = { r = 0.99, g = 0.93, b = 1.0, a = 0 };
    self:addChild(self.cancel);
end

function PM_ISMenu:render()
    local textWid = getTextManager():MeasureStringX(UIFont.Medium, self.balancetext.name);
    local textWid2 = getTextManager():MeasureStringX(UIFont.Medium, self.balance.name);
    local textWid3 = getTextManager():MeasureStringX(UIFont.Medium, self.bonus.name);
    --Отрисовка монеты возле баланса
    self:drawTextureScaledAspect(icon_money, 10 + textWid2 + 5 + textWid + 5, 9, 18, 18, 1, 1, 1, 1)
    self.bonus:setX(10 + textWid2 + 5 + textWid + 30)
    self.bonus:setY(10)
    self:drawTextureScaledAspect(icon_diam, 10 + textWid2 + textWid3 + 5 + textWid + 35, 7, 25, 25, 1, 1, 1, 1)
    self.bonus.name = tostring(PM.bonus)
    self.balance.name = tostring(PM.Balance)
    timer = timer + 1
    if timer >= 200 then
        self.reload.title = getText("IGUI_Reload")
        self.reload.textColor = { r = 1, g = 1, b = 1, a = 1 }
        self.reload.backgroundColor = { r = 0.43, g = 0.21, b = 0.1, a = 0.8 }
    else
        self.reload.title = tostring(math.floor((200 - timer) / 20)) .. getText("IGUI_ReloadTimer")
        self.reload.textColor = { r = 1, g = 1, b = 1, a = 0.5 }
        self.reload.backgroundColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
    end
end

function PM_ISMenu:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager();
        if PM_SafeHouseMenu.instance then
            PM_SafeHouseMenu.instance:close()
            PM_SafeHouseMenu.instance = nil
        end
        if PM_ShopMenu.instance then
            PM_ShopMenu.instance:close()
            PM_ShopMenu.instance = nil
        end
        PM_ISMenu.instance = nil
    end
    if button.internal == "RELOADS" then
        if timer > 200 then
            LoadBalanceAndSafeHousePlayer()
            timer = 0
        end
    end
    if button.internal == "SHBTN" then
        if PM_SafeHouseMenu.instance then
            PM_SafeHouseMenu.instance:close()
            PM_SafeHouseMenu.instance = nil
        else
            local ui = PM_SafeHouseMenu:new(50, 50, 200, 160, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "SHOPBTN" then
        if PM_ShopMenu.instance then
            PM_ShopMenu.instance:close()
            PM_ShopMenu.instance = nil
        else
            local ui = PM_ShopMenu:new(50, 50, 200, 250, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "GARAGE" then
        if PM_Garage.instance then
            PM_Garage.instance:close()
            PM_Garage.instance = nil
        else
            local ui = PM_Garage:new(50, 50, 200, 150, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "SHOP" then
        if PM_Shop.instance then
            PM_Shop.instance:close()
            PM_Shop.instance = nil
        else
            local ui = PM_Shop:new(50, 50, 600, 600, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "AutoLoot" then
        if UI_AutoLoot.instance then
            UI_AutoLoot.instance:close()
            UI_AutoLoot.instance = nil
        else
            local ui = UI_AutoLoot:new(50, 50, 400, 250, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
end

--Create new window
function PM_ISMenu:new(x, y, width, height, player)
    local o = {} -- Создаем новый объект
    -- Получение для x и y центра экрана
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);                -- Создание объекта окна с заданными размерами
    setmetatable(o, self)                                -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self                                  -- Устанавка индекса текущего объекта как self
    o.borderColor = { r = 0.48, g = 0.25, b = 0.0, a = 1 }; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = { r = 0.24, g = 0.17, b = 0.12, a = 0.8 }; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width;                                     -- Устанавка ширины окна
    o.height = height;                                   -- Устанавка высоты окна
    o.player = player;                                   -- Устанавка игрока
    o.moveWithMouse = true;                              -- Разрешаем перемещение окна с помощью мыши
    PM_ISMenu.instance = o;                              -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }; -- Устанавливаем цвет границы кнопки
    return o;                                            -- Возвращаем созданный объект
end
