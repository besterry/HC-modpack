local ModConfig = require "ModKeymap_Instance"

local module     = {}
module.instances = {}


--------------------------------------------------------------------------------
--
-- Get or create a Mod Keymap Instance
--
--------------------------------------------------------------------------------
module.getInstance = function( modname )

  -- if there is an instance available, then we just return it
  ------------------------------------------------------------
  local modcfg = module.instances[ modname ]
  if modcfg then
    return modcfg
  end

  -- no instance available, then we create and register a new one
  ---------------------------------------------------------------
  modcfg = ModConfig:new( modname )
  module.instances[ modname ] = modcfg

  return modcfg

end



--------------------------------------------------------------------------------
--
-- This function monitors any key pressed in the game.
--
-- When a key is pressed, we must loop over all registered ModKey instances and
-- look for a respective attached key. If there is one, then we trigger the
-- callback.
--
--------------------------------------------------------------------------------
function OnKeyPressed( key )

--  print("KEY PRESSED")
  for _, mki in pairs( module.instances ) do
    local callback = mki:get( key )
  --  print("CALLBACK ", callback )
    if callback then
      callback()
    end
  end

end

Events.OnKeyPressed.Add( OnKeyPressed )



return module
