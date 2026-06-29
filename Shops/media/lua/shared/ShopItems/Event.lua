-- special-валюта (дорогой кран, лимит на сервере)
Shop.Items["Base.EventCoin"] = {
	tab = Tab.Event, price = 30000, quantity = 50,
}

-- luxury старт (items = прямая выдача, как recipe_htunpacksurvivorpack)
Shop.Items["Hydrocraft.Survivorpack"] = {
	tab = Tab.Event, price = 100, specialCoin = true,
	items = {
		{item = "Base.Bag_SurvivorBag"},
		{item = "Base.WaterBottleFull", quantity = 2},
		{item = "camping.CampfireKit"},
		{item = "Base.Axe"},
		{item = "Base.HuntingKnife"},
		{item = "Hydrocraft.HCMRE", quantity = 2},
		{item = "Base.Vest_BulletCivilian"},
		{item = "SM.Matches"},
		{item = "Base.Pot"},
		{item = "Hydrocraft.HCSleepingbagsleepin"},
	},
}

-- наборы за special (состав = recipe_htunpackpolicepack / militarypack)
Shop.Items["Hydrocraft.Policepack"] = {
	tab = Tab.Event, price = 150, specialCoin = true,
	items = {
		{item = "Base.Nightstick", quantity = 2},
		{item = "Base.Pistol"},
		{item = "Base.9mmClip"},
		{item = "Base.Bag_ZIP"},
		{item = "Base.Vest_BulletPolice"},
		{item = "Base.Hat_CrashHelmet_Police"},
		{item = "Base.Bullets9mmBox", quantity = 2},
		{item = "Base.HolsterDouble"},
		{item = "Base.Shoes_BlackBoots"},
	},
}
Shop.Items["Hydrocraft.Militarypack"] = {
	tab = Tab.Event, price = 500, specialCoin = true,
	items = {
		{item = "Hydrocraft.HCShotgunSilencer"},
		{item = "Hydrocraft.HCUziSilencer"},
		{item = "Hydrocraft.HCAA12"},
		{item = "Hydrocraft.HCMagAA12"},
		{item = "Base.Pistol3"},
		{item = "Base.44Clip"},
		{item = "Base.Bag_ALICEpack_Army"},
		{item = "Base.Vest_BulletArmy"},
		{item = "Base.Hat_Army"},
		{item = "Base.Bullets44Box", quantity = 2},
		{item = "Base.ShotgunShellsBox", quantity = 4},
		{item = "Base.HolsterDouble"},
		{item = "Base.Shoes_BlackBoots"},
	},
}

-- военная техника за special
Shop.Items["PinkSlip.74amgeneralM151A2"] = {
	tab = Tab.Event, price = 3000, specialCoin = true,
}
Shop.Items["PinkSlip.ATAJeep1"] = {
	tab = Tab.Event, price = 5500, specialCoin = true,
}
Shop.Items["PinkSlip.92amgeneralM998"] = {
	tab = Tab.Event, price = 8500, specialCoin = true,
}
