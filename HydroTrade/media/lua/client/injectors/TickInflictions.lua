local ticks = 0
require "injectors/HT_InjectorStatus"

local function TickInflictions(player)
    local modData = player:getModData()
    local inflictions = modData.inflictions or {}

    --- If all inflictions are processed in one go it may cause huge lag spikes if there are too many effects active at once.
    --- To avoid it, each tick is responsible for processing it's own indexed batch of effects. In this case inflictions are always distributed equally between 60 ticks.
    --- Still not sure if it is a good solution considering the fact that the local tick counter resets on relog.
    local spreadTick = ticks % 60

    for i = #inflictions, 1, -1 do
        if i % 60 == spreadTick then
            local inf = inflictions[i]
            if inf and inf.delay ~= nil and inf.duration ~= nil then
                --- print("Infliction [" .. tostring(inf.func) .. "] #" .. i .. ": " .. tostring(inf.delay) .. " | " .. tostring(inf.duration))

                if inf.delay > 0 then
                    inf.delay = inf.delay - 1
                else
                    inf.duration = inf.duration - 1
                    if inf.duration < 0 then
                        table.remove(inflictions, i)
                    else
                        ApplyEffect(inf, player)
                    end
                end
            end
        end
    end

    modData.inflictions = inflictions

    -- Same cadence as one infliction "second": once every 60 OnPlayerUpdate.
    if spreadTick == 0 and HT_InjectorStatus and HT_InjectorStatus.Tick then
        HT_InjectorStatus.Tick(player)
    end

    ticks = ticks + 1
end

Events.OnPlayerUpdate.Add(TickInflictions)
