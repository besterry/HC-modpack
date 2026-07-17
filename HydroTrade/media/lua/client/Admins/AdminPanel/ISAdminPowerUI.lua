--***********************************************************
--**              	  ROBERT JOHNSON                       **
--***********************************************************

if not isClient() then return end

ISAdminPowerUI = ISPanel:derive("ISAdminPowerUI");
ISAdminPowerUI.messages = {};

ISAdminPowerUI.cheatTooltips = {}
ISAdminPowerUI.cheatTooltips["Fast Move"] = "Fast move:\nMove - arrow keys\nFloor Up/Down - PageUp/PageDown keys"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

--************************************************************************--
--** ISAdminPowerUI:initialise
--**
--************************************************************************--

function ISAdminPowerUI:getAccessLevelNumber(level)
    if level == "observer" then
        return 1
    elseif level == "gm" then
        return 2
    elseif level == "moderator" then
        return 3
    else
        return 4
    end
    return 0
end

function ISAdminPowerUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_RadioSave"), self, ISAdminPowerUI.onClick);
    self.ok.internal = "SAVE";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);
    
    self.tickBox = ISTickBox:new(30, 50, 100, FONT_HGT_SMALL + 5, "Admin Powers", self, self.onTicked)
    self.tickBox.backgroundColor.a = 1
    self.tickBox.background = true
    self.tickBox.choicesColor = {r=1, g=1, b=1, a=1}
    self.tickBox.leftMargin = 2
    self.tickBox:setFont(UIFont.Small)
    self:addChild(self.tickBox);

    self.richText = ISRichTextLayout:new(self.width - 30 * 2)
    self.richText.marginLeft = 0
    self.richText.marginTop = 0
    self.richText.marginRight = 0
    self.richText.marginBottom = 0
    self.richText:setText(getText("IGUI_AdminPanel_ShowAdminTag"))
    self.richText:initialise()
    self.richText:paginate()

    self:addAdminPowerOptions()
end

function ISAdminPowerUI:addAdminPowerOptions()
    self.setFunction = {}
    local accessLevel = self:getAccessLevelNumber(getAccessLevel())

    if accessLevel >= SandboxVars.Admins.adminPowerBtn then -- moderator и выше
        self:addOption(getText("IGUI_AdminPanel_Invisible"), self.player:isInvisible(), function(self, selected)
            self.player:setInvisible(selected);
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerGodMode then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_God_mode"), self.player:isGodMod(), function(self, selected)
            self.player:setGodMod(selected);
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerGhostMode then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Ghost_mode"), self.player:isGhostMode(), function(self, selected)
            self.player:setGhostMode(selected);
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerNoClip then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_No_Clip"), self.player:isNoClip(), function(self, selected)
            self.player:setNoClip(selected);
        end);    
    end
    if accessLevel >= SandboxVars.Admins.adminPowerZombiesDontAttack then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_ZombiesDontAttack"), self.player:isZombiesDontAttack(), function(self, selected)
            self.player:setZombiesDontAttack(selected)
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerCanSeeAll then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_CanSeeAll"), self.player:isCanSeeAll(), function(self, selected)
            self.player:setCanSeeAll(selected)
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerCanHearAll then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_CanHearAll"), self.player:isCanHearAll(), function(self, selected)
            self.player:setCanHearAll(selected)
        end);      
    end
    if accessLevel >= SandboxVars.Admins.adminPowerTimedActionInstant then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Timed_Action_Instant"), self.player:isTimedActionInstantCheat(), function(self, selected)
            self.player:setTimedActionInstantCheat(selected);
        end);        
    end
    if accessLevel >= SandboxVars.Admins.adminPowerUnlimitedCarry then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Unlimited_Carry"), self.player:isUnlimitedCarry(), function(self, selected)
            self.player:setUnlimitedCarry(selected);
        end);        
    end
    if accessLevel >= SandboxVars.Admins.adminPowerUnlimitedEndurance then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Unlimited_Endurance"), self.player:isUnlimitedEndurance(), function(self, selected)
            self.player:setUnlimitedEndurance(selected);
        end);        
    end
    if accessLevel >= SandboxVars.Admins.adminPowerFastMove then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Fast_Move"), ISFastTeleportMove.cheat, function(self, selected)
            ISFastTeleportMove.cheat = selected
        end); 
    end
    if accessLevel >= SandboxVars.Admins.adminPowerMovablesCheat then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_MoveableCheat"), ISMoveableDefinitions.cheat, function(self, selected)
            ISMoveableDefinitions.cheat = selected;
            self.player:setMovablesCheat(selected);
        end);        
    end
    if accessLevel >= SandboxVars.Admins.adminPowerBuildCheat then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_BuildCheat"), ISBuildMenu.cheat, function(self, selected)
            ISBuildMenu.cheat = selected;
            self.player:setBuildCheat(selected);
        end);        
    end
    if accessLevel >= SandboxVars.Admins.adminPowerFarmingCheat then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_FarmingCheat"), ISFarmingMenu.cheat, function(self, selected)
            ISFarmingMenu.cheat = selected;
            self.player:setFarmingCheat(selected);
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerMechanicsCheat then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_MechanicsCheat"), ISVehicleMechanics.cheat, function(self, selected)
            ISVehicleMechanics.cheat = selected;
            self.player:setMechanicsCheat(selected);
        end); 
    end
    if accessLevel >= SandboxVars.Admins.adminPowerNetworkTeleportEnabled then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_NetworkTeleportEnabled"), self.player:isNetworkTeleportEnabled(), function(self, selected)
            self.player:setNetworkTeleportEnabled(selected)
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerShowMPInfos then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_ShowMPInfos"), self.player:isShowMPInfos(), function(self, selected)
            self.player:setShowMPInfos(selected)
        end);  
    end
    if accessLevel >= SandboxVars.Admins.adminPowerHealthCheat then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_HealthCheat"), ISHealthPanel.cheat, function(self, selected)
            ISHealthPanel.cheat = selected;
            self.player:setHealthCheat(selected);
        end);
    end
    if accessLevel >= SandboxVars.Admins.adminPowerBrushTool then -- gm и выше
        self:addOption(getText("IGUI_AdminPanel_Brush_tool"), BrushToolManager.cheat, function(self, selected)
            BrushToolManager.cheat = selected
        end);        
    end
    
    self.tickBox:setWidthToFit()
    self:setHeight(self.tickBox:getBottom() + 40 + self.richText:getHeight() + 20 + self.ok:getHeight() + 10)
end

function ISAdminPowerUI:addOption(text, selected, setFunction)
    local n = self.tickBox:addOption(text)
    self.tickBox:setSelected(n, selected)
    self.setFunction[n] = setFunction
end

function ISAdminPowerUI:onTicked(index, selected)
end

function ISAdminPowerUI:render()
    if self.tickBox:isMouseOver() and ISAdminPowerUI.cheatTooltips[self.tickBox.optionsIndex[self.tickBox.mouseOverOption]] ~= nil then
        local text = ISAdminPowerUI.cheatTooltips[self.tickBox.optionsIndex[self.tickBox.mouseOverOption]]
        if not self.tickBox.tooltipUI then
            self.tickBox.tooltipUI = ISToolTip:new()
            self.tickBox.tooltipUI:setOwner(self.tickBox)
            self.tickBox.tooltipUI:setVisible(false)
            self.tickBox.tooltipUI:setAlwaysOnTop(true)
        end
        if not self.tickBox.tooltipUI:getIsVisible() then
            if string.contains(text, "\n") then
                self.tickBox.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
            else
                self.tickBox.tooltipUI.maxLineWidth = 300
            end
            self.tickBox.tooltipUI:addToUIManager()
            self.tickBox.tooltipUI:setVisible(true)
        end
        self.tickBox.tooltipUI.description = text
        self.tickBox.tooltipUI:setX(self.tickBox:getMouseX() + 23)
        self.tickBox.tooltipUI:setY(self.tickBox:getMouseY() + 23)
    else
        if self.tickBox.tooltipUI and self.tickBox.tooltipUI:getIsVisible() then
            self.tickBox.tooltipUI:setVisible(false)
            self.tickBox.tooltipUI:removeFromUIManager()
        end
    end
end

function ISAdminPowerUI:prerender()
    local z = 20;
    local splitPoint = 100;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_AdminPanel_AdminPower"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_AdminPanel_AdminPower")) / 2), z, 1,1,1,1, UIFont.Medium);

    self.richText:render(30, self.ok.y - 20 - self.richText:getHeight(), self)
end

function ISAdminPowerUI:onClick(button)
    if button.internal == "SAVE" then
        if not self.player:isDead() then
            for i=1,#self.tickBox.options do
                local fn = self.setFunction[i]
                if fn then
                    fn(self, self.tickBox:isSelected(i))
                end
            end
            self.player:setShowAdminTag(false);
            for i,v in pairs(self.tickBox.selected) do
                if self.tickBox.selected[i] then
                    self.player:setShowAdminTag(true);
                    break;
                end
            end

            sendPlayerExtraInfo(self.player)
        end
    
        self:setVisible(false);
        self:removeFromUIManager();
    end
end

ISAdminPowerUI.onGameStart = function()
    ISBuildMenu.cheat = getPlayer():isBuildCheat();
    ISFarmingMenu.cheat = getPlayer():isFarmingCheat();
    ISHealthPanel.cheat = getPlayer():isHealthCheat();
    ISMoveableDefinitions.cheat = getPlayer():isMovablesCheat();
    ISVehicleMechanics.cheat = getPlayer():isMechanicsCheat();
end

--************************************************************************--
--** ISAdminPowerUI:new
--**
--************************************************************************--
function ISAdminPowerUI:new(x, y, width, height, player)
    local o = {}
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor = {r=0, g=0, b=0, a=0.8};
    o.width = width;
    o.height = height;
    o.player = player;
    o.moveWithMouse = true;
    ISAdminPowerUI.instance = o;
    return o;
end

Events.OnGameStart.Add(ISAdminPowerUI.onGameStart)
