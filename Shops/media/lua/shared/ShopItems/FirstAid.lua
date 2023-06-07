Shop.Items["Base.Bandage"] = {
	tab = Tab.FirstAid, price = 250, --бинт
}

Shop.Items["Base.Bandaid"] = {
	tab = Tab.FirstAid, price = 30, -- пластырь
}

Shop.Items["Base.AlcoholWipes"] = {
	tab = Tab.FirstAid, price = 150, --спирт.салфетки
}

Shop.Items["Base.Pills"] = {
	tab = Tab.FirstAid, price = 120, -- обезбол
}

Shop.Items["SchizophreniaTrait.ChlorpromazinePill"] = {
	tab = Tab.FirstAid, price = 5000, -- хлорпромазин
}

Shop.Items["SchizophreniaTrait.Chlorpromazine"] = {
	tab = Tab.FirstAid, price = 35000,-- хлорпромазин пачка
}

Shop.Items["Base.SurvivalPack"] = {
	tab = Tab.FirstAid, price = 200,
	items = {
		{item="Base.AlcoholWipes"},
		{item="Base.Bandaid", quantity = 5},
	}
}
Shop.Items["LabItems.CmpSyringeWithCure"] = {
	tab = Tab.FirstAid, price = 200, specialCoin = true,
}