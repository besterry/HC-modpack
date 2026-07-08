if not isClient() then
    return
end

require "FactionRoles/FactionRolesShared"

local MODULE = HydroFactionRoles.MODULE

HydroFactionRoles.uiState = {
    factionName = nil,
    officers = {},
    isOwner = false,
    isOfficer = false,
    canInvite = false,
    canRemove = false,
    canManageOfficers = false,
    loaded = false,
}

function HydroFactionRoles.resetUiState()
    HydroFactionRoles.uiState = {
        factionName = nil,
        officers = {},
        isOwner = false,
        isOfficer = false,
        canInvite = false,
        canRemove = false,
        canManageOfficers = false,
        loaded = false,
    }
end

function HydroFactionRoles.applyRolePayload(payload)
    if not payload or not payload.ok then
        HydroFactionRoles.uiState.loaded = false
        return
    end
    HydroFactionRoles.uiState.factionName = payload.factionName
    HydroFactionRoles.uiState.officers = HydroFactionRoles.officersToSet(payload.officers)
    HydroFactionRoles.uiState.isOwner = payload.isOwner == true
    HydroFactionRoles.uiState.isOfficer = payload.isOfficer == true
    HydroFactionRoles.uiState.canInvite = payload.canInvite == true
    HydroFactionRoles.uiState.canRemove = payload.canRemove == true
    HydroFactionRoles.uiState.canManageOfficers = payload.canManageOfficers == true
    HydroFactionRoles.uiState.loaded = true

    if ISFactionUI.instance and ISFactionUI.instance:isVisible() then
        ISFactionUI.instance:updateButtons()
        if ISFactionOfficersUI.instance and ISFactionOfficersUI.instance:isVisible() then
            ISFactionOfficersUI.instance:populateList()
        end
    end
end

function HydroFactionRoles.requestRoles(factionName)
    if not factionName then
        return
    end
    sendClientCommand(getPlayer(), MODULE, "getRoles", { factionName = factionName })
end

function HydroFactionRoles.requestInvite(faction, targetUsername)
    if not faction or not targetUsername then
        return
    end
    sendClientCommand(getPlayer(), MODULE, "requestInvite", {
        factionName = faction:getName(),
        targetUsername = targetUsername,
    })
end

function HydroFactionRoles.requestRemove(faction, targetUsername)
    if not faction or not targetUsername then
        return
    end
    sendClientCommand(getPlayer(), MODULE, "requestRemove", {
        factionName = faction:getName(),
        targetUsername = targetUsername,
    })
end

function HydroFactionRoles.requestSetOfficer(factionName, username, enabled)
    sendClientCommand(getPlayer(), MODULE, "setOfficer", {
        factionName = factionName,
        username = username,
        enabled = enabled,
    })
end

function HydroFactionRoles.notifyFactionCleanup(factionName)
    if not factionName then
        return
    end
    sendClientCommand(getPlayer(), MODULE, "cleanup", { factionName = factionName })
end

function HydroFactionRoles.notifyFactionRename(oldName, newName)
    if not oldName or not newName or oldName == newName then
        return
    end
    sendClientCommand(getPlayer(), MODULE, "rename", { oldName = oldName, newName = newName })
end

function HydroFactionRoles.isUsernameOfficer(username)
    return HydroFactionRoles.uiState.officers[username] == true
end

function HydroFactionRoles.canRemoveMember(ui, targetUsername)
    if not ui or not targetUsername then
        return false
    end
    if ui.isAdmin then
        return targetUsername ~= ui.faction:getOwner()
    end
    if not HydroFactionRoles.uiState.loaded then
        return ui.isOwner
    end
    if targetUsername == ui.faction:getOwner() then
        return false
    end
    if ui.isOwner then
        return true
    end
    if HydroFactionRoles.uiState.isOfficer then
        return ui.faction:isMember(targetUsername) and not HydroFactionRoles.isUsernameOfficer(targetUsername)
    end
    return false
end

function HydroFactionRoles.canInvitePlayers(ui)
    if not ui then
        return false
    end
    if ui.isAdmin or ui.isOwner then
        return true
    end
    if HydroFactionRoles.uiState.loaded then
        return HydroFactionRoles.uiState.canInvite
    end
    return false
end

Events.OnServerCommand.Add(function(module, command, args)
    if module ~= MODULE then
        return
    end
    args = args or {}

    if command == "onRoles" or command == "onSetOfficer" then
        HydroFactionRoles.applyRolePayload(args)
    elseif command == "onInviteApproved" then
        local faction = Faction.getFaction(args.factionName)
        if faction and args.targetUsername then
            local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_FactionUI_InvitationSent", args.targetUsername), false, nil, nil)
            modal:initialise()
            modal:addToUIManager()
            sendFactionInvite(faction, getPlayer(), args.targetUsername)
        end
    elseif command == "onInviteDenied" then
        local text = getText("IGUI_HydroFactionRoles_InviteDenied")
        if args.reason == "alreadyInFaction" then
            text = getText("IGUI_FactionUI_AlreadyHaveFaction")
        end
        local modal = ISModalDialog:new(0, 0, 350, 150, text, false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    elseif command == "onRemoveApproved" then
        local faction = Faction.getFaction(args.factionName)
        if faction and args.targetUsername then
            faction:removePlayer(args.targetUsername)
            faction:syncFaction()
            if ISFactionUI.instance and ISFactionUI.instance:isVisible() then
                ISFactionUI.instance:populateList()
            end
        end
    elseif command == "onRemoveDenied" then
        local modal = ISModalDialog:new(0, 0, 350, 150, getText("IGUI_HydroFactionRoles_RemoveDenied"), false, nil, nil)
        modal:initialise()
        modal:addToUIManager()
    end
end)
