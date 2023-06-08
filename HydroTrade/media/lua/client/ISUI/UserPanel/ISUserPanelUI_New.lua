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
    self:create();
end

function ISUserPanelUI:setVisible(visible)    
    self.javaObject:setVisible(visible);
end

function ISUserPanelUI:render()
    local z = 20;
    self:drawText(getText("UI_mainscreen_userpanel"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("UI_mainscreen_userpanel")) / 2), z, 1,1,1,1, UIFont.Medium);
    z = z + 30;
    self:updateButtons();
end

function ISUserPanelUI:create()
    local btnWid = 150 --Ширина кнопок
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2) --Высота кнопок    
    local padBottom = 10 --Нижний отступ кнопки

    local y = 70; --Отступ вниз

    self.factionBtn = ISButton:new(10, y, btnWid, btnHgt, getText("UI_userpanel_factionpanel"), self, ISUserPanelUI.onOptionMouseDown);
    self.factionBtn.internal = "FACTIONPANEL";
    self.factionBtn:initialise();
    self.factionBtn:instantiate();
    self.factionBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.factionBtn);
    y = y + btnHgt + 5;

    --Если убежище существует
    if SafeHouse.hasSafehouse(self.player) then
        self.safehouseBtn = ISButton:new(10, y, btnWid, btnHgt, getText("IGUI_SafehouseUI_Safehouse"), self, ISUserPanelUI.onOptionMouseDown);
        self.safehouseBtn.internal = "SAFEHOUSEPANEL";
        self.safehouseBtn:initialise();
        self.safehouseBtn:instantiate();
        self.safehouseBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.safehouseBtn);
        y = y + btnHgt + 5;
    end

    --Кнопка выдачи убежища
    if not SafeHouse.hasSafehouse(self.player) then
        self.createsafehouseBtn = ISButton:new(10, y, btnWid, btnHgt, getText("IGUI_CreatehouseUI_Safehouse"), self, ISUserPanelUI.onOptionMouseDown);
        self.createsafehouseBtn.internal = "CREATESAFEHOUSE";
        self.createsafehouseBtn:initialise();
        self.createsafehouseBtn:instantiate();
        self.createsafehouseBtn.borderColor = self.buttonBorderColor;
        self:addChild(self.createsafehouseBtn);
        y = y + btnHgt + 5;
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

    y = 70;

    self.showConnectionInfo = ISTickBox:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowConnectionInfo"), self, ISUserPanelUI.onShowConnectionInfo);
    self.showConnectionInfo:initialise();
    self.showConnectionInfo:instantiate();
    self.showConnectionInfo.selected[1] = isShowConnectionInfo();
    self.showConnectionInfo:addOption(getText("IGUI_UserPanel_ShowConnectionInfo"));
    self:addChild(self.showConnectionInfo);
    y = y + btnHgt + 5;

    self.showServerInfo = ISTickBox:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowServerInfo"), self, ISUserPanelUI.onShowServerInfo);
    self.showServerInfo:initialise();
    self.showServerInfo:instantiate();
    self.showServerInfo.selected[1] = isShowServerInfo();
    self.showServerInfo:addOption(getText("IGUI_UserPanel_ShowServerInfo"));
    self:addChild(self.showServerInfo);
    y = y + btnHgt + 5;

    self.showPingInfo = ISTickBox:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_UserPanel_ShowPingInfo"), self, ISUserPanelUI.onShowPingInfo);
    self.showPingInfo:initialise();
    self.showPingInfo:instantiate();
    self.showPingInfo.selected[1] = isShowPingInfo();
    self.showPingInfo:addOption(getText("IGUI_UserPanel_ShowPingInfo"));
    self:addChild(self.showPingInfo);
    y = y + btnHgt + 5;

    local width = 0
    for _,child in pairs(self:getChildren()) do
        width = math.max(width, child:getWidth())
    end
    for _,child in pairs(self:getChildren()) do
        child:setWidth(width)
    end

    self:setWidth(10 + width + 20 + width + 10)

    self.cancel = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_btn_close"), self, ISUserPanelUI.onOptionMouseDown);
    self.cancel.internal = "CANCEL";
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = self.buttonBorderColor;
    self:addChild(self.cancel);
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
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    ISUserPanelUI.instance = o
    return o;
end
