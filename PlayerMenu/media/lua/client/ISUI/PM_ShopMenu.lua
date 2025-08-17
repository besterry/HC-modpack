-- Author: FD --

PM_ShopMenu = ISPanel:derive("PM_ShopMenu");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
local icon_info = getTexture("media/textures/pm_info.png")
local icon_money = getTexture("media/textures/pm_money.png")
local icon_diam = getTexture("media/textures/pm_diamond.png")
PM.editshopTB = false

function PM_ShopMenu:initialise()
    ISPanel.initialise(self);
    local btnWid = 150 --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок    
    local padBottom = 10 --Нижний отступ кнопки
    local x = 10; --Координата по горзонтали 
    local y = 15; --Координата по вертикали 

    --Заголовок "Мой магазин"
    self.shoplabel = ISLabel:new(self:getWidth()/2 - 60, 10, FONT_HGT_MEDIUM, getText("IGUI_ShopMenuLabel"), 0, 1, 1, 1, UIFont.Medium, true)
    self.shoplabel:initialise()
    self.shoplabel:instantiate()
    self:addChild(self.shoplabel)

    --Надпись "Магазины"
    self.shop = ISLabel:new(self:getWidth()/2-50, self.shoplabel.y + y +10, FONT_HGT_MEDIUM, getText("IGUI_ShopCount"), 1, 1, 1, 1, UIFont.Small, true)
    self.shop:initialise()
    self.shop:instantiate()
    self:addChild(self.shop)

    --Число магазинов : 0/10
    self.shopcount = ISLabel:new(self.shop.x+60, self.shoplabel.y + y +10, FONT_HGT_MEDIUM, "", 1, 1, 1, 1, UIFont.Small, true)
    self.shopcount:initialise()
    self.shopcount:instantiate()
    self:addChild(self.shopcount) 

    self.EXPANDCOIN = ISButton:new(self:getWidth()/2 - btnWid/2-10, self.shop.y + y + 35, btnWid/2, btnHgt, getText("IGUI_Expand"), self, PM_ShopMenu.onClick);
    self.EXPANDCOIN.internal = "EXPANDCOIN"; 
    self.EXPANDCOIN:initialise();
    self.EXPANDCOIN:instantiate();
    self.EXPANDCOIN.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.EXPANDCOIN.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.EXPANDCOIN);

    self.ExpCoinLabel = ISLabel:new(self.EXPANDCOIN.x+self.EXPANDCOIN:getWidth()/2-5, self.shop.y + y +10, FONT_HGT_MEDIUM,"50", 1, 1, 1, 1, UIFont.Small, true)
    self.ExpCoinLabel:initialise()
    self.ExpCoinLabel:instantiate()
    self:addChild(self.ExpCoinLabel)

    self.EXPANDBONUS = ISButton:new(self:getWidth()/2 + 10, self.ExpCoinLabel.y + y + 10, btnWid/2, btnHgt, getText("IGUI_Expand"), self, PM_ShopMenu.onClick);
    self.EXPANDBONUS.internal = "EXPANDBONUS"; 
    self.EXPANDBONUS:initialise();
    self.EXPANDBONUS:instantiate();
    self.EXPANDBONUS.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.EXPANDBONUS.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.EXPANDBONUS);

    self.ExpBonusLabel = ISLabel:new(self.EXPANDBONUS.x+self.EXPANDBONUS:getWidth()/2-5, self.shop.y + y +10, FONT_HGT_MEDIUM, "5", 1, 1, 1, 1, UIFont.Small, true)
    self.ExpBonusLabel:initialise()
    self.ExpBonusLabel:instantiate()
    self:addChild(self.ExpBonusLabel)
 
    --Чекбокс редактирования
    self.editshopTB = ISTickBox:new(10, self:getHeight()- padBottom - btnHgt-35, 15, 15, "", nil, nil)
    self.editshopTB:initialise();
    self.editshopTB:instantiate();
    self.editshopTB.selected[1] = PM.editshopTB;
    self:addChild(self.editshopTB);
    self.editshopTB:addOption(getText("IGUI_editshopTB"));

    --кнопка информация    
    self.info = ISButton:new(self.shoplabel.x + self.shoplabel:getWidth() + 5, self.shoplabel.y-5, 25, 25, "", self, PM_ShopMenu.onClick);
    self.info.internal = "OPENINFO";
    self.info:setImage(icon_info)
    self.info:setDisplayBackground(false)
    self.info.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self:addChild(self.info);

    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth()/2 - (btnWid-20)/2, self:getHeight() - padBottom - btnHgt-5, btnWid-20, btnHgt, getText("UI_Close"), self, PM_ShopMenu.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true    
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0};
    self:addChild(self.cancel);
end

function PM_ShopMenu:onClick(button)
    if button.internal == "OPENINFO" then
        if PM_ShopInfo.instance then
            PM_ShopInfo.instance:close()
            PM_ShopInfo.instance = nil
        else  
            local ui = PM_ShopInfo:new(50,50,250,250, getPlayer());    
            ui:initialise();
            ui:addToUIManager();
        end
    end
    if button.internal == "CANCEL" then
        self:setVisible(false);
        self:removeFromUIManager(); 
        PM_ShopMenu.instance = nil   
    end    
    if button.internal == "EXPANDCOIN" then
        if PM.Balance >= 50 and PM.MaxShopCount<15 then
            local saveData = {}
            saveData.delta = 50
            saveData.balance = PM.Balance
            saveData.MaxShopCount = PM.MaxShopCount + 1
            saveData.action = "buy MaxShopCount for coins"
            sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
            LoadBalanceAndSafeHousePlayer()
        end
        if PM.Balance < 50 then
            getPlayer():Say(getText('IGUI_NoMoney'))
        end
    end      
    if button.internal == "EXPANDBONUS" then --Если игрок покупает расширение за бонусы
        if PM.bonus >= 5 and PM.MaxShopCount<10 then --цена покупки 5 бонусов, максимум 10 магазинов
            local saveData = {}
            saveData.delta = 5
            saveData.bonus = PM.bonus            
            saveData.MaxShopCount = PM.MaxShopCount + 1
            saveData.action = "buy MaxShopCount for bonus"
            sendClientCommand(getPlayer(), 'BalanceAndSH', 'saveUserData', saveData)
            LoadBalanceAndSafeHousePlayer()
        end
        if PM.bonus < 5 then
            getPlayer():Say(getText('IGUI_NoMoney'))
        end
    end       
end

function PM_ShopMenu:render()
    --Отрисовка монеты возле баланса
    self:drawTextureScaledAspect(icon_money,self.ExpCoinLabel.x + 15,self.ExpCoinLabel.y,15,15,1,1,1,1)
    self:drawTextureScaledAspect(icon_diam,self.ExpBonusLabel.x + 10,self.ExpBonusLabel.y-3,23,23,1,1,1,1) 
    
    self.shopcount.name = PM.ShopCount .. "/" .. PM.MaxShopCount
    if self.editshopTB.selected[1] then
        PM.editshopTB = true        
    else
        PM.editshopTB = false
    end 
    if PM.ShopCount == PM.MaxShopCount and self.editshopTB.selected[1] then
        self.editshopTB.selected[1] = false
        getPlayer():Say(getText('IGUI_editshopTBdisable'))
    end
    if PM.MaxShopCount == 10 then 
        self.EXPANDCOIN.enable = false
        self.EXPANDCOIN.tooltip = getText("IGUI_PM_TooltipExpandCoin");
        self.EXPANDBONUS.enable = false
        self.EXPANDBONUS.tooltip = getText("IGUI_PM_TooltipExpandCoin");
    else
        self.EXPANDCOIN.enable = true
        self.EXPANDCOIN.tooltip = nil
        self.EXPANDBONUS.enable = true
        self.EXPANDBONUS.tooltip = nil
    end

end

function PM_ShopMenu:new(x, y, width, height, player) --Функция создания окна
    local o = {} -- Создаем новый объект
    -- x = PM_ISMenu.instance.x + PM_ISMenu.instance.height / 2 - (height / 2);  
    -- y = PM_ISMenu.instance.y +PM_ISMenu.instance.width / 2 - (width / 2);
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0.24, g=0.17, b=0.12, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    PM_ShopMenu.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    return o; -- Возвращаем созданный объект
end