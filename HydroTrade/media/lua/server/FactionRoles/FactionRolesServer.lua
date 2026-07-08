if not isServer() then
    return
end
require "FactionRoles/FactionRolesShared"

local MODULE = HydroFactionRoles.MODULE
local MOD_DATA_KEY = HydroFactionRoles.MOD_DATA_KEY

local function getStore()
    return ModData.getOrCreate(MOD_DATA_KEY)
end

local function persistStore()
    -- Важно: многие моды HydroTrade сохраняют ModData через ModData.add + transmit.
    -- Без этого значения могут не переживать перезапуск сервера.
    ModData.add(MOD_DATA_KEY, getStore())
    ModData.transmit(MOD_DATA_KEY)
end

local function getFactionEntry(factionName)
    local store = getStore()
    if not store[factionName] then
        store[factionName] = { officers = {} }
    elseif not store[factionName].officers then
        store[factionName].officers = {}
    end
    return store[factionName]
end

local function getOfficerList(factionName)
    local entry = getStore()[factionName]
    if not entry or not entry.officers then
        return {}
    end
    return entry.officers
end

local function isOfficer(factionName, username)
    if not factionName or not username or username == "" then
        return false
    end
    local officers = getOfficerList(factionName)
    for i = 1, #officers do
        if officers[i] == username then
            return true
        end
    end
    return false
end

local function getFactionByName(factionName)
    if not factionName then
        return nil
    end
    return Faction.getFaction(factionName)
end

local function playerInFaction(player, faction)
    if not player or not faction then
        return false
    end
    local username = player:getUsername()
    return faction:isOwner(username) or faction:isMember(username)
end

local function isOwner(player, faction)
    return player and faction and faction:isOwner(player:getUsername())
end

local function canInvite(player, faction)
    if not player or not faction then
        return false
    end
    if HydroFactionRoles.isAdmin(player) then
        return true
    end
    local username = player:getUsername()
    return faction:isOwner(username) or isOfficer(faction:getName(), username)
end

local function canRemoveMember(player, faction, targetUsername)
    if not player or not faction or not targetUsername then
        return false
    end
    if targetUsername == faction:getOwner() then
        return false
    end
    if HydroFactionRoles.isAdmin(player) then
        return true
    end
    local username = player:getUsername()
    if faction:isOwner(username) then
        return true
    end
    if isOfficer(faction:getName(), username) then
        return faction:isMember(targetUsername) and not isOfficer(faction:getName(), targetUsername)
    end
    return false
end

local function canManageOfficers(player, faction)
    if not player or not faction then
        return false
    end
    return HydroFactionRoles.isAdmin(player) or faction:isOwner(player:getUsername())
end

local function removeOfficerFromStore(factionName, username)
    local store = getStore()
    local entry = store[factionName]
    if not entry or not entry.officers then
        return
    end
    local officers = entry.officers
    for i = #officers, 1, -1 do
        if officers[i] == username then
            table.remove(officers, i)
        end
    end
    if #officers == 0 then
        store[factionName] = nil
    end
end

local function reply(player, command, payload)
    sendServerCommand(player, MODULE, command, payload or {})
end

local function buildRolePayload(player, faction)
    local factionName = faction:getName()
    local username = player:getUsername()
    local officers = getOfficerList(factionName)
    local owner = isOwner(player, faction)
    local officer = owner or isOfficer(factionName, username)
    return {
        factionName = factionName,
        officers = officers,
        isOwner = owner,
        isOfficer = officer,
        canInvite = canInvite(player, faction),
        canRemove = owner or officer or HydroFactionRoles.isAdmin(player),
        canManageOfficers = canManageOfficers(player, faction),
    }
end

local Commands = {}

Commands.getRoles = function(player, args)
    args = args or {}
    local faction = getFactionByName(args.factionName)
    if not faction or not playerInFaction(player, faction) then
        reply(player, "onRoles", { ok = false })
        return
    end
    local payload = buildRolePayload(player, faction)
    payload.ok = true
    reply(player, "onRoles", payload)
end

Commands.setOfficer = function(player, args)
    args = args or {}
    local factionName = args.factionName
    local targetUsername = args.username
    local enabled = args.enabled == true
    local faction = getFactionByName(factionName)
    if not faction or not canManageOfficers(player, faction) then
        reply(player, "onSetOfficer", { ok = false, reason = "denied" })
        return
    end
    if not targetUsername or targetUsername == "" or targetUsername == faction:getOwner() then
        reply(player, "onSetOfficer", { ok = false, reason = "invalid" })
        return
    end
    if not faction:isMember(targetUsername) then
        reply(player, "onSetOfficer", { ok = false, reason = "notMember" })
        return
    end

    local entry = getFactionEntry(factionName)
    local officers = entry.officers
    local found = false
    for i = #officers, 1, -1 do
        if officers[i] == targetUsername then
            found = true
            if not enabled then
                table.remove(officers, i)
            end
        end
    end
    if enabled and not found then
        table.insert(officers, targetUsername)
    end
    table.sort(officers)

    if #officers == 0 then
        getStore()[factionName] = nil
    end

    persistStore()

    local payload = buildRolePayload(player, faction)
    payload.ok = true
    payload.username = targetUsername
    payload.enabled = enabled
    reply(player, "onSetOfficer", payload)
end

Commands.requestInvite = function(player, args)
    args = args or {}
    local faction = getFactionByName(args.factionName)
    local targetUsername = args.targetUsername
    if not faction or not targetUsername or targetUsername == "" then
        reply(player, "onInviteDenied", { reason = "invalid" })
        return
    end
    if not canInvite(player, faction) then
        reply(player, "onInviteDenied", { reason = "denied" })
        return
    end
    if Faction.isAlreadyInFaction(targetUsername) then
        reply(player, "onInviteDenied", { reason = "alreadyInFaction" })
        return
    end
    reply(player, "onInviteApproved", {
        factionName = faction:getName(),
        targetUsername = targetUsername,
    })
end

Commands.requestRemove = function(player, args)
    args = args or {}
    local faction = getFactionByName(args.factionName)
    local targetUsername = args.targetUsername
    if not faction or not targetUsername or targetUsername == "" then
        reply(player, "onRemoveDenied", { reason = "invalid" })
        return
    end
    if not canRemoveMember(player, faction, targetUsername) then
        reply(player, "onRemoveDenied", { reason = "denied" })
        return
    end
    removeOfficerFromStore(faction:getName(), targetUsername)
    persistStore()
    reply(player, "onRemoveApproved", {
        factionName = faction:getName(),
        targetUsername = targetUsername,
    })
end

Commands.cleanup = function(player, args)
    args = args or {}
    local factionName = args.factionName
    if not factionName or factionName == "" then
        return
    end
    getStore()[factionName] = nil
    persistStore()
end

Commands.rename = function(player, args)
    args = args or {}
    local oldName = args.oldName
    local newName = args.newName
    if not oldName or not newName or oldName == "" or newName == "" or oldName == newName then
        return
    end
    local faction = getFactionByName(newName)
    if not faction or not canManageOfficers(player, faction) then
        return
    end
    local store = getStore()
    if store[oldName] then
        store[newName] = store[oldName]
        store[oldName] = nil
        persistStore()
    end
end

Events.OnInitGlobalModData.Add(function()
    ModData.getOrCreate(MOD_DATA_KEY)
    ModData.transmit(MOD_DATA_KEY)
end)

Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= MODULE or not player then
        return
    end
    local handler = Commands[command]
    if handler then
        handler(player, args)
    end
end)
