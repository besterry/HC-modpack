if isClient() then
	SandboxOptions.new():copyValuesFrom(getSandboxOptions());
end

local manager = ScriptManager.instance
local multiplier = SandboxVars.ToxicZonesStalker.FilterDurationMultiplier or 1.0;
local duration = tostring(multiplier * 0.00001);

function Toxic_Tweaks()

manager:getItem("Base.GasMaskFilter"):DoParam("UseDelta".. " = " .. duration);

end

Events.OnGameBoot.Add(Toxic_Tweaks)