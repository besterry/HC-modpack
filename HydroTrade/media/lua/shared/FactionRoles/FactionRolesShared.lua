HydroFactionRoles = HydroFactionRoles or {}

HydroFactionRoles.MODULE = "HydroFactionRoles"
HydroFactionRoles.MOD_DATA_KEY = "HydroFactionRoles"

function HydroFactionRoles.isAdmin(player)
    return player ~= nil and player:getAccessLevel() ~= "None"
end

function HydroFactionRoles.officersToSet(officers)
    local set = {}
    if officers then
        for i = 1, #officers do
            local name = officers[i]
            if name and name ~= "" then
                set[name] = true
            end
        end
    end
    return set
end

function HydroFactionRoles.setToOfficers(officerSet)
    local list = {}
    if officerSet then
        for name, _ in pairs(officerSet) do
            table.insert(list, name)
        end
        table.sort(list)
    end
    return list
end
