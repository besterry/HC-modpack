-- Код вшит в файл ISUserPanelUI_New.lua
--[[
local old_ISUserPanelUI_create = ISUserPanelUI.create

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISUserPanelUI:create()
    old_ISUserPanelUI_create(self)
    
    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnGapY = 5
    local x = 0;
    local y = 0;    

    local last_btn = self.children[self.IDMax - 1]
    if last_btn.internal == "CANCEL" then
        last_btn = self.children[self.IDMax - 2]
    end
    local x = 10
    local y = last_btn.y + btnHgt + btnGapY
    

    self.pvpzoneBtn = ISButton:new(x, y, btnWid, btnHgt, getText("IGUI_PlayerMenu"), self, ISUserPanelUI.onOptionMouseDownPM);
    self.pvpzoneBtn.internal = "PMenu";
    self.pvpzoneBtn:initialise();
    self.pvpzoneBtn:instantiate();
    self.pvpzoneBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.pvpzoneBtn);
    y = y + btnHgt + btnGapY

    
    -- print(self.IDMax)
    -- local btn_count = 0
    -- for i in pairs(self.children) do
    --     if i.visible then
    --         btn_count = btn_count + 1
    --     end
    -- end
    -- self.children[#self.children]
    
end

function ISUserPanelUI:onOptionMouseDownPM()
    if PM_ISMenu.instance then
        PM_ISMenu.instance:close()
        PM_ISMenu.instance = nil
    else
        local ui = PM_ISMenu:new(50,50,600,600, getPlayer());
        ui:initialise();
        ui:addToUIManager();
    end
end ]]--