AM_AdminPage = ISPanel:derive("AM_AdminPage")
AutoMeh = AutoMeh or {}
local o = {} -- Создаем новый объект
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function AM_AdminPage:initialise()
    ISPanel.initialise(self);
    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10
    local x = 10; --Горзонталь 
    local y = 15; --Вертикаль 

    --Заголовок окна
    self.ALLabel = ISLabel:new(self:getWidth()/4, 10, FONT_HGT_MEDIUM, getText("IGUI_AM_ParkingPenalty_Admin_List"), 0, 1, 0, 1, UIFont.Medium, true)
    self.ALLabel:initialise()
    self.ALLabel:instantiate()
    self:addChild(self.ALLabel)

    --Список
    local listY = 20 + FONT_HGT_MEDIUM + 10
    self.datas = ISScrollingListBox:new(10, listY, self.width - 20, self.height - padBottom - btnHgt - padBottom - padBottom - listY);
    self.datas:initialise();
    self.datas:instantiate();
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2; --Высота рамок
    self.datas.selected = 0;
    self.datas.joypadParent = self;
    self.datas.font = UIFont.Small; --Шрифт
    self.datas.doDrawItem = self.drawDatas;
    self.datas.drawBorder = true;
    self:addChild(self.datas);

    --Кнопка получить
    self.getCarBtn = ISButton:new(self:getWidth()/2 - btnWid/2 - btnWid/4, self:getHeight() - padBottom - btnHgt-5, btnWid/2, btnHgt, getText("IGUI_AM_AdminGetCar"), self, AM_AdminPage.onClick)
    self.getCarBtn.internal = "Restore"
    self.getCarBtn.anchorTop = false
    self.getCarBtn.anchorBottom = true
    self.getCarBtn:initialise();
    self.getCarBtn:instantiate();
    self.getCarBtn.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.getCarBtn.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.getCarBtn)

    --Кнопка удалить
    self.RefreshBtn = ISButton:new(self:getWidth()/2 + btnWid/2 - btnWid/4, self:getHeight() - padBottom - btnHgt-5, btnWid/2, btnHgt, getText("IGUI_AM_Delete"), self, AM_AdminPage.onClick)
    self.RefreshBtn.internal = "Delete"
    self.RefreshBtn.anchorTop = false
    self.RefreshBtn.anchorBottom = true
    self.RefreshBtn:initialise();
    self.RefreshBtn:instantiate();
    self.RefreshBtn.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.RefreshBtn.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.RefreshBtn)

    --Кнопка обновить
    self.RefreshBtn = ISButton:new(10, self:getHeight() - padBottom - btnHgt-5, btnWid/2, btnHgt, getText("IGUI_Refresh"), self, AM_AdminPage.onClick)
    self.RefreshBtn.internal = "Refresh"
    self.RefreshBtn.anchorTop = false
    self.RefreshBtn.anchorBottom = true
    self.RefreshBtn:initialise();
    self.RefreshBtn:instantiate();
    self.RefreshBtn.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.RefreshBtn.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.RefreshBtn)

    --кнопка Закрыть
    self.cancel = ISButton:new(self:getWidth() - btnWid/2 - 10, self:getHeight() - padBottom - btnHgt-5, btnWid/2, btnHgt, getText("UI_Close"), self, AM_AdminPage.onClick)
    self.cancel.internal = "CANCEL"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.backgroundColor = {r=0.43, g=0.21, b=0.1, a=0.8}
    self.cancel.borderColor = {r=0.99, g=0.93, b=1.0, a=0}
    self:addChild(self.cancel)
    self:getAllCarPenaltyParking()
end

function AM_AdminPage:getAllCarPenaltyParking() --Запрос таблицы автомобилей на парковке
    sendClientCommand(getPlayer(),"AutoMeh","getAllCarPenaltyParking",nil)
end

local function getData(module, command, args) --Получение таблицы автомобилей с сервера
    if module ~= "AutoMeh" then return end
    if command == "onGetAllCarPenaltyParking" then
        if args and args.globalModData then
            o.vehicleData = args.globalModData
        end
        o:onDataList()
    end
end
Events.OnServerCommand.Add(getData)

function AM_AdminPage:onDataList()
    self.datas:clear()
    local id = 1
    for username, userData in pairs(self.vehicleData) do
        for vehicleIdx, vehicleData in ipairs(userData) do
           local name = id .. ". " .. tostring(username) .. ", ID:" .. tostring(vehicleData.oldSqlid) .. ", " .. tostring(string.format("%.2f",(getWorld():getWorldAgeDays() - vehicleData.startDay))) .. getText("IGUI_AM_days") .. " = " .. math.floor((getWorld():getWorldAgeDays() - vehicleData.startDay)*SandboxVars.NPC.ParkingPenaltyPricePerDay) .. " $" .. ", Car: " .. tostring(vehicleData.scriptName)
           self.datas:addItem(name, vehicleData)
           id = id+1
        end
    end
end

function AM_AdminPage:update()
    local player = getPlayer()
    if AutoMeh.CheckDistance(self.geoX,self.geoY) then --Проверка дистанции до автомеханика
        self:setVisible(false)
        self:removeFromUIManager()
        AM_AdminPage.instance = nil
        player:Say(getText("IGUI_MehFar"))
    end
    local checkZoneSpawn = AutoMeh.CheckZoneSpawnCar() --Проверка свободна ли зона спавна
    if checkZoneSpawn then
        self.getCarBtn.enable = false
        self.getCarBtn:setTooltip(getText("IGUI_AM_Zone_busy"))
    else
        self.getCarBtn.enable = true
        self.getCarBtn:setTooltip(nil)
    end
end

function AM_AdminPage:deleteItem()
    if self.datas.selected <= 0 then
        print("No selected")
		return
	end
	local vehicleData = self.datas.items[self.datas.selected].item
	sendClientCommand(getPlayer(),"AutoMeh","deleteCar",{vehicleData=vehicleData})
end

function AM_AdminPage:onClick(button)
    if button.internal == "CANCEL" then
        self:setVisible(false)
        self:removeFromUIManager()
        AM_AdminPage.instance = nil
    end
    if button.internal == "Delete" then
        self:deleteItem()
    end
    if button.internal == "Refresh" then
        self:getAllCarPenaltyParking()
    end
    if button.internal == "Restore" then
        local vehicleData = self.datas.items[self.datas.selected].item
        local args = {}
        args.oldSqlid = vehicleData.oldSqlid
        args.vehicleFullName = vehicleData.vehicleFullName
        sendClientCommand(getPlayer(),"AutoMeh","GetCar",args)
        self:getAllCarPenaltyParking()
    end
end

function AM_AdminPage:new(x, y, width, height, player, geoX, geoY) --Функция создания окна
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height); -- Создание объекта окна с заданными размерами
    setmetatable(o, self) -- Устанавка текущего объект o как экземпляр класса PM_ISMenu
    self.__index = self -- Устанавка индекса текущего объекта как self
    o.geoX = geoX --Координата X автомеханика
    o.geoY = geoY --Координата Y автомеханика
    o.borderColor = {r=0.48, g=0.25, b=0.0, a=1}; -- Устанавка цвета границы окна {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}; -- Устанавка цвета фона окна {r=0, g=0, b=0, a=0.8};
    o.width = width; -- Устанавка ширины окна
    o.height = height; -- Устанавка высоты окна
    o.player = player; -- Устанавка игрока
    o.moveWithMouse = true; -- Разрешаем перемещение окна с помощью мыши
    AM_AdminPage.instance = o; -- Устанавливаем текущий объект как инстанс PM_ISMenu
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}; -- Устанавливаем цвет границы кнопки
    _G.AM_AdminPageInstance = o
    return o; -- Возвращаем созданный объект
end