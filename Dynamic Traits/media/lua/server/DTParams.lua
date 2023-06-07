-- Change to fatigue decrease by Vitamins due to new Overdose mechanic
local vitamins = ScriptManager.instance:getItem("Base.PillsVitamins")
if vitamins then
	vitamins:DoParam("FatigueChange = -7");
end
