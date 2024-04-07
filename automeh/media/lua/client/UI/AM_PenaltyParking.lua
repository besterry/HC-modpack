PenaltyParkingUI = ISPanelJoypad:derive("PenaltyParkingUI")
AutoMeh = AutoMeh or {}

local EventOnTickAdd = true
local function getCarPP()
	local player = getPlayer()
	if not player then return end
	sendClientCommand(player, "AutoMeh", "getCarPP", nil)
	if EventOnTickAdd then
		Events.OnTick.Remove(getCarPP)
		EventOnTickAdd = false
	end
end
Events.OnTick.Add(getCarPP) --Запрос данных о хранимых авто на штрафстоянке при подключении

local modDataUser
local function receiveServerCommand(module, command, args)
    if module ~= "AutoMeh" then return end
    if command == "onCarPP" then
        if args and args.modDataUser then
            modDataUser = args.modDataUser
        end
    end
end
Events.OnServerCommand.Add(receiveServerCommand)


function PenaltyParkingUI:initialise() --Создание элементов окна
    ISPanelJoypad.initialise(self)
    getCarPP() --Запрос ТС с сервера
    if modDataUser~=nil then self.currenCarList=modDataUser end --Список ТС при инициализации окна
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
    local buttonWid = 100
    local buttonHgt = 25
    local x = 10

    self.RegCarInfo = ISLabel:new(x, 50, FONT_HGT_SMALL, getText("IGUI_AM_UserCarPenaltyParking"), 1, 1, 1, 1, UIFont.Small, true)
    self.RegCarInfo:initialise()
    self.RegCarInfo:instantiate()
    self:addChild(self.RegCarInfo)

    --Выпадающий список автомобилей
    self.comboBox = ISComboBox:new(x, self.RegCarInfo:getY()+20, self:getWidth()-20, 20, self,self.onClickTab)
    self.comboBox:initialise()
    self.comboBox:instantiate()
    self:addChild(self.comboBox)

    --Получения ТС с штрафстоянки
    self.getCarBtn = ISButton:new(self:getWidth()/2-buttonWid/2, self:getHeight() - x - buttonHgt, buttonWid, buttonHgt, getText("IGUI_AM_GetCarPenaltyParking"), self, PenaltyParkingUI.onClick)
    self.getCarBtn.internal = "GETCAR"
    self.getCarBtn:initialise()
    self.getCarBtn:instantiate()
    self.getCarBtn:setEnable(false)
    self.getCarBtn.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.getCarBtn)

    --Кнопка закрытия окна 
    self.close = ISButton:new(self:getWidth()-buttonWid-10, self:getHeight() - x - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, PenaltyParkingUI.onClick)
    self.close.internal = "CLOSE"
    self.close:initialise()
    self.close:instantiate()
    self.close.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.close)
end

function PenaltyParkingUI:FillComboBox()
    self.comboBox:clear()
    local FirstCar = nil
    if modDataUser then
        for _, vehicleData in ipairs(modDataUser) do
            local days = getWorld():getWorldAgeDays() - vehicleData.startDay
            local pricePerDay = SandboxVars.NPC.ParkingPenaltyPricePerDay
            self.price = math.floor(days * pricePerDay) --Цена стоянки            
            days = string.format("%.2f", days)
            --local text = vehicleData.scriptName .. " [H ".. vehicleData.oldSqlid .. " KT] - " .. self.price .. " $" .. getText("IGUI_AM_Per")  .. days .. getText("IGUI_AM_days")
            local text = getText("IGUI_VehicleName" .. getText(vehicleData.scriptName))  .. " [H ".. vehicleData.oldSqlid .. " KT] - " .. self.price .. " $" .. getText("IGUI_AM_Per")  .. days .. getText("IGUI_AM_days")
            self.comboBox:addOptionWithData(text, vehicleData)
            if FirstCar == nil then FirstCar = vehicleData end
        end
        if FirstCar ~= nil then self.SelectedCar = FirstCar end
    end
end

function PenaltyParkingUI:onClickTab() --Действие по выбору автомобиля в выпадающем списке
    local SelectedData = self.comboBox.options[self.comboBox.selected]
    self.SelectedCar = SelectedData.data
end

function PenaltyParkingUI:render() --Обновление 20 раз в секунду
end
local checkChange
function PenaltyParkingUI:update() --Обновление 10 раз в секунду    

    local player = getPlayer()
    if AutoMeh.CheckDistance(self.geoX,self.geoY) then --Проверка дистанции до автомеханика
        self:setVisible(false)
		self:removeFromUIManager()
        player:Say(getText("IGUI_MehFar"))
    end

    if modDataUser ~= checkChange then
        checkChange = modDataUser
        self:FillComboBox()
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

function PenaltyParkingUI:onClick(button)
    if button.internal == "GETCAR" then --NOTE: Добавить проверку баланса и списание средств за парковку
        local balance = AutoMeh.BalancePlayer()
        if balance < self.price then getPlayer():Say(getText("IGUI_AM_No_Money")) return end
        if self.SelectedCar then
            local args = {}
            args.oldSqlid = self.SelectedCar.oldSqlid
            args.vehicleFullName = self.SelectedCar.vehicleFullName
            --print(self.SelectedCar)
            sendClientCommand(getPlayer(),"AutoMeh","GetCar",args)
            sendClientCommand("BS", "Withdraw", {self.price,0})
            self:setVisible(false)
            self:removeFromUIManager()
            PenaltyParkingUI.instance = nil
        else
            getPlayer():Say(getText("IGUI_AM_Select_car"))
        end
    end
    if button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
        PenaltyParkingUI.instance = nil
    end
end

function PenaltyParkingUI:new(x, y, width, height, player, geoX, geoY) --Создание окна
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
    PenaltyParkingUI.instance = o
    return o;
end

--#region Функции отрисовки рамки и перемещения

function PenaltyParkingUI:prerender()
    self.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    local th = 16
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_AM_PenaltyParking"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);
end
function PenaltyParkingUI:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function PenaltyParkingUI:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function PenaltyParkingUI:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end
function PenaltyParkingUI:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end
function PenaltyParkingUI:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end
function PenaltyParkingUI:onMouseDownOutside(x, y)
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