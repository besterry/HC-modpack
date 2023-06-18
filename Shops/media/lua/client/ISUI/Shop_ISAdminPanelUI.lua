-- Добавление кнопки "Ассортимент магазина" в панель администратора
require "ShopAdminEditUI.lua"

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
        self.pvpzoneBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AdminPanel_ShopEdit"), self, ISAdminPanelUI.onOptionMouseDownShopEdit);
        self.pvpzoneBtn.internal = "SHOPEDIT";
        self.pvpzoneBtn:initialise();
        self.pvpzoneBtn:instantiate();
        self.pvpzoneBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.pvpzoneBtn);
        y = y + btnHgt + btnGapY
    end

    local btn_count = 0
    for i in pairs(self.children) do
        btn_count = btn_count + 1
    end
end

function ISAdminPanelUI:onOptionMouseDownShopEdit()
    local playerNum = getPlayer():getPlayerNum()
    local player = getSpecificPlayer(playerNum)
    ShopUI:show(player,false)
    --ShopAdminEditUI:show(player,false)
end