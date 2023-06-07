ISWorldObjectContextMenu.onTrade = function(worldobjects, player, otherPlayer)
	player:Say(getText("IGUI_FIX_T15K_TradeFix"))
	player:playEmote("shrug") 		-- показывает анимацию "не знаю" распуская руки перед собой на уровне живота
end