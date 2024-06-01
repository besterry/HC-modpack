local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);
ShowKillsUI = {
    Original = {
        create = ISUserPanelUI.create,
    }
}

ShowKillsUI.create = function(self)
    ShowKillsUI.Original.create(self)
        local btnWid = 150
        local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
        local y = 35 + ((btnHgt + 5) * 3) + 20 --70

        self.highlightSafehouse = ISTickBox:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowKills"), self, ShowKillsUI.onShowKillsUI);
        self.highlightSafehouse:initialise();
        self.highlightSafehouse:instantiate();
        self.highlightSafehouse.selected[1] = ClientTweaker.Options.GetBool("Show_Kills");
        self.highlightSafehouse:addOption(getText("IGUI_UserPanel_ShowKills"));
        self.highlightSafehouse.enable = SandboxVars.ServerTweaker.HighlightSafehouse;
        self:addChild(self.highlightSafehouse);
        y = y + btnHgt + 5;
end

function ShowKillsUI:onShowKillsUI(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("Show_Kills", enabled);
    end
end

ISUserPanelUI.create = ShowKillsUI.create;


-- local ShowKills = function(ticks)
--     local character = getPlayer()
--     if not character then
--         return
--     end

--     -- if not SandboxVars.ServerTweaker.HighlightSafehouse then
--     --     return
--     -- end

--     if ClientTweaker.Options.GetBool("Show_Kills") == false then
--         return
--     end

--     local kills = character:getZombieKills();
--     print("Kills: " .. kills)
-- end
-- Events.OnRenderTick.Add(ShowKills);