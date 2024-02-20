local old_ISUserPanelUI_create = ISUserPanelUI.create

local old_ISAdminPanelUI_create = ISAdminPanelUI.create

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISAdminPanelUI:create()
    old_ISAdminPanelUI_create(self)
    
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
        self.AutoLootAdminPanelBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_AutoLoot"), self, ISAdminPanelUI.onOptionMouseDownAL);
        self.AutoLootAdminPanelBtn.internal = "AdminAL";
        self.AutoLootAdminPanelBtn:initialise();
        self.AutoLootAdminPanelBtn:instantiate();
        self.AutoLootAdminPanelBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.AutoLootAdminPanelBtn);
        y = y + btnHgt + btnGapY
    end

    local btn_count = 0
    for i in pairs(self.children) do
        btn_count = btn_count + 1
    end
    
end

function ISAdminPanelUI:onOptionMouseDownAL()
    if AutoLootAdminPanel_UI.instance then
        AutoLootAdminPanel_UI.instance:close()
        AutoLootAdminPanel_UI.instance = nil
    else
        local ui = AutoLootAdminPanel_UI:new(50,50,600,600, getPlayer());
        ui:initialise();
        ui:addToUIManager();
    end
end