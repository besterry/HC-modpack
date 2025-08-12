if not isServer() then return end

-- Получаем текущее состояние
local Power = getSandboxOptions():getOptionByName("ElecShutModifier"):getValue() > -1
local Water = getSandboxOptions():getOptionByName("WaterShutModifier"):getValue() > -1


-- Функция для переключения состояния
local function toggle(optionName, turnOn)
    local options = SandboxOptions.new()
    options:copyValuesFrom(getSandboxOptions())
    options:getOptionByName(optionName):setValue(turnOn and 2147483647 or -1)
    getSandboxOptions():copyValuesFrom(options)
    getSandboxOptions():toLua()
end

-- Использование:  
-- toggle("ElecShutModifier", false) -- выключить электричество
-- toggle("WaterShutModifier", true)  -- включить воду