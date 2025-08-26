-- Блокировка снятия/установки деталей для автомобилей на продаже
-- Позволяет просматривать автомеханику, но блокирует действия

-- Подключаем необходимые модули
require "shared/CarShop_utils"

local old_ISVehicleMechanics_doPartContextMenu = ISVehicleMechanics.doPartContextMenu

function ISVehicleMechanics:doPartContextMenu(part, x, y)
    -- Сначала вызываем оригинальную функцию для создания базового меню
    old_ISVehicleMechanics_doPartContextMenu(self, part, x, y)
    if isAdmin() then return end -- Админам не блокируем
    -- Проверяем, находится ли автомобиль на продаже
    local vehicle = part:getVehicle()
    if not vehicle then return end
    
    -- Создаем CarUtils для проверки статуса продажи
    local carInfo = CarShop.CarUtils:initByVehicle(vehicle)
    if not carInfo or not carInfo:isCarOnSale() then return end
    
    -- Если автомобиль на продаже, блокируем все действия
    if self.context then
        for i = self.context.numOptions, 1, -1 do
            local option = self.context.options[i]
            if option then
                -- Блокируем все опции
                option.notAvailable = true
                if option.toolTip then
                    option.toolTip.description = (option.toolTip.description or "") .. " <LINE><RGB:1,0,0>" .. getText("IGUI_CarShop_Block_CarOnSale")
                end
            end
        end
    end
end