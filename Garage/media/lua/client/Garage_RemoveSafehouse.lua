-- local waitingForServerResponse = false -- Состояние ожидания ответа от сервера
-- local function getDataUser()
--     local player = getPlayer()
--     sendClientCommand(player,"Garage","getModDataGarage",{nil})
--     waitingForServerResponse = true -- Устанавливаем флаг ожидания
-- end

-- local original_ISSafehouseUI_onClick1 = ISSafehouseUI.onClick
-- function ISSafehouseUI:onClick(button)
--     if button.internal == "RELEASE" then
--         if not waitingForServerResponse then
--             getDataUser()
--         end
--     else
--         return original_ISSafehouseUI_onClick1(self, button)
--     end
-- end



-- local function receiveServerCommandCreateGarage (module, command, args)--Получение ответа от сервера, есть ли у игрока гараж
--     if module ~= "Garage"  then return; end
--     if command ~= "onGetModData" then return end
--     if args[1] ~= nil then
--         waitingForServerResponse = false -- Сбрасываем флаг ожидания
--         local hasGarage = args[1] or false -- Получаем информацию о наличии гаража        
--         if not hasGarage then -- Если нет гаража
--             -- Если у игрока нет гаража, создаем модальное окно для подтверждения удаления убежища
--             local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_SafehouseUI_ReleaseConfirm", ISSafehouseUI.instance.selectedPlayer), true, nil, ISSafehouseUI.onReleaseSafehouse)
--             modal:initialise()
--             modal:addToUIManager()
--             modal.ui = ISSafehouseUI.instance
--             modal.moveWithMouse = true
--             -- original_ISSafehouseUI_onClick(ISSafehouseUI.instance, {internal="RELEASE"})
--         else
--             getPlayer():Say(getText("IGUI_SafeHouseHasGarage"))
--         end
--     end
-- end
-- Events.OnServerCommand.Add(receiveServerCommandCreateGarage)

-- local function findPlayerSafehouse(player)
--     if not player then return nil end
--     local safehouses = SafeHouse.getSafehouseList()
--     for i=1, safehouses:size() do
--         local safehouse = safehouses:get(i-1)
--         if safehouse:isOwner(player) then
--             return safehouse
--         end
--     end
--     return nil
-- end
