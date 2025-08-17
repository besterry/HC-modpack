--
-- User: FD
-- Date: 8/06/23
-- Time: 6:00
--

require "ISUI/ISPanel"
require "ISUI/UserPanel/ISAddSHUI"
require "ISUI/UserPanel/ISCloseZone"
ISUserPanelUI = ISPanel:derive("ISUserPanelUI");

-------------------------------------------------
-- Определение шрифтов
-------------------------------------------------
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

function ISUserPanelUI:initialise()
    ISPanel.initialise(self);
    sandboxZones = luautils.split(SandboxVars.SafeHouseClose["CloseZone"], ";")
    self:create();
end

function ISUserPanelUI:setVisible(visible)    
    self.javaObject:setVisible(visible);
end

function ISUserPanelUI:render()
    -- Рисуем заголовок с улучшенным стилем
    local title = getText("UI_mainscreen_userpanel");
    local titleWidth = getTextManager():MeasureStringX(UIFont.Large, title);
    local titleX = self.width/2 - titleWidth/2;
    
    -- Тень заголовка
    self:drawText(title, titleX + 2, 22, 0.3, 0.3, 0.3, 0.8, UIFont.Large);
    -- Основной текст заголовка
    self:drawText(title, titleX, 20, 0.95, 0.95, 0.95, 1, UIFont.Large);
    
    self:updateButtons();
end

function ISUserPanelUI:create()
    local btnWid = 160 --Увеличиваем ширину кнопок
    local btnHgt = math.max(30, FONT_HGT_SMALL + 8) --Увеличиваем высоту кнопок    
    local padBottom = 15 --Увеличиваем нижний отступ
    local cornerRadius = 8 --Радиус закругления

    local y = 70; --Увеличиваем отступ вниз

    -- Создаем кнопки с улучшенным стилем
    self.factionBtn = ISButton:new(15, y, btnWid, btnHgt, getText("UI_userpanel_factionpanel"), self, ISUserPanelUI.onOptionMouseDown);
    self.factionBtn.internal = "FACTIONPANEL";
    self.factionBtn:initialise();
    self.factionBtn:instantiate();
    self.factionBtn.borderColor = self.buttonBorderColor;
    self.factionBtn.backgroundColor = {r=0.15, g=0.15, b=0.15, a=0.9};
    self.factionBtn.backgroundColorMouseOver = {r=0.25, g=0.25, b=0.25, a=0.95};
    self.factionBtn.backgroundColorPressed = {r=0.35, g=0.35, b=0.35, a=1};
    self:addChild(self.factionBtn);
    y = y + btnHgt + 10;

    --Если убежище существует
    if SafeHouse.hasSafehouse(self.player) then
        self.safehouseBtn = ISButton:new(15, y, btnWid, btnHgt, getText("IGUI_SafehouseUI_Safehouse"), self, ISUserPanelUI.onOptionMouseDown);
        self.safehouseBtn.internal = "SAFEHOUSEPANEL";
        self.safehouseBtn:initialise();
        self.safehouseBtn:instantiate();
        self.safehouseBtn.borderColor = self.buttonBorderColor;
        self.safehouseBtn.backgroundColor = {r=0.15, g=0.15, b=0.15, a=0.9};
        self.safehouseBtn.backgroundColorMouseOver = {r=0.25, g=0.25, b=0.25, a=0.95};
        self.safehouseBtn.backgroundColorPressed = {r=0.35, g=0.35, b=0.35, a=1};
        self:addChild(self.safehouseBtn);
        y = y + btnHgt + 10;
    end

    --Кнопка выдачи убежища
    if not SafeHouse.hasSafehouse(self.player) then
        self.createsafehouseBtn = ISButton:new(15, y, btnWid, btnHgt, getText("IGUI_CreatehouseUI_Safehouse"), self, ISUserPanelUI.onOptionMouseDown);
        self.createsafehouseBtn.internal = "CREATESAFEHOUSE";
        self.createsafehouseBtn:initialise();
        self.createsafehouseBtn:instantiate();
        self.createsafehouseBtn.borderColor = self.buttonBorderColor;
        self.createsafehouseBtn.backgroundColor = {r=0.15, g=0.15, b=0.15, a=0.9};
        self.createsafehouseBtn.backgroundColorMouseOver = {r=0.25, g=0.25, b=0.25, a=0.95};
        self.createsafehouseBtn.backgroundColorPressed = {r=0.35, g=0.35, b=0.35, a=1};
        self:addChild(self.createsafehouseBtn);
        y = y + btnHgt + 10;
    end

    --Если нет фракции
    if not Faction.isAlreadyInFaction(self.player) then
        self.factionBtn.title = getText("IGUI_FactionUI_CreateFaction");
        if not Faction.canCreateFaction(self.player) then
            self.factionBtn.enable = false;
            self.factionBtn.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"));
        end
        self.factionBtn:setWidthToTitle(self.factionBtn.width)
    end

    self.pvpzoneBtn = ISButton:new(15, y, btnWid, btnHgt, getText("IGUI_PlayerMenu"), self, ISUserPanelUI.onOptionMouseDownPM);
    self.pvpzoneBtn.internal = "PMenu";
    self.pvpzoneBtn:initialise();
    self.pvpzoneBtn:instantiate();    
    self.pvpzoneBtn.borderColor = self.buttonBorderColor;
    self.pvpzoneBtn.backgroundColor = {r=0.15, g=0.15, b=0.15, a=0.9};
    self.pvpzoneBtn.backgroundColorMouseOver = {r=0.25, g=0.25, b=0.25, a=0.95};
    self.pvpzoneBtn.backgroundColorPressed = {r=0.35, g=0.35, b=0.35, a=1};
    self:addChild(self.pvpzoneBtn);
    y = y + btnHgt + 10;

    --Сбрасываем Y для чекбоксов (второй столбец)
    y = 85; -- y - это отступ сверху
    
    y = y + 70 + 10;

    -- Улучшенные чекбоксы с правильным выравниванием
    self.showPingInfo = ISTickBox:new(15 + btnWid + 30, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowPingInfo"), self, ISUserPanelUI.onShowPingInfo);
    self.showPingInfo:initialise();
    self.showPingInfo:instantiate();
    self.showPingInfo.selected[1] = isShowPingInfo();
    self.showPingInfo:addOption(getText("IGUI_UserPanel_ShowPingInfo"));
    self.showPingInfo.backgroundColor = {r=0.12, g=0.12, b=0.12, a=0.8};
    self.showPingInfo.borderColor = {r=0.6, g=0.6, b=0.6, a=0.7};
    self:addChild(self.showPingInfo);

    y = y  + 5 - btnHgt;

    self.showkills = ISTickBox:new(15 + btnWid + 30, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowKills"), self, ISUserPanelUI.onShowKillsUI);
    self.showkills:initialise();
    self.showkills:instantiate();
    self.showkills.selected[1] = ClientTweaker.Options.GetBool("Show_Kills");
    self.showkills:addOption(getText("IGUI_UserPanel_ShowKills"));
    self.showkills.enable = true;
    self.showkills.backgroundColor = {r=0.12, g=0.12, b=0.12, a=0.8};
    self.showkills.borderColor = {r=0.6, g=0.6, b=0.6, a=0.7};
    self:addChild(self.showkills);
    y = y + 5 - btnHgt;

    self.highlightSafehouse = ISTickBox:new(15 + btnWid + 30, y, btnWid, btnHgt, getText("IGUI_UserPanel_HighlightSafehouse"), self, ISUserPanelUI.onHighlightSafehouse);
    self.highlightSafehouse:initialise();
    self.highlightSafehouse:instantiate();
    self.highlightSafehouse.selected[1] = ClientTweaker.Options.GetBool("highlight_safehouse");
    self.highlightSafehouse:addOption(getText("IGUI_UserPanel_HighlightSafehouse"));
    self.highlightSafehouse.enable = SandboxVars.ServerTweaker.HighlightSafehouse;
    self.highlightSafehouse.backgroundColor = {r=0.12, g=0.12, b=0.12, a=0.8};
    self.highlightSafehouse.borderColor = {r=0.6, g=0.6, b=0.6, a=0.7};
    self:addChild(self.highlightSafehouse);
    y = y  + 5 - btnHgt;

    local width = 0
    for _,child in pairs(self:getChildren()) do
        width = math.max(width, child:getWidth())
    end
    for _,child in pairs(self:getChildren()) do
        child:setWidth(width)
    end

    self:setWidth(15 + width + 30 + width + 15)

    -- Улучшенная кнопка закрытия
    self.cancel = ISButton:new((self:getWidth() / 2) - (btnWid / 2), self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_btn_close"), self, ISUserPanelUI.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=0.8, g=0.3, b=0.3, a=0.8};
    self.cancel.backgroundColor = {r=0.2, g=0.1, b=0.1, a=0.9};
    self.cancel.backgroundColorMouseOver = {r=0.3, g=0.15, b=0.15, a=0.95};
    self.cancel.backgroundColorPressed = {r=0.4, g=0.2, b=0.2, a=1};
    self:addChild(self.cancel);
end

function ISUserPanelUI:onHighlightSafehouse(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("highlight_safehouse", enabled);
    end
end

function ISUserPanelUI:onShowKillsUI(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("Show_Kills", enabled);
    end
end

function ISUserPanelUI:onOptionMouseDownPM()
    if PM_ISMenu.instance then
        PM_ISMenu.instance:close()
        PM_ISMenu.instance = nil
    else
        local ui = PM_ISMenu:new(50,50,380,420, getPlayer());
        ui:initialise();
        ui:addToUIManager();
    end
end

function ISUserPanelUI:onShowConnectionInfo(option, enabled)
    setShowConnectionInfo(enabled);
end

function ISUserPanelUI:onShowServerInfo(option, enabled)
    setShowServerInfo(enabled);
end

function ISUserPanelUI:onShowPingInfo(option, enabled)
    setShowPingInfo(enabled);
end

function ISUserPanelUI:updateButtons()
    if not Faction.isAlreadyInFaction(self.player) then
        self.factionBtn.title = getText("IGUI_FactionUI_CreateFaction");
        if not Faction.canCreateFaction(self.player) then
            self.factionBtn.enable = false;
            self.factionBtn.tooltip = getText("IGUI_FactionUI_FactionSurvivalDay", getServerOptions():getInteger("FactionDaySurvivedToCreate"));
        end
    else
        self.factionBtn.title = getText("UI_userpanel_factionpanel");
    end
end

function ISUserPanelUI:onOptionMouseDown(button, x, y)
    
    --Открытие окна выдачи персонального убежища
    if button.internal == "CREATESAFEHOUSE" then
        if ISAddSHUI.instance then
            ISAddSHUI.instance:close();
        end
        --Проверка отображения кнопки, если убежище уже есть
        if SafeHouse.hasSafehouse(self.player) then
            self.createsafehouseBtn:setVisible(false)
            return;
        end
        --Проверка на запретную зону
		local x = math.floor((getPlayer():getX()) / 100)
		local y = math.floor((getPlayer():getY()) / 100)
		if FDSE.checkTownZones(x, y) then
			getPlayer():Say(getText('IGUI_Close_Zone'))
			return;
		end
        --Открытие окна создания убежища, закрытие окна
        local ui = ISAddSHUI:new(getCore():getScreenWidth() / 2 - 210, getCore():getScreenHeight() / 2 - 200, 420, 400, getPlayer());
        ui:initialise();
        ui:addToUIManager();
        self:close()
    end
    
    if button.internal == "SAFEHOUSEPANEL" then
        if SafeHouse.hasSafehouse(self.player) then
            local modal = ISSafehouseUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, SafeHouse.hasSafehouse(self.player), self.player);
            modal:initialise();
            modal:addToUIManager();
        end
    end

    if button.internal == "FACTIONPANEL" then
        if ISFactionUI.instance then
            ISFactionUI.instance:close()
        end
        if ISCreateFactionUI.instance then
            ISCreateFactionUI.instance:close()
        end
        if Faction.isAlreadyInFaction(self.player) then
            local modal = ISFactionUI:new(getCore():getScreenWidth() / 2 - 250, getCore():getScreenHeight() / 2 - 225, 500, 450, Faction.getPlayerFaction(self.player), self.player);
            modal:initialise();
            modal:addToUIManager();
        else
            local modal = ISCreateFactionUI:new(self.x + 100, self.y + 100, 350, 250, self.player)
            modal:initialise();
            modal:addToUIManager();
        end
    end

    if button.internal == "CANCEL" then
        self:close()
    end
end

function ISUserPanelUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    ISUserPanelUI.instance = nil;
end

function ISUserPanelUI:new(x, y, width, height, player)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    self.player = player;
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1};
    o.borderColor = {r=0.7, g=0.7, b=0.7, a=0.9};
    o.backgroundColor = {r=0.05, g=0.05, b=0.05, a=0.98};
    o.buttonBorderColor = {r=0.9, g=0.9, b=0.9, a=0.8};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    ISUserPanelUI.instance = o
    return o;
end
