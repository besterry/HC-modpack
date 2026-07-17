--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if not isClient() then return end

TweakISAdminPowerUI = {
    Original = {
        addOption = ISAdminPowerUI.addOption,
        addAdminPowerOptions = ISAdminPowerUI.addAdminPowerOptions,
        onClick = ISAdminPowerUI.onClick,
    }
}

TweakISAdminPowerUI.addAdminPowerOptions = function(self)
    -- При SaveAdminPower первым в tickBox добавляем "Show admin tag".
    -- Original потом делает self.setFunction = {} и добавляет опции через
    -- tickBox:addOption, поэтому их индексы уже 2,3,4...
    -- Нужно только вернуть handler в [1], без повторного сдвига.
    local showAdminTagFunc = nil

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.setFunction = {}

        self:addOption("Show admin tag", ClientTweaker.AdminOptions.GetBool("ShowAdminTag"), function(self, selected)
            ClientTweaker.AdminOptions.SetBool("ShowAdminTag", selected);
        end);

        showAdminTagFunc = self.setFunction[1]
    end

    TweakISAdminPowerUI.Original.addAdminPowerOptions(self)

    if showAdminTagFunc then
        self.setFunction[1] = showAdminTagFunc
    end
end

TweakISAdminPowerUI.onClick = function(self, button)
    TweakISAdminPowerUI.Original.onClick(self, button)

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.player:setShowAdminTag(ClientTweaker.AdminOptions.GetBool("ShowAdminTag"));
        sendPlayerExtraInfo(self.player)
    end
end

TweakISAdminPowerUI.addOption = function(self, text, selected, setFunction)
    if SandboxVars.ServerTweaker.SaveAdminPower then
        local originalFunc = setFunction

        setFunction = function(self1, selected1)
            originalFunc(self1, selected1)

            if text == "Invisible" or text == getText("IGUI_AdminPanel_Invisible") then
                ClientTweaker.AdminOptions.SetBool("Invisible", selected1);
            end

            if text == "God mode" or text == getText("IGUI_AdminPanel_God_mode") then
                ClientTweaker.AdminOptions.SetBool("GodMode", selected1);
            end

            if text == "Ghost mode" or text == getText("IGUI_AdminPanel_Ghost_mode") then
                ClientTweaker.AdminOptions.SetBool("GhostMode", selected1);
            end

            if text == "No Clip" or text == getText("IGUI_AdminPanel_No_Clip") then
                ClientTweaker.AdminOptions.SetBool("NoClip", selected1);
            end

            if text == "Timed Action Instant" or text == getText("IGUI_AdminPanel_Timed_Action_Instant") then
                ClientTweaker.AdminOptions.SetBool("TimedActionInstantCheat", selected1);
            end

            if text == "Unlimited Carry" or text == getText("IGUI_AdminPanel_Unlimited_Carry") then
                ClientTweaker.AdminOptions.SetBool("UnlimitedCarry", selected1);
            end

            if text == "Unlimited Endurance" or text == getText("IGUI_AdminPanel_Unlimited_Endurance") then
                ClientTweaker.AdminOptions.SetBool("UnlimitedEndurance", selected1);
            end

            if text == "Fast Move" or text == getText("IGUI_AdminPanel_Fast_Move") then
                ClientTweaker.AdminOptions.SetBool("FastMove", selected1);
            end

            if text == getText("IGUI_AdminPanel_BuildCheat") then
                ClientTweaker.AdminOptions.SetBool("BuildCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_FarmingCheat") then
                ClientTweaker.AdminOptions.SetBool("FarmingCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_HealthCheat") then
                ClientTweaker.AdminOptions.SetBool("HealthCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MechanicsCheat") then
                ClientTweaker.AdminOptions.SetBool("MechanicsCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MoveableCheat") then
                ClientTweaker.AdminOptions.SetBool("MovablesCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanSeeAll") then
                ClientTweaker.AdminOptions.SetBool("CanSeeAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_NetworkTeleportEnabled") then
                ClientTweaker.AdminOptions.SetBool("NetworkTeleportEnabled", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanHearAll") then
                ClientTweaker.AdminOptions.SetBool("CanHearAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_ZombiesDontAttack") then
                ClientTweaker.AdminOptions.SetBool("ZombiesDontAttack", selected1);
            end

            if text == getText("IGUI_AdminPanel_ShowMPInfos") then
                ClientTweaker.AdminOptions.SetBool("ShowMPInfos", selected1);
            end

            if text == "Brush tool" or text == getText("IGUI_AdminPanel_Brush_tool") then
                ClientTweaker.AdminOptions.SetBool("BrushTool", selected1);
            end
        end
    end

    TweakISAdminPowerUI.Original.addOption(self, text, selected, setFunction)
end

ISAdminPowerUI.addAdminPowerOptions = TweakISAdminPowerUI.addAdminPowerOptions;
ISAdminPowerUI.onClick = TweakISAdminPowerUI.onClick;
ISAdminPowerUI.addOption = TweakISAdminPowerUI.addOption;
