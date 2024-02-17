---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local RIC = require("RespawnInCarMod/RIC_ClientFunctions")
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Events.OnGameBoot.Add(function()
    -----------------------------------------------------------------------------
    local MainScreen_onMenuItemMouseDownMainMenu = MainScreen.onMenuItemMouseDownMainMenu
    function MainScreen.onMenuItemMouseDownMainMenu(item, x, y)
        if item.internal == "EXIT" then RIC.ISQuitGame() end --or item.internal == "QUIT_TO_DESKTOP" 
        MainScreen_onMenuItemMouseDownMainMenu(item, x, y)
    end
    -----------------------------------------------------------------------------
    local MainScreen_onConfirmQuitToDesktop = MainScreen.onConfirmQuitToDesktop
    function MainScreen:onConfirmQuitToDesktop(button)
        if button.internal == "YES" then RIC.ISQuitGame() end
        MainScreen_onConfirmQuitToDesktop(self, button)
    end
    -----------------------------------------------------------------------------
end)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
]]