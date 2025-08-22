local Infliction = require("injectors/Infliction")

--- @param iso IsoPlayer
function BuildInjector(iso, settings)
    local inflictions = {}
    for _, infliction in pairs(settings) do
        table.insert(inflictions, Infliction:new(infliction.delay, infliction.duration, infliction.func, unpack(infliction.args)))
    end
    ApplyInflictions(iso, unpack(inflictions))
end