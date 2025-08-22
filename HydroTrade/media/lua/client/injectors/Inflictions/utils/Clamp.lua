function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

function LeftClamp(value, min)
    if value < min then
        return min
    else
        return value
    end
end

function RightClamp(value, max)
    if value > max then
        return max
    else
        return value
    end
end