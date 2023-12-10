
--Main--
ISCarMechanicsOverlay.CarList["Base.toyotahilux89singlecab"] = {imgPrefix = "toyotahilux89singlecab_", x=10, y=0};
ISCarMechanicsOverlay.CarList["Base.toyotahilux89extracab"] = {imgPrefix = "toyotahilux89extracab_", x=10, y=0};
ISCarMechanicsOverlay.CarList["Base.toyotahilux89dualcab"] = {imgPrefix = "toyotahilux89dualcab_", x=10, y=0};

--[[Doors--
ISCarMechanicsOverlay.PartList["Bonnet"].vehicles = ISCarMechanicsOverlay.PartList["EngineDoor"].vehicles or {};
ISCarMechanicsOverlay.PartList["Bonnet"].vehicles["toyotahilux89singlecab_"] = {img = "bonnet", x=86,y=134,x2=183,y2=209};
--
ISCarMechanicsOverlay.PartList["DoorFrontLeft"].vehicles = ISCarMechanicsOverlay.PartList["DoorFrontLeft"].vehicles or {};
ISCarMechanicsOverlay.PartList["DoorFrontLeft"].vehicles["toyotahilux89singlecab_"] = {img = "door_fl", x=75,y=225,x2=94,y2=309};

ISCarMechanicsOverlay.PartList["DoorFrontRight"].vehicles = ISCarMechanicsOverlay.PartList["DoorFrontLeft"].vehicles or {};
ISCarMechanicsOverlay.PartList["DoorFrontRight"].vehicles["toyotahilux89singlecab_"] = {img = "door_fl", x=174,y=309,x2=193,y2=225};
--
ISCarMechanicsOverlay.PartList["Battery"].vehicles = ISCarMechanicsOverlay.PartList["Battery"].vehicles or {};
ISCarMechanicsOverlay.PartList["Battery"].vehicles["toyotahilux89singlecab_"] = {img = "battery", x=72,y=64,x2=118,y2=99};
--
ISCarMechanicsOverlay.PartList["SuspensionFrontLeft"].vehicles = ISCarMechanicsOverlay.PartList["SuspensionFrontLeft"].vehicles or {};
ISCarMechanicsOverlay.PartList["SuspensionFrontLeft"].vehicles["toyotahilux89singlecab_"] = {img="suspension_fl", x=21,y=181,x2=59,y2=212};

ISCarMechanicsOverlay.PartList["SuspensionFrontRight"].vehicles = ISCarMechanicsOverlay.PartList["SuspensionFrontRight"].vehicles or {};
ISCarMechanicsOverlay.PartList["SuspensionFrontRight"].vehicles["toyotahilux89singlecab_"] = {img="suspension_fr", x=228,y=181,x2=264,y2=212};

ISCarMechanicsOverlay.PartList["SuspensionRearLeft"].vehicles = ISCarMechanicsOverlay.PartList["SuspensionRearLeft"].vehicles or {};
ISCarMechanicsOverlay.PartList["SuspensionRearLeft"].vehicles["toyotahilux89singlecab_"] = {img="suspension_rl", x=21,y=368,x2=59,y2=399};

ISCarMechanicsOverlay.PartList["SuspensionRearRight"].vehicles = ISCarMechanicsOverlay.PartList["SuspensionRearRight"].vehicles or {};
ISCarMechanicsOverlay.PartList["SuspensionRearRight"].vehicles["toyotahilux89singlecab_"] = {img="suspension_rr", x=231,y=368,x2=264,y2=399};
--]]
