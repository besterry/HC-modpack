function GetRandomDeviation(value, deviation)
    local min = value - deviation
    local max = value + deviation

    return ZombRand(max - min + 1) + min
end