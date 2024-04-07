local iconConfidant = getTexture("media/textures/Confidant.png")
ConfidantCarUI = ISPanelJoypad:derive("ConfidantCarUI");

LuaEventManager.AddEvent("onListChange")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
function ConfidantCarUI:initialise() --Создание элементов окна
    ISPanelJoypad.initialise(self);

    local fontHgt = FONT_HGT_SMALL
    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "Select area") + 12
    local buttonWid3 = getTextManager():MeasureStringX(UIFont.Small, "Close") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid3), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10
    local sqlId = self.vehicleForSend:getModData().sqlId

    self.RegCarInfo = ISLabel:new(self:getWidth()/2-20, 42 , FONT_HGT_SMALL,"H "..tostring(sqlId) .. " KT", 1, 1, 1, 1, UIFont.Small, true)
    self.RegCarInfo:initialise()
    self.RegCarInfo:instantiate()
    self:addChild(self.RegCarInfo)

    self.scrollingList = ISScrollingListBox:new(10, 60, self:getWidth() - 20, self:getHeight() - 150)
    self.scrollingList:initialise();
    self.scrollingList:instantiate();
    self.scrollingList.itemheight = 25;
    self.scrollingList.joypadParent = self;
    self.scrollingList.font = UIFont.Small;
    self.scrollingList:setOnMouseDownFunction(self, self.onClickItem);
    self.scrollingList.drawBorder = true;
    self:addChild(self.scrollingList);

    self.addUserBtn = ISButton:new(self.scrollingList:getX()+self.scrollingList:getWidth()/2-37, self.scrollingList:getY()+self.scrollingList:getHeight()+10, 30, 30, "+", self, ConfidantCarUI.onClick);
    self.addUserBtn.internal = "ADD";
    self.addUserBtn:initialise();
    self.addUserBtn:instantiate();
    self.addUserBtn.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.addUserBtn);

    self.RemoveUser = ISButton:new(self.addUserBtn:getX()+45, self.scrollingList:getY()+self.scrollingList:getHeight()+10, 30, 30, "-", self, ConfidantCarUI.onClick);
    self.RemoveUser.internal = "REMOVE";
    self.RemoveUser:initialise();
    self.RemoveUser:instantiate();
    self.RemoveUser.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.RemoveUser);

    self.close = ISButton:new((self:getWidth() / 2)-buttonWid/2, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, getText("UI_Close"), self, ConfidantCarUI.onClick);
    self.close.internal = "CLOSE";
    self.close:initialise();
    self.close:instantiate();
    self.close.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.close);
    self:populateList()
end

function ConfidantCarUI.populateList(self)
    self.scrollingList:clear()
    if not self.vehicleForSend:getModData().Confidant then
        self.vehicleForSend:getModData().Confidant = {}
    end

    for _, user in ipairs(self.vehicleForSend:getModData().Confidant) do
        local listItem = {}
        listItem.item = user
        listItem.text = user
        self.scrollingList:addItem(listItem.text, listItem.item)
    end
end
function ConfidantCarUI:tableToString(tbl)
    local str = ""
    for key, value in pairs(tbl) do
        str = str .. tostring(value)
    end
    return str
end
local maxEntries = 5
local currentString = ""
function ConfidantCarUI:render()
    if self.vehicleForSend:getModData().Confidant and #self.vehicleForSend:getModData().Confidant<maxEntries then
        self.addUserBtn:setEnable(true)        
    else
        self.addUserBtn:setEnable(false)
        self.addUserBtn:setTooltip(getText("IGUI_MaximumConfidant"))
    end
    local originalTable = self.vehicleForSend:getModData().Confidant or {}
    local newString = self:tableToString(originalTable)    
    if newString ~= currentString then
        currentString = newString
        self:populateList()
    end    
end

function ConfidantCarUI:addUser(user) --Функция отправляет команду на сервер для добавления юзера с кнопки ADD
    if self.vehicleForSend:getModData().register == getPlayer():getUsername() then
        local args = {}
        args.user = user
        args.vehicleId = self.vehicleForSend:getId()
        sendClientCommand(getPlayer(), 'RegisterCar', 'AddConfidant', args)
    else
        getPlayer():Say(getText("IGUI_This_no_my_car"))
    end
end
local RemoveUser
function ConfidantCarUI:onClickItem(selectedIndex, selectedText)
    RemoveUser=selectedIndex --Выбраный ник
end


function ConfidantCarUI:onClick(button)
    if button.internal == "ADD" then --Добавление пользователя в доверенные
        local user
        local modal = ISTextBox:new(1250,720,260,120,getText("IGUI_UserName"),"",self,
            function(_self, button)
                if button.internal == "OK" then
                    user = button.parent.entry:getText()
                    ConfidantCarUI.addUser(_self, user)
                end
            end,nil
        )
        modal:initialise()
        modal:addToUIManager()
    end
    if button.internal == "REMOVE" then --Удаление пользователя из доверенных
        local args = {}
        args.user=RemoveUser
        args.vehicleId = self.vehicleForSend:getId() 
        sendClientCommand(getPlayer(), 'RegisterCar', 'DelConfidant', args)
    end
    if button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
        RegisterCar.instance = nil
        return;
    end
end
local function receiveServerCommandAddUser (module, command, args)--Добавление юзера
    if module ~= "RegisterCar" then return; end
    if command ~= "onAddConfidant" then return; end
    if args.result then
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle or not args.result then return end
        local confidantData = vehicle:getModData().Confidant or {}
        table.insert(confidantData, args.user)
        vehicle:getModData().Confidant = confidantData
    end
end
Events.OnServerCommand.Add(receiveServerCommandAddUser)

local function receiveServerCommandDelete (module, command, args)--Удаление юзера
    if module ~= "RegisterCar"  then return; end
    if command ~= "onDelConfidant" then return end
    if args.result then
        local vehicle = getVehicleById(args.vehicleId)
        if not vehicle or not args.result then return end
        local newConfidantData = {}
        local confidantData = vehicle:getModData().Confidant or {}
        for i, playerName in ipairs(confidantData) do
            if playerName ~= args.user then
                table.insert(newConfidantData, playerName)
            end
        end
        vehicle:getModData().Confidant = newConfidantData
    end
end
Events.OnServerCommand.Add(receiveServerCommandDelete)


function ConfidantCarUI:new(x, y, width, height, player,vehicleForSend) --Создание окна
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
    o.vehicleForSend = vehicleForSend
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

    return o;
end


--#region Функции отрисовки рамки и перемещения

function ConfidantCarUI:prerender()
    self.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    local th = 16
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawTextCentre(getText("IGUI_ConfidantBtn"), self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge);
end
function ConfidantCarUI:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function ConfidantCarUI:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end
function ConfidantCarUI:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end
function ConfidantCarUI:onMouseUp(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x,y)
    end
    ISMouseDrag.dragView = nil
end
function ConfidantCarUI:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end
function ConfidantCarUI:onMouseDownOutside(x, y)
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