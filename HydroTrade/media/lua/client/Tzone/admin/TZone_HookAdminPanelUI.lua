-- Хук администратора, добавляющий кнопку для открытия панели TZone
require "TZonePanel.lua"

local old_ISAdminPanelUI_create = ISAdminPanelUI.create -- Сохраняем оригинальную функцию

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small) -- Высота шрифта

function ISAdminPanelUI:create()
    old_ISAdminPanelUI_create(self) -- Вызываем оригинальную функцию
    
    local btnWid = 150 -- Ширина кнопки
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) -- Высота кнопки
    local btnGapY = 5 -- Расстояние между кнопками
    local x = 0; -- Координата x
    local y = 0; -- Координата y

    local last_btn = self.children[self.IDMax - 1] -- Последняя кнопка
    if last_btn.internal == "CANCEL" then
        last_btn = self.children[self.IDMax - 2] -- Кнопка перед последней
    end
    local x = last_btn.x -- Координата x последней кнопки
    local y = last_btn.y + btnHgt + btnGapY -- Координата y последней кнопки
    
    if getAccessLevel() == "admin" then -- Если уровень доступа admin
        self.tzoneBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AdminPanel_TZone"), self, ISAdminPanelUI.onOptionMouseDownTZone); -- Создаем кнопку
        self.tzoneBtn.internal = "TZone"; -- Внутреннее имя кнопки
        self.tzoneBtn:initialise(); -- Инициализируем кнопку
        self.tzoneBtn:instantiate(); -- Создаем кнопку
        self.tzoneBtn.borderColor = self.buttonBorderColor; -- Цвет границы кнопки
        self:addChild(self.tzoneBtn); -- Добавляем кнопку на панель
        y = y + btnHgt + btnGapY -- Увеличиваем координату y на высоту кнопки и отступ
    end

    -- print(self.IDMax)
    local btn_count = 0 -- Счетчик кнопок
    for i in pairs(self.children) do -- Перебираем все кнопки
        btn_count = btn_count + 1 -- Увеличиваем счетчик
    end
    -- self.children[#self.children] -- Последняя кнопка
    
end

function ISAdminPanelUI:onOptionMouseDownTZone() -- Обработчик нажатия на кнопку TZone
    if TZonePanel.instance then -- Если панель уже открыта
        TZonePanel.instance:close() -- Закрываем её
    end
    local ui = TZonePanel:new(50,50,600,600, getPlayer()); -- Создаем новую панель
    ui:initialise(); -- Инициализируем панель
    ui:addToUIManager(); -- Добавляем панель в UI менеджер
end