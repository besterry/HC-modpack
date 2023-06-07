-- Добавление кнопки "Зона с PVP" в панель администратора
require "PVPE_ISPvpZonePanel.lua"

local old_ISAdminPanelUI_create = ISAdminPanelUI.create

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISAdminPanelUI:create()
    old_ISAdminPanelUI_create(self)
    
    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnGapY = 5
    local x = 0;
    local y = 0;
    
    -- 12 кнопок в ряд
    -- Последняя кнопка - закрыть
    local last_btn = self.children[self.IDMax - 1]
    if last_btn.internal == "CANCEL" then
        last_btn = self.children[self.IDMax - 2]
    end
    local x = last_btn.x
    local y = last_btn.y + btnHgt + btnGapY
    
    if getAccessLevel() == "admin" then
        self.pvpzoneBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AdminPanel_PvpZone"), self, ISAdminPanelUI.onOptionMouseDownPVP);
        self.pvpzoneBtn.internal = "PVPZONE";
        self.pvpzoneBtn:initialise();
        self.pvpzoneBtn:instantiate();
        self.pvpzoneBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.pvpzoneBtn);
        y = y + btnHgt + btnGapY
    end
    
    -- print(self.IDMax)
    local btn_count = 0
    for i in pairs(self.children) do
        btn_count = btn_count + 1
    end
    -- self.children[#self.children]
    
end

function ISAdminPanelUI:onOptionMouseDownPVP()
    if PVPE_ISPvpZonePanel.instance then
        PVPE_ISPvpZonePanel.instance:close()
    end
    local ui = PVPE_ISPvpZonePanel:new(50,50,600,600, getPlayer());
    ui:initialise();
    ui:addToUIManager();
end