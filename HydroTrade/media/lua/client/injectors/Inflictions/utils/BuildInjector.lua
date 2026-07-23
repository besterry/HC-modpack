local Infliction = require("injectors/Infliction")
require "injectors/HT_InjectorStatus"

--- @param iso IsoPlayer
--- @param settings table InjectorSettings entry
--- @param injectorId string|nil e.g. "adrenaline" for moodle tracking
function BuildInjector(iso, settings, injectorId)
    local inflictions = {}
    for _, infliction in pairs(settings) do
        table.insert(inflictions, Infliction:new(infliction.delay, infliction.duration, infliction.func, unpack(infliction.args)))
    end
    ApplyInflictions(iso, unpack(inflictions))

    if injectorId and HT_InjectorStatus and HT_InjectorStatus.Register then
        HT_InjectorStatus.Register(iso, injectorId, settings)
    end
end
