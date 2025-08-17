-- Author: FD --
-- require "PM_ISMenu"
-- сохраняем оригинал на всякий

require "ISUI/UserPanel/ISAddSHUI"
PM_ISMenu = ISPanel:derive("PM_ISMenu");
require "ISUI/UserPanel/ISCloseZone"
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

-- Добавляем переменные для песочницы
local sandboxZones = {}

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
    
    -- Инициализация зон песочницы
    if SandboxVars and SandboxVars.SafeHouseClose and SandboxVars.SafeHouseClose["CloseZone"] then
        sandboxZones = luautils.split(SandboxVars.SafeHouseClose["CloseZone"], ";")
    end
    
    local btnWid = 170                                   --Уменьшаем ширину кнопок в два раза
    local btnHgt = math.max(30, FONT_HGT_SMALL + 6)    --Уменьшаем высоту кнопок
    local padBottom = 15                                --Нижний отступ
    local y = 60;                                       --Отступ сверху
    local x = 15;                                       --Отступ слева

    --Современная панель баланса с боковыми отступами
    local balancePanel = ISPanel:new(15, 8, 350, 40)    --Панель с боковыми отступами 15px
    balancePanel.backgroundColor = {r=0.08, g=0.08, b=0.12, a=0.95}
    balancePanel.borderColor = {r=0.3, g=0.5, b=0.8, a=0.8}
    balancePanel:initialise()
    balancePanel:instantiate()
    self:addChild(balancePanel)

    --Надпись баланс по центру
    self.balancetext = ISLabel:new(90, 18, FONT_HGT_MEDIUM, getText("IGUI_Balance"), 0.9, 0.9, 0.9, 1, UIFont.Medium, true)
    self.balancetext.tooltip = getText("IGUI_RemoveConfirm_for_Support_Server")
    self.balancetext:initialise()
    self.balancetext:instantiate()
    self:addChild(self.balancetext)

    --Баланс игрока
    self.balance = ISLabel:new(x + self.balancetext:getWidth() + 15, 18, FONT_HGT_MEDIUM, "", 1, 0.8, 0.2, 1, UIFont.Medium, true)
    self.balance:initialise()
    self.balance:instantiate()
    self:addChild(self.balance)

    --бонусный баланс
    self.bonus = ISLabel:new(x + self.balance:getWidth() + 140, 18, FONT_HGT_MEDIUM, "", 0.4, 0.8, 1, 1, UIFont.Medium, true)
    self.bonus:initialise()
    self.bonus:instantiate()
    self:addChild(self.bonus)

    -- Кнопка фракции
    self.factionBtn = ISButton:new(x, y, btnWid, btnHgt, getText("UI_userpanel_factionpanel"), self, PM_ISMenu.onClick);
    self.factionBtn.internal = "FACTIONPANEL";
    self.factionBtn:initialise();
    self.factionBtn:instantiate();
    self.factionBtn.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
    self.factionBtn.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
    self.factionBtn.backgroundColorMouseOver = {r=0.18, g=0.22, b=0.28, a=1};
    self.factionBtn.backgroundColorPressed = {r=0.25, g=0.3, b=0.35, a=1};
    self.factionBtn.font = UIFont.Medium;               --Устанавливаем средний шрифт
    self.factionBtn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
    self:addChild(self.factionBtn);
    y = y + btnHgt + 8;

    --Если убежище существует
    if SafeHouse.hasSafehouse(self.player) then
        self.safehouseBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_SafehouseUI_Safehouse"), self, PM_ISMenu.onClick);
        self.safehouseBtn.internal = "SAFEHOUSEPANEL";
        self.safehouseBtn:initialise();
        self.safehouseBtn:instantiate();
        self.safehouseBtn.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
        self.safehouseBtn.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
        self.safehouseBtn.backgroundColorMouseOver = {r=0.18, g=0.22, b=0.28, a=1};
        self.safehouseBtn.backgroundColorPressed = {r=0.25, g=0.3, b=0.35, a=1};
        self.safehouseBtn.font = UIFont.Medium;
        self.safehouseBtn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
        self:addChild(self.safehouseBtn);
        y = y + btnHgt + 8;
    end

    --Кнопка выдачи убежища
    if not SafeHouse.hasSafehouse(self.player) then
        self.createsafehouseBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_CreatehouseUI_Safehouse"), self, PM_ISMenu.onClick);
        self.createsafehouseBtn.internal = "CREATESAFEHOUSE";
        self.createsafehouseBtn:initialise();
        self.createsafehouseBtn:instantiate();
        self.createsafehouseBtn.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
        self.createsafehouseBtn.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
        self.createsafehouseBtn.backgroundColorMouseOver = {r=0.18, g=0.22, b=0.28, a=1};
        self.createsafehouseBtn.backgroundColorPressed = {r=0.25, g=0.3, b=0.35, a=1};
        self.createsafehouseBtn.font = UIFont.Medium;
        self.createsafehouseBtn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
        self:addChild(self.createsafehouseBtn);
        y = y + btnHgt + 8;
    end

    --Если нет фракции
    if not Faction.isAlreadyInFaction(self.player) then
        self.factionBtn.title = getText("IGUI_FactionUI_CreateFaction");
        if not Faction.canCreateFaction(self.player) then
            self.factionBtn.enable = false;
            self.factionBtn.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"));
        end
        self.factionBtn:setWidthToTitle(self.factionBtn.width)
    end

    --кнопка убежище
    self.SHBTN = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_SafeHouseButton"), self, PM_ISMenu.onClick);
    self.SHBTN.internal = "SHBTN";
    self.SHBTN.textColor = { r = 0.7, g = 0.9, b = 0.7, a = 1 }; -- Приглушенный зеленый
    self.SHBTN.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.SHBTN:initialise();
    self.SHBTN:instantiate();
    self.SHBTN.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.SHBTN.font = UIFont.Medium;
    self:addChild(self.SHBTN);
    y = y + btnHgt + 8;

    --кнопка Мой магазин
    self.SHOPBTN = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_PMShopButton"), self, PM_ISMenu.onClick);
    self.SHOPBTN.internal = "SHOPBTN";
    self.SHOPBTN.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.SHOPBTN.textColor = { r = 0.7, g = 0.8, b = 0.9, a = 1 }; -- Приглушенный голубой
    self.SHOPBTN:initialise();
    self.SHOPBTN:instantiate();
    self.SHOPBTN.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.SHOPBTN.font = UIFont.Medium;
    self:addChild(self.SHOPBTN);
    y = y + btnHgt + 8;

    --кнопка Мой гараж
    self.Garage = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_My_Garage"), self, PM_ISMenu.onClick);
    self.Garage.internal = "GARAGE";
    self.Garage.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.Garage.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
    self.Garage:initialise();
    self.Garage:instantiate();
    self.Garage.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.Garage.font = UIFont.Medium;
    self:addChild(self.Garage);
    y = y + btnHgt + 8;

    --кнопка Магазин
    self.Shop = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_PMShop"), self, PM_ISMenu.onClick);
    self.Shop.internal = "SHOP";
    self.Shop.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.Shop.textColor = { r = 0.9, g = 0.8, b = 0.6, a = 1 }; -- Приглушенный желтый
    self.Shop:initialise();
    self.Shop:instantiate();
    self.Shop.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.Shop.font = UIFont.Medium;
    self:addChild(self.Shop);
    self.Shop:setEnabled(false) -- отключение кнопки магазин (в разработке)
    self.Shop:setVisible(false)

    if dontLoad then
        --кнопка Автолут (теперь выше Авторынка)
        self.AutoLoot = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AutoLoot"), self, PM_ISMenu.onClick);
        self.AutoLoot.internal = "AutoLoot";
        self.AutoLoot.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
        self.AutoLoot.textColor = { r = 0.9, g = 0.7, b = 0.5, a = 1 }; -- Приглушенный оранжевый
        self.AutoLoot:initialise();
        self.AutoLoot:instantiate();
        self.AutoLoot.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
        self.AutoLoot.font = UIFont.Medium;
        self:addChild(self.AutoLoot);
        y = y + btnHgt + 8;
    end

    --кнопка AutoMarket (теперь ниже Автосбора)
    self.AutoMarket = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AutoMarket"), self, PM_ISMenu.onClick);
    self.AutoMarket.internal = "AUTOMARKET";
    self.AutoMarket.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.AutoMarket.textColor = { r = 0.9, g = 0.6, b = 0.4, a = 1 }; -- Приглушенный оранжево-красный
    self.AutoMarket:initialise();
    self.AutoMarket:instantiate();
    self.AutoMarket.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.AutoMarket.font = UIFont.Medium;
    self:addChild(self.AutoMarket);
    y = y + btnHgt + 8;

    --Сбрасываем Y для чекбоксов (второй столбец)
    local y_checkboxes = 60;
    y_checkboxes = y_checkboxes + 30; -- Уменьшаем отступ с 8 до 5

    -- Современные чекбоксы
    self.showPingInfo = ISTickBox:new(x + btnWid + 15, y_checkboxes, 70, btnHgt, getText("IGUI_UserPanel_ShowPingInfo"), self, PM_ISMenu.onShowPingInfo);
    self.showPingInfo:initialise();
    self.showPingInfo:instantiate();
    self.showPingInfo.selected[1] = isShowPingInfo();
    self.showPingInfo:addOption(getText("IGUI_UserPanel_ShowPingInfo"));
    self.showPingInfo.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
    self.showPingInfo.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
    self:addChild(self.showPingInfo);

    y_checkboxes = y_checkboxes + btnHgt; -- Уменьшаем отступ с 8 до 3

    self.showkills = ISTickBox:new(x + btnWid + 15, y_checkboxes, 70, btnHgt, getText("IGUI_UserPanel_ShowKills"), self, PM_ISMenu.onShowKillsUI);
    self.showkills:initialise();
    self.showkills:instantiate();
    self.showkills.selected[1] = ClientTweaker.Options.GetBool("Show_Kills");
    self.showkills:addOption(getText("IGUI_UserPanel_ShowKills"));
    self.showkills.enable = true;
    self.showkills.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
    self.showkills.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
    self:addChild(self.showkills);
    y_checkboxes = y_checkboxes + btnHgt; -- Уменьшаем отступ с 8 до 3

    self.highlightSafehouse = ISTickBox:new(x + btnWid + 15, y_checkboxes, 70, btnHgt, getText("IGUI_UserPanel_HighlightSafehouse"), self, PM_ISMenu.onHighlightSafehouse);
    self.highlightSafehouse:initialise();
    self.highlightSafehouse:instantiate();
    self.highlightSafehouse.selected[1] = ClientTweaker.Options.GetBool("highlight_safehouse");
    self.highlightSafehouse:addOption(getText("IGUI_UserPanel_HighlightSafehouse"));
    self.highlightSafehouse.enable = SandboxVars.ServerTweaker.HighlightSafehouse;
    self.highlightSafehouse.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95};
    self.highlightSafehouse.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9};
    self:addChild(self.highlightSafehouse);


    --кнопка обновить баланс (ВОЗВРАЩАЕМ!)
    self.reload = ISButton:new(x, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_Reload"), self, PM_ISMenu.onClick);
    self.reload.internal = "RELOADS";
    self.reload.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 };
    self.reload:initialise();
    self.reload:instantiate();
    self.reload.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.reload.font = UIFont.Medium;
    self:addChild(self.reload);

    --Статус обновления (не используется)
    self.status = ISLabel:new(self.reload.x, self.reload.y - 20, FONT_HGT_MEDIUM, "", 0, 1, 0, 1, UIFont.Small, true)
    self.status:initialise()
    self.status:instantiate()
    self:addChild(self.status)

    --кнопка Отмена (закрыть окно) - размещаем справа от кнопки обновления
    self.cancel = ISButton:new(x + btnWid + 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, PM_ISMenu.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 }
    self.cancel.borderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 };
    self.cancel.font = UIFont.Medium;
    self:addChild(self.cancel);

    -- Запускаем таймер для обновления кнопок
    self:startUpdateTimer()
end

-- Добавляем функцию для запуска таймера обновления
function PM_ISMenu:startUpdateTimer()
    if not self.updateTimer then
        self.updateTimer = 0
        Events.OnTick.Add(PM_ISMenu.onUpdateTick)
    end
end

-- Функция обновления каждые 60 тиков (примерно 1 секунда)
function PM_ISMenu.onUpdateTick()
    if PM_ISMenu.instance and PM_ISMenu.instance:isVisible() then
        PM_ISMenu.instance.updateTimer = (PM_ISMenu.instance.updateTimer or 0) + 1
        if PM_ISMenu.instance.updateTimer >= 60 then
            PM_ISMenu.instance:updateButtons()
            PM_ISMenu.instance:updateSafehouseButtons()
            PM_ISMenu.instance:updateSafehouseButtonVisibility() -- Добавляем обновление видимости кнопок убежища
            PM_ISMenu.instance.updateTimer = 0
        end
    end
end

-- Функция для обновления видимости кнопок убежища
function PM_ISMenu:updateSafehouseButtonVisibility()
    if SafeHouse.hasSafehouse(self.player) then
        -- Если убежище есть
        if self.createsafehouseBtn and self.createsafehouseBtn:isVisible() then
            self.createsafehouseBtn:setVisible(false) -- Скрываем кнопку создания
        end
        if self.safehouseBtn and not self.safehouseBtn:isVisible() then
            self.safehouseBtn:setVisible(true) -- Показываем кнопку управления
        end
    else
        -- Если убежища нет
        if self.safehouseBtn and self.safehouseBtn:isVisible() then
            self.safehouseBtn:setVisible(false) -- Скрываем кнопку управления
        end
        if self.createsafehouseBtn and not self.createsafehouseBtn:isVisible() then
            self.createsafehouseBtn:setVisible(true) -- Показываем кнопку создания
        end
    end
end

-- Функция обновления кнопок убежища
function PM_ISMenu:updateSafehouseButtons()
    if SafeHouse.hasSafehouse(self.player) then
        -- Если убежище есть, но кнопка создания видна - скрываем её
        if self.createsafehouseBtn and self.createsafehouseBtn:isVisible() then
            self.createsafehouseBtn:setVisible(false)
        end
        -- Если кнопка убежища не видна - показываем её
        if not self.safehouseBtn then
            local btnWid = 170 -- Используем ту же ширину что и у других кнопок
            local btnHgt = math.max(30, FONT_HGT_SMALL + 6) -- Используем ту же высоту
            local y = 60 + btnHgt + 8 -- Правильное позиционирование после кнопки фракции
            
            self.safehouseBtn = ISButton:new(15, y, btnWid, btnHgt, getText("IGUI_SafehouseUI_Safehouse"), self, PM_ISMenu.onClick);
            self.safehouseBtn.internal = "SAFEHOUSEPANEL";
            self.safehouseBtn:initialise();
            self.safehouseBtn:instantiate();
            self.safehouseBtn.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9}; -- Современный синий
            self.safehouseBtn.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95}; -- Темно-синий
            self.safehouseBtn.backgroundColorMouseOver = {r=0.18, g=0.22, b=0.28, a=1}; -- Hover эффект
            self.safehouseBtn.backgroundColorPressed = {r=0.25, g=0.3, b=0.35, a=1}; -- Press эффект
            self.safehouseBtn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
            self.safehouseBtn.font = UIFont.Medium; -- Средний шрифт
            self:addChild(self.safehouseBtn);
        end
    else
        -- Если убежища нет, но кнопка убежища видна - скрываем её
        if self.safehouseBtn and self.safehouseBtn:isVisible() then
            self.safehouseBtn:setVisible(false)
        end
        -- Если кнопка создания не видна - показываем её
        if not self.createsafehouseBtn then
            local btnWid = 170 -- Используем ту же ширину что и у других кнопок
            local btnHgt = math.max(30, FONT_HGT_SMALL + 6) -- Используем ту же высоту
            local y = 60 + btnHgt + 8 -- Правильное позиционирование после кнопки фракции
            
            self.createsafehouseBtn = ISButton:new(15, y, btnWid, btnHgt, getText("IGUI_CreatehouseUI_Safehouse"), self, PM_ISMenu.onClick);
            self.createsafehouseBtn.internal = "CREATESAFEHOUSE";
            self.createsafehouseBtn:initialise();
            self.createsafehouseBtn:instantiate();
            self.createsafehouseBtn.borderColor = {r=0.4, g=0.6, b=0.8, a=0.9}; -- Современный синий
            self.createsafehouseBtn.backgroundColor = {r=0.12, g=0.15, b=0.2, a=0.95}; -- Темно-синий
            self.createsafehouseBtn.backgroundColorMouseOver = {r=0.18, g=0.22, b=0.28, a=1}; -- Hover эффект
            self.createsafehouseBtn.backgroundColorPressed = {r=0.25, g=0.3, b=0.35, a=1}; -- Press эффект
            self.createsafehouseBtn.textColor = { r = 0.9, g = 0.9, b = 0.9, a = 1 }; -- Единообразный белый цвет
            self.createsafehouseBtn.font = UIFont.Medium; -- Средний шрифт
            self:addChild(self.createsafehouseBtn);
        end
    end
end

function PM_ISMenu:render()
    local textWid = getTextManager():MeasureStringX(UIFont.Medium, self.balancetext.name);
    local textWid2 = getTextManager():MeasureStringX(UIFont.Medium, self.balance.name);
    local textWid3 = getTextManager():MeasureStringX(UIFont.Medium, self.bonus.name);
    
    -- Вычисляем общую ширину всех элементов баланса
    local totalWidth = textWid + 15 + textWid2 + 25 + textWid3 + 45 + 25 -- текст + отступ + баланс + отступ + бонус + отступ + алмаз
    local startX = 15 + (350 - totalWidth) / 2 -- центрируем с учетом отступа панели
    
    -- Позиционируем текст баланса
    self.balancetext:setX(startX)
    
    -- Позиционируем значение баланса
    self.balance:setX(startX + textWid + 15)
    
    -- Позиционируем бонус
    self.bonus:setX(startX + textWid + 15 + textWid2 + 35)
    
    --Отрисовка монеты возле баланса (с увеличенным отступом от цифры)
    local coinX = startX + textWid + 15 + textWid2 + 5
    self:drawTextureScaledAspect(icon_money, coinX, 18, 18, 18, 1, 1, 1, 1)
    
    --Отрисовка алмаза после бонуса (с увеличенным отступом от цифры)
    local diamondX = startX + textWid + 15 + textWid2 + 25 + textWid3 + 15
    self:drawTextureScaledAspect(icon_diam, diamondX, 16, 25, 25, 1, 1, 1, 1)
    
    self.bonus.name = tostring(PM.bonus)
    self.balance.name = tostring(PM.Balance)
    timer = timer + 1
    if timer >= 200 then
        self.reload.title = getText("IGUI_Reload")
        self.reload.textColor = { r = 1, g = 1, b = 1, a = 1 }
        self.reload.backgroundColor = { r = 0.12, g = 0.15, b = 0.2, a = 0.95 }
    else
        self.reload.title = tostring(math.floor((200 - timer) / 20)) .. getText("IGUI_ReloadTimer")
        self.reload.textColor = { r = 1, g = 1, b = 1, a = 0.5 }
        self.reload.backgroundColor = { r = 0.08, g = 0.1, b = 0.15, a = 0.95 }
    end
end

-- Добавляем функции для чекбоксов
function PM_ISMenu:onHighlightSafehouse(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("highlight_safehouse", enabled);
    end
end

function PM_ISMenu:onShowKillsUI(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("Show_Kills", enabled);
    end
end

function PM_ISMenu:onShowPingInfo(option, enabled)
    setShowPingInfo(enabled);
end

function PM_ISMenu:updateButtons()
    if not Faction.isAlreadyInFaction(self.player) then
        self.factionBtn.title = getText("IGUI_FactionUI_CreateFaction");
        if not Faction.canCreateFaction(self.player) then
            self.factionBtn.enable = false;
            self.factionBtn.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"));
        end
    else
        self.factionBtn.title = getText("UI_userpanel_factionpanel");
    end
end

function PM_ISMenu:onClick(button)
    if button.internal == "CANCEL" then
        -- Очищаем таймер обновления
        if self.updateTimer then
            Events.OnTick.Remove(PM_ISMenu.onUpdateTick)
            self.updateTimer = nil
        end
        
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
    
    --Открытие окна выдачи персонального убежища
    if button.internal == "CREATESAFEHOUSE" then
        if ISAddSHUI.instance then
            ISAddSHUI.instance:close();
        end
        --Проверка отображения кнопки, если убежище уже есть
        if SafeHouse.hasSafehouse(self.player) then
            self.createsafehouseBtn:setVisible(false)
            return;
        end
        --Проверка на запретную зону
        local x = math.floor((getPlayer():getX()) / 100)
        local y = math.floor((getPlayer():getY()) / 100)
        if FDSE and FDSE.checkTownZones and FDSE.checkTownZones(x, y, sandboxZones) then
            getPlayer():Say(getText('IGUI_Close_Zone'))
            return;
        end
        --Открытие окна создания убежища, закрытие окна
        local ui = ISAddSHUI:new(getCore():getScreenWidth() / 2 - 210, getCore():getScreenHeight() / 2 - 200, 420, 400, getPlayer());
        ui:initialise();
        ui:addToUIManager();
        self:close()
    end
    
    if button.internal == "SAFEHOUSEPANEL" then
        if SafeHouse.hasSafehouse(self.player) then
            local modal = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, SafeHouse.hasSafehouse(self.player), self.player);
            modal:initialise();
            modal:addToUIManager();
        end
    end

    if button.internal == "FACTIONPANEL" then
        if ISFactionUI.instance then
            ISFactionUI.instance:close()
        end
        if ISCreateFactionUI.instance then
            ISCreateFactionUI.instance:close()
        end
        if Faction.isAlreadyInFaction(self.player) then
            local modal = ISFactionUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, Faction.getPlayerFaction(self.player), self.player);
            modal:initialise();
            modal:addToUIManager();
        else
            local modal = ISCreateFactionUI:new(self.x + 100, self.y + 100, 350, 250, self.player)
            modal:initialise();
            modal:addToUIManager();
        end
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
            local x = self:getX() + self:getWidth() + 10
            local y = self:getY()
            local ui = PM_SafeHouseMenu:new(x, y, 200, 160, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "SHOPBTN" then
        if PM_ShopMenu.instance then
            PM_ShopMenu.instance:close()
            PM_ShopMenu.instance = nil
        else
            local x = self:getX() + self:getWidth() + 10
            local y = self:getY()
            local ui = PM_ShopMenu:new(x, y, 200, 250, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "GARAGE" then
        if PM_Garage.instance then
            PM_Garage.instance:close()
            PM_Garage.instance = nil
        else
            --Получаем координаты текущего окна + ширина и высота
            local x = self:getX() + self:getWidth() + 10
            local y = self:getY()
            local ui = PM_Garage:new(x, y, 220, 270, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "SHOP" then
        if PM_Shop.instance then
            PM_Shop.instance:close()
            PM_Shop.instance = nil
        else
            local x = self:getX() + self:getWidth() + 10
            local y = self:getY()
            local ui = PM_Shop:new(x, y, 600, 600, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "AutoLoot" then
        if UI_AutoLoot.instance then
            UI_AutoLoot.instance:close()
            UI_AutoLoot.instance = nil
        else
            local x = self:getX() + self:getWidth() + 10
            local y = self:getY()
            local ui = UI_AutoLoot:new(x, y, 400, 250, getPlayer());
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "AUTOMARKET" then
        local CarMagazine = require "cars/Magazine"
        CarMagazine.show()
    end
end

--Create new window
function PM_ISMenu:new(x, y, width, height, player)
    local o = {} -- Создаем новый объект
    -- Устанавливаем размеры по умолчанию для размещения всех элементов
    width = width or 380
    height = height or 420
    -- Получение для x и y центра экрана
    -- x = getCore():getScreenWidth() / 2 - (width / 2);
    -- y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);                -- Создание объекта окна с заданными размерами
    setmetatable(o, self)                                -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self                                  -- Устанавка индекса текущего объекта как self
    o.borderColor = { r = 0.3, g = 0.5, b = 0.8, a = 0.8 }; -- Современный синий цвет границы
    o.backgroundColor = { r = 0.08, g = 0.1, b = 0.15, a = 0.98 }; -- Темно-синий фон
    o.width = width;                                     -- Устанавка ширины окна
    o.height = height;                                   -- Устанавка высоты окна
    o.player = player;                                   -- Устанавка игрока
    o.moveWithMouse = true;                              -- Разрешаем перемещение окна с помощью мыши
    PM_ISMenu.instance = o;                              -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = { r = 0.4, g = 0.6, b = 0.8, a = 0.9 }; -- Современный синий цвет границы кнопки
    return o;                                            -- Возвращаем созданный объект
end

local original_ISUserPanelUI_new = ISUserPanelUI.new
-- подмена конструктора: вместо ISUserPanelUI возвращаем наш UI
ISUserPanelUI.new = function (x, y, width, height, player)
    if PM_ISMenu.instance then -- если уже открыто, закрываем
        PM_ISMenu.instance:close()
        PM_ISMenu.instance = nil
        -- Возвращаем объект-заглушку, чтобы избежать ошибки
        local dummy = {}
        dummy.initialise = function() end
        dummy.addToUIManager = function() end
        return dummy
    end
    local x,y = 150,200
    local w,h = 380,420
    local ui = PM_ISMenu:new(
        x,
        y,
        w, h, getPlayer()
    )
    ui:initialise()
    ui:addToUIManager()
    return ui
end