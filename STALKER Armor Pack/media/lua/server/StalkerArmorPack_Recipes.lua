local GasMaskFilter = {
	"GasMaskFilter",
}

function GiveGasMaskFilter(items, result,  player)
    player:getInventory():AddItem("GasMaskFilter")
end