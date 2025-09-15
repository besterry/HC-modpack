--хук для админ панели
local old_ISAdminPanelUI_create = ISAdminPanelUI.create
local old_ISAdminPanelUI_updateButtons = ISAdminPanelUI.updateButtons

local function getAccessLevelNumber(level)
    if level == "observer" then
        return 1
    elseif level == "gm" then
        return 2
    elseif level == "moderator" then
        return 3
    elseif level == "admin" then
        return 4
    end
    return 0
end

local function setAccessLevel(self, level)
    local accessLevel = getAccessLevelNumber(level)
    
    -- Базовые настройки для всех уровней
    self.dbBtn.enable = accessLevel >= 3 --кнопка "См. базу данных"
    self.checkStatsBtn.enable = accessLevel >= 1 --кнопка "Ваша статистика"
    self.adminPowerBtn.enable = accessLevel >= 2 --кнопка "Изменение адм. сил"
    self.itemListBtn.enable = accessLevel >= 2 --кнопка "Список предметов"
    self.seeOptionsBtn.enable = accessLevel == 4 --кнопка "Настройки сервера"
    if self.nonpvpzoneBtn then self.nonpvpzoneBtn.enable = accessLevel >= 4 end --кнопка "Не-PvP зоны" (только для admin)
    self.seeFactionBtn.enable = accessLevel >= 3 --кнопка "Список фракций"
    self.seeSafehousesBtn.enable = accessLevel >= 3 --кнопка "Список убежищ"
    self.safezoneBtn.enable = accessLevel >= 3 --кнопка "Добавить убежище"
    self.seeTicketsBtn.enable = accessLevel == 4 --кнопка "Просмотреть сообщения"
    self.miniScoreboardBtn.enable = accessLevel >= 2 --кнопка "Мини-табло"
    self.packetCountsBtn.enable = accessLevel >= 3 --кнопка "Количество пакетов"
    self.sandboxOptionsBtn.enable = accessLevel == 4 --кнопка "Настройки песочницы"
    self.climateOptionsBtn.enable = accessLevel == 4 --кнопка "Контроль климата"
    self.showStatisticsBtn.enable = accessLevel >= 2 --кнопка "Показать статистику"
end

function ISAdminPanelUI:create()
    old_ISAdminPanelUI_create(self)
    setAccessLevel(self, getAccessLevel())
end

function ISAdminPanelUI:updateButtons()
    old_ISAdminPanelUI_updateButtons(self)
    setAccessLevel(self, getAccessLevel())
end