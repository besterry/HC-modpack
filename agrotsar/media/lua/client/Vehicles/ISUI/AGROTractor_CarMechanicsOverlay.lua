ISCarMechanicsOverlay.CarList["Base.Agrotractor"] = {imgPrefix = "agrotractor_", x=0,y=0};
ISCarMechanicsOverlay.CarList["Base.TrailerAgroplough"] = {imgPrefix = "agroplough_", x=0,y=0};
ISCarMechanicsOverlay.CarList["Base.TrailerAgroseeder"] = {imgPrefix = "agroseeder_", x=0,y=0};


-- ISCarMechanicsOverlay.PartList["EngineDoor"].vehicles["agrotractor_"] = {x=101,y=167,x2=159,y2=309};
if not ISCarMechanicsOverlay.PartList["Engine"].vehicles then
	ISCarMechanicsOverlay.PartList["Engine"].vehicles = {}
end
ISCarMechanicsOverlay.PartList["Engine"].vehicles["agrotractor_"] = {x=128,y=77 ,x2=228,y2=137};
ISCarMechanicsOverlay.PartList["Battery"].vehicles["agrotractor_"] = {x=62,y=92,x2=107,y2=123};

if not ISCarMechanicsOverlay.PartList["Muffler"].vehicles then
	ISCarMechanicsOverlay.PartList["Muffler"].vehicles = {}
end
ISCarMechanicsOverlay.PartList["Muffler"].vehicles["agrotractor_"] = {x=178,y=270,x2=247,y2=307};

if not ISCarMechanicsOverlay.PartList["GasTank"].vehicles then
	ISCarMechanicsOverlay.PartList["GasTank"].vehicles = {}
end
ISCarMechanicsOverlay.PartList["GasTank"].vehicles["agrotractor_"] = {x=86,y=496,x2=173,y2=554};

ISCarMechanicsOverlay.PartList["TireFrontLeft"].vehicles["agrotractor_"] = {x=60,y=155,x2=88,y2=249};
ISCarMechanicsOverlay.PartList["TireFrontRight"].vehicles["agrotractor_"] = {x=174,y=155,x2=201,y2=249};

ISCarMechanicsOverlay.PartList["TireRearLeft"].vehicles["agrotractor_"] = {x=21,y=323,x2=69,y2=454};
ISCarMechanicsOverlay.PartList["TireRearRight"].vehicles["agrotractor_"] = {x=192,y=323,x2=240,y2=454};

ISCarMechanicsOverlay.PartList["BrakeRearLeft"].vehicles["agrotractor_"] = {x=8,y=502,x2=48,y2=541};
ISCarMechanicsOverlay.PartList["BrakeRearRight"].vehicles["agrotractor_"] = {x=218,y=502,x2=258,y2=541};

ISCarMechanicsOverlay.PartList["SuspensionRearLeft"].vehicles["agrotractor_"] = {x=8,y=466,x2=48,y2=501};
ISCarMechanicsOverlay.PartList["SuspensionRearRight"].vehicles["agrotractor_"] = {x=218,y=466,x2=258,y2=501};

ISCarMechanicsOverlay.PartList["WindshieldRear"].vehicles["agrotractor_"] = {x=76,y=418,x2=184,y2=428};
ISCarMechanicsOverlay.PartList["Windshield"].vehicles["agrotractor_"] = {x=100,y=310,x2=160,y2=316};



ISCarMechanicsOverlay.PartList["AgroSeederTankLeft"] = {img="seedertank_left", x=34,y=119,x2=126,y2=172, vehicles={}};
ISCarMechanicsOverlay.PartList["AgroSeederTankRight"] = {img="seedertank_right", x=141,y=119,x2=235,y2=172, vehicles={}};
ISCarMechanicsOverlay.PartList["AgroSeederPlateLeft"] = {img="seederflap_left", x=34,y=213,x2=126,y2=264, vehicles={}};
ISCarMechanicsOverlay.PartList["AgroSeederPlateRight"] = {img="seederflap_right", x=48,y=213,x2=92,y2=264, vehicles={}};

ISCarMechanicsOverlay.PartList["AgroSeederTankLeft"].vehicles["agroseeder_"] = {x=34,y=119,x2=126,y2=172};
ISCarMechanicsOverlay.PartList["AgroSeederTankRight"].vehicles["agroseeder_"] = {x=141,y=119,x2=235,y2=172};
ISCarMechanicsOverlay.PartList["AgroSeederPlateLeft"].vehicles["agroseeder_"] = {x=34,y=213,x2=126,y2=264};
ISCarMechanicsOverlay.PartList["AgroSeederPlateRight"].vehicles["agroseeder_"] = {x=141,y=213,x2=235,y2=264};

ISCarMechanicsOverlay.PartList["TireFrontLeft"].vehicles["agroseeder_"] = {x=20,y=124,x2=33,y2=157};
ISCarMechanicsOverlay.PartList["TireFrontRight"].vehicles["agroseeder_"] = {x=235,y=124,x2=248,y2=157};
ISCarMechanicsOverlay.PartList["TireRearLeft"].vehicles["agroseeder_"] = {x=32,y=176,x2=127,y2=194};
ISCarMechanicsOverlay.PartList["TireRearRight"].vehicles["agroseeder_"] = {x=139,y=176,x2=236,y2=194};


ISCarMechanicsOverlay.PartList["AgroPlowshareLeft"] = {img="plowshare_left", x=71,y=140,x2=114,y2=178, vehicles={}};
ISCarMechanicsOverlay.PartList["AgroPlowshareRight"] = {img="plowshare_right", x=137,y=140,x2=184,y2=178, vehicles={}};

ISCarMechanicsOverlay.PartList["AgroPlowshareLeft"].vehicles["agroplough_"] = {x=71,y=140,x2=114,y2=178};
ISCarMechanicsOverlay.PartList["AgroPlowshareRight"].vehicles["agroplough_"] = {x=137,y=140,x2=184,y2=178};

ISCarMechanicsOverlay.PartList["TireFrontLeft"].vehicles["agroplough_"] = {x=52,y=161,x2=66,y2=194};
ISCarMechanicsOverlay.PartList["TireFrontRight"].vehicles["agroplough_"] = {x=186,y=161,x2=200,y2=194};