local nvctrl = require "NVAPI/ctrl/instance"


Events.OnGameStart.Add( function()

	nvctrl:start()

end )


Events.OnCreatePlayer.Add( function()

  nvctrl:start()

end )


Events.OnPlayerDeath.Add( function()

	nvctrl:clear()

end )
