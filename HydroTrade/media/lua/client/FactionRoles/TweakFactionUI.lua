require "FactionRoles/FactionRolesClient"
require "FactionRoles/ISFactionOfficersUI"

TweakFactionUI = {
    Original = {
        initialise = ISFactionUI.initialise,
        updateButtons = ISFactionUI.updateButtons,
        render = ISFactionUI.render,
        drawPlayers = ISFactionUI.drawPlayers,
        onClick = ISFactionUI.onClick,
        onRemovePlayerFromFaction = ISFactionUI.onRemovePlayerFromFaction,
        onChangeTitle = ISFactionUI.onChangeTitle,
        onQuitFaction = ISFactionUI.onQuitFaction,
        SyncFaction = ISFactionUI.SyncFaction,
        new = ISFactionUI.new,
        close = ISFactionUI.close,
    },
    AddPlayerOriginal = {
        onClick = ISFactionAddPlayerUI.onClick,
    },
}

local function ensureFactionRoleWidgets(self)
    if self.hydroFactionRolesReady then
        return
    end
    self.hydroFactionRolesReady = true

    local btnHgt2 = getTextManager():getFontHeight(UIFont.Small)
    self.manageOfficers = ISButton:new(self.addPlayer:getRight() + 10, self.addPlayer.y, 70, btnHgt2, getText("IGUI_HydroFactionRoles_Officers"), self, TweakFactionUI.onManageOfficers)
    self.manageOfficers:initialise()
    self.manageOfficers:instantiate()
    self.manageOfficers.borderColor = self.buttonBorderColor
    self.manageOfficers:setWidthToTitle(70)
    self.manageOfficers:setVisible(false)
    self:addChild(self.manageOfficers)
end

function ISFactionUI:initialise()
    TweakFactionUI.Original.initialise(self)
    ensureFactionRoleWidgets(self)
end

function ISFactionUI:new(x, y, width, height, faction, player)
    local o = TweakFactionUI.Original.new(self, x, y, width, height, faction, player)
    HydroFactionRoles.resetUiState()
    if faction then
        HydroFactionRoles.requestRoles(faction:getName())
    end
    return o
end

function ISFactionUI:close()
    HydroFactionRoles.resetUiState()
    TweakFactionUI.Original.close(self)
end

function ISFactionUI:updateButtons()
    TweakFactionUI.Original.updateButtons(self)

    if self.manageOfficers then
        self.manageOfficers:setVisible(HydroFactionRoles.uiState.canManageOfficers or self.isOwner or self.isAdmin)
        self.manageOfficers.enable = self.isOwner or self.isAdmin or HydroFactionRoles.uiState.canManageOfficers
    end

    if HydroFactionRoles.canInvitePlayers(self) then
        self.addPlayer.enable = true
    elseif not self.isOwner and not self.isAdmin then
        self.addPlayer.enable = false
    end
end

function ISFactionUI:render()
    TweakFactionUI.Original.render(self)

    if self.playerList.selected > 0 and self.selectedPlayer then
        if HydroFactionRoles.canRemoveMember(self, self.selectedPlayer) then
            self.removePlayer.enable = true
        else
            self.removePlayer.enable = false
        end
    end
end

function ISFactionUI:drawPlayers(y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, y, self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    local label = item.item.name
    if HydroFactionRoles.isUsernameOfficer(label) then
        label = label .. " [" .. getText("IGUI_HydroFactionRoles_OfficerTag") .. "]"
    end
    self:drawText(label, 10, y + 2, 1, 1, 1, a, self.font)
    return y + self.itemheight
end

function TweakFactionUI.onManageOfficers(ui, button)
    if not ui or not ui.faction then
        return
    end
    ISFactionOfficersUI.Open(ui.faction, ui.player)
end

function ISFactionUI:onClick(button)
    if button.internal == "REMOVE" then
        HydroFactionRoles.notifyFactionCleanup(self.faction:getName())
    end
    TweakFactionUI.Original.onClick(self, button)
end

function ISFactionUI:onRemovePlayerFromFaction(button, player)
    if button.internal == "YES" then
        local ui = button.parent.ui
        if ui and ui.faction and ui.selectedPlayer then
            HydroFactionRoles.requestRemove(ui.faction, ui.selectedPlayer)
        end
        return
    end
    TweakFactionUI.Original.onRemovePlayerFromFaction(button, player)
end

function ISFactionUI:onChangeTitle(button)
    if button.internal == "OK" then
        local oldName = button.parent.faction:getName()
        local newName = button.parent.entry:getText()
        TweakFactionUI.Original.onChangeTitle(button)
        if oldName ~= newName then
            HydroFactionRoles.notifyFactionRename(oldName, newName)
            HydroFactionRoles.requestRoles(newName)
        end
        return
    end
    TweakFactionUI.Original.onChangeTitle(button)
end

function ISFactionUI:onQuitFaction(button)
    if button.internal == "YES" then
        local ui = button.parent.ui
        if ui and ui.faction and ui.player then
            local username = ui.player:getUsername()
            if HydroFactionRoles.isUsernameOfficer(username) then
                HydroFactionRoles.requestSetOfficer(ui.faction:getName(), username, false)
            end
        end
    end
    TweakFactionUI.Original.onQuitFaction(button)
end

function ISFactionUI.SyncFaction(factionName)
    TweakFactionUI.Original.SyncFaction(factionName)
    if ISFactionUI.instance and ISFactionUI.instance:isVisible() then
        HydroFactionRoles.requestRoles(factionName)
    end
end

function ISFactionAddPlayerUI:onClick(button)
    if button.internal == "ADDPLAYER" and not self.changeOwnership then
        if self.selectedPlayer then
            HydroFactionRoles.requestInvite(self.faction, self.selectedPlayer)
            self:setVisible(false)
            self:removeFromUIManager()
            return
        end
    end
    TweakFactionUI.AddPlayerOriginal.onClick(self, button)
end

ISFactionUI.initialise = ISFactionUI.initialise
ISFactionUI.updateButtons = ISFactionUI.updateButtons
ISFactionUI.render = ISFactionUI.render
ISFactionUI.drawPlayers = ISFactionUI.drawPlayers
ISFactionUI.onClick = ISFactionUI.onClick
ISFactionUI.onRemovePlayerFromFaction = ISFactionUI.onRemovePlayerFromFaction
ISFactionUI.onChangeTitle = ISFactionUI.onChangeTitle
ISFactionUI.onQuitFaction = ISFactionUI.onQuitFaction
ISFactionUI.SyncFaction = ISFactionUI.SyncFaction
ISFactionUI.new = ISFactionUI.new
ISFactionUI.close = ISFactionUI.close
ISFactionAddPlayerUI.onClick = ISFactionAddPlayerUI.onClick
