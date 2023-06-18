local CarTeleport_UI = {}
g_CarTeleport_UI = CarTeleport_UI -- TODO: Удалить. Использовалось для дебага

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

---@return boolean
function CarTeleport_UI:isVisible()
    return self.UI.isUIVisible
end

function CarTeleport_UI:close()
    return self.UI:close()
end

function CarTeleport_UI:render() -- NOTE: украдено из steamapps\common\ProjectZomboid\media\lua\client\DebugUIs\ISRemoveItemTool.lua
    local self = self.CarTeleport_UI_instance -- HACK: достаём наш инстанс обратно из UI инстанса
    self.base_render(self.UI)
    
    if self.selectStart then 
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        local sq = getCell():getGridSquare(math.floor(xx), math.floor(yy), self.zPos)
        if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end
    elseif self.selectEnd then
        local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), self.zPos)
        xx = math.floor(xx)
        yy = math.floor(yy)
        local cell = getCell()
        local x1 = math.min(xx, self.startPos.x)
        local x2 = math.max(xx, self.startPos.x)
        local y1 = math.min(yy, self.startPos.y)
        local y2 = math.max(yy, self.startPos.y)
        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end
            end
        end
    elseif self.startPos ~= nil and self.endPos ~= nil then
        local cell = getCell()
        local x1 = math.min(self.startPos.x, self.endPos.x)
        local x2 = math.max(self.startPos.x, self.endPos.x)
        local y1 = math.min(self.startPos.y, self.endPos.y)
        local y2 = math.max(self.startPos.y, self.endPos.y)
        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, self.zPos)
                if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end
            end
        end
    end
end

function CarTeleport_UI:onMouseDownOutside(x, y)
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
    end
end

function CarTeleport_UI:createUI()
    print('CarTeleport_UI:createUI isCarTeleport_UI', self.isCarTeleport_UI)
    self.UI = NewUI()
    local UI = self.UI

    -- HACK: Не разобрался как нормально наследоваться, поэтому делаем хуки
    self.base_render = UI.render
    self.base_onMouseDownOutside = UI.onMouseDownOutside
    UI.CarTeleport_UI_instance = self -- Записываем self в UI чтоб потом достать в рендере (см `CarTeleport_UI:render`)
    UI.render = self.render
    UI.onMouseDownOutside = self.onMouseDownOutside
    
    -- NOTE: формируем UI
    UI:addText("CarTeleport_title", getText("IGUI_AdminPanel_CarTeleport_btn"), "Title", "Center")
    UI:nextLine();
    UI:addButton("CarTeleport_selectArea_btn", "SelectArea", self.selectArea_btnHandler);
    UI:addButton("CarTeleport_cancel_btn", "Cancel", self.cancel_btnHandler);
    UI['CarTeleport_cancel_btn'].args = self -- NOTE: не задокументировано, но работает. Если нужно передать не key-value таблицу, а один аргумент
    UI['CarTeleport_selectArea_btn']:addArg('self', self) -- NOTE: стандартный способ передачи аргументов (см `CarTeleport_UI.selectArea_btnHandler`)
    UI:saveLayout();
    
end

function CarTeleport_UI:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if CarTeleport_UI.instance then -- NOTE: Делаем что-то типа синглтона. TODO: разобраться как делать нормальные синглтоны
        CarTeleport_UI.instance:close()
    end
    CarTeleport_UI.instance = o; -- NOTE: Статичное поле. 
    o.player = getPlayer()
    o.selectStart = false
    o.selectEnd = false
    o.startPos = nil
    o.endPos = nil
    o.zPos = 0
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
    
    if getAccessLevel() == "admin" then
        self.carTeleportBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AdminPanel_CarTeleport_btn"), self, ISAdminPanelUI.carTeleport_btnHandler);
        self.carTeleportBtn.internal = "CAR_TELEPORT";
        self.carTeleportBtn:initialise();
        self.carTeleportBtn:instantiate();
        self.carTeleportBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.carTeleportBtn);
        -- y = y + btnHgt + btnGapY
    end
end

-- NOTE: хендлер для кнопки в админпанеле
function ISAdminPanelUI:carTeleport_btnHandler()
    if CarTeleport_UI.instance then
        CarTeleport_UI.instance:close()
    end
    CarTeleport_UI:new()
end

Events.OnCreateUI.Add(function() -- TODO: Удалить
    CarTeleport_UI:new()
end) 