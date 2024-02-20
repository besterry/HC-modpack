-- local old_ISUserPanelUI_create = ISUserPanelUI.create

-- local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

-- function ISUserPanelUI:create()
--     old_ISUserPanelUI_create(self)
    
--     local btnWid = 150
--     local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
--     local btnGapY = 5
--     local x = 0;
--     local y = 0;
    
--     local last_btn = self.children[self.IDMax - 1]
--     if last_btn.internal == "CANCEL" then
--         last_btn = self.children[self.IDMax - 2]
--     end
--     local x = 10
--     local y = 30+last_btn.y + btnHgt + btnGapY
    

--     self.autolootbtn = ISButton:new(x, y, btnWid, btnHgt, getText("AutoLoot"), self, ISUserPanelUI.onOptionMouseDownAL);
--     self.autolootbtn.internal = "ALoot";
--     self.autolootbtn:initialise();
--     self.autolootbtn:instantiate();
--     self.autolootbtn.borderColor = self.buttonBorderColor;
--     self:addChild(self.autolootbtn);
--     y = y + btnHgt + btnGapY

    
--     -- print(self.IDMax)
--     local btn_count = 0
--     for i in pairs(self.children) do
--         btn_count = btn_count + 1
--     end
--     -- self.children[#self.children]
    
-- end

-- function ISUserPanelUI:onOptionMouseDownAL()
--     local ui = UI_AutoLoot:new(50,50,400,250, getPlayer());
--     ui:initialise();
--     ui:addToUIManager();
-- end