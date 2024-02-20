-- Author: FD --

AutoLootAdminPanel_UI = ISPanel:derive("AutoLootAdminPanel_UI");
PM = PM or {} -- Глобальный контейнер PlayerMenu
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)
--PM.Autoloot = false
local price = 100 --Цена подписки
PM.AutolootDurationAction = 7 --На сколько активируется подписка

local function onGetPlayers()    
    sendClientCommand(getPlayer(),'AdminAutoLoot','getPlayers',{})
    print("send command")
end

function AutoLootAdminPanel_UI:initialise()
    ISPanel.initialise(self);
    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local x = 10; --Горзонталь 
    local y = 15; --Вертикаль 

    --Заголовок окна
    self.ALLabel = ISLabel:new(self:getWidth()/4, 10, FONT_HGT_MEDIUM, getText("IGUI_IGAutoLootAdminPanel"), 0, 1, 0, 1, UIFont.Medium, true)
    self.ALLabel:initialise()
    self.ALLabel:instantiate()
    self:addChild(self.ALLabel)

    --Список
    local listY = 20 + FONT_HGT_MEDIUM + 10
    self.datas = ISScrollingListBox:new(10, listY, self.width - 20, self.height - padBottom - btnHgt - padBottom - padBottom - listY);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.NewSmall;
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self:addChild(self.datas);

    --Кнопка обновить
    self.RefreshBtn = ISButton:new(self:getWidth()/4 - btnWid/2, self:getHeight() - padBottom - btnHgt-5, btnWid, btnHgt, getText("IGUI_Refresh"), self, AutoLootAdminPanel_UI.onClick)
    self.RefreshBtn.internal = "Refresh"
    self.RefreshBtn.anchorTop = false
    self.RefreshBtn.anchorBottom = true
    self.RefreshBtn:initialise();
    self.RefreshBtn:instantiate();
    self.RefreshBtn.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.RefreshBtn.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.RefreshBtn)

    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth()/2 +self:getWidth()/4 - btnWid/2, self:getHeight() - padBottom - btnHgt-5, btnWid, btnHgt, getText("UI_Close"), self, AutoLootAdminPanel_UI.onClick)
    self.cancel.internal = "CANCEL"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.cancel)

    self:onDataList()
end

function AutoLootAdminPanel_UI:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false)
        self:removeFromUIManager()
        AutoLootAdminPanel_UI.instance = nil
    end
    if button.internal == "Refresh" then
        print("RefreshBtn")
        onGetPlayers()
        --self:onDataList()
    end
end

function AutoLootAdminPanel_UI:onDataList()
    --onGetPlayers()
    -- self.datas:clear();
    -- for i=0,Faction.getFactions():size()-1 do
    --     local fact = Faction.getFactions():get(i);
    --    self.datas:addItem(fact:getName(), fact);
    -- end
end

function AutoLootAdminPanel_UI:render()    
end

function AutoLootAdminPanel_UI:new(x, y, width, height, player) --Функция создания окна
    local o = {} -- Создаем новый объект
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    AutoLootAdminPanel_UI.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    return o; -- Возвращаем созданный объект
end
