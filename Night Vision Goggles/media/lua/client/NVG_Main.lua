local nvctrl    			= require "NVAPI/ctrl/instance"
local ItemNightVision = require "NVAPI/item/ItemNightVision"
local ModKeymap 			= require "ModKeymap_Main"


Events.OnGameStart.Add( function()

	local keymap = ModKeymap.getInstance( "NVG" )
	keymap:add(
		'ToggleNightVision',
		function() nvctrl:toggle() end,
		49
	)

end )

local oldIsNightVision = ItemNightVision.isNightVision


function ItemNightVision:isNightVision()

	return oldIsNightVision( self ) or string.find( self:getBoundItem():getDisplayName(), 'Night Vision' ) ~= nil

end
