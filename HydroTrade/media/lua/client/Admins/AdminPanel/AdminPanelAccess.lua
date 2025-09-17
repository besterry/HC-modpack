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
    self.dbBtn.enable = accessLevel >= SandboxVars.Admins.dbBtn --кнопка "См. базу данных" 3
    self.checkStatsBtn.enable = accessLevel >= SandboxVars.Admins.checkStatsBtn --кнопка "Ваша статистика" 1
    self.adminPowerBtn.enable = accessLevel >= SandboxVars.Admins.adminPowerBtn --кнопка "Изменение адм. сил" 2
    self.itemListBtn.enable = accessLevel >= SandboxVars.Admins.itemListBtn --кнопка "Список предметов" 2
    self.seeOptionsBtn.enable = accessLevel == SandboxVars.Admins.seeOptionsBtn --кнопка "Настройки сервера" 4
    if self.nonpvpzoneBtn then self.nonpvpzoneBtn.enable = accessLevel >= SandboxVars.Admins.nonpvpzoneBtn end --кнопка "Не-PvP зоны" (только для admin) 4
    self.seeFactionBtn.enable = accessLevel >= SandboxVars.Admins.seeFactionBtn --кнопка "Список фракций" 3
    self.seeSafehousesBtn.enable = accessLevel >= SandboxVars.Admins.seeSafehousesBtn --кнопка "Список убежищ" 3
    self.safezoneBtn.enable = accessLevel >= SandboxVars.Admins.safezoneBtn --кнопка "Добавить убежище" 3
    self.seeTicketsBtn.enable = accessLevel == SandboxVars.Admins.seeTicketsBtn --кнопка "Просмотреть сообщения" 4
    self.miniScoreboardBtn.enable = accessLevel >= SandboxVars.Admins.miniScoreboardBtn --кнопка "Мини-табло" 2
    self.packetCountsBtn.enable = accessLevel >= SandboxVars.Admins.packetCountsBtn --кнопка "Количество пакетов" 3
    self.sandboxOptionsBtn.enable = accessLevel == SandboxVars.Admins.sandboxOptionsBtn --кнопка "Настройки песочницы" 4
    self.climateOptionsBtn.enable = accessLevel == SandboxVars.Admins.climateOptionsBtn --кнопка "Контроль климата" 4
    self.showStatisticsBtn.enable = accessLevel >= SandboxVars.Admins.showStatisticsBtn --кнопка "Показать статистику" 2
end

function ISAdminPanelUI:create()
    old_ISAdminPanelUI_create(self)
    setAccessLevel(self, getAccessLevel())
end

function ISAdminPanelUI:updateButtons()
    old_ISAdminPanelUI_updateButtons(self)
    setAccessLevel(self, getAccessLevel())
end