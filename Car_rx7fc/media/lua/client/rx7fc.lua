local function info()

	ISCarMechanicsOverlay.CarList["Base.rx7fc"] = {imgPrefix = "2door_", x=10,y=0};

end


Events.OnInitWorld.Add(info);
