local main = require "CarTeleportClient"

local CarTeleport_UI = {}
g_CarTeleport_UI = CarTeleport_UI -- TODO: Удалить. Использовалось для дебага


local UI_TITLE = 'CarTeleport_carListTitle'
local UI_COUNTER = 'CarTeleport_carListCounter'
local UI_LIST = 'CarTeleport_carList'
local UI_SELECT = 'CarTeleport_selectAreaBtn'
local UI_RESET = 'CarTeleport_resetBtn'
local UI_CANCEL = 'CarTeleport_cancelBtn'
local UI_COPY = 'CarTeleport_copyBtn'
local UI_PASTE = 'CarTeleport_pasteBtn'
local UI_DEL = 'CarTeleport_deletelBtn'

function CarTeleport_UI.selectArea_btnHandler(button, args)
    local self = args['self'] or {}
    self.selectEnd = false
    self.startPos = nil
    self.endPos = nil
    self.zPos = self.player:getZ()
    self.selectStart = true
end

function CarTeleport_UI.cancel_btnHandler(button, self)
    self:close()
end

function CarTeleport_UI.reset_btnHandler(button, self)
    self:reset()
end

function CarTeleport_UI.copy_btnHandler(button, self)
    print('copy_btnHandler', self.isCarTeleport_UI)
    self:startMove()
end

function CarTeleport_UI.paste_btnHandler(button, self)
    -- self:paste()
    print('paste_btnHandler')
    self:endMove()
end

function CarTeleport_UI:delete_confirmHandler(button)
    if button.internal == 'YES' then
        self:delete()
    end
end

function CarTeleport_UI.delete_btnHandler(button, self)
    local vehicleList = {table.unpack(self.vehicleList)}
    local modal = ISModalDialog:new(
        0, 0, 250, 150, 
        "Permanently remove ".. #vehicleList .. ' cars?', 
        true, self, CarTeleport_UI.delete_confirmHandler, self.player:getPlayerNum()
    )
    modal:initialise()
    modal:addToUIManager()
end

---@return boolean
function CarTeleport_UI:isVisible()
    return self.UI.isUIVisible
end

function CarTeleport_UI:close()
    self:reset()
    return self.UI:close()
end

local highlightArea = function(x1, x2, y1, y2, z, color)
    local cell = getCell()
    for x = x1, x2 do
        for y = y1, y2 do
            local sq = cell:getGridSquare(x, y, z)
            if sq then 
                local floor = sq:getFloor()
                if floor then
                    floor:setHighlighted(true) 
                    if color then
                        if color == 'red' then                            
                            floor:setHighlightColor(1,0,0,1); 
                        end
                        if color == 'green' then                            
                            floor:setHighlightColor(0,1,0,1); 
                        end
                        if color == 'blue' then                            
                            floor:setHighlightColor(0,0,1,1); 
                        end
                        if color == 'yellow' then                            
                            floor:setHighlightColor(1,1,0,1); 
                        end
                    end
                end        
            end
        end
    end
end

local preHighlightArea = function (startX, stopX, startY, stopY, z, color)
    local x1 = math.min(startX, stopX)
    local x2 = math.max(startX, stopX)
    local y1 = math.min(startY, stopY)
    local y2 = math.max(startY, stopY)
    highlightArea(x1, x2, y1, y2, z, color)
end

function CarTeleport_UI:render() -- NOTE: украдено из steamapps\common\ProjectZomboid\media\lua\client\DebugUIs\ISRemoveItemTool.lua
    local self = self.CarTeleport_UI_instance -- HACK: достаём наш инстанс обратно из UI инстанса
    self.base_render(self.UI)
    
    if self.selectStart or self.isMove then 
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        highlightArea(xx, xx, yy, yy, self.zPos, 'yellow')
        -- local sq = getCell():getGridSquare(math.floor(xx), math.floor(yy), self.zPos)
        -- if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) sq:getFloor():setHighlightColor(1,1,0,1);  end
    end
        
    if not self.selectStart and self.selectEnd then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        xx = math.floor(xx)
        yy = math.floor(yy)
        preHighlightArea(xx, self.startPos.x, yy, self.startPos.y, self.zPos, 'yellow')
    elseif self.startPos ~= nil and self.endPos ~= nil then
        preHighlightArea(self.startPos.x, self.endPos.x, self.startPos.y, self.endPos.y, self.zPos, 'red')
    end

    if self.target then
        highlightArea(self.target.x1, self.target.x2, self.target.y1, self.target.y2, self.zPos, 'green')
    end
end

function CarTeleport_UI:onMouseDownOutside(x, y)
    local isOutside = x < 0 or y < 0 or x > self:getWidth() or y > self:getHeight()
    local self = self.CarTeleport_UI_instance -- HACK: достаём наш инстанс обратно из UI инстанса
    self.base_onMouseDownOutside(self.UI, x, y)

    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
    if self.selectStart then
        self.startPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectStart = false
        self.selectEnd = true
    elseif self.selectEnd then
        self.endPos = { x = math.floor(xx), y = math.floor(yy) }
        self.selectEnd = false
        self:renderCarsList()
    end
    if self.isMove and isOutside then
        self.xDif = self.origin.x2 - math.floor(xx)
        self.yDif = self.origin.y2 - math.floor(yy)
        self.target = {
            x1 = self.origin.x1 - self.xDif,
            x2 = self.origin.x2 - self.xDif,
            y1 = self.origin.y1 - self.yDif,
            y2 = self.origin.y2 - self.yDif,
        }
        self.UI[UI_PASTE]:setEnable(true)
    end
end

function CarTeleport_UI:renderCarsList()
    local vehicleList = main.getCarsListByCoord(self.startPos, self.endPos, self.zPos)
    local renderedList = {}
    for k,v in pairs(vehicleList) do
        local carName = getText("IGUI_VehicleName" .. v:getScript():getName())
        table.insert(renderedList, carName..' | sqlId: '..v:getSqlId()..', vehicleId: '..v:getId()..', keyId: '..v:getKeyId())
    end
    self.vehicleList = vehicleList
    self.UI[UI_LIST]:setitems(renderedList)
    self.UI[UI_COUNTER]:setText('number of cars: '..#renderedList)
    self.UI[UI_SELECT]:setEnable(false)
    self.UI[UI_RESET]:setEnable(true)
    self.UI[UI_DEL]:setEnable(true)
    self.UI[UI_COPY]:setEnable(true)
end

function CarTeleport_UI:startMove()
    print('copy')
    self.UI[UI_COPY]:setEnable(false)
    self.UI[UI_DEL]:setEnable(false)
    
    self.origin = {
        x1 = math.min(self.startPos.x, self.endPos.x),
        x2 = math.max(self.startPos.x, self.endPos.x),
        y1 = math.min(self.startPos.y, self.endPos.y),
        y2 = math.max(self.startPos.y, self.endPos.y),
    }
    self.isMove = true
    main.startMove(self.vehicleList)
end

function CarTeleport_UI:endMove()
    self.isMove = false
    print('origin: ', bcUtils.dump(self.origin))
    main.moveCars(self.xDif, self.yDif)
    -- main.sendGetCarList(self.startPos, self.endPos, self.zPos)
end

function CarTeleport_UI:delete()
    main.removeCars(self.vehicleList)
    self:reset()
end

function CarTeleport_UI:reset()
    self.vehicleList = {}
    self.selectStart = false
    self.selectEnd = false
    self.isMove = false
    self.startPos = nil
    self.endPos = nil
    self.origin = nil
    self.target = nil
    self.zPos = 0
    self.xDif = 0
    self.yDif = 0
    self.UI[UI_LIST]:setitems({})
    self.UI[UI_COUNTER]:setText()
    self.UI[UI_SELECT]:setEnable(true)
    self.UI[UI_RESET]:setEnable(false)
    self.UI[UI_COPY]:setEnable(false)
    self.UI[UI_PASTE]:setEnable(false)
    self.UI[UI_DEL]:setEnable(false)
end

function CarTeleport_UI:createUI()
    local UI = NewUI()
    local marginPx = 15
    -- HACK: Не разобрался как нормально наследоваться, поэтому делаем хуки
    self.base_render = UI.render
    self.base_onMouseDownOutside = UI.onMouseDownOutside
    UI.CarTeleport_UI_instance = self -- Записываем self в UI чтоб потом достать в рендере (см `CarTeleport_UI:render`)
    UI.render = self.render
    UI.onMouseDownOutside = self.onMouseDownOutside
    UI:setCollapse(true)

    local addEmpty_helper = function()
        return UI:addEmpty(_,_,_, marginPx)
    end
    
    -- NOTE: формируем UI
    UI:setTitle(getText("IGUI_AdminPanel_CarTeleport_btn"))
    UI:addEmpty()
    UI:nextLine()
    addEmpty_helper()
    UI:addText(UI_TITLE, 'Car List', "Small")
    UI:addEmpty()
    UI:addText(UI_COUNTER, '', "Small", "Right")
    UI:nextLine()
    UI:addEmpty()
    UI:nextLine()
    UI:addScrollList(UI_LIST, {})
    UI:nextLine()
    addEmpty_helper()
    UI:addButton(UI_SELECT, "Select area", self.selectArea_btnHandler);
    addEmpty_helper()
    UI:addButton(UI_RESET, "Reset", self.reset_btnHandler);
    addEmpty_helper()
    UI:addButton(UI_CANCEL, "Cancel", self.cancel_btnHandler);
    addEmpty_helper()
    UI:nextLine()
    UI:addEmpty()
    UI:setLineHeightPixel(marginPx)
    UI:nextLine()
    addEmpty_helper()
    UI:addButton(UI_COPY, "Move", self.copy_btnHandler);
    addEmpty_helper()
    UI:addButton(UI_PASTE, "Put", self.paste_btnHandler);
    addEmpty_helper()
    UI:addButton(UI_DEL, "Remove", self.delete_btnHandler);
    addEmpty_helper()
    UI:nextLine()
    UI:addEmpty()
    UI:setLineHeightPixel(marginPx)
    UI[UI_SELECT]:addArg('self', self) -- NOTE: стандартный способ передачи аргументов (см `CarTeleport_UI.selectArea_btnHandler`)
    UI[UI_CANCEL].args = self -- NOTE: не задокументировано, но работает. Если нужно передать не key-value таблицу, а один аргумент
    UI[UI_RESET].args = self
    UI[UI_COPY].args = self
    UI[UI_PASTE].args = self
    UI[UI_DEL].args = self
    self.UI = UI
    self:reset()
    UI:saveLayout();

end

function CarTeleport_UI:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if CarTeleport_UI.instance then -- NOTE: Делаем что-то типа синглтона. TODO: разобраться как делать нормальные синглтоны
        CarTeleport_UI.instance:close()
    end
    CarTeleport_UI.instance = o;
    o.player = getPlayer()
    o.isCarTeleport_UI = true -- TODO: Удалить. Переменная просто для дебага. Чтоб отличить инстанс UI, от инстанса CarTeleport_UI. Потому что из-за хаков может возникнуть путаница
    self.createUI(o)
    return o
end

-- NOTE: добавляем кнопку в админ панель
local base_ISAdminPanelUI_create = ISAdminPanelUI.create
function ISAdminPanelUI:create()
    base_ISAdminPanelUI_create(self)
    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnGapY = 5
    local x = 0;
    local y = 0;
    
    local last_btn = self.children[self.IDMax - 1]
    if last_btn.internal == "CANCEL" then
        last_btn = self.children[self.IDMax - 2]
    end
    local x = last_btn.x
    local y = last_btn.y + btnHgt + btnGapY
    
    if isAdmin() then
        self.carTeleportBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AdminPanel_CarTeleport_btn"), self, ISAdminPanelUI.carTeleport_btnHandler);
        self.carTeleportBtn.internal = "CAR_TELEPORT";
        self.carTeleportBtn:initialise();
        self.carTeleportBtn:instantiate();
        self.carTeleportBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.carTeleportBtn);
    end
end

-- NOTE: хендлер для кнопки в админпанеле
function ISAdminPanelUI:carTeleport_btnHandler()
    CarTeleport_UI:new()
end

Events.OnCreateUI.Add(function() -- TODO: Удалить. Нужно для дебага. Чтобы просто открывать окно при старте
    CarTeleport_UI:new()
end) 