if isClient() then
	SandboxOptions.new():copyValuesFrom(getSandboxOptions());
end

local manager = ScriptManager.instance -- Получаем менеджер скриптов
local multiplier = SandboxVars.ToxicZonesStalker.FilterDurationMultiplier or 1.0; -- Получаем множитель длительности фильтра
local duration = tostring(multiplier * 0.00001); -- Получаем длительность фильтра

function Toxic_Tweaks() -- Функция для изменения параметров предмета
	manager:getItem("Base.GasMaskFilter"):DoParam("UseDelta".. " = " .. duration); -- Изменяем параметр UseDelta предмета
end

Events.OnGameBoot.Add(Toxic_Tweaks) -- Событие при загрузке игры