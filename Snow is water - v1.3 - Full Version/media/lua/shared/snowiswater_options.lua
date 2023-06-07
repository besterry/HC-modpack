--Default options.
local OPTIONS = { 
  snowscaler = 2,
  --box2 = false,
}

-- Connecting the options to the menu, so user can change them.
if ModOptions and ModOptions.getInstance then
  local settings = ModOptions:getInstance(OPTIONS, "Snow Is Water", "Snow Is Water Options")

  local drop1 = settings:getData("snowscaler")
  drop1[1] = "25%" --"Chioce One"
  drop1[2] = "50%" --"Chioce Two"
  drop1[3] = "75%" --"Chioce Three"
  drop1[4] = "100%" --"Chioce four"
  drop1.tooltip = "Snow filling containers rate VS when it's raining (100% means close to equal filling times)"

  settings.names = {
    snowscaler = "Snow to Rain ratio",
    --box2 = "Box Two",
  }

  --drop1.sandbox_path = "WorldOptions"

	--[[function drop1:OnApplyMainMenu(val)
    	self:resetLua() -- Reload all mods.
  	end--]]
end

--Make a link
SIS_MOD = {} -- global variable (pick another name!)
SIS_MOD.OPTIONS = OPTIONS