local function info()

	ISCarMechanicsOverlay.CarList["Base.eclipse95rs"] = {imgPrefix = "sportscar_", x=10,y=0};
	ISCarMechanicsOverlay.CarList["Base.eclipse95gs"] = {imgPrefix = "sportscar_", x=10,y=0};
	ISCarMechanicsOverlay.CarList["Base.eclipse95gsx"] = {imgPrefix = "sportscar_", x=10,y=0};
	ISCarMechanicsOverlay.CarList["Base.eclipse95modified"] = {imgPrefix = "sportscar_", x=10,y=0};

end


Events.OnInitWorld.Add(info);