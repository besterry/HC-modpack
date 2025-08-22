function ApplyInflictions(player, ...)
    local modData = player:getModData()
    local inflictions = modData.inflictions or {}

    for _, infliction in ipairs({...}) do
        table.insert(inflictions, infliction)
    end

    modData.inflictions = inflictions
end